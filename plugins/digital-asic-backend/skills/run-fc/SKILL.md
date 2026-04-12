---
name: run-fc
description: Run Full Fusion Compiler Flow
allowed-tools: [Read, Glob, Grep, Bash, Skill]
---

# Run Full Fusion Compiler Flow

Run the complete Fusion Compiler synthesis + place & route flow from scratch.

## Setup

1. Find the project root by looking for the `fc/scripts/setup.tcl` file starting from the current directory.
2. Read `fc/scripts/setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.

## Pre-flight Checks

1. Verify RTL files exist in `$PROJECT_PATH/hdl/` (read `fc/scripts/steps/design_setup.tcl` to see which files are needed).
2. Verify PDK path is accessible (check `LIBRARY_PATH` from `setup.tcl`).
3. Check if `fc/${DESIGN_NAME}.dlib` already exists:
   - If yes, **warn the user** and create a backup:
     ```
     cp -a $PROJECT_PATH/fc/${DESIGN_NAME}.dlib $PROJECT_PATH/fc/backup_full_$(date +%Y%m%d_%H%M%S).dlib
     ```
4. Ensure `fc/scripts/runners/run_full.tcl` exists.

## Execution

Run from the `fc/` directory:
```bash
cd $PROJECT_PATH/fc && mkdir -p scripts report output temp
```

Then launch fc_shell. Since this can take a long time, use background execution:
```bash
cd $PROJECT_PATH/fc/temp && nohup fc_shell -f ../scripts/runners/run_full.tcl > ../report/run_fc.log 2>&1 &
echo $! > /tmp/.fc_run_pid
echo "RUNNING" > /tmp/.fc_run_status
```

Then poll for completion by checking:
1. Whether the process is still running: `kill -0 $(cat /tmp/.fc_run_pid) 2>/dev/null`
2. Tail the log for progress markers: `tail -20 $PROJECT_PATH/fc/report/run_fc.log`
3. Look for completion: grep for `"Fusion Compiler flow completed"` or `"Error"` in the log

When using the Bash tool, set `run_in_background: true` if you expect the run to take more than a few minutes. You will be notified when it completes.

For smaller designs where the full flow may complete within 10 minutes, you can run directly:
```bash
cd $PROJECT_PATH/fc/temp && fc_shell -f ../scripts/runners/run_full.tcl 2>&1 | tee ../report/run_fc.log
```

## Post-run

After completion, invoke `/check-reports all` to parse and present all report results.

## Safety Rules

- **NEVER** modify RTL files in `hdl/`.
- **NEVER** delete existing report files. If re-running, the new run overwrites reports naturally.
- **Always** backup the .dlib before a fresh run.
- If the run fails mid-way, check the log for the last successful `save_block` to determine which checkpoint is valid.
