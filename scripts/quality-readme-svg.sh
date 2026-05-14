#!/usr/bin/env bash
# ==============================================================================
# quality-readme-svg.sh --- README & SVG Architecture Quality Checks
#
# Automated validation for README and SVG files in the hub. Codifies the
# architectural lessons from the session that established these patterns.
#
# Usage:
#   bash ./scripts/quality-readme-svg.sh          # Run all checks
#   bash ./scripts/quality-readme-svg.sh --fix    # Auto-fix where possible
#   bash ./scripts/quality-readme-svg.sh --help   # Show check details
#
# Checks:
#   1. SVG: Valid XML (xmllint)
#   2. SVG: No SVG 2 features (auto-start-auto, etc.)
#   3. SVG: No emoji characters in files
#   4. SVG: No script elements
#   5. SVG: viewBox required on all SVG files
#   6. SVG: No broken url(#id) references
#   7. SVG: Paired dark/light versions exist for background SVGs
#   8. README: All referenced images exist
#   9. README: Cache-busting (?v=N) on all <img> and <source srcset>
#  10. README: No --- content text (should use ~)
#  11. README: Light/dark picture elements for background SVGs
#  12. Color: Light SVGs don't use dark-background colors (cascade check)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIX_MODE=false
EXIT_CODE=0

# Check for --fix flag
for arg in "$@"; do
  case "$arg" in
    --fix) FIX_MODE=true ;;
    --help|-h)
      grep -E "^#   " "$0" | sed 's/^#   //'
      exit 0
      ;;
  esac
done

fail() { echo "  FAIL  $*"; EXIT_CODE=1; }
pass() { echo "  PASS  $*"; }
info() { echo "  INFO  $*"; }

SVG_FILES=$(find "$REPO_ROOT/docs" -name '*.svg' 2>/dev/null || echo "")
README="$REPO_ROOT/README.md"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════"
echo "  README & SVG Architecture Quality Checks"
echo "═══════════════════════════════════════════════════"

# =========================================================
# CHECK 1: SVG XML Validity
# =========================================================
echo ""
echo "  [1/12] SVG XML Validity"
found=0
for f in $SVG_FILES; do
  if python3 -c "import xml.etree.ElementTree as ET; ET.parse('$f')" 2>/dev/null; then
    pass "$f"
  else
    fail "$f is not valid XML"
    found=$((found+1))
  fi
done
[ "$found" -eq 0 ] && pass "All SVGs valid XML" || fail "$found SVGs have XML errors"

# =========================================================
# CHECK 2: No SVG 2 features
# =========================================================
echo ""
echo "  [2/12] No SVG 2 features"
found=0
for f in $SVG_FILES; do
  if grep -q 'auto-start-auto' "$f" 2>/dev/null; then
    fail "$f uses SVG 2 auto-start-auto (use orient=\"auto\" for SVG 1.1)"
    found=$((found+1))
  fi
done
[ "$found" -eq 0 ] && pass "No SVG 2 features detected" || fail "$found files use SVG 2 features"

# =========================================================
# CHECK 3: No emoji in SVG files
# =========================================================
echo ""
echo "  [3/12] No emoji in SVGs"
found=0
for f in $SVG_FILES; do
  if python3 -c "
with open('$f', 'r') as fh:
    for i, c in enumerate(fh.read()):
        if ord(c) > 127 and ord(c) < 0x2000 and c not in '\n\r\t':
            pass  # non-emoji non-ASCII
        elif ord(c) > 0x2000:
            line = open('$f').read()[:i].count('\n') + 1
            print(f'$f: emoji at line {line}')
            exit(1)
    exit(0)
" 2>/dev/null; then
    pass "$f"
  else
    fail "$f contains emoji"
    found=$((found+1))
  fi
done
[ "$found" -eq 0 ] && pass "No emoji in SVGs" || fail "$found SVGs have emoji"

# =========================================================
# CHECK 4: No script elements in SVGs
# =========================================================
echo ""
echo "  [4/12] No script elements in SVGs"
found=0
for f in $SVG_FILES; do
  if rtk grep -qi '<script' "$f" 2>/dev/null; then
    fail "$f contains <script> element"
    found=$((found+1))
  fi
done
[ "$found" -eq 0 ] && pass "No script elements" || fail "$found SVGs have scripts"

# =========================================================
# CHECK 5: viewBox required on all SVGs
# =========================================================
echo ""
echo "  [5/12] viewBox attribute required"
found=0
for f in $SVG_FILES; do
  if rtk grep -q 'viewBox=' "$f" 2>/dev/null; then
    pass "$f"
  else
    fail "$f missing viewBox"
    found=$((found+1))
  fi
done
[ "$found" -eq 0 ] && pass "All SVGs have viewBox" || fail "$found SVGs missing viewBox"

# =========================================================
# CHECK 6: No broken url(#id) references
# =========================================================
echo ""
echo "  [6/12] No broken url(#id) references"
found=0
for f in $SVG_FILES; do
  # Find all url(#...) references and check they have matching ids
  python3 -c "
import xml.etree.ElementTree as ET, re
tree = ET.parse('$f')
root = tree.getroot()
ns = '{http://www.w3.org/2000/svg}'
# Collect all ids
ids = set()
for el in root.iter():
    i = el.get('id')
    if i:
        ids.add(i)
    # Also check href attributes
    for attr in ('href', '{http://www.w3.org/1999/xlink}href'):
        val = el.get(attr, '')
        if val.startswith('#'):
            ids.add(val[1:])
# Find all url(#id) refs in attributes
text = open('$f').read()
for m in re.finditer(r'url\(#([^)]+)\)', text):
    ref = m.group(1)
    if ref not in ids:
        print(f'Broken ref: url(#{ref})')
        exit(1)
exit(0)
" 2>/dev/null || { fail "$f has broken references"; found=$((found+1)); }
done
[ "$found" -eq 0 ] && pass "All references valid" || fail "$found SVGs have broken refs"

# =========================================================
# CHECK 7: Dark/light SVG pairs
# =========================================================
echo ""
echo "  [7/12] Dark/light SVG pairs for background SVGs"
found=0
for f in $SVG_FILES; do
  # Skip files that are transparent-background (typing-animation)
  if rtk grep -q 'background:transparent' "$f" 2>/dev/null; then
    continue
  fi
  # Check if this is a dark file that needs a light pair
  if echo "$f" | grep -q 'light'; then
    continue  # skip light files (they're the pair)
  fi
  light_f=$(echo "$f" | sed 's/\.svg$/-light.svg/')
  if [ ! -f "$light_f" ]; then
    fail "$f has no -light.svg pair"
    found=$((found+1))
  fi
done
[ "$found" -eq 0 ] && pass "All dark SVGs have light pairs" || fail "$found SVGs missing light pair"

# =========================================================
# CHECK 8: README referenced images exist
# =========================================================
echo ""
echo "  [8/12] README image references exist"
found=0
if [ -f "$README" ]; then
  # Find all src="..." references to local files
  python3 -c "
import re
with open('$README', 'r') as f:
    readme = f.read()
# Remove query params for existence check
for m in re.finditer(r'src=\"([^\"]+\.\w+)(\?[^\"]*)?\"', readme):
    path = m.group(1)
    # Skip external URLs
    if path.startswith('http'):
        continue
    full = '$REPO_ROOT/' + path
    import os
    if not os.path.exists(full):
        print(f'Missing: {path}')
        exit(1)
exit(0)
" 2>/dev/null || { fail "Some referenced images don't exist"; found=$((found+1)); }
fi
[ "$found" -eq 0 ] && pass "All referenced images exist" || fail "Missing image references"

# =========================================================
# CHECK 9: Cache-busting on all img/srcset
# =========================================================
echo ""
echo "  [9/12] Cache-busting on image references"
found=0
if [ -f "$README" ]; then
  python3 -c "
import re
with open('$README', 'r') as f:
    readme = f.read()
for m in re.finditer(r'(src|srcset)=\"([^\"]+\.svg)(\?[^\"]*)?\"', readme):
    path = m.group(2)
    qs = m.group(3) or ''
    if not qs.startswith('?v=') or not qs[3:].isdigit():
        print(f'Missing cache-buster: {path}')
        exit(1)
exit(0)
" 2>/dev/null || { fail "Some SVGs missing ?v=N cache-buster"; found=$((found+1)); }
fi
[ "$found" -eq 0 ] && pass "All SVGs have cache-busters" || fail "$found missing cache-busters"

# =========================================================
# CHECK 10: No --- in README content
# =========================================================
echo ""
echo "  [10/12] No --- in README content text"
found=0
if [ -f "$README" ]; then
  python3 -c "
import re
with open('$README', 'r') as f:
    lines = f.readlines()
for i, line in enumerate(lines, 1):
    s = line.strip()
    if re.match(r'^[\|\s\-]+$', s): continue  # table separator
    if re.match(r'^-{3,}$', s): continue        # horizontal rule
    if '---' in s:
        print(f'Line {i}: {s[:60]}')
        exit(1)
exit(0)
" 2>/dev/null || { fail "Found --- in text content (use ~ instead)"; found=$((found+1)); }
fi
[ "$found" -eq 0 ] && pass "No --- in content text" || fail "--- found"

# =========================================================
# CHECK 11: <picture> elements for theme-aware SVGs
# =========================================================
echo ""
echo "  [11/12] Theme-aware <picture> elements"
found=0
if [ -f "$README" ]; then
  dark_svgs=$(python3 -c "
import re
with open('$README', 'r') as f:
    readme = f.read()
for m in re.finditer(r'srcset=\"([^\"]+-light\.svg)', readme):
    # This is a light-mode-only reference --- should be inside <picture>
    print(m.group(1))
" 2>/dev/null || true)
  
  # Check each background SVG has a <picture> element
  for svg in $SVG_FILES; do
    if echo "$svg" | grep -q 'light'; then continue; fi
    if rtk grep -q 'background:transparent' "$svg" 2>/dev/null; then continue; fi
    basename=$(basename "$svg")
    if ! rtk grep -q "$basename" "$README" 2>/dev/null; then continue; fi
    # Check it's inside a <picture> element
    if ! python3 -c "
with open('$README', 'r') as f:
    content = f.read()
import re
# Find the <picture> block containing this SVG
for m in re.finditer(r'<picture>.*?</picture>', content, re.DOTALL):
    block = m.group()
    if '$basename' in block:
        exit(0)  # found it inside picture
exit(1)
" 2>/dev/null; then
      fail "$basename not wrapped in <picture>"
      found=$((found+1))
    fi
  done
fi
[ "$found" -eq 0 ] && pass "All themed SVGs use <picture>" || fail "$found SVGs missing <picture>"

# =========================================================
# CHECK 12: Light SVGs don't use dark-background colors
# =========================================================
echo ""
echo "  [12/12] Light SVG color cascade check"
found=0
for f in $SVG_FILES; do
  if ! echo "$f" | grep -q 'light'; then continue; fi
  # Check for dark-mode-only colors that indicate cascade bug
  if rtk grep -q '#0d1117\|#1a1a2e\|#16213e\|#0f3460' "$f" 2>/dev/null; then
    fail "$f may contain dark-mode colors (cascade bug)"
    found=$((found+1))
  fi
done
[ "$found" -eq 0 ] && pass "No cascade bugs detected" || fail "$found files may have cascade bugs"

# =========================================================
# SUMMARY
# =========================================================
echo ""
echo "═══════════════════════════════════════════════════"
if [ "$EXIT_CODE" -eq 0 ]; then
  echo -e "  ${GREEN}All checks passed${NC}"
else
  echo -e "  ${RED}$EXIT_CODE checks failed${NC}"
fi
echo "═══════════════════════════════════════════════════"
exit "$EXIT_CODE"
