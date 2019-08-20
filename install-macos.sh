#!/bin/bash
set -e

PKG_URL="https://vanta-agent.s3.amazonaws.com/latest/vanta.pkg"
PKG_PATH="/tmp/vanta.pkg"

if [ $(echo "$UID") = "0" ]; then
    SUDO=''
else
    SUDO='sudo -E'
fi

 if [ -z "$VANTA_KEY" ]; then
    printf "\033[31m
You must specify the VANTA_KEY environment variable in order to install the agent.
\n\033[0m\n"
    exit 1
fi

 function onerror() {
    printf "\033[31m$ERROR_MESSAGE
Something went wrong while installing the Vanta agent.

If you're having trouble installing, please send an email to support@vanta.com, and we'll help you fix it!
\n\033[0m\n"
    $SUDO launchctl unsetenv VANTA_KEY
    $SUDO launchctl unsetenv VANTA_OWNER_EMAIL
}
trap onerror ERR


 # Install the agent
printf "\033[34m\n* Downloading the Vanta Agent\n\033[0m"
rm -f $PKG_PATH
curl --progress-bar $PKG_URL > $PKG_PATH
printf "\033[34m\n* Installing the Vanta Agent. You might be asked for your password...\n\033[0m"
$SUDO launchctl setenv VANTA_KEY "$VANTA_KEY"
$SUDO launchctl setenv VANTA_OWNER_EMAIL "$VANTA_OWNER_EMAIL"
$SUDO /usr/sbin/installer -pkg $PKG_PATH -target / >/dev/null
$SUDO launchctl unsetenv VANTA_KEY
$SUDO launchctl unsetenv VANTA_OWNER_EMAIL

 # Check if the agent is running
$SUDO vanta-cli status

 # Agent works, echo some instructions and exit
printf "\033[32m
 Your Agent is running properly. It will continue to run in the
background and submit data to Vanta.
 You can check the agent status using the \"vanta-cli status\" command.
 If you ever want to stop the agent, please use the toolbar icon or
the launchctl command. It will restart automatically at login.
 To register this device to a new user, run \"vanta-cli register\" or click on \"Register Vanta Agent\"
on the toolber.
 \033[0m"