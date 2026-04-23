<#
.SYNOPSIS
    Analyzes writing samples and extracts voice patterns into VOICE-PROFILE.md.

.DESCRIPTION
    Reads all .txt and .md files from personal-voice/samples/,
    analyzes them for voice patterns, and updates personal-voice/VOICE-PROFILE.md.

    Analyzes:
    - Sentence length distribution and variation (burstiness)
    - Vocabulary choices and formality level
    - Contraction usage
    - Transition patterns
    - Common words and phrases
    - Structural patterns

.EXAMPLE
    .\extract-voice-profile.ps1
    Run analysis and update voice profile.

.NOTES
    Author: AI Prompting
    Date: 2026-04-20
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$ScriptDir = Split-Path -Parent $PSScriptRoot
$PersonalVoiceDir = Join-Path $ScriptDir 'personal-voice'
$SamplesDir = Join-Path $PersonalVoiceDir 'samples'
$VoiceProfilePath = Join-Path $PersonalVoiceDir 'VOICE-PROFILE.md'

function Get-SentenceStats {
    param([string]$Text)

    $sentences = [regex]::Split($Text, '(?<=[.!?])\s+') | Where-Object { $_.Length -gt 0 }
    if (-not $sentences -or $sentences.Count -eq 0) {
        return @{ avgLength = 0; shortCount = 0; longCount = 0; totalSentences = 0 }
    }

    $lengths = $sentences | ForEach-Object { $_.Trim().Length }
    $avgLength = ($lengths | Measure-Object -Average).Average
    $shortCount = ($lengths | Where-Object { $_ -lt 10 }).Count
    $longCount = ($lengths | Where-Object { $_ -gt 25 }).Count

    return @{
        avgLength = [math]::Round($avgLength, 1)
        shortCount = $shortCount
        longCount = $longCount
        totalSentences = $sentences.Count
        lengths = $lengths
    }
}

function Get-WordStats {
    param([string]$Text)

    $words = [regex]::Matches($Text, '\b\w+\b') | ForEach-Object { $_.Value.ToLower() }
    $wordCount = $words.Count
    $uniqueWords = ($words | Select-Object -Unique).Count

    $contractions = [regex]::Matches($Text, "\b(I['""],?m|don['""]t|can['""]t|won['""]t|it['""]s|that['""]s|he['""]s|she['""]s|we['""]re|they['""]re|I['""]ll|you['""]ll|we['""]ll|they['""]ll|I['""]ve|you['""]ve|we['""]ve|they['""]ve)\b", 'IgnoreCase').Count

    $informalWords = @('like', 'stuff', 'things', 'honestly', 'basically', 'actually', 'literally', 'totally', 'kinda', 'sorta', 'gonna', 'wanna', 'gotta', 'kinda', 'yeah', 'nah', 'cool', 'weird', 'random')
    $informalCount = ($words | Where-Object { $informalWords -contains $_ }).Count

    $aiWords = @('delve', 'tapestry', 'nuanced', 'comprehensive', 'multifaceted', 'utilize', 'implement', 'furthermore', 'moreover', 'consequently')
    $aiCount = ($words | Where-Object { $aiWords -contains $_ }).Count

    return @{
        wordCount = $wordCount
        uniqueWords = $uniqueWords
        uniqueRatio = if ($wordCount -gt 0) { [math]::Round($uniqueWords / $wordCount, 3) } else { 0 }
        contractionRatio = if ($wordCount -gt 0) { [math]::Round($contractions / $wordCount, 3) } else { 0 }
        informalCount = $informalCount
        aiWordCount = $aiCount
    }
}

function Get-TransitionPatterns {
    param([string]$Text)

    $transitions = @{
        'so' = 0
        'but' = 0
        'and' = 0
        'however' = 0
        'therefore' = 0
        'also' = 0
        'then' = 0
        'because' = 0
        'although' = 0
    }

    foreach ($key in $transitions.Keys) {
        $transitions[$key] = [regex]::Matches($Text.ToLower(), "\b$key\b").Count
    }

    $total = ($transitions.Values | Measure-Object -Sum).Sum
    if ($total -eq 0) {
        $total = 1
    }

    $normalized = @{}
    foreach ($key in $transitions.Keys) {
        $normalized[$key] = [math]::Round($transitions[$key] / $total * 100, 1)
    }

    return $normalized
}

function Get-StructuralPatterns {
    param([string]$Text)

    $patterns = @{
        fragments = [regex]::Matches($Text, '\b[A-Z][a-z]+.*[.!?]\s+[a-z]+.*[.!?]').Count
        emDashes = [regex]::Matches($Text, '—').Count
        ellipsis = [regex]::Matches($Text, '\.{3}').Count
        questions = [regex]::Matches($Text, '\?').Count
        exclamations = [regex]::Matches($Text, '!').Count
        quotes = [regex]::Matches($Text, '[""]').Count
    }

    $sentences = [regex]::Split($Text, '(?<=[.!?])\s+') | Where-Object { $_.Length -gt 0 }
    $pattern.questionsPerSentence = if ($sentences.Count -gt 0) { [math]::Round($patterns.questions / $sentences.Count, 2) } else { 0 }

    return $patterns
}

try {
$sampleFiles = Get-ChildItem -Path $SamplesDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.txt', '.md') }

if (-not $sampleFiles -or $sampleFiles.Count -eq 0) {
    Write-Host "No samples found in $SamplesDir" -ForegroundColor Yellow
    Write-Host "Add .txt or .md files to samples/ and run again." -ForegroundColor Yellow
    exit 0
}

Write-Host "Analyzing $($sampleFiles.Count) samples..." -ForegroundColor Cyan

$combinedText = ""
foreach ($file in $sampleFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $combinedText += $content + " "
    }
}

$sentenceStats = Get-SentenceStats $combinedText
$wordStats = Get-WordStats $combinedText
$transitions = Get-TransitionPatterns $combinedText
$structural = Get-StructuralPatterns $combinedText

$sentenceLength = if ($sentenceStats.avgLength -lt 12) { "short" } elseif ($sentenceStats.avgLength -lt 18) { "medium" } else { "long" }
$formality = if ($wordStats.contractionRatio -gt 0.08) { "Casual" } elseif ($wordStats.contractionRatio -gt 0.04) { "Semi-formal" } else { "Formal" }

$topTransitions = $transitions.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 3

Write-Host ""
Write-Host "=== Analysis Results ===" -ForegroundColor Green
Write-Host "Sentences: $($sentenceStats.totalSentences) (avg $($sentenceStats.avgLength) words)"
Write-Host "Words: $($wordStats.wordCount) ($($wordStats.uniqueWords) unique, $($wordStats.uniqueRatio) vocab ratio)"
Write-Host "Formality: $formality (contraction ratio: $($wordStats.contractionRatio))"
Write-Host "AI words found: $($wordStats.aiWordCount)"
Write-Host "Em-dashes: $($structural.emDashes), Ellipsis: $($structural.ellipsis)"
Write-Host "Top transitions: $($topTransitions -join ', ')"
Write-Host ""

$profileContent = @"
# Your Voice Profile

**Extracted from**: $($sampleFiles.Name -join ', ')
**Last updated**: $(Get-Date -Format 'yyyy-MM-dd')
**Confidence**: $(if ($sampleFiles.Count -ge 5) { 'High' } elseif ($sampleFiles.Count -ge 3) { 'Medium' } else { 'Low' }) (based on $($sampleFiles.Count) samples)

---

## Sentence Patterns

### Length Variation
- Average sentence length: $sentenceLength ($($sentenceStats.avgLength) words)
- Short sentences (<10 words): $($sentenceStats.shortCount)
- Long sentences (>25 words): $($sentenceStats.longCount)
- Pattern: $(if ($sentenceStats.shortCount -gt $sentenceStats.longCount * 2) { 'mostly short with occasional long' } elseif ($sentenceStats.longCount -gt $sentenceStats.shortCount) { 'mostly long with occasional short' } else { 'mixed evenly' })

### Structural Quirks
- Fragment usage (em-dashes): $($structural.emDashes)
- Ellipsis usage: $($structural.ellipsis)
- Questions: $($structural.questions) ($($structural.questionsPerSentence) per sentence)
- Exclamations: $($structural.exclamations)

---

## Vocabulary & Register

### Formality Level
$formality (contraction ratio: $($wordStats.contractionRatio))

### Vocabulary Diversity
- Unique words: $($wordStats.uniqueWords) / $($wordStats.wordCount) ($($wordStats.uniqueRatio) ratio)
- AI-typical words found: $($wordStats.aiWordCount) (should be 0 for natural human writing)

### Typical Informal Words You Use
$(if ($wordStats.informalCount -gt 0) { "- Approximately $($wordStats.informalCount) informal/filler words detected" } else { "- Few informal words detected" })

---

## Transition Patterns

### How You Connect Ideas
Most common transitions:
$(foreach ($t in $topTransitions) {
    "- $($t.Key): $($t.Value)% of all transitions"
})

### Transition Style
$(if ($transitions.'so' -gt 15 -or $transitions.'but' -gt 10) {
    "Casual connector style (heavy use of 'so' and 'but')"
} elseif ($transitions.'however' -gt 5 -or $transitions.'therefore' -gt 5) {
    "Formal connector style (uses 'however', 'therefore')"
} else {
    "Minimal transitions, likely links ideas through juxtaposition"
})

---

## Voice Characteristics

### Overall Tone
$formality with $(if ($structural.questions -gt 3) { 'questioning' } else { 'declarative' }) tendency

### Expressive Markers
- Questions: $($structural.questions)
- Exclamations: $($structural.exclamations)
- Quotes used: $($structural.quotes)

---

## What You DON'T Sound Like

These are AI/other patterns you should NOT use:
- "delve", "tapestry", "nuanced", "comprehensive", "multifaceted"
- "It's worth noting...", "Furthermore", "Moreover", "In conclusion"
- "First/Second/Third" structured lists
- Perfect grammar throughout
- Uniform sentence length
- No false starts or self-correction

---

## Recommendations for AI Output

Based on this analysis:
1. Use $sentenceLength sentences averaging $($sentenceStats.avgLength) words
2. Contractions: $(if ($wordStats.contractionRatio -gt 0.06) { 'USE THEM FREELY' } else { 'use sparingly' })
3. Transitions: rely heavily on $($topTransitions[0].Key) and $($topTransitions[1].Key)
4. Structure: $(if ($structural.emDashes -gt 2) { 'USE em-dashes — like this — for asides' } else { 'minimal em-dashes' })
5. Avoid AI vocabulary completely (found $($wordStats.aiWordCount) AI words in samples — should be 0)

---

## Sample Extraction Notes

Analyzed $($sampleFiles.Count) files totaling approximately $($wordStats.wordCount) words.
"@

$profileContent | Out-File -FilePath $VoiceProfilePath -Encoding UTF8
Write-Host "Voice profile updated: $VoiceProfilePath" -ForegroundColor Green
}
catch {
    Write-Error "Voice profile extraction failed: $_"
    exit 1
}
