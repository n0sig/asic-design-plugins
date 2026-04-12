---
name: modify-floorplan
description: Modify Floorplan
argument-hint: <natural language description of changes>
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---

# Modify Floorplan

Generate or modify `floorplan.tcl` and/or `io_floorplan.tcl` based on user's natural language description.

**Arguments**: `$ARGUMENTS` = natural language description of the desired changes.

Examples:
- `"Change core size to 200x100 um with 10um offset"`
- `"Put all DAC pins on the top edge, clock and control on the right"`
- `"Increase die size by 20% in both dimensions"`

## Setup

1. Find the project root by looking for the `fc/scripts/setup.tcl` file starting from the current directory.
2. Read `fc/scripts/setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.
3. Read the current `fc/scripts/floorplan.tcl` and `fc/scripts/io_floorplan.tcl` to understand existing settings.
4. Read RTL files in `hdl/` to get the complete list of ports (input/output/inout with bit widths).

## Understanding the Current Floorplan

Parse current `floorplan.tcl` for:
- `initialize_floorplan` arguments: `core_offset` and `side_length`
- PG ring/mesh configuration
- Routing layer settings

Parse current `io_floorplan.tcl` for:
- Pin placement commands (`place_port`, `place_pin_group`, `set_individual_pin_constraints`)
- Pin groupings and their edge assignments
- Layer alternation patterns

## Modifying Core/Die Size

When the user asks to change the die or core size:

1. Calculate new dimensions:
   - Core size = user-specified `side_length {WIDTH HEIGHT}`
   - Die size = core size + 2 * core_offset on each side
   - Core offset = user-specified or keep existing

2. Update `initialize_floorplan` in `floorplan.tcl`:
   ```tcl
   initialize_floorplan -control_type core \
       -core_offset {LEFT BOTTOM RIGHT TOP} \
       -shape R \
       -side_length {WIDTH HEIGHT}
   ```

3. If die size changes significantly, PG ring/mesh may need adjustment:
   - Mesh pitch should scale with die size
   - Ring offset should remain proportional

## Modifying Pin Placement

When the user describes pin arrangements:

1. **Parse the RTL** to get all port names and widths:
   ```bash
   grep -E '^\s*(input|output|inout)' $PROJECT_PATH/hdl/*.v
   ```

2. **Map user description to pin groups and edges**:
   - Side 1 = bottom, Side 2 = top, Side 3 = right, Side 4 = left
   - Group related pins (e.g., all `sw_vrefp_a[*]` together)

3. **Calculate spacing**:
   - Minimum pitch for GF130: 0.46 um
   - Default pin width: 0.2-0.3 um
   - Step = pin_width + gap (typically 0.46 um for this process)
   - Verify total pin span fits within the edge length

4. **Generate TCL** using the helper procs from the existing io_floorplan.tcl:
   ```tcl
   proc place_port {name layer side offset width} { ... }
   proc place_pin_group {pins side start step width layers} { ... }
   ```

5. **Layer alternation**:
   - Horizontal edges (top/bottom): alternate METAL2/METAL4
   - Vertical edges (left/right): use METAL3
   - This reduces coupling between adjacent pins

## Output

Generate **new versions** of the modified files (do not overwrite directly):
- Write to `fc/scripts/floorplan_new.tcl` and/or `fc/scripts/io_floorplan_new.tcl`
- Show a diff against the current files
- Ask the user to confirm before replacing

After confirmation:
```bash
# Backup originals
cp $PROJECT_PATH/fc/scripts/floorplan.tcl $PROJECT_PATH/fc/scripts/floorplan_$(date +%Y%m%d_%H%M%S).tcl.bak
cp $PROJECT_PATH/fc/scripts/io_floorplan.tcl $PROJECT_PATH/fc/scripts/io_floorplan_$(date +%Y%m%d_%H%M%S).tcl.bak

# Replace
mv $PROJECT_PATH/fc/scripts/floorplan_new.tcl $PROJECT_PATH/fc/scripts/floorplan.tcl
mv $PROJECT_PATH/fc/scripts/io_floorplan_new.tcl $PROJECT_PATH/fc/scripts/io_floorplan.tcl
```

## Validation

After generating new floorplan scripts, verify:

1. **All RTL ports are assigned**: Compare port list from RTL against pins in io_floorplan.tcl.
2. **No pin overlaps**: Check that no two pins occupy the same offset on the same edge.
3. **Pins within boundary**: All pin offsets must be > 0 and < edge length.
4. **Minimum pitch**: Step between pins >= 0.46 um.
5. **PG ring clearance**: Signal pins should not overlap with the PG ring offset region.

Present validation results:
```
=== Floorplan Validation ===
| Check                    | Status |
|--------------------------|--------|
| All ports assigned       | OK     |
| No pin overlaps          | OK     |
| Pins within boundary     | OK     |
| Minimum pitch satisfied  | OK     |
| PG ring clearance        | OK     |
```

## Safety Rules

- **Always** show proposed changes and ask for user confirmation before replacing files.
- **Always** backup original files before overwriting.
- **Never** modify RTL to match the floorplan -- the floorplan must match the RTL.
- Verify pin names against the actual RTL port list.
