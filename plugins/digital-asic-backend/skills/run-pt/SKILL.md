---
name: run-pt
description: Run PrimeTime DMSA Analysis
allowed-tools: [Read, Glob, Grep, Bash]
---

# Run PrimeTime DMSA Analysis

Run PrimeTime distributed multi-scenario analysis for timing signoff and ECO generation.

## Setup

1. Find the project root by looking for the `fc/scripts/setup.tcl` file starting from the current directory.
2. Read `fc/scripts/setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.
3. Read `pt/scripts/setup.tcl` to understand the DMSA configuration.

## Prerequisites

1. Verify FC post-PnR netlist exists: `$PROJECT_PATH/fc/output/${DESIGN_NAME}_pt.v`
2. Verify FC SDC exists: `$PROJECT_PATH/fc/output/${DESIGN_NAME}.sdc`
3. Verify all 4 SPEF files exist in `$PROJECT_PATH/starrc/spef/`:
   - `cmax_25c.spef`, `cmax_125c.spef`, `cmin_25c.spef`, `cmin_125c.spef`
4. Verify SPEF paths in `pt/scripts/setup.tcl` match the actual SPEF locations.

## Safety

- Backup existing PT reports:
  ```bash
  if [ -d "$PROJECT_PATH/pt/report" ] && [ "$(ls -A $PROJECT_PATH/pt/report 2>/dev/null)" ]; then
      cp -a $PROJECT_PATH/pt/report $PROJECT_PATH/pt/report_backup_$(date +%Y%m%d_%H%M%S)
  fi
  ```
- **NEVER** modify FC outputs or StarRC SPEF files.

## Execution

PrimeTime DMSA runs 4 scenarios (func_tt_cmax, func_tt_cmin, func_ss_cmax, func_ss_cmin). This typically takes 5-15 minutes.

```bash
cd $PROJECT_PATH/pt && mkdir -p report result work temp
```

Use background execution:
```bash
cd $PROJECT_PATH/pt/temp && nohup pt_shell -multi_scenario -f ../scripts/dmsa.tcl > dmsa.log 2>&1 &
echo $! > /tmp/.pt_pid
```

Poll for completion:
1. Check if process is still running: `kill -0 $(cat /tmp/.pt_pid) 2>/dev/null`
2. Tail the log: `tail -20 $PROJECT_PATH/pt/temp/dmsa.log`
3. Check for completion markers in the log (e.g., `write_changes` output)

Alternatively for smaller designs:
```bash
cd $PROJECT_PATH/pt/temp && pt_shell -multi_scenario -f ../scripts/dmsa.tcl 2>&1 | tee dmsa.log
```

## Completion Verification

1. Verify report files exist:
   - `$PROJECT_PATH/pt/report/${DESIGN_NAME}_allvios.rpt`
   - `$PROJECT_PATH/pt/report/${DESIGN_NAME}_fix_all_vios.report`
2. Check for errors in work dir: `cat $PROJECT_PATH/pt/work/error_log.txt`
3. **Check ECO convergence**: Read `$PROJECT_PATH/fc/scripts/eco_changes.tcl`:
   - If the file is empty or contains only comments/whitespace -> **CONVERGED** (no ECO needed)
   - If it contains `size_cell` or `insert_buffer` commands -> ECO changes needed

## Report Parsing

### Violations Report (`*_allvios.rpt`)
Count lines containing `(VIOLATED)` and categorize:
- Setup timing violations
- Hold timing violations
- max_transition violations
- max_capacitance violations
- min_capacitance violations

### Post-ECO Violations (`*_fix_all_vios.report`)
Same parsing -- these show residual violations after ECO fixes.

### Noise Reports
Check `*_report_noise_all_viol_*.report` for noise violations.

### Annotated Parasitics
Check `*_report_annotated_parasitics_*.report` for annotation coverage -- should be close to 100%.

## Report Format

```
=== PrimeTime DMSA Summary ===

| Category         | Pre-ECO Violations | Post-ECO Violations |
|------------------|-------------------|-------------------|
| Setup Timing     | N                 | N                 |
| Hold Timing      | N                 | N                 |
| max_transition   | N                 | N                 |
| max_capacitance  | N                 | N                 |
| Noise            | N                 | N                 |

ECO Changes Generated:
- Cell sizings: N
- Buffer insertions: N
- Convergence: YES/NO
```

## Safety Rules

- **NEVER** modify the FC netlist or SPEF files.
- PrimeTime may require multiple licenses. If license errors appear in the log, report to user.
- Check `pt/work/error_log.txt` for any worker errors.
