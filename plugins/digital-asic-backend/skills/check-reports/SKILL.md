---
name: check-reports
description: Check ASIC Backend Reports
argument-hint: <stage> (fc-synthesis|fc-placement|fc-clocktree|fc-routing|fc-dfm|fc-output|starrc|pt|eco|all)
allowed-tools: [Read, Glob, Grep, Bash]
---

# Check ASIC Backend Reports

Parse and present reports from any stage of the ASIC backend flow.

**Argument**: `$ARGUMENTS` = stage name. One of: `fc-synthesis`, `fc-placement`, `fc-clocktree`, `fc-routing`, `fc-dfm`, `fc-output`, `starrc`, `pt`, `eco`, `all`

## Setup

1. Find the project root by looking for the `fc/scripts/setup.tcl` file starting from the current directory.
2. Read `fc/scripts/setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.

## Stage-to-Report Mapping

| Stage | Report Files (under `fc/report/` unless noted) |
|-------|-----------------------------------------------|
| `fc-synthesis` | `timing_synthesis.rpt`, `qor_synthesis.rpt`, `power_synthesis.rpt` |
| `fc-placement` | `placement_timing.rpt`, `placement_qor.rpt` |
| `fc-clocktree` | `timing_cts.rpt`, `timing_clock_opt.rpt`, `timing_clock_opt_hold.rpt` |
| `fc-routing` | `route_timing.rpt`, `route_timing_hold.rpt`, `route_qor.rpt`, `route_drc.rpt` |
| `fc-dfm` | `dfm_drc.rpt`, `dfm_lvs.rpt` |
| `fc-output` | `final_timing.rpt`, `final_timing_hold.rpt`, `final_qor.rpt`, `final_area.rpt`, `final_power.rpt` |
| `starrc` | Verify 4 SPEF files in `starrc/spef/`, check `starrc/temp/stardir_*/summary/*.sum` for errors |
| `pt` | `pt/report/${DESIGN_NAME}_allvios.rpt`, `pt/report/${DESIGN_NAME}_fix_all_vios.report` |
| `eco` | Same as `fc-dfm` + `fc-output` combined |
| `all` | All of the above |

## Parsing Patterns

### Timing Reports (`*timing*.rpt`)
- Find the line containing `slack (MET)` or `slack (VIOLATED)` and extract the numeric slack value.
- Extract `Startpoint:`, `Endpoint:`, `Path Group:`, `Path Type:` (max or min).
- **CRITICAL**: Negative slack = timing violation. Report it prominently.

### QoR Reports (`*qor*.rpt`)
For each `Timing Path Group` block, extract:
- `Critical Path Slack:` value
- `Total Negative Slack:` value (should be 0.00)
- `No. of Violating Paths:` count (should be 0)
- `Worst Hold Violation:` value
- `No. of Hold Violations:` count

From the `Cell Count` section:
- `Leaf Cell Count:` total standard cells
- `Sequential Cell Count:` flip-flops + ICGs

From the `Area` section:
- `Cell Area (netlist):` standard cell area

### Area Reports (`*area*.rpt` / `report_design -all`)
Extract:
- `Core Area is :` value (um^2)
- `Chip Area is :` value (um^2)
- From `CELL INSTANCE INFORMATION` table: `Standard cells` count and area
- **Calculate utilization**: `Standard cell area / Core area * 100%`
- Report utilization prominently.

### DRC Reports (`*drc*.rpt` / `check_routes` output)
Extract:
- `TOTAL VIOLATIONS =` count (**must be 0**)
- `Total number of open nets =` count (**must be 0**)
- `Total number of antenna violations =` count
- `TOTAL SOFT VIOLATIONS =` count

### LVS Reports (`*lvs*.rpt` / `check_lvs` output)
Extract:
- `Total number of short violations is` count (**CRITICAL -- must be 0**)
- `Total number of open nets is` count (**must be 0**)
- `Total number of floating route violations is` count (**must be 0**)

### Power Reports (`*power*.rpt`)
Extract:
- `Total Dynamic Power` value and unit
- `Cell Leakage Power` value and unit
- From power group table: `clock_network` percentage (watch for high clock power)

### PrimeTime Violation Reports
For `*_allvios.rpt`:
- Count lines containing `(VIOLATED)` -- total violations
- Categorize by section: `max_transition`, `max_capacitance`, `setup`, `hold`

For `*_fix_all_vios.report`:
- Same parsing -- these are post-ECO residual violations

### StarRC Verification
- Check all 4 SPEF files exist and have non-zero size:
  - `starrc/spef/cmax_25c.spef`, `cmax_125c.spef`, `cmin_25c.spef`, `cmin_125c.spef`
- Grep for `Error` in `starrc/temp/stardir_*/summary/*.sum` files

## Output Format

Present results as a clear table:

```
=== FC [Stage] Report Summary ===

| Metric                  | Value        | Status   |
|-------------------------|--------------|----------|
| Setup Slack (max)       | XX.XX ns     | MET/FAIL |
| Hold Slack (min)        | XX.XX ns     | MET/FAIL |
| Total Negative Slack    | 0.00         | CLEAN    |
| Violating Paths         | 0            | CLEAN    |
| DRC Violations          | 0            | CLEAN    |
| LVS Shorts              | 0            | CLEAN    |
| LVS Opens               | 0            | CLEAN    |
| Antenna Violations      | 0            | CLEAN    |
| Floating Routes         | 0            | CLEAN    |
| Cell Area               | XXXX.XX um^2 |          |
| Core Area               | XXXX.XX um^2 |          |
| Area Utilization        | XX.X%        |          |
| Total Dynamic Power     | XX.XX uW     |          |
| Cell Leakage Power      | XX.XX uW     |          |
```

Use "FAIL" in red-style emphasis (**FAIL**) for any violations. Use "CLEAN" or "MET" for passing checks.

## Important Rules

- **Never delete or modify report files.**
- If a report file is missing, note it clearly (do not fail silently).
- Always calculate and present area utilization percentage.
- For timing, always report BOTH setup (delay_type max) and hold (delay_type min) when available.
- Flag any `Warning:` lines in reports that indicate potential issues (e.g., power table extrapolation).
