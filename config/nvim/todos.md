# TODOS 

- Draw Detection
- Hash fills up super quick? like my default is 4 threads i think and against stockfish in 5 second + 0.5 at the end oopsmate has 100% hashful stockfish is like 1.3%
- Pondermove


- mmdc -i in.mmd -o out.pdf --pdfFit, --pdfFit scales PDF to fit chart.
- Format shit properlty worksheet 0
- 6 minutes 10 seconds
- Upload multiple urls (text,vs csv) (Lists tab)
    <!-- - Allow users to create new list  -->
    <!-- - Allow users to either select urls from the project we are currently on -->
    <!-- - Or, multi-line textbox, split urls by new line, and automatically add the lists that exist in the project into that list -->
        <!-- - If a list is entered that doesn't exist in the current project (say different domain), create a new project for it -->
<!-- - Empty State ( New Project Thing ) -->
    <!-- - First run, auto-switch to the created project, show live progress -->
<!-- - Actionable Steps ( Gemini API ) -->
<!--     - AIzaSyDlMRatTJ2z1qubpBvT7zUKY1o0uaAk0rM -->
<!-- - Admin View Tunable Metrics -->
- Landing Page
- Stripe Payment ( on signup )
- Clean up all linting erros,
- Get 100 on react-doctor

---

# NNUEBIE Performance Parity Spec (main branch, AVX2)

Date: 2026-02-27
Branch scope: `main` (AVX2 only)
Goal: Match Stockfish NNUE throughput without changing evaluation parity.

This document captures findings from the `nnuebie` main branch and the Stockfish reference code in `archive/nnue/Stockfish-sf_17.1/`. It is intended to be a thorough spec sheet with the what, why, and how of each optimization opportunity.

## Baseline (from repo docs)

From `README.md` (last recorded on main):

- Full refresh: ~836k evals/sec
- Incremental: ~1.39M evals/sec
- Speedup: ~1.66x

Known perf hot spots reported in the repo (main `README.md`):

- `<AffineTransform as Layer>::propagate`
- `NNUEProbe::evaluate`
- `finny_tables::update_accumulator_refresh_cache`
- `accumulator::update_accumulators_single_pass_avx2`
- `NNUEProbe::set_position`

This spec assumes AVX2 builds (`RUSTFLAGS="-C target-cpu=native"` and/or `--features simd_avx2`). AVX512 is intentionally excluded due to prior build/runtime issues.

## Current Architecture Summary

Key pipeline pieces in main:

- Feature transformer: `src/feature_transformer.rs`
  - LEB128 load, weight permutation, scale by 2
- Accumulator: `src/accumulator.rs`
  - AVX2 add/remove/update kernels
- Finny tables: `src/finny_tables.rs` + `src/accumulator_refresh.rs`
  - AVX2 tiled refresh/update+copy
- Transform features: `src/network.rs`
  - AVX2 multiply/pack path
- Dense layers: `src/layers.rs`
  - `AffineTransform` only (dense), AVX2 path
- Stack/state: `src/accumulator_stack.rs`
  - Incremental updates + refresh path
- Probe API: `src/nnue.rs`

## Architectural Differences vs Stockfish

| Area | Stockfish | nnuebie main | Impact |
| --- | --- | --- | --- |
| FC_0 implementation | `AffineTransformSparseInput` (block-sparse input + dpbusd) | Dense `AffineTransform` with chunk skip | Major throughput gap in forward pass |
| SIMD dot-product | `dpbusd` (VNNI when available) | `maddubs + madd` only | Slower matmul on AVX2/AVX2-VNNI CPUs |
| Runtime dispatch | Compile-time SIMD path (selected at build) | Per-call `is_x86_feature_detected!` in hot loops | Extra branches in hot path |
| Cache layout | Inline arrays, contiguous | `AlignedBuffer` per cache entry | Fragmentation + cache/TLB misses |
| Accumulator stack reset | Reuses buffers | Reallocates on reset (`AccumulatorState::new`) | Heavy when `set_position` is frequent |
| FC_2 specialization | Dedicated small kernel | Same dense kernel for all | Missed fast-path for last layer |
| Feature index update | Uses bitboards from `Position` | Rebuilds bitboards from piece list | Extra work on cache refresh |
| FC_0 weight layout | Scrambled for dpbusd | Only packus permutation | Blocks dpbusd/sparse kernels |

## Correctness and Safety Issues (P0)

1. **Out-of-bounds read in FC_1 input**
   - **Where:** `src/network.rs` (`ScratchBuffer::fc_1_in` length is 30)
   - **Why:** `AffineTransform` pads input dims to 32, AVX2 path does `_mm256_load_si256` on `input` (expects 32 bytes)
   - **Impact:** UB / incorrect eval / performance anomalies
   - **Fix:** Make `fc_1_in` length 32 and zero the padding bytes (indices 30..31) each eval

2. **`AlignedBuffer::zero_out` writes too many bytes**
   - **Where:** `src/aligned.rs`
   - **Why:** `ptr::write_bytes` expects element count, but current code passes `len * size_of::<T>()`
   - **Impact:** Memory corruption if the method is ever called
   - **Fix:** Use `ptr::write_bytes(self.ptr.as_ptr(), 0, self.len)`

## Optimization Opportunities (Prioritized)

### P1 - Forward Pass Hot Path

**A. Implement Sparse FC_0 (Stockfish-style)**

- **What:** Replace `AffineTransformSparseInput = AffineTransform` with a real sparse input kernel for FC_0.
- **Why:** Stockfish uses block-sparse input and dpbusd; this is a major throughput multiplier for the forward pass.
- **How:**
  - Port `AffineTransformSparseInput` from `archive/nnue/Stockfish-sf_17.1/src/nnue/layers/affine_transform_sparse_input.h`.
  - Implement `find_nnz` for non-zero 32-bit chunks of input (input is `u8`, treat as `i32` blocks as Stockfish does).
  - Use AVX2 `dpbusd` equivalent when VNNI is present, else maddubs+madd.
  - This requires a **weight layout change**: follow Stockfish `get_weight_index` / `get_weight_index_scrambled` for `ChunkSize = 4`.
  - Apply the scrambled layout to FC_0 weights at load time only.

**B. AVX2-VNNI dpbusd fast path (optional, safe)**

- **What:** Use `_mm256_dpbusd_epi32` when AVX2-VNNI is available.
- **Why:** Hardware dot-product is substantially faster than maddubs+madd.
- **How:**
  - Add an AVX2-VNNI feature gate (`is_x86_feature_detected!("avx2") && is_x86_feature_detected!("avxvnni")`).
  - Provide dpbusd kernels for FC_0 (sparse) and FC_1/FC_2 (dense).
  - Keep maddubs+madd as fallback.

**C. Dedicated FC_2 kernel**

- **What:** Implement a specialized kernel for output dims = 1 (32 inputs).
- **Why:** Avoid full 4-output loop and reduce overhead.
- **How:**
  - Mirror Stockfish’s `AffineTransform` output=1 path.
  - Use a single vector accumulator and horizontal sum.

### P1 - Accumulator/Finny Hot Path

**D. Eliminate per-eval allocations in set_position**

- **What:** Avoid `AccumulatorState::new()` on `AccumulatorStack::reset`.
- **Why:** `set_position` currently allocates aligned buffers every time.
- **How:**
  - Add `AccumulatorState::clear()` to reuse existing `AlignedBuffer`s and reset computed flags.
  - Update `AccumulatorStack::reset` to clear in-place.

**E. Avoid heap allocation for `pieces` vectors**

- **What:** Replace `Vec` with fixed-size arrays or a small buffer.
- **Why:** `make_move` and `set_position` build `Vec` each call.
- **How:**
  - Use `[ (usize, usize); 32 ]` with a count.
  - Thread-local scratch buffers or `SmallVec<[T; 32]>`.

**F. Cache layout and alignment**

- **What:** Make `AccumulatorCacheEntry` and `Accumulator` store inline arrays (contiguous) instead of `AlignedBuffer` per entry.
- **Why:** Improves locality, reduces allocations and fragmentation.
- **How:**
  - Use `#[repr(align(64))] struct` with `[i16; SIZE]` and `[i32; PSQT_BUCKETS]`.
  - For generic size, use `Box<[i16; SIZE]>` with aligned allocation if inline is too large.

**G. Update Finny refresh to use engine bitboards**

- **What:** Reuse bitboards from engine state instead of rebuilding from pieces.
- **Why:** `update_accumulator_refresh_cache` recomputes `current_color_bb` and `current_type_bb`.
- **How:**
  - Accept `by_color_bb` and `by_type_bb` from the caller.
  - Provide a `NNUEProbe` helper that maintains these bitboards incrementally.

### P2 - Dispatch and Micro-optimizations

**H. Remove runtime feature detection in hot loops**

- **What:** Select function pointers at init, not per call.
- **Why:** Avoid `is_x86_feature_detected!` overhead in `AffineTransform` and `transform_features`.
- **How:**
  - Store `propagate_fn` in `AffineTransform` and `transform_features_fn` in `Network`.
  - Initialize based on compile-time features and runtime CPUID.

**I. Review chunk skip in `AffineTransform`**

- **What:** Reassess `_mm256_testz_si256` skip logic in dense paths.
- **Why:** Branch mispredicts can outweigh benefits for dense inputs.
- **How:**
  - Keep for sparse inputs only.
  - Remove for FC_1/FC_2 if not beneficial.

**J. Reduce slice creation in incremental update**

- **What:** Pass weight indices rather than slices to `update_accumulators_single_pass_*`.
- **Why:** Avoid slice creation and bounds checks in tight loops.
- **How:**
  - Change kernel signature to `(prev, curr, weights, added_idx, removed_idx)`.
  - Compute weight pointers inside the kernel.

## Implementation Notes and Design Constraints

- **Maintain evaluation parity:** Changes must produce identical output to Stockfish.
- **AVX2-only baseline:** Keep AVX2 as the required SIMD baseline. AVX2-VNNI can be optional.
- **No AVX512 assumptions:** Avoid AVX512 paths on main due to known errors.
- **Weights layout:** Any dpbusd path requires matching Stockfish’s weight scrambling.
- **Aligned loads:** If input dims are padded, ensure input buffers are padded and zeroed.

## Proposed Work Plan

1. **Fix correctness issues**
   - `fc_1_in` padding (length 32 + zero tail)
   - `AlignedBuffer::zero_out` count

2. **Sparse FC_0 + dpbusd infrastructure**
   - Implement `AffineTransformSparseInput`
   - Add weight layout scrambling for FC_0
   - Add AVX2-VNNI dpbusd path (optional)

3. **Finny + Accumulator memory optimizations**
   - In-place reset of `AccumulatorState`
   - Contiguous cache entries
   - Avoid per-call `Vec` in `set_position` and `make_move`

4. **Dispatch cleanup**
   - Initialize function pointers once per layer or per network
   - Remove hot-path `is_x86_feature_detected!`

5. **Specialized FC_2 kernel**
   - Single-output fast path

## Validation Plan

1. **Correctness**
   - Run `cargo run --release --bin validate` (compare vs Stockfish)
   - Test a set of fixed positions for exact eval equality

2. **Performance**
   - `cargo run --release --bin benchmark` with `RUSTFLAGS="-C target-cpu=native"`
   - `perf record` + `perf report` to confirm hot spot reduction

3. **Regression**
   - Keep a small test harness of 50-100 positions to compare scores
   - Lock output to identical integer values

## File References (main branch)

- `src/layers.rs` (AffineTransform, activations)
- `src/network.rs` (forward pass, transform features)
- `src/feature_transformer.rs` (weight permutation)
- `src/accumulator.rs` (incremental updates)
- `src/accumulator_refresh.rs` (tiled refresh)
- `src/finny_tables.rs` (cache refresh/update)
- `src/accumulator_stack.rs` (stack update logic)
- `src/nnue.rs` (probe API)
- `archive/nnue/Stockfish-sf_17.1/src/nnue/layers/affine_transform_sparse_input.h` (reference)
- `archive/nnue/Stockfish-sf_17.1/src/nnue/layers/affine_transform.h` (reference)

---

# REVSERP PageSpeed Thing
- It's cause if we do page speed for all the pages, it's cooked we are limited to like 3 without the token
