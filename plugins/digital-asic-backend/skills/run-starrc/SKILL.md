---
name: run-starrc
description: Run StarRC Parasitic Extraction
allowed-tools: [Read, Glob, Grep, Bash]
---

# Run StarRC Parasitic Extraction

Run StarRC parasitic extraction for all 4 corners.

## Setup

1. Find the project root by looking for the `fc/scripts/setup.tcl` file starting from the current directory.
2. Read `fc/scripts/setup.tcl` to extract `DESIGN_NAME` and `PROJECT_PATH`.

## Prerequisites

1. Verify FC DFM checkpoint exists: `$PROJECT_PATH/fc/${DESIGN_NAME}.dlib` must contain the `${DESIGN_NAME}_dfm` block.
2. Verify StarRC command files exist in `$PROJECT_PATH/starrc/scripts/`:
   - `extract_cmax_25c.cmd`
   - `extract_cmax_125c.cmd`
   - `extract_cmin_25c.cmd`
   - `extract_cmin_125c.cmd`
3. Verify TCAD grid files are accessible (read the `TCAD_GRD_FILE` path from one of the .cmd files).
4. Verify the NDM database path in the .cmd files points to the current .dlib.

## Safety

- Backup existing SPEF files if present:
  ```bash
  if [ -d "$PROJECT_PATH/starrc/spef" ] && [ "$(ls -A $PROJECT_PATH/starrc/spef 2>/dev/null)" ]; then
      cp -a $PROJECT_PATH/starrc/spef $PROJECT_PATH/starrc/spef_backup_$(date +%Y%m%d_%H%M%S)
  fi
  ```
- **NEVER** modify the FC design library.

## Execution

StarRC runs 4 sequential extractions. For this design size (~400 nets), each takes seconds. For larger designs, use background execution.

```bash
cd $PROJECT_PATH/starrc && mkdir -p spef temp
cd $PROJECT_PATH/starrc/temp && \
    StarXtract -clean ../scripts/extract_cmax_25c.cmd && \
    StarXtract -clean ../scripts/extract_cmax_125c.cmd && \
    StarXtract -clean ../scripts/extract_cmin_25c.cmd && \
    StarXtract -clean ../scripts/extract_cmin_125c.cmd
```

For larger designs or if timeout is a concern:
```bash
cd $PROJECT_PATH/starrc && nohup make run > temp/starrc_run.log 2>&1 &
echo $! > /tmp/.starrc_pid
```

Then poll for completion.

## Completion Verification

1. Check all 4 SPEF files exist and have non-zero size:
   ```bash
   ls -la $PROJECT_PATH/starrc/spef/cmax_25c.spef \
          $PROJECT_PATH/starrc/spef/cmax_125c.spef \
          $PROJECT_PATH/starrc/spef/cmin_25c.spef \
          $PROJECT_PATH/starrc/spef/cmin_125c.spef
   ```

2. Check for errors in StarRC summary files:
   ```bash
   grep -ri "error" $PROJECT_PATH/starrc/temp/stardir_*/summary/*.sum 2>/dev/null
   ```

3. Check for `success.lock` files in each stardir:
   ```bash
   ls $PROJECT_PATH/starrc/temp/stardir_*/success.lock
   ```

## Report Format

```
=== StarRC Extraction Summary ===

| Corner     | SPEF File      | Size     | Status |
|------------|----------------|----------|--------|
| cmax_25c   | cmax_25c.spef  | XXX KB   | OK     |
| cmax_125c  | cmax_125c.spef | XXX KB   | OK     |
| cmin_25c   | cmin_25c.spef  | XXX KB   | OK     |
| cmin_125c  | cmin_125c.spef | XXX KB   | OK     |
```

## Safety Rules

- **NEVER** modify the FC design library or any FC output files.
- If extraction fails for one corner, report which corner failed and check the stardir error logs.
