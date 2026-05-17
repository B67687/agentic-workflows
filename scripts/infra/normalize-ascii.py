#!/usr/bin/env python3
"""
ASCII Normalizer --- converts Unicode characters that have ASCII equivalents
to their plain ASCII counterparts. Prevents edit tool byte-matching failures.

Why: The Edit tool matches raw bytes. Unicode arrows (->), dashes (-- ---), 
bullets (*), ellipsis (...), and smart quotes (""'') look identical to their 
ASCII counterparts in rendered text but are different byte sequences, causing
edit operations to fail with 'Could not find oldString'.

Usage:
  ./scripts/normalize-ascii.py check         # Check for non-ASCII (exit 1 if found)
  ./scripts/normalize-ascii.py fix           # Convert to ASCII in-place
  ./scripts/normalize-ascii.py check --file path.md  # Check single file
  ./scripts/normalize-ascii.py fix --file path.md   # Fix single file

Rules:
  -> (U+2192, RIGHTWARDS ARROW)  -> ASCII hyphen-minus '->'
  -- (U+2013, EN DASH)           -> ASCII hyphen-minus '--'
  --- (U+2014, EM DASH)           -> ASCII hyphen-minus '---'
  ... (U+2026, HORIZONTAL ELLIPSIS) -> ASCII period '...'
  * (U+2022, BULLET)            -> ASCII asterisk '*'
  " (U+201C, LEFT DOUBLE QUOTATION MARK)  -> ASCII quotation mark '"'
  " (U+201D, RIGHT DOUBLE QUOTATION MARK) -> ASCII quotation mark '"'
  ' (U+2019, RIGHT SINGLE QUOTATION MARK) -> ASCII apostrophe "'"
  ' (U+2018, LEFT SINGLE QUOTATION MARK)  -> ASCII apostrophe "'"
  < > (SINGLE ANGLE QUOTES)     -> ASCII apostrophe "'"
  " " (DOUBLE ANGLE QUOTES)     -> ASCII quotation mark '"'
  - (U+2043, HYPHEN BULLET)     -> ASCII hyphen-minus '-'
  - (U+2012, FIGURE DASH)      -> ASCII hyphen-minus '-'
  \u00a0 (NO-BREAK SPACE)       -> ASCII space ' '
"""

import re
import sys
from pathlib import Path

# Mapping: Unicode char -> ASCII replacement
# Ordered by likelihood of occurrence for efficiency
UNICODE_TO_ASCII = {
    '\u2013': '--',   # EN DASH
    '\u2014': '---',  # EM DASH
    '\u2012': '-',    # FIGURE DASH
    '\u2192': '->',   # RIGHTWARDS ARROW
    '\u2190': '<-',   # LEFTWARDS ARROW
    '\u2191': '^',    # UPWARDS ARROW
    '\u2193': 'v',    # DOWNWARDS ARROW
    '\u21d2': '=>',   # RIGHTWARDS DOUBLE ARROW
    '\u21d0': '<=',   # LEFTWARDS DOUBLE ARROW
    '\u27a1': '->',   # BLACK RIGHTWARDS ARROW
    '\u2022': '*',    # BULLET
    '\u2023': '*',    # TRIANGULAR BULLET
    '\u25cf': '*',    # BLACK CIRCLE
    '\u25cb': 'o',    # WHITE CIRCLE
    '\u2026': '...',  # HORIZONTAL ELLIPSIS
    '\u201c': '"',    # LEFT DOUBLE QUOTATION MARK
    '\u201d': '"',    # RIGHT DOUBLE QUOTATION MARK
    '\u201e': '"',    # DOUBLE LOW-9 QUOTATION MARK
    '\u2018': "'",    # LEFT SINGLE QUOTATION MARK
    '\u2019': "'",    # RIGHT SINGLE QUOTATION MARK
    '\u2039': '<',    # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    '\u203a': '>',    # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    '\u00ab': '"',    # LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    '\u00bb': '"',    # RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    '\u2043': '-',    # HYPHEN BULLET
    '\u00a0': ' ',    # NO-BREAK SPACE
}

# File extensions to check
TEXT_EXTENSIONS = {'.md', '.sh', '.py', '.json', '.txt', '.yaml', '.yml', 
                   '.toml', '.cfg', '.ini', '.conf', '.jsonc', '.ts', '.js'}

# Directories to skip
SKIP_DIRS = {'.git', 'node_modules', '.cache', 'archive/history'}


def collect_files(path='.', file_filter=None):
    """Collect all text files to process."""
    files = []
    root = Path(path).resolve()
    
    if file_filter:
        p = Path(file_filter).resolve()
        if p.exists() and p.is_file():
            return [p]
    
    for f in root.rglob('*'):
        # Skip directories
        if f.is_dir():
            continue
        # Skip by extension
        if f.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        # Skip by parent path
        rel = f.relative_to(root)
        if any(skip in rel.parts for skip in SKIP_DIRS):
            continue
        files.append(f)
    
    return files


def has_problematic_chars(content):
    """Check if content has any problematic Unicode characters."""
    for char in UNICODE_TO_ASCII:
        if char in content:
            return True
    return False


def normalize(content):
    """Replace problematic Unicode characters with ASCII equivalents."""
    for char, ascii_replacement in UNICODE_TO_ASCII.items():
        if char in content:
            content = content.replace(char, ascii_replacement)
    return content


def cmd_check(files):
    """Check files for problematic Unicode characters."""
    found_any = False
    file_count = 0
    char_counts = {}
    
    for fpath in files:
        try:
            content = fpath.read_text(encoding='utf-8')
        except Exception:
            continue
        
        if not has_problematic_chars(content):
            continue
        
        found_any = True
        file_count += 1
        
        # Compute relative path safely
        try:
            rel_path = fpath.resolve().relative_to(Path.cwd().resolve())
        except ValueError:
            rel_path = fpath.name
        
        # Count per character type in this file
        for char, ascii_replacement in UNICODE_TO_ASCII.items():
            count = content.count(char)
            if count > 0:
                char_name = {
                    '\u2013': 'en-dash',
                    '\u2014': 'em-dash',
                    '\u2012': 'figure-dash',
                    '\u2192': 'arrow',
                    '\u2190': 'left-arrow',
                    '\u2191': 'up-arrow',
                    '\u2193': 'down-arrow',
                    '\u21d2': 'double-arrow',
                    '\u21d0': 'left-double-arrow',
                    '\u27a1': 'black-arrow',
                    '\u2022': 'bullet',
                    '\u2023': 'tri-bullet',
                    '\u25cf': 'black-circle',
                    '\u25cb': 'white-circle',
                    '\u2026': 'ellipsis',
                    '\u201c': 'left-quote',
                    '\u201d': 'right-quote',
                    '\u201e': 'low-quote',
                    '\u2018': 'left-squote',
                    '\u2019': 'right-squote',
                    '\u2039': 'left-angle',
                    '\u203a': 'right-angle',
                    '\u00ab': 'double-left-angle',
                    '\u00bb': 'double-right-angle',
                    '\u2043': 'hyphen-bullet',
                    '\u00a0': 'nbsp',
                }.get(char, f'U+{ord(char):04X}')
                
                if file_count <= 10:  # Show first 10 files
                    print(f"  {rel_path}: {count}x {char_name} ({ascii_replacement})")
                
                char_counts[char_name] = char_counts.get(char_name, 0) + count
    
    if found_any:
        total = sum(char_counts.values())
        print(f"\nFound: {total} problematic Unicode chars in {file_count} files")
        for name, count in sorted(char_counts.items(), key=lambda x: -x[1]):
            print(f"  {name}: {count}")
        return 1
    
    print("OK: No problematic Unicode characters found")
    return 0


def cmd_fix(files):
    """Fix problematic Unicode characters in-place."""
    fixed_count = 0
    fixed_files = 0
    
    for fpath in files:
        try:
            content = fpath.read_text(encoding='utf-8')
        except Exception:
            continue
        
        if not has_problematic_chars(content):
            continue
        
        new_content = normalize(content)
        fpath.write_text(new_content, encoding='utf-8')
        
        try:
            rel_path = fpath.resolve().relative_to(Path.cwd().resolve())
        except ValueError:
            rel_path = fpath.name
        print(f"  FIXED: {rel_path}")
        fixed_count += 1
        fixed_files += content.count('\n')
    
    print(f"\nFixed {fixed_count} files")
    return 0


def main():
    args = sys.argv[1:]
    
    if not args or args[0] in ('-h', '--help'):
        print(__doc__)
        return 0
    
    command = args[0]
    file_filter = None
    
    if '--file' in args:
        idx = args.index('--file')
        if idx + 1 < len(args):
            file_filter = args[idx + 1]
    
    files = collect_files(file_filter=file_filter)
    
    if command == 'check':
        return cmd_check(files)
    elif command == 'fix':
        return cmd_fix(files)
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
