# Data folder

This repository expects the raw grocery panel at:

```text
data/raw/grocery.csv
```

## Why the raw file is not included

The original CSV was provided through course materials.  
Before publishing a public repository, check whether redistribution is allowed.  
If you are not sure, keep the repo public **without** the raw file and use this folder only for local reproduction.

## Expected columns

- `BASE_PRICE`
- `PRICE`
- `WEEK_END_DATE`
- `STORE_NUM`
- `UPC`
- `MANUFACTURER`
- `DISPLAY`
- `FEATURE`
- `TPR_ONLY`
- `UNITS`

## Local-only workflow

1. Place `grocery.csv` in `data/raw/`.
2. Run `src/05_run_model_comparison.R`.
3. Review generated outputs in `results/`.
