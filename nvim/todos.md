# TODOS 

## 
<!-- - Fix Issues Page ( Scroll ) -->
<!-- - Page Speed tab, bug where only selecting one didn't show up the bug. -->
<!-- - SEO Audit Tab No Metrics For Search Appereance and other stat boxes, crossed out -->
<!-- - SEO Audit Show Multiple Graphs For The comparison ( compare against multiple metrics ) -->
- Graphs, if gone down show red else show green from that point on type shi
<!-- - Previous vs current metrics ( red if gone down, green if up strike through type thing) -->
<!-- - NAN Error On SEO Audit -->
<!-- - Fix linting errors -->

<!-- - Make links clickable ( ulrs across everywhere ) -->

- Specific URL track list thing
<!-- - Javascript Crawler Expose -->


- The toggle project / list is different color, when list is selected it's green its no bueno
- when a list is created in the url bar thing, the create list has weird padding and makes it misaligned with the rest 


https://pswoyam.com.np/, https://blogs.pswoyam.com.np/posts/chess_engine/pext/, https://blogs.pswoyam.com.np/posts/chess_engine/artifact_report/

# REV SCORE Refactoring - Project Notes

## Problem

The main dashboard has **redundant information** across the E-E-A-T Analysis and SEO Audit tabs:

- "Pages with Author" appears in E-E-A-T and Author Attribution below (same data)
- "Pages with Schema" = Structured Data but unclear correlation
- SEO Audit: "Search Appearance" vs "All Categories Breakdown → Search Appearance" (duplicate)
- No clarity on how "Overall Health Score" is calculated
- "Technical SEO", "Content Quality" - unclear what's included

**Goal**: Create a unified **REV SCORE** that aggregates all signals into one clear metric, eliminating redundancy and making correlations obvious.

---

## Current State Analysis

### E-E-A-T Tab Metrics (100-point system)

| Signal | Points | What it checks |
|--------|--------|----------------|
| HTTPS | 10 | URL starts with https:// |
| Author | 20 | author metadata or og:author exists |
| Schema | 25 | json_ld exists |
| External Links | 15 | external_links count (capped at 15 pts) |
| OG Tags | 10 | og:title exists |
| Content | 20 | word_count >= 300 |

### SEO Audit Tab Categories (10 categories, weighted)

| Category | Weight | Issues Tracked |
|----------|--------|----------------|
| Search Appearance | 15% | Title, meta, H1 tags |
| Content & Semantic SEO | 15% | Thin content, duplicates |
| In-Depth Content (EEAT) | 15% | Structured data (only - bug?) |
| Indexability & Crawlability | 10% | Noindex, nofollow |
| Multimedia Optimization | 10% | Image alt text |
| Performance (CWV) | 10% | Response time, page size |
| User Experience & Social | 10% | OG tags, Twitter cards |
| Technical SEO & Security | 5% | Viewport, mobile |
| Internal Linking | 5% | NOT IMPLEMENTED |
| Advanced AEO Factors | 5% | NOT IMPLEMENTED |

### Issue Categories Tracked (issue_detector.py)

- **SEO**: Missing title, title length, meta description, H1 tags
- **Content**: Thin content (<300 words)
- **Technical**: HTTP errors (4xx/5xx), redirects, canonical URLs
- **Mobile**: Missing viewport meta
- **Accessibility**: Language attribute, image alt text
- **Social**: OpenGraph tags, Twitter cards
- **Structured Data**: Missing JSON-LD/Schema.org
- **Performance**: Slow response (>3s), large page size (>3MB)
- **Indexability**: Noindex, nofollow directives
- **Duplication**: Content similarity detection

---

## Identified Redundancies

| Duplication | Appears In |
|------------|------------|
| Author Attribution | E-E-A-T (Author signal) + SEO category |
| Schema/Structured Data | E-E-A-T (Schema signal) + SEO "In-Depth Content" |
| Open Graph Tags | E-E-A-T (OG Tags) + SEO "UX & Social" |
| Content Quality (word count) | E-E-A-T (Content) + SEO "Content & Semantic" |
| External Links | E-E-A-T + Content & Semantic |
| HTTPS Security | E-E-A-T + SEO "Technical SEO" |

---

## Proposed REV SCORE Structure

### Master Score: REV SCORE (0-100)

```
                          ┌──────────────────────────┐
                          │     REV SCORE (0-100)    │
                          │    (Aggregate of all)    │
                          └────────────┬─────────────┘
                                       │
    ┌──────────────┬─────────────┬─────┴────┬──────────────┬──────────────┐
    │              │             │          │              │              │
    ▼              ▼             ▼          ▼              ▼              ▼
┌─────────┐  ┌───────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐  ┌─────────┐
│DISCOVER-│  │ AUTHORITY │ │ CONTENT  │ │  TRUST   │ │PERFORM-│  │ MULTI-  │
│ABILITY  │  │           │ │  DEPTH   │ │          │ │ANCE    │  │  MEDIA  │
│  (25%)  │  │   (20%)   │ │  (20%)   │ │  (15%)   │ │ (15%)  │  │  (5%)   │
└────┬────┘  └─────┬─────┘ └────┬─────┘ └─────┬─────┘ └────┬────┘  └────┬────┘
     │              │            │             │            │             │
 Title         Author       Word count    HTTPS         Speed        Alt text
 Meta          Schema       Indexability  Canonical     Size         Images
 H1            Ext Links   Dup content   OG/Twitter    CWV          missing
 Schema(SERP)  (citations)               Schema(valid) Mobile       
 Internal LP                 ← moved here←
```

### Category Breakdown

#### 1. DISCOVERABILITY (25%)
How easily search engines can find, parse, and understand your pages.

| Signal | Source | Points |
|--------|--------|--------|
| Title Optimization | SEO Audit | 6% |
| Meta Descriptions | SEO Audit | 6% |
| H1 Structure | SEO Audit | 5% |
| Schema (SERP) | E-E-A-T + SEO | 5% |
| Indexability | SEO Audit | 3% |

**Rationale**: Title/Meta/H1 are the primary SERP signals. Schema helps rich results. Indexability ensures pages can be crawled.

#### 2. AUTHORITY (20%)
How authoritative your content appears to search engines.

| Signal | Source | Points |
|--------|--------|--------|
| Author Attribution | E-E-A-T | 6% |
| External Citations | E-E-A-T | 6% |
| Schema (Entity) | E-E-A-T | 5% |
| Internal Linking | SEO (moved from placeholder) | 3% |

**Rationale**: Author + External links + Schema = classic E-E-A-T authority signals. Internal linking helps crawl depth but does NOT equal authority - moved here for organizational clarity.

#### 3. CONTENT DEPTH (20%)
Quality and depth of page content.

| Signal | Source | Points |
|--------|--------|--------|
| Word Count | E-E-A-T | 8% |
| Duplicate Content | SEO Audit | 6% |
| Semantic Markup | E-E-A-T + SEO | 6% |

**Rationale**: Combines thin content detection with content depth. The SEO "In-Depth Content (EEAT)" was a misnomer - it only tracked Schema. Now it properly includes content depth.

#### 4. TRUST (15%)
 signals that verify site legitimacy and safety.

| Signal | Source | Points |
|--------|--------|--------|
| HTTPS | E-E-A-T | 5% |
| Canonical URLs | SEO Audit | 4% |
| OpenGraph/Twitter | E-E-A-T + SEO | 3% |
| Schema Validation | SEO Audit | 3% |

**Rationale**: Security (HTTPS), proper URL canonicalization, and social meta signals all contribute to trust.

#### 5. PERFORMANCE (15%)
How fast and responsive your pages are.

| Signal | Source | Points |
|--------|--------|--------|
| Response Speed | SEO Audit | 5% |
| Page Size | SEO Audit | 4% |
| Core Web Vitals | PageSpeed API | 4% |
| Mobile Optimization | SEO Audit | 2% |

**Rationale**: Front-loaded speed metrics. CWV requires PageSpeed API - may need fallback if no API key.

#### 6. MULTIMEDIA (5%)
Image and media optimization.

| Signal | Source | Points |
|--------|--------|--------|
| Image Alt Text | SEO Audit | 3% |
| Image Optimization | SEO Audit | 2% |

**Rationale**: Lower weight - important but not critical for rankings.

---

## Recommendations (Decisions Made)

### Q3: "In-Depth Content (EEAT)" category
**Decision**: Fix the category. Rename to "Content Depth & Schema" and include BOTH:
- Schema markup (structured data)
- Content depth (word count >= 300)

### Q4: Advanced AEO Factors
**Decision**: Remove. Currently NOT IMPLEMENTED - placeholder with 5% weight and zero scoring. Can be added back when actually implemented.

### Q5: Internal Linking
**Decision**: Move to DISCOVERABILITY. Rationale:
- External links = citations from other sites → builds AUTHORITY ✓
- Internal links = helps crawlers find pages + user navigation → DISCOVERABILITY ✓

---

## Implementation Notes

### Where REV SCORE Lives
- **Primary location**: Overview tab (as requested)
- **Rationale**: Acts as summary of entire crawl
- E-E-A-T tab: Keep for backward compatibility but mark as "legacy" or integrate into REV SCORE drill-down
- SEO Audit: Similar approach - categories still useful for detailed analysis

### Calculation Logic
```javascript
REV_SCORE = 
  (DISCOVERABILITY * 0.25) +
  (AUTHORITY * 0.20) +
  (CONTENT_DEPTH * 0.20) +
  (TRUST * 0.15) +
  (PERFORMANCE * 0.15) +
  (MULTIMEDIA * 0.05)
```

Each sub-score calculated similarly to existing:
- score = 100 * (1 - (fail_ratio * penalty_weight))
- Individual signal pass rates aggregated up

### Key Behavior Changes
1. When user optimizes REV SCORE, all sub-categories improve proportionally
2. Clear cause-effect: "Improving title tags → increases DISCOVERABILITY → increases REV SCORE"
3. No more duplicate counting (Author appears in both E-E-A-T and SEO categories)

### Future Considerations
- Allow custom weight adjustment (advanced users)
- Add historical REV SCORE tracking for comparison
- AEO factors can be added later under CONTENT DEPTH or new category

---

# Dark Mode
