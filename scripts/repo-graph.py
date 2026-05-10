#!/usr/bin/env python3
"""
repo-graph.py — Generate a beautiful interactive knowledge graph for the repo.
Shows explicit links, propagation mirrors, and co-location clusters.

Usage: python3 scripts/repo-graph.py [output.html]
Default output: repo-graph.html
"""

import os
import re
import json
import math
import sys
from pathlib import Path
from collections import defaultdict

# ---- CONFIG ----
EXCLUDE_DIRS = {"archive", ".git", "skills", "agents", "references",
                "node_modules", "agent-concourse", ".opencode", ".pi"}
INCLUDE_EXT = {".md"}
EXCLUDE_FILES = {"session-state.json"}

EXPLICIT_COLOR = "rgba(200,200,200,0.25)"
MIRROR_COLOR = "rgba(155,89,182,0.35)"    # purple for propagation mirrors
COLOCATION_COLOR = "rgba(255,255,255,0.06)"  # very subtle for same-directory

DIR_COLORS = {
    "docs":           {"bg": "#4A90D9", "border": "#2C6BB0", "label": "Documentation"},
    "commands":       {"bg": "#50B86C", "border": "#3A8F52", "label": "Commands"},
    "scripts":        {"bg": "#E8A838", "border": "#C98A2A", "label": "Scripts"},
    "propagation":    {"bg": "#9B59B6", "border": "#7D3C98", "label": "Propagation"},
    "research":       {"bg": "#1ABC9C", "border": "#16A085", "label": "Research"},
    "workflow":       {"bg": "#E74C3C", "border": "#C0392B", "label": "Workflow State"},
    "root":           {"bg": "#95A5A6", "border": "#7F8C8D", "label": "Root Files"},
    "prompt-library": {"bg": "#E91E63", "border": "#C2185B", "label": "Prompt Library"},
    "agent-skills":   {"bg": "#00BCD4", "border": "#0097A7", "label": "Agent Skills"},
    "personal-voice": {"bg": "#FF7043", "border": "#E64A19", "label": "Personal Voice"},
    "other":          {"bg": "#78909C", "border": "#546E7A", "label": "Other"},
}


def is_excluded(path):
    parts = Path(path).parts
    return any(e in parts for e in EXCLUDE_DIRS)


def get_group(filepath):
    parts = Path(filepath).parts
    if len(parts) == 1:
        return "root"
    for key in DIR_COLORS:
        if key in parts:
            return key
    return "other"


def stem(filepath):
    """Get filename without extension."""
    return os.path.splitext(os.path.basename(filepath))[0]


def main():
    output_path = sys.argv[1] if len(sys.argv) > 1 else "repo-graph.html"
    repo_root = Path(__file__).resolve().parent.parent
    os.chdir(repo_root)

    print("🔍 Scanning repo for markdown files and links...")

    # ── Collect all markdown files ──
    all_files = []
    for root, dirs, filenames in os.walk("."):
        dirs[:] = [d for d in dirs if not d.startswith(".") and d not in EXCLUDE_DIRS]
        for f in filenames:
            fpath = os.path.join(root, f)
            ext = os.path.splitext(f)[1]
            if ext in INCLUDE_EXT and not is_excluded(fpath) and f not in EXCLUDE_FILES:
                all_files.append(fpath)

    print(f"  Found {len(all_files)} markdown files")

    # ── Build lookup: filename stem → list of filepaths ──
    stem_to_paths = defaultdict(list)
    for fpath in all_files:
        stem_to_paths[stem(fpath)].append(fpath)

    # Build a normalized lookup: normalized path → original path
    norm_to_orig = {}
    for f in all_files:
        norm = f.replace("\\", "/")
        if norm.startswith("./"):
            norm = norm[2:]
        norm_to_orig[norm] = f
    file_set = set(norm_to_orig.keys())

    # ── Extract explicit markdown links ──
    link_pattern = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")

    node_map = {}
    explicit_edges = []

    # First pass: collect nodes
    for fpath in all_files:
        try:
            content = open(fpath, "r", encoding="utf-8").read()
        except Exception:
            continue

        line_count = len(content.splitlines())
        links = link_pattern.findall(content)
        internal_links = [l for l in links
                          if l[1].endswith(".md") and not l[1].startswith("http")]

        node_map[fpath] = {
            "filepath": fpath,
            "display": stem(fpath),
            "group": get_group(fpath),
            "lines": line_count,
            "outgoing": 0,
            "incoming": 0,
        }

    # Helper: resolve a link target to a known filepath
    def resolve_target(source_file, target):
        if target.startswith("http") or not target.endswith(".md"):
            return None

        source_dir = os.path.dirname(source_file)
        resolved = os.path.normpath(os.path.join(source_dir, target))
        resolved = resolved.replace("\\", "/")

        # Strip leading ./
        if resolved.startswith("./"):
            resolved = resolved[2:]

        # Normalize source for matching
        source_norm = source_file.replace("\\", "/")
        if source_norm.startswith("./"):
            source_norm = source_norm[2:]

        # Direct match in normalized set
        if resolved in file_set:
            # Convert back to original path
            if resolved in norm_to_orig:
                return norm_to_orig[resolved]
            return resolved

        # Try matching by suffix
        for norm_key in file_set:
            if norm_key.endswith(resolved):
                if norm_key in norm_to_orig:
                    return norm_to_orig[norm_key]
                return norm_key

        # Try matching just the filename
        target_stem = stem(target)
        source_stem = stem(source_file)
        if target_stem in stem_to_paths and target_stem != source_stem:
            candidates = stem_to_paths[target_stem]
            for c in candidates:
                if c != source_file:
                    return c

        return None

    # Second pass: extract edges
    for fpath in all_files:
        try:
            content = open(fpath, "r", encoding="utf-8").read()
        except Exception:
            continue

        links = link_pattern.findall(content)
        internal_links = [l for l in links
                          if l[1].endswith(".md") and not l[1].startswith("http")]

        for text, target in internal_links:
            matched = resolve_target(fpath, target)
            if matched:
                explicit_edges.append({"source": fpath, "target": matched})
                node_map[matched]["incoming"] += 1
                node_map[fpath]["outgoing"] += 1

    # Remove self-loops
    explicit_edges = [e for e in explicit_edges if e["source"] != e["target"]]

    print(f"  Found {len(explicit_edges)} explicit link edges")

    # ── Add implicit propagation mirror edges ──
    # commands/foo.md ↔ propagation/command/foo.template.md
    mirror_edges = []
    for fpath in all_files:
        fstem = stem(fpath)
        norm_path = fpath.replace("\\", "/")
        if norm_path.startswith("./"):
            norm_path = norm_path[2:]

        if norm_path.startswith("commands/"):
            # Look for mirror in propagation/command/
            mirror_norm = f"propagation/command/{fstem}.template.md"
            if mirror_norm in norm_to_orig:
                mirror_orig = norm_to_orig[mirror_norm]
                mirror_edges.append({"source": fpath, "target": mirror_orig})
                mirror_edges.append({"source": mirror_orig, "target": fpath})

            # Also propagation/pi/prompts/
            mirror_pi_norm = f"propagation/pi/prompts/{fstem}.template.md"
            if mirror_pi_norm in norm_to_orig:
                mirror_pi_orig = norm_to_orig[mirror_pi_norm]
                mirror_edges.append({"source": fpath, "target": mirror_pi_orig})
                mirror_edges.append({"source": mirror_pi_orig, "target": fpath})

    print(f"  Added {len(mirror_edges)} propagation mirror edges")

    # ── Add co-location edges (same directory → subtle connection) ──
    # Only for directories with 3-12 files. Uses a chain pattern (file→file→file)
    # to show neighborhood relationships without full-mesh clutter.
    # Large dirs like docs/ (30+ files) skip co-location — their internal
    # links and shared context already indicate group membership.
    dir_groups = defaultdict(list)
    for fpath in all_files:
        d = os.path.dirname(fpath)
        dir_groups[d].append(fpath)

    colocation_edges = []
    for d, files_in_dir in dir_groups.items():
        n = len(files_in_dir)
        if n < 3 or n > 12:
            continue
        # Chain pattern: sorted alphabetically, connect adjacent pairs
        sorted_files = sorted(files_in_dir)
        for i in range(n - 1):
            a, b = sorted_files[i], sorted_files[i + 1]
            # Skip if already explicitly connected
            already = any(
                (e["source"] == a and e["target"] == b) or
                (e["source"] == b and e["target"] == a)
                for e in explicit_edges + mirror_edges
            )
            if not already:
                colocation_edges.append({"source": a, "target": b})

    print(f"  Added {len(colocation_edges)} co-location edges")

    # ── Build nodes with size calculation ──
    max_size, min_size = 0, float("inf")
    for key, info in node_map.items():
        # Size = content size + connection importance
        size = math.sqrt(info["lines"]) * 2 + info["incoming"] * 3 + info["outgoing"] * 1
        info["raw_size"] = size
        max_size = max(max_size, size)
        min_size = min(min_size, size)

    size_range = max_size - min_size if max_size > min_size else 1

    nodes_json = []
    for key, info in node_map.items():
        color = DIR_COLORS.get(info["group"], DIR_COLORS["other"])
        normalized = 12 + (info["raw_size"] - min_size) / size_range * 40
        nodes_json.append({
            "id": key,
            "label": info["display"],
            "title": (f"{info['filepath']}\n"
                      f"{info['lines']} lines · "
                      f"{info['outgoing']}→{info['incoming']} links"),
            "group": info["group"],
            "value": round(normalized, 1),
            "shape": "dot",
            "color": {
                "background": color["bg"],
                "border": color["border"],
                "highlight": {"background": color["bg"], "border": "#FFFFFF"},
            },
            "font": {
                "size": max(9, min(18, 8 + normalized * 0.15)),
                "face": "Inter, system-ui, sans-serif",
            },
            "filepath": info["filepath"],
            "lines": info["lines"],
            "outgoing": info["outgoing"],
            "incoming": info["incoming"],
        })

    # ── Build all edges with dedup and styling ──
    seen = set()
    all_edges = []

    # Explicit edges first
    for e in explicit_edges:
        key = (e["source"], e["target"])
        if key not in seen:
            seen.add(key)
            rev = (e["target"], e["source"])
            is_bi = rev in seen
            all_edges.append({
                "from": e["source"],
                "to": e["target"],
                "color": {"color": EXPLICIT_COLOR, "highlight": "#FFFFFF"},
                "width": 1.8 if is_bi else 1.0,
                "smooth": {"type": "curvedCW", "roundness": 0.08},
            })

    # Mirror edges (propagation relationships) — lighter but distinct
    for e in mirror_edges:
        key = (e["source"], e["target"])
        if key not in seen:
            seen.add(key)
            all_edges.append({
                "from": e["source"],
                "to": e["target"],
                "color": {"color": MIRROR_COLOR, "highlight": "rgba(155,89,182,0.7)"},
                "width": 0.6,
                "smooth": {"type": "curvedCW", "roundness": 0.12},
                "dashes": True,
            })

    # Co-location edges — very subtle
    for e in colocation_edges:
        key = (e["source"], e["target"])
        if key not in seen:
            seen.add(key)
            all_edges.append({
                "from": e["source"],
                "to": e["target"],
                "color": {"color": COLOCATION_COLOR},
                "width": 0.3,
                "smooth": {"type": "curvedCW", "roundness": 0.15},
            })

    print(f"  Total: {len(nodes_json)} nodes, {len(all_edges)} edges "
          f"({len(explicit_edges)} explicit, {len(mirror_edges)} mirror, "
          f"{len(colocation_edges)} co-location)")

    # ── Count connections for orphans report ──
    connected = set()
    for e in all_edges:
        connected.add(e["from"])
        connected.add(e["to"])
    orphans = [n for n in nodes_json if n["id"] not in connected]
    if orphans:
        print(f"\n  ⚠️  {len(orphans)} orphan files (0 connections):")
        for o in sorted(orphans, key=lambda x: x["filepath"]):
            print(f"      {o['filepath']}")

    # ── Embed everything into HTML ──
    nodes_embedded = json.dumps(nodes_json)
    edges_embedded = json.dumps(all_edges)

    # Build legend HTML
    legend_items = ""
    group_counts = defaultdict(int)
    for n in nodes_json:
        group_counts[n["group"]] += 1
    for g_key, g_info in DIR_COLORS.items():
        if g_key in group_counts:
            legend_items += f'''
            <div class="legend-item" data-group="{g_key}">
              <div class="legend-dot" style="background:{g_info['bg']}"></div>
              <span class="legend-label">{g_info['label']}</span>
              <span class="legend-count">{group_counts[g_key]}</span>
            </div>'''

    # Edge type legend
    edge_legend = f'''
    <div class="legend-section">
      <div class="edge-legend-item">
        <span class="edge-line solid"></span>
        <span class="legend-label">Explicit link</span>
      </div>
      <div class="edge-legend-item">
        <span class="edge-line dashed"></span>
        <span class="legend-label">Propagation mirror</span>
      </div>
      <div class="edge-legend-item">
        <span class="edge-line subtle"></span>
        <span class="legend-label">Same directory</span>
      </div>
    </div>'''

    # ── Write the HTML ──
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Repo Knowledge Graph</title>
<script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}

  body {{
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background: #0f1117;
    color: #e1e4e8;
    overflow: hidden;
    height: 100vh;
  }}

  #graph {{
    width: 100%;
    height: 100vh;
    position: absolute;
    top: 0; left: 0;
  }}

  .top-bar {{
    position: fixed;
    top: 0; left: 0; right: 0;
    z-index: 100;
    padding: 20px 28px;
    background: linear-gradient(180deg, rgba(15,17,23,0.95) 50%, transparent);
    display: flex;
    align-items: center;
    gap: 14px;
    pointer-events: none;
  }}

  .top-bar h1 {{
    font-size: 17px;
    font-weight: 600;
    letter-spacing: -0.3px;
    color: #f0f2f5;
  }}

  .top-bar .subtitle {{
    font-size: 13px;
    color: #8b949e;
    font-weight: 400;
  }}

  .top-bar .badge {{
    font-size: 10px;
    padding: 3px 10px;
    border-radius: 20px;
    background: rgba(88,166,255,0.10);
    color: #58a6ff;
    border: 1px solid rgba(88,166,255,0.15);
    font-weight: 500;
    letter-spacing: 0.02em;
  }}

  .legend {{
    position: fixed;
    bottom: 20px;
    left: 20px;
    z-index: 100;
    background: rgba(22,27,34,0.92);
    backdrop-filter: blur(14px);
    border: 1px solid rgba(255,255,255,0.06);
    border-radius: 12px;
    padding: 14px 16px;
    font-size: 12px;
    min-width: 150px;
    user-select: none;
  }}

  .legend h3 {{
    font-size: 10px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: #8b949e;
    margin-bottom: 8px;
  }}

  .legend-section {{
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px solid rgba(255,255,255,0.06);
  }}

  .legend-item {{
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 3px 4px;
    cursor: pointer;
    transition: background 0.15s;
    border-radius: 4px;
  }}
  .legend-item:hover {{ background: rgba(255,255,255,0.05); }}

  .legend-dot {{
    width: 10px; height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
  }}

  .legend-label {{
    color: #c9d1d9;
    font-size: 12px;
    flex: 1;
  }}

  .legend-count {{
    color: #8b949e;
    font-size: 11px;
  }}

  .edge-legend-item {{
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 2px 4px;
  }}

  .edge-line {{
    display: inline-block;
    width: 18px;
    height: 0;
    flex-shrink: 0;
  }}
  .edge-line.solid {{ border-top: 2px solid rgba(200,200,200,0.4); }}
  .edge-line.dashed {{ border-top: 2px dashed rgba(155,89,182,0.5); }}
  .edge-line.subtle {{ border-top: 1px solid rgba(255,255,255,0.1); }}

  .stats {{
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 100;
    background: rgba(22,27,34,0.92);
    backdrop-filter: blur(14px);
    border: 1px solid rgba(255,255,255,0.06);
    border-radius: 12px;
    padding: 14px 18px;
    font-size: 12px;
    text-align: right;
    line-height: 1.8;
  }}

  .stats span {{ color: #8b949e; }}
  .stats strong {{ color: #f0f2f5; font-weight: 600; }}

  .info-panel {{
    position: fixed;
    top: 80px;
    right: 24px;
    z-index: 100;
    background: rgba(22,27,34,0.94);
    backdrop-filter: blur(16px);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 12px;
    padding: 16px 20px;
    font-size: 13px;
    max-width: 280px;
    display: none;
    transition: all 0.25s;
  }}

  .info-panel.visible {{ display: block; animation: fadeSlide 0.25s ease; }}
  @keyframes fadeSlide {{
    from {{ opacity: 0; transform: translateY(-6px); }}
    to {{ opacity: 1; transform: translateY(0); }}
  }}

  .info-panel .file-path {{
    color: #58a6ff;
    font-family: 'SF Mono', 'Fira Code', monospace;
    font-size: 11px;
    word-break: break-all;
    margin-bottom: 6px;
    opacity: 0.8;
  }}

  .info-panel .file-name {{
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 2px;
  }}

  .info-panel .file-stats {{
    color: #8b949e;
    font-size: 12px;
    line-height: 1.6;
  }}

  .search-box {{
    position: fixed;
    top: 18px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 100;
    width: 280px;
    pointer-events: all;
  }}

  .search-box input {{
    width: 100%;
    padding: 9px 16px;
    background: rgba(22,27,34,0.9);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255,255,255,0.06);
    border-radius: 10px;
    color: #f0f2f5;
    font-size: 13px;
    outline: none;
    transition: all 0.2s;
    text-align: center;
  }}

  .search-box input:focus {{
    border-color: rgba(255,255,255,0.2);
    background: rgba(22,27,34,0.96);
  }}

  .search-box input::placeholder {{ color: #8b949e; }}

  .loading {{
    position: fixed;
    top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    text-align: center;
    z-index: 1;
    color: #8b949e;
    font-size: 14px;
  }}

  .loading .spinner {{
    width: 26px; height: 26px;
    border: 2px solid rgba(255,255,255,0.06);
    border-top-color: #58a6ff;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 0 auto 10px;
  }}

  @keyframes spin {{ to {{ transform: rotate(360deg); }} }}

  .no-data {{
    position: fixed;
    top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    z-index: 2;
    text-align: center;
  }}
  .no-data h2 {{ color: #f85149; font-size: 18px; margin-bottom: 8px; }}
  .no-data p {{ color: #8b949e; font-size: 13px; }}

  .hints {{
    position: fixed;
    bottom: 80px;
    right: 24px;
    z-index: 100;
    font-size: 11px;
    color: #484f58;
    text-align: right;
    line-height: 1.6;
    pointer-events: none;
  }}
</style>
</head>
<body>

<div class="loading" id="loading">
  <div class="spinner"></div>
  <p>Building graph...</p>
</div>

<div class="top-bar">
  <h1>Knowledge Graph</h1>
  <span class="subtitle">· agentic-workflows</span>
  <span class="badge">interactive</span>
</div>

<div class="search-box">
  <input type="text" id="search" placeholder="Search files… (⌘F)" spellcheck="false" />
</div>

<div class="info-panel" id="infoPanel">
  <div class="file-name" id="infoName"></div>
  <div class="file-path" id="infoPath"></div>
  <div class="file-stats" id="infoStats"></div>
</div>

<div id="graph"></div>

<div class="legend">
  <h3>Groups</h3>
  {legend_items}
  {edge_legend}
</div>

<div class="stats">
  <span><strong id="nodeCount">0</strong> files</span>
  <span><strong id="edgeCount">0</strong> connections</span>
</div>

<div class="hints">drag · scroll to zoom<br>click a node · esc to reset</div>

<script>
(function() {{
  const NODES = {nodes_embedded};
  const EDGES = {edges_embedded};

  const container = document.getElementById('graph');
  if (!NODES || NODES.length === 0) {{
    document.getElementById('loading').innerHTML = '<div class="no-data"><h2>No data</h2><p>No markdown files found.</p></div>';
    return;
  }}

  document.getElementById('loading').style.display = 'none';
  document.getElementById('nodeCount').textContent = NODES.length;
  document.getElementById('edgeCount').textContent = EDGES.length;

  const data = {{
    nodes: new vis.DataSet(NODES),
    edges: new vis.DataSet(EDGES)
  }};

  const options = {{
    physics: {{
      stabilization: {{ iterations: 200 }},
      solver: 'forceAtlas2Based',
      forceAtlas2Based: {{
        gravitationalConstant: -30,
        centralGravity: 0.003,
        springLength: 160,
        springConstant: 0.05,
        damping: 0.5,
      }},
      adaptiveTimestep: true,
      maxVelocity: 30,
    }},
    edges: {{
      smooth: {{ type: 'curvedCW', roundness: 0.08 }},
    }},
    interaction: {{
      hover: true,
      tooltipDelay: 200,
      navigationButtons: false,
      keyboard: true,
    }},
  }};

  const network = new vis.Network(container, data, options);

  // After stabilization, freeze physics and auto-frame
  network.once('stabilizationIterationsDone', function() {{
    network.setOptions({{ physics: false }});
    network.fit({{ animation: true, duration: 400 }});
  }});

  // Search
  let searchTimeout;
  const searchInput = document.getElementById('search');
  searchInput.addEventListener('input', function() {{
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {{
      const q = this.value.toLowerCase().trim();
      if (!q) {{
        network.selectNodes([]);
        return;
      }}
      const hits = NODES.filter(n =>
        n.label.toLowerCase().includes(q) || n.filepath.toLowerCase().includes(q)
      );
      if (hits.length > 0) {{
        const ids = hits.map(n => n.id);
        network.selectNodes(ids, false);
        network.focus(ids[0], {{ scale: 1.6, animation: true }});
      }}
    }}, 150);
  }});

  // Click → info panel
  network.on('click', function(params) {{
    const panel = document.getElementById('infoPanel');
    if (params.nodes.length > 0) {{
      const node = NODES.find(n => n.id === params.nodes[0]);
      if (node) {{
        document.getElementById('infoName').textContent = node.label;
        document.getElementById('infoPath').textContent = node.filepath;
        document.getElementById('infoStats').innerHTML =
          '📄 ' + node.lines + ' lines · ' +
          '🔗 ' + node.outgoing + ' outgoing · ' + node.incoming + ' incoming';
        panel.classList.add('visible');
      }}
    }} else {{
      panel.classList.remove('visible');
    }}
  }});

  // Legend click → select group
  document.querySelectorAll('.legend-item').forEach(function(item) {{
    item.addEventListener('click', function() {{
      const group = this.dataset.group;
      const ids = NODES.filter(n => n.group === group).map(n => n.id);
      if (ids.length > 0) {{
        network.selectNodes(ids, false);
        network.focus(ids[0], {{ scale: 1.4, animation: true }});
      }}
    }});
  }});

  // Keyboard
  document.addEventListener('keydown', function(e) {{
    if (e.key === 'Escape') {{
      network.selectNodes([]);
      searchInput.value = '';
      document.getElementById('infoPanel').classList.remove('visible');
      network.fit({{ animation: true }});
    }}
    if ((e.ctrlKey || e.metaKey) && e.key === 'f') {{
      e.preventDefault();
      searchInput.focus();
    }}
  }});

  // Double-click background → close panel
  network.on('doubleClick', function(params) {{
    if (params.nodes.length === 0) {{
      document.getElementById('infoPanel').classList.remove('visible');
    }}
  }});
}})();
</script>
</body>
</html>'''

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html)

    real_path = os.path.abspath(output_path)
    print(f"\n✅ Generated: {real_path}")
    print(f"   {len(nodes_json)} nodes · {len(all_edges)} edges")
    print(f"   ({len(explicit_edges)} explicit, {len(mirror_edges)} mirror, "
          f"{len(colocation_edges)} co-location)")
    print(f"\n   Open: file://{real_path}")


if __name__ == "__main__":
    main()
