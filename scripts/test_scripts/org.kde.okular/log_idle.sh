#! /usr/bin/env bash

startTime=$(date +%s%N)
elapsed=0

syncUp() {
    elapsed=$((elapsed + ($1 * 1000000000)))
    delta=$(echo "scale=10; (($startTime + $elapsed) - $(date +%s%N)) / 1000000000" | bc)

    if (( $(echo "$delta < 0" | bc -l) )); then
        delta=0
    fi

    echo "Sleep" $delta
    sleep $delta
}

# startAction / stopAction functions are used to output the time and action into log.csv file
startAction() {
    echo "iteration $1;$(date -I) $(date +%T);startAction;$2 " >> ~/log_idle.csv
}
stopAction() {
    echo "iteration $1;$(date -I) $(date +%T);stopAction " >> ~/log_idle.csv
}

# Start scripts with everything fresh
# Make sure Okular is not running
flatpak kill org.kde.okular || true
# Remove previous logs and dot-files
rm -f ~/log_idle.csv
rm ~/.var/app/org.kde.okular/config/okularrc
rm ~/.var/app/org.kde.okular/config/okularpartrc
rm -r ~/.var/app/org.kde.okular/cache/*

for ((i = 1; i <= 10; i++)); do

    # burn in
    syncUp 60

    # start
    echo "iteration $i;$(date -I) $(date +%T);startTestrun" >> ~/log_idle.csv
    echo "start iteration $i"

    # start pause
    syncUp 5

    # open okular
    echo " open okular "
    startAction "$i" "open okular"
    flatpak run org.kde.okular > /dev/null 2>&1 & #Open Okular
    syncUp 2
    stopAction "$i"

    # leave open for time (in seconds)
    # for SUS minus start pause minus wrap-up
    syncUp 225 #210

    # wrap-up
    # quit okular
    echo " quit okular "
    startAction "$i" "quit okular"
    # making sure okular is focused
    kdotool search --class okular windowactivate
    # Keypress Ctrl+q
    ydotool key 29:1 16:1 29:0 16:0
    syncUp 2
    stopAction "$i"

    # stop iteration
    echo " stop iteration "
    echo "iteration $i;$(date -I) $(date +%T);stopTestrun" >> ~/log_idle.csv

    syncUp 1

    # Remove logs
    rm ~/.var/app/org.kde.okular/config/okularrc
    rm ~/.var/app/org.kde.okular/config/okularpartrc
    rm -r ~/.var/app/org.kde.okular/cache/*

    # cool down
    syncUp 30

    clear

done
