# How to port Synthdefs to SuperDirt / Tidalcycles

## Changing output args to Offset.Out 

Say you have this synthdef, in a .scd file :

<p><code>/*
henonN: using the non-interpolated Henon Ugen as a synth
	
Contains a LeakDC Ugen to stop any DC bias in the signal from disturbing the rest of the mix

Arguments for a, b, x0 and x1 are at their default values which gives a periodic signal, and only slight deviation will change the properties of the signal a LOT.

The non-interpolated version gives the most 'harsh' signal

it uses the equation x(n+2) = 1 - a * x(n+1)^2 + b * x(n)

freq = frequency

a = a

b = b

x0 = first value of x

x1 = second value of x

atk = attack

sus = sustain

rel = release

ts = timescale

out = channels out

pan = panning in stereo

amp = volume

*/

(

SynthDef(\henon,

{arg freq=440,a=1.3,b=0.3,x0=0.30501993062401,x1=0.20938865431933,atk=0.01,sus=1,rel=1,ts=1,out=0,pan=0,amp=0.3;

var sig,env;	

sig = HenonN.ar(freq,a,b,x0,x1,amp);

env = EnvGen.ar(Env.linen(atk,sus,rel),1,1,0,ts,2);

sig = LeakDC.ar(sig);

sig = sig*env;

Out.ar(out,Pan2.ar(sig,pan));

}).add; </code><p>


_(Synthdef stops here)_

Make sure `pan` is declared in the args pipe in the beginning, this is mandatory ! Default is `pan=0.0`. 

You'll have to comment and rewrite, or edit the `Out.ar(out, etc(arg,arg));` line to SuperDirt. 

The audio output will be parsed to OffsetOut as it seems to be the convention for SD.

We have to replace the out argument straight on the first arg, and put the var(s) in the right place and in the right order, which is DirtPan's args array. Here it will be:

` OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env)); `

## Importing args to TC

Prior to your pattern, and after the Synthdef is evaluated, you have to evaluate the synthdef's own args to change them to Tidalcycle control functions. 

Our synthdef has been kindly commented in the beginning, so we're lucky, otherwise we could read the arg pipe between brackets in the beginning. 

We won't touch any enveloppe setting, since there are native control fucntions about it in Tidalcycles. But we still have a few args to mess with.

Evaluate the following block in your `.tidal` file , we're about to grab our synthdef args and pass them as control funcs :


<p><code>let 
	
  a = pF "a"  
  
  b = pF "b"  
  
  x0 = pF "x0"  
  
  x1 = pF "x1"  
  
  ts = pF "ts"</code></p>
  
  Do Control + Enter (or whatever combination you're used to validate with). This syntax allows us to evaluate a stack at once.
  
  ## Testing
  
  Write a pattern with the synthdef we want to test, with some control functions with the variables we just validated:
  
  <p><code>do
	
   d1 $ 
   
      n (every 2 (0.25 ~>) $ "1 [2 [~ -4]] -7 [[~ -2] 6]") #      
      
      s "henon "      
      
      # cut "-1"      
      
      # a "1.3 1.5 0.3"      
      
      # b "0.5 0.3 0.4 0.3 0.2"      
      
      # ts "0.5 1 0.2 1 0.5"      
      
      # x0 "0.3 0.4 0.5 0.1"      
      
      # x1 "0.2 0.1 0.6 0.3 0.2" 
      </code></p>

Done. 

## More examples

- For this output `Out.ar(out, Pan2.ar(BPF.ar(BrownNoise.ar,SinOsc.kr(LFNoise2.kr(50,50,50),0,100,2000),0.001,10)* amp, pan));`, 

	- we change the output(`Out.ar`) to an offset output,

	- we change the pan declaration to its own arg at the very end, and since we use SuperDirt's panner, and all we have to do is take the args in between. 

	SuperDirt : `OffsetOut.ar(out, DirtPan.ar( BPF.ar(BrownNoise.ar,SinOsc.kr(LFNoise2.kr(50,50,50),0,100,2000),0.001,10)* amp , ~dirt.numChannels, pan));`

- For this output `Out.ar(out, Pan2.ar(snare * amp * 10, pan));` ,

	SuperDirt : `OffsetOut.ar(out, DirtPan.ar(snare * amp * 10, ~dirt.numChannels, pan));`

- For this output `OffsetOut.ar( 0, [ signalOut * kenv2, signalOut * kenv2 ] );` ,

	SuperDirt : `OffsetOut.ar(0, DirtPan.ar( [ signalOut * kenv2, signalOut * kenv2 ] , ~dirt.numChannels, pan));`

Feel free to help yourself in this repo !
