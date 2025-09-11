#!/bin/bash

# Ensure the logs directory exists
mkdir -p logs

# get current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Build log file name (including test name and timestamp)
LOG_FILE="logs/${1##*/}_${TIMESTAMP}.log"

cd Yux_FHE_HElib/build

# Run tests and capture output
echo "=== Running $1 at $(date) ===" | tee -a ../$LOG_FILE
./$@ 2>&1 | tee -a ../$LOG_FILE

# Add execution result status
EXIT_STATUS=${PIPESTATUS[0]}
echo -e "\n=== Test completed with exit status: $EXIT_STATUS ===" | tee -a ../$LOG_FILE
