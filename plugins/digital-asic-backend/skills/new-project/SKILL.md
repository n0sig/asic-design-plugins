---
name: new-project
description: Create New ASIC Backend Project
argument-hint: <pdk-path> <project-path> <design-name>
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# Create New ASIC Backend Project

Scaffold a new digital ASIC backend project with the complete directory structure and template scripts.

**Arguments**: `$ARGUMENTS` should contain the PDK path, project path, and design name, separated by spaces. Example: `/ic_data/szj/digital/pdk/GF130 /ic_data/szj/digital/project/my_design/top top_module_name`

If arguments are not provided, ask the user for:
1. **PDK path** (e.g., `/ic_data/szj/digital/pdk/GF130`)
2. **Project path** (where to create the project)
3. **Design name** (top-level module name)

## Step 1: PDK Discovery

Search the PDK path for required files. Present findings to the user and ask for confirmation.

```bash
# Standard cell NDM (not phy_only)
find $PDK_PATH -name "*.ndm" -not -path "*phy_only*" -not -path "*antenna*" | head -10

# Physical-only NDM
find $PDK_PATH -name "*phy_only*" -path "*.ndm" | head -5

# Tech file
find $PDK_PATH -name "*.tf" | head -5

# TLU+ files (worst, typical, best)
find $PDK_PATH -name "*.TLUplus" -o -name "*.tluplus" | head -10

# TLU+ map file
find $PDK_PATH -name "*.map" -path "*tlu*" | head -5

# Timing DB files (look for tt, ss, ff corners)
find $PDK_PATH -name "*.db" | head -20

# Symbol DB files
find $PDK_PATH -name "*.sdb" | head -5

# StarRC TCAD grid files
find $PDK_PATH -name "*.nxtgrd" | head -10

# Antenna rules
find $PDK_PATH -name "*antenna*" -name "*.tcl" | head -5
```

Present a summary table:
```
=== PDK Discovery Results ===
| File Type     | Path                                    |
|---------------|-----------------------------------------|
| NDM           | ...                                     |
| NDM (phy)     | ...                                     |
| Tech File     | ...                                     |
| TLU+ Worst    | ...                                     |
| TLU+ Typical  | ...                                     |
| TLU+ Best     | ...                                     |
| TLU+ Map      | ...                                     |
| DB (tt)       | ...                                     |
| DB (ss)       | ...                                     |
| DB (ff)       | ...                                     |
| SDB           | ...                                     |
| TCAD Grid     | ...                                     |
```

**Ask the user to confirm** the file selections before proceeding. If multiple options exist for any file type, present all and ask which to use.

## Step 2: Create Directory Structure

```bash
mkdir -p $PROJECT_PATH/{hdl,fc/{scripts,report,output,temp},starrc/{scripts,spef,temp},pt/{scripts,report,result,work,temp},vcs/post}
```

## Step 3: Generate FC Scripts

Generate the following files using the confirmed PDK paths. Use the existing `adc` project scripts as templates but substitute all paths and design names.

### `fc/scripts/fc_setup.tcl`
Variable-only setup (no create_lib, no flow invocation):
- `DESIGN_NAME`, `PROJECT_PATH`, `LIBRARY_PATH`
- `SEARCH_PATH` pointing to DB and SDB directories, plus `$PROJECT_PATH/hdl`, `$PROJECT_PATH/fc/scripts`, `$PROJECT_PATH/fc/report`, `$PROJECT_PATH/fc/output`
- `TARGET_LIBRARY` (tt corner .db)
- `LINK_LIBRARY`, `SYMBOL_LIBRARY`
- `set_app_var` for search_path, target_library, link_library, symbol_library
- `NDM_REFERENCE_LIB`, `NDM_REFERENCE_LIB_PHY_ONLY`
- `TECH_FILE`, `MAX_TLUPLUS_FILE`, `TYP_TLUPLUS_FILE`, `MIN_TLUPLUS_FILE`, `TLUPLUS_MAP_FILE`
- `DESIGN_LIBRARY` path
- `set_host_options -max_cores 32`
- Verify settings echo block

### `fc/scripts/fc_run_full.tcl`
Sources fc_setup.tcl, creates library, sources fc_flow.tcl.

### `fc/scripts/fc_run_design_setup.tcl`
Sources fc_setup.tcl, creates library, sources design_setup.tcl.

### `fc/scripts/fc_run_{floorplan,synthesis,clocktree,routing,dfm,output}.tcl`
Each: sources fc_setup.tcl, opens library, sources the step script.

### `fc/scripts/fc_flow.tcl`
Sources all step scripts in order (design_setup through output).

### `fc/scripts/design_setup.tcl` (PLACEHOLDER)
```tcl
######################################################################
# Design Setup -- Read RTL, Elaborate, Apply Constraints
# TODO: User must add RTL file list below
######################################################################

analyze -format verilog {
# ADD YOUR RTL FILES HERE, e.g.:
# top_module.v
# sub_module.v
}

elaborate $DESIGN_NAME
set_top_module $DESIGN_NAME

read_parasitic_tech -tlup $MAX_TLUPLUS_FILE -layermap $TLUPLUS_MAP_FILE -name rcworst
read_parasitic_tech -tlup $MIN_TLUPLUS_FILE -layermap $TLUPLUS_MAP_FILE -name rcbest
read_parasitic_tech -tlup $TYP_TLUPLUS_FILE -layermap $TLUPLUS_MAP_FILE -name rctypical

set_parasitic_parameters -late_spec rcworst -early_spec rcbest

set_temperature 25
set_voltage 1.20

set_app_options -name time.remove_clock_reconvergence_pessimism -value true

source ../scripts/fc_clk_con.tcl
source ../scripts/fc_phy_con.tcl

report_ref_libs

save_block -as ${DESIGN_NAME}_initial
save_lib
```

### `fc/scripts/floorplan.tcl` (PLACEHOLDER)
```tcl
# TODO: User must set core dimensions and pin placement
open_block ${DESIGN_NAME}_initial

initialize_floorplan -control_type core \
    -core_offset {10 10 10 10} \
    -shape R \
    -side_length {100 100}

source ../scripts/io_floorplan.tcl

connect_pg_net -automatic

# TODO: Configure PG ring and mesh for your design

set_ignored_layers -min_routing_layer METAL1 -max_routing_layer METAL6

save_block -as ${DESIGN_NAME}_floorplan
save_lib
```

### `fc/scripts/io_floorplan.tcl` (PLACEHOLDER)
```tcl
# TODO: User must define pin placement
# Use /modify-floorplan skill to generate pin placement from natural language
place_pins -self
```

### `fc/scripts/fc_clk_con.tcl` (PLACEHOLDER)
```tcl
# TODO: User must define clock constraints
# Example:
# set CLK_PERIOD "10"
# create_clock -period $CLK_PERIOD -name clk [get_ports clk]
# set_input_delay [expr {0.1*$CLK_PERIOD}] -clock clk [all_inputs]
# set_output_delay [expr {0.1*$CLK_PERIOD}] -clock clk [all_outputs]
```

### `fc/scripts/fc_phy_con.tcl` (PLACEHOLDER)
```tcl
# Physical constraints (dont_use cells, etc.)
# Example:
# set_dont_use [get_lib_cells */AOI222*]
```

### `fc/scripts/synthesis.tcl`, `clocktree.tcl`, `routing.tcl`, `dfm.tcl`, `output.tcl`
Copy the standard templates from the adc project. These are generally design-independent. Read the corresponding scripts from the adc project at `/ic_data/szj/digital/project/202605-nr512/adc/fc/scripts/` and replicate them with `$DESIGN_NAME` variable references (they already use variables, so they're portable).

### `fc/scripts/fc_setup_eco.tcl`, `fc/scripts/eco_flow.tcl`
Same as adc project templates.

### `fc/scripts/antenna_rule.tcl`
If found in PDK, copy it. Otherwise, use the GF130 antenna rules from the adc project as a starting template.

## Step 4: Generate StarRC Scripts

Create 4 extraction command files based on the template. The key differences between corners:
- `TCAD_GRD_FILE`: wst vs bst nxtgrd file
- `OPERATING_TEMPERATURE`: 25 vs 125
- `NETLIST_FILE`: output spef filename
- `STAR_DIRECTORY`: unique stardir name

### `starrc/Makefile`
```makefile
SHELL := /bin/csh -f
.PHONY: all run clean

all: run

run:
	mkdir -p spef temp
	cd temp && \
	StarXtract -clean ../scripts/extract_cmax_25c.cmd && \
	StarXtract -clean ../scripts/extract_cmax_125c.cmd && \
	StarXtract -clean ../scripts/extract_cmin_25c.cmd && \
	StarXtract -clean ../scripts/extract_cmin_125c.cmd

clean:
	rm -rf spef temp
```

## Step 5: Generate PT Scripts

Create PrimeTime scripts based on the adc project templates:
- `pt/scripts/setup.tcl` -- with correct library paths for all corners
- `pt/scripts/dmsa.tcl` -- standard DMSA orchestration
- `pt/scripts/dmsa_con.tcl` -- per-scenario setup with SDC filtering
- `pt/scripts/dmsa_analysis.tcl` -- analysis, noise, ECO generation

### `pt/Makefile`
```makefile
SHELL := /bin/csh -f
.PHONY: all run clean

all: run

run:
	mkdir -p report result work temp
	cd temp && pt_shell -multi_scenario -f ../scripts/dmsa.tcl | tee dmsa.log

clean:
	rm -rf report result work temp
```

## Step 6: Generate VCS Makefile

Create `vcs/post/Makefile` based on the adc project template with the correct PROJECT_PATH.

## Step 7: Inform User

After scaffolding, present a checklist of what the user needs to fill in:

```
=== New Project Created: $DESIGN_NAME ===

Project path: $PROJECT_PATH
PDK: $PDK_PATH

TODO for the user:
[ ] Place RTL files in hdl/
[ ] Edit fc/scripts/design_setup.tcl: add RTL file list to analyze command
[ ] Edit fc/scripts/fc_clk_con.tcl: define clock, I/O delays, loads
[ ] Edit fc/scripts/floorplan.tcl: set core dimensions (or use /modify-floorplan)
[ ] Edit fc/scripts/io_floorplan.tcl: set pin placement (or use /modify-floorplan)
[ ] Edit fc/scripts/fc_phy_con.tcl: add physical constraints if needed
[ ] Create hdl/verilog_file_post.f for VCS (post-layout file list)
[ ] Review antenna_rule.tcl for your process

Once done, run: /run-fc to start the flow.
```

## Safety Rules

- **NEVER** overwrite an existing project directory without explicit user confirmation.
- Ask user to confirm PDK file selections before generating scripts.
- Mark all placeholder sections clearly with `# TODO:` comments.
