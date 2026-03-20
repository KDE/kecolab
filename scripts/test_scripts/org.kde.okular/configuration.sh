#! /usr/bin/env bash

## Setting custom shortcuts
echo "Importing shortcuts"
sleep 1
rm ~/.var/app/org.kde.okular/data/kxmlgui5/okular/part.rc
sleep 1
mkdir -p ~/.var/app/org.kde.okular/data/kxmlgui5/okular/
cp part.rc ~/.var/app/org.kde.okular/data/kxmlgui5/okular/part.rc
sleep 1
echo "Finished importing shortcuts"
