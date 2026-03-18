# Start Here
<!-- - Cargo.toml - package shape, local crates, binary/library split -->
<!-- - src/lib.rs - the subsystem map for the whole engine -->
<!-- - src/main.rs - actual startup path: warm tables, init LMR, run UCI -->
<!-- - .cargo/config.toml - performance assumptions (target-cpu=native, avx2) -->
<!-- - flake.nix - dev/build environment context -->
1. External Interface / Control Flow
<!-- - src/uci.rs -->
<!-- - src/uci/engine.rs -->
- src/uci/run.rs
- src/uci/parse.rs
- src/time_control.rs
This gives you the engine lifecycle, command surface, option handling, threading, stop signals, and time budgeting.
2. Search Architecture
- src/search/mod.rs
- src/search/parallel.rs
- src/search/params.rs
- src/search/score.rs
- src/search/alphabeta.rs
- src/search/alphabeta/root.rs
- src/search/alphabeta/move_search.rs
- src/search/alphabeta/negamax.rs
- src/search/alphabeta/iid.rs
- src/search/qsearch.rs
- src/search/ordering.rs
- src/search/pruning.rs
- src/search/pruning/null_move.rs
- src/search/pruning/futility.rs
- src/search/pruning/razoring.rs
- src/search/pruning/lmr.rs
- src/search/pruning/probcut.rs
This is the heart of the whitepaper: iterative deepening, aspiration windows, alpha-beta/PVS, qsearch, move ordering, pruning, and Lazy SMP style parallel search.
3. Board Representation and State Transitions
- src/types.rs
- src/position.rs
- src/position/state.rs
- src/position/fen.rs
- src/position/hash.rs
- src/position/make.rs
- src/position/unmake.rs
- src/position/draw.rs
- src/zobrist.rs
Read this before movegen internals so you understand what a Position really stores and how it changes.
4. Move Generation and Legality
- src/movegen.rs
- src/movegen/generation.rs
- src/movegen/constraints.rs
- src/movegen/attacks.rs
- src/movegen/captures.rs
- src/movegen/pawns.rs
- src/movegen/pawn_captures.rs
- src/movegen/leapers.rs
- src/movegen/sliders.rs
- src/movegen/king.rs
This captures legal move generation, attack maps, checks, pins, sliders, and piece-specific generation.
5. Evaluation
- src/evaluate.rs
- src/evaluate/probe.rs
- src/evaluate/delta.rs
- src/evaluate/mapping.rs
- src/evaluate/networks.rs
- src/see.rs
This shows how the engine bridges its board representation into NNUE and how incremental eval is maintained.
6. Core Search Infrastructure
- src/tpt.rs - transposition table
- src/see.rs - static exchange eval, also search support
- src/zobrist.rs - hash key generation
If you’re writing a technical paper, these deserve their own subsection.
7. Tests and Behavioral Evidence
- src/benchmark_tests.rs
- src/position/tests.rs
- src/evaluate/tests.rs
These often expose intended invariants better than implementation alone.
8. Dependency Crate: strikes
- crates/strikes/Cargo.toml
- crates/strikes/src/lib.rs
- crates/strikes/src/enumerate.rs
- crates/strikes/src/table_builder.rs
- crates/strikes/src/attacks/mod.rs
- crates/strikes/src/attacks/pawns.rs
- crates/strikes/src/attacks/knights.rs
- crates/strikes/src/attacks/kings.rs
- crates/strikes/src/attacks/bishops.rs
- crates/strikes/src/attacks/rooks.rs
- crates/strikes/src/paths/mod.rs
- crates/strikes/src/paths/between.rs
- crates/strikes/src/paths/through.rs
This crate underpins movegen and attack lookups, so it matters for completeness.
9. Dependency Crate: nnuebie
- crates/nnuebie/Cargo.toml
- crates/nnuebie/src/lib.rs
- crates/nnuebie/src/types.rs
- crates/nnuebie/src/architecture.rs
- crates/nnuebie/src/features.rs
- crates/nnuebie/src/feature_transformer.rs
- crates/nnuebie/src/piece_list.rs
- crates/nnuebie/src/aligned.rs
- crates/nnuebie/src/loader.rs
- crates/nnuebie/src/network/mod.rs
- crates/nnuebie/src/network/load.rs
- crates/nnuebie/src/network/evaluate.rs
- crates/nnuebie/src/layers/mod.rs
- crates/nnuebie/src/layers/affine.rs
- crates/nnuebie/src/layers/sparse.rs
- crates/nnuebie/src/layers/activations.rs
- crates/nnuebie/src/accumulator/mod.rs
- crates/nnuebie/src/accumulator/core.rs
- crates/nnuebie/src/accumulator/simd.rs
- crates/nnuebie/src/accumulator_stack/mod.rs
- crates/nnuebie/src/accumulator_stack/state.rs
- crates/nnuebie/src/accumulator_stack/stack.rs
- crates/nnuebie/src/accumulator_stack/updates.rs
- crates/nnuebie/src/accumulator_refresh.rs
- crates/nnuebie/src/finny_tables/mod.rs
- crates/nnuebie/src/finny_tables/cache.rs
- crates/nnuebie/src/finny_tables/refresh.rs
- crates/nnuebie/src/nnue/mod.rs
- crates/nnuebie/src/nnue/delta.rs
- crates/nnuebie/src/nnue/probe.rs
- crates/nnuebie/src/nnue/probe/board.rs
- crates/nnuebie/src/nnue/probe/moves.rs
- crates/nnuebie/src/nnue/probe/evaluate.rs
- crates/nnuebie/src/uci.rs
Then read the explanation docs:
- crates/nnuebie/NNUE_COMPLETE_GUIDE.md
- crates/nnuebie/archive/nnue/networks/networks.md
10. Small Utility Crate
- crates/utilities/Cargo.toml
- crates/utilities/src/lib.rs
- crates/utilities/src/algebraic.rs
- crates/utilities/src/board.rs
11. Examples / Validation / Tests in nnuebie
- crates/nnuebie/examples/engine_usage.rs
- crates/nnuebie/examples/multithreaded.rs
- crates/nnuebie/src/bin/validate.rs
- crates/nnuebie/src/bin/benchmark.rs
- crates/nnuebie/src/tests/mod.rs
- crates/nnuebie/src/tests/common.rs
- crates/nnuebie/src/tests/integration_api.rs
- crates/nnuebie/src/tests/incremental.rs
- crates/nnuebie/src/tests/multithreaded.rs
- crates/nnuebie/src/tests/manual.rs
12. Historical Evolution / Why Certain Heuristics Exist
Read these last, after you understand the code:
- archive/data/results/initial_v2_test.md
- archive/data/results/v2_mull_move_pruning.md
- archive/data/results/v3_late_move_reduction.md
- archive/data/results/v4_killer_heuristic.md
- archive/data/results/v5_futility_pruning.md
- archive/data/results/v6_reverse_futility_pruning.md
- archive/data/results/v7_principle_variation_search.md
- archive/data/results/v8_check_extentions.md
- archive/data/results/v9_razoring.md
- archive/data/results/v10_aspiration_windows.md
- archive/data/results/v11_interal_iterative_deepening.md
- archive/data/results/v12_static_exchange_eval.md
- archive/data/results/v13_history_heuristic.md
- archive/data/results/v14_tuned_params.md
- archive/data/results/v15_probcut.md
- archive/data/results/v16_lazysmp.md
- archive/data/results/v17_nnue_oops.md


# School

- Find and fix bugs 
- Better Time Control 
    - RUns out on time -xx:xx 5 + 0.1s time control
## OopsMate

- "Even" playing field?
    - To benchmark the elo of how much lazysmp gained, i will have to increase the thread count, so it'll be 4 threads vs 1 thread? Not an even playing ground
    - AlphaBeta pruning's impact is exponential. Better the move ordering more pruning, can't really be measured directly?
    - Rating against engine, stockfish is ccrl rated turns out? against sayuri and goldfish too. But stockfish looses to sayuri? in the same ccrl scale?
- Societal Contribution?:
    - `strikes` crate, provides attack patterns in the nanoseconds
    - `nnuebie` only stockfish nnue function port to reach full parity of evaluation metrics. Evidently caused a ~+1200 ccrl elo increase in OopsMate

# TODO: 
    - Clean Up Codebase ( Oopsmate & nnuebie both)
    - Will also be training custom NNUE network. ( not guaranteed; big data.)
    - Reports & Stuff

---
# Work
- [ ] GSC

- create list only in project level, dont need new tab
- Summary tab, SEO, AEO, PageSpeed, Health & Issues
- Search page, group things together, show pie chart thng like revscore 

revscore -> seo, aeo , page speed
seo -> content, technical indexibility 
aeo -> eeat 

---
