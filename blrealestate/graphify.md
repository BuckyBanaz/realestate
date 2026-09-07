# Graphify: Project Visualization Guide

This document explains how to generate the `graphify-out` directory for a project. This folder contains a 3D visualization and a detailed architectural report used by AI agents to quickly onboard and understand the codebase.

## Prerequisites
- The `graphify` CLI tool must be installed on your local machine.

## Steps to Generate `graphify-out`

### 1. Initialize the Graph
Navigate to your project root in the terminal and run:
```bash
graphify init .
```
This command scans all files, extracts dependencies, and creates the initial `graph.json` data file.

### 2. Update/Refresh the Graph
If you have made code changes and want the graph to reflect the latest state:
```bash
graphify update .
```

### 3. Community Detection & Report Generation
To cluster the code into logical "communities" and generate the Markdown report:
```bash
graphify cluster-only .
```

## Output Structure
The following files will be created in the `graphify-out/` directory:
- **`graph.html`**: Interactive 3D visualization of file relationships.
- **`GRAPH_REPORT.md`**: Architectural summary, community detection results, and node stats.
- **`graph.json`**: Raw relationship data used by the visualization engine.
- **`cache/`**: Cached extraction data for faster subsequent updates.

## Agent Instructions
When an AI agent (like Antigravity, Trae, or Hermes) encounters a project with this tool, it should:
1. Check for an existing `graphify-out/GRAPH_REPORT.md` to get an instant architectural overview.
2. If it doesn't exist, use the `graphify init .` command to build its own mental map of the project structure.
