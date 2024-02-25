// https://github.com/v7b1/mi-UGens

(

SynthDef(\braids, {|out = 0, amp = 0.3, pan = 0, sustain = 1, begin = 0, end = 1, freq = 440, speed = 1, accelerate = 0, timbre = 0.5, color = 0.5, model = 0|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiBraids.ar(pitch: freq.cpsmidi, timbre: timbre, color: color, model: model);

	OffsetOut.ar(out, DirtPan.ar(sig * amp * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\omi, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiOmi.ar(pit: freq.cpsmidi);

	OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\plaits, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,
	timbre=0.5,engine=0,harm=0.5,morph=0.5,level=1,lpgdecay=0,lpgcolour=0|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiPlaits.ar(
		pitch: freq.cpsmidi,
		timbre: timbre,
		harm: harm,
		engine: engine,
		morph: morph,
		level: level,
		decay: lpgdecay,
		lpg_colour: lpgcolour,
	);

	OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\tides, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,tidesshape=0.5,slope=0.5,tidessmooth=0.5,shift=0.5,mode=2|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiTides.ar(
		freq: freq,
		shape: tidesshape,
		slope: slope,
		smooth: tidessmooth,
		shift: shift,
		output_mode: mode,
		ramp_mode: 1,
		rate: 1
	);

	OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\Sd_stochadiet1, {|out = 0, amp = 1, pan = 0, begin = 0, end = 1, speed = 1, sustain = 1, sdm = 1, modSin = 0.4, from = 9, dest = 12, minSeq = 0.1, maxSeq = 0.3, doneAction = 2|
	var sig, sd, hpf=40, mf=1.0;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	sdm = sdm.max(0.1);
	sd = SampleDur.ir * sdm;

	sig = HPF.ar(
		DemandEnvGen.ar(
			Dseq([minSeq, minSeq.neg, [maxSeq.neg, maxSeq]], inf),
			sd * Dseq([Lag.kr(from), Lag.kr(dest), Dbrown(from, dest, dest, from.neg, from)], inf)
		).fold2(SinOsc.ar(modSin)) * mf,
		hpf
	);
	sig = sig * globalEnv;
	/*sig = Balance2.ar(sig[0], sig[1], pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

// corriger args to en dest

SynthDef(\Sd_stochadiet2, {|out = 0, amp = 0.5, pan = 0, begin = 0, end = 1, speed = 1, sustain = 1, sdm = 1, repeats = 32, from = 8, dest = 30, doneAction = 2|
	var sig, sd, mf=0.2;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	sdm = sdm.max(0.1);
	sd = SampleDur.ir * sdm;

	repeats = repeats.max(1);

	sig = DemandEnvGen.ar(
		Dseq([
			Dseq([0, 0.5], repeats),
			Dseq([-0.2, 0.8], repeats / 2),
			Dseq([-1.0, 1.0], Dwhite(repeats / 32, repeats)),
			Dseq([-0.8, 0.1], repeats / 16)
		], inf),
		Dseq([
			Dwhite(from, dest, [repeats, repeats * 0.5]),
			Dwhite(from / 1.5, dest / 1.5, [repeats, repeats * 2]),
			Dbrown(from / 10, dest / 10, from / 20, [repeats, repeats * 0.25])
		], inf) * sd
	) * mf;
	sig = sig * globalEnv;
	/*sig = Balance2.ar(sig[0], sig[1], pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet3, {|out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, sustain = 1, timeStep = 2, start = 1, from = 2, dest = 5, sdm = 0.2, minLev = 0.1, maxLev = 0.9, brownStep = 0.01, doneAction = 2|
	var sig, iter = 2, sd, mf = 0.08;
	var levels = ({ Dseries(rrand(minLev.neg, maxLev.neg), rrand(minLev, maxLev), from * rrand(from, dest)) } ! iter) ++
	({ Dbrown(rrand(minLev.neg, maxLev.neg), rrand(minLev, maxLev), brownStep, dest * 2) } ! iter);
	var times = { Dseries(rrand(start, start * 2), rrand(timeStep, timeStep * 2), rrand(from * 5, dest * 4)) } ! (iter * 2);
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	sdm = sdm.max(0.1);
	sd = SampleDur.ir * [sdm, sdm * 1.1];

	sig = DemandEnvGen.ar(
		Dseq(levels, inf),
		Dseq(times, inf) * sd
	) * mf;
	sig = sig * globalEnv;
	/*sig = Balance2.ar(sig[0], sig[1], pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet4, {|out = 0, amp = 1, pan = 0, begin = 0, end = 1, speed = 1, sustain = 1, sdm = 1, repeats = 4, from = 5, dest = 18, sinMod = 60, doneAction = 2|
	var sig, length = 30, sd, mf = 0.3;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	sdm = sdm.max(0.1);
	sd = SampleDur.ir * sdm;

	sig = DemandEnvGen.ar(
		Dseq([Dseries(-1.0, [0.04, 0.09], 30)], inf),
		Dseq([
			Dwhite(from, dest, repeats),
			Dwhite(from / 1.5, dest * 3, repeats)
		], inf) * sd
	).clip(SinOsc.ar(sinMod)) * mf;
	sig = sig * globalEnv;
	/*sig = Balance2.ar(sig[0], sig[1], pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet5, {|out = 0, amp = 0.4, pan = 0, begin = 0, end = 1, speed = 1, sustain = 1, filtSpeed = 10, filtCenter = 200, sdm = 1, modFreq = 0.01, filtBw = 3, doneAction = 2|
	var sig, sd, size = 3, a = 9, b = 5, min = 0.1, max = 0.3;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	sdm = sdm.max(0.1);
	sd = SampleDur.ir * sdm;

	sig = DemandEnvGen.ar(
		Dseq([min, min.neg, [max.neg, max]], inf),
		Dwhite(sd * a, sd * b),
	).wrap2(SinOsc.ar([modFreq, modFreq * 1.1])) * 0.2;
	sig = SoftClipAmp8.ar(sig, 10);
	sig = HPF.ar(BBandStop.ar(sig, Lag.ar(LFNoise1.ar([filtSpeed, filtSpeed * 2] ).range(filtCenter * 0.2, filtCenter * 2), 0.05), filtBw));
	sig = sig * globalEnv;
	/*sig = Balance2.ar(sig[0], sig[1], pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_metro, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, envT1 = 0.02, envT2 = 0.12, envT3 = 0.01, envT4 = 0, envDivDur = 1, theta = 0.5, rho = 0.8, filterfreq = 1000, rq = 1.0, doneAction = 2;
	var snd, envf, b1, b2;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	// freq = max(0, freq * speed * (1 + (accelerate * line)));
	envf = EnvGen.ar(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2, envT3, envT4]), timeScale: sustain / envDivDur);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	snd = SOS.ar(envf, 1.0, 0.0, 0.0, b1, b2) * envf;
	snd = RHPF.ar(snd, filterfreq, rq);
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kickBoomy, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, envT1 = 0.012, envL1 = 0, envT2 = 0.0012, envL2 = 1, envT3 = 0.12, envL3 = 0.1, envCrv = (-4), lvlScale = 1, hpfFreq = 500, softGain=1.1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	sig = (SinOsc.ar(frq1/4 * freq) + SinOsc.ar(frq2/4 * freq) + LFTri.ar(frq3/4 * freq) + LFTri.ar(frq4/4 * freq) + BrownNoise.ar(0.1));
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.pairs([[envT1, envL1], [envT2, envL2], [envT3, envL3]], envCrv), levelScale: lvlScale), hpfFreq);
	sig = sig * softGain;
	sig = sig.softclip * 1;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_batuhan, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, eSawDec = 0.6, eSinL1 = 0, eSinL2 = 1, eSinL3 = 0, eSinL4 = 0.32, eSinT1 = 0.24, eSinT2 = 0.02, eSinT3 = 0.12, eSinC1 = (-4), eSinC2 = (-4), eSinC3 = (-4), sinFreq = 33, sawMix = 1, sawFreq = 8, bpfFreq = 162, bpfRq = 1, bpfMix = 0, brfFreq1 = 45.1, brfFreq2 = 45, brfRq = 1, doneAction = 2;
	var sig, trig, envSaw, envSin;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	trig = Impulse.kr(0);
	envSaw = Decay2.kr(
		trig,
		0.01,
		eSawDec
	);
	envSin = EnvGen.kr(Env.new([eSinL1, eSinL2, eSinL3, eSinL4], [eSinT1, eSinT2, eSinT3], [eSinC1, eSinC2, eSinC3]), trig);
	sig = ((Saw.ar(sawFreq * freq, envSaw) ** 1.5) * sawMix) + (SinOsc.ar(sinFreq * freq, 0, envSin) * (1 - sawMix));
	sig = (sig * (1 - bpfMix)) + (BPF.ar(sig, bpfFreq, bpfRq.max(0.01)) * bpfMix);
	sig = BRF.ar(sig, trig * 20 + [brfFreq1, brfFreq2], brfRq.max(0.01));
	sig = Splay.ar(sig, levelComp: false);
	sig = LeakDC.ar(sig).tanh;
	sig = HPF.ar(sig, 28);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_rim, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	var envf = EnvGen.ar(Env([\envfL1.kr(1600), \envfL2.kr(5600), \envfL3.kr(800), \envfL4.kr(250)],[\envfT1.kr(0.001), \envfT2.kr(0.001), \envfT3.kr(0.001)].normalizeSum * sustain, -4));
	var envf2 = EnvGen.ar(Env([\envf2L1.kr(1000), \envf2L2.kr(1600), \envf2L3.kr(700), \envf2L4.kr(200)],[\envf2T1.kr(0.001), \envf2T2.kr(0.001), \envf2T3.kr(0.06)].normalizeSum * sustain, -4));

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = SinOsc.ar(freq * \sinFreq.kr(400)) * globalEnv;
	sig = WhiteNoise.ar(globalEnv) + sig;
	sig = RHPF.ar(sig, \rhpfFreq.kr(100) * freq, \rhpfRq.kr(1)) + sig;
	sig = sig + Mix.ar(BPF.ar(sig, [\bpfFreq1.kr(327), \bpfFreq2.kr(430)], [\bpfRq1.kr(0.5), \bpfRq2.kr(0.5)]) * 0.8) + WhiteNoise.ar(globalEnv) + BrownNoise.ar(globalEnv / 8);
	sig = RLPF.ar(sig, \rlpfFreq.kr(11100) * freq, \rlpfRq.kr(0.5)) + sig;
	sig = (Ringz.ar(WhiteNoise.ar, Mix.ar([envf2, envf * 0.9, envf2 * 0.8]), 1, globalEnv) + RLPF.ar(BrownNoise.ar(globalEnv), envf * 4, 1, 1) + sig) * globalEnv;
	sig = CompanderD.ar(sig * 4, 0.8, 0.3, 0.5, 0.001, 0.2, globalEnv);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_rim1, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	var envf = EnvGen.ar(Env([\envfL1.kr(1600), \envfL2.kr(5600), \envfL3.kr(800), \envfL4.kr(250)],[\envfT1.kr(0.001), \envfT2.kr(0.001), \envfT3.kr(0.001)].normalizeSum * sustain, -4));
	var envf2 = EnvGen.ar(Env([\envf2L1.kr(1000), \envf2L2.kr(1600), \envf2L3.kr(700), \envf2L4.kr(200)],[\envf2T1.kr(0.001), \envf2T2.kr(0.001), \envf2T3.kr(0.06)].normalizeSum * sustain, -4));

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = SinOsc.ar(freq * \sinFreq.kr(400)) * globalEnv;
	sig = WhiteNoise.ar(globalEnv) + sig;
	sig = RHPF.ar(sig, \rhpfFreq.kr(100), \rhpfRq.kr(1)) + sig;
	sig = sig + Mix.ar(BPF.ar(sig, [\bpfFreq1.kr(327), \bpfFreq2.kr(430)], [\bpfRq1.kr(0.5), \bpfRq2.kr(0.5)]) * 0.8) + WhiteNoise.ar(globalEnv) + BrownNoise.ar(globalEnv / 8);
	sig = RLPF.ar(sig, \rlpfFreq.kr(11100), \rlpfRq.kr(0.5)) + sig;
	sig = (Ringz.ar(WhiteNoise.ar, Mix.ar([envf2, envf * 0.9, envf2 * 0.8]), 1, globalEnv) + RLPF.ar(BrownNoise.ar(globalEnv), envf * 4, 1, 1) + sig);
	sig = CompanderD.ar(sig * 4, 0.8, 0.3, 0.5, 0.001, 0.2, globalEnv);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_rim2, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	var envf = EnvGen.ar(Env([\envfL1.kr(1600), \envfL2.kr(5600), \envfL3.kr(800), \envfL4.kr(250)],[\envfT1.kr(0.001), \envfT2.kr(0.001), \envfT3.kr(0.001)].normalizeSum * sustain, -4));
	var envf2 = EnvGen.ar(Env([\envf2L1.kr(1000), \envf2L2.kr(1600), \envf2L3.kr(700), \envf2L4.kr(200)],[\envf2T1.kr(0.001), \envf2T2.kr(0.001), \envf2T3.kr(0.06)].normalizeSum * sustain, -4));

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	sig = SinOsc.ar(freq) * globalEnv;
	sig = WhiteNoise.ar(globalEnv) + sig;
	sig = RHPF.ar(sig, \rhpfFreq.kr(100), \rhpfRq.kr(1)) + sig;
	sig = sig + Mix.ar(BPF.ar(sig, [\bpfFreq1.kr(327), \bpfFreq2.kr(430)], [\bpfRq1.kr(0.5), \bpfRq2.kr(0.5)]) * 0.8) + WhiteNoise.ar(globalEnv) + BrownNoise.ar(globalEnv / 8);
	sig = RLPF.ar(sig, \rlpfFreq.kr(11100), \rlpfRq.kr(0.5)) + sig;
	sig = (Ringz.ar(WhiteNoise.ar, Mix.ar([envf2, envf * 0.9, envf2 * 0.8] * freq), 1, globalEnv) + RLPF.ar(BrownNoise.ar(globalEnv), envf /** 4*/ * freq, 1, 1) + sig);
	sig = CompanderD.ar(sig * 4, 0.8, 0.3, 0.5, 0.001, 0.2, globalEnv);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kick3new, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 60, tu = 1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = SinOsc.ar(freq*tu, 0);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kickBlocks, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1,
	//tone1 arguments
	t1freq = 400, t1harmonic = 2, t1glide = 0.01,
	t1att = 0.0005, t1rel = 0.01, t1curve = (-4), t1del = 0, t1amp = 1,
	//tone2 arguments
	t2freq = 50, t2harmonic = 3.44, t2glide = 0.01,
	t2att = 0.0001, t2rel = 0.3, t2curve = (-4), t2del = 0.005, t2amp = 1,
	//hit1 arguments
	h1freq = 100, h1harmonic = 8, h1glide = 0.01, h1rq = 0.6,
	h1att = 0.001, h1rel = 0.02, h1curve = (-4), h1del = 0.001, h1amp = 1,
	//hit2 arguments
	h2freq = 1320, h2harmonic = 1, h2glide = 0,
	h2att = 0.003, h2rel = 0.03, h2curve = (-4), h2del = 0, h2amp = 0.5,
	//click arguments
	cfreq = 6100, crq = 1, camp = 1.41, cdur = 0.001,
	doneAction = 2;

	var sig, noise, tone1, tone2, hit1, hit2, click;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	noise = Hasher.ar(Sweep.ar); //deterministic white noise

	tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide) * freq,
		mul: Env.perc(attackTime: t1att, releaseTime: t1rel, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide) * freq,
		mul: Env.perc(attackTime: t2att, releaseTime: t2rel, level: t2amp, curve: t2curve).delay(t2del).ar);

	hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide) * freq,
		rq: h1rq,
		mul: Env.perc(attackTime: h1att, releaseTime: h1rel, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide) * freq,
		mul: Env.perc(attackTime: h2att, releaseTime: h2rel, level: h2amp, curve: h2curve).delay(h2del).ar);

	click = BPF.ar(
		in: noise * EnvGen.kr(Env.step([1, 0], [cdur, cdur * 0.01]), levelScale: camp),
		freq:  cfreq * freq,
		rq: crq
	);

	sig = Mix.ar(tone1 + tone2 + hit1 + hit2 + click).tanh;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_hat808, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, rls = 0.1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = Saw.ar((1..9)*1000.23/**env*/*freq);
	sig = RHPF.ar(sig, \rhpfFreq.kr(5700), \rhpfRq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1), rls, -4), timeScale: sustain))*freq;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \rhpf1Freq.kr(2000)/**env*freq*/, \rhpf1Rq.kr(0.5));
	sig = LeakDC.ar(sig);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_werkit, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, rq = 0.1, doneAction = 2;
	var sig, filter;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = WhiteNoise.ar;
	filter = BLowPass4.ar(sig, freq, rq) * 0.3;
	sig = (0.7 * filter + (0.3 * filter.distort));

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_tubularBell, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, harmFreq = 1, harmAmp = 1, harmTime = 1, atk = 0.005, rls = 9, exciterRel = 0.05, doneAction = 2;
	var sig, exenv, exciter;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	exenv = Env.perc(atk, exciterRel, 0.05).kr;

	exciter = GrayNoise.ar(exenv);

	sig = DynKlank.ar(
		specificationsArrayRef:
		Ref.new([
			[1.013, 1.512, 2.113, 2.525, 3.35, 4.57, 6.48] * harmFreq,   // harmonics
			[1, 0.78, 0.89, 0.63, 0.31, 0.56, 0.25] * harmAmp, // amplitudes
			[1, 0.9, 0.8, 0.65, 0.45, 0.3, 0.1] * harmTime   // ring times
		]),
		input: exciter,
		freqscale: freq,
		decayscale: rls
	);

	sig = LPF.ar(sig, freq * 9.5);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_snapkick, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, doneAction = 2;
	var sig, bodyFreq, bodyAmp, body, popFreq, popAmp, pop, clickAmp, click;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC)) * freq;
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve));
	body = SinOsc.ar(bodyFreq) * bodyAmp;
	// pop sweeps over the midrange
	popFreq = XLine.kr(popFrqSt, popFrqEnd, popFrqDur) * freq;
	popAmp = EnvGen.ar(Env.linen(popAmpAtt, popAmpSus, popAmpRel, popAmpLev));
	pop = SinOsc.ar(popFreq) * popAmp;
	// click is spectrally rich, covering the high-freq range
	// you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(clkAmpAtt, clkAmpRel, clkAmpLev, clkAmpCurve));
	click = LPF.ar(Formant.ar(clkfFundFreq * freq, clkfFormFreq, clkfBwFreq), clkLpfFreq) * clickAmp;

	sig = body + pop + click;
	sig = sig.tanh * globalEnv;

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_waveguideFlute, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, scl = 0.2, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1, doneAction = 2;
	var signalOut;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	var ifqc = max(0, freq * speed * (1 + (accelerate * line)));

	var sr = SampleRate.ir;
	var cr = ControlRate.ir;
	var block = cr.reciprocal;

	// noise envelope
	var kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);

	// vibrato envelope
	var kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	var aflow1 = LFClipNoise.ar( sr, kenv1 );
	var kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	var asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	var afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	var fdbckArray = LocalIn.ar( 1 );

	var aflute1 = fdbckArray;
	var asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	var ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	var apoly = ax - ( ax.cubed );
	var asum3 = apoly + ( aflute1 * ifeedbk2 );
	var avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	OffsetOut.ar(out, DirtPan.ar(signalOut * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kick_oto309, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.5, env0L4 = 0, env0T1 = 0.005, env0T2 = 0.06, env0T3 = 0.26, env0Crv1 = (-4), env0Crv2 = (-2), env0Crv3 = (-4), env1L1 = 110, env1L2 = 59, env1L3 = 29, env1T1 = 0.005, env1T2 = 0.29, env1Crv1 = (-4), env1Crv2 = (-5), doneAction = 2;
	var son, env0, env1, env1m;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [env0Crv1, env0Crv2, env0Crv3]));
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [env1Crv1, env1Crv2])) * freq;
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2 * globalEnv;
	son = son.clip2(1);

	OffsetOut.ar(out, DirtPan.ar(son * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_cymnew, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 6, doneAction = 2;
	var sig, freqs;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	freqs = geom(63,40,pi/3) * 10.234567 * freq;
	sig = WhiteNoise.ar(0.2);
	sig = Ringz.ar(sig,freqs,1).mean;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kickmed, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, level = 0.5, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.0001, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, doneAction = 2;
	var son, env0, env1, env1m, son2, son3, son4;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	env0 = Env([env0L1, env0L2, env0L3, env0L4, 0],[atkEnv0, decEnv0, relEnv0, 0.05], [curve1, curve2, curve3]);
	env1 = Env([env1L1, env1L2, env1L3], [env1T1, env1T2], curve1);
	env0 = EnvGen.ar(env0);
	env1 = EnvGen.ar(env1);
	env1m = freq * env1.max(0.01).min(2);
	son = LFSaw.ar(env1m, 0, oamp, 1, 1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1, 1.4);
	son3 = LFPulse.ar(env1m, 0, oamp, 1, 1.4);
	son4 = LFTri.ar(env1m, 0, oamp, 1, 1.4);
	son = SelectX.ar(ochoose.mod(4), [son, son2, son3, son4]);
	son = LeakDC.ar(son,dc.min(1),30);
	son = son + WhiteNoise.ar(noise);
	son = LPF.ar(son, env1m * fratio.max(0.01), env0);
	son = son + SelectX.ar(owhich2.mod(4),[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son = son * level.distort;

	OffsetOut.ar(out, DirtPan.ar(son * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kickMist, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, noise = 1, env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, curve1_1 = (-4), curve1_2 = (-5), doneAction = 2;
	var sig, env1m;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	env1m = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [curve1_1, curve1_2]));
	sig = LFPulse.ar(env1m*freq, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, globalEnv);
	sig = sig + SinOsc.ar(env1m*freq, 0.5, globalEnv);
	sig = sig.clip2(1);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_main, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sin1Freq = 30, envL1 = 0, envL2 = 1, envL3 = 0.01, envL4 = 1.3, envL5 = 0, envT1 = 0.01, envT2 = 0, envT3 = 0.2, envT4 = 0.01, clickCurve = (-4), clickInScale = 1, clickEnvPow = 1, clickHpf = 80, clickHpRq = 1, clickLpf = 13000, clickLpRq = 1, clickAmp = 1, sel = 0, sin2Freq = 40, sin2Amp = 0.3, noiseAmp = 1, hpffreq = 8000, revtime = 3, room = 10, distAmt = 2, distMix = 0, doneAction = 2;
	var sig, fmod;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	var distSig, envClick, click;
	freq = max(0, freq * speed * (1 + (accelerate * line)));

	fmod = SinOsc.ar(freq/60, 0, freq/60);
	sig = [
		SinOsc.ar([freq, freq + 0.6] + fmod, 0, [lev, lev - 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpffreq),
		SinOsc.ar(sin1Freq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];

	envClick = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum * sustain, clickCurve), levelScale: clickInScale).pow(clickEnvPow);
	click = RHPF.ar(envClick, clickHpf, clickHpRq);
	click = RLPF.ar(click, clickLpf, clickLpRq);
	click = click * clickAmp;

	sig = (click + SelectX.ar(sel.wrap(0, 3), sig).fold(-1, 1) * 0.7 + SinOsc.ar(sin2Freq, 0, sin2Amp) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpffreq)));

	distSig = Clip.ar(sig * distAmt);
	sig = SelectX.ar(distMix, [sig, distSig]);
	sig = LeakDC.ar(sig);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_sosKick, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
	// sub controls
	startsubfreq = 60, endsubfreq = 32, linesubdur = 0.08, subdecay = 0.2, sublowpass = 500,
	// drum controls
	drumFreq = 50, drumHarmonic = 2, drumSweep = 0.02, drumAtt = 0.005, drumRel = 0.4, crv = (-4),
	drumFilter = 1000, modIndex = 6.5, modFreq = 5,
	// beater controls
	beaterFreq = 500, beaterHarmonic = 12, beaterSweep = 0.03, noiseMod = 500, beaterL1 = 0, beaterL2 = 1, beaterL3 = 2.4, beaterL4 = 0, beaterT1 = 0.01, beaterT2 = 0.3, beaterT3 = 0.08,
	// click controls
	clkffreq = 500, clkres = 0, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	var gate, subfreq, sub, drumEnv, drumContour, drum, beaterContour, beaterEnv, beater, snd, click, envClick;

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	gate = Impulse.kr(0);

	subfreq = XLine.kr(startsubfreq, endsubfreq, linesubdur, 1, 0);

	sub = LPF.ar(Ringz.ar(Impulse.ar(0), subfreq, subdecay), sublowpass) * subamp;

	drumEnv = Env.perc(attackTime: drumAtt, releaseTime: drumRel, curve: crv).kr;

	sub = sub * drumEnv;

	drumContour = Line.kr(start: drumFreq * drumHarmonic, end: drumFreq, dur: drumSweep);

	drum = PMOsc.ar(
		carfreq: drumContour.explin(20, 20000, 0.01, 1) * freq,
		modfreq: modFreq,
		pmindex: modIndex,
		mul: drumAmp
	);

	drum = LPF.ar(in: drum, freq: Lag2.kr(drumFilter), mul: drumEnv);

	beaterEnv = Env([beaterL1, beaterL2, beaterL3, beaterL4], [beaterT1, beaterT2, beaterT3]).kr;

	beaterFreq = beaterFreq.explin(20, 20000, 0.01, 1) * freq;

	beaterContour = Line.kr(start: (beaterFreq * beaterHarmonic).min(20000), end: beaterFreq, dur: beaterSweep);

	beater = HPF.ar(in: WhiteNoise.ar(LFNoise0.kr(noiseMod)), freq: beaterFreq);

	beater = LPF.ar(in: beater, freq: beaterContour, mul: beaterEnv) * beaterAmp;

	envClick = EnvGen.kr(Env.step([700, 0], [0.0007, 0.1]), gate, 0.002);
	click = Hasher.ar(Sweep.ar(gate, 0.000001)) * envClick;
	click = MoogLadder.ar(click, clkffreq.explin(20, 20000, 0.01, 1) * freq, clkres) * EnvGen.kr(Env.perc(0.0001, 0.00001), gate, clickAmp);

	snd = Mix.ar(sub + drum + beater + click);

	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_windowsync, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 65.40639132515, syncEgTop = 20, syncRatio = 2, syncDcy = 0.5, doneAction = 2;
	var sig, fundamental, syncFreq, syncPhase;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	var syncEg = EnvGen.kr(Env([syncEgTop / syncRatio, 1], [syncDcy], \exp));
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	fundamental = LFTri.ar(freq);
	syncFreq = freq * syncRatio * syncEg;
	// note, Phasor here is behaving like the Sweep above (retrigger behavior)
	// but Phasor loops around its range, eliminating the need for '% 1'
	syncPhase = Phasor.ar(fundamental, syncFreq * SampleDur.ir, 0, 1, 0);
	sig = SinOsc.ar(0, syncPhase * 2pi) * fundamental;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_hoover, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, attack = 0.001, release = 0.5, curve = (-4), envPow = 1, envfL1 = (-5), envfL2 = 6, envfL3 = 0, envfT1 = 0.1, envfT2 = 1.7, crvf1 = 0, crvf2 = (-4), bw = 1.035, doneAction = 2;
	var snd, frq;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	bw = bw.min(85);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	frq = freq * Env([envfL1.min(2.5), envfL2.min(2.5), envfL3.min(2.5)], [envfT1, envfT2], [crvf1, crvf2]).kr.midiratio;
	snd = { DelayN.ar(Saw.ar(frq * ExpRand(bw, 1 / bw)) + Saw.ar(frq * 0.5 * ExpRand(bw, 1 / bw)), 0.01, Rand(0, 0.01)) }.dup(10);
	snd = (Splay.ar(snd) * 3).atan;
	snd = snd * Env.asr(0.01, 1.0, 1.0).kr(0);
	snd = FreeVerb2.ar(snd[0], snd[1], 0.3, 0.9);
	snd = snd * globalEnv;

	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kickRingz, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, attack = 0, release = 1.2, envPow = 1, clickCurve = (-4), clickInScale = 1, clickEnvPow = 1, clickHpf = 80, clickHpRq = 1, clickLpf = 13000, clickLpRq = 1, clickAmp = 1, envL1 = 0.1, envL2 = 1.2, envL3 = 3, envL4 = 2.1, envL5 = 0.1, envT1 = 0.1, envT2 = 0.2, envT3 = 0, envT4 = 0.1, curve = (-4), envpL1 = 0.1, envpL2 = 1.2, envpL3 = 3, envpL4 = 2.1, envpT1 = 0.1, envpT2 = 0, envpT3 = 1.2, curvep = (-4), dcy = 0.25, ffreq = 1000, doneAction = 2;
	var snd, envClick, click, envp;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	envClick = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum, clickCurve), timeScale: sustain, levelScale: clickInScale).pow(clickEnvPow);
	click = RHPF.ar(envClick, clickHpf, clickHpRq);
	click = RLPF.ar(click, clickLpf, clickLpRq.min(1.6));
	click = click * clickAmp;

	// env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum, [curve, curve/2, curve]), timeScale: sustain);

	envp = EnvGen.kr(Env([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3].normalizeSum, [curvep, curvep * 1.25, curvep].midicps), timeScale: sustain);

	snd = Ringz.ar(
		in: LPF.ar(in: Impulse.ar(0), freq: ffreq),
		freq: freq * envp,
		decaytime: dcy,
		mul: amp
	);

	snd = snd.tanh.sin * 2 /** env*/;

	snd = LeakDC.ar(snd + click) * globalEnv;

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_runglerDeter, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, attack = 0.001, release = 1.4, curve = (-4), envPow = 1, lfSrc1Sel = 0, lfSrc1Rate = 0.7, lfSrc2Sel = 1, lfSrc2Rate = 0.24, switchSrcRate = 0.4, ffreq = 24, doneAction = 2;
	var snd, lfSource1, lfSource2, lfo, rungler, runglerOut, tu;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	tu = max(0, freq * speed * (1 + (accelerate * line)));

	lfSource1 = Select.ar(lfSrc1Sel.round.mod(5), [BlitB3Tri.ar(lfSrc1Rate), DPW4Saw.ar(lfSrc1Rate), SinOsc.ar(lfSrc1Rate), LFCub.ar(lfSrc1Rate), LFGauss.ar(lfSrc1Rate)]);
	lfSource2 = Select.ar(lfSrc2Sel.round.mod(5), [BlitB3Tri.ar(lfSrc2Rate), DPW4Saw.ar(lfSrc2Rate), SinOsc.ar(lfSrc2Rate), LFCub.ar(lfSrc2Rate), LFGauss.ar(lfSrc2Rate)]);

	lfo = {
		var trigger;
		trigger = Impulse.ar(switchSrcRate);
		Select.ar(ToggleFF.ar(trigger), [
			lfSource1,
			lfSource2
		]);
	};

	rungler = { |dataSignal, clockSignal|
		var numBits, bits, bit, out, doDAC;
		doDAC = { |bits|
			var result;
			result = bits[0] + (bits[1] * 2) + (bits[2] * 4);
			result = result / 7;
			result = (result * 2) - 1;
			result;
		};
		bit = dataSignal > 0;
		numBits = 8;
		bits = [];
		numBits.do {
			bit = Latch.ar(bit, clockSignal);
			bits = bits.add(bit);
			bit = Delay1.ar(bit);
		};
		(
			out: doDAC.(bits[numBits - 3..numBits - 1]),
			outReverse: doDAC.(bits[numBits - 2..numBits - 4]),
		);
	};
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFTri.ar(({ lfo.() } ! 2).linexp(-1, 1, [10, 1], 8000) * (snd * tu).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, ({ lfo.() } ! 2).linexp(-1, 1, 100, 8000) * (runglerOut[\out] * ffreq).midiratio, 3);
	snd = snd * globalEnv;

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_fabHi1Sus, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatt = 0.001, envSrel = 0.2, mix = 0.5, ffreq = 6000, doneAction = 2;
	var sig, noise, sin1, sin2, envNoise, envSin;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	envNoise = EnvGen.kr(Env.perc(envNatt, envNrel));
	envSin = EnvGen.kr(Env.perc(envSatt, envSrel));
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1 * freq, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2 * freq, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	sig = HPF.ar(sig * globalEnv, ffreq);

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_clapthan, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1024, envL1 = 0, envL2 = 1, envL3 = 0.5, envL4 = 1, envT1 = 0.001, envT2 = 0.01, envT3 = 0.001, crv = 0, hpfRq = 0.3, doneAction = 2;
	var sig, inEnv;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	inEnv = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], crv));
	sig = RHPF.ar(Hasher.ar(Sweep.ar(trig: Impulse.ar(freq))), freq, hpfRq);
	sig = sig * inEnv;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_lcm2Sus, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 140, envNoiseFrq1 = 0.3, envNoiseFrq2 = 0.33, envNoiseVol = 0.3, envInv = 0, mod1 = 3.09431, mod2 = 54.0487, doneAction = 2;
	var sig, sig1, sig2;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	globalEnv = globalEnv + LFNoise0.kr([envNoiseFrq1, envNoiseFrq1] , envNoiseVol);

	globalEnv = Select.kr(envInv, [globalEnv, globalEnv.neg]);

	mod1 = mod1.min(1000).max(1);
	mod2 = mod2.min(1000).max(1);

	sig1 = Saw.ar(freq * mod1).range(-100,100).round(1);
	sig2 = LFCub.ar(freq * mod2).range(-100,100).round(1);

	sig = tanh(lcm(sig1, sig2) * 0.001);

	sig = sig * globalEnv;

	sig = LeakDC.ar(sig);

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_danScar, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
	var sig, inSig, lfo;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	inSig = SinOsc.ar(freq + [0, 0.1]);
	lfo = LFDNoise1.kr(noiseFreq).linexp(-1, 1, 0.5, 1);

	sig = LPF.ar(
		Fb1.ar(
			{ |in, out| in[0] - (out[1] % lfo) },
			inSig, 2, blockSize: s.options.blockSize
		),
		lpfFreq
	) /** amp*/;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_vowelsynth, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, vel = 1, bend = 0, vow = 0, doneAction = 2;
	var sig, fq;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	var a,b,c,d,e,
	vib1,vib2,vib3,vib4,vib5,vib6,vib7,vib8,
	gen1,gen2,gen3,gen4,gen5,gen6,gen7,gen8,ngen,
	ah1,eh1,ih1,oh1,uh1,
	ah2,eh2,ih2,oh2,uh2,
	ah3,eh3,ih3,oh3,uh3,
	ah4,eh4,ih4,oh4,uh4,
	ah5,eh5,ih5,oh5,uh5,
	ah6,eh6,ih6,oh6,uh6,
	ah7,eh7,ih7,oh7,uh7,
	ah8,eh8,ih8,oh8,uh8,
	mod1,mod2,mod3,mod4,mod5,mod6,mod7,mod8,
	pan1,pan2,pan3,pan4,pan5,pan6,pan7,pan8;

	fq = max(0, freq * speed * (1 + (accelerate * line)));

	vib1=SinOsc.ar(5,0,EnvGen.kr(Env([0,2],[0.2],4),1));
	vib2=SinOsc.ar(5.2,0,EnvGen.kr(Env([0,1],[0.3],4),1));
	vib3=SinOsc.ar(4.3,0,EnvGen.kr(Env([0,2],[0.4],4),1));
	vib4=SinOsc.ar(5.4,0,EnvGen.kr(Env([0,1],[0.5],4),1));
	vib5=SinOsc.ar(4.5,0,EnvGen.kr(Env([0,2],[0.6],4),1));
	vib6=SinOsc.ar(5.25,0,EnvGen.kr(Env([0,1],[0.7],4),1));
	vib7=SinOsc.ar(4.35,0,EnvGen.kr(Env([0,2],[0.8],4),1));
	vib8=SinOsc.ar(5.45,0,EnvGen.kr(Env([0,1],[0.9],4),1));

	mod1=SinOsc.ar(0.1,mul:1);
	mod2=SinOsc.ar(-0.23,mul:1);
	mod3=SinOsc.ar(0.34,mul:1);
	mod4=SinOsc.ar(-0.44,mul:1);
	mod5=SinOsc.ar(0.5,mul:1);
	mod6=SinOsc.ar(-0.6,mul:1);
	mod7=SinOsc.ar(0.73,mul:1);
	mod8=SinOsc.ar(-0.81,mul:1);

	gen1=LFPulse.ar(fq*bend.midiratio+mod1+vib1,0,0.4*mod8/8+0.2,0.15,0);
	gen2=LFPulse.ar(fq*bend.midiratio+mod2+vib2,0,0.4*mod7/8+0.2,0.15,0);
	gen3=LFPulse.ar(fq*bend.midiratio+mod3+vib3,0,0.4*mod6/8+0.2,0.15,0);
	gen4=LFPulse.ar(fq*bend.midiratio+mod4+vib4,0,0.4*mod5/8+0.2,0.15,0);
	gen5=LFPulse.ar(fq*bend.midiratio+mod5+vib5,0,0.4*mod4/8+0.2,0.15,0);
	gen6=LFPulse.ar(fq*bend.midiratio+mod6+vib6,0,0.4*mod3/8+0.2,0.15,0);
	gen7=LFPulse.ar(fq*bend.midiratio+mod7+vib7,0,0.4*mod2/8+0.2,0.15,0);
	gen8=LFPulse.ar(fq*bend.midiratio+mod8+vib8,0,0.4*mod1/8+0.2,0.15,0);
	ngen=Pulse.ar(220)*GrayNoise.ar(0.005);

	//Female vowel charts.

	ah1=BBandPass.ar(gen1, 751,0.075) + BBandPass.ar(gen1, 1460,0.075) + BBandPass.ar(gen1, 2841,0.075);
	eh1=BBandPass.ar(gen1, 431,0.075) + BBandPass.ar(gen1, 2241,0.075) + BBandPass.ar(gen1, 2871,0.075);
	ih1=BBandPass.ar(gen1, 329,0.075) + BBandPass.ar(gen1, 2316,0.075) + BBandPass.ar(gen1, 2796,0.075);
	oh1=BBandPass.ar(gen1, 438,0.075) + BBandPass.ar(gen1, 953,0.075) + BBandPass.ar(gen1, 2835,0.075);
	uh1=BBandPass.ar(gen1, 350,0.075) +BBandPass.ar(gen1, 1048,0.075) + BBandPass.ar(gen1, 2760,0.075);

	ah2=BBandPass.ar(gen2, 751,0.075) + BBandPass.ar(gen2, 1460,0.075) + BBandPass.ar(gen2, 2841,0.075);
	eh2=BBandPass.ar(gen2, 431,0.075) + BBandPass.ar(gen2, 2241,0.075) + BBandPass.ar(gen2, 2871,0.075);
	ih2=BBandPass.ar(gen2, 329,0.075) + BBandPass.ar(gen2, 2316,0.075) + BBandPass.ar(gen2, 2796,0.075);
	oh2=BBandPass.ar(gen2, 438,0.075) + BBandPass.ar(gen2, 953,0.075) + BBandPass.ar(gen2, 2835,0.075);
	uh2=BBandPass.ar(gen2, 350,0.075) + BBandPass.ar(gen2, 1048,0.075) + BBandPass.ar(gen2, 2760,0.075);

	ah3=BBandPass.ar(gen3, 751,0.075) + BBandPass.ar(gen3, 1460,0.075) + BBandPass.ar(gen3, 2841,0.075);
	eh3=BBandPass.ar(gen3, 431,0.075) + BBandPass.ar(gen3, 2241,0.075) + BBandPass.ar(gen3, 2871,0.075);
	ih3=BBandPass.ar(gen3, 329,0.075) + BBandPass.ar(gen3, 2316,0.075) + BBandPass.ar(gen3, 2796,0.075);
	oh3=BBandPass.ar(gen3, 438,0.075) + BBandPass.ar(gen3, 953,0.075) + BBandPass.ar(gen3, 2835,0.075);
	uh3=BBandPass.ar(gen3, 350,0.075) + BBandPass.ar(gen3, 1048,0.075) + BBandPass.ar(gen3, 2760,0.075);

	ah4=BBandPass.ar(gen4, 751,0.075) + BBandPass.ar(gen4, 1460,0.075) + BBandPass.ar(gen4, 2841,0.075);
	eh4=BBandPass.ar(gen4, 431,0.075) + BBandPass.ar(gen4, 2241,0.075) + BBandPass.ar(gen4, 2871,0.075);
	ih4=BBandPass.ar(gen4, 329,0.075) + BBandPass.ar(gen4, 2316,0.075) + BBandPass.ar(gen4, 2796,0.075);
	oh4=BBandPass.ar(gen4, 438,0.075) + BBandPass.ar(gen4, 953,0.075) + BBandPass.ar(gen4, 2835,0.075);
	uh4=BBandPass.ar(gen4, 350,0.075) + BBandPass.ar(gen4, 1048,0.075) + BBandPass.ar(gen4, 2760,0.075);

	//Male vowel charts

	ah5=BBandPass.ar(gen5, 608,0.075) + BBandPass.ar(gen5, 1309,0.075) + BBandPass.ar(gen5, 2466,0.075);
	eh5=BBandPass.ar(gen5, 372,0.075) + BBandPass.ar(gen5, 1879,0.075) + BBandPass.ar(gen5, 2486,0.075);
	ih5=BBandPass.ar(gen5, 290,0.075) + BBandPass.ar(gen5, 1986,0.075) + BBandPass.ar(gen5, 2493,0.075);
	oh5=BBandPass.ar(gen5, 380,0.075) + BBandPass.ar(gen5, 907,0.075) + BBandPass.ar(gen5, 2415,0.075);
	uh5=BBandPass.ar(gen5, 309,0.075) +BBandPass.ar(gen5, 961,0.075) + BBandPass.ar(gen5, 2366,0.075);

	ah6=BBandPass.ar(gen6, 608,0.075) + BBandPass.ar(gen6, 1309,0.075) + BBandPass.ar(gen6, 2466,0.075);
	eh6=BBandPass.ar(gen6, 372,0.075) + BBandPass.ar(gen6, 1879,0.075) + BBandPass.ar(gen6, 2486,0.075);
	ih6=BBandPass.ar(gen6, 290,0.075) + BBandPass.ar(gen6, 1986,0.075) + BBandPass.ar(gen6, 2493,0.075);
	oh6=BBandPass.ar(gen6, 380,0.075) + BBandPass.ar(gen6, 907,0.075) + BBandPass.ar(gen6, 2415,0.075);
	uh6=BBandPass.ar(gen6, 309,0.075) + BBandPass.ar(gen6, 961,0.075) + BBandPass.ar(gen6, 2366,0.075);

	ah7=BBandPass.ar(gen7, 608,0.075) + BBandPass.ar(gen7, 1309,0.075) + BBandPass.ar(gen7, 2466,0.075);
	eh7=BBandPass.ar(gen7, 372,0.075) + BBandPass.ar(gen7, 1879,0.075) + BBandPass.ar(gen7, 2486,0.075);
	ih7=BBandPass.ar(gen7, 290,0.075) + BBandPass.ar(gen7, 1986,0.075) + BBandPass.ar(gen7, 2493,0.075);
	oh7=BBandPass.ar(gen7, 380,0.075) + BBandPass.ar(gen7, 907,0.075) + BBandPass.ar(gen7, 2415,0.075);
	uh7=BBandPass.ar(gen7, 309,0.075) + BBandPass.ar(gen7, 961,0.075) + BBandPass.ar(gen7, 2366,0.075);

	ah8=BBandPass.ar(gen8, 608,0.075) + BBandPass.ar(gen8, 1309,0.075) + BBandPass.ar(gen8, 2466,0.075);
	eh8=BBandPass.ar(gen8, 372,0.075) + BBandPass.ar(gen8, 1879,0.075) + BBandPass.ar(gen8, 2486,0.075);
	ih8=BBandPass.ar(gen8, 290,0.075) + BBandPass.ar(gen8, 1986,0.075) + BBandPass.ar(gen8, 2493,0.075);
	oh8=BBandPass.ar(gen8, 380,0.075) + BBandPass.ar(gen8, 907,0.075) + BBandPass.ar(gen8, 2415,0.075);
	uh8=BBandPass.ar(gen8, 309,0.075) + BBandPass.ar(gen8, 961,0.075) + BBandPass.ar(gen8, 2366,0.075);

	//Summing them all

	a = [ah1+ah2+ah3+ah4+ah5+ah6+ah7+ah8];
	b = [eh1+eh2+eh3+eh4+eh5+eh6+eh7+eh8];
	c = [ih1+ih2+ih3+ih4+ih5+ih6+ih7+ih8];
	d = [oh1+oh2+oh3+oh4+oh5+oh6+oh7+oh8];
	e = [uh1+uh2+uh3+uh4+uh5+uh6+uh7+uh8];

	//Panning and adding crossfading bwteeen vowels.

	pan1=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-1,1);
	pan2=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.8,1);
	pan3=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.6,1);
	pan4=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.4,1);
	pan5=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.4,1);
	pan6=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.6,1);
	pan7=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.8,1);
	pan8=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,1,1);
	sig = pan1+pan2+pan3+pan4+pan5+pan6+pan7+pan8;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_sinBass, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, hpf4 = 50, curve = (-4), envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
	var sig, freqEnv;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve));
	sig = SinOsc.ar(freqEnv * freq, mul: globalEnv);
	//sig = HPF.ar(sig, 20);
	sig = BHiPass4.ar(sig, hpf4, 1, globalEnv);

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_feedBackos, { arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, fbPow = 0.999, baseFreq = 0.01, freq = 1, lpfFreq = 4000, doneAction = 2;
	var i, o;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	i = LocalIn.ar(2);
	i = i + ((1 + i) ** fbPow);
	o = DelayC.ar(i, 1, (SinOsc.ar(baseFreq / (1..8)).exprange * freq));
	o = LeakDC.ar(o);
	o = Splay.ar(o).tanh;
	LocalOut.ar(o);
	sig = LPF.ar(o, lpfFreq) * 1/5;
	sig = Pan2.ar(sig, pan, amp * globalEnv);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\Sd_nataskick, { arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, atk = 0.001, duration = 1, freq = 60, modfreqamt1 = 8, modfreqtime1 = 0.001, modfreqamt2 = 8, modfreqtime2 = 0.03, modfreqamt3 = 0.5, modfreqtime3 = 0.3, modfreqamt4 = 0.1, bpffreq1 = 8321, bpfrq1 = 0.3, bpffreq2 = 3321, bpfrq2 = 0.3, revtime = 1, earlyRef = 0.7, doneAction = 2;
	var snd, velocity;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	velocity = duration.linlin(1, 0, 1, 0);
	snd = SinOsc.ar(
		freq
		* (1 + (modfreqamt1 * Env.perc(0, modfreqtime1).ar * velocity))
		* (1 + (modfreqamt2 * Env.perc(0, modfreqtime2).ar * velocity))
		* (1 + (modfreqamt3 * Env.perc(0, modfreqtime3).ar * velocity))
		* ([1, -1] * modfreqamt4).midiratio
	);
	snd = snd * (1 + (Env.perc(0, 0.03).ar * velocity));
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), bpffreq1, bpfrq1) * Env.perc(0.001, 0.003).ar * 1.dbamp * velocity);
	snd = snd.tanh;
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), bpffreq2, bpfrq2) * Env.perc(0.03, 0.05).ar * -10.dbamp * velocity);
	snd = snd * velocity.sqrt;
	snd = snd + GVerb.ar(snd.sum * -30.dbamp, 30, revtime, earlyreflevel: earlyRef);
	snd = snd * Env.perc(atk, duration).ar;
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_chaosEngine, { arg out = 0, pan = 0, amp = 0.2, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, modPhaseFreq = 0.12345, modPhaseMul = 678, modPhaseAdd = 9, modAmpFreq = 101, modAmpMul = 0.2, modAmpAdd = 0.8, modOffsetFreq = 25, modOffsetWidth = 0.25, modOffsetMul = 0.125, modOffsetAdd = (-0.25), modFreqFreq = 50, freq = 10, doneAction = 2;

	var sig, modPhase, modAmp, modOffset, modFreq;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	modPhase = Saw.kr(modPhaseFreq, modPhaseMul, modPhaseAdd);
	modAmp = SinOsc.kr(modAmpFreq, modPhase, modAmpMul, modAmpAdd);
	modOffset = Pulse.kr([modOffsetFreq, modOffsetFreq + 0.5], modOffsetWidth, modOffsetMul, modOffsetAdd);
	modFreq = (modFreqFreq * SinOsc.kr([modFreqFreq, modFreqFreq + 1], 0, modAmp, modOffset));

	sig = SinOsc.ar(freq + modFreq, 0, 0.5);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_claudes, { arg out = 0, amp = 0.5, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 210, filtCutOff = 950, lpffreq = 2000, revMix = 0, dur = 0.16666666666667, doneAction = 2;
	var sig, num = 10;

	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(20).min(20000);

	sig = num.collect {
		var frq = freq * SinOsc.kr(LFNoise1.kr(dur).range(30, 1000), 0, LFNoise1.kr(dur).range(0.01, 8)).midiratio;
		var sig = Select.ar(LFNoise0.kr(dur).range(0, 2).round,
			[SinOsc.ar(frq, 0, 0.3), Saw.ar(frq, 0.3), Pulse.ar(frq, 0, 0.3)]);
		var filtFreq = filtCutOff.min(3000).max(1) * LFNoise1.kr(dur).range(1.0, 5.0);
		var filt = Select.ar(LFNoise0.kr(dur).range(0, 2).round,
			[LPF.ar(sig, filtFreq), HPF.ar(sig, filtFreq), BPF.ar(sig, filtFreq)]
		);
		sig = CombL.ar(filt, 0.5, LFNoise1.kr(dur).range(0.02, 0.5), rrand(0.3, 2));
		sig
	};

	sig = Splay.ar(sig); // nb! levelComp: true, so if removed signal will be extremely loud!
	sig = LPF.ar(sig, lpffreq);
	sig = FreeVerb2.ar(sig[0], sig[1], revMix.range(0, 1.0), LFNoise1.kr(dur).range(0.2, 2));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_sillyVoice, { arg out = 0, amp = 0.5, pan = 0,
	begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	freq = 220,
	vibratoSpeed = 6,
	vibratoDepth = 4,
	vwl = 0,
	lag = 1,
	doneAction = 2;

	var in, vibrato, va, ve, vi, vo, vu, snd;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
	in = Saw.ar(Lag.ar(freq, lag) + vibrato);

	va = BBandPass.ar(
		in: in,
		freq: [ 600, 1040, 2250, 2450, 2750 ],
		bw: [ 0.1, 0.067307692307692, 0.048888888888889, 0.048979591836735, 0.047272727272727 ],
		mul: [ 1, 0.44668359215096, 0.35481338923358, 0.35481338923358, 0.1 ]);

	ve = BBandPass.ar(
		in: in,
		freq: [ 400, 1620, 2400, 2800, 3100 ] ,
		bw: [ 0.1, 0.049382716049383, 0.041666666666667, 0.042857142857143, 0.038709677419355 ],
		mul: [ 1, 0.25118864315096, 0.35481338923358, 0.25118864315096, 0.12589254117942 ]);

	vi = BBandPass.ar(
		in: in,
		freq: [ 250, 1750, 2600, 3050, 3340 ] ,
		bw: [ 0.24, 0.051428571428571, 0.038461538461538, 0.039344262295082, 0.035928143712575 ],
		mul: [ 1, 0.031622776601684, 0.15848931924611, 0.079432823472428, 0.03981071705535 ] );

	vo = BBandPass.ar(
		in: in,
		freq:[ 400, 750, 2400, 2600, 2900 ] ,
		bw: [ 0.1, 0.10666666666667, 0.041666666666667, 0.046153846153846, 0.041379310344828 ],
		mul: [ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 ]);

	vu = BBandPass.ar(
		in: in,
		freq: [ 350, 600, 2400, 2675, 2950 ],
		bw: [ 0.11428571428571, 0.13333333333333, 0.041666666666667, 0.044859813084112, 0.040677966101695 ],
		mul: [ 1, 0.1, 0.025118864315096, 0.03981071705535, 0.015848931924611 ]);

	snd = SelectX.ar(Lag.kr(vwl, lag), [va, ve, vi, vo, vu]);
	snd = Mix.new(snd);
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_sf, {
	arg combDecTime = 0.87780169785023, filterFreq = [ 95.257843732834, 1092.9450431466, 2090.6322425604, 3088.3194419742, 4086.0066413879, 58.884483242035], verbMixLfoMul = 0.65344390869141, verbMixBase = 0.62439071655273, verbDamp = 0.49267339795828, filterRQ= 0.88423060178757, lfnFreq = 2.5169273328781,  amp = 0.1, verbRoom = 0.32687248945236, verbMixLfoFreq = 0.52672609329224,  combDelTime = 0.50482958555222, excitationLfoFreq = 4.6370942592621, mulEnd = 1.3822771310806, mulSlope = 87.377484935522, excitation = 2.8778329193592,tensionStart = 0.33643479049206, lossSlope = 49.668849676847, lossStart = 0.93807110734582, tensionEnd = 0.45843720436096, lossEnd = 0.75090856331253,addStart = 0.9387298822403, addEnd = 0.81052476167679, mulStart = 0.81965047121048, addSlope = 0.87180473804474, tensionSlope = 5.8839141070843, out = 0, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 10, freq = 440, doneAction = 2;

	var sig, src, q, mod;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	// thisThread.randSeed = 100000000;

	mod = MembraneCircle.ar(
		LFPulse.ar(excitationLfoFreq, 0.0, 0.5, excitation, excitation / 2),
		Phasor.kr(0.0, tensionSlope, tensionStart, tensionEnd, tensionEnd) ,
		Phasor.kr(0.0, lossSlope, lossStart, lossEnd, lossEnd),
		Phasor.kr(0.0, mulSlope, mulStart, mulEnd, mulEnd),
		Phasor.kr(0.0, addSlope, addStart, addEnd, addEnd)
	);

	src = { |int|
		RLPF.ar( // reprendre ici
			0.6 ** int * 40 * Impulse.ar(0), // input
			((4 ** LFCub.kr(
				( 1 / 16 + lfnFreq) // LFNoise0 freq
			) * 300 + filterFreq) * freq).max(20).min(14000), // freq
			((mod % -1) * filterRQ).max(0).min(2) // 5e-3 + (filterRQ * 0.025) // rq
		).sin * 2
	} ! 8;

	q = src * 0.125;

	sig = CombC.ar(
		q,
		maxdelaytime: 2,
		delaytime: combDelTime ,
		decaytime: combDecTime,
		mul: 1,
		add: 0.0
	);

	sig = sig + Ringz.ar(
		sig,
		Line.kr(20 * filterFreq, 80 * filterFreq, 1.5 * verbMixLfoFreq, 0.4) - mod, // filterFreq, //
		mod % 0.012,
		0.12
	);

	2.do {
		sig = FreeVerb2.ar(
			sig[0], // in1
			sig[1], // in2
			(verbMixBase + SinOsc.ar(verbMixLfoFreq, 0, verbMixLfoMul, verbMixLfoMul / 2)).linlin(0,2,0.1,0.9), // mix
			verbRoom, // room
			verbDamp // damp
		)
	};

	sig = Splay.ar(sig, 1);
	// sig = sig * amp * 0.25;
	sig = Limiter.ar(sig, 0.79, 0.25);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


// via https://web.archive.org/web/20191104212834/https://www.nada.kth.se/utbildning/grukth/exjobb/rapportlistor/2010/rapporter10/szabo_adam_10131.pdf
// 180224
// accelerate ne fonctionne pas?

SynthDef(\Sd_hoover, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, mix=0.75, detune = 0.75, freq = 523.3572, doneAction = 2;
	var detuneCurve, centerGain, sideGain, center, detuneFactor, freqs, side, sig, envLength, line, env, globalEnv;
	// var sig;

	envLength = sustain * (end - begin) / speed;
	line = Line.ar(begin, end, envLength, doneAction: doneAction);
	env = Env.asr;
	globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));

	detuneCurve = { |x|
		(10028.7312891634*x.pow(11)) -
		(50818.8652045924*x.pow(10)) +
		(111363.4808729368*x.pow(9)) -
		(138150.6761080548*x.pow(8)) +
		(106649.6679158292*x.pow(7)) -
		(53046.9642751875*x.pow(6)) +
		(17019.9518580080*x.pow(5)) -
		(3425.0836591318*x.pow(4)) +
		(404.2703938388*x.pow(3)) -
		(24.1878824391*x.pow(2)) +
		(0.6717417634*x) +
		0.0030115596
	};
	centerGain = { |x| (-0.55366 * x) + 0.99785 };
	sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

	center = LFSaw.ar(freq, Rand());

	detuneFactor = freq * detuneCurve.(detune);

	freqs = [
		(freq - (detuneFactor * 0.11002313)),
		(freq - (detuneFactor * 0.06288439)),
		(freq - (detuneFactor * 0.01952356)),
		// (freq + (detuneFactor * 0)),
		(freq + (detuneFactor * 0.01991221)),
		(freq + (detuneFactor * 0.06216538)),
		(freq + (detuneFactor * 0.10745242))
	];
	side = Mix.fill(6, { |n|
		LFSaw.ar(freqs[n], Rand(0, 2))
	});




	sig = (center * centerGain.(mix)) + (side * sideGain.(mix));

	sig = HPF.ar(sig ! 2, freq);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;

SynthDef(\Sd_kicklaserbeam, { arg out = 0, amp = 0.3, pan = 0.0, attack = 0.0001, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, release = 0.26, freq = 13007, freqenvL1 = 3.97, freqenvL2 = 5, freqenvL3 = 0, freqenvL4 = 2.97, freqenvT1 = 0.16, freqenvT2= 0.07, freqenvT3= 0.26, ampenvL1 = 1, ampenvL2 = 1, ampenvL3 = 0, ampenvL4 = 0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, clickAtk = 0, clickRls = 0.1, clickSus = 1, clickLevScale = 10, clickEnvPow = 1, clickEnvNoiseAmp = 0.4, clickEnvInv = 0, clickFreq = 820, clickAmp = 0.3, doneAction = 2;

	var sig, freqenv, ampenv, clickEnv;

	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3].normalizeSum));
	sig = LFTri.ar((freq * freqenv).max(20).min(16000), 0, ampenv);
	sig = BHiPass4.ar(sig, hpfFreq, hpfRq);

	clickEnv = EnvGen.ar(Env.perc(clickAtk, clickRls), levelScale: clickLevScale, timeScale: clickSus).pow(clickEnvPow) * PinkNoise.ar(clickEnvNoiseAmp).range(0.1, 1).lag(0.02);

	clickEnv = Select.ar(clickEnvInv, [clickEnv, clickEnv.neg]);

	sig = sig + HPF.ar(clickEnv, clickFreq, clickAmp);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;

SynthDef(\Sd_kickhi, { arg out = 0, amp = 0.3, pan = 0, sustain = 1, envPow = 1, vcaLev1 = 0.5, vcaLev2 = 0.1, vcaLev3 = 0.01, vcaLev4 = 0.01, vcaLev5 = 0, vcaTime1 = 0.01, vcaTime2 = 0.5, vcaTime3 = 1.26, vcaTime4 = 0.1, vcaCurve1 = (-4), vcaCurve2 = (-2), vcaCurve3 = (-4), vcfLev1 = 122, vcfLev2 = 30, vcfLev3 = 33, vcfLev4 = 28, vcfTime1 = 0.05, vcfTime2 = 0.29, vcfTime3 = 1, vcfCurve1 = (-4), vcfCurve2 = (-5), begin = 0, end = 1, speed = 1, accelerate = 0, freq = 60, tu = 1, sinLev = 16, doneAction = 2;
	var env0, env1, env1m, sig, globalEnv;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	globalEnv = IEnvGen.ar(env, line).pow(envPow);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	env0 =  EnvGen.ar(Env.new([vcaLev1, vcaLev2, vcaLev3, vcaLev4, vcaLev5], [vcaTime1, vcaTime2, vcaTime3, vcaTime4].normalizeSum * sustain, [vcaCurve1, vcaCurve2, vcaCurve3]));

	env1 = EnvGen.ar(Env.new([vcfLev1, vcfLev2, vcfLev3, vcfLev4], [vcfTime1, vcfTime2, vcfTime3].normalizeSum * sustain, [vcfCurve1, vcfCurve2]));

	env1m = env1.midicps;
	sig = LFPulse.ar(env1m * tu, 0, 0.5, 1, -0.5);
	sig = out + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m * 1.5, env0);
	sig = sig * 1.2;
	sig = sig.clip2(1);
	sig = sig + SinOsc.ar((env1m * tu + freq).max(20).min(16000), 0.5, env0 * sinLev);
	sig = LeakDC.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;



SynthDef(\Sd_IkedaBass, { arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 60, envL1 = 0.2, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, envCurve = 1, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, gate = 1, doneAction = 2;

	var sin, sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line).pow(envCurve.abs);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, timeScale: sustain, doneAction: doneAction);

	sin = SinOsc.ar(freq, (Sweep.ar(gate, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;



SynthDef(\Sd_kick2new,{arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, freq = 60, attack = 0.001, sustain = 1, release = 1.4, curve = (-4), envPow = 1, envfT1 = 0.002, envfT2 = 0.1, freqEnvStart = 100, tu = 1.33, bpeqf1 = 3081, bpeqrq1 = 0.71, bpeqamp1 = (-54), bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 81, gate = 1, doneAction = 2;

	var frequ, sig;

	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line).pow(envPow.abs);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	frequ = EnvGen.ar(Env([freq + freqEnvStart, freq, 31.4], [envfT1, envfT2]));
	sig = SinOsc.ar((frequ * tu).min(16000).max(20), 0);

	sig = BPeakEQ.ar(sig, bpeqf1, bpeqrq1, bpeqamp1);
	sig = BPeakEQ.ar(sig, bpeqf2, bpeqrq2, bpeqamp2);
	//sig = Limiter.ar(sig,0.5);
	sig = HPF.ar(sig, hpff);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_t1kick2, {arg
	out = 0, amp = 0.5, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 60, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = (-4), envfT1 = 0, envfL1 = 10000, envfT2 = 0.2, envfL2 = 20, envfT3 = 1, envfL3 = 0, envfT4 = 1.4, envfL4 = 4, envfCurve = (-4), pitch = 0.1, hpfFreq = 120, hpfRq = 1, envT1 = 0.012, envL1 = 0, envT2 = 0.0012, envL2 = 1, envT3 = 0.12, envL3 = 0.1, envCrv = (-4), envPow = 2, envInv = 0, lvlScale = 1, attFreq = 440, verbMix = 0.1, verbRoom = 0.1, verbDamp = 0.15, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), timeScale: sustain, doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve), doneAction: doneAction);
	// var sig = SinOsc.ar(envf+50*pitch, 0, enva);
	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = SinOsc.ar( envf * freq * pitch, 0, enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);


	sig = BHiPass4.ar(sig.distort, hpfFreq, hpfRq);
	sig = sig + HPF.ar(EnvGen.ar(Env.pairs([[envT1, envL1], [envT2, envL2], [envT3, envL3]], envCrv), levelScale: lvlScale).pow(envPow) * envInv.linlin(0, 1, 1, -1) * PinkNoise.ar(0.3!2).range( 0.1, 1 ).lag(0.01), attFreq);
	revSig = FreeVerb.ar(sig, verbMix, verbRoom.max(0.01), verbDamp);
	sig = SelectX.ar(verbMix, [sig, revSig]);
	// sig = Pan2.ar(sig, pan, amp*enva);
	// OffsetOut.ar(out, sig);
	sig = LeakDC.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;


SynthDef(\Sd_kickmed2, { |
	out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 60, attack = 0.001, release = 1.4, curve = (-4), envPow = 1, level = 0.5, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 0.2, env1L2 = 0.4, env1L3 = 0.0, env1T1 = 0.0001, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, doneAction = 2 |

	var globalEnv, env0, env1, env1m, sig, son2, son3, son4, p2;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;

	globalEnv = IEnvGen.ar(env, line);

	p2 = phase * (-pi);
	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	env0 = Env([env0L1, env0L2, env0L3, env0L4, 0],[atkEnv0, decEnv0, relEnv0, 0.05], [curve1, curve2, curve3]);
	env1 = Env([env1L1, env1L2, env1L3], [env1T1, env1T2], curve1);
	env0 = EnvGen.ar(env0);
	env1 = EnvGen.ar(env1).range(0.0, 2);
	freq = max(0, freq * speed * (1 + (accelerate * line)));

	// env1m = env1.midicps * freq;
	env1m = (env1 * freq).max(20).min(16000);
	sig = LFSaw.ar(env1m, 0, oamp, 1, 1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1, 1.4);
	son3 = LFPulse.ar(env1m, 0, oamp, 1, 1.4);
	son4 = LFTri.ar(env1m, 0, oamp, 1, 1.4);
	sig = SelectX.ar(ochoose.mod(5), [sig, son2, son3, son4]);
	sig = LeakDC.ar(sig,dc,30);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m * fratio.max(0.01), env0);
	sig = sig + SelectX.ar(owhich2.mod(5),[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	sig = sig * level.distort;
	// sig = Pan2.ar(sig, pan);
	// OffsetOut.ar(out, sig*level).tanh;
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp)).tanh;
}).add;

SynthDef(\Sd_so, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 10, freq = 1, verbMixLfo =  0.70107585787773, decTime4 = 13.907386982441, decTime1 = 6.9938727498055, lpfFreq = 3976, ringzFreq4 = 7890.3197827339, ringzFreq1 = 43.246298016335, ringzFreq2 = 96.466201484, ringzFreq3 = 9004.5744515777, decTime3 = 25.021273517609, verbRoomLfo = 2.9249746382236, verbRoom = 0.55860961675644, ringzMul = #[ 4, 8, 2, 7 ], dist = 1, decTime2 = 20.645671010017, verbMix = 0.33222706317902, decTimeDiv = 7, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);

	sig = Ringz.ar(
		Impulse.ar(0),
		([
			ringzFreq1,
			ringzFreq2,
			ringzFreq3,
			ringzFreq4
		] * freq).min(16000).max(20), // freq
		[
			decTime1,
			decTime2,
			decTime3,
			decTime4  // - Ndef.ar(\soMod1)
		] / decTimeDiv, // dec time 10,
		ringzMul * dist // mul
	).sin.sum.tanh ! 2;

	sig = LPF.ar(
		Mix.ar(sig) ,
		lpfFreq
	);

	sig = FreeVerb.ar(
		Mix.ar(sig),
		mix:   LFTri.kr(
			verbMixLfo, 0.0, verbMix, verbMix/2).linlin(0, 1 + verbMix, 0, 1),
		room:  LFPulse.kr(verbRoomLfo, 0.0, 0.5, verbRoom, verbRoom/2),
		damp:  0.15, // abs(SinOsc.kr(0.133)).linlin(0,1,0.15,0.75),
		// mul: 1.15,
		// add: 0.0
	);

	sig = Splay.ar(sig, 1);
	sig = HPF.ar(sig, 140);
	sig = sig * amp ;

	sig = Limiter.ar(sig, 0.5);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

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

)