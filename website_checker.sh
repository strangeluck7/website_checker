#!/bin/bash

# Env variables
slack_webhook="<ENTER SLACK TOKEN>"
website="<ENTER WEBSITE ADDRESS>"

function website_update_check() {

    address="$1"
    name=$(echo "$address" | awk -F'[/:]' '{gsub(/www./,""); print $4}')

    if [ -f "/var/tmp/$name-check1.txt" ]; then
        echo "Previous Check File Exists - Curling Website again to compare"
        /usr/bin/curl --insecure "$address" | sed '/Email Us/d' > /var/tmp/"$name"-check2.txt

        echo "Comparing Website Since Last Checked"
        different_strokes=$(/usr/bin/diff /var/tmp/"$name"-check1.txt /var/tmp/"$name"-check2.txt)

        if [ "$different_strokes" != "" ]; then
            slackNotifier "$name"
        fi

        # Cleanup
        rm /var/tmp/"$name"-check1.txt
        rm /var/tmp/"$name"-check2.txt

        # Last thing script should do is create new text file to compare for next run
        /usr/bin/curl --insecure "$1" | sed '/Email Us/d' > /var/tmp/"$name"-check1.txt
    else
        # If pacFileRound1 doesn't exist create it
        /usr/bin/curl --insecure "$1" | sed '/Email Us/d' > /var/tmp/"$name"-check1.txt
    fi


}

function slackNotifier() {
    echo "Website changes have occured!"
	curl -X POST --data-urlencode "payload={\"attachments\": [{\"color\": \"#FFFF00\", \"title\": \"Website Checker\", \"title_link\": \"$1\", \"text\": \"A website change has occured: $address\"}], \"channel\": \"#<ENTER CHANNEL>\", \"username\": \"Website Checker\", \"icon_emoji\": \":globe_with_meridians:\"}" "$slack_webhook"
}

website_update_check "$website"
