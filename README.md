# simplex-repeater-bash
A simple simplex repeater for ham radio enthusiasts using bash and a slew of other programs tied together

-------------------------------------------
 GENERAL NOTES

-------------------------------------------
 Fairly major improvements added as of
 2020-02-24 though this is still very much
 a very crude and simple simplex repeater
 script written in bash. Requires sox,
 espeak, sed, tr, grep, morse (or cw), 
 and multimon-ng.

 This version allows for remote DTMF 
 controls. (2020/02/22)

 Now has automagic conversion of
 espeak spoken call sign into NATO
 Phonetics. (2020/02/23)

 Added several more variables to control
 settings for various parts. (2020/02/23)

 Made the terminal output a bit more bold
 so you can see what the parrot script
 is doing at a glance. (2020/02/24)
-------------------------------------------
 Save in its own directory as simplex.sh
 and run:

 ./simplex.sh
-------------------------------------------
 Use pavucontrol to select input and output
 or however is easiest/best for your
 working environment.

 Raspberry Pi will use alsa instead of 
 pulse. You'll have to configure things
 with alsamixer or similar.
-------------------------------------------
 Code by Phillip J Rhoades
-------------------------------------------

-------------------------------------------
 HARDWARE NOTES

-------------------------------------------
 I use an HT with an APRS cable and a
 mic/headphones splitter on one end
 to patch the radio into a Linux computer
 or a Raspberry Pi. The Pi will need a
 cheap USB sound card.
 
 You'll have to adjust input and output
 volumes on the computer and the output
 volume on the radio. I also set the 
 radio to use VOX in this setup.

 You could improve on this basic setup
 in a number of ways but that's outside
 the scope of this "simple" project.

 If you're reading this script in monospace
 then this rough ASCII diagram of the setup
 might help you get a clearer idea:

                    -->[PC Mic In]
 [HT]<-APRS->SPLIT-||
                    <--[PC Sound Card Out]

 In some cases, a ground loop noise
 isolator or two might help with buzzing
 sounds between the computer and the HT.
-------------------------------------------

-------------------------------------------
 VARIABLES TO CONTROL THINGS

-------------------------------------------
 Set SECONDS to greater than 600 to trigger
 repeater ID at startup.
-------------------------------------------
 Set DTMFCONTROLS to 1 in order to be able
 to control remotely via DTMF commands or
 set DTMFCONTROLS to 0 in order to disable
 that functionality.
-------------------------------------------
 Leave IDLOOPING set to 1 in most cases.
 Since identifying a station every 10
 minutes is legally required.

 You might want to turn off the ID Loop
 while testing on your sound card only.
 To do that, set IDLOOPING to 0.
-------------------------------------------
 Set CALLSIGN to your call sign.
-------------------------------------------
 Set CALLSIGN_SPEAK to 1 to have espeak
 say your call sign in NATO Phonetics
 during each 10 minute ID announcement.
-------------------------------------------
 Set CALLSIGN_MORSE to 1 to have morse
 (usually from the bsdgames package)
 or cw beep out your call sign during each 
 10 minute ID announcement.
-------------------------------------------
 Set MORSEPROG to whichever text to morse
 program you prefer to use. You can
 uncomment for EITHER morse from bsdgames
 or cw from the cw package.
-------------------------------------------
 Set MULTIMONPROG to either multimon or
 multimon-ng, depending on what you have
 installed or prefer. Both seem to work
 just fine for DTMF decoding.
 (2020/02/23)
-------------------------------------------
 Setting PARROT to 0 will disable the
 repeat of audio received by the script.
 Setting PARROT to 1 will enable the
 repeat of audio received by the script.

 This way a menu item in dtmfactions
 can be used to turn on and off just the
 audio repeat part of this script while
 keeping the DTMF processing in place.
 (2020/02/24)
-------------------------------------------
