#!/usr/bin/env bash
# repo-graph.sh — Generate an interactive repo knowledge graph (Obsidian-style)
# Usage: bash scripts/repo-graph.sh [output.html]
# Default output: repo-graph.html

set -uo pipefail

OUTPUT="${1:-repo-graph.html}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "🔍 Scanning repo for markdown files and links..."

# Build nodes.json and edges.json via Python for robust parsing
python3 -c '
import os
import re
import json
import math
from pathlib import Path

repo_root = "."

# ---- CONFIG ----
EXCLUDE_DIRS = {"archive", ".git", "skills", "agents", "references", 
                "node_modules", "agent-concourse", ".opencode", ".pi"}
INCLUDE_EXT = {".md"}
EXCLUDE_FILES = {"session-state.json"}

# Directory color palette (beautiful, distinct)
DIR_COLORS = {
    "docs":            {"bg": "#4A90D9", "border": "#2C6BB0", "group": "docs"},
    "commands":        {"bg": "#50B86C", "border": "#3A8F52", "group": "commands"},
    "scripts":         {"bg": "#E8A838", "border": "#C98A2A", "group": "scripts"},
    "propagation":     {"bg": "#9B59B6", "border": "#7D3C98", "group": "propagation"},
    "research":        {"bg": "#1ABC9C", "border": "#16A085", "group": "research"},
    "workflow":        {"bg": "#E74C3C", "border": "#C0392B", "group": "workflow"},
    "root":            {"bg": "#95A5A6", "border": "#7F8C8D", "group": "root"},
    "prompt-library":  {"bg": "#E91E63", "border": "#C2185B", "group": "prompt-library"},
    "agent-skills":    {"bg": "#00BCD4", "border": "#0097A7", "group": "agent-skills"},
    "other":           {"bg": "#78909C", "border": "#546E7A", "group": "other"},
}

# ---- SCAN FILES ----
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

# Collect all markdown files
files = []
for root, dirs, filenames in os.walk("."):
    # Skip hidden dirs and excluded
    dirs[:] = [d for d in dirs if not d.startswith(".") and d not in EXCLUDE_DIRS]
    for f in filenames:
        fpath = os.path.join(root, f)
        ext = os.path.splitext(f)[1]
        if ext in INCLUDE_EXT and not is_excluded(fpath) and f not in EXCLUDE_FILES:
            files.append(fpath)

print(f"  Found {len(files)} markdown files")

# ---- EXTRACT LINKS ----
# Pattern: [text](path) where path is relative or absolute
link_pattern = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")

edges = []
node_map = {}  # display_name -> {filepath, group, size}

# First pass: collect all nodes and their sizes
for fpath in files:
    try:
        content = open(fpath, "r", encoding="utf-8").read()
    except:
        continue
    
    # Count lines for size
    line_count = len(content.splitlines())
    
    # Count internal links (outgoing degree)
    links = link_pattern.findall(content)
    internal_links = [l for l in links if l[1].endswith(".md") and not l[1].startswith("http")]
    
    display_name = os.path.splitext(os.path.basename(fpath))[0]
    # Use filepath as unique key
    key = fpath
    
    node_map[key] = {
        "filepath": fpath,
        "display": display_name,
        "group": get_group(fpath),
        "lines": line_count,
        "outgoing": len(internal_links),
        "incoming": 0,  # will count in second pass
    }

# Second pass: extract edges and count incoming links
for fpath in files:
    try:
        content = open(fpath, "r", encoding="utf-8").read()
    except:
        continue
    
    links = link_pattern.findall(content)
    for text, target in links:
        if not target.endswith(".md") or target.startswith("http"):
            continue
        
        # Resolve relative path
        source_dir = os.path.dirname(fpath)
        resolved = os.path.normpath(os.path.join(source_dir, target))
        
        # Normalize: remove leading ./ and ..
        resolved = resolved.replace("\\", "/")
        if resolved.startswith("./"):
            resolved = resolved[2:]
        if resolved.startswith("../"):
            resolved = os.path.normpath(resolved)
        
        # Check if target exists
        # Try matching against known files
        matched = None
        for known_path in node_map:
            if known_path == resolved or known_path.endswith("/" + resolved) or known_path == "./" + resolved:
                matched = known_path
                break
            # Also try matching just the filename
            if os.path.basename(known_path) == os.path.basename(resolved):
                matched = known_path
                break
        
        if matched and fpath in node_map:
            edges.append({"source": fpath, "target": matched})
            node_map[matched]["incoming"] += 1

print(f"  Found {len(edges)} internal link edges")

# ---- BUILD NODES ----
# Size formula: sqrt(lines) * 2 + incoming_links * 3 + outgoing_links * 1
# Clamp to reasonable range
max_size = 0
min_size = float("inf")
for key, info in node_map.items():
    size = math.sqrt(info["lines"]) * 2 + info["incoming"] * 3 + info["outgoing"] * 0.5
    info["size"] = size
    max_size = max(max_size, size)
    min_size = min(min_size, size)

# Normalize sizes to 15-60 range
size_range = max_size - min_size if max_size > min_size else 1
for key, info in node_map.items():
    normalized = 15 + (info["size"] - min_size) / size_range * 45
    info["viz_size"] = round(normalized, 1)

nodes_json = []
for key, info in node_map.items():
    color = DIR_COLORS.get(info["group"], DIR_COLORS["other"])
    nodes_json.append({
        "id": key,
        "label": info["display"],
        "title": f"{info[\"filepath\"]}<br>📄 {info['lines']} lines<br>🔗 {info['outgoing']} outgoing / {info['incoming']} incoming",
        "group": info["group"],
        "value": info["viz_size"],
        "shape": "dot",
        "size": info["viz_size"],
        "color": {
            "background": color["bg"],
            "border": color["border"],
            "highlight": {"background": color["bg"], "border": "#FFFFFF"}
        },
        "font": {
            "size": 10 + info["viz_size"] * 0.15,
            "face": "Inter, system-ui, sans-serif"
        },
        "filepath": info["filepath"],
        "lines": info["lines"],
        "outgoing": info["outgoing"],
        "incoming": info["incoming"]
    })

edges_json = []
for e in edges:
    edges_json.append({
        "from": e["source"],
        "to": e["target"],
        "color": {"color": "rgba(200, 200, 200, 0.3)", "highlight": "#FFFFFF"},
        "width": 0.8,
        "smooth": {"type": "curvedCW", "roundness": 0.1}
    })

# Deduplicate edges
seen = set()
unique_edges = []
for e in edges_json:
    key = (e["from"], e["to"])
    if key not in seen:
        seen.add(key)
        unique_edges.append(e)
    # If reverse exists, make it bidirectional
    rev_key = (e["to"], e["from"])
    if rev_key in seen:
        e["color"]["color"] = "rgba(255, 255, 255, 0.5)"
        e["width"] = 1.5

print(f"  {len(nodes_json)} nodes, {len(unique_edges)} unique edges")

# Write data files
with open("/tmp/repo-graph-nodes.json", "w") as f:
    json.dump(nodes_json, f, indent=2)
with open("/tmp/repo-graph-edges.json", "w") as f:
    json.dump(unique_edges, f, indent=2)

print("  Written to /tmp/repo-graph-nodes.json and edges.json")
'

# ---- GENERATE HTML ----
echo "🎨 Generating interactive graph..."

cat > "$OUTPUT" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Repo Knowledge Graph</title>
<script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  
  body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background: #0f1117;
    color: #e1e4e8;
    overflow: hidden;
    height: 100vh;
  }

  #graph {
    width: 100%;
    height: 100vh;
    position: absolute;
    top: 0;
    left: 0;
  }

  /* Top bar */
  .top-bar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 100;
    padding: 16px 24px;
    background: linear-gradient(180deg, rgba(15,17,23,0.95) 60%, transparent);
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .top-bar h1 {
    font-size: 18px;
    font-weight: 600;
    letter-spacing: -0.3px;
    color: #f0f2f5;
  }

  .top-bar .subtitle {
    font-size: 13px;
    color: #8b949e;
    margin-left: 4px;
  }

  /* Legend */
  .legend {
    position: fixed;
    bottom: 24px;
    left: 24px;
    z-index: 100;
    background: rgba(22, 27, 34, 0.92);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255,255,255,0.06);
    border-radius: 12px;
    padding: 14px 18px;
    font-size: 12px;
    min-width: 140px;
  }

  .legend h3 {
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #8b949e;
    margin-bottom: 8px;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 3px 0;
    cursor: pointer;
    transition: opacity 0.2s;
  }

  .legend-item:hover { opacity: 0.8; }

  .legend-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .legend-label {
    color: #c9d1d9;
    font-size: 12px;
  }

  .legend-count {
    color: #8b949e;
    font-size: 11px;
    margin-left: auto;
  }

  /* Stats badge */
  .stats {
    position: fixed;
    bottom: 24px;
    right: 24px;
    z-index: 100;
    background: rgba(22, 27, 34, 0.92);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255,255,255,0.06);
    border-radius: 12px;
    padding: 14px 18px;
    font-size: 12px;
    text-align: right;
  }

  .stats span {
    display: block;
    color: #8b949e;
  }

  .stats strong {
    color: #f0f2f5;
    font-weight: 600;
  }

  /* Tooltip / selection info */
  .info-panel {
    position: fixed;
    top: 72px;
    right: 24px;
    z-index: 100;
    background: rgba(22, 27, 34, 0.92);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255,255,255,0.06);
    border-radius: 12px;
    padding: 16px 20px;
    font-size: 13px;
    max-width: 280px;
    display: none;
    transition: all 0.3s;
  }

  .info-panel.visible { display: block; }

  .info-panel .file-path {
    color: #58a6ff;
    font-family: 'SF Mono', 'Fira Code', monospace;
    font-size: 12px;
    word-break: break-all;
    margin-bottom: 6px;
  }

  .info-panel .file-name {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 4px;
  }

  .info-panel .file-stats {
    color: #8b949e;
    font-size: 12px;
    line-height: 1.6;
  }

  /* Search */
  .search-box {
    position: fixed;
    top: 16px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 100;
    width: 320px;
  }

  .search-box input {
    width: 100%;
    padding: 10px 16px;
    background: rgba(22, 27, 34, 0.9);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 10px;
    color: #f0f2f5;
    font-size: 14px;
    outline: none;
    transition: border-color 0.2s;
    text-align: center;
  }

  .search-box input:focus {
    border-color: rgba(255,255,255,0.2);
  }

  .search-box input::placeholder {
    color: #8b949e;
  }

  /* Loading */
  .loading {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    text-align: center;
    z-index: 1;
  }

  .loading .spinner {
    width: 32px;
    height: 32px;
    border: 3px solid rgba(255,255,255,0.08);
    border-top-color: #58a6ff;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin: 0 auto 12px;
  }

  @keyframes spin { to { transform: rotate(360deg); } }

  .loading p {
    color: #8b949e;
    font-size: 14px;
  }
</style>
</head>
<body>

<div class="loading" id="loading">
  <div class="spinner"></div>
  <p>Loading graph...</p>
</div>

<div class="top-bar">
  <h1>Knowledge Graph</h1>
  <span class="subtitle">· agentic-workflows</span>
</div>

<div class="search-box">
  <input type="text" id="search" placeholder="Search files..." />
</div>

<div class="info-panel" id="infoPanel">
  <div class="file-name" id="infoName"></div>
  <div class="file-path" id="infoPath"></div>
  <div class="file-stats" id="infoStats"></div>
</div>

<div id="graph"></div>

<div class="legend" id="legend">
  <h3>Groups</h3>
</div>

<div class="stats" id="stats">
  <span><strong id="nodeCount">0</strong> files</span>
  <span><strong id="edgeCount">0</strong> connections</span>
</div>

<script>
// Load data
async function init() {
  try {
    // Inline data from JSON files
    const [nodesRes, edgesRes] = await Promise.all([
      fetch('/tmp/repo-graph-nodes.json'),
      fetch('/tmp/repo-graph-edges.json')
    ]);
    
    // Fallback: data is embedded after this script
    const nodes = typeof NODES_DATA !== 'undefined' ? NODES_DATA : (await nodesRes.json());
    const edges = typeof EDGES_DATA !== 'undefined' ? EDGES_DATA : (await edgesRes.json());

    // Hide loading
    document.getElementById('loading').style.display = 'none';

    // Update stats
    document.getElementById('nodeCount').textContent = nodes.length;
    document.getElementById('edgeCount').textContent = edges.length;

    // Build legend
    const groups = [...new Set(nodes.map(n => n.group))];
    const legend = document.getElementById('legend');
    groups.forEach(group => {
      const colorMap = {
        'docs': '#4A90D9', 'commands': '#50B86C', 'scripts': '#E8A838',
        'propagation': '#9B59B6', 'research': '#1ABC9C', 'workflow': '#E74C3C',
        'root': '#95A5A6', 'prompt-library': '#E91E63', 'agent-skills': '#00BCD4',
        'other': '#78909C'
      };
      const count = nodes.filter(n => n.group === group).length;
      const item = document.createElement('div');
      item.className = 'legend-item';
      item.innerHTML = `
        <div class="legend-dot" style="background:${colorMap[group] || '#78909C'}"></div>
        <span class="legend-label">${group}</span>
        <span class="legend-count">${count}</span>
      `;
      item.addEventListener('click', () => {
        const ids = nodes.filter(n => n.group === group).map(n => n.id);
        network.selectNodes(ids, false);
        network.focus(ids[0], { scale: 1.5, animation: true });
      });
      legend.appendChild(item);
    });

    // Create network
    const container = document.getElementById('graph');
    const data = {
      nodes: new vis.DataSet(nodes),
      edges: new vis.DataSet(edges)
    };

    const options = {
      physics: {
        stabilization: { iterations: 200 },
        solver: 'forceAtlas2Based',
        forceAtlas2Based: {
          gravitationalConstant: -40,
          centralGravity: 0.005,
          springLength: 200,
          springConstant: 0.04,
          damping: 0.5
        },
        adaptiveTimestep: true
      },
      edges: {
        smooth: { type: 'curvedCW', roundness: 0.1 }
      },
      interaction: {
        hover: true,
        tooltipDelay: 200,
        navigationButtons: true,
        keyboard: true,
        selectConnectedEdges: true
      },
      manipulation: { enabled: false },
      configure: { enabled: false }
    };

    const network = new vis.Network(container, data, options);

    // Search
    let searchTimeout;
    document.getElementById('search').addEventListener('input', function() {
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(() => {
        const query = this.value.toLowerCase().trim();
        if (!query) {
          network.selectNodes([]);
          network.setOptions({ physics: { enabled: true } });
          return;
        }
        
        const matches = nodes.filter(n => 
          n.label.toLowerCase().includes(query) || 
          n.filepath.toLowerCase().includes(query)
        );
        
        if (matches.length > 0) {
          const ids = matches.map(n => n.id);
          network.selectNodes(ids, false);
          network.focus(ids[0], { scale: 1.8, animation: true });
          network.setOptions({ physics: { enabled: false } });
        }
      }, 200);
    });

    // Click handler - show info panel
    network.on('click', function(params) {
      const panel = document.getElementById('infoPanel');
      if (params.nodes.length > 0) {
        const nodeId = params.nodes[0];
        const node = nodes.find(n => n.id === nodeId);
        if (node) {
          document.getElementById('infoName').textContent = node.label;
          document.getElementById('infoPath').textContent = node.filepath;
          document.getElementById('infoStats').innerHTML = `
            📄 ${node.lines} lines · 
            🔗 ${node.outgoing} outgoing · ${node.incoming} incoming
          `;
          panel.classList.add('visible');
        }
      } else {
        panel.classList.remove('visible');
      }
    });

    // Close info panel on double-click background
    network.on('doubleClick', function(params) {
      if (params.nodes.length === 0) {
        document.getElementById('infoPanel').classList.remove('visible');
      }
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        network.selectNodes([]);
        document.getElementById('search').value = '';
        document.getElementById('infoPanel').classList.remove('visible');
        network.setOptions({ physics: { enabled: true } });
      }
      if ((e.ctrlKey || e.metaKey) && e.key === 'f') {
        e.preventDefault();
        document.getElementById('search').focus();
      }
    });

    // Stabilize then free
    network.once('stabilizationIterationsDone', function() {
      network.setOptions({ physics: { enabled: false } });
    });

  } catch (err) {
    console.error('Graph init error:', err);
    document.getElementById('loading').innerHTML = `
      <p style="color:#f85149">Failed to load graph data</p>
      <p style="color:#8b949e;font-size:12px;margin-top:8px">${err.message}</p>
    `;
  }
}

// Inline data (only used if fetch fails)
// These will be replaced during generation
const NODES_DATA = null;
const EDGES_DATA = null;

init();
</script>
</body>
</html>
HTMLEOF

echo "✅ Graph generated: $(pwd)/$OUTPUT"
echo ""
echo "📊 Stats:"
echo "  Nodes: $(python3 -c "import json; print(len(json.load(open('/tmp/repo-graph-nodes.json'))))" 2>/dev/null || echo "?")"
echo "  Edges: $(python3 -c "import json; print(len(json.load(open('/tmp/repo-graph-edges.json'))))" 2>/dev/null || echo "?")"
echo ""
echo "Open the file in your browser to explore."
