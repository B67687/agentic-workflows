# Harvested Topic Insights

Generated: 2026-05-08 19:07:01 +0800

## Summary

- Harvest mode: read-only topic-insights snapshot
- Topic folders included: 13

## Included

- bus-hop | /home/namikaz/projects/dev/bus-hop/topic-insights.md
- fengshui | /home/namikaz/projects/dev/fengshui/topic-insights.md
- fluent-prs | /home/namikaz/projects/dev/fluent-prs/topic-insights.md
- hugo | /home/namikaz/projects/dev/hugo/topic-insights.md
- image-glass | /home/namikaz/projects/dev/image-glass/topic-insights.md
- image-magick | /home/namikaz/projects/dev/image-magick/topic-insights.md
- keyboard | /home/namikaz/projects/dev/keyboard/topic-insights.md
- math-learning-notes | /home/namikaz/projects/dev/math-learning-notes/topic-insights.md
- no-face-scan-app | /home/namikaz/projects/dev/no-face-scan-app/topic-insights.md
- random | /home/namikaz/projects/dev/random/topic-insights.md
- reality | /home/namikaz/projects/dev/reality/topic-insights.md
- rss-reader | /home/namikaz/projects/dev/rss-reader/topic-insights.md
- scenic-fetch | /home/namikaz/projects/dev/scenic-fetch/topic-insights.md

## Snapshots

## Folder: bus-hop

- Path: /home/namikaz/projects/dev/bus-hop
- Source: /home/namikaz/projects/dev/bus-hop/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: fengshui

- Path: /home/namikaz/projects/dev/fengshui
- Source: /home/namikaz/projects/dev/fengshui/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: fluent-prs

- Path: /home/namikaz/projects/dev/fluent-prs
- Source: /home/namikaz/projects/dev/fluent-prs/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

### PowerShell Performance
- **JSON deserialization is the bottleneck, not file I/O.** `ConvertFrom-Json` on 4000+ manifests costs ~2400ms. Same files scanned with `Select-String` costs ~200ms. Defer JSON parsing to only matched records. (Level 4)
- **Hashtable iteration is faster than file enumeration.** Iterating 4000 hashtable keys with `IndexOf` costs ~5ms. Doing `Get-ChildItem` + file reads on 4000 files costs ~1500ms. (Level 4)
- **Cmdlets have overhead vs .NET methods.** `Get-ChildItem` is ~10x slower than `[System.IO.Directory]::GetFiles()`. `Get-Content` is ~5x slower than `[System.IO.File]::ReadAllText()`. For batch operations on thousands of files, use .NET directly. (Level 3)
- **`-like "*$query*"` vs `-match $query` is semantics, not style.** `-like` supports wildcards (`*`, `?`, `[...]`). `-match` supports regex. Identical for plain substrings; divergent for metacharacters. (Level 4)

### Scoop Internals
- **Two search paths with different matching semantics.** SQLite cache uses `LIKE '%query%'` (substring). Non-SQLite path uses `New-Object Regex $query` (regex). Same `scoop search` command produces different results depending on config. (Level 4)
- **Bucket structure is inconsistent.** Some stores manifests at `$bucketsdir\$Name\*.json`, others at `$bucketsdir\$Name\bucket\*.json`. `Find-BucketDirectory` handles this. `-Recurse` on `Get-ChildItem` is over-broad but harmless in practice. (Level 3)
- **Scoop's installed version is a git repo.** `master` tracks releases. `develop` is where PRs target. Contributing guide requires `develop` as base. (Level 4)
- **`$scoopdir`, `$bucketsdir`, and `Find-BucketDirectory` are set by Scoop's bootstrap** (`bin/scoop.ps1` → `lib/core.ps1`). Any `libexec/` script can rely on these. (Level 4)

### Stock Scoop Search Behavior
- **Stock shows binaries only for binary-only matches.** Name-matched apps get `Binaries = ''`. This is a deliberate if/else in `search_bucket`. Any cache implementation must replicate this exactly. (Level 4)
- **`bin_match_json` handles three JSON shapes:** `"bin": "string"`, `"bin": ["arr"]`, `"bin": [["exe","alias"], "string"]`. All three must be handled identically across stock paths and cache path. (Level 4)
- **Stock `search_bucket` uses recursive `Get-ChildItem`.** The cache must use the same enumeration for staleness counts to match. (Level 4)

### Caching Design
- **Caching multiplies complexity.** A 3-function solution (search) becomes 6+ functions (search + cache init + cache build + validation + fallback + staleness). Every edge case (corrupt file, removed bucket, null query) adds a code path. (Level 4)
- **Warm/cold path split is the hardest to maintain.** Two parallel implementations must produce identical results. Any bug in one path that isn't in the other causes hard-to-debug inconsistencies. Fallback guarantees correctness but trustworthiness depends on thorough testing. (Level 3)
- **Timestamp + file count + LastWriteTime for staleness.** Timestamp alone misses file changes. File count misses in-place edits. LastWriteTime catches everything. Each check adds ~50ms to warm path but prevents silent stale results. (Level 3)

### PR Process
- **Code review bottleneck is perception, not code volume.** Same 183-line diff with 8 commits estimated at 45 min; with 1 commit estimated at 25 min. Squashing doesn't change code but reduces intimidation. (Level 2)
- **Testing builds trust, not proof.** 10 matching queries demonstrate diligence but don't prove correctness. Proactive verification statements reduce reviewer back-and-forth. (Level 3)
- **Scoop's PR template is rigid.** Target `develop`, add CHANGELOG entry, use conventional commits, check all boxes. Deviations cause friction. (Level 4)

## Transferable Lessons

- **When optimizing PowerShell scripts that process many files, batch the I/O and defer `ConvertFrom-Json` to only matched records.** This pattern applies to any script processing JSON files (config scans, log analysis, manifest processing). #cross-domain
- **An in-memory index is orders of magnitude faster than file-based enumeration for repeated lookups.** Generic cache pattern: build once, validate before use, fall back to original when stale. #cross-domain
- **For PRs to established projects, match the EXACT output of the original, even if your approach is logically correct.** Any deviation (even arguably better output) is a regression from the reviewer's perspective. #ai-relevant
- **Separate `$query` (string) from `$regex` (Regex object).** Mutating a command-line parameter from string to Regex mid-function creates latent bugs in downstream callers. Keep input types stable across the entire function flow. #cross-domain

## Insights

- **PowerShell 5.1 compatibility constrains everything.** No `ForEach-Object -Parallel`, no `System.Text.Json`, no fluent LINQ. Every .NET API must work on .NET Framework 4.x. `[StringComparison]::OrdinalIgnoreCase` is safe (4.5+). `[System.IO.File]::ReadAllText` works everywhere. (Level 4)
- **Performance claims should report range, not single number.** Fastest query (100ms) and slowest (244ms) differ by 2.4x based purely on number of matching apps. Report: "145-244ms average (~15x)". (Level 3)
- **`$Matches` automatic variable persists after `-notmatch`.** Using `-notmatch` for the metacharacter guard (line 314 of the PR) sets `$Matches`, which can pollute later `-match` calls. Use a non-capturing regex or save/restore `$Matches` if subsequent code uses it. (Level 2)

## Mistakes To Avoid Repeating

- **Don't remove the file-count cross-check from cache staleness.** Earlier versions used timestamp-only and missed file changes within 24h. Adding file count + LastWriteTime fingerprint was the right call, even though it adds ~150ms per warm run.
- **Don't write a PR with 8 commits for a 183-line change.** The reviewer estimates 45 min review time for 8 commits vs 25 min for 1 squashed commit. Same code, different presentation. Squash before submitting.
- **Don't assume stock behavior is obvious.** Stock's binary display is counter-intuitive (empty for name matches, populated for binary-only matches is not what users expect). Always verify against actual stock output, not against intuition.
- **Don't optimize the stale-path file scan.** The staleness check runs `Get-ChildItem -Recurse` on all buckets on every warm run. It's tempting to optimize this to a lighter check. Don't — the consistency between staleness count, cache build count, and `search_bucket` enumeration is more important than saving 100ms.

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: hugo

- Path: /home/namikaz/projects/dev/hugo
- Source: /home/namikaz/projects/dev/hugo/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: image-glass

- Path: /home/namikaz/projects/dev/image-glass
- Source: /home/namikaz/projects/dev/image-glass/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: image-magick

- Path: /home/namikaz/projects/dev/image-magick
- Source: /home/namikaz/projects/dev/image-magick/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- **AI-generated security fixes require build/test verification before submission** - PR #8691 fix failed ImageMagick tests
- Current models (Sonnet 4.5, K2.6, M2.5) can identify patterns but may introduce subtle bugs in complex C code
- Security fixes without local build verification are high-risk for rejection

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

### AI Limitations for Security Fixes (Level 4: Established)
- **PR #8691 failed ImageMagick tests** - AI-generated fix was logically sound but failed in practice
- Current models can identify patterns but miss context-specific requirements in complex C codebases
- Without local build/test verification, AI security fixes are high-risk for rejection
- **Recommendation:** Do NOT submit AI-generated security patches without: (1) local build, (2) test suite pass, (3) manual code review

### ImageMagick PR Culture (Level 3: Confirmed)
- **Do NOT ping maintainers for reviews** - they review PRs in their own time
- dlemstra is the active security/maintainer (8 security advisories published in Apr 2026)
- PRs are accepted without direct ping - wait for maintainer to pick it up
- Adding a heart reaction is acceptable; adding comments requesting review is not

### PR Review Request Protocol (Cross-Domain) (Level 3: Confirmed)
- When in doubt about repo culture, OBSERVE first: check recent merged PRs for pinging patterns
- "No explicit rule against X" != "X is acceptable" - silence != permission
- Better: let PR sit naturally than risk being told not to ping
- If you must do something, low-key reactions (hearts) are safer than comments

## Mistakes To Avoid Repeating

- **Submitting AI-generated C code without running tests** - PR #8691 failed ImageMagick CI/tests
  - How to avoid: Always build and run test suite before submitting PRs
- **Assuming pattern-matching equals correct fixes** - AI can match cleanup patterns but miss context-specific requirements
  - How to avoid: Treat AI suggestions as drafts, require human review + automated test verification
- **Pinging maintainers for PR review** - caused public correction from dlemstra
  - How to avoid: Look at recent merged PRs first, check if anyone pings, if uncertain don't ping
- **Assuming "no rule against it" means "it's okay"** - silence is not permission
  - How to avoid: Positive signal > negative signal - find evidence it's welcome, not just that it's not forbidden

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: keyboard

- Path: /home/namikaz/projects/dev/keyboard
- Source: /home/namikaz/projects/dev/keyboard/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: math-learning-notes

- Path: /home/namikaz/projects/dev/math-learning-notes
- Source: /home/namikaz/projects/dev/math-learning-notes/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: no-face-scan-app

- Path: /home/namikaz/projects/dev/no-face-scan-app
- Source: /home/namikaz/projects/dev/no-face-scan-app/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: random

- Path: /home/namikaz/projects/dev/random
- Source: /home/namikaz/projects/dev/random/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: reality

- Path: /home/namikaz/projects/dev/reality
- Source: /home/namikaz/projects/dev/reality/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.

### End Topic Insights

## Folder: rss-reader

- Path: /home/namikaz/projects/dev/rss-reader
- Source: /home/namikaz/projects/dev/rss-reader/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.
### End Topic Insights

## Folder: scenic-fetch

- Path: /home/namikaz/projects/dev/scenic-fetch
- Source: /home/namikaz/projects/dev/scenic-fetch/topic-insights.md

### Begin Topic Insights
<!-- Managed-By: AI-Prompting-Library -->
<!-- Template: Topic-Insights -->
# Topic Insights

Capture insights, lessons, and discoveries from this topic domain. These insights can be harvested for cross-domain review and potential integration into the central AI Prompting knowledge base.

## Key Learnings

- Add insights discovered while working in this topic area

## Transferable Lessons

- If a lesson applies to other domains too, phrase it clearly here so it can be harvested later
- Use tags like #ai-relevant or #cross-domain to flag for cross-domain review

## Insights

- Capture new patterns, techniques, or discoveries here
- Note confidence level: Level 1 (speculative), Level 2 (plausible), Level 3 (confirmed), Level 4 (established)

## Mistakes To Avoid Repeating

- Add failures and how to avoid them

## Update Rule

When a new insight is discovered, add it here before continuing similar work.
### End Topic Insights


