---
name: run-fc-step
description: Run Single FC Step
argument-hint: <step> (design_setup|floorplan|synthesis|placement|clocktree|routing|dfm|output)
allowed-tools: [Read, Glob, Grep, Bash, Skill]
---

# Run Single FC Step

Run a single Fusion Compiler step with backup and report checking.

**Argument**: `$ARGUMENTS` = step name. One of: `design_setup`, `floorplan`, `synthesis`, `placement`, `clocktree`, `routing`, `dfm`, `output`

## Setup

1. Find the project root by looking for the `fc/scripts/setup.tcl` file starting from the current directory.
2. Read `fc/scripts/setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.

## Step Prerequisite Map

Each step requires a checkpoint from the previous step:

| Step | Requires Checkpoint | Produces Checkpoint |
|------|-------------------|-------------------|
| `design_setup` | (none -- creates library from scratch) | `${DESIGN_NAME}_initial` |
| `floorplan` | `${DESIGN_NAME}_initial` | `${DESIGN_NAME}_floorplan` |
| `synthesis` | `${DESIGN_NAME}_floorplan` | `${DESIGN_NAME}_synthesis` |
| `placement` | `${DESIGN_NAME}_synthesis` | `${DESIGN_NAME}_placement` |
| `clocktree` | `${DESIGN_NAME}_placement` | `${DESIGN_NAME}_clocktree` |
| `routing` | `${DESIGN_NAME}_clocktree` | `${DESIGN_NAME}_route` |
| `dfm` | `${DESIGN_NAME}_route` | `${DESIGN_NAME}_dfm` |
| `output` | `${DESIGN_NAME}_dfm` | (writes files to fc/output/) |

## Pre-run Checks

1. Verify the prerequisite checkpoint exists (except for `design_setup`):
   - Check that `$PROJECT_PATH/fc/${DESIGN_NAME}.dlib` exists
   - The checkpoint block name should be present in the .dlib
2. **Backup** the .dlib before running (except for `design_setup` which creates a new one):
   ```bash
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   cp -a $PROJECT_PATH/fc/${DESIGN_NAME}.dlib $PROJECT_PATH/fc/backup_${STEP}_${TIMESTAMP}.dlib
   ```

## Execution

```bash
cd $PROJECT_PATH/fc && mkdir -p scripts report output temp
cd $PROJECT_PATH/fc/temp && fc_shell -f ../scripts/runners/run_${STEP}.tcl 2>&1 | tee ../report/run_${STEP}.log
```

For longer steps (`synthesis`, `clocktree`, `routing`), consider using `run_in_background: true` or the nohup pattern:
```bash
cd $PROJECT_PATH/fc/temp && nohup fc_shell -f ../scripts/runners/run_${STEP}.tcl > ../report/run_${STEP}.log 2>&1 &
echo $! > /tmp/.fc_step_pid
```

Then poll for completion by checking if the process is still running and tailing the log.

## Post-run Report Checks

After the step completes, check the appropriate reports:

| Step | Check Reports (invoke /check-reports with) |
|------|-------------------------------------------|
| `design_setup` | Verify `save_block` succeeded in log |
| `floorplan` | Verify `save_block` succeeded in log |
| `synthesis` | `/check-reports fc-synthesis` |
| `placement` | `/check-reports fc-placement` |
| `clocktree` | `/check-reports fc-clocktree` |
| `routing` | `/check-reports fc-routing` |
| `dfm` | `/check-reports fc-dfm` |
| `output` | `/check-reports fc-output` |

## Report to User

Present the report summary and ask whether to proceed to the next step.

For each step, highlight the critical checks:
- **synthesis**: Area utilization %, timing slack, any warnings
- **clocktree**: Setup and hold timing after CTS
- **routing**: DRC violations, shorts, opens, setup and hold timing
- **dfm**: DRC = 0, LVS clean, no antenna/short/open/floating violations
- **output**: Final timing (setup + hold), power, area utilization, DRC/LVS clean

## Safety Rules

- **NEVER** modify RTL files.
- **NEVER** skip the backup step.
- **NEVER** delete reports.
- If a step fails, **do not** proceed to the next step. Report the error and suggest debugging steps.
- Check the run log for `Error` or `FATAL` messages.
