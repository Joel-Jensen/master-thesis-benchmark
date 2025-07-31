# PostgreSQL Benchmark Monitoring

This directory contains enhanced PostgreSQL benchmarking scripts that track CPU and memory usage during query execution.

## Files

- `run.sh` - Modified benchmark script that tracks system resources
- `analyze_monitoring.py` - Python script to analyze and visualize monitoring data
- `requirements.txt` - Python dependencies for analysis
- `monitoring_data/` - Directory where monitoring CSV files are saved
- `plots/` - Directory where generated plots are saved

## Usage

### 1. Run Benchmarks with Monitoring

```bash
# Run with default queries.sql
./run.sh

# Run with specific query file
./run.sh queries_1y.sql
./run.sh queries_2024.sql
```

The script will:
- Create a `monitoring_data/` directory
- Track system-wide CPU and memory usage
- Save data to CSV files with timestamps

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 3. Analyze Monitoring Data

```bash
# Create all visualizations
python analyze_monitoring.py

# Create only individual plots
python analyze_monitoring.py --individual

# Create only comparison plots
python analyze_monitoring.py --comparison

# Create only summary statistics
python analyze_monitoring.py --summary

# Use custom directories
python analyze_monitoring.py --monitor-dir custom_data --output-dir custom_plots
```

## Output Files

### Monitoring Data (CSV format)
- `{query_base}_system_{timestamp}.csv` - System-wide metrics

### Generated Plots
- Individual plots for each monitoring session
- Comparison plots across different runs
- Summary statistics in CSV format

## CSV Data Format

### System Data
```
timestamp,cpu_percent,memory_percent,memory_available_mb
1703123456.789,67.8,78.5,2048.0
1703123456.889,69.2,79.1,2032.0
...
```

## Example Workflow

1. Run benchmarks:
   ```bash
   ./run.sh queries_1y.sql
   ```

2. Analyze results:
   ```bash
   python analyze_monitoring.py
   ```

3. View generated plots in the `plots/` directory

## Notes

- Monitoring starts when each query begins and stops when the query completes
- Monitoring data is collected every 1 second for system metrics
- The script automatically handles multiple runs and creates timestamped files
- All plots are saved as high-resolution PNG files suitable for publication 