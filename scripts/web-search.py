#!/usr/bin/env python3
"""Web search via Bing (no API key needed). Reads query from env vars."""

import os
import re
import json
import sys
import html
import base64
import urllib.request
import urllib.parse

def search_bing(query, count=10):
    """Search Bing and return list of {title, url, snippet} results."""
    encoded = urllib.parse.quote(query)
    url = f"https://www.bing.com/search?q={encoded}&count={count}"

    req = urllib.request.Request(url, headers={
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml",
        "Accept-Language": "en-US,en;q=0.9",
    })

    try:
        resp = urllib.request.urlopen(req, timeout=15)
        html_content = resp.read().decode("utf-8", errors="replace")
    except Exception as e:
        print(f"Error fetching search results: {e}", file=sys.stderr)
        sys.exit(1)

    results = []
    items = re.findall(r'<li class="b_algo"[^>]*>(.*?)</li>', html_content, re.DOTALL)

    for item in items:
        if "b_caption" not in item:
            continue  # Skip non-result items (CSS loaders etc.)

        # Extract title from <h2> tag
        title_match = re.search(r'<h2[^>]*><a[^>]*>(.*?)</a></h2>', item, re.DOTALL)
        if not title_match:
            continue
        title = re.sub(r"<[^>]+>", "", title_match.group(1))
        title = html.unescape(title).strip()
        if not title:
            continue

        # Extract URL from Bing redirect link
        url_match = re.search(r'<a[^>]*href="([^"]+)"[^>]*>', item, re.DOTALL)
        actual_url = ""
        if url_match:
            href = url_match.group(1)
            # Bing HTML uses &amp; for & — decode for URL parsing
            href = html.unescape(href)
            if "bing.com/ck/" in href:
                parsed = urllib.parse.urlparse(href)
                params = urllib.parse.parse_qs(parsed.query)
                if "u" in params:
                    # Bing base64-encodes the real URL with "a1" prefix
                    encoded = params["u"][0]
                    if encoded.startswith("a1"):
                        encoded = encoded[2:]
                    try:
                        # Add padding for base64
                        padding = 4 - len(encoded) % 4
                        if padding != 4:
                            encoded += "=" * padding
                        actual_url = base64.b64decode(encoded).decode("utf-8")
                    except Exception:
                        pass
            if not actual_url:
                # Try to extract direct URL
                direct = re.search(r'(https?://[^\s&"]+)', href)
                if direct:
                    actual_url = direct.group(1)

        # Extract snippet from b_caption
        snip_match = re.search(r'<p[^>]*class="b_lineclamp2"[^>]*>(.*?)</p>', item, re.DOTALL)
        snippet = ""
        if snip_match:
            snippet = re.sub(r"<[^>]+>", "", snip_match.group(1))
            snippet = re.sub(r"\s+", " ", snippet).strip()
            snippet = html.unescape(snippet[:300])

        results.append({"title": title, "url": actual_url, "snippet": snippet})

    return results[:count]


def main():
    query = os.environ.get("SEARCH_QUERY", "")
    count = int(os.environ.get("SEARCH_COUNT", "10"))
    is_raw = os.environ.get("SEARCH_RAW", "false") == "true"

    if not query:
        print("Error: SEARCH_QUERY not set", file=sys.stderr)
        sys.exit(1)

    results = search_bing(query, count)

    if is_raw:
        print(json.dumps(results, indent=2))
        return

    print("=== Web Search Results ===")
    print(f"Query: {query}")
    print()

    for i, r in enumerate(results):
        print(f"{i+1}. {r['title']}")
        print(f"   URL: {r['url']}")
        if r["snippet"]:
            print(f"   {r['snippet']}")
        print()

    print(f"--- {len(results)} results ---")


if __name__ == "__main__":
    main()
