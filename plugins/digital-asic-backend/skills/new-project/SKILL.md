---
name: new-project
description: Create New ASIC Backend Project
argument-hint: <pdk-path> <project-path> <design-name>
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
---

# Create New ASIC Backend Project

Scaffold a new digital ASIC backend project by copying the template directory and substituting PDK-discovered paths.

**Arguments**: `$ARGUMENTS` should contain the PDK path, project path, and design name, separated by spaces. Example: `/ic_data/szj/digital/pdk/GF130 /ic_data/szj/digital/project/my_design/top top_module_name`

If arguments are not provided, ask the user for:
1. **PDK path** (e.g., `/ic_data/szj/digital/pdk/GF130`)
2. **Project path** (where to create the project)
3. **Design name** (top-level module name)

## Step 1: Safety Check

**NEVER** overwrite an existing project directory without explicit user confirmation. Check if the project path already exists.

## Step 2: Read PDK Summary

Check whether `$PDK_PATH/pdk.md` exists:

```bash
test -f $PDK_PATH/pdk.md && echo "found" || echo "missing"
```

**If not found**, stop and inform the user:

> **Error:** No PDK summary found at `$PDK_PATH/pdk.md`.
> Run `/discover-pdk $PDK_PATH` first to catalog the PDK, then retry `/new-project`.

**If found**, read `$PDK_PATH/pdk.md` and extract the following variables from the table rows (format: `| VARIABLE | value |`):

| Variable | Description |
|----------|-------------|
| `LIBRARY_PATH` | PDK root path |
| `DB_DIR` | Directory containing .db timing files |
| `SDB_DIR` | Directory containing .sdb symbol files |
| `TARGET_LIBRARY` | TT corner .db basename |
| `SYMBOL_LIBRARY` | .sdb basename |
| `NDM_REFERENCE_LIB` | Full path to standard cell NDM |
| `NDM_REFERENCE_LIB_PHY_ONLY` | Full path to phy_only NDM |
| `TECH_FILE` | Full path to .tf tech file |
| `MAX_TLUPLUS_FILE` | Full path to worst-case TLU+ |
| `TYP_TLUPLUS_FILE` | Full path to typical TLU+ |
| `MIN_TLUPLUS_FILE` | Full path to best-case TLU+ |
| `TLUPLUS_MAP_FILE` | Full path to TLU+ layer map |
| `TCAD_GRD_WST` | Full path to worst-corner nxtgrd |
| `TCAD_GRD_BST` | Full path to best-corner nxtgrd |
| `DB_TT_FULL_PATH` | Full path to TT corner .db |
| `DB_SS_FULL_PATH` | Full path to SS corner .db |
| `ANTENNA_RULES_TCL` | Full path to antenna rules TCL |

If any variable has value `MISSING`, warn the user and ask whether to continue:

> **Warning:** The following PDK variables are marked MISSING in `pdk.md`: [list].
> These must be resolved before the flow can run. Continue anyway?

## Step 3: Copy Template and Substitute

The template directory is at `$PLUGIN_DIR/skills/new-project/template/`. To find it:
```bash
PLUGIN_DIR=$(dirname $(dirname $(find /ic_data/szj/claude/plugins/digital-asic-backend -name "SKILL.md" -path "*/new-project/*")))
TEMPLATE_DIR="$PLUGIN_DIR/skills/new-project/template"
```

Copy the entire template to the project path:
```bash
cp -r $TEMPLATE_DIR/* $PROJECT_PATH/
```

Create additional empty directories:
```bash
mkdir -p $PROJECT_PATH/{fc/{report,output,temp},starrc/{spef,temp},pt/{report,result,work,temp},hdl}
```

Then substitute all `__PLACEHOLDER__` variables in the copied files using `sed`:

```bash
find $PROJECT_PATH -type f \( -name "*.tcl" -o -name "*.cmd" -o -name "Makefile" \) -exec sed -i \
    -e "s|__DESIGN_NAME__|$DESIGN_NAME|g" \
    -e "s|__PROJECT_PATH__|$PROJECT_PATH|g" \
    -e "s|__LIBRARY_PATH__|$LIBRARY_PATH|g" \
    -e "s|__DB_DIR__|$DB_DIR|g" \
    -e "s|__SDB_DIR__|$SDB_DIR|g" \
    -e "s|__TARGET_LIBRARY__|$TARGET_LIBRARY|g" \
    -e "s|__SYMBOL_LIBRARY__|$SYMBOL_LIBRARY|g" \
    -e "s|__NDM_REFERENCE_LIB__|$NDM_REFERENCE_LIB|g" \
    -e "s|__NDM_REFERENCE_LIB_PHY_ONLY__|$NDM_REFERENCE_LIB_PHY_ONLY|g" \
    -e "s|__TECH_FILE__|$TECH_FILE|g" \
    -e "s|__MAX_TLUPLUS_FILE__|$MAX_TLUPLUS_FILE|g" \
    -e "s|__TYP_TLUPLUS_FILE__|$TYP_TLUPLUS_FILE|g" \
    -e "s|__MIN_TLUPLUS_FILE__|$MIN_TLUPLUS_FILE|g" \
    -e "s|__TLUPLUS_MAP_FILE__|$TLUPLUS_MAP_FILE|g" \
    -e "s|__TCAD_GRD_WST__|$TCAD_GRD_WST|g" \
    -e "s|__TCAD_GRD_BST__|$TCAD_GRD_BST|g" \
    -e "s|__DB_TT_FULL_PATH__|$DB_TT_FULL_PATH|g" \
    -e "s|__DB_SS_FULL_PATH__|$DB_SS_FULL_PATH|g" \
    {} +
```

**Antenna rules (mandatory):** Copy the PDK antenna rules file into the project, replacing the placeholder:

```bash
cp $ANTENNA_RULES_TCL $PROJECT_PATH/fc/scripts/constraints/antenna_rules.tcl
```

If `ANTENNA_RULES_TCL` is `MISSING`, skip the copy and warn the user — the flow will error at runtime until the file is provided.

## Step 4: Inform User

After scaffolding, present a checklist:

```
=== New Project Created: $DESIGN_NAME ===

Project path: $PROJECT_PATH
PDK: $PDK_PATH (from pdk.md)

TODO for the user:
[ ] Place RTL files in hdl/
[ ] Edit fc/scripts/stages/init.tcl: add RTL file list to analyze command
[ ] Edit fc/scripts/constraints/timing.tcl: define clock, I/O delays, loads
[ ] Edit fc/scripts/stages/floorplan.tcl: set core dimensions (or use /modify-floorplan)
[ ] Edit fc/scripts/constraints/io.tcl: set pin placement (or use /modify-floorplan)
[ ] Edit fc/scripts/constraints/physical.tcl: add physical constraints if needed
[ ] Create hdl/verilog_file_post.f for VCS (post-layout file list)
[ ] Verify fc/scripts/constraints/antenna_rules.tcl was populated from PDK (flow will error if still a placeholder)

Once done, run: /run-fc to start the flow.
```
