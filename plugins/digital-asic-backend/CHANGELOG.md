# fc/scripts Changelog

## 1. Reorganized directory structure

### Before

All 24 scripts in a single flat directory with inconsistent naming:

```
fc/scripts/
├── fc_setup.tcl
├── fc_setup_eco.tcl
├── fc_run_full.tcl
├── fc_flow.tcl
├── eco_flow.tcl
├── fc_run_design_setup.tcl
├── fc_run_floorplan.tcl
├── fc_run_synthesis.tcl
├── fc_run_clocktree.tcl
├── fc_run_routing.tcl
├── fc_run_dfm.tcl
├── fc_run_output.tcl
├── design_setup.tcl
├── floorplan.tcl
├── floorplan_io.tcl
├── floorplan_power.tcl
├── synthesis.tcl
├── clocktree.tcl
├── routing.tcl
├── dfm.tcl
├── output.tcl
├── fc_clk_con.tcl
├── fc_phy_con.tcl
└── antenna_rule.tcl
```

### After

Structured into four purpose-based subdirectories, redundant `fc_` prefix and abbreviations removed:

```
fc/scripts/
├── setup.tcl                         # global config (was fc_setup.tcl)
├── setup_eco.tcl                     # ECO entry point (was fc_setup_eco.tcl)
├── runners/
│   ├── run_full.tcl                  # was fc_run_full.tcl
│   ├── run_design_setup.tcl          # was fc_run_design_setup.tcl
│   ├── run_floorplan.tcl             # was fc_run_floorplan.tcl
│   ├── run_synthesis.tcl             # was fc_run_synthesis.tcl
│   ├── run_clocktree.tcl             # was fc_run_clocktree.tcl
│   ├── run_routing.tcl               # was fc_run_routing.tcl
│   ├── run_dfm.tcl                   # was fc_run_dfm.tcl
│   └── run_output.tcl                # was fc_run_output.tcl
├── flow/
│   ├── flow.tcl                      # was fc_flow.tcl
│   └── flow_eco.tcl                  # was eco_flow.tcl
├── steps/
│   ├── design_setup.tcl
│   ├── floorplan.tcl
│   ├── floorplan_io.tcl
│   ├── floorplan_power.tcl
│   ├── synthesis.tcl
│   ├── clocktree.tcl
│   ├── routing.tcl
│   ├── dfm.tcl
│   └── output.tcl
└── constraints/
    ├── clk.tcl                       # was fc_clk_con.tcl
    ├── physical.tcl                  # was fc_phy_con.tcl
    └── antenna_rules.tcl             # was antenna_rule.tcl
```

All `source` paths updated in affected scripts. Makefile updated to match new paths.

---

## 2. Shared `setup.tcl` with the ECO flow

`setup_eco.tcl` previously duplicated the full contents of `setup.tcl` (~70 lines).
Replaced the duplicate block with a single source call:

```tcl
# Before: ~70 lines of duplicated variable declarations

# After:
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/flow/flow_eco.tcl
```

---

## 3. Split `synthesis` into `synthesis` + `placement`

`steps/synthesis.tcl` previously ran both `compile_fusion` and `place_opt` in one script.
Split at the checkpoint boundary:

| File | Change |
|---|---|
| `steps/synthesis.tcl` | Trimmed — stops after `compile_fusion` and `save_block` |
| `steps/placement.tcl` | **New** — opens from synthesis checkpoint, runs `place_opt`, saves `placement` |
| `runners/run_placement.tcl` | **New** — standalone entry point for the placement step |
| `runners/run_full.tcl` | `placement` sourced between `synthesis` and `clocktree` |
| `Makefile` | `placement` added to `.PHONY` and as a new target |

---

## 4. Renamed checkpoint `compile_fusion` → `synthesis`

| File | Change |
|---|---|
| `steps/synthesis.tcl` | `save_block -as ${DESIGN_NAME}_synthesis`; reports renamed `timing/qor/power_synthesis.rpt` |
| `steps/placement.tcl` | `open_block ${DESIGN_NAME}_synthesis` |

> The `compile_fusion` tool command (the Fusion Compiler binary call) is unchanged.

---

## v1.1.0

See [`releases/v1.1.0.md`](releases/v1.1.0.md) for full details and migration commands.

| Change | Summary |
|--------|---------|
| `runners/` → `flows/`, `steps/` → `stages/` | Clearer naming: flows define which stages to invoke; stages implement each PnR phase |
| `design_setup` → `init` | Avoids naming clash with parent `setup.tcl` |
| New skill: `discover-pdk` | One-time PDK scan writes `$PDK_PATH/pdk.md`; `new-project` reads it instead of re-scanning |
| `antenna_rules.tcl` → placeholder | Hard-coded process rules removed; `/new-project` now copies the real file from PDK |
