# Visualization Prompts

Split from docs/prompt-templates.md during the 2026-04 optimization pass.

## 27. Generate Excalidraw Diagram

Use when explaining systems, architectures, flows, or relationships --- a diagram makes the explanation concrete and editable.

### When to Offer a Diagram

Offer when explaining:
- System architecture or components
- Data flow or process steps
- Entity relationships
- Hierarchies or branching decisions
- Any concept where spatial structure aids understanding

### How to Generate the Diagram

**Step 1**: Extract structured information from your explanation:
- Entities/nodes (name + optional description)
- Relationships (from -> to, with label)
- Sequential steps or decision points

**Step 2**: Create the `.excalidraw` JSON structure:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [
    {
      "id": "[unique-id]",
      "type": "rectangle",
      "x": [x],
      "y": [y],
      "width": [width],
      "height": [height],
      "strokeColor": "#000000",
      "backgroundColor": "#a5d8ff",
      "fillStyle": "solid",
      "fontFamily": 5,
      "text": "[label]"
    }
  ],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": 20
  },
  "files": {}
}
```

**Step 3**: Use these element types:
- `rectangle` --- boxes for entities, steps, concepts
- `ellipse` --- alternative for emphasis
- `diamond` --- decision points
- `arrow` --- directional connections (set `points` array for start/end)
- `text` --- labels and annotations (must use `fontFamily: 5`)

**Step 4**: Output the complete JSON as a codeblock named `diagram-name.excalidraw`.

### Layout Guidelines

| Element type | Gap between items |
|---|---|
| Horizontal spacing | 200-300px |
| Vertical spacing | 100-150px |
| Text size | 16-24px for readability |

### Color Palette

| Element type | Color |
|---|---|
| Primary elements | Light blue `#a5d8ff` |
| Secondary elements | Light green `#b2f2bb` |
| Important/central | Yellow `#ffd43b` |
| Alerts/warnings | Light red `#ffc9c9` |

### Complexity Rule

Keep diagrams under 15 elements. If the explanation is complex:
1. Create a high-level diagram first
2. Offer to create detailed sub-diagrams
3. Or save as `.excalidraw` and let the user edit/add

### How the User Opens It

1. Go to [https://excalidraw.com](https://excalidraw.com)
2. Click "Open" or drag-and-drop the file
3. The diagram is fully editable --- user can move, relabel, annotate

### Example Use

```
After explaining the request pipeline:
"Want me to draw this as a diagram? Here's the flow as an Excalidraw file:"
[dumps diagram.excalidraw codeblock]
"Open it at excalidraw.com and you can edit, annotate, or add to it."
```

### Source

Based on [selopo-ec/my-awesome-copilot Excalidraw Diagram Generator skill](https://github.com/selopo-ec/my-awesome-copilot/blob/main/skills/excalidraw-diagram-generator/SKILL.md) (613 lines, MIT license).

