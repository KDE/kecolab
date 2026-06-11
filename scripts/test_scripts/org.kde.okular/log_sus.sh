#!/usr/bin/env bash

# Make sure language is set to en_us
setxkbmap us

##################################################################
# THESE NEED TO BE DEFINED IN OKULAR THROUGH CONFIGURATION SCRIPT#
##################################################################
# Rotate Left: Ctrl+l
# Rotate Right: Ctrl+r
# Invert color: Ctrl+i
# Fit to width: Ctrl+Shift+w
# Single page mode: Ctrl+Alt+s

# Log file names start with today's date, so new log file name is given if running past midnight.

# syncUp unction to synchronize code execution with real-world time:
# It executes sleep command with about 0.99% accuracy.
# It calculates the elapsed time by adding the argument ($1) multiplied by 1 billion (1000000000) to the elapsed variable.
# It calculates the delta (difference) between the start time ($startTime) plus the elapsed time and the current time in nanoseconds ($(date +%s%N)).
# It uses the bc command in a pipeline to perform floating-point arithmetic to divide the delta by 1 billion and store the result in the delta variable.
# Then it sleeps for this delta variable.
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

# startAction / stopAction functions are used to output the time and action into log.csv file
startAction() {
    echo "iteration $1;$(date -I) $(date +%T);startAction;$2 " >> ~/log_sus.csv
}
stopAction() {
    echo "iteration $1;$(date -I) $(date +%T);stopAction " >> ~/log_sus.csv
}

# Log the system info at the time of testing
flatpak info org.kde.okular >> ~/$(date +%Y%m%d)_system-info.txt
inxi -F >> ~/$(date -d "today" +"%Y%m%d")\_system-info.txt

# Start scripts with everything fresh
# Make sure Okular is not running
flatpak kill org.kde.okular || true

# Remove previous logs and dot-files
rm -f ~/log_sus.csv
rm ~/.var/app/org.kde.okular/config/okularrc
rm ~/.var/app/org.kde.okular/config/okularpartrc
rm -r ~/.var/app/org.kde.okular/cache/*
rm -f ~/Documents/20yearsofKDE.pdf

# Define PDF used for the script exists
FILE=~/Documents/okular/20yearsofKDE.pdf
# check if the file exists
if test -f "$FILE"; then
    echo "$FILE exists"
# if it does not exist, download it
else
    wget https://20years.kde.org/book/20yearsofKDE.pdf -P ~/Documents/okular/
fi

# Loop running for 30 times
# Start loop
for ((i = 1 ; i <= 30; i++)); do

    # Copy PDF to home directory
    # so PDF is identical every time
    cp ~/Documents/okular/20yearsofKDE.pdf ~/Documents/20yearsofKDE.pdf

    # Burn in time
    syncUp 60

    # Start iteration
    echo "iteration $i;$(date -I) $(date +%T);startTestrun" >> ~/log_sus.csv
    echo "start iteration $i"

    # start pause
    syncUp 5

    # Open okular, discard STDERR and STDOUT to /dev/null
    echo " Open Okular "
    startAction "$i" "Open Okular"
    flatpak run org.kde.okular > /dev/null 2>&1 &
    syncUp 2
    stopAction "$i"

    # open PDF document
    echo " open PDF document "
    startAction "$i" "open PDF document"
    # Keypress Ctrl+o
    ydotool key 29:1 24:1 29:0 24:0
    syncUp 1
    # Type 20yearsofKDE.pdf
    ydotool type "20yearsofKDE.pdf"
    syncUp 1
    # Keypress Return/Enter
    ydotool key 28:1 28:0
    syncUp 1
    stopAction "$i"

    # NOTE not in xdotool script
    # Maximize okular window
    echo " Maximize Window"
    startAction "$i" "Maximize window"
    # No direct command 
    # Move to top left and resize to 100%
    kdotool search --class okular windowmove 0 0 windowsize 100% 100%
    syncUp 2
    stopAction "$i"

    # NOTE not in xdotool script
    # Toggle to single page mode
    echo " Single page mode"
    startAction "$i" "Single page mode"
    # Keypress Ctrl+Alt+s
    ydotool key 29:1 56:1 31:1 29:0 56:0 31:0
    syncUp 1
    stopAction "$i"

    # Fit to width
    echo " Fit to width "
    startAction "$i" "Fit to width"
    # Keypress Ctrl+Shift+w
    ydotool key 29:1 42:1 17:1 29:0 42:0 17:0
    syncUp 2
    stopAction "$i"

    # Enter page number 38 and jump there
    echo " Open Go to dialogue and type 38 "
    startAction "$i" "Open Go to dialogue and type 38"
    # Keypress Ctrl+g
    ydotool key 29:1 34:1 29:0 34:0
    syncUp 1
    # Type 38
    ydotool type "38"
    syncUp 1
    # Keypress Return
    ydotool key 28:1 28:0
    syncUp 1
    stopAction "$i"

    # TODO Script differs significantly from xdotool
    # Mark text and insert comment
    echo " Toggle annotation panel "
    startAction "$i" "Toggle annotation panel"
    # Toggle annotations panel
    # Keypress F6
    ydotool key 64:1 64:0
    syncUp 2

    # Move mouse to center of Okular window
    # No direct Command
    # Move mouse to center of maximized Okular window
    echo "Move mouse to center of window"

    # Get the active window geometry
    WIN_ID=$(kdotool getactivewindow)
    loc="$(kdotool getwindowgeometry "$WIN_ID")"

    # Extract only width and height (position is always 0,0 for maximized)
    width=$(echo "$loc" | sed -n 's/.*Geometry: \([0-9.]*\)x.*/\1/p')
    height=$(echo "$loc" | sed -n 's/.*Geometry: [0-9.]*x\([0-9.]*\).*/\1/p')

    # Calculate center
    center_x=$(echo "$width / 2" | bc)
    center_y=$(echo "$height / 2" | bc)

    # Reset mouse to top-left and move to center
    ydotool mousemove -x -9999 -y -9999
    syncUp 2
    ydotool mousemove -x "$center_x" -y "$center_y"

    syncUp 2
    stopAction "$i"

    # Select text with highlighter tool
    echo " Toggle highlighter tool and select text to highlight "
    startAction "$i" "Toggle highlighter tool and select text to highlight"
    # Keypress Alt+1
    ydotool key 56:1 2:1 56:0 2:0
    syncUp 1
    # Hold mouse button down, move directly downwards (180) for 75 pixels, unclick
    ydotool click 0x40
    ydotool mousemove -x 0 -y 75
    # NOTE change to 1
    syncUp 2
    ydotool click 0x80
    # NOTE change to 1
    syncUp 2
    stopAction "$i"

    # Move mouse directly downwards from middle point of
    # window (180) over highlighted text, double click to add note
    echo " Write annotation "
    startAction "$i" "Write annotation"
    # Move directly upwards (180) for 25 pixels and double click to open annotation
    ydotool mousemove -x 0 -y -25
    ydotool click -r 2 0xC0
    # Type 'Very interesting text! I should read more about this topic.
    ydotool type 'Very interesting text! I should read more about this topic.'
    syncUp 8
    stopAction "$i"

    # return to browsing mode
    echo " Toggle highlighter tool again to return to browsing mode "
    startAction "$i" "Toggle highlighter tool again to return to browsing mode"
    # Keypress Alt+1
    ydotool key 56:1 2:1 56:0 2:0
    syncUp 2
    stopAction "$i"

    # Start presentation mode and move up and down pages
    echo " Start presentation mode "
    startAction "$i" "Start presentation mode"
    # Toggle presentation
    # Keypress Ctrl+Shift+p
    ydotool key 29:1 42:1 25:1 29:0 42:0 25:0
    # NOTE change sync to 1
    syncUp 3
    # Close default popup window
    # Keypress Return/Enter
    ydotool key 28:1 28:0
    syncUp 1
    stopAction "$i"

    # Move around the pages
    echo " Move down five pages "
    startAction "$i" "Move down a page 1"
    # Keypress Down
    ydotool key 108:1 108:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move down a page 2"
    # Keypress Down
    ydotool key 108:1 108:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move down a page 3"
    # Keypress Down
    ydotool key 108:1 108:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move down a page 4"
    # Keypress Down
    ydotool key 108:1 108:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move down a page 5"
    # Keypress Down
    ydotool key 108:1 108:0
    syncUp 2
    stopAction "$i"

    echo " Move up five pages "
    startAction "$i" "Move up a page 1"
    # Keypress Up
    ydotool key 103:1 103:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move up a page 2"
    # Keypress Up
    ydotool key 103:1 103:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move up a page 3"
    # Keypress Up
    ydotool key 103:1 103:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move up a page 4"
    # Keypress Up
    ydotool key 103:1 103:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move up a page 5"
    # Keypress Up
    ydotool key 103:1 103:0
    syncUp 2
    stopAction "$i"

    # Exit
    echo " Exit presentation mode "
    startAction "$i" "Exit presentation mode"
    # Keypress Escape
    ydotool key 1:1 1:0
    syncUp 1
    stopAction "$i"

    # Move mouse to center of Okular window, click mouse to exit annotation text box
    echo " Move mouse to center of window "
    startAction "$i" "Move mouse to center of window"
    # Get the active window geometry
    WIN_ID=$(kdotool getactivewindow)
    loc="$(kdotool getwindowgeometry "$WIN_ID")"
    # Extract only width and height (position is always 0,0 for maximized)
    width=$(echo "$loc" | sed -n 's/.*Geometry: \([0-9.]*\)x.*/\1/p')
    height=$(echo "$loc" | sed -n 's/.*Geometry: [0-9.]*x\([0-9.]*\).*/\1/p')
    # Calculate center
    center_x=$(echo "$width / 2" | bc)
    center_y=$(echo "$height / 2" | bc)
    # Reset mouse to top-left and move to center
    ydotool mousemove -x -9999 -y -9999
    syncUp 1
    ydotool mousemove -x "$center_x" -y "$center_y"
    # NOTE change sync to 1
    syncUp 2
    ydotool click 0xC0
    # NOTE change sync to 1
    syncUp 3
    stopAction "$i"

    # Rotate page right twice
    echo " Rotate page right twice "
    startAction "$i" "Rotate page right 1"
    # Keypress Ctrl+r
    ydotool key 29:1 19:1 29:0 19:0
    syncUp 2
    stopAction "$i"
    syncUp 4
    startAction "$i" "Rotate page right 2"
    # Keypress Ctrl+r
    ydotool key 29:1 19:1 29:0 19:0
    syncUp 2
    stopAction "$i"
    syncUp 4

    # Rotate page left twice
    echo " Rotate page left twice "
    startAction "$i" "Rotate page left 1"
    # Keypress Ctrl+l
    ydotool key 29:1 38:1 29:0 38:0
    syncUp 2
    stopAction "$i"
    syncUp 4
    echo " Rotate page left 2 "
    startAction "$i" "Rotate page left 2"
    # Keypress Ctrl+l
    ydotool key 29:1 38:1 29:0 38:0
    syncUp 2
    stopAction "$i"
    syncUp 4

    # Move around the pages
    echo " Move forward five pages "
    startAction "$i" "Move forward a page 1"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 2"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 3"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 4"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 5"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"

    echo " Move backward five pages "
    startAction "$i" "Move backward a page 1"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 2"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 3"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 4"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 5"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    syncUp 1

    # Zoom out
    echo " Zoom to 100 percent "
    startAction "$i" "Zoom to 100 percent"
    # Keypress Ctrl+0
    ydotool key 29:1 11:1 29:0 11:0
    syncUp 3
    stopAction "$i"

    echo " Zoom to 400 percent "
    # Zoom in
    startAction "$i" "Zoom in to 400 percent 1"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 2"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 3"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 4"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 5"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"

    # Fit to width
    echo " Fit to width "
    startAction "$i" "Fit to width"
    # Keypress Ctrl+Shift+w
    ydotool key 29:1 42:1 17:1 29:0 42:0 17:0
    syncUp 1
    stopAction "$i"

    # Invert colors
    echo " Invert colors "
    startAction "$i" "Invert colors"
    # Invert colors
    # Keypress Ctrl+i
    ydotool key 29:1 23:1 29:0 23:0
    syncUp 2
    stopAction "$i"
    syncUp 3

# START PARTIAL REPEAT
# Note: now goes to page number 42, writes slightly different annotation

    # Enter page number 42 and jump there
    echo " Open Go to dialogue and type 42 "
    startAction "$i" "Open Go to dialogue and type 42"
    # Keypress Ctrl+g
    ydotool key 29:1 34:1 29:0 34:0
    syncUp 1
    # Type "42"
    ydotool type "42"
    syncUp 1
    # Keypress Return/Enter
    ydotool key 28:1 28:0
    syncUp 2
    stopAction "$i"

    # TODO differs significantly from xdotool
    echo " Move mouse to center of window "
    startAction "$i" "Move mouse to center of window"
    # Get the active window geometry
    WIN_ID=$(kdotool getactivewindow)
    loc="$(kdotool getwindowgeometry "$WIN_ID")"
    # Extract only width and height (position is always 0,0 for maximized)
    width=$(echo "$loc" | sed -n 's/.*Geometry: \([0-9.]*\)x.*/\1/p')
    height=$(echo "$loc" | sed -n 's/.*Geometry: [0-9.]*x\([0-9.]*\).*/\1/p')
    # Calculate center
    center_x=$(echo "$width / 2" | bc)
    center_y=$(echo "$height / 2" | bc)
    # Reset mouse to top-left and move to center
    ydotool mousemove -x -9999 -y -9999
    ydotool mousemove -x "$center_x" -y "$center_y"
    syncUp 2
    stopAction "$i"

    # TODO SEE ABOVE
    # Select text using highlighter tool
    echo " Toggle highlighter tool and select text to highlight "
    startAction "$i" "Toggle highlighter tool and select text to highlight"
    # Keypress Alt+1
    ydotool key 56:1 2:1 56:0 2:0
    # Hold mouse button down, move directly downwards (180) for 75 pixels, unclick
    ydotool click 0x40
    ydotool mousemove -y 75 -x 0
    ydotool click 0x80
    syncUp 2
    stopAction "$i"

    # Move mouse directly downwards from middle point of
    # window (180) over highlighted text, double click to add note
    echo " Write annotation "
    startAction "$i" "Write annotation"
    # Move directly upwards (180) for 25 pixels and double click to open annotation.
    ydotool mousemove -x 0 -y -25
    ydotool click -r 2 0xC0
    # Type 'Again this is very interesting, should read more.'
    ydotool type 'Again this is very interesting, should read more.'
    syncUp 8
    stopAction "$i"

    # return to browsing mode
    echo " Toggle highlighter tool again to return to browsing mode "
    startAction "$i" "Toggle highlighter tool again to return to browsing mode"
    # Keypress Alt+1
    ydotool key 56:1 2:1 56:0 2:0
    syncUp 1
    stopAction "$i"

    # Start presentation mode and move up and down pages
    echo " Start presentation mode "
    startAction "$i" "Start presentation mode"
    # Toggle presentation
    # Keypress Ctrl+Shift+p
    ydotool key 29:1 42:1 25:1 29:0 42:0 25:0
    syncUp 2
    # Close default popup window
    # Keypress Return/Enter
    ydotool key 28:1 28:0
    syncUp 19
    stopAction "$i"

    # Exit presentation
    echo " Exit presentation mode "
    startAction "$i" "Exit presentation mode"
    # Keypress Escape
    ydotool key 1:1 1:0
    syncUp 1

    # Move mouse to center of Okular window, click mouse to exit annotation text box
    # Get the active window geometry
    WIN_ID=$(kdotool getactivewindow)
    loc="$(kdotool getwindowgeometry "$WIN_ID")"
    # Extract only width and height (position is always 0,0 for maximized)
    width=$(echo "$loc" | sed -n 's/.*Geometry: \([0-9.]*\)x.*/\1/p')
    height=$(echo "$loc" | sed -n 's/.*Geometry: [0-9.]*x\([0-9.]*\).*/\1/p')
    # Calculate center
    center_x=$(echo "$width / 2" | bc)
    center_y=$(echo "$height / 2" | bc)
    # Reset mouse to top-left and move to center
    ydotool mousemove -x -9999 -y -9999
    ydotool mousemove -x "$center_x" -y "$center_y"
    ydotool click 0xC0

    # NOTE change sync to 1
    syncUp 3
    stopAction "$i"

    # Rotate page right twice
    echo " Rotate page right twice "
    startAction "$i" "Rotate page right 1"
    # Keypress Ctrl+r
    ydotool key 29:1 19:1 29:0 19:0
    syncUp 2
    stopAction "$i"
    syncUp 4
    startAction "$i" "Rotate page right 2"
    # Keypress Ctrl+r
    ydotool key 29:1 19:1 29:0 19:0
    syncUp 2
    stopAction "$i"
    syncUp 4

    # Rotate page left twice
    echo " Rotate page left twice "
    startAction "$i" "Rotate page left 1"
    # Keypress Ctrl+l
    ydotool key 29:1 38:1 29:0 38:0
    syncUp 2
    stopAction "$i"
    syncUp 4
    echo " Rotate page left 2 "
    startAction "$i" "Rotate page left 2"
    # Keypress Ctrl+l
    ydotool key 29:1 38:1 29:0 38:0
    syncUp 2
    stopAction "$i"
    syncUp 4

    # Move around the pages
    echo " Move forward five pages "
    startAction "$i" "Move forward a page 1"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 2"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 3"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 4"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move forward a page 5"
    # Keypress Right
    ydotool key 106:1 106:0
    syncUp 2
    stopAction "$i"

    echo " Move backward five pages "
    startAction "$i" "Move backward a page 1"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 2"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 3"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 4"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"
    startAction "$i" "Move backward a page 5"
    # Keypress Left
    ydotool key 105:1 105:0
    syncUp 2
    stopAction "$i"

    # Zoom out
    echo " Zoom to 100 percent "
    startAction "$i" "Zoom to 100 percent"
    # Keypress Ctrl+0
    ydotool key 29:1 11:1 29:0 11:0
    syncUp 3
    stopAction "$i"

    echo " Zoom to 400 percent "
    # Zoom in
    startAction "$i" "Zoom in to 400 percent 1"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 2"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 3"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 4"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    startAction "$i" "Zoom in to 400 percent 5"
    # Keypress Ctrl+plus
    ydotool key 29:1 13:1 29:0 13:0
    syncUp 1
    stopAction "$i"
    syncUp 1

    # Fit to width
    echo " Fit to width "
    startAction "$i" "Fit to width"
    # Keypress Ctrl+Shift+w
    ydotool key 29:1 42:1 17:1 29:0 42:0 17:0
    syncUp 1
    stopAction "$i"

    # Invert colors back
    echo " Invert colors back "
    startAction "$i" "Invert colors back"
    # Keypress Ctrl+i
    ydotool key 29:1 23:1 29:0 23:0
    syncUp 2
    stopAction "$i"
    syncUp 2

    echo " Toggle annotation panel "
    startAction "$i" "Toggle annotation panel"
    # Toggle annotations panel
    # Keypress F6
    ydotool key 64:1 64:0
    syncUp 2
    stopAction "$i"

# REPEAT OVER

    ## wrap-up
    # save
    echo " Save PDF "
    startAction "$i" "Save PDF"
    # Keypress Ctrl+s
    ydotool key 29:1 31:1 29:0 31:0
    syncUp 1
    stopAction "$i"

    # quit okular
    echo " Quit Okular "
    startAction "$i" "Quit Okular"
    # Keypress Ctrl+q
    ydotool key 29:1 16:1 29:0 16:0
    syncUp 2
    stopAction "$i"

    # stop iteration
    echo " stop iteration "
    echo "iteration $i;$(date -I) $(date +%T);stopTestrun" >> ~/log_sus.csv

    syncUp 1

    ## clean up
    # remove logs
    rm ~/.var/app/org.kde.okular/config/okularrc
    rm ~/.var/app/org.kde.okular/config/okularpartrc
    rm -r ~/.var/app/org.kde.okular/cache/*
    # delete annotated PDF
    rm ~/Documents/20yearsofKDE.pdf

    # cool down
    syncUp 30

    clear

done

## rm configuration scripts and keyboard shortcuts

rm /tmp/configuration.sh
rm /tmp/part.rc
