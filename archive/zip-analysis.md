# Zip File Deletion Analysis

**Generated:** 2026-04-19 12:48
**Scope:** M:\\M-Namikaz-Others\\*\\*.zip

---

## 1. OpenCode Brand Assets (console/app/src/asset/brand)

- **Path:** M:\\M-Namikaz-Others\\OpenCode\\packages\\console\\app\\src\\asset\\brand\\opencode-brand-assets.zip
- **In managed folder?:** No (brand/ subdirectory has no AGENTS.md or topic-insights.md)
- **Size:** 19,070 bytes (~19 KB)
- **Referenced by:** Yes - OpenCode\\packages\\console\\app\\src\\routes\\brand\\index.tsx (line 32, 77)
- **Risk if deleted:** LOW
- **Recommendation:** KEEP
- **Reason:** Actively referenced in brand download functionality at line 32: const brandAssets = "/opencode-brand-assets.zip" and used in downloadFile function

---

## 2. OpenCode Brand Assets (console/public) - GHOST REFERENCE

- **Path:** M:\\M-Namikaz-Others\\OpenCode\\packages\\console\\public\\opencode-brand-assets.zip
- **In managed folder?:** N/A
- **Size:** FILE DOES NOT EXIST (verified via Test-Path)
- **Referenced by:** N/A
- **Risk if deleted:** NONE
- **Recommendation:** N/A - Already deleted/missing
- **Reason:** Glob result was outdated; file does not exist on filesystem

---

## 3. Comfer issue2-main.zip

- **Path:** M:\\M-Namikaz-Others\\Comfer\\issue2-main.zip
- **In managed folder?:** Yes (Comfer folder has AGENTS.md and topic-insights.md)
- **Size:** 0 bytes (empty file)
- **Referenced by:** cleanup-analysis.md and folder-structure-analysis.md (both indicate already processed)
- **Risk if deleted:** NONE
- **Recommendation:** DELETE
- **Reason:** Empty file (0 bytes), previously documented as \"SAFE to delete\" in cleanup-analysis.md; Issue #2 archive already processed

---

## 4. Fluent Search Manifest - fluent-search-nightly.zip

- **Path:** M:\\M-Namikaz-Others\\Fluent Search Manifest\\Extras\\_checks\\nightly\\fluent-search-nightly.zip
- **In managed folder?:** Yes (parent Extras folder has AGENTS.md and topic-insights.md)
- **Size:** 80,710,113 bytes (~77 MB)
- **Referenced by:** No (not referenced by any bucket JSON; bucket downloads from GitHub releases)
- **Risk if deleted:** MEDIUM
- **Recommendation:** DELETE (with extract cleanup)
- **Reason:** Local audit/validation copy. Bucket JSON (bucket\\fluent-search-nightly.json) downloads from GitHub. Extracted FluentSearch.exe (~198 MB) in extract\\ subdirectory is also not referenced. Recommend: delete zip AND extract\\FluentSearch.exe to reclaim ~277 MB total.

---

## 5. Fluent Search Manifest - fluent-search-stable.zip

- **Path:** M:\\M-Namikaz-Others\\Fluent Search Manifest\\Extras\\_checks\\stable\\fluent-search-stable.zip
- **In managed folder?:** Yes (parent Extras folder has AGENTS.md and topic-insights.md)
- **Size:** 74,357,048 bytes (~71 MB)
- **Referenced by:** No (not referenced by any bucket JSON; bucket downloads from Azure blob storage)
- **Risk if deleted:** MEDIUM
- **Recommendation:** DELETE (with extract cleanup)
- **Reason:** Local audit/validation copy. Bucket JSON (Extras\\bucket\\fluent-search.json) downloads from Azure blob storage. Extracted FluentSearch.exe (~185 MB) in extract\\ subdirectory is also not referenced. Recommend: delete zip AND extract\\FluentSearch.exe to reclaim ~256 MB total.

---

## 6. Handbrake Master Icons PSD Zips (27 files)

- **Path Pattern:** M:\\M-Namikaz-Others\\Handbrake\\HandBrake-upstream\\graphics\\Icons\\v2\\Master\\*.psd.zip
- **In managed folder?:** No (HandBrake-upstream/graphics is upstream source, not managed)
- **Total Size:** 1,198,000 bytes (~1.2 MB across 27 files)
- **Referenced by:** Yes - HandBrake-upstream\\graphics\\AUTHORS.markdown (lines 6-24)
- **Risk if deleted:** MEDIUM
- **Recommendation:** KEEP but reconsider need
- **Reason:** Listed in AUTHORS.markdown as attribution for icon sources. These are compressed source files for HandBrake's upstream icons. If upstream repo already has these files, the local copies are redundant.

---

## Summary Table

| Zip File | Size | Managed | Referenced | Risk | Recommendation |
|----------|------|---------|------------|------|----------------|
| opencode-brand-assets.zip (brand/) | 19 KB | No | Yes | LOW | KEEP |
| opencode-brand-assets.zip (public/) | N/A | N/A | N/A | NONE | Already missing |
| issue2-main.zip | 0 bytes | Yes | Doc only | NONE | DELETE |
| fluent-search-nightly.zip | 77 MB | Yes | No | MEDIUM | DELETE |
| fluent-search-stable.zip | 71 MB | Yes | No | MEDIUM | DELETE |
| Handbrake *.psd.zip (27 files) | 1.2 MB | No | Yes (AUTHORS) | MEDIUM | KEEP |

---

## Total Space Reclaimable

- **Safe to delete (0 risk):** 0 bytes (issue2-main.zip is already empty)
- **Recommended delete (medium risk, ~148 MB):** fluent-search-nightly.zip + fluent-search-stable.zip + their extract folders
- **Grand total potential reclaim:** ~433 MB (if cleaning both zip + extract)

