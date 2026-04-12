---
name: run-vcs
description: Run Post-Layout VCS Simulation
allowed-tools: [Read, Glob, Grep, Bash]
---

# Run Post-Layout VCS Simulation

Compile and run post-layout simulation using VCS.

## Setup

1. Find the project root by looking for the `fc/scripts/setup.tcl` file starting from the current directory.
2. Read `fc/scripts/setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.

## Prerequisites

1. Verify post-layout netlist exists: `$PROJECT_PATH/fc/output/${DESIGN_NAME}_pt.v`
2. Verify file list exists: `$PROJECT_PATH/hdl/verilog_file_post.f`
   - If not, warn the user that a post-layout file list is needed.
3. Check `vcs/post/Makefile` exists and has correct `PROJECT_PATH`.

## Execution

```bash
cd $PROJECT_PATH/vcs/post && make com 2>&1 | tee compile_sim.log
```

Note: The VCS Makefile uses the `-R` flag which runs simulation immediately after compilation.

If the simulation takes a long time, use background execution:
```bash
cd $PROJECT_PATH/vcs/post && nohup make com > compile_sim.log 2>&1 &
echo $! > /tmp/.vcs_pid
```

## Completion Verification

1. Check compilation:
   - Grep for `Error` in `compile.log` (compilation errors)
   - Grep for `Warning` in `compile.log` (note count)
   - Check exit code (0 = success)

2. Check simulation:
   - Grep for `$finish` in `run.log` (simulation completed)
   - Grep for timing violations: `Timing violation` or `$setup` or `$hold`
   - Count setup/hold violations

3. Check for waveform files:
   ```bash
   ls $PROJECT_PATH/vcs/post/*.fsdb $PROJECT_PATH/vcs/post/*.vcd $PROJECT_PATH/vcs/post/*.vpd 2>/dev/null
   ```

## Report Format

```
=== VCS Post-Layout Simulation Summary ===

| Metric                | Value    | Status |
|-----------------------|----------|--------|
| Compilation           | OK/FAIL  |        |
| Compilation Warnings  | N        |        |
| Simulation            | OK/FAIL  |        |
| Setup Violations      | N        |        |
| Hold Violations       | N        |        |
| Waveform Generated    | YES/NO   |        |
```

## Safety Rules

- **NEVER** modify the post-layout netlist (`${DESIGN_NAME}_pt.v`).
- **NEVER** modify the testbench without user permission.
- If no testbench exists, inform the user -- do not create one automatically.
- If timing violations are found, report them but note that post-layout SDF annotation may need checking.
