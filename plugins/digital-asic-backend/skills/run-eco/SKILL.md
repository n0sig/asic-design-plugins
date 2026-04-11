---
name: run-eco
description: Apply ECO Changes in Fusion Compiler
allowed-tools: [Read, Glob, Grep, Bash, Skill]
---

# Apply ECO Changes in Fusion Compiler

Apply PrimeTime-generated ECO changes incrementally in Fusion Compiler.

## Setup

1. Find the project root by looking for the `fc/scripts/fc_setup.tcl` file starting from the current directory.
2. Read `fc/scripts/fc_setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.

## Prerequisites

1. Verify ECO changes file exists and is non-empty: `$PROJECT_PATH/fc/scripts/eco_changes.tcl`
   - Read the file. If it's empty or contains only comments, inform user: **"No ECO changes to apply -- flow has converged."**
2. Verify the DFM checkpoint exists in `$PROJECT_PATH/fc/${DESIGN_NAME}.dlib`
3. Verify `fc/scripts/fc_setup_eco.tcl` and `fc/scripts/eco_flow.tcl` exist.

## Safety

- **CRITICAL: NEVER re-run the full FC flow during ECO. Only use fc_setup_eco.tcl.**
- Backup .dlib before ECO:
  ```bash
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  cp -a $PROJECT_PATH/fc/${DESIGN_NAME}.dlib $PROJECT_PATH/fc/backup_eco_${TIMESTAMP}.dlib
  ```
- Backup existing FC outputs:
  ```bash
  cp -a $PROJECT_PATH/fc/output $PROJECT_PATH/fc/output_backup_${TIMESTAMP}
  ```
- **NEVER** delete any reports.

## Execution

```bash
cd $PROJECT_PATH/fc && mkdir -p scripts report output temp
cd $PROJECT_PATH/fc/temp && fc_shell -f ../scripts/fc_setup_eco.tcl 2>&1 | tee ../report/run_eco.log
```

ECO typically takes 1-5 minutes. Use `run_in_background: true` if needed, or the nohup pattern:
```bash
cd $PROJECT_PATH/fc/temp && nohup fc_shell -f ../scripts/fc_setup_eco.tcl > ../report/run_eco.log 2>&1 &
echo $! > /tmp/.fc_eco_pid
```

## Post-ECO Checks

The ECO flow (eco_flow.tcl) produces the same reports as the DFM + output stages. Check:

1. **DRC**: Parse `fc/report/dfm_drc.rpt`
   - `TOTAL VIOLATIONS =` must be 0
   - `Total number of open nets =` must be 0
   - `Total number of antenna violations =` must be 0

2. **LVS**: Parse `fc/report/dfm_lvs.rpt`
   - `Total number of short violations is` must be 0
   - `Total number of open nets is` must be 0
   - `Total number of floating route violations is` must be 0

3. **Timing (setup)**: Parse `fc/report/final_timing.rpt`
   - Look for `slack (MET)` -- must not be `(VIOLATED)`

4. **Timing (hold)**: Parse `fc/report/final_timing_hold.rpt`
   - Look for `slack (MET)` -- must not be `(VIOLATED)`

5. **Power**: Parse `fc/report/final_power.rpt`

6. **QoR**: Parse `fc/report/final_qor.rpt`
   - `No. of Violating Paths:` must be 0

7. **Verify new outputs**:
   ```bash
   ls -la $PROJECT_PATH/fc/output/${DESIGN_NAME}_pt.v \
          $PROJECT_PATH/fc/output/${DESIGN_NAME}_lvs.v \
          $PROJECT_PATH/fc/output/${DESIGN_NAME}.sdc \
          $PROJECT_PATH/fc/output/${DESIGN_NAME}.gds \
          $PROJECT_PATH/fc/output/${DESIGN_NAME}.def
   ```

## Report Format

Same as `/check-reports eco`.

## Safety Rules

- **NEVER** use `fc_run_full.tcl` or `create_lib` during ECO.
- **NEVER** modify RTL.
- **NEVER** delete reports -- ECO log uses `run_eco.log` (append iteration number if tracking).
