#! /usr/bin/env bash

startTime=$(date +%s%N)
elapsed=0

# syncUp function is used to get accurate time to be elapsed
syncUp() {
    elapsed=$((elapsed + ($1 * 1000000000)))
    delta=$(echo "scale=10; (($startTime + $elapsed) - $(date +%s%N)) / 1000000000" | bc)

    if (( $(echo "$delta < 0" | bc -l) )); then
        delta=0
    fi

    echo "Sleep" $delta
    sleep $delta
}

# startAction / stopAction functions not needed

for ((i = 1; i <= 10; i++)); do

    # burn in
    syncUp 60

    # start
    echo "iteration $i;$(date -I) $(date +%T);startTestrun" >> ~/log_baseline.csv
    echo "start iteration $i"

    syncUp 1

    # leave running for time (in seconds)
    # for SUS
    syncUp 218

    # stop iteration
    echo " stop iteration "
    echo "iteration $i;$(date -I) $(date +%T);stopTestrun" >> ~/log_baseline.csv

    syncUp 1

    # cool down
    syncUp 30

done
