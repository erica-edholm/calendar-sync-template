#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Script to replace variables in calendar-sync templates"
   echo
   echo "Syntax: replacement [-e|-t|-s]"
   echo "options:"
   echo "e     enter email used"
   echo "t     enter calendar id of target calendar (where you want to store new event)"
   echo "s     enter calendar id of source calendar (the calendar which events you want to trigger on)"
   echo
}

unset -v email
unset -v targetCalendarId
unset -v sourceCalendarId

while getopts ":h:e:t:s:" option; do
  case $option in
    h) # display Help
       Help
       exit;;
    e) # enter email
       email=$OPTARG;;
    t) # enter calendar id of target calendar
       targetCalendarId=$OPTARG;;
    s) # enter calendar id of source calendar
       sourceCalendarId=$OPTARG;;
   \?) # Invalid option
       echo "Error: Invalid option"
       exit;;
  esac
done

if [ -z "$email" ] || [ -z "$targetCalendarId" ] || [ -z "$sourceCalendarId" ]; then
        echo "e: $email"
        echo "t: $targetCalendarId"
        echo "s: $sourceCalendarId"
        echo 'Missing -e, -t or -s' >&2
        exit 1
fi

cp -r scheduled-calendar-sync-template scheduled-calendar-sync-$email
find scheduled-calendar-sync-$email -type f -exec sed -i "s/<email>/$email/g" {} \;
find scheduled-calendar-sync-$email -type f -exec sed -i "s/<target-calendar>/$targetCalendarId/g" {} \;
find scheduled-calendar-sync-$email -type f -exec sed -i "s/<source-calendar>/$sourceCalendarId/g" {} \;
cd scheduled-calendar-sync-$email
zip -r ../scheduled-calendar-sync-$email.zip .
cd ..
