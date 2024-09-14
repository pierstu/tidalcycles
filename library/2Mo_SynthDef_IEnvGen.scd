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

/// tonal pierre 0924

SynthDef(\Sd_fakeRes, {
	arg  out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440,
	peamount = 900,
	pitchAtt = 0.001, pitchDec = 0.13,
	ampAtt = 0.03, ampDec = 1.0, level = 0.5, doneAction = 2;

	var sig, sig1, sig2, ampenv, pitchenv, sig2Phase;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	pitchenv = EnvGen.ar(
		// Env([0, 1, 0], [pitchAtt, pitchDec], [0, 0])  // original
		Env([0, 1, 0], [pitchAtt, pitchDec],  \squared)
		// Env([0, 1, 0], [pitchAtt, pitchDec],  \cubed)
	);

	ampenv = EnvGen.ar(
		Env([0, 1, 0], [ampAtt, ampDec], [0, 0]),
		levelScale: level,
		timeScale: sustain,
		doneAction: doneAction
	);

	sig1 = SinOsc.ar(
		freq,
		mul: -0.53,
		add: 0.5
	);

	sig2Phase = Sweep.ar(sig1, (freq + (pitchenv * peamount)));

	sig2 = SinOsc.ar(
		freq + (pitchenv * peamount),
		phase: 2pi * sig2Phase
	);

	// sig = (sig1 * sig2)**2;  // orig
	// sig = (sig1 * sig2).pow(2);  // same sound as orig
	sig = (sig1 * sig2).squared;  // sounds different

	sig = OnePole.ar(sig, -0.22); // added
	sig = sig * ampenv;
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_ambitek, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,  freq = 440,  envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4),  delTime = 0.1, delDecay = 2, brfRq = 2, doneAction = 2;
	var sig, envS;
	// env = Linen.kr(gate, attack, 1, release, doneAction);
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));

	envS = EnvGen.kr(Env([envSL1, envSL2, envSL3, envSL4], [envST1, envST2, envST3], envSCurve));
	sig = Saw.ar(freq * envS);
	2.do{|i|
		var f = 2 ** (8 - i);
		sig = BRF.ar(
			AllpassN.ar(sig, 1, Lag2.kr(delTime, 0.2) / (12 - i), delDecay),
			Lag2.ar(80 ** TRand.ar(0, 1, Impulse.ar(f / 32, 1/2)).lag(1 / f) * 80, 0.5),
			brfRq
		);
	};
	sig = Limiter.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_danUk, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, attack = 0.0, sustain = 1, release = 1.0,
	curve = (-4), envPow = 1, globalEnvNoise = 0.3, globalEnvInv = 0, freq = 50, r = 12, doneAction = 2;
	var phi, x, y,  envShape;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	envShape = [attack, release].normalizeSum * sustain;
	// globalEnv = EnvGen.kr(Env.perc(envShape[0], envShape[1], 1, curve), doneAction: doneAction).pow(envPow);
	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range([0.1, 0.12], [1, 1.02]).lag(0.02);

	globalEnv = Select.ar(globalEnvInv.wrap(0, 1).round, [globalEnv, globalEnv.neg]);

	phi = LFSaw.ar([freq, freq + 0.1], -1).range(0, 2pi);
	x = r * cos(phi);
	y = r * sin(phi);
	sig = sin(x) - (sin(y) * log(x * x + 1)) / 10;
	sig = Limiter.ar(sig * globalEnv, 0.2);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * amp, ~dirt.numChannels, pan));
}).add;



SynthDef(\Sd_markSamFell,{ arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 12,
	trigSpeed = 15, harm1 = 0, harm2 = 2, harm3 = 3, harm4 = 5, harm5 = 7, harm6 = 9, harm7 = 10, plkDec = 1.9, plkCoeff = 0.15, filterFreq = 3060, doneAction = 2;
	var trig, sig, freqs;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	thisThread.randSeed = 1000;
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(20).min(2000);

	// trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, trigSpeedMin, trigSpeedMax));
	trig = Impulse.ar(trigSpeed);
	freqs = (freq + [harm1, harm2, harm3, harm4, harm5, harm6, harm7]).midicps;
	// sig = Pluck.ar(Hasher.ar(Sweep.ar(trig)) * -10.dbamp, trig, freqs.reciprocal, freqs.reciprocal, plkDec, plkCoeff.min(1).max(-1));
	sig = Pluck.ar(trig , trig, freqs.reciprocal, freqs.reciprocal, plkDec, plkCoeff.min(1).max(-1));
	sig = LeakDC.ar(sig).sum;
	sig = MoogFF.ar(sig, filterFreq);
	/*sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_gabor, { arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 1, sustain = 1,
	freq = 14, doneAction = 2;

	var trig = \trig.tr;

	var freqEnv = EnvGen.kr(Env([1,2,1], [0.75, 0.01], \lin), trig);
	var fltEnv = EnvGen.kr(Env([0.0125,1,0.025], [\fAtk.kr(0.1), \fRel.kr(0.1)], \exp), trig);


	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	var cutoff, amps, sig, numPartials, partials, freqs;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	numPartials = 40;
	partials = (1..numPartials);
	freqs = freq * (partials + (partials * partials * 0.01));

	cutoff = fltEnv * \fltRange.kr(16000);

	amps = (
		(freqs.log2 - cutoff.log2).squared
		* \slope.kr(-5)
	).dbamp;

	sig = SinOsc.ar(freqs * freqEnv.midiratio, 0, amps).sum * -15.dbamp;

	/*sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_additiveGabor, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
freq = 140,
	index=1, iScale=3, time=1, doneAction = 2;

	var numPartials = 40;
	var bufAmps = LocalBuf(numPartials, 1);
	// var f0 = \freq.kr(68);
	var sig, mod;

	var iEnv = EnvGen.kr(Env([index, index * iScale, index], [\iAtk.kr(0.2), \iRel.kr(0.5)], \lin), timeScale: time);
	// var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	BufWr.ar(
		LFGauss.ar(
			duration: SampleDur.ir * numPartials * \factor.kr(1, 0.5).reciprocal,
			width: \width.kr(0.2, 0.5),
			iphase: LFTri.ar(\phaseModFreq.kr(0.5)).linexp(-1, 1, 1, 2),
		),
		bufnum: bufAmps,
		phase: Phasor.ar(end: numPartials)
	);

	mod = SinOsc.ar(freq * \mRatio.kr(1), mul: iEnv);

	sig = Array.fill(numPartials, {|int|
		var freqs, partials;
		freqs = freq * (int + (int * int * 0.05));
		partials = SinOsc.ar(
			freq: freqs * \cRatio.kr(1),
			phase: mod.wrap(0, 4pi),
			mul: Index.ar(bufAmps, int)
		) / numPartials;
	}).sum;

	sig = LeakDC.ar(sig);


	/*sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_tonic, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	oscfreq=50, lfofreq=200, lfoamount=0, penvamount=200, decaycurve=(-5), patt=0.001, pdec=0.200, shamount=0, shrate=3, ampatt=0.001, ampdec=0.7, ampdecaycurve=(-5), oscwaveform=1, noiseatt=0.001, noisedec=0.164, noiseamp=0.6, mixfade=0, nfiltfreq=1800, noisereso=0.2, noisefiltselect=0, drive=2, doneAction=2 ;
	var sin,tri,saw,lfo,modsh,penv,ampenv,sh,sig,noisesig,noiseenv,noisesigbp,noisesighp,noisesiglp;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	oscfreq = max(0, oscfreq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	noisesig = WhiteNoise.ar * noiseamp;
	noiseenv = EnvGen.ar(Env([0,1,0],[noiseatt,noisedec],[0,-5]));
	noisesig = noisesig * noiseenv;
	noisesigbp = BPF.ar(noisesig, nfiltfreq, rq:noisereso);
	noisesighp = RHPF.ar(noisesig, nfiltfreq, rq:noisereso);
	noisesiglp = RLPF.ar(noisesig, nfiltfreq, rq:noisereso);
	noisesig = Select.ar(noisefiltselect,[noisesigbp, noisesighp, noisesiglp]);
	sh = LFNoise0.ar(shrate) * shamount;
	penv = EnvGen.ar(Env([0,1,0], [patt,pdec], [0,decaycurve]), doneAction:0) * penvamount;
	ampenv = EnvGen.ar(Env([0,1,0], [ampatt,ampdec], [0,ampdecaycurve]));
	lfo = SinOsc.ar(lfofreq) * lfoamount;
	sin = SinOsc.ar(oscfreq + penv + lfo + sh) * ampenv;
	tri = LFTri.ar(oscfreq + penv + lfo + sh) * ampenv;
	saw = LFSaw.ar(oscfreq + penv + lfo + sh) * ampenv;
	sig = Select.ar(oscwaveform, [sin, tri, saw]);
	sig = XFade2.ar(sig, noisesig, pan:mixfade);
	sig = ((sig) * drive).tanh;
	// signal=Pan2.ar(signal,pos:pan)*amp;
	// OffsetOut.ar(out,signal);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;


SynthDef(\Sd_dx11algo3, { //v3-->v2-->v1<--v4
	arg  out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 90, feedback = 1.83, doneAction = 2;

	var allArguments = (
		\atk:  [\op1att.kr(0.001), \op2att.kr(0.001), \op3att.kr(0.001), \op4att.kr(0.001)],  // \atk.kr(0.00!4), or like this?
		\dec:  [\op1dec.kr(0.4),   \op2dec.kr(3.25),  \op3dec.kr(0.15),  \op4dec.kr(1.25)],   // \dec.kr(0.1!4),
		\sus:  [\op1sus.kr(0.01),  \op2sus.kr(0.1),   \op3sus.kr(0.1),   \op4sus.kr(0.1)],    // \sus.kr(0.1!4)
		\rel:  [\op1rel.kr(0.1),   \op2rel.kr(0.1),   \op3rel.kr(0.1),   \op4rel.kr(0.1)],    // \rel.kr(0.1!4),
		\amt:  [\op1amt.kr(1),     \op2amt.kr(4),     \op3amt.kr(2),     \op4amt.kr(2)],      // \amt.kr(2!4),
		\tune: [\op1tune.kr(0),    \op2tune.kr(12),   \op3tune.kr(0),    \op4tune.kr(0)]      // \tune.kr(2!4)
	);
	var voice1 = allArguments.collect{|a| a[0] };
	var voice2 = allArguments.collect{|a| a[1] };
	var voice3 = allArguments.collect{|a| a[2] };
	var voice4 = allArguments.collect{|a| a[3] };

	// var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	var mk_env = {
		|voice, done_action|
		EnvGen.ar(Env.adsr(voice[\atk], voice[\dec], voice[\sus], voice[\rel]), doneAction: done_action ? 0)
	};
	var mk_freq = {
		|voice|
		// (\pitch.kr(48) + voice[\tune]).midicps
		(freq + voice[\tune])
	};

	var env3 = mk_env.(voice3);
	var v3 = SinOsc.ar(mk_freq.(voice3)) * env3 * voice3[\amt];

	var env2 = mk_env.(voice2);
	var v2 = SinOsc.ar(mk_freq.(voice2), v3) * env2 * voice2[\amt];

	var env4 = mk_env.(voice4);
	var v4 = SinOscFB.ar(mk_freq.(voice4), env4 * feedback) * env4 * voice4[\amt];

	var env1 = mk_env.(voice1);

	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	mk_freq = max(0, mk_freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	sig = SinOsc.ar(mk_freq.(voice1), v2 + v4) * env1 * voice1[\amt];

	// var final = Pan2.ar(v1 * amp, pos: pan);
	//OffsetOut.ar(out, final);globalEnv
	sig = Limiter.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;


SynthDef(\Sd_sqwer, {
	| out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	freq = 58, filteramount = 600, filterfreq = 800, res = 0.21,
	ampattack = 0.001, ampdecay = 1, filtattack = 0.01, filtdecay = 0.500, osc1amp = 0.3, osc2amp = 0.3, osc3amp = 0.3, offset1 = -24, offset2 = -0.3, offset3 = 0.1, lp = 1, bp = 0, hp = 0,  fsh = 3, mixfade = 0, doneAction = 2 |
	var sig, sig1, sig2, sig3, ampenvelope, filterenvelope;
	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	filterenvelope = EnvGen.ar(Env([0, 1, 0], [filtattack, filtdecay], [0, -5]), doneAction: 0);
	ampenvelope = EnvGen.ar(Env([0, 1, 0], [ampattack, ampdecay], [0, -5]), doneAction: doneAction);

	sig1 = Pulse.ar((freq * (offset1.midicps)), mul: osc1amp);
	sig2 = Pulse.ar((freq * (offset2.midicps) ), mul: osc2amp);
	sig3 = Pulse.ar((freq * (offset3.midicps) ), mul: osc3amp);

	sig = sig1 + sig2 + sig3;
	sig = SVF.ar(sig, (filterfreq + (filterenvelope * filteramount)).clip(20, 20000), lowpass: lp, bandpass: bp, highpass: hp, res: res);
	sig = sig * ampenvelope;
	sig = XFade2.ar(sig, FreqShift.ar(sig, fsh), pan: mixfade);
	/*sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * globalEnv));
}).add;


SynthDef(\Sd_lazaer, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;

	var lpfEnv, gainEnv;
	var cutoff, tension, tilt, lpf, peakEQ;
	var sig, freqs, numPartials, spectrum;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);


	numPartials = 64;
	spectrum = (1..numPartials);


	lpfEnv = EnvGen.kr(Env(
		[0, 1, 0],
		[\fltAtk.kr(0.10), \fltRls.kr(0.90)],
		[\fltAtkCurve.kr(4.0), \fltRlsCurve.kr(-8.0)]
	));

	gainEnv = EnvGen.ar(Env(
		[0, 1, 0],
		[\atk.kr(0.01), \rls.kr(0.99)],
		[\atkCurve.kr(4.0), \rlsCurve.kr(-4.0)]
	), doneAction: doneAction);

	// harmonic tension
	tension = (1 + (spectrum * spectrum * \inharmonic.kr(0.01))).sqrt;

	// frequency spectrum
	// freqs = \frq.kr(103.826) * spectrum * tension;
	freqs = freq * spectrum * tension;
	sig = SinOsc.ar(freqs, { Rand(0, 2pi) } ! numPartials);

	// 3db/octave spectral tilt
	tilt = (log2(spectrum) * \tilt.kr(-3)).dbamp;

	// LPF
	cutoff = \lpfCutoff.kr(100) + lpfEnv.linlin(0, 1, 0, \lpfEnvAmount.kr(8000));
	lpf = ((log2(freqs) - log2(cutoff)) * \lpfSlope.kr(-12)).min(0).dbamp;

	// Peak EQ
	peakEQ = ((log2(freqs) - log2(cutoff)).abs * \peakSlope.kr(-12) + \peakRes.kr(24)).max(0).dbamp;

	sig = (sig * tilt * lpf * peakEQ).sum;

	sig = sig * gainEnv * amp;

	/*sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp ));
}).add;

//




SynthDef(\Sd_neurosnare, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, freq = 60,
	curve = -4, preamp = 1.4,
	//Click Controls
	clickatt = 0.001, clicksus = 0.01, clickrel = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
	//Body Controls
	bodyatt = 0.04, bodyrel = 0.2, bodyamp = 2,
	//Rattle Controls
	rattlehold = 0.01, rattleatt = 0.05, rattlerel = 0.2, rattleamp = 0.7, rattlefreq = 400, rq = 0.15, rattlepeak = 3,
	//Sweep Controls
	sweepatt = 0.001, sweeprel = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500, sustain = 1,
	doneAction = 2;

	var sig, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));


	// a percussive click to give it some attack
	cEnv = Env.linen(
		attackTime: clickatt,
		sustainTime: clicksus,
		releaseTime: clickrel,
		level: clickamp
	).ar;

	click = Hasher.ar(Sweep.ar);

	click = HPF.ar(in: click, freq: hipass);

	click = LPF.ar(in: click, freq: lopass);

	click = click * cEnv;

	// sine sweep body
	bEnvFreq = Env.new(
		levels: [2.5, 1.225, 1],
		times: [bodyatt, bodyrel],
		curve: \exp
	).ar;

	bEnvAmp = Env.perc(
		attackTime: bodyatt,
		releaseTime: bodyrel,
		level: bodyamp,
		curve: curve
	).ar;

	body = SinOsc.ar(freq: freq * bEnvFreq, mul: bEnvAmp);

	body = body.tanh;

	// sound of snare coils rattling
	rEnv = Env.perc(
		attackTime: rattleatt,
		releaseTime: rattlerel,
		level: rattleamp,
		curve: curve
	).delay(rattlehold).ar;

	rattle = Hasher.ar(Sweep.ar);

	rattle = BPeakEQ.ar(in: rattle, freq: rattlefreq, rq: rq, db: rattlepeak);

	rattle = HPF.ar(in: rattle, freq: hipass);

	rattle = rattle * rEnv;

	// another sound sweep to improve the attack, optional
	sEnvFreq = XLine.kr(
		start: sweepstart,
		end: sweepend,
		dur: sweeprel / 2
	);

	sEnvAmp = Env.perc(
		attackTime: sweepatt,
		releaseTime: sweeprel,
		level: sweepamp,
		curve: curve
	).ar;

	sweep = SinOsc.ar(freq: sEnvFreq, mul: sEnvAmp);

	// distortion helps glue everything together and acts as a compressor
	sig = Mix.ar(click + body + rattle + sweep);

	sig = (sig * preamp).tanh * amp;

	// DetectSilence.ar(in: snd, doneAction: doneAction);
	// sig = sig * EnvGen.kr(Env.perc(0, sustain), doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(sig, pan));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;


SynthDef(\Sd_circSegs, { arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 140,
	segments = 39, xMajor = 10.0, yMajor = 1.0, rMajor = 100.1, rMinor = 1.1, circlefreq = 0.021, doneAction = 2;
	var sig, xMinor, yMinor, freqs, amps, phase, shuheiKawachi;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	shuheiKawachi = { arg x, y, a, b;
		((cos(x) * cos(y))
			+ (cos((sqrt(a) * x - y) / b)
				* cos((x + (sqrt(a) * y) ) / b))
			+ (cos(( sqrt(a) * x + y) /b)
				* cos((x - (sqrt(a) * y*y)) / b)))/3;
	};


	freqs = freq * [ 0.11570247597776, 0.144564800894, 0.14785564761272, 0.15451234714171, 0.15556648803344, 0.16171468818528, 0.17080264242479, 0.18217975122767, 0.20147819491099, 0.20282833440148, 0.20406306776099, 0.21546436067452, 0.22085086527343, 0.23651387138061, 0.23996077107573, 0.24024656336116, 0.26851735008425, 0.2779626793712, 0.28616771659557, 0.31408888912011, 0.35706702211027, 0.44101942638255, 0.45172822345566, 0.45192677257273, 0.4589093850173, 0.52286876256048, 0.54018444140557, 0.66076973168793, 0.66679435434973, 0.76435070264518, 0.77707981729464, 0.79412992736159, 0.89454197094502, 0.93021514533318, 0.93982794977273, 0.96626773775473, 1.05887479471, 1.1199233890697, 1.2498103591333, 1.465983831025, 1.5928947558493, 1.6135547675467, 1.6294681644635, 1.9169480096232, 2.0414366199636, 2.3280828523657, 2.4489509565095, 2.5516314245259, 3.082880535347 ];


	phase = #[0.0]!49;
	//phase = Array.rand(49, 0, 2*pi);
	amps = Array.new;
	xMinor = xMajor + (rMajor * SinOsc.ar(circlefreq));
	yMinor = yMajor + (rMajor * SinOsc.ar(circlefreq, pi/2));
	amps = Array.fill(49,
		{
			arg seg;
			var x = xMinor + (rMinor * sin(seg*2*pi/segments));
			var y = yMinor + (rMinor * cos(seg*2*pi/segments));
			var grey = abs(shuheiKawachi.(x, y, 2*pi, 0.5))/12;
			grey
		}
	);
	sig = DynKlang.ar(`[freqs, amps, phase]);
	/*sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig * globalEnv);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * globalEnv));
}).add;


SynthDef(\Sd_easelDeter, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 1, sustain = 1, freq = 150,
	lfRate = 3.7, lfPhase = (-4), selSnd = 1,  doneAction = 2;
	var sig, numInputs, numOutputs;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	numInputs = 6;
	numOutputs = 5;
	sig = LocalIn.ar(numOutputs);


	// Matrix-vector multiplication using multichannel expansion.
	sig = sig * ({arg j;
		{ arg i;
			var offset = i;
			if(i.odd, { offset = i.neg; });
			LFGauss.ar((lfRate + (offset * j)).reciprocal, 0.1, (i + j + lfPhase.round) * pi).round;
		} ! numInputs
	} ! numOutputs);

	sig = sig.sum;

	// If additional modules are added, remember to update numInputs and numOutputs.
	// numInputs should equal the maximum i in sig[i], plus one.
	// numOutputs should equal the number of entries in the sig array.
	sig = [
		// Oscillator that reaches LFO range
		SinOsc.ar(sig[0].linexp(-1, 1, 0.1, freq)),
		// Oscillator in audio range only
		// SinOsc.ar(sig[4].linexp(-1, 1, 100, 8000)),
		SinOsc.ar(sig[4].linexp(-1,1,freq,12000)),
		// Wavefolder with controllable gain
		(sig[2] * sig[3].linexp(-1, 1, 1, 8)).fold2,
		// Two filters with controllable cutoff and resonance
		// MoogFF.ar(sig[4], sig[5].linexp(-1, 1, 10, 8000), sig[0].linlin(-1, 1, 0, 4)) * 3.dbamp,
		MoogFF.ar(
			sig[4],
			sig[5].linexp(-1, 1, freq, 16000),
			sig[0].linlin(-1, 1, 0, 4)
		) ,
		// MoogFF.ar(sig[1], sig[2].linexp(-1, 1, 10, 8000), sig[3].linlin(-1, 1, 0, 4)) * 3.dbamp,
		MoogFF.ar(
			sig[1],
			sig[2].linexp(-1, 1, freq, 16000),
			sig[3].linlin(-1, 1, 0, 4)
		)
		// FreeVerb.ar(sig[0], mix: 1),
		// Five-step sequencer
		// Demand.ar(Impulse.ar(sig[5].linexp(-1, 1, 0.1, 1000)), 0, Dseq([0.1, 0.5, 0.9, 0.3, 0.4]))
	];

	if(sig.size != numOutputs) {
		Error("Please ensure numOutputs matches number of modules").throw;
	};
	sig = Sanitize.ar(sig);
	LocalOut.ar(sig);

	sig = Select.ar(selSnd.mod(7), sig ++ sig.sum);

	sig = Limiter.ar(LeakDC.ar(sig));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_ulysse42, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	freq = 124,
	mod1 = 0.2, mod2 = 0.71, width = 1, doneAction = 2;
	var sig, sig1, sig2, sig3, z1, z2, sinFrq;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	freq = freq.explin(20, 20000, 0.01, 2); // .max(0.01).min(2);



	mod1 = mod1.linlin(0, 1, -10, 10);
	sig1 = LFSaw.kr(0.062).range(-10, 10);
	sig1 = sig1 + (mod2.linlin(0, 1, 0, 5) * (0..8));
	sig2 = sig1.frac;
	sig3 = 0.8 - sig2.moddif(0.5, 1);

	z1 = gcd(sig1, mod1) + sig2;
	z2 = lcm(sig1, mod1) + sig2;
	sinFrq = (120 * ([z1, z2].flop.abs + 1));

	// sinFrq = Mix.ar(sinFrq);
	// sinFrq = Splay.ar(sinFrq);

	sig = (SinOsc.ar(sinFrq * freq) * AmpComp.kr(sinFrq) * sig3).mean;
	sig = Splay.ar(sig, width);
	// sig = Pan2.ar(sig * env, pan, amp);
	// sig = Mix.ar(sig);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_mutantFric, { arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0,
	spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, freq = 50, spring = 0.414, damp = 0.313, beltmass = 1, source = 0, hpfFreq = 150, gate = 1, sustain = 1, doneAction = 2;

	var friction, sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);


	friction = Array.fill(5, {
		[spec1.max(0.00001), spec2.max(0.03)].asSpec.map(LFNoise2.kr(noiseFreq))
	});
	sig = Select.ar(source, [
		LFTri.ar(freq),
		LFPar.ar(freq),
		LFCub.ar(freq),
		LFSaw.ar(freq),
		LFDNoise3.ar(freq),
		LFDNoise0.ar(freq)
	]);
	sig = Friction.ar(sig, friction, Lag2.kr(spring), damp, friction*30000, beltmass);
	sig = HPF.ar(sig, hpfFreq);
	sig = Limiter.ar(sig, 0.5);
	// OffsetOut.ar(out, Splay.ar(sig * amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig * globalEnv), ~dirt.numChannels, pan, amp));
}).add;



SynthDef(\Sd_natwich, { arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	modFreq = 0.4, modAmount = 0.8, freq = 40, rlpfFreq = 4000, rlpfRq = 0.21, doneAction = 2;
	var snd, fb, sig, mod1, mod2;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	// freq = freq.explin(20,16000,0.1,2);


	mod1 = LFDNoise3.kr(modFreq, modAmount).range(0.1, 1.5);
	mod2 = LFDNoise0.kr(modFreq, modAmount).range(0.1, 1.5);

	fb = LocalIn.ar(1);
	// snd = Saw.ar(freq * mod1 * (fb * 48).midiratio);
	snd = Saw.ar(freq * mod1 * (fb * 1.2).midiratio);
	// snd = RLPF.ar(snd, rlpfFreq * mod2 * (48 * (1 - fb)).midiratio, rlpfRq);
	snd = RLPF.ar(snd, rlpfFreq * mod2 * (1.2 * (1 - fb)).midiratio, rlpfRq);
	// snd = (snd * 3).fold2;
	snd = (snd * 4).fold2;
	sig = snd;
	snd = Amplitude.ar(ToggleFF.ar(PulseDivider.ar(snd, 3 * (1 + (100 * fb)))), 0.03, 0.3);
	LocalOut.ar(snd);
	snd = Pan2.ar(sig, pan) * amp * globalEnv;
	snd = Sanitize.ar(snd);
	snd = snd + (NHHall.ar(snd, 3) * -10.dbamp);

	// OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_clapping, {arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	envNoiseVol = 0, noiseAmp = 1, freq = 1120, rq=0.91, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 1400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, doneAction=2;
	var sig, noise, hpf1, hpf2, fx;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	lpfFreq = max(0, lpfFreq * speed * (1 + (accelerate * line)));
	hpfFreq = max(0, hpfFreq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	// freq = freq.explin(20, 20000, 0.01, 2); // .max(0.01).min(2);



	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([freq/2,freq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
	hpf1 = RLPF.ar(noise, lpfFreq, rq);
	hpf2 = RHPF.ar(noise, hpfFreq, rq/4);

	sig = Mix.ar(hpf1 + hpf2) * globalEnv;
	fx = CombC.ar(sig, 0.5, delTimeL, delDecL)+CombC.ar(sig, 0.5, delTimeR, delDecR);
	sig = (sig * (1 - delMix)) + (fx * delMix) ;
	sig = Limiter.ar(sig);
	// DetectSilence.ar(sig, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_cymbalicMcld, { |out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	attLowf = 0.5, relLowf = 5, lowNoiseLev = 0.1, attHif = 1, relHif = 3, hiNoiseLev = 0.1, attHi = 1, relHi = 2, hiLev = 0.25, attTh = 0.001, relTh = 0.001, freq = 440, doneAction = 2|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, freq1, freq2, freq3, freq4, res, thwack, sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	locutoffenv = EnvGen.kr(Env.perc(attLowf, relLowf)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, relHif)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
	hidriver = hidriver * EnvGen.kr(Env.perc(attHi, relHi, hiLev));

	thwack = EnvGen.kr(Env.perc(attTh,relTh));

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	//freqs  = {exprand(300, 20000)}.dup(100);
	freq1 = freq * 1.425;
	freq2 = freq * 6.729;
	freq3 = freq * 17.78;
	freq4 = freq * 1.08;
	freqs = [freq1, freq2, freq3, freq4] /** LFNoise2.kr(0.002, 0.5, 0.5)*/;

	res = Ringz.ar(
		lodriver + hidriver + thwack,
		freqs
	).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	sig = sig * 0.5;
	sig = Limiter.ar(sig, 0.75);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_cymbal808ryan, { arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 0.5, accelerate = 0, sustain = 1,
	freq = 300, penvL1 = 1.0, penvL2 = 0.6, ptime = 50, pcurve = (-8.5), pulsew = 0.55, rlpfFrq = 7000, rlpfRq = 0.16, rhpfFrq = 6800, rhpfRq = 1.15, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envL5 = 0, envT1 = 2, envT2 = 250, envT3 = 50, envT4 = 500, envC1 = 0, envC2 = (-0.5), envC3 = 0, envC4 = (-50), doneAction = 2;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	var sig, pulseEnv, freqs;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freqs = [freq, freq*1.3420, freq*1.2312, freq*1.6532, freq*1.9523, freq*2.1523];
	// freq = freq.max(0.01).min(2);

	//var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
	//var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
	//var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	pulseEnv = EnvGen.kr(Env.new([penvL1, penvL2], [ptime], [pcurve]), timeScale:(1/1000));
	sig = Mix.new(LFPulse.ar(freqs * 4.09));
	sig = (BinaryOpUGen('==', sig, 6.0) * 0.6) + (BinaryOpUGen('==', sig, 2.0) * 0.2) + (BinaryOpUGen('==', sig, 1.0) * 0.9); // XOR
	sig = (sig * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width: pulsew)) * 0.9);
	sig = RLPF.ar(sig, rlpfFrq, rlpfRq);
	sig = RHPF.ar(sig, rhpfFrq, rhpfRq);
	sig = sig * EnvGen.kr(Env.new([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum, [envC1, envC2, envC3, envC4]), timeScale: sustain); // (1/1000));
	// sig = [signal, DelayN.ar(signal, 0.005, 0.005)];
	// OffsetOut.ar(out, signal*4*amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;



SynthDef(\Sd_attBreath, { arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	seqv1 = 0.4, seqv2 = 0.1, seqv3 = 0.8, seqv4 = 2, seqv5 = 4, seqFreq = 200.0512, freqMin = 150, freqMax = 800, bwrMod = 0.15, gate = 1,
	doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, timeScale: sustain, doneAction: doneAction);
	// env = Linen.kr(gate, attack, 1, release, doneAction);

	seqFreq = max(0, seqFreq * speed * (1 + (accelerate * line)));
	// seqFreq = seqFreq.explin(20, 20000, 30, 1900); // .max(0.01).min(2);

	freqMin = max(0, freqMin * speed * (1 + (accelerate * line)));
	// freqMin = freqMin.explin(20, 20000, 30, 1900); // .max(0.01).min(2);
	freqMax = max(0, freqMax * speed * (1 + (accelerate * line)));
	// freqMax = freqMax.explin(20, 20000, 30, 1900); // .max(0.01).min(2);
	// freq = freq.max(0.01).min(2);

	sig = TDuty.kr(Dseq([seqv1, seqv2, seqv3, seqv4, seqv5] / seqFreq, inf), doneAction: doneAction);
	sig = Resonz.ar(
		Crackle.ar(sig.range(0.6, 1.6))!2,
		Demand.kr(sig, 0, Dseq([freqMin, freqMax], inf)),
		Demand.kr(sig, 0, Dwhite(0.01,0.5, inf)) * bwrMod
	);
	// sig = sig * env;
	// sig = Compander.ar(sig, sig, 0.4, 1, 1/3);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

// freq ne fonctionne pas, accellerate et speed ok
SynthDef(\Sd_kickey,{ arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1000,
	startFreq = 60, startFreqMod = 6, endFreq = 10, endFreqMod = 3, linedur = 0.8, decay = 0.8, lowpass = 500, rq = 1, sat = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, doneAction = 2;
	var sig;

	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	// freq = XLine.kr(PinkNoise.kr(startFreqMod, startFreq), PinkNoise.kr(endFreqMod, endFreq), linedur, 1, 0);
	freq = XLine.kr(LFSaw.kr(startFreqMod, startFreq), LFSaw.kr(endFreqMod, endFreq), linedur, 1, 0);
	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
	sig = sig * sat;

	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * globalEnv;
	sig = LeakDC.ar(sig);
	sig = Limiter.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;


SynthDef(\Sd_liljedMyst, { arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	pNoiseFreq = 0.5, hpfFreq = 190, modDur = 9, lfnFreq = 10.5, ringFreq = 155, ringDec = 0.2, revTime = 0.99, gate = 1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	ringFreq = max(0, ringFreq * speed * (1 + (accelerate * line)));
	hpfFreq = max(0, hpfFreq * speed * (1 + (accelerate * line)));
	// pNoiseFreq = max(0, pNoiseFreq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	thisThread.randSeed = 1000;

	sig = HPF.ar(PinkNoise.ar(pNoiseFreq), hpfFreq) * Line.kr(0, 1, modDur);
	sig = GVerb.ar(
		({ |i|
			Ringz.ar(
				sig * LFNoise1.kr(lfnFreq + 0.1.rand),
				ringFreq * i + 60,
				ringDec
			)
		}!24).sum,
		2,
		revTime
	).tanh;
	sig = sig * globalEnv * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_additiveSin, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 44,
	sampleRate = 44100, doneAction = 2;

	var sig, buffAmp, numPartials = 50;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	buffAmp = LocalBuf(numPartials);

	BufWr.ar(
		LFGauss.ar(
			duration: sampleRate.reciprocal * numPartials / \factor.kr(1, 0.5),
			width: \width.kr(0.2, 0.5),
			iphase: \phase.kr(0, 0.5).mod(4)
		),
		bufnum: buffAmp,
		phase: Phasor.ar(
			end: numPartials
		)
	);

	sig = Mix.fill(numPartials, {
		arg i;
		SinOsc.ar(
			//Odd harmonics
			// freq: ((i * 2) + 1) * \fund.kr(120, 0.5),
			freq: ((i * 2) + 1) * freq,
			//The i-th value of ~buffer_amplitudes is read with an Index Ugen
			mul: Index.ar(buffAmp, i)
		) / numPartials
	});

	/*sig = Pan2.ar(sig * globalEnv, pan, amp);

	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_sosTom, { arg
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, curve = -6,
	atk = 0.005, drumRel = 0.4, stickRel = 0.01, drumModeAmp = 0.25, freq = 250, timbreIndex = 0.77, clickAtk = 0, clickRls = 0.2, clickSus = 1, clickLevScale = 5, clickEnvPow = 1, clickEnvNoiseAmp = 0.3, clickFreq = 224, clickAmp = 0.5, doneAction = 2;

	var drumMode, drumModeEnv, stick, stickEnv, sig, clickEnv;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));


	clickEnv = EnvGen.ar(Env.perc(clickAtk, clickRls), levelScale: clickLevScale, timeScale: clickSus).pow(clickEnvPow) * PinkNoise.ar(clickEnvNoiseAmp).range(0.1, 1).lag(0.02);

	drumModeEnv = Env.perc(
		attackTime: atk,
		releaseTime: drumRel,
		level: 0.5,
		curve: curve
	).kr;

	drumMode = PMOsc.ar(
		carfreq: Saw.ar(freq: freq * 0.9),
		modfreq: freq * 0.85,
		pmindex: timbreIndex,
		mul: drumModeEnv * 10
	);

	drumMode = drumMode + SinOsc.ar(freq: [freq, freq * 0.8], mul: drumModeEnv);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	stick = Crackle.ar(chaosParam: 2.01);

	stickEnv = Env.perc(attackTime: atk, releaseTime: stickRel, level: 3, curve: curve).kr;

	sig = Mix.ar(drumMode + stickEnv + HPF.ar(clickEnv, clickFreq, clickAmp)) * globalEnv;

	sig = LeakDC.ar(sig * 0.5);
	sig = Limiter.ar(sig, 0.6);
	// OffsetOut.ar(out, Pan2.ar(sig, pan));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;


SynthDef(\Sd_sosSnare, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, atk = 0.005, rls = 0.1, crv = (-4), atk1 = 0.05, rls1 = 0.6, crv1 = (-8), freq = 405,
	//drumMode Controls
	drumModeAmp = 0.25, timbreIndex = 0.385, modHarmonic = 0.452,
	//snares controls
	snareAmp = 40, nyquist = 1700, snareRez = 1000, ffreq = 40, rq = 0.1, bwr = 1,
	doneAction = 2;

	var drumMode, drumModeEnv, snares, snareEnv, sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	drumModeEnv = Env.perc(attackTime: atk, releaseTime: rls, level: 0.5, curve: crv).kr;

	drumMode = SinOsc.ar(freq: freq * 0.53, mul: drumModeEnv);

	drumMode = drumMode + SinOsc.ar(freq: freq, mul: drumModeEnv);

	drumMode = drumMode + PMOsc.ar(
		carfreq: Saw.ar(freq * 0.85),
		modfreq: freq * modHarmonic,
		pmindex: timbreIndex,
		mul: drumModeEnv // * 10
	);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	snareEnv = Env.perc(attackTime: atk1, releaseTime: rls1, curve: crv1).kr;

	snares = Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(nyquist * 2));

	snares = BRF.ar(in: snares, freq: ffreq, mul: snareEnv, rq: rq);

	snares = Resonz.ar(in: snares, freq: snareRez, bwr: bwr, mul: snareAmp) ;

	sig = Mix.new(drumMode + snares) * globalEnv * amp;

	sig = LeakDC.ar(sig * 0.5);

	//DetectSilence.ar(in: sig, doneAction: doneAction);
	sig = Limiter.ar(sig);

	// OffsetOut.ar(out, Pan2.ar(sig, pan));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;

SynthDef(\Sd_hiSin, {arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
	envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, envT1 = 0.02, envT2 = 0.12, envT3 = 0.01, envLev = 15, envPow = 1, envDivDur = 1, theta = 0.5, rho = 0.8, a0 = 1, a1 = 0, a2 = 0, filterfreq = 1000, rq = 1.0, selectMod = 0, freq = 9000, sinAmp = 0.3, modFreq = 0.2, doneAction = 2;

	var click, b1, b2, sig, mod;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.ar(Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]), levelScale: envLev, timeScale: sustain / envDivDur).pow(envPow);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	click = SOS.ar(env, a0, a1, a2, b1, b2);
	click = RHPF.ar(click, filterfreq, rq);
	mod = SelectX.kr(selectMod.mod(3), [LFNoise0.kr(modFreq), LFNoise1.kr(modFreq), LFNoise2.kr(modFreq)]);
	sig = ((SinOsc.ar(freq, mul: sinAmp) * mod.range([0, 0.1], 1.0) * env) + click) ;
	sig = Limiter.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_haty48,{ arg out = 0, amp = 0.3, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 140,
	envaL1 = 2.81, envaL2 = 0.91, envaL3 = 2.52, envaL4 = 0.85, envaL5 = 0, envaT1 = 0.01, envaT2 = 0.02, envaT3 = 0, envaT4 = 0, envaCrv = -3.54, envpL1 = 120, envpL2 = 16.936, envpL3 = 1279, envpL4 = 0, envpT1 = 0, envpT2 = 0.33, envpT3 = 0, envpT4 = 0.53, envpCrv = (-0.64), modFreq = 1, modAmt = 1.4, sinfAdd = 1.7, sinPhase = 0.28, sinpAdd = 1.7, sinAddAmp = 1, rf1Freq = 1238.8, rf1Rq = 0.26, rf2Freq = 765, rf2Rq = 0.62, hpfFreq = 3699, doneAction = 2;
	var mod, enva, envp, sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	freq = freq.explin(20, 20000, 0.01, 10); // .max(0.01).min(2);

	// globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	enva = EnvGen.kr(Env([envaL1, envaL2, envaL3, envaL4, envaL5], [envaT1, envaT2, envaT3, envaT4], [envaCrv, envaCrv / 2, envaCrv.neg]), timeScale: sustain);
	envp = EnvGen.kr(Env.circle([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3, envpT4], [envpCrv, envpCrv * 2 , envpCrv.neg, envpCrv / 2]), timeScale: sustain);
	mod = LFNoise0.ar(modFreq * envp.range(0.1, 4), modAmt * enva).range(1, modAmt);
	sig = SinOsc.ar([envp, envp + sinfAdd] * freq, [sinPhase, (sinPhase + sinpAdd)], [1, sinAddAmp]);
	// sig = Resonz.ar(sig, [rf1Freq, rf2Freq] * mod, [rf1Rq, rf2Rq], enva);
	// sig = HPF.ar(sig, hpfFreq);
	sig = (sig[0] + sig[1]);
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


/*SynthDef(\Sd_template, { arg
out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1,
freq = 440, doneAction = 2;
var sig;
var envLength = sustain * (end - begin) / speed;
var line = Line.ar(begin, end, envLength, doneAction: doneAction);
var env = Env.asr;
var globalEnv = IEnvGen.ar(env, line);

freq = max(0, freq * speed * (1 + (accelerate * line)));
// freq = freq.max(0.01).min(2);

OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;*/

// portedPlugins, requires https://github.com/madskjeldgaard/portedplugins

SynthDef(\Sd_bltri, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, pw = 0.5, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	sig = BLOsc.ar(freq, pw, 0);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_blsaw, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, pw = 0.5, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	sig = BLOsc.ar(freq, pw, 1);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_blsquare, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, pw = 0.5, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	sig = BLOsc.ar(freq, pw, 2);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_harmosc, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, firstharmonic = 1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	sig = HarmonicOsc.ar(freq, firstharmonic, Array.rand(16, 0.1, 1.0).normalizeSum);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_neoformant, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, carrierfreq = 200, phaseshift = 0.5, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	sig = NeoFormant.ar(freq, carrierfreq, phaseshift);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

// planet drone
// prefix arrays with # <- nameControl syntax
SynthDef(\Sd_so, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 10, freq = 1, verbMixLfo =  0.70107585787773, decTime4 = 13.907386982441, decTime1 = 6.9938727498055, lpfFreq = 3976, ringzFreq4 = 7890.3197827339, ringzFreq1 = 43.246298016335, ringzFreq2 = 96.466201484, ringzFreq3 = 9004.5744515777, decTime3 = 25.021273517609, verbRoomLfo = 2.9249746382236, verbRoom = 0.55860961675644, ringzMul = 1, dist = 1, decTime2 = 20.645671010017, verbMix = 0.33222706317902, decTimeDiv = 7, doneAction = 2;
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
		ringzMul * [ 4, 8, 2, 7 ] * dist // mul
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

SynthDef(\Sd_sa,{

	// var freq = ~saPreset[\sineLfo] ;
	arg sineLfo = 705.98, shiftmul = 0.96, lpfFreq = 4643, srcSusFactor = 1,  verbMix = 0.67, verbRoom = 0.64, freqShift = 2.0625, freqShiftDiv = 1.25, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, doneAction = 2;

	var rt = 0.75;
	var sig, i, item;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	var srcSus = [ 0.47988572208828, 0.446525963203 ] * srcSusFactor;
	var src = (PinkNoise.ar(1!2) - srcSus) ;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.max(0.01).min(2);


	4.do{src = BRF.ar(
		src,
		rrand(1900,3600).round(2)+(sineLfo * LFNoise0.ar(rt.rand!2)),
		0.25
	)
	};
	2.do{src = BRF.ar(
		src,
		rrand(100,600).round(8)+(sineLfo * LFNoise1.ar(rt.rand!2)),
		0.14
	)
	};
	4.do{src = BRF.ar(
		src,
		rrand(900,2600).round(16)+(sineLfo * LFNoise1.ar(rt.rand!4)),
		0.2
	)
	};
	6.do{src = BRF.ar(
		src,
		rrand(250,7500).round(8)+(sineLfo * LFNoise1.ar(rt.rand!6)),
		0.11
	)
	};
	4.do{src = BRF.ar(
		src,
		rrand(2500,5000).round(12)+(sineLfo * LFNoise1.ar(rt.rand!2)),
		0.2
	)
	};
	sig = FreqShift.ar(
		Mix.ar(src),
		Duty.ar(
			Phasor.kr(0.0, 96000, 0.016, 0.006, 0.006),
			0,
			Diwhite(
				sineLfo * 0.6,
				sineLfo * 5
			).round(sineLfo / 32)
		) * freq,  // freq
		0,  // phase
		shiftmul// mul
	) + src;

	sig = CombC.ar(sig, 1, 0.001, 7);

	sig = Limiter.ar(
		LPF.ar(
			sig,
			lpfFreq + LFNoise1.ar(rt.rand!2,1250)
		),
		0.5
	);
	sig = FreqShift.ar(
		sig,
		abs(freqShift * 8) /
		// ne réagit pas depuis tidal, est statique une fois interprété :
		/*3.collect{ arg item, i;
		freqShiftDivArrayStart + (/*i **/ freqShiftDivArrayStep)
		}.debug('freqShift')*/
		[ 5.8820016384125, 6.8820016384125, 7.8820016384125, 8.8820016384125, 9.8820016384125, 10.882001638412, 11.882001638412, 12.882001638412, 13.882001638412, 14.882001638412, 15.882001638412, 16.882001638412, 17.882001638412, 18.882001638412, 19.882001638412 ] * freqShiftDiv // (4..16)
	);

	sig = FreeVerb.ar(

		sig,
		mix:  verbMix,
		room: verbRoom,
		damp:  0.25,
		mul: 1.0,
		add: 0.0);

	sig = Splay.ar(sig);
	sig = HPF.ar(sig, 140);
	// sig = Limiter.ar(sig, 1);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;

SynthDef(\Sd_sd, {
	arg /*envs = 79,*/ dryLevel = -2.9293020057678, earlyRef = -1.627618971467, phasorSkew = 0.5, phasorStages = 8, random4 = 129.59043478966, tailLevel = 1.626927190423, hpfLfo = 0.15, phasorMod = 0.5, random3 = 1.0151849246025,  hpfFreq = 124, revMix = 0,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1000, doneAction = 2;

	var sig, sig2, phaserSources, phaserCycle, envs;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	thisThread.randSeed = 1000000;

	envs = rrand(0, 79);

	sig = EnvGen.ar(
		Env(
			({ (0.65.rand2 ** 3) } ! envs),
			({ exprand(0.01, 0.2) } ! (envs - 1)),
			0.05
		)
	);

	sig = ({
		sig * Blip.ar(
			freq * LFPulse.kr(random3) * [ 1, 1.3217046260834, 0.621127869665623 ],
			random4 * sig * 9 % [9,7,5.5]
		)
	}!4).mean;

	sig = HPF.ar(sig, SinOsc.kr(
		hpfLfo ,
		LFPulse.kr(0.51),
		hpfFreq,
		(hpfFreq * 1.32051282)
	),
	1.15);

	phaserSources = [
		sig,
		SinOsc.ar(
			LFNoise1.kr(phasorSkew),
			SinOsc.ar(0.331)
		)
	]; // skew: SinOsc.kr(0.5),
	phaserCycle = phaserSources.size * 0.25;

	sig = AnalogPhaserMod.ar(
		sig,
		Select.kr(phaserCycle, phaserSources),
		LFPulse.kr(phasorMod), // modulation: LFPulse.kr(0.1),
		phasorStages
	);

	sig2 = GVerb.ar(
		Mix.ar(sig),
		roomsize: 100, // 200,
		revtime:  23, // 385,
		damping: 0.15, //0.5,
		inputbw: 0.5,
		spread: 20, // 50,
		drylevel: dryLevel,
		earlyreflevel:earlyRef,
		taillevel: tailLevel
	);

	sig = LinSelectX.ar(
		revMix,
		[sig * 8.5, sig2 * 0.8]
	);

	sig = HPF.ar(sig, 70);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_jpd2, {
	arg serie1 = 0.35, serie2 = 0.85,
	serie3 = 0.5, serie4 = 0.75, verbmix = 0.4, panpos = 0.5, panmul = 0.35,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 240, doneAction = 2;
	var sig, snd, bohlen;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	thisThread.randSeed = 100000;
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	bohlen=[1, 27/25, 25/21, 9/7, 7/5, 75/49, 5/3, 9/5, 49/25, 15/7, 7/3, 63/25, 25/9, 3];
	sig = {{snd = LFTri.ar((bohlen.choose/3) * freq);
		4.do{
			snd = BAllPass.ar(snd, PinkNoise.kr(11, 30 * [1, 3, 9/7, 9/5, 7/3, 25/9].choose + (serie1 * 15)), 0.01);
			snd =BAllPass.ar(snd, PinkNoise.kr(23, 270 * [1, 3, 9].choose * bohlen.choose) + (serie2 * 275), 0.003);
			snd =BAllPass.ar(snd, PinkNoise.kr(30, 120 * [3, 9, 3].choose * bohlen.choose) + (serie4 * 125), 0.073);
			snd =((snd * LFTri.ar(bohlen.choose/7, 7, 3)) + WhiteNoise.ar(Lag.ar(Dust2.ar(SinOsc.kr(1, 25, 3), 1, PinkNoise.kr(0.001)), 0.02), 0)).tanh;
			snd =LPF.ar(LeakDC.ar(snd, 0.996), 10000 + (serie3 * 4500)  )};
		snd = (snd / 2)}!8};
	sig = FreeVerb.ar(sig, verbmix, 1, 1);
	sig = Mix.ar(sig);
	sig = Pan2.ar(
		sig,
		pos:SinOsc.ar(
			freq: 0.005 + (SinOsc.kr((panpos * 3), 0, 20, 50)).abs,
			phase: 0.125,
			mul: panmul * 0.75,
			add: 0.15)
	);
	// sig = Limiter.ar(sig, 0.5);
	sig = HPF.ar(sig, SinOsc.kr(1, 0, 0.5, 80));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp * 0.5));
}).add;



SynthDef(\Sd_jpd, {
	arg  freq1 = 1.5, freq2 = 2.75, freq3 = 1.2, freq4 = 1.1,  ghDelTime = 0.3,
	filterFreq = 1500, filterRes = 0.23,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 140, doneAction = 2;
	var amp_,hz_,sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	amp_ = Lag.ar(K2A.ar(amp), 0.02);
	// hz_ = Lag.ar(K2A.ar(hz), hzlag);
	hz_ = Lag.ar(K2A.ar(freq), 0.02);
	sig = VarSaw.ar(
		freq: hz_ * Array.fill(
			3,
			{arg freqI;
				2 ** freqI * LinLin.kr(SinOsc.kr(LFNoise0.kr(1)),
					freq1 ,
					freq2 ,
					freq3,
					freq4
				)
		})  ,
		mul: amp_ * Array.fill(3, {arg freqI; (1/2) ** freqI}),
	);
	sig = Mix.ar(sig);
	sig = Greyhole.ar(
		sig,
		delayTime:0.25 + abs(ghDelTime)
	);
	sig = DFM1.ar(
		sig,
		filterFreq ,
		filterRes
	);
	//sig = ComplexRes.ar(sig, freq: 100.0, decay: 0.2);
	// sig = HPF.ar(sig, 110);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;



SynthDef(\Sd_jb,{
	arg freqPulse1 = 370, freqPulse2 = 387,  freqPulse3 = 411, freqPulse4 = 306,
	pulseWidth1 = 150,  pulseWidth2 = 94, pulseWidth3 = 178,  pulseWidth4 = 43,
	brf = 34, modOffset = 254, modAmount = 2.69,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 157.48465, doneAction = 2;

	var sig, mix1, mix2, mix3, mix4;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.explin(20, 20000, 0.01, 2); // .max(0.01).min(2);

	mix1 = Pulse.ar(
		freq: ((SinOsc.kr(50) + freqPulse1 + modOffset  + (SinOsc.ar(0.075) * modAmount)) * freq).max(20).min(20000),
		width:  SinOsc.ar(0.005 * pulseWidth1) + 0.25,
		mul: 1.7,
	);
	mix1 = BRF.ar(
		mix1,
		2000 + brf - (SinOsc.ar(0.15) * 1100),
		0.5);
	mix1 = Pan2.ar(
		mix1,
		SinOsc.ar(0.015) - 0.5);
	mix2 = Pulse.ar(
		freq: (LFPulse.kr(123) + freqPulse2 + modOffset  - (SinOsc.ar(0.05) * modAmount ) * freq).min(20000).max(20),
		width: SinOsc.ar(0.012 * pulseWidth2 ) + 0.25,
		mul: 1.8,
	);
	mix2 = BRF.ar(
		mix2,
		2000 + brf  - (SinOsc.ar(0.08) * 1100),
		0.5
	);
	mix2 = Pan2.ar(
		mix2,
		SinOsc.ar(0.055)
	);
	mix3 = Pulse.ar(
		freq: (LFSaw.kr(27) + freqPulse3  + modOffset + (SinOsc.ar(0.075) * modAmount ) * freq).min(20000).max(20),
		width: SinOsc.ar(0.0005 * pulseWidth3 ) + 0.25,
		mul: 1.9,
	);
	mix3 = BRF.ar(
		mix3,
		2000 + brf - (SinOsc.ar(0.02) * 1100),
		0.5
	);
	mix3 = Pan2.ar(
		mix3 ,
		SinOsc.ar(0.15)-0.5
	);
	mix4 = Pulse.ar(
		freq: (SinOscFB.kr(13) + freqPulse4  + modOffset  - (SinOsc.ar(0.05) * modAmount) * freq).min(20000).max(20),
		width: SinOsc.ar(0.0005 * pulseWidth4 ) + 0.25,
		mul: 2.0,
	);
	mix4 = BRF.ar(
		mix4,
		2000 + brf  - (SinOsc.ar(0.005) * 1100),
		0.5
	);

	mix4 = Pan2.ar(
		mix4 ,
		SinOsc.ar(0.005));

	sig = Mix.ar([
		mix1,
		mix2,
		mix3,
		mix4
	]);

	sig = DFM1.ar(sig, SinOsc.kr(0.0, 15, 0.5, 6200).abs, 0.35);

	sig = Greyhole.ar(sig, delayTime: brf / 10);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp * 0.5));


}).add;


SynthDef(\Sd_sn,{

	arg freqMul2 = 21.257689658999, lfoPhase2 = 0.7797144651413, filterDecay = 0.13442561626434,
	freqOffset = 3.2626762163639, verbRoom = 0.53601360321045, freqAdd = 0.31584845781326, lfoPhase1 = 0.72416956424713, verbMix = 0.55239865779877,
	freqBase = 6.4624158263206, freqMul = 33.736344687939,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 120, doneAction = 2;

	var sig, quickos;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	sig = FreeVerb.ar(
		quickos = 0;
		(100..90).do{
			|freqIter|
			freqIter = freqIter / 2 + freqBase  + (1.0 + SinOsc.ar(
				freqAdd ,
				1.25,
				freqMul
			)
			);
			quickos = SinOsc.ar(
				freqIter + [0 + (freqMul + SinOsc.ar(
					freq: 0.03,
					phase: 0.0,
					mul: freqOffset,
					add: 0.0)
				),
				1 + (freqMul2   - SinOsc.ar(
					freq: 0.03,
					phase: 0.0,
					mul: freqOffset,
					add: 0.0
				)
				)] * freq, // freq
				quickos * LFTri.kr(0.75,1.25).range(1.2+lfoPhase1,
					0.25 + lfoPhase2) // phase
			)
		};
		quickos;,
		mix:  abs(verbMix),
		room: abs(verbRoom),
		damp:  0.25,
		mul: 1.0,
		add: 0.0);

	sig = Balance2.ar(
		sig[0],
		sig[1],
		SinOsc.kr(1.5) * 0.5
	);

	sig = AllpassN.ar(
		sig,
		2.75,
		filterDecay ,
		abs(SinOsc.ar(
			0.0258,
			1.38,
			0.12,
			1.0 / (1.0 + abs(SinOsc.kr(filterDecay, 0.0,filterDecay * 250, filterDecay * 125))) // add
		)
		)
	);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));


}).add;


SynthDef(\Sd_skk, {

	arg earlyRef = 0.52961673587561, revTime = 0.81880112171173, dryLev = 0.76181447505951,
	impulseFreq1 = 0.092333076000214, impulseFreq2 = 0.92188009023666, impulseFreq3 = 0.24880619049072, impulseFreq4 = 0.23297158479691, envCurve = -8,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1440, doneAction = 2;

	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr(curve: envCurve);
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	freq = freq.explin(20,20000,0.01,2);

	// thisThread.randSeed = randSeed] ?? ({  10000000.rand.debug("randSeed") });
	thisThread.randSeed = 100000;

	sig = tanh(Impulse.kr(
		freq: (freq * (impulseFreq1 * rrand(6.0,12))).min(20000).max(20),
		phase: Line.kr(0.2, 0.0, 0.4)
	).lag * Crackle.ar(LFSaw.kr(rrand(3.0, 7) + (impulseFreq2 * rrand(10.0, 20))).abs.lag * 1.8)
	+
	GVerb.ar([
		Impulse.kr(
			freq: ((impulseFreq3 * rrand(60,90)) * freq).min(20000).max(20),
			phase: Line.kr(0.2, 0.0, 0.3)
		) + Impulse.kr(
			freq: rrand(1.0,6) + impulseFreq4 * (impulseFreq3 * rrand(1.0,10)),
			phase: 0.5
		)
	].lag * Blip.ar(
		((5.9 + (impulseFreq4 * rrand(30.0, 50))) * freq).min(20000).max(20),
		7,
		0.4)!2, 1, 1) * 5);

	sig = GVerb.ar(
		Mix.ar(sig),
		roomsize: 2, // 26, foutre un dseq dessus
		revtime: SinOsc.kr(LFPulse.kr(revTime), 0.0, 0.5, 0.65),
		damping: 0.165,
		inputbw: 0.46,
		spread:  17, // 25,
		drylevel:  SinOsc.kr(dryLev).abs , // -6 + (dryLev * rrand(30, 70)).debug("drylevel"),
		earlyreflevel: LFPulse.kr(earlyRef, 0.0, Phasor.kr(0.0, 10.05, 0.25, 0.75)), // -10.47 + (planetDrone_effect_3 * rrand(50,80)),
		taillevel: -10.15,
		maxroomsize: 3, // 100,
		mul: 0.125, // .0,
		add: 0
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp * 0.06));

}).add;



SynthDef(\Sd_gutter, { arg out = 0, pan = 0, begin = 0, end = 1, speed =
	1, accelerate = 0, sustain = 1, freq = 621.58, doneAction = 2;
	var amp, gamma, omega, c, dt, singlegain, smoothing, gains1, gains2,
	freqs1, qs1, freqs2, qs2, audioinput, size, sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = A2K.kr(freq).explin(20, 20000, 0.01, 2); // (0.01).min(2);

	thisThread.randSeed = 8; // 25; // 3;

	size = rrand(4, 16);

	amp = \amp.kr(0.4, 0.02, spec: ControlSpec(0.0, 1, step: 0.01, default:
		0.4));
	gamma = \gamma.kr(0.1, 0.02, spec: ControlSpec(0.0, 10, step: 0.01,
		default: 0.1));
	omega = \omega.kr(0.02, 0.02, spec: ControlSpec(0.0000001, 1, step:
		0.01, default: 0.02));
	c = \c.kr(0.1, 0.02, spec: ControlSpec(0.0, 1, step: 0.01, default:
		0.1));
	dt = \dt.kr(5, 0.02, spec: ControlSpec(0.01, 1000, step: 0.01, default:
		5));
	singlegain = \singlegain.kr(1, 0.02, spec: ControlSpec(0.0, 1, step:
		0.01, default: 1));
	smoothing = \smoothing.kr(0.5, 0.02, spec: ControlSpec(0.0, 7, step:
		0.01, default: 0.5));
	gains1 = Array.rand(size, 0.0, 1) * \gains1.kr(1, 0.02, spec:
		ControlSpec(0.0, 2, step: 0.01, default: 1));
	gains2 = Array.rand(size, 0.0, 1) * \gains2.kr(1, 0.02, spec:
		ControlSpec(0.0, 2, step: 0.01, default: 1));
	freqs1 = Array.exprand(size, 20, 16000) * \freqs1.kr(1, 0.1, spec:
		ControlSpec(0.01, 2, step: 0.01, default: 1)) * freq;
	qs1 = Array.rand(size, 10, 1000) * \qs1.kr(1, 0.02, spec:
		ControlSpec(0.0, 2, step: 0.01, default: 1));
	freqs2 = Array.exprand(size, 20, 16000) * \freqs2.kr(1, 0.1, spec:
		ControlSpec(0.01, 2, step: 0.01, default: 1)) * freq;
	qs2 = Array.rand(size, 10, 1000) * \qs2.kr(1, 0.02, spec:
		ControlSpec(0.0, 2, step: 0.01, default: 1));

	audioinput = SinOsc.ar(SinOsc.ar(LFNoise2.ar(30)*100).exprange(100.0,
		2500.0));

	sig = GutterSynth.ar(
		gamma.max(0.0).min(10),
		omega.max(0.0000001).min(1),
		c.max(0.0).min(1),
		dt.max(0.01).min(1000),
		singlegain.max(0.0).min(1),
		smoothing.max(0.0).min(7),
		1, // togglefilters [0 1]
		0, // distortionmethod [0 1 2 3 4] // at init
		2, // oversampling [0 1 2 3 4]
		0, // enableaudioinput [0 1]
		audioinput,
		gains1.max(0.0).min(1),
		gains2.max(0.0).min(1),
		freqs1.max(20).min(20000),
		qs1.max(10).min(1000),
		freqs2.max(20).min(20000),
		qs2.max(10).min(1000)
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan,
		amp));
}).add;

// solo 2704
SynthDef(\Sd_jgg, {
	arg sine1Div1 = 1,
	sine1Div2 = 1,
	sine1Freq = 1,
	sine1FreqMod = 1,
	sine1Mul = 7.8680473923683,
	sine2Freq1 = 1,
	sine2FreqMod = 1,
	sine2Mul = 48.79680823088,
	sine2Freq2 = 10.25989812255,
	sine2Fb2 = 1.9023437261581,
	srcADiv = 1,
	freqShift1 = 31.43260506392,
	freqDiv = 1,
	freqShift2 = 1,
	freqShift2Mul = 0.5390748977661,
	roomLfoFreq = 0.86564662694931,
	roomSize = 15.663612246513,
	revTimeLfoFreq = 1.6621443271637,
	revTime = 16.106231057644,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
	var
	sig, srcA, srcB;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.explin(20,20000,0.01,2);

	srcA = Splay.ar(
		SinOscFB.ar(
			freq: (SinOscFB.ar(
				[ 11.021904468536, 12.051196551323, 13.080488634109, 14.109780716896, 15.139072799683, 16.168364882469 ] * sine1Div1 , // (10..15),
				Phasor.kr(0.0, 10.0, 0.0, 8.0, 8.0)
			) < ([ 6.6674477100372, 8.6676820230484 ] * sine1Div2) /*1*/ * 450 + 90
			+ SinOsc.ar (
				freq: (sine1Freq * [ 0.1841375887394, 0.42661230743756, 0.98838081949021, 2.2898932527378 ]) % (sine1FreqMod * [ 6.8669802308083, 8.1952688598633, 9.5235574889183, 10.851846117973, 12.180134747028, 13.508423376083 ]) ,
				phase: 0.0,
				mul: sine1Mul,
				add: 0.0
		)) * freq).max(20).min(20000) / ([ 6.6674477100372, 8.6676820230484 ] * sine1Div2) // 7
		+ SinOscFB.ar(
			freq: ((SinOsc.ar(
				freq: (sine2Freq1 * [ 0.39846314287186, 0.79684929692007, 1.5935446310682 ]) % (sine2FreqMod * [ 17.413986957073, 15.880323654413, 14.346660351753, 12.812997049093, 11.279333746433, 9.7456704437733, 8.2120071411133 ]) * freq, // 0.0073,
				phase: 0.0,
				mul: sine2Mul,
				add: 0.0
			) + sine2Freq2 + 600) * freq).max(20).min(20000),
			feedback: SinOscFB.ar(
				SinOscFB.ar(1, 1) > sine2Fb2 , // 0.1 + 1,
				abs(VarSaw.kr(sine2Fb2))
			),
			mul: SinOscFB.ar(
				(0.1) ,
				LFPulse.kr(sine2Fb2)
			).min(sine2Fb2) // (0.01)
	))
	/ (srcADiv * [ 3.1000294208527, 9.2891416983033 ]); // 2;

	srcB = FreqShift.ar(
		srcA,
		0.1 + freqShift1) / ((freqDiv * [ 2.5132746219635, 3.4630087018013, 4.4127427816391, 5.3624768614769, 6.3122109413147, 7.2619450211525, 8.2116791009903 ]) +   SinOsc.ar(
		freq: (0.00025 + (freqShift2 * [ 67.211892831326, 119.124, 226.61 ]) * freq).min(20000).max(20),
		phase: 0.0,
		mul: freqShift2Mul,
		add: freqShift2Mul / 2 // 0.0
	));
	sig = SelectX.ar(
		LFTri.kr(0.15).abs, // which // arg sur lfo freq?
		[srcA * 0.2, srcB]
	);
	sig = GVerb.ar(
		Mix.ar(sig * 0.5),
		roomsize: LFPulse.kr(
			roomLfoFreq,
			0.0,
			0.5,
			roomSize,
			roomSize * 1.5
		), // 180,
		revtime: LFPulse.kr(
			revTimeLfoFreq,
			0.0,
			0.5,
			revTime,
			revTime * 2
		), // 30,
		damping: 0.17,
		inputbw: 0.97,
		spread: 4,
		drylevel: 40,
		earlyreflevel: 5,
		taillevel: 2,
		mul: 0.4
	);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp * 0.6));
}).add;

SynthDef(\Sd_jee,{
	arg sineFreq1 = 121,
	sineFreq2 = 154,
	sineFreq3 = 482,
	sineLfo1 = 1.25,
	sineLfo2 = 7.23,
	freqShift1 = 479.23,
	freqShiftLfo = 0.90,
	roomsize1 = 11,
	revtime1 = 39.11,
	roomsizeLfo = 1.2,
	revtimeLfo = 2.64,
	freqShift2 = 0.11,
	freqShiftDivArray = 1,
	roomsize2 = 9,
	revtime2 = 5.5594990253448,
	envCurve = -8,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;

	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr(curve: envCurve);
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.explin(20,20000,0.01,2);

	sig = SinOsc.ar(
		(sineFreq1
			+ SinOsc.ar(
				freq: sineLfo1 , // 0.03,
				phase: 0.0,
				mul: sineFreq3,
				add: sineFreq3 / 2 // 0.0
			) +
			sineFreq2
			+ SinOsc.ar(
				freq: sineLfo2 , // 0.03,
				phase: 0.0,
				mul: sineFreq3,
				add: sineFreq3 / 2 //0.0
		) * freq).min(20000).max(20), // range // freq
		0, // phase
		0.095 // mul
	);
	sig = FreqShift.ar(
		sig,
		freqShift1 / (
			([ 3, 4, 5, 6, 7, 8, 9 ] * freqShiftDivArray) +   SinOsc.ar(
				freq: freqShiftLfo,
				phase: 0.0,
				mul: freqShift2,
				add: freqShift2/ 2 // 0.0
			)
		)
	);
	// sig = sig * Decay.kr(Dust.kr(dustDensity)) * LFPulse.ar(lfNoiseFreq);
	sig =GVerb.ar(
		Mix.ar(sig),
		Phasor.kr(0.0, roomsizeLfo, roomsize1, roomsize2, roomsize2), // 299, // roomsize
		Phasor.kr(0.0, revtimeLfo, revtime1, revtime2, revtime2), // 400, // revtime
		0.5, // damping
		0.5, // inputbw
		50, // spread
		0.2, // drylevel
		0.2, // earlyreflevel
		0.9 // taillevel
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp * 0.25));
}).add;

SynthDef(\Sd_jii, {
	arg select1 = 0.31979692578316, select2 = 0.31584572792053,  panMod = 0.37190895080566,
	verbMix = 0.17909510731697, verbRoom = 0.59750739336014, verbMod = 0.045994164943695,  freqShift = 0.30387362092733, bpfreq = 1, bprq = 1, bpdb = 1, freqShiftDivArray = 1, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
	var gamma, sig, select;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);
	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);
	thisThread.randSeed = 100000000; // anciennement stocké dans une var, dont on n'a pas besoin
	// gamma= {[rrand(30, 50), rrand(50, 70), rrand(50, 70), rrand(70, 100)].choose.midicps * LFNoise2.kr(1, 0.01, 1)} ! 24;
	gamma= {([rrand(3, 5), rrand(5, 7), rrand(5, 7), rrand(7, 10)].choose.midicps * freq).min(20000).max(20) * LFNoise2.kr(1, 0.01, 1)} ! 24;
	select = SelectX.kr(
		[SinOsc,LFTri].choose.kr(2.rrand(25).reciprocal).range(0,2) - (select1 * 0.5),
		[
			0.7.rrand(1),
			LFGauss.kr(
				Latch.kr(
					LFNoise2.kr(1).range(1/5, 5.rrand(20)).reciprocal - (select2 * 0.5),
					Impulse.kr(LFNoise2.kr(3.rrand(10).reciprocal).range(0.5, 3.rrand(6)))
				),
				SinOsc.kr(3.rrand(15).reciprocal).range(0.07.rrand(0.16), 0.25.rrand(0.4))
			),
			0.1.rrand(0.5)
		]
	);
	sig = RLPF.ar(
		LFSaw.ar(gamma)/4,
		gamma * LFCub.kr(rrand(0.01, 0.1), 0, 2, 3),
		LFNoise2.kr(1/8, 0.6, 0.7)
	);
	sig =FreeVerb.ar(
		sig,
		0.12 + (SinOsc.kr(verbMod).linexp(-1,1,0.01,0.5)),
		0.32 ,
		0.32
	);
	sig = BPeakEQ.ar(
		sig,
		[ 177, 1908, 5201, 7917 ] * bpfreq,
		[ 2.5961435782909, 0.18070378184319, 3.1636937344074, 0.3819401717186 ] * bprq,
		[ 5.2225273728371, 0.97371907234192, 1.4251277923584, 3.6801275014877 ] * bpdb
	).mean;
	sig = LeakDC.ar(
		Normalizer.ar(
			sig,
			0.8,
			0.1
		)
	);
	sig = FreqShift.ar(
		sig,
		(0.01 + freqShift)
		/  (freqShiftDivArray * [ 1.049005202055, 2.0452961915731, 3.0415871810913, 4.0378781706095, 5.0341691601276, 6.0304601496458, 7.026751139164, 8.0230421286821, 9.0193331182003, 10.015624107718, 11.011915097237, 12.008206086755, 13.004497076273, 14.000788065791, 14.997079055309, 15.993370044827, 16.989661034346 ])
	);
	sig = Pan2.ar(
		Mix.ar(sig),
		LFNoise2.kr(0.1.exprand(10)).range(-0.25, 0.25) + (LFNoise1.kr(panMod) )
	);
	sig = FreeVerb2.ar(
		sig[0],
		sig[1],
		verbMix,
		verbRoom,
		LFPar.kr(1.5, 0.0, 0.35, 0.5),
		0.5 // 1
	);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_jz,{
	arg freq = 140, freqFactor1 = 1.51, freqFactor2 = 3.81,  num = 5.279, delTime = 56.33, revMix = 0.85, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, doneAction = 2;
	var sig, sig2;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	thisThread.randSeed = 100;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = Saw.ar([freq * freqFactor1, freq * 1.1 * freqFactor2].min(20000).max(20));
	8.do{
		|iter| num = 2 ** (8 - iter + num);
		sig = BRF.ar(
			AllpassN.ar(
				sig,
				1,
				0.1 / (12 - iter + delTime),
				2
			),
			/*80 ** TRand.ar(0, 1, Impulse.ar(num/32, 1/2)).lag(1 / num) * 80,*/
			80 ** Demand.ar(Impulse.ar(num/32, 1/2), 0, Dseq(Array.rand(rrand(8, 24), 0.0, 1), inf)).lag(1 / num) * 80,
			0.35,
			0.85
		)
	};
	sig2 = GVerb.ar(
		Splay.ar(sig),
		roomsize: 100, // Phasor.kr(0.0, 912500, 100.0, 30.0), // 400,
		revtime:  4, // Phasor.kr(0.0, 918250, 0.2, 4, 4), // 4,
		damping: 0.065,
		inputbw: 0.192, // 0.46,
		spread: 16,
		drylevel: 3, // -3,
		earlyreflevel: 0.7, // -4.47,
		taillevel:  0.25,
		maxroomsize: 101
	);
	sig2 = FreeVerb2.ar(
		sig2[0],
		sig2[1],
		0.15 ,// (Ndef.kr(\jzMod1).linlin(-1,1,0.3,0.65)), // Phasor.kr(0.0, 50, 0.5, 0.81), // mix
		0.12, // room
		0.15 // damp
	);

	sig = LinSelectX.ar(
		revMix,
		[sig, sig2 * 0.6]
	);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp * 0.5));
}).add;

// 060524 solo

SynthDef(\Sd_jh,{
	arg   panLfo = 1.4565196990967,
	freq1_1 = 1.6934319496155,
	freq1_2 = 3.5750915050507,
	freqFactor1_1 = 1.9044935464859,
	modFreq = 0.060987344384193,
	freqFactor1 = 0.12856451869011,
	fbLfo1 = 0.60225704908371,
	freq2_1 = 1.6643635296822,
	freq2_2 = 2.1858045578003,
	freqFactor2_1 = 1.4623861312866,
	freqAdd2_1 = 2.1889247775078,
	fbLfo2 = 0.167200922966,
	freqFactor2 = 2.8845697343349,
	phaserLfoSkew = 0.32457834482193,
	phaserLfoMod = 1.8739063501358,
	phaserStages = 31,
	sigMix = 0.5,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 60, doneAction = 2;


	var sig1, sig2, sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	thisThread.randSeed = 10000;

	sig1 = SinOscFB.ar(
		[
			freq * freq1_1
			+
			(SinOsc.ar(
				modFreq,
				LFNoise1.kr(freqFactor1_1).mod(2pi)
			)
			* (freqFactor1 * freqFactor1_1 )
			) ,
			freq * freq1_2
			-
			(SinOsc.ar(
				modFreq,
				LFNoise0.kr(freqFactor1_1 ).mod(pi)
			)
			* (freqFactor1)
			)
		].min(20000).max(20) , // freq
		LFNoise2.kr(
			Phasor.kr(0.0, 48000, fbLfo1, fbLfo1 * 4, fbLfo1 * 4 ),
			0.5,
			1
		).mod(2pi) //+ 1/2 // feedback
	);

	sig1 = Mix.ar(sig1);

	sig2 = SinOscFB.ar(
		[
			freq2_1
			+
			(SinOsc.ar(
				modFreq * freqFactor2_1,
				LFNoise0.kr(freqFactor2_1)
			)
			* (freqFactor2 + freqAdd2_1 )
			) ,
			freq2_2
			-
			(SinOsc.ar(modFreq)
				* freqFactor2
			)
		], // freq
		LFNoise2.kr(
			fbLfo2,
			0.5, // fbLfo2 * 2,
			1 // fbLfo2 * 4
		).mod(4pi) // + 1/2 // feedback
	);

	sig2 = AnalogPhaserMod.ar(
		sig1,
		phaserLfoSkew,  // skew -1 à 1
		phaserLfoMod, // modulation 0 à 1
		phaserStages // 8 // stages 0 à 50
	);




	sig = LinSelectX.ar(
		sigMix, //LFTri.kr(62).abs,
		[sig1, sig2 * 1.2]
	);

	// Ndef('jh'): wrapped channels from 2 to 1 channels
	sig= Splay.ar(sig , 1);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;


SynthDef(\Sd_jff,{
	arg modFreq = 1.35,
	modMul = 0.3,
	dustFreq1 = 5.84683664917946,
	dustFreq2 = 10.24021685361862,
	gendyMinFreq = 6,
	gendyMaxFreq = 16,
	gendyMaxFreqMod = 6.6386635303497,
	gendyMaxFreqModMul = 1.5669676065,
	klankFreqMul = 1,
	klankRingMul = 1,
	roomSize = 1.8979070186615,
	revTime = 5.5169875025749,
	revMix = 0.25,
	combMix = 0.5,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;

	var sig, sig1, sig2, sigVerb, mod;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);


	mod = SinOsc.ar(
		freq: (modFreq),
		phase: 0.0,
		mul: modMul,
		add: modMul / 2
	);

	sig1 = Gendy1.ar(
		/*0:	LINEAR.
		1:	CAUCHY.
		2:	LOGIST.
		3:	HYPERBCOS.
		4:	ARCSINE.
		5:	EXPON.
		6:	SINUS.*/
		ampdist: 3, // 6,
		durdist: 1,
		adparam: 1, // 3,
		ddparam: Dust.ar(
			density: [
				dustFreq1,  dustFreq2 + SinOsc.ar(
					freq: 12.5,
					phase: 0.0,
					mul: 0.15,
					add: 0.30
				)
			],
			mul: 0.5
		),
		minfreq: (gendyMinFreq * freq).min(20000).max(20),
		maxfreq: abs(freq * gendyMaxFreq + SinOsc.ar(
			freq: gendyMaxFreqMod, // 0.000525,
			phase: 0.0,
			mul: gendyMaxFreqModMul , // 360, // 3,
			add: gendyMaxFreqModMul / 2 // 130 // 0.0
		)).min(20000).max(20) ,
		ampscale: 1,
		durscale: LFTri.kr(1.0, 0.0, 0.5, 1),
		initCPs: 18,
		knum: LFTri.kr(12, 0, 6, 12).abs,
		mul: 0.015,
		add: 0.0
	);

	sig2 = CombC.ar(
		sig1 * 0.05,
		0.08 ,
		mod.linlin(-1, 1, 0.01, 0.079)
	);

	sig = LinSelectX.ar(
		combMix,
		[sig1 * 0.05, sig2 * 0.6]
	);


	sig = Klank.ar(
		`[
			[ 227.39, 140.07, 298.69, 220.25, 331.64 ] * klankFreqMul,
			nil,
			[ 0.20, 0.106, 0.416, 0.226, 0.124 ] * klankRingMul
		] ,
		sig
	);




	sigVerb = GVerb.ar(
		Mix.ar(sig),
		roomsize: roomSize,
		revtime: revTime,
		damping: 0.15, // 0.81,
		inputbw: 0.15, // 0.97,
		spread: 20, // 40,
		drylevel: 1, // 0.5, // -0,
		earlyreflevel: 0.17, // 0,
		taillevel: 0.31, // -11,
		maxroomsize: 10, // 170,
		mul: 0.613 //0.008
	);

	sig = LinSelectX.ar(
		revMix,
		[sig, sigVerb * 0.6]
	);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));


}).add;


SynthDef(\Sd_st,{
	arg bbpFreqOffset = 3.716802292347, bbpFreqBase = 14325, bbpBwBase = 7.4702313637733, verbRoom = 0.24938998699188, verbDamp = 0.55016008615494, revMix = 0, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;

	var sig, sigVerb;
	var ascii3 = [7.2, 6.1, 5.6, 4.1, 3.4, 2.11, 1.667, 1.21, 1.10];

	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig =  ([84.0, 101.0, 108.1, 101.2, 103.4, 114, 97, 112, 104, 101, 44, 32, 108, 105, 103, 110, 101, 32, 49, 49] / 100.1 * freq).max(20).min(20000) ;
	// sig = Saw.ar([ 56, 50, 51, 52, 57, 56, 54 ] );

	sig = BBandPass.ar(
		Saw.ar(sig), // in
		((Saw.kr(bbpFreqBase  / [ 20, 44, 52 ] )  +  bbpFreqOffset) * freq).max(20).min(20000), // BBP freq
		LFCub.kr(bbpBwBase / ascii3).abs + bbpFreqOffset
	);

	sig = Splay.ar(sig * 0.25, 1 );



	sigVerb = 	FreeVerb2.ar(
		sig[0],
		sig[1],
		1,
		verbRoom, // room
		verbDamp // damp
	);

	sig = LinSelectX.ar(
		revMix,
		[sig, sigVerb]
	);

	// sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)),0.95,0.13);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;


SynthDef(\Sd_sbb, {
	arg  maxFreq = 278.36, maxFreqLfo = 304.66,  minFreq = 18.66,  minFreqLfo = 34.796, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 60, doneAction = 2;

	var sig, sigVerb;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = Gendy1.ar(
		3, // ampdist
		1, // durdist
		2, // adparam
		1, // ddparam
		minFreq + SinOsc.ar(
			freq: 0.33,
			phase: 0.0,
			mul: (minFreqLfo),
			add: 0.0
		).abs, // minfreq
		(maxFreq + SinOsc.ar(
			freq: freq,
			phase: 0.0,
			mul: (freq),
			add: 0.0
		).abs).max(20).min(20000), // maxfreq
		0.33 // durscale
	);

	sig = HPF.ar(sig, 110);
	sig = Limiter.ar(sig, 0.95);
	sig = Mix.ar(sig);
	sig = Splay.ar(sig, 1);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;

SynthDef(\Sd_doo, {
	arg sawFreq = 0.20591886043549, dstut = 7.9137629508972,
	sinFreq = 0.44790935516357, sawFreq2 = 0.66750446557999, verbmix = 0.54155253410339, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 240, doneAction = 2;
	var sig, mod, rndWform;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);



	thisThread.randSeed = 100000000; // anciennement stocké dans une var, dont on n'a pas besoin

	rndWform = {
		var waves;
		waves = [SinOsc, LFTri, LFCub, LFSaw];
		waves.wchoose([0.6, 0.5, 0.4, 0.15].normalizeSum);
	};
	mod = { arg wform, factor = 1;
		wform.ar(
			0.03,
			0.0,
			sinFreq) * factor
	};
	sig = SyncSaw.ar(
		(
			[ // syncFreq
				rrand(2.0, 4) + abs(sawFreq * rrand(90, 195))
				+ mod.value(rndWform.(), 25),
				rrand(3.0,5) + LFPulse.kr(SinOsc.kr((sawFreq2) * rrand(50,150)))
				+ mod.value(rndWform.(), rrand(55, 75) )
			] * (freq / 190)
		).max(20).min(6000),
		Duty.ar( // sawFreq
			dur: 1 / Ddup(rrand(55, 180) , Dwhite(55,259)) * dstut + Select.kr(
				Impulse.kr(mod.value(rndWform.())) > 0,
				DC.kr(0)
			)
			reset: 0,
			level: Dseries(0, Ddup(rrand(20,50), Dwhite(-330, 9) / 300)) % 1
			* freq).min(20000).max(20)
	).trunc(0.25);


	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;


SynthDef(\Sd_dll, {

	arg envLevRatio = 0.99081794023514, curveFactor = 0.72705893516541, delTimeFactor = 0.67101268768311, timeScaleRatio = 0.33996820449829, verbRoom = 0.10882434248924,  revMix = 0, out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;

	var output, filtFreq, noise, noiseAmp, chain, combs, sig, sigVerb, env;
	var tardRate = 0.36 + (curveFactor * 4);
	var segments = 4;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var genv = Env.asr;
	var globalEnv = IEnvGen.ar(genv, line);

	thisThread.randSeed = 1000;

	env = EnvGen.kr(
		Env(
			levels: { rrand(0.3, 1) } ! segments,
			times: { 0.5.rand } ! segments - 1,
			curve: ({ 4.0.rand2 } ! segments - 1) * curveFactor,
			releaseNode: segments - 2,
			loopNode: 0
		),
		1,
		envLevRatio,
		0.0,
		timeScaleRatio * 0.5
	);



	freq = max(0, freq * speed * (1 + (accelerate * line)));
	freq = freq.explin(20, 20000, 0.01, 2); // .max(0.01).min(2);


	noiseAmp = LFNoise1.kr(env * 100).abs;

	noise = BrownNoise.ar(LinXFade2.kr(noiseAmp, env, env));

	filtFreq = SinOsc.kr(tardRate + timeScaleRatio).range(400, 1800 + (envLevRatio * 2500));
	noise = RLPF.ar(noise, (filtFreq * freq).min(20000).max(20), 0.7);

	chain = FFT(LocalBuf(256), noise);
	chain = PV_BinShift(chain, SinOsc.kr(tardRate * 0.986, 0.7).range(0.96, 1.052) * freq, SinOsc.kr(tardRate * 1.003, 0.61).range(-3, 2.1));
	chain = PV_BinScramble(chain, 0.05, 0.1, 1.0 );

	noise = IFFT(chain, 1, 256);
	noise = noise.fold(-0.5, 0.5);

	combs = Mix.ar(
		[
			CombL.ar(
				noise,
				0.1,
				(SinOsc.kr(tardRate * 0.9966, 0.1).range(0.00032, 0.00028) * 3.4 * abs(1 + delTimeFactor)) * freq,
				0.4,
				0.06
			),
			CombL.ar(
				noise,
				0.1,
				(SinOsc.kr(tardRate * 0.99684, 0.1 ).range(0.000318, 0.000266) * 3.397) * freq,
				0.4,
				0.06
			)
		]
	) * 1.2;

	output = combs + (noise / Array.geom(7, 2, 1.3));



	sig = HPF.ar(output, 80);

	sigVerb = FreeVerb.ar(
		Mix.ar(output),
		0.5, // mix
		0.1 + verbRoom // room
	);

	sig = LinSelectX.ar(
		revMix,
		[sig, sigVerb * 0.3]
	);

	sig = HPF.ar(sig, 70);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;


// 300524


SynthDef(\Sd_su, {
	arg impulseRate3 = 3.5916145443916, del2 = 0.030725069999695, bpf1MaxFreq = 1276, dutyMaxLevel = 921.46335695982,
	attackRate2 = 2.6036867797375, bpf3MaxFreq = 1068, attackRate3 = 0.00047512110471725, decayRate3 = 0.020023078918457, fbGain = 0.5,
	bpf1LfoRate = 0.62046678066254, factorRate3 = 59, loc2FbFactor = 22.767423379421, delayTime = 0.020550796031952, verbMul2 = 0.52233266830444,
	loc3FbFactor = 1.362118062973, verbMul1 = 0.93637094497681, attackRate = 8.7942997813225, locFbFactor = 0.83967577457428, factorRate = 0.85922640562057,
	factorRate2 = 299, del3 = 0.58138495186965, bpf3LfoRate = 0.31931487083435, decayRate2 = 5.954227745533, impulseRate2 = 6.4026742875576,
	bpf2LfoRate = 0.2919663131237, inputRate = 8.435743742519, decayRate = 7.2120881855488, bpf2MaxFreq = 586, verbMix = 0,
	out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;

	var src, loc,
	src2, loc2,
	src3, loc3, sig, localIn, locFb, loc2Fb, loc3Fb, sigVerb;


	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	thisThread.randSeed = 1000;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);


	src = Decay2.ar(
		Dust.ar(inputRate), // in
		LFNoise2.kr(attackRate).range(0.001,0.0001), // attackTime
		LFNoise2.kr(decayRate).range(0.005, 0.05) // decayTime
	)!2 * Saw.ar(
		LFNoise2.kr(factorRate).exprange(40, 3000)
	);

	localIn = LocalIn.ar(6);

	loc = BPF.ar(
		localIn[0..1] + [src, 0],
		(LFNoise0.kr(bpf1LfoRate).range(10, bpf1MaxFreq / 200).lag * freq).min(20000).max(20),
		3.2
	);

	loc = GVerb.ar(
		loc,
		100,
		4,
		mul:verbMul1,
		add:loc
	);

	loc = Compander.ar(
		loc,
		loc,
		0.5,
		1,
		0.001
	);

	loc = (loc * 0.501).tanh;

	loc = Compander.ar(
		loc,
		loc,
		0.1,
		1,
		0.1
	);

	loc = DelayC.ar(
		loc,
		delayTime * 1.33 , // 1.25,
		delayTime
	);

	locFb = loc.reverse * locFbFactor;

	loc = loc + (loc * locFb).tanh;

	src2 = Decay2.ar(
		TDuty.ar(
			impulseRate2 , // Impulse.kr(LFPulse.kr(impulseRate2)), // 1/4,
			0,
			Dseq(
				[1, 0.5, 003, 0.1 + dutyMaxLevel ],
				inf
			)
		),
		LFNoise2.kr(attackRate2).range(0.001, 0.0001),
		LFNoise2.kr(decayRate2).range(0.005, 0.05)
	)!2 * Saw.ar(
		LFNoise2.kr(factorRate2).exprange(40, 10000)
	);

	loc2 = BPF.ar(
		localIn[2..3] + [src2, 0],
		(LFNoise2.kr(bpf2LfoRate).range(40, bpf2MaxFreq / 200) * freq).max(20).min(20000),
		3.2
	);

	sigVerb = GVerb.ar(
		Select.ar(
			LFPulse.kr(0.4),
			[loc2, loc2 * 0.75]
		),
		100,
		3, // 4,
		mul: verbMul2,
		add:loc2
	);

	loc2 = LinSelectX.ar(
		verbMix,
		[loc2, sigVerb]
	);

	loc2 = AnalogPhaser.ar(
		loc2,
		SinOsc.kr(1), // SinOsc.kr(0.1, 0.0, 0.5, 0.5),
		SinOsc.kr(0.2),
		0.5,
		SinOsc.kr(0.25).abs,
		8
	);

	loc2 = Compander.ar(
		loc2,
		loc2,
		0.9,
		1,
		0.001
	);

	loc2 = (loc2 * 0.51).tanh;

	loc2 = Compander.ar(
		loc2,
		loc2,
		0.1,
		1,
		0.1
	);

	loc2 = DelayC.ar(
		loc2,
		del2 * 1.22,
		del2
	);

	loc2Fb = loc2.reverse * loc2FbFactor;

	loc2 = loc2 + (loc2 * loc2Fb);

	src3 = Decay2.ar(
		Impulse.ar(impulseRate3),
		attackRate3,
		decayRate3
	) * SinOsc.ar(factorRate3);

	loc3 = src3 + localIn[4..5];

	loc3 = BPF.ar(
		loc3,
		(LFNoise2.kr(bpf3LfoRate).range(80, bpf3MaxFreq / 10000) * freq).min(20000).max(20), // maths bizarres // bpf3MaxFreq,
		3.2
	).softclip;

	loc3 = DelayN.ar(
		loc3,
		del3 * 1.16,
		[0, del3]
	);

	loc3Fb = loc3.reverse * loc3FbFactor;

	loc3 = loc3 + (loc3 + loc3Fb).tanh;

	LocalOut.ar(LPF.ar(locFb ++ loc2Fb ++ loc3Fb, 8008) * fbGain );

	sig = (loc * 0.25) + (Compander.ar(loc2, loc2, 0.1, 1, 0.05) * 0.35);

	sig = Mix.ar(Mix.ar(sig));

	sig = HPF.ar(sig, 80);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));

}).add;



SynthDef(\Sd_filterTrig, {
	arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, trigDur = 0.13, freq = 1440, vadimRes = 0.81, vadimType = 1, doneAction = 2;
	var sig;
	var envLength = sustain * (end - begin) / speed;
	var line = Line.ar(begin, end, envLength, doneAction: doneAction);
	var env = Env.asr;
	var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	// freq = freq.max(0.01).min(2);

	sig = Trig1.ar(1.0, trigDur);
	sig = VadimFilter.ar(
		sig,
		freq,
		vadimRes,
		vadimType
	);
	sig = HPF.ar(sig, 80);

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