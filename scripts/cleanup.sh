#!/bin/sh
# Common cleanup script — removes all files created by any pipeline stage
# that could be leftover from a previous cancelled or failed run.
#
# Called from before_script of every stage in both pipelines.
# Safe at any stage: rm -f silently ignores non-existent files.

echo "=== Cleaning up leftover processes and files from previous runs ==="

# -------------------------------------------------------
# Runner-local processes (Raspi)
# -------------------------------------------------------

# Kill any leftover power meter measurement process
pkill -f check_gude_modified.py || true

echo "Runner process cleanup done."

# -------------------------------------------------------
# Runner-local files (Raspi)
# -------------------------------------------------------

# Power meter readings (energy_measurement stage)
rm -f ~/testreadings1.csv \
       ~/testreadings2.csv \
       ~/testreadings3.csv

# R preprocessing outputs (result stage)
rm -f ~/pm_bse.csv ~/pm_idl.csv ~/pm_sus.csv \
       ~/hw_bse.csv ~/hw_idl.csv ~/hw_sus.csv \
       ~/log_sus.csv ~/log_baseline.csv ~/log_idle.csv

# Generated reports and graphics (result stage)
rm -rf ~/SUS_Report.pdf ~/SUS_Report.tex \
        ~/sus_graphics ~/SUS_Report_files \
        ~/Idle_Report.pdf ~/Idle_Report.tex \
        ~/idle_graphics ~/Idle_Report_files

echo "Runner cleanup done."

# -------------------------------------------------------
# LABPC files (via SSH)
# -------------------------------------------------------

if [ -f "${HOME}/.ssh/kecolab" ]; then
  echo "Killing leftover LABPC processes..."
  # Kill any SUS/measurement scripts still running from a previous cancelled job.
  # pkill -f matches by full command name so this works for any app's scripts.
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/kecolab kecolab@"${LABPC_IP}" '
    pkill -f log_sus.sh    || true
    pkill -f log_baseline.sh || true
    pkill -f log_idle.sh   || true
    pkill -f collectl       || true' || true
  echo "LABPC process cleanup done."

  echo "Cleaning up LABPC files..."
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/kecolab kecolab@"${LABPC_IP}" \
    'rm -f log_sus.csv log_baseline.csv log_idle.csv \
            test1.csv-*.tab.gz test2.csv-*.tab.gz test3.csv-*.tab.gz \
            *_system-info.txt \
            /tmp/log_sus.sh /tmp/log_baseline.sh /tmp/log_idle.sh' || true
  echo "LABPC cleanup done."
fi

echo "=== Cleanup complete ==="
