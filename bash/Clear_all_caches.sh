#!/bin/bash

USER=`stat -f%Su /dev/console` 

#System Caches
sudo mv /private/var/log/privoxy /private/var/privoxy > /dev/null 2>&1
sudo /bin/rm -rf /private/var/log/* > /dev/null 2>&1
sudo mv /private/var/privoxy /private/var/log/privoxy > /dev/null 2>&1

#System Caches
sudo /bin/rm -rf /Users/$USER/Library/Logs/* > /dev/null 2>&1 & sudo /bin/rm -rf /Library/Logs/DiagnosticReports/*.* > /dev/null 2>&1 & sudo /bin/rm -rf /private/var/tmp/com.apple.messages > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Caches/* > /dev/null 2>&1 & sudo /bin/rm -rf /private/var/db/diagnostics/*/* > /dev/null 2>&1 & sudo /bin/rm -rf /Library/Logs/DiagnosticReports/ProxiedDevice-Bridge/*.ips > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/CrashReporter/* > /dev/null 2>&1 & sudo /bin/rm -rf /private/tmp/gzexe* > /dev/null 2>&1

#Safari Caches
sudo /bin/rm -rf /Users/$USER/Library/Containers/com.apple.Safari/Data/Library/Caches/* > /dev/null 2>&1 & sudo /bin/rm -rf /private/var/folders/ry/*/*/com.apple.Safari/com.apple.Safari/com.apple.metal/*/libraries.data > /dev/null 2>&1 & sudo /bin/rm -rf /private/var/folders/ry/*/*/com.apple.Safari/com.apple.Safari/com.apple.metal/*/libraries.maps > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Containers/io.te0.WebView/Data/Library/Caches/WebKit > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Safari/History.db* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Safari/RecentlyClosedTabs.plist > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Safari/CloudHistoryRemoteConfiguration.plist > /dev/null 2>&1

#Chrome Caches
ChromePath="/Applications/Google Chrome.app"
if [[ -d $ChromePath ]]; then
sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/GPUCache/* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Storage/ext/*/def/GPUCache/* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/*-journal > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/databases/*-journal > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Visited\ Links > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Top\ Sites > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/History\ Provider\ Cache > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Current\ Tabs > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Network\ Action\ Predictor > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/*.ldb > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/*.log > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Extension\ State/* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Session\ Storage/* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Current\ Session > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/Storage/ext/* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/Library/Application\ Support/Google/Chrome/*/*/Cache > /dev/null 2>&1
fi

#Clean Download History
sudo sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent' > /dev/null 2>&1

#Clean Terminal History
sudo /bin/rm -rf /Users/$USER/.bash_sessions/* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/.bash_history > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/.zsh_sessions/* > /dev/null 2>&1 & sudo /bin/rm -rf /Users/$USER/.zsh_history > /dev/null 2>&1

#Applications Caches
for x in $(ls ~/Library/Containers/) 
do 
    echo "Cleaning ~/Library/Containers/$x/Data/Library/Caches/"
    rm -rf ~/Library/Containers/$x/Data/Library/Caches/*
done

echo 'Empty the Trash on all mounted volumes and the main HDD…'
sudo rm -rfv /Volumes/*/.Trashes &>/dev/null
sudo rm -rfv ~/.Trash &>/dev/null

echo 'Clear System Log Files…'
sudo rm -rfv /private/var/log/asl/*.asl &>/dev/null
sudo rm -rfv /Library/Logs/DiagnosticReports/* &>/dev/null
sudo rm -rfv /Library/Logs/Adobe/* &>/dev/null
rm -rfv ~/Library/Containers/com.apple.mail/Data/Library/Logs/Mail/* &>/dev/null
rm -rfv ~/Library/Logs/CoreSimulator/* &>/dev/null

echo 'Clear Adobe Cache Files…'
sudo rm -rfv ~/Library/Application\ Support/Adobe/Common/Media\ Cache\ Files/* &>/dev/null

echo 'Cleanup iOS Applications…'
rm -rfv ~/Music/iTunes/iTunes\ Media/Mobile\ Applications/* &>/dev/null

echo 'Remove iOS Device Backups…'
rm -rfv ~/Library/Application\ Support/MobileSync/Backup/* &>/dev/null

echo 'Cleanup XCode Derived Data and Archives…'
rm -rfv ~/Library/Developer/Xcode/DerivedData/* &>/dev/null
rm -rfv ~/Library/Developer/Xcode/Archives/* &>/dev/null

echo 'Cleanup Homebrew Cache…'
brew cleanup --force -s &>/dev/null
brew cask cleanup &>/dev/null
rm -rfv /Library/Caches/Homebrew/* &>/dev/null
brew tap --repair &>/dev/null

echo 'Cleanup any old versions of gems…'
gem cleanup &>/dev/null

echo 'Running the maintenance scripts…'
sudo periodic daily weekly monthly

echo 'Purge inactive memory…'
sudo purge

clear && echo 'Yeah, everything is cleaned up! :)'
echo done
