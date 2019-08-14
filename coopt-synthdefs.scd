/*
// taken from Coopt
// https://github.com/theseanco/howto_co34pt_liveCode
//
*/

/*

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
		// Out.ar(out,Pan2.ar(sig,pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

/*

henonC: using the cubic-interpolated Henon Ugen as a synth
Contains a LeakDC Ugen to stop any DC bias in the signal from disturbing the rest of the mix
Arguments for a, b, x0 and x1 are at their default values which gives a periodic signal, and only slight deviation will change the properties of the signal a LOT.
The cubic-interpolated version gives the most 'soft' signal

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

SynthDef(\henonc,
	{arg freq=440,a=1.3,b=0.3,x0=0.30501993062401,x1=0.20938865431933,atk=0.01,sus=1,rel=1,ts=1,out=0,pan=0,amp=0.3;
		var sig,env;
		sig = HenonC.ar(freq,a,b,x0,x1,amp);
		sig = LeakDC.ar(sig);
		// Out.ar(out,Pan2.ar(sig,pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*

warp1: a SynthDef to leverate Warp1 (my favourite granular buffer player) within patterns
I don't use this that much, as Warp1 is much better suited going straight into ProxySpace and modulated by Ugens, but it's in here in case it is useful within a Pmono
The arguments are quite convoluted, and they can be much better understood by looking at Warp1's helpfile

buf = buffer number
channels = number of channels of the buffer
rate = rate of playback of grains
size = window size of grains
env = envelope number of grains
olap = overlap of grains
rand = random playback window of grains
interp = interpolation (4 = cubic)
poslag = lag in the position for use within a Pmono (in seconds)
ratelag = lag in the rate for use within a Pmono (in seconds)
out = channels out
sizelag = lag in the window size for use within a Pmono (in seconds)
pan = pan within a stereo field
amp = volume

*/

SynthDef(\warp1,
	{arg buf=0, channels=2, pos=0, rate=1, size=0.2, env= -1, olap=8, rand=0, interp=4, poslag=0, ratelag=0, out=0, sizelag=0, pan=0, amp=0.5;
		var sig;
		sig = Warp1.ar(2,buf,Lag.kr(pos,poslag),Lag.kr(rate,ratelag),Lag.kr(size,sizelag),env,olap,rand,interp,1);
		// Out.ar(out,Pan2.ar(sig,pan,amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;


/*

bpfbuf: a synth created by Eli Fieldsteel as part of his SuperCollider tutorials series
Plays looped buffers through a band pass filter, and in the tutorial is used to create pitched 'clouds' of percussion
I don't use this one much, but it can be very useful.

atk = attack
sus = sustain
rel = release
c1 = start of the envelope curve
c2 = end of the envelope curve
buf = buffer index
rate = rate of buffer played
pos = start position
freq = frequency of buffer player
rq = Q of Band Pass Filter
bpfmix = amount of band pass filter included in signal
pan = pan in the stereo field
amp = volume
out = channels out

*/

SynthDef(\bpfbuf, {
	arg atk=0, sus=0, rel=3, c1=1, c2=(-1),
	buf=0, rate=1, pos=0, freq=440, rq = 1,
	bpfmix=0, pan=0, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
	sig = PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), startPos:pos);
	sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
	sig = sig * env;
	sig = Pan2.ar(sig,pan,amp);
	// Out.ar(out,sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*

sinfb: General purpose SinOscFB Ugen designed to mutate between pure sine waves and noise using the feedback argument.
A SynthDef that gets heavy use from me, works well for bass, chords and melody.

freq = frequency
atk = attack
sus = sustain
rel = release
fb = feedback (generally useful values are from 0-2, with 0 being pure sine waves and 2-20 being noise. More info on this in 'Between Pitch and Noise' section of guides)
amp = volume
out = channels out
pan = panning in stereo

*/

SynthDef(\sinfb, {
	arg freq = 440, atk = 0.01, sus = 0, rel = 1, fb = 0, amp = 0.3, out = 0, pan=0;
	var sig, env;
	env = EnvGen.ar(Env.linen(atk,sus,rel),1,1,0,1,2);
	sig = SinOscFB.ar(freq,fb,1);
	sig = sig*env;
	// Out.ar(out,Pan2.ar(sig,pan,amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;


/*

ring1: a Ringz-based synth which is inspired by this: http://sccode.org/1-1b
ring2, ring3 and ring4 represent the other tones used in this example, but I don't use them. They have been left in in case I would like to use the original combination of frequencies
the .tanh gives a wonderful squelch when driven very hard, and at low frequencies it resembles an acid bass

f = frequency (the reason this isn't freq is because it doesn't seem to work)
a = amplitude of Ringz (before the final multiplier so that a heavily distorted signal can be later scaled by amp)
d = duration of envelope on Ringz
pan = Pan in stereo
amp = overall volume
out = channels out

*/

SynthDef(\ring1,
	{
		arg f = 45, a = 9, d = 0.6, pan = 0, amp = 1, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		// Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
		OffsetOut.ar(out, DirtPan.ar(sig.tanh, ~dirt.numChannels, pan, env));
	};
).add;

SynthDef(\ring2,
	{
		arg f = 9000, a = 2, d = 0.1, amp = 1, pan = 2, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		// Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
		OffsetOut.ar(out, DirtPan.ar((sig.tanh) * amp, ~dirt.numChannels, pan, env));
	};
).add;

SynthDef(\ring3,
	{
		arg f = 50, a = 3, d = 1, pan = 0, amp = 1, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		// Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
	OffsetOut.ar(out, DirtPan.ar(sig.tanh * amp, ~dirt.numChannels, pan, env));
	};
).add;

SynthDef(\ring4,
	{
		arg f = 8000, a = 1, d = 0.3, pan = 0, amp = 1, out = 0;
		var sig, env;
		env = Line.kr(0,1,d);
		env = FreeSelfWhenDone.kr(env);
		sig = Impulse.ar(0);
		sig = Ringz.ar(sig,f,d,a);
		// Out.ar(out,Pan2.ar(sig.tanh,pan) * amp)
	OffsetOut.ar(out, DirtPan.ar(sig.tanh * amp, ~dirt.numChannels, pan, env));
	};
).add;
)

