#!/bin/bash
# =============================================================================
# browser.sh --- Browser automation via Playwright
#
# Wraps common browser operations for agent use. Also supports Playwright MCP
# (configured in opencode.jsonc) for richer interactive sessions.
#
# Usage:
#   bash ./scripts/browser.sh navigate <url>         # Load a page and return title
#   bash ./scripts/browser.sh screenshot <url> <file> # Save page screenshot
#   bash ./scripts/browser.sh text <url>              # Extract page text content
#   bash ./scripts/browser.sh html <url>              # Extract page HTML
#   bash ./scripts/browser.sh pdf <url> <file>        # Save page as PDF
#   bash ./scripts/browser.sh check <url> <pattern>   # Check if page contains text
#   bash ./scripts/browser.sh click <url> <selector>  # Click matching element, return new URL
#   bash ./scripts/browser.sh section <url> <selector> # Extract text from matching element
#
# Agent-driven exploration workflow:
#   1. bash browser.sh navigate <url>
#   2. bash browser.sh text <url>              # Read page content
#   3. bash browser.sh click <url> "a.more"   # Follow a link
#   4. bash browser.sh section <new-url> "main" # Read target section
#
# Examples:
#   bash ./scripts/browser.sh navigate https://example.com
#   bash ./scripts/browser.sh screenshot https://example.com /tmp/shot.png
#   bash ./scripts/browser.sh text https://example.com | head -20
#   bash ./scripts/browser.sh click https://example.com "a[href]"
# =============================================================================
set -euo pipefail

CMD="${1:-help}"
URL="${2:-}"
OUTPUT="${3:-}"

# Use locally installed Playwright (npm install playwright)
# For interactive browsing, use Playwright MCP (configured in opencode.jsonc)
# which provides: navigate, screenshot, click, fill, select, hover, etc.
NODE_SCRIPT="node -e"

case "$CMD" in
  navigate)
    [ -z "$URL" ] && echo "Usage: browser.sh navigate <url>" && exit 1
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  const title = await page.title();
  console.log('Title: ' + title);
  console.log('URL:   ' + page.url());
  await browser.close();
})();
" 2>&1
    ;;

  screenshot)
    [ -z "$URL" ] && echo "Usage: browser.sh screenshot <url> <output.png>" && exit 1
    OUTPUT="${3:-screenshot.png}"
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  await page.screenshot({ path: '$OUTPUT', fullPage: true });
  console.log('Screenshot saved: $OUTPUT');
  await browser.close();
})();
" 2>&1
    ;;

  text)
    [ -z "$URL" ] && echo "Usage: browser.sh text <url>" && exit 1
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  const text = await page.innerText('body');
  console.log(text);
  await browser.close();
})();
" 2>&1
    ;;

  html)
    [ -z "$URL" ] && echo "Usage: browser.sh html <url>" && exit 1
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  const html = await page.content();
  console.log(html);
  await browser.close();
})();
" 2>&1
    ;;

  pdf)
    [ -z "$URL" ] && echo "Usage: browser.sh pdf <url> <output.pdf>" && exit 1
    OUTPUT="${3:-page.pdf}"
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  await page.pdf({ path: '$OUTPUT' });
  console.log('PDF saved: $OUTPUT');
  await browser.close();
})();
" 2>&1
    ;;

  check)
    [ -z "$URL" ] && echo "Usage: browser.sh check <url> <text-pattern>" && exit 1
    PATTERN="${3:-}"
    [ -z "$PATTERN" ] && echo "Usage: browser.sh check <url> <text-pattern>" && exit 1
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  const text = await page.innerText('body');
  if (text.includes('$PATTERN')) {
    console.log('FOUND: $PATTERN');
  } else {
    console.log('NOT FOUND: $PATTERN');
  }
  await browser.close();
})();
" 2>&1
    ;;

  click)
    # Click a CSS selector on a page, return new page info
    [ -z "$URL" ] && echo "Usage: browser.sh click <url> <css-selector>" && exit 1
    SELECTOR="${3:-}"
    [ -z "$SELECTOR" ] && echo "Usage: browser.sh click <url> <css-selector>" && exit 1
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  const el = await page.locator('$SELECTOR').first();
  if (!el) { console.log('ERROR: No element found for: $SELECTOR'); await browser.close(); process.exit(1); }
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'domcontentloaded' }).catch(() => {}),
    el.click().catch(() => {}),
  ]);
  console.log('Title: ' + (await page.title()));
  console.log('URL:   ' + page.url());
  await browser.close();
})();
" 2>&1
    ;;

  section)
    # Extract text content of a specific element
    [ -z "$URL" ] && echo "Usage: browser.sh section <url> <css-selector>" && exit 1
    SELECTOR="${3:-}"
    [ -z "$SELECTOR" ] && echo "Usage: browser.sh section <url> <css-selector>" && exit 1
    $NODE_SCRIPT "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('$URL', { waitUntil: 'domcontentloaded' });
  const el = await page.locator('$SELECTOR').first();
  if (!el) { console.log('ERROR: No element found for: $SELECTOR'); await browser.close(); process.exit(1); }
  const text = await el.innerText();
  console.log(text);
  await browser.close();
})();
" 2>&1
    ;;

  help|--help|-h)
    echo "Browser automation via Playwright"
    echo ""
    echo "Usage:"
    echo "  navigate <url>              Load page and show title/URL"
    echo "  screenshot <url> [file]     Save screenshot (default: screenshot.png)"
    echo "  text <url>                  Extract visible text"
    echo "  html <url>                  Extract page HTML"
    echo "  pdf <url> [file]            Save page as PDF (default: page.pdf)"
    echo "  check <url> <pattern>      Check if page contains text"
    echo "  click <url> <selector>     Click matching element, return new URL/title"
    echo "  section <url> <selector>   Extract text from matching CSS element"
    echo ""
    echo "Agent exploration workflow: navigate -> text -> click -> section"
    echo ""
    echo "For interactive browsing, use Playwright MCP (configured in opencode.jsonc)."
    echo "MCP tools include: navigate, screenshot, click, fill, select, hover, etc."
    ;;
esac
