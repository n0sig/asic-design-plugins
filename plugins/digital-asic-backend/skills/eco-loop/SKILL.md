---
name: eco-loop
description: ECO Convergence Loop
allowed-tools: [Read, Glob, Grep, Bash, Skill]
---

# ECO Convergence Loop

Run the iterative ECO convergence loop: StarRC -> PrimeTime -> FC ECO. Maximum 5 iterations.

## Setup

1. Find the project root by looking for the `fc/scripts/fc_setup.tcl` file starting from the current directory.
2. Read `fc/scripts/fc_setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.

## Prerequisites

- FC DFM checkpoint must exist (full FC flow must have been completed).
- FC outputs (DEF, Verilog, SDC, GDS) must exist in `fc/output/`.

## Loop Logic

Execute this loop for up to 5 iterations:

```
for ITER in 1, 2, 3, 4, 5:
    echo "============================================"
    echo "  ECO Iteration $ITER of 5"
    echo "============================================"

    # Step 1: StarRC parasitic extraction
    Invoke /run-starrc
    -> If StarRC failed: STOP, report error to user.

    # Step 2: PrimeTime DMSA analysis
    Invoke /run-pt
    -> If PT failed: STOP, report error to user.

    # Step 3: Check convergence
    Read $PROJECT_PATH/fc/scripts/eco_changes.tcl
    -> If file is empty or contains no size_cell/insert_buffer commands:
        Report: "CONVERGED at iteration $ITER -- no ECO changes needed."
        STOP with success.

    # Step 4: Apply ECO in FC
    Invoke /run-eco
    -> If ECO failed: STOP, report error to user.

    # Step 5: Check ECO results
    Invoke /check-reports eco
    -> If DRC > 0 or LVS fails: WARN user but continue to next iteration.
    -> If timing violated: continue to next iteration (PT will try to fix).

    echo "Iteration $ITER completed."
```

If the loop reaches iteration 5 without converging:
```
WARNING: ECO loop did not converge after 5 iterations.
Please review the remaining violations and consider:
1. Adjusting timing constraints
2. Changing floorplan/die size
3. Manual ECO intervention
```

## Tracking Progress

Maintain an iteration summary table and update it after each iteration:

```
=== ECO Loop Progress ===

| Metric                | Iter 1 | Iter 2 | Iter 3 | Iter 4 | Iter 5 |
|-----------------------|--------|--------|--------|--------|--------|
| PT Setup Violations   | N      | N      |        |        |        |
| PT Hold Violations    | N      | N      |        |        |        |
| PT DRC Violations     | N      | N      |        |        |        |
| ECO Cell Sizings      | N      | N      |        |        |        |
| ECO Buffer Insertions | N      | N      |        |        |        |
| Post-ECO FC DRC       | N      | N      |        |        |        |
| Post-ECO FC LVS       | OK     | OK     |        |        |        |
| Post-ECO Setup Slack  | XX ns  | XX ns  |        |        |        |
| Post-ECO Hold Slack   | XX ns  | XX ns  |        |        |        |
| Converged?            | NO     | YES    |        |        |        |
```

## Safety Rules

- **HARD LIMIT: 5 iterations maximum.** After 5, stop and escalate to user.
- **NEVER** re-run the full FC flow during ECO iterations.
- **NEVER** modify RTL.
- Keep ALL reports from every iteration. Use iteration-specific filenames or backup directories.
- Backup the .dlib before each ECO application.
