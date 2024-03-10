(



SynthDef(\Sd_analogBd, {
	arg out = 0, amp = 0.5, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, trig = 0.1, infsustain = 0.0, accent = 0.5, freq = 30, tone = 0.5, decay = 0.5, attackfm = 0.5, selffm = 0.25, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = AnalogBassDrum.ar(
		trig,
		infsustain,
		accent,
		freq,
		tone,
		decay,
		attackfm,
		selffm
	);

	sig = sig * amp;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;


SynthDef(\Sd_foldOsc, {
	arg out = 0, amp = 1, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 140, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = AnalogFoldOsc.ar(freq, amp);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;

SynthDef(\Sd_analogSd, {
	arg trig = 0.1, infsustain = 0, accent = 0.1, freq = 200, tone = 0.5, decay = 0.5, snappy = 0.5, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = AnalogSnareDrum.ar(
		trig,
		infsustain,
		accent,
		freq,
		tone,
		decay,
		snappy
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;

SynthDef(\Sd_blOsc, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, pulsewidth = 0.5, waveform = 0, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = BLOsc.ar(freq, pulsewidth, waveform);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;
/*
SynthDef(\Sd_harmOsc, {
arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 100, firstharmonic = 1, amplitudes = Array.rand(16, 0.1, 1), doneAction = 2;
var sig;
var envLength = sustain * (end - begin) / speed;
var line = Line.ar(begin, end, envLength, doneAction: doneAction);
var env = Env.asr;
var globalEnv = IEnvGen.ar(env, line);

freq = max(0, freq * speed * (1 + (accelerate * line)));

sig = HarmonicOsc.ar(
freq,
firstharmonic,
amplitudes
);
sig = Mix.ar(sig);

OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).play;*/

SynthDef(\Sd_neoFormant, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, formantfreq = 100, carrierfreq = 440, phaseshift = 0.5, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	sig = NeoFormant.ar(
		formantfreq * freq,
		carrierfreq * freq,
		phaseshift
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_neoVarSaw, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, pw = 0.5, waveshape = 0.5, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = NeoVarSawOsc.ar(
		freq,
		pw,
		waveshape
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;

// ne fonctionne pas encore !!

/*SynthDef(\Sd_rongs, {
	arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, freq = 1, sustain = 1, f0 = 0.01, structure = 0.5, brightness = 0.5, damping = 0.75, accent = 0.9, stretch = 0.5, position = 0.15, loss = 0.15, modeNum = 2, cosFreq = 0.25, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	sig = Rongs.ar(
		1,
		sustain,
		f0, // f0 * freq,
		structure,
		brightness,
		damping,
		accent,
		stretch,
		position,
		loss,
		modeNum,
		cosFreq
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).play;*/


SynthDef(\Sd_varshapeOsc, { arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 100, pw = 0.5, waveshape = 0.5, sync = 1, syncfreq = 105, doneAction = 2;
var sig;
var envLength = sustain * (end - begin) / speed;
var line = Line.ar(begin, end, envLength, doneAction: doneAction);
var env = Env.asr;
var globalEnv = IEnvGen.ar(env, line);

freq = max(0, freq * speed * (1 + (accelerate * line)));
// freq = freq.max(0.01).min(2);
	sig = VarShapeOsc.ar(freq, pw, waveshape, sync, syncfreq);

OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_vosimOsc, { arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 100, form1freq = 951, form2freq = 919, shape = 0, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	sig = VosimOsc.ar(freq, form1freq, form2freq, shape);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_zosc, { arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 100, formantfreq = 91, shape = 0.5, offsetphase = 0.5, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	sig = ZOsc.ar(freq, formantfreq, shape, mode: offsetphase);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;



)



/*SynthDef(\Sd_template, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
var sig;
var envLength = sustain * (end - begin) / speed;
var line = Line.ar(begin, end, envLength, doneAction: doneAction);
var env = Env.asr;
var globalEnv = IEnvGen.ar(env, line);

freq = max(0, freq * speed * (1 + (accelerate * line)));
// freq = freq.max(0.01).min(2);

OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;*/
