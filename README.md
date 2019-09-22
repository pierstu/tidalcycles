Here's what to expect from that messy repo:

# .tidal files
tidalcyles patterns for 2Mo &amp; other projects

# startup.scd
The startup conf I use

# synthdefs
Some synthdefs I came across. Here's the list of args. Any `arg=value` is a default value for this arg.

# `bgold-tidal5.scd` = bgold synthdefs
are synthdefs that were already written for SuperDirt, i'm just mirroring them.

## superclassic
- sustain
- pan
- accelerate
- freq
- voice

## superharm
- sustain
- pan
- accelerate
- freq
- voice
- lfo=0.5
- decay
- pitch1=1
- pitch2=1

## supermod
- sustain
- pan
- accelerate
- freq
- voice
- lfo=0.5
- decay
- detune
- pitch2=1.5

## synthdev
- sustain
- pan
- freq

## synthdev2
- out
- sustain
- pan
- freq

## synthdev3
- sustain
- pan
- freq

## synthdev4
- sustain
- pan
- freq

## supertrip
- pan
- freq
- sustain
- accelerate

## supernonlin
- pan
- freq
- sustain
- voice
- accelerate

## superdeep
- pan
- freq
- sustain
- voice
- accelerate

## superdeep2
- pan
- freq
- sustain
- accelerate

## superbass
- pan
- freq
- sustain
- detune
- accelerate

## superbell
- pan
- freq
- sustain
- accelerate

## superwide
- pan
- freq
- sustain
- accelerate

## superblip2
- pan
- freq
- sustain

## superrand
- pan
- freq
- sustain

## supercombo
- pan
- freq
- sustain
- voice

## supersync2
- pan
- freq
- sustain

## supersync3
- pan
- freq
- sustain

## superscratch
- pan
- freq
- sustain
- accelerate
- detune=0

## superx2
- pan
- freq
- sustain
- accelerate,detune=0
- voice=0

## superx3
- pan
- freq
- sustain
- accelerate
- voice=0
- pitch1
- pitch2=4
- lfo=0

## superx4
- pan
- freq
- sustain
- accelerate
- voice=0
- pitch1
- pitch2=4
- lfo=0  

## superds
- pan
- freq 
- sustain
- accelerate
- detune
- voice

## super1
- pan
- freq
- sustain
- voice=0

## super2
- pan
- freq
- sustain
- speed

## super3
- pan
- freq
- sustain
- speed

## super4
- pan
- freq
- sustain
- voice
- pitch1

## super5
- pan
- freq
- sustain
- speed
- detune
- accelerate
- voice
- pitch1
- slidedelay

## superd
- pan
- freq
- sustain

## dronec
- n=0
- gain=1
- pan=0.5
- speed
- sustain

## drone
- pan
- freq
- sustain

## superf
- pan
- freq
- sustain

## superfff
- pan
- freq
- sustain

## superpsaw
- pan
- freq
- sustain
- detune=0
- voice=0

## supersync
- pan
- freq
- sustain

## superdrop
- sustain=1
- pan
- freq
- accelerate=0
- pitch1=4
- voice=0
- lfo=0

## superdub5
- sustain=1
- pan
- freq
- accelerate=0
- pitch1=4
- voice=0
- lfo=0

## superdub6
- sustain=1
- pan
- freq
- accelerate=0
- pitch1=4
- voice=0
- lfo=0
- detune=0.008

## superacid
- speed=1
- sustain=1
- decay=0
- pan
- freq
- accelerate=0
- voice=0.0
- slide=0
- pitch1=500
- pitch2=1500

## superwobble
- sustain=1
- pan
- speed=1
- accelerate
- freq
- decay=0
- pitch1=4000
- lfo=0.5
- pitch2=4
- slide=0

## superpulse
- sustain=1
- pan
- speed=1
- accelerate
- freq
- decay=0
- slide=1

## superzzz
- sustain=1
- pan
- freq
- detune=1

## supervoice
- sustain=1
- pan
- freq
- pitch1=240
- pitch2=2400

## superbuf
- sustain=1
- pan
- freq

## supercross
- speed=1
- sustain=1
- decay=0
- pan
- freq
- accelerate=0
- voice=0.0
- detune=0.0

## superlagcomp
- speed=1
- sustain=1
- decay=0
- pan
- freq
- accelerate=0
- voice=0.2

## superphase
- speed=1
- sustain=1
- decay=0
- pan
- freq
- accelerate=0
- voice=0

## superblip
- sustain=1
- pan
- freq

# `coopt-synthdefs.scd` = coopt synthdefs
taken from [https://github.com/theseanco/howto_co34pt_liveCode](https://github.com/theseanco/howto_co34pt_liveCode), ported to SD
## henon
- freq = frequency
- a = a
- b = b
- x0 = first value of x
- x1 = second value of x
- atk = attack
- sus = sustain
- rel = release
- ts = timescale
- out = channels out
- pan = panning in stereo
- amp = volume

## henonc
- freq = frequency
- a = a
- b = b
- x0 = first value of x
- x1 = second value of x
- atk = attack
- sus = sustain
- rel = release
- ts = timescale
- out = channels out
- pan = panning in stereo
- amp = volume

## sinfb
- freq = frequency
- atk = attack
- sus = sustain
- rel = release
- fb = feedback (generally useful values are from 0-2, with 0 being pure sine waves and 2-20 being noise. More info on this in 'Between Pitch and Noise' section of guides)
- amp = volume
- out = channels out
- pan = panning in stereo

## ring1, ring2, ring3, ring4
- f = frequency (the reason this isn't freq is because it doesn't seem to work)
- a = amplitude of Ringz (before the final multiplier so that a heavily distorted signal can be later scaled by amp)
- d = duration of envelope on Ringz
- pan = Pan in stereo
- amp = overall volume
- out = channels out

# `synthdefs_extra.scd` = everythingwillbetakenaway synthdef pool
taken form [https://github.com/everythingwillbetakenaway/Synthdefs](https://github.com/everythingwillbetakenaway/Synthdefs), ported to SD

## plastickystrings
- freq = 440
- amp = 0.1
- gate=1
- lforate = 5900
- lfowidth= 0.01 cutoff= 12000
- rq=0.5
- pan=0.0

## plucking
- amp = 0.1
- freq = 440
- decay = 5
- coef = 0.1
- pan=0.0

## pitchednoise
- freq=440
- amp=0.1
- attack=0.01
- sustain=0.1
- decay=0.01
- pan=0.0
- bandwidth=100

## werkit
- freq = 440
- amp = 0.1
- gate = 1
- cutoff = 100
- rq = 0.1
- att = 0.01
- dec = 0
- sus = 1
- rel = 0.1
- pan=0.0

## trianglewavebells
- pan = 0.0
- freq = 440
- amp = 1.0
- gate = 1
- att = 0.01
- dec = 0.1
- sus = 1
- rel = 0.5
- lforate = 10
- lfowidth = 0.0
- cutoff = 100
- rq = 0.5

## voicform
-  gate=1
- freq=440
- amp=0.25
- voiceGain=0.25
- noiseGain=0.2
- sweepRate=0.01
- pan = 0.0

## synchronicity
- freq = 440
- amp = 0.1
- gate=1
- cutoff=8000
- rq=0.2
- pan=0.0

## spook
- freq = 440
- amp = 0.1
- gate=1
- cutoff=8000
- rq=0.2
- lfowidth=0.01
- lforate=3.8
- pan=0.0

## spook2
- freq = 440
- amp = 0.1
- gate=1
- cutoff=8000
- rq=0.2
- pan=0.0

## sos_bell
- freq=440
- amp=0.1
- pan=0

## apad  
- freq=880
- amp=0.5
- attack=0.4
- decay=0.5
- sustain=0.8
- release=1.0
- gate=1.0
- pan=0.0

## babbl
- amp=0.1
- pan=0.0

## bd
- pan=0.0

## beating
- freq = 440
- amp = 0.1
- art = 1
- pan = 0.0

## blips1  
- freq = 25
- numharm = 10
- att = 0.01
- rel = 1
- amp = 0.1
- pan = 0.5

## blowbotl  
- amp=1.0
- freq= 20
- rq=0.1
- gate=1
- noise=0.1
- vibFreq=5.2
- vibGain=0.9
- pan=0.0

## clap_oto309
- out=0
- amp = 0.1
- pan=0
## cymbal808_ryan
- baseFreq = 300
- time = 250
- amp=0.1
- pan=0.0

## cymbalic_mcld
- pan=0.0
- amp=0.1

## drum_kick
- freq=440
- gate=1
- amp=0.5
- source
- pan = 0.0

## waveguideFlute
- scl = 0.2
- freq = 440
- ipress = 0.9
- ibreath = 0.09
- ifeedbk1 = 0.4
- ifeedbk2 = 0.4
- dur = 1
- gate = 1
- amp = 2
- pan=0.0

## forest_bird_pj
- amp=0.1
- pan=0

## goeysynth
- freq=440
- amp=0.1
- sustain=0.1
- pan=0.0

## goeyfx
- a
- c
- z
- y
- in
- pan=0.0

## handclapsmash
- amp = 0.1
- gate=1
- cutoff= 12000
- rq=0.5
- releaseTime=0.5
- pan=0.0

## handclapsmash2
- amp = 0.1
- gate=1
- cutoff= 12000
- cutoff2=10000
- rq=0.5
- modamount=0.0
- modrate=50
- releaseTime=0.7
- pan=0.0

## harpsichord1  
- freq = 440
- amp = 0.1
- pan = 0.0

## hihat
- amp = 0.5
- att = 0.01
- rel = 0.2
- ffreq = 6000
- pan = 0

## snare
- amp = 0.1
- sinfreq = 180
- att = 0.01
- rel = 0.2
- ffreq = 2000
- pan = 0

## kick
- amp = 0.3
- sinfreq = 70
- glissf = 0.9
- att = 0.01
- rel = 0.45
- pan = 0

## impulsetrain1
- freq=440
- amp=0.1
- attack=0.01
- sustain=0.1
- decay=0.01
- pan=0.0
- bandwidth=100

## jilet
- gate=1
- freq=4
- amp=0.5
- endReflection=1.5
- jetReflection=0.5
- jetRatio=10.72
- noiseGain=0.35
- vibFreq=5.925
- vibGain=0.02
- outputGain=0.20
- pan=0.0

## justwannahavefun
- freq = 440
- amp = 0.1
- ringTime=10.0 pan=(-0.1)

## kick_oto309
- amp=0.5
- pan=0

## laserbeam
- pan = 0.0
- freq = 440
- amp = 0.1
- att = 0.01

## mrostinato
- freq = 440
- amp = 0.1
- gate=1
- lforate = 10
- lfowidth= 0.5
- pan = 0.0

## noisy
- freq = 440
- amp = 0.2
- pan = 0.5

## oneclap_thor  
- t_trig=1
- amp=0.1
- filterfreq=1000
- rq=0.1
- pan=0

## organdonor -
-  pan = 0.0
- freq = 440
- amp = 0.1
- gate = 1
- att = 0.01
- dec = 0.5
- sus = 1
- rel = 0.5
- lforate = 10
- lfowidth = 0.01
- cutoff = 100
- rq = 0.5;

## ping_mh
- freq=440
- amp=0.2
- dur=0.1
- attack=0.001
- pan=0
- out=0

## sillyVoice
-	freq = 220 -
-	amp = 0.5 -
-	vibratoSpeed = 6 -
-	vibratoDepth = 4 -
-	vowel = 0 -
-	att = 0.01 -
-	rel = 0.1 -
-	lag = 1 -
-	pan = 0.0 -
-	gate = 1;

## situationsynth
- freq = 440
- amp = 0.1
- gate=1
- cutoff=8000
- rq=0.8
- lfowidth=0.001
- lforate= 3.3
- pan=(-0.1)

## yazoodelayeffect
- out =0
- gate= 1
- pan= 0.1

## snare_oto309
- amp=0.1
- pan=0
