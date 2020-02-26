#!/bin/bash

#-------------------------------------------
# GENERAL NOTES
#
#-------------------------------------------
# Fairly major improvements added as of
# 2020-02-24 though this is still very much
# a very crude and simple simplex repeater
# script written in bash. Requires sox,
# espeak, sed, tr, grep, morse (or cw), 
# and multimon-ng.
#
# This version allows for remote DTMF 
# controls. (2020/02/22)
#
# Now has automagic conversion of
# espeak spoken call sign into NATO
# Phonetics. (2020/02/23)
#
# Added several more variables to control
# settings for various parts. (2020/02/23)
#
# Made the terminal output a bit more bold
# so you can see what the parrot script
# is doing at a glance. (2020/02/24)
#-------------------------------------------
# Save in its own directory as simplex.sh
# and run:
#
# ./simplex.sh
#-------------------------------------------
# Use pavucontrol to select input and output
# or however is easiest/best for your
# working environment.
#
# Raspberry Pi will use alsa instead of 
# pulse. You'll have to configure things
# with alsamixer or similar.
#-------------------------------------------
# Code by Phillip J Rhoades
#-------------------------------------------

#-------------------------------------------
# HARDWARE NOTES
#
#-------------------------------------------
# I use an HT with an APRS cable and a
# mic/headphones splitter on one end
# to patch the radio into a Linux computer
# or a Raspberry Pi. The Pi will need a
# cheap USB soundcard. A USB soundcard
# could also help with ground issues
# (buzzing) on computers/laptops.
# 
# You'll have to adjust input and output
# volumes on the computer and the output
# volume on the radio. I also set the 
# radio to use VOX in this setup.
#
# You could improve on this basic setup
# in a number of ways but that's outside
# the scope of this "simple" project.
#
# If you're reading this script in monospace
# then this rough ASCII diagram of the setup
# might help you get a clearer idea:
#
#                    -->[PC Mic In]
# [HT]<-APRS->SPLIT-||
#                    <--[PC Sound Card Out]
#
# In some cases, a ground loop noise
# isolator or two might help with buzzing
# sounds between the computer and the HT.
#-------------------------------------------

#-------------------------------------------
# VARIABLES TO CONTROL THINGS
#
#-------------------------------------------
# Set SECONDS to greater than 600 to trigger
# repeater ID at startup.
#-------------------------------------------
# Set DTMFCONTROLS to 1 in order to be able
# to control remotely via DTMF commands or
# set DTMFCONTROLS to 0 in order to disable
# that functionality.
#-------------------------------------------
# Leave IDLOOPING set to 1 in most cases.
# Since identifying a station every 10
# minutes is legally required.
#
# You might want to turn off the ID Loop
# while testing on your sound card only.
# To do that, set IDLOOPING to 0.
#-------------------------------------------
# Set CALLSIGN to your call sign.
#-------------------------------------------
# Set CALLSIGN_SPEAK to 1 to have espeak
# say your call sign in NATO Phonetics
# during each 10 minute ID announcement.
#-------------------------------------------
# Set CALLSIGN_MORSE to 1 to have morse
# (usually from the bsdgames package)
# or cw beep out your call sign during each 
# 10 minute ID announcement.
#-------------------------------------------
# Set MORSEPROG to whichever text to morse
# program you prefer to use. You can
# uncomment for EITHER morse from bsdgames
# or cw from the cw package.
#-------------------------------------------
# Set MULTIMONPROG to either multimon or
# multimon-ng, depending on what you have
# installed or prefer. Both seem to work
# just fine for DTMF decoding.
# (2020/02/23)
#-------------------------------------------
# Setting PARROT to 0 will disable the
# repeat of audio received by the script.
# Setting PARROT to 1 will enable the
# repeat of audio received by the script.
#
# This way, a menu item in dtmfactions
# can be used to turn on and off just the
# audio repeat part of this script while
# keeping the DTMF processing in place.
# (2020/02/24)
#-------------------------------------------
# Some radios and radio/computer combos
# seem to have a slow vox. In those cases
# activating a sound just loud enough to
# trip the vox on can help the radio be
# ready to transmit the first second of
# the recorded audio.
#
# Set PREVOX to 1 in order to activate this
# feature or set PREVOX to 0 in order to
# deactivate it. (2020/02/25)
#-------------------------------------------

SECONDS=1000
DTMFCONTROLS=1
PARROT=1
PREVOX=0

CALLSIGN="KE8GGD"
IDLOOPING=1
CALLSIGN_SPEAK=0
CALLSIGN_MORSE=1

#MORSEPROG="cw"
MORSEPROG="morse"

MULTIMONPROG="multimon-ng"
#MULTIMONPROG="multimon"

#-------------------------------------------
# MORE "ELEGANT" EXITING
# (but still pretty much a hammer)
#
# Trap ctrl-c and call ctrl_c()
# to exit somewhat gracefully...
#-------------------------------------------

trap ctrl_c INT

function ctrl_c() {
          voxy
          if test -f "./recording.wav"; then
               rm recording.wav
          fi
          echo
          echo "#-------------------------------"
          echo "# Terminating the simplex Parrot"
          echo "#-------------------------------"
          espeak "Terminating the simplex parrot"

          #-------------------------------------------
          # Kill the parrot and its parent process
          # since exiting any other way via DTMF 
          # commands seems to leave the script
          # running in the background right now.
          # Will try for more elegance later.
          # (2020/02/23)
          # 
          # Could issue shutdown -h instead in order
          # to shut down Linux/Pi computer completely.
          #-------------------------------------------

          kill -9 $PPID
          #shutdown -h now
}

#-------------------------------------------
# VOX ACTIVATOR
#
# See notes in the settings area about
# the PREVOX variable which turns this
# on and off.
#
# Adjust this sound to something that
# is not annoying/bothersome/crude.
#
# Sine sounds a tone and "brownnoise" has
# the "benefit" of sounding like radio
# static... So... A bit more natural?
#
# Less lossy. More bossy. (2020/02/25)
#
#-------------------------------------------

voxy () {
     if [ $PREVOX -eq 1 ]; then
          play -n -c1 synth .2 sine 50
          #play -n -c1 synth .2 brownnoise
     fi
}

#-------------------------------------------
# NATO PHONETICS
#
#-------------------------------------------
# Pipe output into this function and it will
# return the string as NATO Phonetics, at
# least for letters and numbers.
#-------------------------------------------
# Used for espeak to speak CALLSIGN
# in NATO Phonetics
#-------------------------------------------

natophonetics () {
    echo $* | sed -e 's/\(.\)/\1\n/g' | natophonetics_sub
}

natophonetics_sub () {
    while read data; do
        case "$data" in
            A)  echo -n "Alpha " ;;
            B)  echo -n "Bravo " ;;
            C)  echo -n "Charlie " ;;
            D)  echo -n "Delta " ;;
            E)  echo -n "Echo " ;;
            F)  echo -n "Foxtrot " ;;
            G)  echo -n "Golf " ;;
            H)  echo -n "Hotel " ;;
            I)  echo -n "India " ;;
            J)  echo -n "Juliet " ;;
            K)  echo -n "Kilo " ;;
            L)  echo -n "Lima " ;;
            M)  echo -n "Mike " ;;
            N)  echo -n "November " ;;
            O)  echo -n "Oscar " ;;
            P)  echo -n "Papa " ;;
            Q)  echo -n "Quebec " ;;
            R)  echo -n "Romeo " ;;
            S)  echo -n "Sierra " ;;
            T)  echo -n "Tango " ;;
            U)  echo -n "Uniform " ;;
            V)  echo -n "Victor " ;;
            W)  echo -n "Whiskey " ;;
            X)  echo -n "X-ray " ;;
            Y)  echo -n "Yankee " ;;
            Z)  echo -n "Zulu " ;;
            0)  echo -n "Zero " ;;
            1)  echo -n "One " ;;
            2)  echo -n "Two " ;;
            3)  echo -n "Three " ;;
            4)  echo -n "Four " ;;
            5)  echo -n "Five " ;;
            6)  echo -n "Six " ;;
            7)  echo -n "Seven " ;;
            8)  echo -n "Eight " ;;
            9)  echo -n "Nine " ;;
            " ")  echo -n ". " ;;
        esac
    done
}

#-------------------------------------------
# DTMF CONTROLS (using multimon-ng)
#
#-------------------------------------------
# scandtmf runs after every recording to 
# check for dtmf codes and passes those to
# dtmfactions to be processed.
#-------------------------------------------
# Complex DTMF Actions could have their own
# functions to call.
#-------------------------------------------

scandtmf () {
     dtmfactions $($MULTIMONPROG -q -t wav -a DTMF ./recording.wav 2>/dev/null |grep "DTMF" |grep -v "Enabled" |sed 's/^.\{6\}//'|tr -d '\n')
}

dtmfactions () {
     if [ $# -eq 1 ]; then
          rm recording.wav
          voxy
          echo
          echo "#-------------------------------"
          echo "# Received DTMF Command: $1"
          echo "#-------------------------------"
          espeak "Received D T M F Command: $(echo $1| sed -e 's/\(.\)/\1 /g')"
          if [ $1 = "#73" ]; then
               ctrl_c 
               exit
          fi
          if [ $1 = "#99" ]; then
               if [ $PARROT -eq 1 ]; then
                    espeak "Parrot will now be silent."
                    PARROT=0
               else
                    espeak "Parrot will now repeat traffic."
                    PARROT=1
               fi 
               return
          fi
          if [ $1 = "#1" ]; then
               espeak "`date +"%A %I %M %p"`"
               return
          fi
          if [ $1 = "#0" ]; then
               espeak "The DTMF commands are"
               espeak "#0 for help"
               espeak "#1 for date and time"
               espeak "#73 to terminate the simplex parrot"
               espeak "#99 to toggle the audio parrot"
               return
          fi
          espeak "No such code. Send D T M F Code #0 for help."
     fi
}

#-------------------------------------------
# REPEATER ID LOOP
#
#-------------------------------------------
# Loop in background to identify repeater
# no matter what else is going on.
#-------------------------------------------

while [ $IDLOOPING -eq 1 ]; do
     if [ $SECONDS -gt 600 ]; then
          #-------------------------------------------
          # By checking the value of SECONDS we can
          # identify the repeater every 10 minutes
          # (600 seconds).
          #-------------------------------------------
          #-------------------------------------------
          # Identify repeater using espeak, morse,
          # or both (or cw instead of morse).
          #-------------------------------------------
          if [ $CALLSIGN_SPEAK -eq 1 ] || [ $CALLSIGN_MORSE -eq 1 ]; then
               voxy
          fi
          if [ $CALLSIGN_SPEAK -eq 1 ]; then
               espeak "This is simplex repeater $(natophonetics $CALLSIGN) / R" &
          fi
          if [ $CALLSIGN_MORSE -eq 1 ]; then
               echo "$CALLSIGN/R" |$MORSEPROG &
          fi
          #-------------------------------------------
          # Always reset SECONDS to 0 here
          # so we can begin watching for 600 seconds
          # again and ID every 10-ish minutes.
          #-------------------------------------------
          SECONDS=0
     fi
     sleep 30 # If we loop this less often, it's easier on the CPU
done &


#-------------------------------------------
# REPEATER PARROT LOOP
#
#-------------------------------------------
# Loop until ctrl-c on keyboard or the
# DTMF command to terminate the repeater
#-------------------------------------------

while [ 1 ]; do
          echo
          echo "#-------------------------------"
          echo "# WAITING FOR AUDIO INPUT:"
          echo "#-------------------------------"
          rec -V1 -c1 recording.wav rate 64k silence 1 0.1 1% 1 3.0 1% trim 0 30
          if [ $DTMFCONTROLS -eq 1 ]; then
               scandtmf
          fi
          if [ $PARROT -eq 1 ]; then
               if test -f "./recording.wav"; then
                    sleep 1 # wait a second so vox can be ready
                    voxy
                    echo
                    echo "#-------------------------------"
                    echo "# PLAYING BACK CAPTURED AUDIO:"
                    echo "#-------------------------------"
                    play -V1 recording.wav #play back what was said, activating vox
                    rm recording.wav #cleanup before restarting loop
               fi
          fi
done
