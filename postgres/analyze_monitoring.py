#!/usr/bin/env python3
"""
Monitoring Data Analysis Script for PostgreSQL Benchmark

This script reads the CSV files generated by the modified run.sh script
and creates matplotlib visualizations of CPU and memory usage during query execution.
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime
import os
import glob
import argparse
from pathlib import Path

def load_monitoring_data(monitor_dir="monitoring_data"):
    """Load all monitoring CSV files from the specified directory."""
    data = {}
    
    # Find all CSV files
    csv_files = glob.glob(os.path.join(monitor_dir, "*.csv"))
    
    for file_path in csv_files:
        filename = os.path.basename(file_path)
        
        # Parse filename to extract query type and monitoring type
        # Expected format: {query_base}_system_{timestamp}.csv
        parts = filename.replace('.csv', '').split('_')
        
        if len(parts) >= 3 and parts[-2] == 'system':
            # Reconstruct query base (might contain underscores)
            query_base = '_'.join(parts[:-2])
            monitor_type = 'system'
            timestamp = parts[-1]
            
            try:
                df = pd.read_csv(file_path)
                df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')
                
                key = f"{query_base}_{monitor_type}_{timestamp}"
                data[key] = {
                    'data': df,
                    'query_base': query_base,
                    'monitor_type': monitor_type,
                    'timestamp': timestamp,
                    'file_path': file_path
                }
            except Exception as e:
                print(f"Error loading {file_path}: {e}")
    
    return data

def create_individual_plots(data, output_dir="plots"):
    """Create individual plots for each monitoring session."""
    os.makedirs(output_dir, exist_ok=True)
    
    for key, info in data.items():
        df = info['data']
        query_base = info['query_base']
        monitor_type = info['monitor_type']
        timestamp = info['timestamp']
        
        fig, axes = plt.subplots(2, 1, figsize=(12, 8))
        fig.suptitle(f'{query_base} - System Monitoring - {timestamp}', fontsize=14)
        
        # CPU Usage
        axes[0].plot(df['timestamp'], df['cpu_percent'], 'b-', linewidth=1)
        axes[0].set_ylabel('CPU Usage (%)')
        axes[0].set_title('System CPU Usage Over Time')
        axes[0].grid(True, alpha=0.3)
        axes[0].xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
        
        # Memory Usage
        axes[1].plot(df['timestamp'], df['memory_percent'], 'r-', linewidth=1)
        axes[1].set_ylabel('Memory Usage (%)')
        axes[1].set_title('System Memory Usage Over Time')
        axes[1].set_xlabel('Time')
        axes[1].grid(True, alpha=0.3)
        axes[1].xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
        
        plt.tight_layout()
        
        # Save plot
        plot_filename = f"{key}.png"
        plot_path = os.path.join(output_dir, plot_filename)
        plt.savefig(plot_path, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Created plot: {plot_path}")

def create_comparison_plots(data, output_dir="plots"):
    """Create comparison plots across different query types."""
    os.makedirs(output_dir, exist_ok=True)
    
    # Group data by query base
    query_groups = {}
    for key, info in data.items():
        query_base = info['query_base']
        if query_base not in query_groups:
            query_groups[query_base] = []
        query_groups[query_base].append(info)
    
    # Create comparison plots for each query type
    for query_base, group_info in query_groups.items():
        fig, axes = plt.subplots(2, 1, figsize=(15, 8))
        fig.suptitle(f'System Performance Comparison: {query_base}', fontsize=16)
        
        # System CPU Usage
        ax1 = axes[0]
        for info in group_info:
            df = info['data']
            label = f"Run {info['timestamp']}"
            ax1.plot(df['timestamp'], df['cpu_percent'], label=label, linewidth=1)
        ax1.set_ylabel('CPU Usage (%)')
        ax1.set_title('System CPU Usage')
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
        
        # System Memory Usage
        ax2 = axes[1]
        for info in group_info:
            df = info['data']
            label = f"Run {info['timestamp']}"
            ax2.plot(df['timestamp'], df['memory_percent'], label=label, linewidth=1)
        ax2.set_ylabel('Memory Usage (%)')
        ax2.set_title('System Memory Usage')
        ax2.set_xlabel('Time')
        ax2.legend()
        ax2.grid(True, alpha=0.3)
        ax2.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
        
        plt.tight_layout()
        
        # Save plot
        plot_filename = f"{query_base}_comparison.png"
        plot_path = os.path.join(output_dir, plot_filename)
        plt.savefig(plot_path, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Created comparison plot: {plot_path}")

def create_summary_statistics(data, output_dir="plots"):
    """Create summary statistics and save to CSV."""
    summary_data = []
    
    for key, info in data.items():
        df = info['data']
        
        # Calculate statistics
        stats = {
            'query_base': info['query_base'],
            'monitor_type': info['monitor_type'],
            'timestamp': info['timestamp'],
            'duration_seconds': (df['timestamp'].max() - df['timestamp'].min()).total_seconds(),
            'cpu_mean': df['cpu_percent'].mean(),
            'cpu_max': df['cpu_percent'].max(),
            'cpu_std': df['cpu_percent'].std()
        }
        
        # Add memory statistics
        stats['memory_mean'] = df['memory_percent'].mean()
        stats['memory_max'] = df['memory_percent'].max()
        stats['memory_std'] = df['memory_percent'].std()
        
        summary_data.append(stats)
    
    # Create summary DataFrame
    summary_df = pd.DataFrame(summary_data)
    
    # Save summary
    summary_path = os.path.join(output_dir, "monitoring_summary.csv")
    summary_df.to_csv(summary_path, index=False)
    print(f"Created summary: {summary_path}")
    
    return summary_df

def main():
    parser = argparse.ArgumentParser(description='Analyze PostgreSQL monitoring data')
    parser.add_argument('--monitor-dir', default='monitoring_data', 
                       help='Directory containing monitoring CSV files')
    parser.add_argument('--output-dir', default='plots', 
                       help='Directory to save generated plots')
    parser.add_argument('--individual', action='store_true',
                       help='Create individual plots for each monitoring session')
    parser.add_argument('--comparison', action='store_true',
                       help='Create comparison plots across runs')
    parser.add_argument('--summary', action='store_true',
                       help='Create summary statistics')
    
    args = parser.parse_args()
    
    # Load data
    print("Loading monitoring data...")
    data = load_monitoring_data(args.monitor_dir)
    
    if not data:
        print("No monitoring data found!")
        return
    
    print(f"Loaded {len(data)} monitoring sessions")
    
    # Create plots based on arguments
    if args.individual:
        print("Creating individual plots...")
        create_individual_plots(data, args.output_dir)
    
    if args.comparison:
        print("Creating comparison plots...")
        create_comparison_plots(data, args.output_dir)
    
    if args.summary:
        print("Creating summary statistics...")
        summary_df = create_summary_statistics(data, args.output_dir)
        print("\nSummary Statistics:")
        print(summary_df.to_string(index=False))
    
    # If no specific option is selected, create all
    if not any([args.individual, args.comparison, args.summary]):
        print("Creating all visualizations...")
        create_individual_plots(data, args.output_dir)
        create_comparison_plots(data, args.output_dir)
        summary_df = create_summary_statistics(data, args.output_dir)
        print("\nSummary Statistics:")
        print(summary_df.to_string(index=False))

if __name__ == "__main__":
    main() 