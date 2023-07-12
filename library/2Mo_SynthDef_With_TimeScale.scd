(

///////////////////////////////////////  SynthDef with timeScale

///////////////////////////////////////  Kick

SynthDef(\snapkickSusSd, { |out = 0, amp = 0.3, pan = 0, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, sustain = 1, doneAction = 2|
	var body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC));
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve), timeScale: sustain, doneAction: doneAction);
	body = SinOsc.ar(bodyFreq) * bodyAmp;
	// pop sweeps over the midrange
	popFreq = XLine.kr(popFrqSt, popFrqEnd, popFrqDur);
	popAmp = EnvGen.ar(Env.linen(popAmpAtt, popAmpSus, popAmpRel, popAmpLev));
	pop = SinOsc.ar(popFreq) * popAmp;
	// click is spectrally rich, covering the high-freq range
	// you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(clkAmpAtt, clkAmpRel, clkAmpLev, clkAmpCurve));
	click = LPF.ar(Formant.ar(clkfFundFreq, clkfFormFreq, clkfBwFreq), clkLpfFreq) * clickAmp;

	snd = body + pop + click;
	snd = snd.tanh;

	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snapkick_Sd, { |out = 0, amp = 0.3, pan = 0, attack = 0.0001, release = 0.4, sustain = 1, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, doneAction = 2|
	var globalEnv, body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC));
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve));
	body = SinOsc.ar(bodyFreq) * bodyAmp;
	// pop sweeps over the midrange
	popFreq = XLine.kr(popFrqSt, popFrqEnd, popFrqDur);
	popAmp = EnvGen.ar(Env.linen(popAmpAtt, popAmpSus, popAmpRel, popAmpLev));
	pop = SinOsc.ar(popFreq) * popAmp;
	// click is spectrally rich, covering the high-freq range
	// you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(clkAmpAtt, clkAmpRel, clkAmpLev, clkAmpCurve));
	click = LPF.ar(Formant.ar(clkfFundFreq, clkfFormFreq, clkfBwFreq), clkLpfFreq) * clickAmp;

	snd = body + pop + click;
	snd = snd.tanh * globalEnv;

	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickbass_Sd, { | out = 0, level = 0.5, pan = 0, attack = 0.0001, sustain = 1, release = 0.26, atk = 0.01, dcy = 0.2, rls = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, doneAction = 2 |
	var env0,env1,
	env1m, son, son2,son3,son4,p2, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	p2 = p1 * (-pi);
	env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[atk,dcy,rls],[curve1, curve2, curve3]);
	env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0,SinOsc.kr(0.025));
	env1 = EnvGen.ar(env1);
	env1m = env1.midicps;

	son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
	son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

	son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = Pan2.ar(son,pan);
	son = LeakDC.ar(son,dc,30);

	son = LPF.ar(son+ WhiteNoise.ar(1*noise), env1m*fratio.max(0.01), env0);

	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, [p1,p2], env0), LFSaw.ar(env1m, [p1,p2], env0), LFPulse.ar(env1m, [p1,p2], env0), LFTri.ar(env1m, [p1,p2], env0)]);
	son = LPF.ar(son,filter.max(150)+SinOsc.kr(2,0.5,200));
	son = son * 1;
	//son = son.clip2(1);
	son = son * level.distort;
	// son = Pan2.ar(son, pan, level);
	// OffsetOut.ar(out, son).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level * globalEnv)).tanh;
}).add;

SynthDef(\kicklaserbeam_Sd, { arg out = 0, amp = 0.3, pan = 0.0, attack = 0.0001, sustain = 1, release = 0.26, freq = 13007, freqenvL1 = 3.97, freqenvL2 = 5, freqenvL3 = 0, freqenvL4 = 2.97, freqenvT1 = 0.16, freqenvT2= 0.07, freqenvT3= 0.26, ampenvL1 = 1, ampenvL2 = 1, ampenvL3 = 0, ampenvL4 = 0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, clickAtk = 0, clickRls = 0.1, clickSus = 1, clickLevScale = 10, clickEnvPow = 1, clickEnvNoiseAmp = 0.4, clickEnvInv = 0, clickFreq = 820, clickAmp = 0.3, doneAction = 2;
	var snd, freqenv, ampenv, globalEnv, clickEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3].normalizeSum));
	snd = LFTri.ar(freq * freqenv, 0, ampenv);
	snd = BHiPass4.ar(snd, hpfFreq, hpfRq);

	clickEnv = EnvGen.ar(Env.perc(clickAtk, clickRls), levelScale: clickLevScale, timeScale: clickSus).pow(clickEnvPow) * PinkNoise.ar(clickEnvNoiseAmp).range(0.1, 1).lag(0.02);

	clickEnv = Select.ar(clickEnvInv, [clickEnv, clickEnv.neg]);

	snd = snd + HPF.ar(clickEnv, clickFreq, clickAmp);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetBassLeak_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = 1, globalEnvPow = 1, globalEnvNoise = 0.1, globalEnvInv = 0, atk = 0.01, dcy = 0.4, frqStart = 2, frqEnd = 2, frqTime = 0, sawPow = 1.5, brfFreq1 = 45.1, brfFreq2 = 45, rq = 0.1, t_gate = 1, doneAction = 2;
	var sig, env, globalEnv, trig;

	globalEnv = EnvGen.ar(Env.perc(attack, release, curve), t_gate, timeScale: sustain, doneAction: doneAction).pow(globalEnvPow);
	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range(0.1, 1).lag(0.02);

	globalEnv = Select.ar(globalEnvInv, [globalEnv, globalEnv.neg]);

	env = Decay2.ar(
		Trig.ar(t_gate, sustain),
		atk,
		dcy
	);

	sig = Saw.ar(XLine.ar(frqStart, frqEnd, frqTime), env) ** sawPow;
	sig = BRF.ar(sig, 20 + [brfFreq1, brfFreq2], rq);
	sig = sig * globalEnv;
	sig = LeakDC.ar(sig).tanh;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick_oto309_Sd, { arg out=0, amp=0.5, pan=0, attack = 0, release = 1.2, sustain = 1, curve = 1, globalEnvPow = 1, globalEnvNoise = 0.1, globalEnvInv = 0, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.5, env0L4 = 0, env0T1 = 0.005, env0T2 = 0.06, env0T3 = 0.26, env0Crv1 = (-4), env0Crv2 = (-2), env0Crv3 = (-4), env1L1 = 110, env1L2 = 59, env1L3 = 29, env1T1 = 0.005, env1T2 = 0.29, env1Crv1 = (-4), env1Crv2 = (-5), t_gate = 1, doneAction = 2;
	var env0, env1, env1m, son, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, curve), t_gate, timeScale: sustain, doneAction: doneAction).pow(globalEnvPow);
	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range(0.1, 1).lag(0.02);

	globalEnv = Select.ar(globalEnvInv, [globalEnv, globalEnv.neg]);

	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [env0Crv1, env0Crv2, env0Crv3]));
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [env1Crv1, env1Crv2]));
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2 * globalEnv;
	son = son.clip2(1);

	// OffsetOut.ar(out, Pan2.ar(son * amp, pan));
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\IkedaBassSusSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.2, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, sustain = 1, envCurve = (-5), freq = 0, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, gate = 1, doneAction = 2;
	var env, sin, sig;
	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, timeScale: sustain, doneAction: doneAction);
	sin = SinOsc.ar(freq, (Sweep.ar(gate, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickRingz_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.2, sustain = 1, envPow = 1, clickCurve = (-4), clickInScale = 1, clickEnvPow = 1, clickHpf = 80, clickHpRq = 1, clickLpf = 13000, clickLpRq = 1, clickAmp = 1, envL1 = 0.1, envL2 = 1.2, envL3 = 3, envL4 = 2.1, envL5 = 0.1, envT1 = 0.1, envT2 = 0.2, envT3 = 0, envT4 = 0.1, curve = (-4), envpL1 = 0.1, envpL2 = 1.2, envpL3 = 3, envpL4 = 2.1, envpT1 = 0.1, envpT2 = 0, envpT3 = 1.2, curvep = (-4), freq = 40, dcy = 0.25, ffreq = 1000, doneAction = 2;
	var globalEnv, snd, env, envp, envClick, click;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	envClick = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum, clickCurve), timeScale: sustain, levelScale: clickInScale).pow(clickEnvPow);
	click = RHPF.ar(envClick, clickHpf, clickHpRq);
	click = RLPF.ar(click, clickLpf, clickLpRq);
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

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickMistSusSd, { arg out = 0, level = 1, pan = 0, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, sustain = 1, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, curve0_1 = (-4), curve0_2 = (-2), curve0_3 = (-4), env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, curve1_1 = (-4), curve1_2 = (-5), doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [curve0_1, curve0_2, curve0_3]), timeScale: sustain, doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [curve1_1, curve1_2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0);
	sig = sig.clip2(1);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig * env0, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\kickMist_Sd, { arg out = 0, level = 1, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, curve0_1 = (-4), curve0_2 = (-2), curve0_3 = (-4), env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, curve1_1 = (-4), curve1_2 = (-5), doneAction = 2;
	var env0, env1, env1m, sig, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [curve0_1, curve0_2, curve0_3]), timeScale: sustain, doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [curve1_1, curve1_2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0);
	sig = sig.clip2(1);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig * env0 * globalEnv, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\kickhi_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, vcaLev1 = 0.5, vcaLev2 = 0.1, vcaLev3 = 0.01, vcaLev4 = 0.01, vcaLev5 = 0, vcaTime1 = 0.01, vcaTime2 = 0.5, vcaTime3 = 1.26, vcaTime4 = 0.1, vcaCurve1 = (-4), vcaCurve2 = (-2), vcaCurve3 = (-4), vcfLev1 = 122, vcfLev2 = 30, vcfLev3 = 33, vcfLev4 = 28, vcfTime1 = 0.05, vcfTime2 = 0.29, vcfTime3 = 1, vcfCurve1 = (-4), vcfCurve2 = (-5), tu = 1, sinLev = 16, sinFreq = 1, doneAction = 2;
	var env0, env1, env1m, sig, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	env0 =  EnvGen.ar(Env.new([vcaLev1, vcaLev2, vcaLev3, vcaLev4, vcaLev5], [vcaTime1, vcaTime2, vcaTime3, vcaTime4].normalizeSum * sustain, [vcaCurve1, vcaCurve2, vcaCurve3]));
	env1 = EnvGen.ar(Env.new([vcfLev1, vcfLev2, vcfLev3, vcfLev4], [vcfTime1, vcfTime2, vcfTime3].normalizeSum * sustain, [vcfCurve1, vcfCurve2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m * tu, 0, 0.5, 1, -0.5);
	sig = out + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m * 1.5, env0);
	sig = sig * 1.2;
	sig = sig.clip2(1);
	sig = sig + SinOsc.ar(env1m * tu + sinFreq, 0.5, env0 * sinLev);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	sig = LeakDC.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick2newSusSd,{arg out = 0, amp = 1, pan = 0, att = 0, sustain = 1, rel = 1, envfT1 = 0.002, envfT2 = 0.1, freq = 60, tu = 1.33, bpeqf1 = 3081, bpeqrq1 = 0.71, bpeqamp1 = (-54), bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 81, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.perc(att, rel), gate, timeScale: sustain, doneAction: doneAction);
    var frequ = EnvGen.ar(Env([freq+1100, freq, 31.4],[envfT1, envfT2]));
    var sig = SinOsc.ar(frequ*tu, 0, env);
    sig = BPeakEQ.ar(sig, bpeqf1, bpeqrq1, bpeqamp1);
    sig = sig * env;
    sig = BPeakEQ.ar(sig, bpeqf2, bpeqrq2, bpeqamp2);
    //sig = Limiter.ar(sig,0.5);
    //Out.ar(6,[DelayL.ar(sig*(-1),0.1,SinOsc.kr(-0.1,0,0.05,0.1)),sig]);
	sig = HPF.ar(sig, hpff);
	// sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick2new_Sd,{arg out = 0, amp = 1, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, envfT1 = 0.002, envfT2 = 0.1, freq = 60, tu = 1.33, bpeqf1 = 3081, bpeqrq1 = 0.71, bpeqamp1 = (-54), bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 81, gate = 1, doneAction = 2;
	var globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    var frequ = EnvGen.ar(Env([freq+1100, freq, 31.4],[envfT1, envfT2]));
    var sig = SinOsc.ar(frequ*tu, 0, globalEnv);
    sig = BPeakEQ.ar(sig, bpeqf1, bpeqrq1, bpeqamp1);
    sig = sig * globalEnv;
    sig = BPeakEQ.ar(sig, bpeqf2, bpeqrq2, bpeqamp2);
    //sig = Limiter.ar(sig,0.5);
	sig = HPF.ar(sig, hpff);
	// sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t1kick2SusSd, {arg out = 0, amp = 0.5, pan = 0, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = (-4), envfT1 = 0, envfL1 = 10000, envfT2 = 0.2, envfL2 = 20, envfT3 = 1, envfL3 = 0, envfT4 = 1.4, envfL4 = 4, envfCurve = (-4), pitch = 0.1, hpfFreq = 1200, hpfRq = 1, envT1 = 0.012, envL1 = 0, envT2 = 0.0012, envL2 = 1, envT3 = 0.12, envL3 = 0.1, envCrv = (-4), envPow = 1, envInv = 0, lvlScale = 1, attFreq = 440, verbMix = 1, verbRoom = 1, verbDamp = 0.5, sustain = 1, doneAction = 2;
	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), timeScale: sustain, doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve), doneAction: doneAction);
	var sig = SinOsc.ar(envf+50*pitch, 0, enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = BHiPass4.ar(sig.distort, hpfFreq, hpfRq);
	sig = sig + HPF.ar(EnvGen.ar(Env.pairs([[envT1, envL1], [envT2, envL2], [envT3, envL3]], envCrv), levelScale: lvlScale).pow(envPow) * envInv.linlin(0, 1, 1, -1) * PinkNoise.ar(0.3!2).range( 0.1, 1 ).lag(0.01), attFreq);
	revSig = FreeVerb.ar(sig, verbMix, verbRoom.max(0.01), verbDamp);
	sig = SelectX.ar(verbMix, [sig, revSig]);
	// sig = Pan2.ar(sig, pan, amp*enva);
	// OffsetOut.ar(out, sig);
	sig = LeakDC.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp*enva));
}).add;

SynthDef(\kickmedSusSd, { | out = 0, level = 0.5, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0, sustain = 1, doneAction = 2|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0,0.5],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2,env1T3,env1T4],[curve1, curve2, curve3]);
	env0 = EnvGen.ar(env0, timeScale: sustain, doneAction: doneAction);
	env1 = EnvGen.ar(env1);
	env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);
	son = SelectX.ar(ochoose.mod(5),[son,son2,son3,son4]);
	son = LeakDC.ar(son,dc,30);
	son = son + WhiteNoise.ar(noise);
	son = LPF.ar(son, env1m*fratio.max(0.01), env0);
	son = son + SelectX.ar(owhich2.mod(5),[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son = son*level.distort;
	// son = Pan2.ar(son, pan);
	// OffsetOut.ar(out, son*level).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level)).tanh;
	//OffsetOut.ar(snd, Mono(son)*level).tanh;
}).add;

SynthDef(\kickmed_Sd, { | out = 0, amp = 0.3, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, level = 0.5, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.0001, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, doneAction = 2 |
	var globalEnv, env0, env1,
	env1m, son, son2, son3, son4, p2;
	p2 = phase * (-pi);
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	env0 = Env([env0L1, env0L2, env0L3, env0L4, 0],[atkEnv0, decEnv0, relEnv0, 0.05], [curve1, curve2, curve3]);
	env1 = Env([env1L1, env1L2, env1L3], [env1T1, env1T2], curve1);
	env0 = EnvGen.ar(env0);
	env1 = EnvGen.ar(env1);
	env1m = env1.midicps;
	son = LFSaw.ar(env1m, 0, oamp, 1, 1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1, 1.4);
	son3 = LFPulse.ar(env1m, 0, oamp, 1, 1.4);
	son4 = LFTri.ar(env1m, 0, oamp, 1, 1.4);
	son = SelectX.ar(ochoose.mod(5), [son, son2, son3, son4]);
	son = LeakDC.ar(son,dc,30);
	son = son + WhiteNoise.ar(noise);
	son = LPF.ar(son, env1m * fratio.max(0.01), env0);
	son = son + SelectX.ar(owhich2.mod(5),[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son = son * level.distort;
	// son = Pan2.ar(son, pan);
	// OffsetOut.ar(out, son*level).tanh;
	OffsetOut.ar(out, DirtPan.ar(son * globalEnv, ~dirt.numChannels, pan, amp)).tanh;
}).add;

SynthDef(\kick808newSusSd, { arg out = 0, amp = 0.5, pan = 0, envL1 = 1, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, envCurve = (-8), enfL1 = 5000, enfL2 = 100, enfL3 = 50, enfT1 = 0.0001, enfT2 = 0.01, enfCurve = (-4), tu = 2, sin2Frq = 10, sin2Amp = 50, sustain = 1, doneAction = 2;
    var env = EnvGen.ar(Env([envL1, envL2, envL3],[envT1, envT2], -8), timeScale: sustain, doneAction: doneAction);
    var enf  = EnvGen.ar(Env([enfL1, enfL2, enfL3],[enfT1, enfT2, 0.1], enfCurve));
    var sig = SinOsc.ar(tu*(enf))*env;
    sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(sin2Frq, 0, sin2Amp, 40*tu), 0, 0.01) * env, 100);
    sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out,sig*env);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kicklaserbeamSusSd, { arg out = 0, amp = 0.3, pan = 0.0, frq = 13007, freqenvL1 = 3.97, freqenvL2 = 5, freqenvL3 = 0, freqenvL4 = 2.97, freqenvT1 = 0.16, freqenvT2= 0.07, freqenvT3= 0.26, ampenvL1 = 1, ampenvL2 = 1, ampenvL3 = 0, ampenvL4 = 0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, sustain = 1, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3]),
		levelScale: amp,
		timeScale: sustain,
		doneAction: doneAction);
	snd = LFTri.ar(frq * freqenv, 0, ampenv);
	snd = BHiPass4.ar(snd, hpfFreq, hpfRq);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickParallaxSusSd, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, kharm1 = 1, kharm2 = 2, kharm3 = 3, kharm4 = 4, kamp1 = 0.05, kamp2 = 0.05, kamp3 = 0.05, kamp4 = 0.05, kring1 = 1, kring2 = 1, kring3 = 1, kring4 = 1, frqScale = 1, decScale = 1, resoMix = 0.5, sustain = 1, doneAction = 2;
	var sig, env_amp, env_freq, kharm, kamp, kring, reso;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, timeScale: sustain, doneAction: doneAction);

	env_freq = Env.perc (envFrqAtt, envFrqRel, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq + (44100 ** env_freq), 0, env_amp);

	// harmonics
	kharm = [kharm1, kharm2, kharm3, kharm4];
    // amplitudes
	kamp = [kamp1, kamp2, kamp3, kamp4];
    // ring times
	kring = [kring1, kring2, kring3, kring4];

    //reso = Klank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	reso = DynKlank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	sig = SelectX.ar(resoMix, [sig, reso]);
	// sig = Pan2.ar (sig, pan);
	// OffsetOut.ar (out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickParallax_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, kharm1 = 1, kharm2 = 2, kharm3 = 3, kharm4 = 4, kamp1 = 0.05, kamp2 = 0.05, kamp3 = 0.05, kamp4 = 0.05, kring1 = 1, kring2 = 1, kring3 = 1, kring4 = 1, frqScale = 1, decScale = 1, resoMix = 0.5, doneAction = 2;
	var sig, env_freq, kharm, kamp, kring, reso, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	env_freq = Env.perc (envFrqAtt, envFrqRel, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq + (44100 ** env_freq), 0, globalEnv);

	// harmonics
	kharm = [kharm1, kharm2, kharm3, kharm4];
    // amplitudes
	kamp = [kamp1, kamp2, kamp3, kamp4];
    // ring times
	kring = [kring1, kring2, kring3, kring4];

    //reso = Klank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	reso = DynKlank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	sig = SelectX.ar(resoMix, [sig, reso]);
	// sig = Pan2.ar (sig, pan);
	// OffsetOut.ar (out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\rc808KickSusSd, {
    arg out = 0, pan = 0, dcy = 30, amp = 0.3, gate = 0, tone = 56, sustain = 1, doneAction = 2;
    var fenv, env, trienv, sig, sub, punch, pfenv;
    env = EnvGen.kr(Env.new([0.11, 1, 0], [0, dcy], -225), timeScale: sustain, doneAction:2);
    trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, dcy], -230), doneAction:0);
    fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
    pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
    sig = SinOsc.ar(fenv, pi/2) * env;
    sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
    punch = SinOsc.ar(pfenv, pi/2) * env * 2;
    punch = HPF.ar(punch, 350);
    sig = (sig + sub + punch) * 2.5;
    sig = Limiter.ar(sig, 0.5) * amp;
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosKickSusSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
	// sub controls
	startsubfreq = 60, endsubfreq = 32, linesubdur = 0.08, subdecay = 0.2, sublowpass = 500,
	// drum controls
	drumFreq = 50, drumHarmonic = 2, drumSweep = 0.02, drumAtt = 0.005, drumRel = 0.4, curve = (-4),
	drumFilter = 1000, modIndex = 6.5, modFreq = 5,
	// beater controls
	beaterFreq = 500, beaterHarmonic = 12, beaterSweep = 0.03, noiseMod = 500, beaterL1 = 0, beaterL2 = 1, beaterL3 = 2.4, beaterL4 = 0, beaterT1 = 0.01, beaterT2 = 0.3, beaterT3 = 0.08,
	// click controls
	clkffreq = 500, clkres = 0,
	gate = 1, sustain = 1, doneAction = 2;

	var subfreq, sub, drumEnv, drumContour, drum, beaterContour, beaterEnv, beater, snd, click, envClick;

	subfreq = XLine.kr(startsubfreq, endsubfreq, linesubdur, 1, 0);

	sub = LPF.ar(Ringz.ar(Impulse.ar(0), subfreq, subdecay), sublowpass) * subamp;

	drumEnv = Env.perc(attackTime: drumAtt, releaseTime: drumRel, curve: curve).kr;

	sub = sub * drumEnv;

	drumContour = Line.kr(start: drumFreq * drumHarmonic, end: drumFreq, dur: drumSweep);

	drum = PMOsc.ar(
		carfreq: drumContour,
		modfreq: modFreq,
		pmindex: modIndex,
		mul: drumAmp
	);

	drum = LPF.ar(in: drum, freq: Lag2.kr(drumFilter), mul: drumEnv);

	beaterEnv = Env([beaterL1, beaterL2, beaterL3, beaterL4], [beaterT1, beaterT2, beaterT3]).kr;

	beaterContour = Line.kr(start: (beaterFreq * beaterHarmonic).min(20000), end: beaterFreq, dur: beaterSweep);

	beater = HPF.ar(in: WhiteNoise.ar(LFNoise0.kr(noiseMod)), freq: beaterFreq);

	beater = LPF.ar(in: beater, freq: beaterContour, mul: beaterEnv) * beaterAmp;

	envClick = EnvGen.kr(Env.step([700, 0], [0.0007, 0.1]), gate, 0.002);
	click = Hasher.ar(Sweep.ar(gate, 0.000001)) * envClick;
	click = MoogLadder.ar(click, clkffreq, clkres) * EnvGen.kr(Env.perc(0.0001, 0.00001), gate, clickAmp);

	snd = Mix.ar(sub + drum + beater + click) * amp;

	snd = snd * EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);
    //DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosKick_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
	// sub controls
	startsubfreq = 60, endsubfreq = 32, linesubdur = 0.08, subdecay = 0.2, sublowpass = 500,
	// drum controls
	drumFreq = 50, drumHarmonic = 2, drumSweep = 0.02, drumAtt = 0.005, drumRel = 0.4, crv = (-4),
	drumFilter = 1000, modIndex = 6.5, modFreq = 5,
	// beater controls
	beaterFreq = 500, beaterHarmonic = 12, beaterSweep = 0.03, noiseMod = 500, beaterL1 = 0, beaterL2 = 1, beaterL3 = 2.4, beaterL4 = 0, beaterT1 = 0.01, beaterT2 = 0.3, beaterT3 = 0.08,
	// click controls
	clkffreq = 500, clkres = 0,
	doneAction = 2;

	var gate, subfreq, sub, drumEnv, drumContour, drum, beaterContour, beaterEnv, beater, snd, click, envClick, globalEnv;

	gate = Impulse.kr(0);

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	subfreq = XLine.kr(startsubfreq, endsubfreq, linesubdur, 1, 0);

	sub = LPF.ar(Ringz.ar(Impulse.ar(0), subfreq, subdecay), sublowpass) * subamp;

	drumEnv = Env.perc(attackTime: drumAtt, releaseTime: drumRel, curve: crv).kr;

	sub = sub * drumEnv;

	drumContour = Line.kr(start: drumFreq * drumHarmonic, end: drumFreq, dur: drumSweep);

	drum = PMOsc.ar(
		carfreq: drumContour,
		modfreq: modFreq,
		pmindex: modIndex,
		mul: drumAmp
	);

	drum = LPF.ar(in: drum, freq: Lag2.kr(drumFilter), mul: drumEnv);

	beaterEnv = Env([beaterL1, beaterL2, beaterL3, beaterL4], [beaterT1, beaterT2, beaterT3]).kr;

	beaterContour = Line.kr(start: (beaterFreq * beaterHarmonic).min(20000), end: beaterFreq, dur: beaterSweep);

	beater = HPF.ar(in: WhiteNoise.ar(LFNoise0.kr(noiseMod)), freq: beaterFreq);

	beater = LPF.ar(in: beater, freq: beaterContour, mul: beaterEnv) * beaterAmp;

	envClick = EnvGen.kr(Env.step([700, 0], [0.0007, 0.1]), gate, 0.002);
	click = Hasher.ar(Sweep.ar(gate, 0.000001)) * envClick;
	click = MoogLadder.ar(click, clkffreq, clkres) * EnvGen.kr(Env.perc(0.0001, 0.00001), gate, clickAmp);

	snd = Mix.ar(sub + drum + beater + click) * amp;

	snd = snd * globalEnv;

    //DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\drumkickSusSd, { arg out = 0, amp = 0.5, pan = 0.0, atk = 0.0001, rls = 0.09, curve = 8, attSinFreq = 0.0001, relSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, attBpfFreq = 0.001, relBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineLevBpf = 0.1, gate = 1, sustain = 1, doneAction = 2;
	var source;

	source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, relSinFreq, levSin, curveSinFreq), gate, 1000, 45), 1, 1) +
	((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, relBpfFreq, levBpf, curveBpf), gate, levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineLevBpf)) * EnvGen.kr(Env.perc(atk, rls, curve: curve), gate, timeScale: sustain, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(source, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\drumkick_Sd, { arg out = 0, amp = 0.5, pan = 0.0, attack = 0.0001, release = 0.09, curve = 8, sustain = 1, envPow = 1, attSinFreq = 0.0001, relSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, levScaleSin = 1000, levBiasSin = 45, attBpfFreq = 0.001, relBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineDurBpf = 0.1, doneAction = 2;
	var source, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, relSinFreq, levSin, curveSinFreq), levScaleSin, levBiasSin.max(0.1)), 1, 1);
	source = source + ((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, relBpfFreq, levBpf, curveBpf), levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineDurBpf)) * globalEnv;

	// OffsetOut.ar(out, Pan2.ar(source, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tabassSusSd, { arg out = 0, amp = 0.8, pan = 0, gate = 1, atk = 0.01, rls = 2, frq = 1, lfnFrq = (1/2), sustain = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, timeScale: sustain, doneAction: doneAction);
	sig = LFTri.ar(frq) * Impulse.kr(0);
	20.do{
		sig = BAllPass.ar(sig,80,1);
		sig = ((sig+0.02)*LFNoise0.kr(lfnFrq).range(0.1, 0.98)*6).tanh;
		sig = LeakDC.ar(sig,0.995);
	};
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickBlocksSusSd, { arg out = 0, amp = 0.4, pan = 0, curve = (-4),
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
	cfreq = 6100, crq = 1, camp = 1.41, sustain = 1,
	doneAction = 2;

    var env, snd, noise, tone1, tone2, hit1, hit2, click;

	env = EnvGen.kr(Env.linen(0.01, 1, 6), timeScale: sustain, doneAction: doneAction);
	noise = Hasher.ar(Sweep.ar); //deterministic white noise

    tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide),
		mul: Env.perc(attackTime: t1att, releaseTime: t1rel, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide),
		mul: Env.perc(attackTime: t2att, releaseTime: t2rel, level: t2amp, curve: t2curve).delay(t2del).ar);

    hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide),
		rq: h1rq,
		mul: Env.perc(attackTime: h1att, releaseTime: h1rel, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide),
		mul: Env.perc(attackTime: h2att, releaseTime: h2rel, level: h2amp, curve: h2curve).delay(h2del).ar);

	click = BPF.ar(
		in: Impulse.ar(0) * SampleRate.ir / 44100,
		freq:  cfreq,
		rq: crq,
		mul: camp);

	snd = Mix.ar(tone1 + tone2 + hit1 + hit2 + click).tanh * amp;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd * env, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\kickBlocks_Sd, { arg out = 0, amp = 0.4, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1,
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

    var globalEnv, snd, noise, tone1, tone2, hit1, hit2, click;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	noise = Hasher.ar(Sweep.ar); //deterministic white noise

    tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide),
		mul: Env.perc(attackTime: t1att, releaseTime: t1rel, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide),
		mul: Env.perc(attackTime: t2att, releaseTime: t2rel, level: t2amp, curve: t2curve).delay(t2del).ar);

    hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide),
		rq: h1rq,
		mul: Env.perc(attackTime: h1att, releaseTime: h1rel, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide),
		mul: Env.perc(attackTime: h2att, releaseTime: h2rel, level: h2amp, curve: h2curve).delay(h2del).ar);

	click = BPF.ar(
		in: noise * EnvGen.kr(Env.step([1, 0], [cdur, cdur * 0.01]), levelScale: camp),
		freq:  cfreq,
		rq: crq
	);

	snd = Mix.ar(tone1 + tone2 + hit1 + hit2 + click).tanh * amp;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd * env, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, globalEnv));
}).add;

SynthDef(\tweetKickIntSusSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, impfreq = 2, phRate = 64, lagFreq = 2, inAmt = 99, coef1 = 0.9, coef2 = 0.99, sustain = 1, doneAction = 2;
	var sig, freq, phase, env, i;
	i = Impulse.ar(_);
	freq = i.(impfreq).lagud(0,0.4)*360;
	phase = Integrator.ar(
		Integrator.ar(
			i.(phRate).lag(LFNoise1.ar(lagFreq!2,2,2)) * inAmt,
			coef1
		),
		coef2
	).fold2(pi);
	env = EnvGen.kr(Env.linen(attack, 1, release), timeScale: sustain, doneAction: doneAction);
	sig = SinOsc.ar(freq, phase, env);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetKickInt_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, sustain = 1, curve = (-4), envPow = 1, impfreq = 2, phRate = 64, lagFreq = 2, inAmt = 99, coef1 = 0.9, coef2 = 0.99, doneAction = 2;
	var sig, freq, phase, globalEnv, i;
	i = Impulse.ar(_);
	freq = i.(impfreq).lagud(0,0.4)*360;
	phase = Integrator.ar(
		Integrator.ar(
			i.(phRate).lag(LFNoise1.ar(lagFreq!2,2,2)) * inAmt,
			coef1
		),
		coef2
	).fold2(pi);
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	sig = SinOsc.ar(freq, phase, globalEnv);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickbassSusSd, { | out = 0, level = 0.5, pan = 0, attack = 0.01, decay = 0.2, release = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, sustain = 1, done = 2 |
	var env0,env1,
env1m, son, son2,son3,son4,p2;

	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[attack,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0,SinOsc.kr(0.025), timeScale: sustain, doneAction: done);
	env1 = EnvGen.ar(env1);
env1m = env1.midicps;

son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = Pan2.ar(son,pan);
son = LeakDC.ar(son,dc,30);

	son = LPF.ar(son+ WhiteNoise.ar(1*noise), env1m*fratio.max(0.01), env0);

	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, [p1,p2], env0), LFSaw.ar(env1m, [p1,p2], env0), LFPulse.ar(env1m, [p1,p2], env0), LFTri.ar(env1m, [p1,p2], env0)]);
	son = LPF.ar(son,filter.max(150)+SinOsc.kr(2,0.5,200));
son = son * 1;
//son = son.clip2(1);
son = son * level.distort;
// son = Pan2.ar(son, pan, level);
// OffsetOut.ar(out, son).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level)).tanh;
}).add;

SynthDef(\batuhan_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 1.5, sustain = 1, curve = (-4), envPow = 1, eSawDec = 0.6, eSinL1 = 0, eSinL2 = 1, eSinL3 = 0, eSinL4 = 0.32, eSinT1 = 0.24, eSinT2 = 0.02, eSinT3 = 0.12, eSinC1 = (-4), eSinC2 = (-4), eSinC3 = (-4), sinFreq = 33, sawMix = 1, sawFreq = 8, bpfFreq = 162, bpfRq = 1, bpfMix = 0, brfFreq1 = 45.1, brfFreq2 = 45, brfRq = 1, doneAction = 2;
	var sig, trig, envSaw, envSin, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	trig = Impulse.kr(0);
	envSaw = Decay2.kr(
		trig,
		0.01,
		eSawDec
	);
	envSin = EnvGen.kr(Env.new([eSinL1, eSinL2, eSinL3, eSinL4], [eSinT1, eSinT2, eSinT3].normalizeSum, [eSinC1, eSinC2, eSinC3]), trig, timeScale: sustain);
	sig = ((Saw.ar(sawFreq, envSaw) ** 1.5) * sawMix) + (SinOsc.ar(sinFreq, 0, envSin) * (1 - sawMix));
	sig = (sig * (1 - bpfMix)) + (BPF.ar(sig, bpfFreq, bpfRq.max(0.01)) * bpfMix);
	sig = BRF.ar(sig, trig * 20 + [brfFreq1, brfFreq2], brfRq.max(0.01));
	sig = Splay.ar(sig, levelComp: false);
	sig = LeakDC.ar(sig).tanh;
	sig = HPF.ar(sig, 28);
	//sig = (sig[0] + sig[1])!2; // mono
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, globalEnv * amp));
}).add;

SynthDef(\kickBoomySusSd, { arg out = 0, amp=1, pan = 0, atk = 0.0014, rls=0.4, curve = (-5), frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, envT1 = 0.012, envL1 = 0, envT2 = 0.0012, envL2 = 1, envT3 = 0.12, envL3 = 0.1, envCrv = (-4), lvlScale = 1, hpfFreq = 500, gain=1.1, sustain = 1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, timeScale: sustain, doneAction: doneAction);
	sig = (SinOsc.ar(frq1/4) + SinOsc.ar(frq2/4) + LFTri.ar(frq3/4) + LFTri.ar(frq4/4) + BrownNoise.ar(0.1)) * env * amp;
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.pairs([[envT1, envL1], [envT2, envL2], [envT3, envL3]], envCrv), levelScale: lvlScale), hpfFreq);
	sig = sig * gain;
	sig = sig.softclip * 1;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\ringkickSusSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, dcy = 2.63, lpfFreq = 13760, frq = 26, envfL1 = 6416.9, envfL2 = 0, envfL3 = 66.2, envfL4 = 20, envfL5 = 0, envfT1 = 0, envfT2 = 0.04, envfT3 = 0.53, envfT4 = 2.37, curve = (-4.92), envfAmt = 0.32, lfnFrq = 59.2, lfnAmt = 0, ringAmp = 0.04, sawFreq = 20.7, sawPh = 6.18, sawDecDiv = 7, sawAmp = 0.18, sinFreq = 10010, sinFb = 0, sinDecDiv = 188, sinAmp = 0.29, sustain = 1, doneAction = 2;
	var snd, env, trig, envf, mod;
	mod = LFNoise2.kr(lfnFrq, lfnAmt).range(1, lfnAmt);
	env = EnvGen.kr(Env.linen(atk, 1, dcy), doneAction: doneAction);
	envf = EnvGen.kr(Env([envfL1, envfL2, envfL3, envfL4, envfL5], [envfT1, envfT2, envfT3, envfT4], [curve, curve/2, curve]), levelScale: envfAmt * mod, timeScale: sustain);
	trig = Impulse.ar(0);
	snd = Ringz.ar(
		in: LPF.ar(
			in: trig,
			freq: lpfFreq
		),
		freq: frq * envf.range(1, envfAmt), /*+ (frq * envf)*/
		decaytime: dcy,
		mul: 7 * ringAmp
	).tanh.sin*2;

	snd = snd + SawDPW.ar(sawFreq, sawPh, Decay.ar(trig, dcy / sawDecDiv) * sawAmp);

	snd = snd + SinOscFB.ar(sinFreq * envf.range(1, envfAmt), sinFb, Decay.ar(trig, dcy / sinDecDiv) * sinAmp);

	snd = snd * env;
	// OffsetOut.ar(out, snd * amp);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ringkick_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 1.6, sustain = 1, curve = (-4), envPow = 1, dcy = 0.2, lpfFreq = 13760, frq = 26, envfL1 = 6416.9, envfL2 = 0, envfL3 = 66.2, envfL4 = 20, envfL5 = 0, envfT1 = 0, envfT2 = 0.04, envfT3 = 0.53, envfT4 = 2.37, envfAmt = 0.32, lfnFrq = 59.2, lfnAmt = 0, ringAmp = 0.04, sawFreq = 20.7, sawPh = 6.18, sawDecDiv = 7, sawAmp = 0.18, sinFreq = 10010, sinFb = 0, sinDecDiv = 188, sinAmp = 0.29, doneAction = 2;
	var snd, globalEnv, trig, envf, mod;
	mod = LFNoise2.kr(lfnFrq, lfnAmt).range(1, lfnAmt);
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	envf = EnvGen.kr(Env([envfL1, envfL2, envfL3, envfL4, envfL5], [envfT1, envfT2, envfT3, envfT4], [curve, curve/2, curve]), levelScale: envfAmt * mod);
	trig = Impulse.ar(0);
	snd = Ringz.ar(
		in: LPF.ar(
			in: trig,
			freq: lpfFreq
		),
		freq: frq * envf.range(1, envfAmt), /*+ (frq * envf)*/
		decaytime: dcy,
		mul: 7 * ringAmp
	).tanh.sin*2;

	snd = snd + SawDPW.ar(sawFreq, sawPh, Decay.ar(trig, dcy / sawDecDiv) * sawAmp);

	snd = snd + SinOscFB.ar(sinFreq * envf.range(1, envfAmt), sinFb, Decay.ar(trig, dcy / sinDecDiv) * sinAmp);

	snd = snd * globalEnv;
	// OffsetOut.ar(out, snd * amp);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickeySusSd,{ arg out = 0, amp = 0.3, pan = 0, att = 0.0014, rel = 0.8, curve = (-5), startFreq = 60, endFreq = 10, linedur = 0.8, decay = 0.8, lowpass = 500, rq = 1, gain = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, sustain = 1, doneAction = 2;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, linedur, 1, 0);
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, timeScale: sustain, doneAction: doneAction);
	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
	sig = sig * gain;
	// sig = sig.softclip * amp * env;
	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * env;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickey_Sd,{ arg out = 0, amp = 0.3, pan = 0, attack = 0.0014, release = 0.8, sustain = 1, curve = (-5), envPow = 1, startFreq = 60, startFreqMod = 6, endFreq = 10, endFreqMod = 3, linedur = 0.8, decay = 0.8, lowpass = 500, rq = 1, sat = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, doneAction = 2;
	var sig, globalEnv, freq;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	freq = XLine.kr(PinkNoise.kr(startFreqMod, startFreq), PinkNoise.kr(endFreqMod, endFreq), linedur, 1, 0);
	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
	sig = sig * sat;

	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * globalEnv;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickySusSd,{ arg out = 0, amp=1, pan = 0, startFreq=80, endFreq=15, length=6, decay=4, lowpass=800, softclip=1, sustain = 1, doneAction = 2;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), length, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, length, 1, -5), 1, timeScale: sustain, doneAction: doneAction);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = sig * softclip;
	sig = sig.softclip * amp * env;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kicky_Sd,{ arg out = 0, amp=1, pan = 0, attack = 0.014, release = 1.4, sustain = 1, curve = (-4), envPow = 1, startFreq=80, endFreq=15, decay=4, lowpass=1500, sat = 1, doneAction = 2;
	var sig, globalEnv, freq;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), sustain, 1, 0);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,lowpass))*0.3;
	sig = sig * sat;
	sig = sig.softclip * amp * globalEnv;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick808AwSusSd, {arg out = 0, amp = 0.2, pan = 0, freqSrt = 240, freqEnd = 60, freqTime = 0.1, ringTime = 100, envpT1 = 0, envpL1 = 0, envpT2 = 0.2, envpL2 = 1, envpT3 = 0.4, envpL3 = 0.2, envpT4 = 0.4, envpL4 = 0, envpCurve = (-4), dist = 1.5, hpfFreq = 30, tott = 1, durr = 0.01, gate = 1, sustain = 1, doneAction = 2;
    var snd, env;
	tott = tott.max(0.01);
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freqSrt, freqEnd, freqTime),
		decaytime: ringTime
	);
	env = EnvGen.ar(Env.pairs([[envpT1, envpL1], [envpT2, envpL2], [envpT3, envpL3], [envpT4, envpL4]], envpCurve), gate, timeScale: sustain, doneAction: doneAction);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	snd = HPF.ar(snd, hpfFreq);
	snd = Limiter.ar(snd, tott, durr.max(0.01)) * 0.5 *(1/tott);
	//snd = Clip.ar(snd, -1 * tott, tott);
	//snd = Fold.ar(snd, -1 * tott, tott);
	//snd = Wrap.ar(snd, -1 * tott, tott);
	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef.new(\bd808Horiuchi_Sd, { arg out = 0, amp = 2, pan = 0, attack = 0, release = 0.921, sustain = 1, curve = (-6.843224515159), envPow = 1, decay = 0.921, tone = 56, doneAction = 2;
    var fenv, globalEnv, trienv, sig, sub, punch, pfenv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, decay], -230), doneAction: 0);
    fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
    pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
    sig = SinOsc.ar(fenv, pi/2) * globalEnv;
    sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
    punch = SinOsc.ar(pfenv, pi/2) * globalEnv * 2;
    punch = HPF.ar(punch, 350);
    sig = (sig + sub + punch) * 2.5;
    sig = Limiter.ar(sig, 0.5) * amp;
    // sig = Pan2.ar(sig, pan);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  HiHat

SynthDef(\haten_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.0001, release = 1.3, sustain = 1, curve = (-4), envPow = 1, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, mixNoise = 0.5, sinFreq = 200, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	env = EnvGen.kr(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt).range(0.1, 1), envT3, envT4].normalizeSum), timeScale: sustain);
	sig = (WhiteNoise.ar(amp) * mixNoise) + (FSinOsc.ar(sinFreq) * (1 - mixNoise));
	sig = (LFSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\haten1SusSd, { arg out = 0, amp = 0.06, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, curve = (-4), mixNoise = 0.5, sinFreq = 142, sinAmp = 0.2, fsinFreq = 200, fsinAmp = 0, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, sustain = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4], curve), timeScale: sustain, doneAction: 2);
	sig = (WhiteNoise.ar(1) * mixNoise) + ((SinOsc.ar(sinFreq, 0, sinAmp) + FSinOsc.ar(fsinFreq, 0, fsinAmp)) * (1 - mixNoise));
	sig = (VarSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env * amp;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\haten1_Sd, { arg out = 0, amp = 0.06, pan = 0, attack = 0, release = 1.4, sustain = 1, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, curve = (-4), mixNoise = 0.5, sinFreq = 142, sinAmp = 0.2, fsinFreq = 200, fsinAmp = 0, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4], curve));
	sig = (WhiteNoise.ar(1) * mixNoise) + ((SinOsc.ar(sinFreq, 0, sinAmp) + FSinOsc.ar(fsinFreq, 0, fsinAmp)) * (1 - mixNoise));
	sig = (VarSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env * amp;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;

SynthDef(\hatnew_Sd, {|out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.9, envT4 = 0.03, envModCrv = (-4), envModPow = 1, envModNoise = 0.3, freq = 230, rhpf = 8500, rhpfRq = 1, doneAction = 2|
	var pulse, sig, globalEnv, freqs, envMod, rhpfFreq;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	envMod = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum, envModCrv), timeScale: sustain).pow(envModPow);

	envMod = envMod * PinkNoise.ar(envModNoise).range(0.1, 1).lag(0.002);

	envMod = envMod;

	freqs = [freq, freq * 1.4471, freq * 1.617, freq * 1.9265, freq * 2.5028, freq * 2.6637];
	pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6));
	rhpfFreq = rhpf * envMod;
	sig = RHPF.ar(RHPF.ar(pulse, rhpfFreq), rhpfFreq, rhpfRq) * globalEnv;
	// sig =  Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out,sig);
	sig = LeakDC.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\fabHi1SusSd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatt = 0.001, envSrel = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envL4 = 0, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, sustain = 1, ffreq = 6000, gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin, delay;
	envNoise = EnvGen.kr(Env.perc(envNatt, envNrel), gate);
	envSin = EnvGen.kr(Env.perc(envSatt, envSrel), gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]).kr(timeScale: sustain, doneAction: doneAction);
	sig = HPF.ar(sig * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\fabHi1_Sd, {arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, envNcurve = (-4), envNpow = 1, wbpfFreq = 2800, wbpfRq = 1, sawFrq = 2120, sinFrq = 12423, sawPh = 0, sinPh = 0.02, sawLev = 1, sinLev = 1, mix = 0.5, clickInScale = 40, envSatt = 0.001, envSrel = 0.2, envScurve = (-4), envSpow = 1, clickHpf = 322, clickRq = 1, clickPow = 1, clickAmp = 1, ffreq = 6000, gate = 1, doneAction = 2;
	var globalEnv, noise, saw, sin, click, sig, envNoise, envOsc, delay;
	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	globalEnv = globalEnv * WhiteNoise.ar(0.3 + [0, 0.1]).range(0.1, 1).lag(0.02);

	envNoise = EnvGen.ar(Env.perc(envNatt, envNrel, curve: envNcurve), gate).pow(envNpow);
	envOsc = EnvGen.kr(Env.perc(envSatt, envSrel, curve: envScurve), gate).pow(envSpow);

	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));

	click = RHPF.ar((envNoise * clickInScale).pow(clickPow), clickHpf, clickRq, clickAmp);

	saw = VarSaw.ar(sawFrq, sawPh, mul: sawLev);
	sin = SinOsc.ar(sinFrq, sinPh, sinLev);

	sig = XFade2.ar(noise * envNoise, Mix.ar([saw, sin]) * envOsc, mix);
	sig = HPF.ar(sig, ffreq);
	sig = Mix.ar([sig, click]) * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hiSin_Sd, {arg out = 0, amp = 1, pan = 0, attack = 0.0001, sustain = 1, release = 1.2, curve = (-4), envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, envT1 = 0.02, envT2 = 0.12, envT3 = 0.01, envLev = 15, envPow = 1, envDivDur = 1, theta = 0.5, rho = 0.8, a0 = 1, a1 = 0, a2 = 0, filterfreq = 1000, rq = 1.0, selectMod = 0, sinFreq = 12000, sinAmp = 0.3, modFreq = 0.2, doneAction = 2;
	var env, globalEnv, click, b1, b2, signal, mod;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.ar(Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]), levelScale: envLev, timeScale: sustain / envDivDur).pow(envPow);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	click = SOS.ar(env, a0, a1, a2, b1, b2);
	click = RHPF.ar(click, filterfreq, rq);
	mod = SelectX.kr(selectMod.mod(3), [LFNoise0.kr(modFreq), LFNoise1.kr(modFreq), LFNoise2.kr(modFreq)]);
	signal = ((SinOsc.ar(sinFreq, mul: sinAmp) * mod.range([0, 0.1], 1.0) * env) + click) * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\metro_Sd, {arg out = 0, amp = 1, pan = 0, attack = 0, release = 2, sustain = 1, curve = (-4), envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, envT1 = 0.02, envT2 = 0.12, envT3 = 0.01, envT4 = 0, envDivDur = 1, theta = 0.5, rho = 0.8, filterfreq = 1000, rq = 1.0, doneAction = 2;
	var globalEnv, env, signal, b1, b2;
	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.ar(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2, envT3, envT4]), timeScale: sustain / envDivDur);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	signal = SOS.ar(env, 1.0, 0.0, 0.0, b1, b2) * env;
	signal = RHPF.ar(signal, filterfreq, rq);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\metro1_Sd, {arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, impFreq=1, theta = 0.5, rho = 0.8, filterfreq=1000, rq=1.0, doneAction = 2;
	var globalEnv, signal, b1, b2;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	signal = SOS.ar(Impulse.ar(impFreq, 0, globalEnv), 1.0, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal, filterfreq, rq);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\haty48_Sd,{ arg out = 0, amp = 0.75, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, envaL1 = 1.81, envaL2 = 0, envaL3 = 2.52, envaL4 = 0.85, envaL5 = 0, envaT1 = 0.01, envaT2 = 0.02, envaT3 = 0, envaT4 = 0, envaCrv = 3.54, envpL1 = 0, envpL2 = 16936, envpL3 = 1279, envpL4 = 0, envpT1 = 0, envpT2 = 0.33, envpT3 = 0, envpT4 = 0.53, envpCrv = (-0.64), modFreq = 1, modAmt = 1.4, sinfAdd = 1.7, sinPhase = 0.28, sinpAdd = 1.7, sinAddAmp = 1, rf1Freq = 16938.8, rf1Rq = 0.26, rf2Freq = 765, rf2Rq = 0.62, hpfFreq = 3699, doneAction = 2;
	var mod, globalEnv, enva, envp, sig;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	enva = EnvGen.kr(Env([envaL1, envaL2, envaL3, envaL4, envaL5], [envaT1, envaT2, envaT3, envaT4], [envaCrv, envaCrv / 2, envaCrv.neg]), timeScale: sustain);
	envp = EnvGen.kr(Env.circle([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3, envpT4], [envpCrv, envpCrv * 2 , envpCrv.neg, envpCrv / 2]), timeScale: sustain);
	mod = LFNoise0.ar(modFreq * envp.range(0.1, 4), modAmt * enva).range(1, modAmt);
	sig = SinOsc.ar([envp, envp + sinfAdd], [sinPhase, (sinPhase + sinpAdd)], [1, sinAddAmp]);
	sig = Resonz.ar(sig, [rf1Freq, rf2Freq] * mod, [rf1Rq, rf2Rq], enva);
	sig = HPF.ar(sig, hpfFreq);
	sig = (sig[0] + sig[1]) * globalEnv;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hat808SusSd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, atk = 0.01, rls = 0.1, sustain = 1, envPow = 1, envNoiseFrq1 = 0.3, envNoiseFrq2 = 0.33, envNoiseVol = 0.3, envInv = 0, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(atk, rls), timeScale: sustain, doneAction: doneAction);
	env = env.pow(envPow) * LFNoise0.kr([envNoiseFrq1, envNoiseFrq1] , envNoiseVol).range(0.1, 1);

	env = Select.kr(envInv, [env, env.neg]);

	sig = Saw.ar((1..9)*1000.23*env*tu);
	sig = RHPF.ar(sig, \rhpfFreq.kr(5700), \rhpfRq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1), rls, -4), timeScale: sustain))*tu;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \rhpf1Freq.kr(2000)*env*tu, \rhpf1Rq.kr(0.5));
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sosHatsSusSd, { arg out = 0, amp = 0.8, pan = 0, frq = 6000, curve = -4, rootIndex = 238.5, rq = 1,
	// Initial envelopes
	initAtt = 0.005, initRel = 0.1, initAmp = 1, initStart = 15000, initEnd = 9000,
	// Body envelopes
	bodyAtt = 0.005, bodyRel = 0.1, bodyAmp = 1, bodyStart = 9000, bodyEnd = 12000,
	// General envelope
	envAtt = 0.01, envRel = 1, envCurve = (-4), sustain = 1,
	doneAction = 2;

	var root, initialEnv, initialSweep, initial, bodyEnv, bodySweep, body, snd;

	root = Pulse.ar(freq: frq, width: 0.5, mul: 1);

	root = PMOsc.ar(
		carfreq: root,
		modfreq: frq * [1.34, 2.405, 3.09, 1.309],
		pmindex: rootIndex * [1, 0.22, 0.014, 0.0038]
	);

	root = Mix.new(root);

	initialEnv = Env.perc(attackTime: initAtt, releaseTime: initRel, curve: curve).kr;

	initialSweep = Line.kr(start: initStart, end: initEnd, dur: initRel);

	initial = BPF.ar(in: root, freq: initialSweep, rq: rq, mul: initialEnv * initAmp);

	bodyEnv = Env.perc(attackTime: bodyAtt, releaseTime: bodyRel, curve: curve / 2).kr;

	bodySweep = Line.kr(start: bodyStart, end: bodyEnd, dur: bodyRel);

	body = HPF.ar(in: root, freq: bodySweep, mul: bodyEnv * bodyAmp);

	snd = Mix.ar([initial, body]) * amp;

	snd = snd * EnvGen.kr(Env.perc(envAtt, envRel, curve: envCurve), timeScale: sustain, doneAction: doneAction);
    // DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosHats_Sd, { arg out = 0, amp = 0.8, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, frq = 6000, crv = (-4), rootIndex = 238.5, rq = 1,
	// Initial envelopes
	initAtt = 0.005, initRel = 0.1, initAmp = 1, initStart = 15000, initEnd = 9000,
	// Body envelopes
	bodyAtt = 0.005, bodyRel = 0.1, bodyAmp = 1, bodyStart = 9000, bodyEnd = 12000,
	doneAction = 2;

	var root, initialEnv, initialSweep, initial, bodyEnv, bodySweep, body, snd, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	root = Pulse.ar(freq: frq, width: 0.5, mul: 1);

	root = PMOsc.ar(
		carfreq: root,
		modfreq: frq * [1.34, 2.405, 3.09, 1.309],
		pmindex: rootIndex * [1, 0.22, 0.014, 0.0038]
	);

	root = Mix.new(root);

	initialEnv = Env.perc(attackTime: initAtt, releaseTime: initRel, curve: crv).kr;

	initialSweep = Line.kr(start: initStart, end: initEnd, dur: initRel);

	initial = BPF.ar(in: root, freq: initialSweep, rq: rq, mul: initialEnv * initAmp);

	bodyEnv = Env.perc(attackTime: bodyAtt, releaseTime: bodyRel, curve: crv / 2).kr;

	bodySweep = Line.kr(start: bodyStart, end: bodyEnd, dur: bodyRel);

	body = HPF.ar(in: root, freq: bodySweep, mul: bodyEnv * bodyAmp);

	snd = Mix.ar([initial, body]) * amp;

	snd = snd * globalEnv;
    // DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Cymbal

SynthDef(\cymbalicMcldSusSd, { |out=0, amp=0.5, pan=0, atk = 0.0001, sustain = 1, rls = 0.2, attLowf = 0.5, relLowf = 5, lowNoiseLev = 0.1, attHif = 1, relHif = 3, hiNoiseLev = 0.1, attHi = 1, relHi = 2, hiLev = 0.25, attTh = 0.001, relTh = 0.001, freq1 = 627, freq2 = 2961, freq3 = 7824, freq4 = 476, gate = 1, doneAction = 2|
	var env, lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

	env = EnvGen.kr(Env.perc(atk, rls), gate, timeScale: sustain, doneAction: doneAction);
	locutoffenv = EnvGen.kr(Env.perc(attLowf, relLowf), gate) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, relHif), gate) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
	hidriver = hidriver * EnvGen.kr(Env.perc(attHi, relHi, hiLev));

	thwack = EnvGen.kr(Env.perc(attTh,relTh), gate);

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	//freqs  = {exprand(300, 20000)}.dup(100);

	freqs = [freq1, freq2, freq3, freq4] /** LFNoise2.kr(0.002, 0.5, 0.5)*/;

	res = Ringz.ar(
		lodriver + hidriver + thwack,
		freqs
	).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymbalicMcld_Sd, { |out=0, amp=0.5, pan=0, attack = 0.0001, release = 0.9, sustain = 1, curve = (-4), envPow = 1, attLowf = 0.5, relLowf = 5, lowNoiseLev = 0.1, attHif = 1, relHif = 3, hiNoiseLev = 0.1, attHi = 1, relHi = 2, hiLev = 0.25, attTh = 0.001, relTh = 0.001, freq1 = 627, freq2 = 2961, freq3 = 7824, freq4 = 476, doneAction = 2|
	var globalEnv, lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	locutoffenv = EnvGen.kr(Env.perc(attLowf, relLowf)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, relHif)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
	hidriver = hidriver * EnvGen.kr(Env.perc(attHi, relHi, hiLev));

	thwack = EnvGen.kr(Env.perc(attTh,relTh));

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	//freqs  = {exprand(300, 20000)}.dup(100);

	freqs = [freq1, freq2, freq3, freq4] /** LFNoise2.kr(0.002, 0.5, 0.5)*/;

	res = Ringz.ar(
		lodriver + hidriver + thwack,
		freqs
	).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cym_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-8), envPow = 1, tu = 1, doneAction = 2;
	var sig;
	var globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var freqs = geom(100, 50, 1.3434) * 10.234567 * Lag3.kr(tu);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig, freqs).mean;
	// sig = Pan2.ar(sig * env, pan, amp);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cym1_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-8), envPow = 1, freqStart = 50, freqGrow = 1.3434, tu = 1, ringzDec = 1, doneAction = 2;
	var sig;
	var globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var freqs = geom(75, freqStart, freqGrow) * 10.234567 * Lag3.kr(tu);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig, freqs, ringzDec).mean;
	// sig = Pan2.ar(sig * env, pan, amp);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymnew1_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envT1 = 0.12, envT2 = 0.02, envT3 = 0.23, tu = 6, freqStart = 40, freqGrow = 1.0471975511966, doneAction = 2;
    var sig;
	var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3].normalizeSum, curve), timeScale: sustain);
	var freqs = geom(48, freqStart, freqGrow)*10.234567*tu;
	sig = WhiteNoise.ar(0.2) * env;
    sig = Ringz.ar(sig, freqs,1).mean;

    // sig = Pan2.ar(sig*env, pan);
    // OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymbal808ryan_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, baseFreq = 300, penvL1 = 1.0, penvL2 = 0.6, ptime = 250, pcurve = (-0.5), pulsew = 0.55, rlpfFrq = 7000, rlpfRq = 0.6, rhpfFrq = 6800, rhpfRq = 1.5, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envL5 = 0, envT1 = 2, envT2 = 250, envT3 = 50, envT4 = 500, envC1 = 0, envC2 = (-0.5), envC3 = 0, envC4 = (-50), doneAction = 2;
	var freqs = [baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523];
	//var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
	//var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
	//var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];
	var signal, pulseEnv, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	pulseEnv = EnvGen.kr(Env.new([penvL1, penvL2], [ptime], [pcurve]), timeScale:(1/1000));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
	signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width: pulsew)) * 0.9);
	signal = RLPF.ar(signal, rlpfFrq, rlpfRq);
 	signal = RHPF.ar(signal, rhpfFrq, rhpfRq);
	signal = signal * EnvGen.kr(Env.new([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum, [envC1, envC2, envC3, envC4]), timeScale: sustain); // (1/1000));
	// signal = [signal, DelayN.ar(signal, 0.005, 0.005)];
	// OffsetOut.ar(out, signal*4*amp);
	OffsetOut.ar(out, DirtPan.ar(signal * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymbal808_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0.002, release = 1.3, sustain = 1, curve = (-4), envPow = 1, dcy = 0.25, freqMultiplier = 4.09, decLevel = 0.4, reverb = 0.33, size = 0.5, damp = 0.5, doneAction = 2;
	var snda, sndb, snd, env, pulseEnv, globalEnv, freqs;

	freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	pulseEnv = Env.new(
		levels: [1.0, 0.6],
		times: dcy,
		curve: -0.5
	).kr;

	snd = Mix.ar(LFPulse.ar(freq: freqs * freqMultiplier));

	snd = (BinaryOpUGen('==', snd, 6.0) * 0.6) + (BinaryOpUGen('==', snd, 2.0) * 0.2) + (BinaryOpUGen('==', snd, 1.0) * 0.9);

	snd = (snd * pulseEnv) + Mix.ar(LFPulse.ar(freq: freqs, width: 0.55, mul: 0.9));

	snd = RLPF.ar(in: snd, freq: \rlpfFreq.kr(7000), rq: \rlpfRq.kr(0.6));
	snd = RHPF.ar(in: snd, freq: \rhpf1Freq.kr(6800), rq: \rhpf1Rq.kr(1.5));
	snd = RHPF.ar(in: snd, freq: \rhpf2Freq.kr(6800), rq: \rhpf2Rq.kr(1.5));
	snd = RHPF.ar(in: snd, freq: \rhpf3Freq.kr(1200), rq: \rhpf3Rq.kr(1.5));

	snd = snd + FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp);
	snd = Mix.ar(snd);
	snd = snd * globalEnv * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Clap

SynthDef(\oneclap_thor_Sd, {arg out = 0, amp = 0.1,  pan = 0, attack = 0.003, release = 1.35, sustain = 1, curve = (-4), envPow = 1, filterfreq = 1000, rq = 0.1, doneAction = 2;
	var globalEnv, signal, noise1, noise2, hpf1, hpf2, sinStart, sinEnd, sinDur;
	sinStart = \sinStart.kr(1);
	sinEnd = \sinEnd.kr(0.01);
	sinDur = \sinDur.kr(4);
	noise1 = WhiteNoise.ar(\noise1Amp.kr(1)) + SinOsc.ar([filterfreq/2, filterfreq / 2 + 4 ], pi * 0.5, XLine.kr(sinStart, sinEnd, sinDur));
	noise2 = PinkNoise.ar(\noise2Amp.kr(1)) + SinOsc.ar([(filterfreq) * XLine.kr(sinStart, sinEnd, sinDur), (filterfreq + 4) * XLine.kr(sinStart, sinEnd, sinDur) ], pi * 0.5, XLine.kr(sinStart, sinEnd, sinDur));
	hpf1 = RLPF.ar(noise1, filterfreq, rq);
	hpf2 = RHPF.ar(noise2, filterfreq/2, rq/4);
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	signal = (hpf1 + hpf2) * globalEnv;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031) + CombC.ar(signal, 0.5, 0.03016, 0.06);
	// signal = Decay2.ar(signal, 0.5);
	signal = FreeVerb.ar(signal, 0.23, 0.15, 0.2);
	// DetectSilence.ar(signal, doneAction:2);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\clapGray_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, atk = 0.001, rls = 0.25, crv = (-4), spreadRate = 75, minDelay = 0.025, maxDelay = 0.05, decay = 0.15, rq = 0.4, blend = 0.7, reverb = 0.1, size = 0.25, damp = 1, doneAction = 2;
	var env1, env2, snd, noise1, noise2, spread, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	//Multiple Shorter Claps
	spread = LFNoise1.kr(spreadRate).range(minDelay, maxDelay);

	env1 = Env.perc(attackTime: atk / 10, releaseTime: rls / 8, curve: [0, crv]).kr;
	env1 = CombC.ar(in: env1, maxdelaytime: maxDelay, delaytime: spread, decaytime: decay);

	noise1 = GrayNoise.ar(env1); //Play with frequencies here:
	noise1 = RHPF.ar(in: noise1, freq: 1000, rq: rq);
	noise1 = BPF.ar(in: noise1, freq: 2000, rq: 3);

	//One Longer Clap
	env2 = Env.perc(attackTime: atk, releaseTime: rls, curve: [0, crv]).kr;

	noise2 = GrayNoise.ar(env2); //Play with frequencies here:
	noise2 = RHPF.ar(in: noise2, freq: 1200, rq: rq);
	noise2 = BPF.ar(in: noise2, freq: 1400, rq: 0.7);

	//Mixing and light Reverb
	snd = Mix.ar((blend * noise1) + ((1 - blend) * noise2));
	snd = (snd * 2).softclip;
	snd = FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp, mul: amp);

	// DetectSilence.ar(in: snd, doneAction: doneAction);
	snd = LeakDC.ar(snd) * globalEnv;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapping_Sd, {arg out = 0, amp=0.5, pan = 0, attack = 0.01, release = 1, sustain = 1, curve = (-4), envPow = 1, envNoiseVol = 0, noiseAmp = 1, filterfreq=120, rq=0.1, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, doneAction=2;
	var globalEnv, signal, noise, hpf1, hpf2, fx;
	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([filterfreq/2,filterfreq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
	hpf1 = RLPF.ar(noise, lpfFreq, rq);
	hpf2 = RHPF.ar(noise, hpfFreq, rq/4);
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow) * PinkNoise.ar(envNoiseVol).range(0.1, envNoiseVol).lag(0.02);
	signal = Mix.ar(hpf1 + hpf2) * globalEnv;
	fx = CombC.ar(signal, 0.5, delTimeL, delDecL)+CombC.ar(signal, 0.5, delTimeR, delDecR);
	// signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
	// signal = Limiter.ar(signal, 0.7, 0.01) * amp;
	signal = (signal * (1 - delMix)) + (fx * delMix) ;
	signal = signal * globalEnv;
	// DetectSilence.ar(signal, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\clapy_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0.01, release = 1, sustain = 1, curve = (-4), envPow = 1, atk = 0.02, rls = 0.3, crv1 = 0, crv2 = (-4), hpf1 = 600, hpf2 = 1000, bpf1 = 2000, bpf2 = 1200, gain = 1.5, doneAction = 2;
	var env1, env2, globalEnv, sig, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [atk, rls], [crv1, crv2]), doneAction: doneAction);

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), hpf1), bpf1, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), hpf2), bpf2, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = 0.4 * sig.softclip * amp;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapthan_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 1, sustain = 1, curve = (-4), envPow = 1, envL1 = 0, envL2 = 1, envL3 = 0.5, envL4 = 1, envL5 = 0.5, envL6 = 1, envL7 = 0, envT1 = 0.001, envT2 = 0.01, envT3 = 0.001, envT4 = 0.01, envT5 = 0.001, envT6 = 0.01, crv = 0, hpfFrq = 1024, hpfRq = 0.3, doneAction = 2;
    var snd, env, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5, envL6, envL7], [envT1, envT2, envT3, envT4, envT5, envT6], crv));
    snd = RHPF.ar(Hasher.ar(Sweep.ar), hpfFrq, hpfRq);
    snd = snd * env;
	/*snd = Pan2.ar(snd, pan, amp);
    OffsetOut.ar(out, snd);*/
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Noise

SynthDef(\tweetFogAttackSusSd, { arg out = 0, amp = 1, pan = 0, sustain = 1, sigatt = 0.01, sigdec = 3.16, feedBack = 0.2, freq = 0.8, gate = 1, doneAction = 2;
	var sig, env, coef, sigenv;
	sig = Pulse.ar(freq*(pi/[1,2.57]),[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig * feedBack);
	sigenv = EnvGen.kr(Env.asr(sigatt, 1, sigdec), gate, timeScale: sustain);
	sig = (sig.mean!2) * sigenv;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetFogAttack_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 1, sustain = 1, curve = (-4), envPow = 1, feedBack = 0.2, freq = 0.8, doneAction = 2;
	var sig, env, coef, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	sig = Pulse.ar(freq*(pi/[1,2.57]),[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig * feedBack);
	sig = (sig.mean) * globalEnv;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\attBreathSusSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, seqv1 = 1, seqv2 = 1, seqv3 = 4, seqv4 = 2, seqv5 = 2, seqFreq = 0.2, freqMin = 250, freqMax = 800, bwrMod = 0.5, gate = 1, sustain = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, timeScale: sustain, doneAction: doneAction);
	// env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = TDuty.kr(Dseq([seqv1, seqv2, seqv3, seqv4, seqv5] * seqFreq, inf));
	sig = Resonz.ar(
		Crackle.ar(sig.range(0.6, 1.6))!2,
		Demand.kr(sig, 0, Dseq([freqMin, freqMax], inf)),
		Demand.kr(sig, 0, Dwhite(0.01,0.5, inf)) * bwrMod
	);
	sig = sig * env;
	// sig = Compander.ar(sig, sig, 0.4, 1, 1/3);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\complexoscSusSd, { arg out = 0, amp = 1, pan = 0, feedBack = 1, envL1 = 0, envL2 = 2.2, envL3 = 0.12, envL4 = 0, envT1 = 0.01, envT2 = 0.24, envT3 = 0.12, sustain = 1, envCurve = (-4), freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, gate = 1, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, env, sigenv;
    fbk = LocalIn.ar(2) * feedBack;
	//env = Linen.kr(gate, attack, 1, release, doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, timeScale: sustain, doneAction: doneAction);
    osc1 = SinOsc.ar(freq1 + (fbk[1].range(1,1000) * fm1), 0 + (fbk[1].range(-pi,pi) * pm1), amp1 + (fbk[1] * ring1), offset1);
    osc2 = SinOsc.ar(freq2 + (fbk[0].range(1,1000) * fm2), 0 + (fbk[1].range(-pi,pi) * pm2), amp2 + (fbk[0] * ring2), offset2);
    LocalOut.ar([osc1, osc2]);
    folded = Fold.ar(osc1 ! 2, fold.neg, fold);
    wrapped = Wrap.ar(osc1 ! 2, wrap.neg, wrap);
    outlet = LeakDC.ar(Select.ar(switch, [osc1!2, osc2!2, folded, wrapped]));
    // OffsetOut.ar(out, outlet * env * amp);
	OffsetOut.ar(out, DirtPan.ar(outlet, ~dirt.numChannels, pan, amp * env));
}, [\kr ! 12, \ar ! 15, \kr, \tr, \ir].flat).add;

SynthDef(\complexosc_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.3, sustain = 1, curve = (-4), envPow = 1, feedBack = 1, freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, sigenv, globalEnv;
    fbk = LocalIn.ar(2) * feedBack;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    osc1 = SinOsc.ar(freq1 + (fbk[1].range(1,1000) * fm1), 0 + (fbk[1].range(-pi,pi) * pm1), amp1 + (fbk[1] * ring1), offset1);
    osc2 = SinOsc.ar(freq2 + (fbk[0].range(1,1000) * fm2), 0 + (fbk[1].range(-pi,pi) * pm2), amp2 + (fbk[0] * ring2), offset2);
    LocalOut.ar([osc1, osc2]);
    folded = Fold.ar(osc1 ! 2, fold.neg, fold);
    wrapped = Wrap.ar(osc1 ! 2, wrap.neg, wrap);
	outlet = LeakDC.ar(Select.ar(switch.wrap(0, 3), [osc1!2, osc2!2, folded, wrapped]));
    // OffsetOut.ar(out, outlet * env * amp);
	OffsetOut.ar(out, DirtPan.ar(outlet, ~dirt.numChannels, pan, amp * globalEnv));
}, [\kr ! 8, \ar ! 15, \kr, \ir].flat).add;

SynthDef(\mutantFricSusSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, sigFreq = 50, spring = 0.414, damp = 0.313, beltmass = 1, source = 0, hpfFreq = 50, gate = 1, sustain = 1, doneAction = 2;
	var friction, sig;
	friction = Array.fill(5, {
		[spec1.max(0.00001), spec2.max(0.03)].asSpec.map(LFNoise2.kr(noiseFreq))
	});
	sig = Select.ar(source, [
		LFTri.ar(sigFreq),
		LFPar.ar(sigFreq),
		LFCub.ar(sigFreq),
		LFSaw.ar(sigFreq),
		LFDNoise3.ar(sigFreq),
		LFDNoise0.ar(sigFreq)
	]);
	sig = Friction.ar(sig, friction, Lag2.kr(spring), damp, friction*30000, beltmass);
	sig = HPF.ar(sig, hpfFreq);
	sig = sig * EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, timeScale: sustain, doneAction: doneAction);

	// OffsetOut.ar(out, Splay.ar(sig * amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\noise_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 1.25, sustain = 1, curve = (-4), envPow = 1, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, doneAction = 2;
	var globalEnv =  EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var sig = LatoocarfianL.ar(
		SampleRate.ir/coeff,
		avar.max(-3).min(3),
		bvar.max(-3).min(3),
		cvar.max(0.5).min(1.5),
		dvar.max(0.5).min(1.5),
		xi,
		yi
	);
	sig = HPF.ar(sig,hpf);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig, DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*coeff);
	//sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\newNoise48SusSd,{arg out = 0, amp = 1, pan = 0, env0L1 = 0.1, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.2, env0T3 = 0.25, env0T4 = 0.25, offset = 0, sustain = 1, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, gate = 1, doneAction = 2;
var env0 =  EnvGen.ar(Env.step([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3, env0T4], offset), gate, timeScale: sustain, doneAction: doneAction);
var sig = LatoocarfianL.ar(
		SampleRate.ir/coeff,
		avar.max(-3).min(3),
		bvar.max(-3).min(3),
		cvar.max(0.5).min(1.5),
		dvar.max(0.5).min(1.5),
		xi,
		yi
	);
	sig = HPF.ar(sig,hpf);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig, DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*coeff);
	//sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh*env0;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\benjolisSusSd,{ |out = 0, amp = 0.1, pan = 0, atk = 0.00001, rls = 0.2, fadeTime = 0.01, freq1= 40, freq2=4, scaler=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, rq=0.82, gain=1, filterType=0, outSignal=6, sustain = 1, doneAction = 2|
	var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, output;
	var sr;
	var osc2freq, buf, bufR;

	bufR = LocalIn.ar(2,0);
	rungler = bufR.at(0);
	buf = bufR.at(1);

	sr = SampleDur.ir;
	//sr = ControlDur.ir;
	tri1 = LFTri.ar((rungler*rungler1)+freq1);
	tri2 = LFTri.ar((rungler*rungler2)+freq2);
	osc1 = PulseDPW.ar((rungler*rungler1)+freq1);
	osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

	//pwm = tri1 > tri2;
	pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

	osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
	sh0 = BinaryOpUGen('>', osc1, 0.5);
	sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
	sh0 = (sh0 * -1) + 1;

	sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
	sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
	sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
	sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
	sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
	sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
	sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
	sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

	//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
	//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

	rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

	buf = rungler;
	rungler = (rungler * scaler.linlin(0,1,0,127));
	rungler = rungler.midicps;

	LocalOut.ar([rungler,buf]);

	filt = Select.ar(filterType, [
		RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,0,gain),
		RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,1,0,0,0,0,gain),
		DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,gain,1)
	]);

	output = SelectX.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output = LeakDC.ar(output * amp ! 2);
	// OffsetOut.ar(out, output * EnvGate(fadeTime: fadeTime, doneAction: doneAction));
	output = output * EnvGen.kr(Env.asr(atk, 1, rls), 1, timeScale: sustain, doneAction: doneAction);
	OffsetOut.ar(out, DirtPan.ar(output, ~dirt.numChannels, pan));
}).add;

SynthDef(\benjolis_Sd,{ |out = 0, amp = 0.1, pan = 0, attack = 0.01, release = 4, sustain = 1, curve = (-4), envPow = 1, atk = 0.00001, rls = 0.2, fadeTime = 0.01, freq1= 40, freq2=4, scaler=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, rq=0.82, gain=1, filterType=0, outSignal=6, doneAction = 2|
	var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, output;
	var sr;
	var osc2freq, buf, bufR, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	bufR = LocalIn.ar(2,0);
	rungler = bufR.at(0);
	buf = bufR.at(1);

	sr = SampleDur.ir;
	//sr = ControlDur.ir;
	tri1 = LFTri.ar((rungler*rungler1)+freq1);
	tri2 = LFTri.ar((rungler*rungler2)+freq2);
	osc1 = PulseDPW.ar((rungler*rungler1)+freq1);
	osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

	//pwm = tri1 > tri2;
	pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

	osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
	sh0 = BinaryOpUGen('>', osc1, 0.5);
	sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
	sh0 = (sh0 * -1) + 1;

	sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
	sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
	sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
	sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
	sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
	sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
	sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
	sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

	//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
	//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

	rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

	buf = rungler;
	rungler = (rungler * scaler.linlin(0,1,0,127));
	rungler = rungler.midicps;

	LocalOut.ar([rungler,buf]);

	filt = Select.ar(filterType, [
		RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,0,gain),
		RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,1,0,0,0,0,gain),
		DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,gain,1)
	]);

	output = SelectX.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output = LeakDC.ar(output * amp ! 2);
	// OffsetOut.ar(out, output * EnvGate(fadeTime: fadeTime, doneAction: doneAction));
	output = output * globalEnv;
	OffsetOut.ar(out, DirtPan.ar(output, ~dirt.numChannels, pan));
}).add;

SynthDef(\lcm2SusSd, { arg out = 0, amp = 0.1, pan = 0, atk = 1, rls = 2, sustain = 1, envPow = 1, envNoiseFrq1 = 0.3, envNoiseFrq2 = 0.33, envNoiseVol = 0.3, envInv = 0, mod1 = 3.09431, mod2 = 54.0487, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

	env = EnvGen.kr(Env.perc(atk, rls), timeScale: sustain, doneAction: doneAction);
	env = env.pow(envPow) + LFNoise0.kr([envNoiseFrq1, envNoiseFrq1] , envNoiseVol);

	env = Select.kr(envInv, [env, env.neg]);

    mod1 = mod1.min(1000).max(1);
    mod2 = mod2.min(1000).max(1);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * env;

	sig = LeakDC.ar(sig);
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\lcm2_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0.001, release = 1.3, curve = (-4), sustain = 1, envPow = 1, envNoiseVol = 0.3, mod1 = 3.09431, mod2 = 54.0487, doneAction = 2;
    var sig, sig1, sig2, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	globalEnv = globalEnv.pow(envPow) * PinkNoise.kr(envNoiseVol).range([0.1, 0.14], 1).lag(0.02);

    mod1 = mod1.min(1000).max(1);
    mod2 = mod2.min(1000).max(1);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * globalEnv;

	sig = LeakDC.ar(sig);
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedMyst_Sd, { arg out = 0, amp = 0.6, pan = 0, attack = 0.01, release = 4, sustain = 1, curve = (-4), envPow = 1, pNoiseFreq = 0.5, hpfFreq = 10, modDur = 9, lfnFreq = 0.05, ringFreq = 55, ringDec = 0.2, revTime = 99, gate = 1, doneAction = 2;
	var sig, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
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
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\danScar_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = SinOsc.ar(sinFreq + [0, 0.1]);
    lfo = LFDNoise1.kr(noiseFreq).linexp(-1, 1, 0.5, 1);

    sig = LPF.ar(
        Fb1.ar(
            { |in, out| in[0] - (out[1] % lfo) },
            inSig, 2, blockSize: s.options.blockSize
        ),
        lpfFreq
    ) /** amp*/;

    // sig = Pan2.ar(sig, pan);

    // OffsetOut.ar(out, sig * globalEnv);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\danScar1_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = SinOsc.ar(sinFreq + [0, 0.1]);
    lfo = LFDNoise1.ar(noiseFreq).linexp(-1, 1, 0.5, 1);

    sig = LPF.ar(
         Fb1.ar(
            // in[0][0] is the current stereo sample of inSig
            // in[0][1] is the current mono sample of lfo
            { |in, out| in[0][0] - (out[1] % in[0][1]) },
            [inSig, lfo], 2, blockSize: s.options.blockSize
        ),
        lpfFreq
    ) /** amp*/;

    // sig = Pan2.ar(sig, pan);

    // OffsetOut.ar(out, sig * globalEnv);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\danScar2_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, triFreq = 60, noiseFreq = 0.5, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = LFTri.ar(triFreq);
    lfo = { LFDNoise3.ar(0.5).linexp(-1, 1, 0.1, 150) } ! 2;

    sig = Fb1.ar(
        // in[0][0] is the current stereo sample of inSig
        // in[0][1] is the current mono sample of lfo
        { |in, out| in[0][0] - (out[1] % in[0][1]) },
        [inSig, lfo], 2, blockSize: s.options.blockSize
    ) /** amp*/;

    // OffsetOut.ar(out, sig * globalEnv);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;*/

SynthDef(\natwich_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, modFreq = 0.4, modAmount = 0.8, sawFreq = 2100, rlpfFreq = 4000, rlpfRq = 0.1, doneAction = 2;
    var snd, fb, sig, globalEnv, mod1, mod2;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    mod1 = LFDNoise3.kr(modFreq, modAmount).range(0.1, 1.5);
    mod2 = LFDNoise0.kr(modFreq, modAmount).range(0.1, 1.5);

    fb = LocalIn.ar(1);
    snd = Saw.ar(sawFreq * mod1 * (fb * 48).midiratio);
    snd = RLPF.ar(snd, rlpfFreq * mod2 * (48 * (1 - fb)).midiratio, rlpfRq);
    snd = (snd * 3).fold2;
    sig = snd;
    snd = Amplitude.ar(ToggleFF.ar(PulseDivider.ar(snd, 3 * (1 + (100 * fb)))), 0.03, 0.3);
    LocalOut.ar(snd);
    snd = Pan2.ar(sig, pan) * amp * globalEnv;
    snd = Sanitize.ar(snd);
    snd = snd + (NHHall.ar(snd, 3) * -10.dbamp);

    // OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\noise2_Sd,{arg out = 0, amp = 1, pan = 0, attack = 0.0001, release = 1.3, sustain = 1, curve = (-4), envPow = 1, a = 4, doneAction = 2;
	var lfn1Freq = \lfn1Freq.kr(4);
	var lfn1Scale = \lfn1Scale.kr(1.5);
	var lfn2Freq = \lfn2Freq.kr(2);
	var lfn2Scale = \lfn2Scale.kr(0.5);
	var globalEnv =  EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
var sig = CuspN.ar(
		SampleRate.ir/a,
		LFNoise2.kr([lfn1Freq, lfn1Freq], lfn1Scale, lfn1Scale),
		LFNoise2.kr([lfn2Freq, lfn2Freq], lfn1Scale, lfn1Scale),
		LFNoise2.kr([lfn2Freq, lfn2Freq], lfn2Scale, lfn1Scale),
		LFNoise2.kr([lfn2Freq, lfn2Freq], lfn2Scale, lfn1Scale);
	);
	sig = HPF.ar(sig, \hpfFreq.kr(1000));
	sig = Limiter.ar(sig,0.4);
	sig = [sig, DelayL.ar(sig, 0.1, \delaytime.kr(100)/44100)];
	// sig = PitchShift.ar(sig, 0.2, a);
	sig = Compander.ar(sig,sig,0.01,1,0.01,0.01,0.1);
	// sig =  Pan2.ar(sig.tanh, pan, amp);
	// OffsetOut.ar(out,sig*env0);
	OffsetOut.ar(out, DirtPan.ar(sig.tanh, ~dirt.numChannels, pan, amp * globalEnv));
}).add;

SynthDef(\pnoise_Sd, {
    /*:the Perlin noise is sampled on a supertoroid 3d path with
    given major and minor radius. The shape is controled wit tMajor and sMinor.
    */
	/*
	1 < rMajor < 25
	1 < rMinor < 10
	0.25 < tMajor < 2.5
	0.25 < sMinor < 2.5
	1 < freq_u < 250
	1 < freq_v < 250
	0 < scaleX < 5
	0 < scaleY < 5
	0 < scaleZ < 5])
	*/
	arg out = 0, amp = 0.3, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, globalEnvNoise = 0.3, rMajor = 1, rMinor = 0.25, tMajor = 1, sMinor = 0.5, freq_u = 100, freq_v = 100, scaleX = 1, scaleY = 1, scaleZ = 1, doneAction = 2;
    var u, v, x, y, z, grey, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range([0.1, 0.12], 1.1).lag(0.02);

    //parametric supertoroid
    //u -> [  0   , 2*pi];
    //v -> [  0   , 2*pi];
    u = Phasor.ar(0, freq_u/SampleRate.ir, start: 0, end: 2*pi);
    v = Phasor.ar(0, freq_v/SampleRate.ir, start: 0, end: 2*pi);
    x = cos(u).sign*pow(abs(cos(u)),tMajor)*(rMajor+rMinor*cos(v).sign*pow(abs(cos(v)),sMinor));
    y = sin(u).sign*pow(abs(sin(u)),tMajor)*(rMajor+rMinor*cos(v).sign*pow(abs(cos(v)),sMinor));
    z = rMinor*sin(v).sign*pow(abs(sin(v)),sMinor);
    grey = Perlin3.ar(x/scaleX, y/scaleY, z/scaleZ);
	grey = grey * globalEnv;
    OffsetOut.ar(out, DirtPan.ar(grey, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ulysse42_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, mod1 = 0.2, mod2 = 0.71, doneAction = 2;
    var sig, sig1, sig2, sig3, z1, z2, sinFrq, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    mod1 = mod1.linlin(0, 1, -10, 10);
    sig1 = LFSaw.kr(0.062).range(-10, 10);
    sig1 = sig1 + (mod2.linlin(0, 1, 0, 5) * (0..8));
    sig2 = sig1.frac;
    sig3 = 0.8 - sig2.moddif(0.5, 1);

    z1 = gcd(sig1, mod1) + sig2;
    z2 = lcm(sig1, mod1) + sig2;
    sinFrq = 120 * ([z1, z2].flop.abs + 1);

    sig = (SinOsc.ar(sinFrq) * AmpComp.kr(sinFrq) * sig3).mean;
    // sig = Pan2.ar(sig * env, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDmFbGene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, ser1_1 = 0, ser1_2 = 1, ser1_3 = 2, ser1_4 = 3, ser1Size = 4, ser2_1 = 4, ser2_2 = 3, ser2_3 = 2, ser2_4 = 1, ser2_5 = 0, ser2Size = 5, add1 = 50, add2 = 50.1, modul = 50, sinFmin = 70, divisor = 10, sigSel = 0, fbSel = 0, doneAction = 2;
    var seq1, seq2, src1, src2, count1, count2, in, sinFrq, sig, sig1, sig2, sig3, sig4, sig5, fb, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	seq1 = Dseq([Dser([ser1_1, ser1_2, ser1_3, ser1_4], ser1Size.max(1))], inf);
	seq2 = Dseq([Dser([ser2_1, ser2_2, ser2_3, ser2_4, ser2_5], ser2Size.max(1))], inf);

    src1 = TDuty.ar(seq1 + add1 * SampleDur.ir);
    src2 = TDuty.ar(seq2 + add2 * SampleDur.ir);

    count1 = PulseCount.ar(src1) % modul;
    count2 = PulseCount.ar(src2) % modul;

    in = LocalIn.ar(2);
    sig1 = gcd(count1, count2 + [0, 1]);
    sinFrq = sig1.linexp(0, modul, sinFmin, 10000);
    sig2 = SinOsc.ar(sinFrq, 0, in / 2);
    sig3 = SinOsc.ar(sinFrq * (in / divisor + 1));
    sig4 = SinOsc.ar(sinFrq);
    sig5 = SinOsc.ar(sinFrq) + BPF.ar(in * 0.95, LFDNoise3.ar(0.2).range(100, 10000));

    sigSel = sigSel.min(3).max(0);
    sig = Select.ar(sigSel.mod(4), [sig2, sig3, sig4, sig5]);

    fbSel = fbSel.min(3).max(0);
	fb = Select.ar(fbSel.mod(4), [sinFrq.reverse, in.reverse, sig * in, sig]);
    LocalOut.ar(fb);

    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3) * globalEnv;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\addiditiveSin_Sd, { arg out = 0, amp = 0.9, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, sampleRate = 44100, doneAction = 2;
	var sig, globalEnv, buffAmp, numPartials = 50;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
			freq: ((i * 2) + 1) * \fund.kr(120, 0.5),
			//The i-th value of ~buffer_amplitudes is read with an Index Ugen
			mul: Index.ar(buffAmp, i)
		) / numPartials
	});

	/*sig = Pan2.ar(sig * globalEnv, pan, amp);

	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\fbDelNet_Sd, { arg out = 0, pan = 0, amp = 0.2, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, doneAction = 2;
    var trig = \trig.tr(1);
    var size, delTimes, delTimesSec, order;
    var sig, inSig, modEnv, gainEnv, delMod;
    var rotate, angle, matrix, householder4x4, givens2x2, kronecker, s, c;

    rotate = SinOsc.ar(\rotateFreq.kr(0.1)).linlin(-1, 1, 0, \rotateAmount.kr(55));
    angle = Phasor.ar(trig, rotate * SampleDur.ir, 0, 1) * 2pi;

    s = angle.sin;
    c = angle.cos;

    givens2x2 = [
        [ c, s.neg ],
        [ s,  c ]
    ];

    householder4x4 = [
        [ -0.5,  0.5,  0.5,  0.5 ],
        [  0.5, -0.5,  0.5,  0.5 ],
        [  0.5,  0.5, -0.5,  0.5 ],
        [  0.5,  0.5,  0.5, -0.5 ],
    ];

    matrix = givens2x2.collect { |x|
        x.collect { |y| householder4x4 * y }.reduce('+++')
    }.reduce('++');

    delMod = SinOsc.ar(2).linlin(-1, 1, 1, 4);

    gainEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    modEnv = EnvGen.ar(Env([0,1,0], [0.125, 0.5], [-8.0, -4.0]), trig);

	inSig = Saw.ar(XLine.kr(\startFreq.kr(100), \endFreq.kr(1000), \durFreq.kr(0.1))) * gainEnv;
    sig = Mix(inSig);

    order = 8;
    size = \size.kr(0.15) + modEnv.linlin(0, 1, 0, \sizeEnvAmount.kr(0.65));

	delTimes = order.collect({|i| ((i + 1) * 511).max(1000).nextPrime });
    delTimesSec = (delTimes * delMod) / 44100;

    sig = sig + LocalIn.ar(order);
    sig = DelayC.ar(sig, 0.5, delTimesSec * size - ControlDur.ir);
    sig = sig * \feedback.kr(0.9);
    sig = OnePole.ar(sig, \coef.kr(0.3));

    sig = sig * matrix.flop;
    sig = sig.sum;
    LocalOut.ar(sig);
    // OffsetOut.ar(out, Pan2.ar((inSig + Splay.ar(sig)), pan, amp) * 0.5);
	OffsetOut.ar(out, DirtPan.ar((inSig + Splay.ar(sig)), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\stochadiet1_Sd, {|out = 0, amp = 1, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, sdm = 1, mod = 0.005, from = 9, to = 12, min = 0.1, max = 0.3, doneAction = 2|
    var sig, globalEnv, sd = SampleDur.ir * sdm, hpf=40, mf=1.0;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    sig = HPF.ar(
        DemandEnvGen.ar(
            Dseq([min, min.neg, [max.neg, max]], inf),
            sd * Dseq([Lag.kr(from), Lag.kr(to), Dbrown(from, to, to, from.neg, from)], inf)
        ).fold2(SinOsc.ar(mod)) * mf,
        hpf
    );
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\stochadiet2_Sd, {|out = 0, amp = 0.5, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, sdm = 1, repeats = 32, from = 8, to = 30, min = 0.1, max = 0.9, doneAction = 2|
    var sig, globalEnv, sd = SampleDur.ir * sdm, mf=0.2;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    sig = DemandEnvGen.ar(
        Dseq([
            Dseq([0, 0.5], repeats),
            Dseq([-0.2, 0.8], repeats / 2),
            Dseq([-1.0, 1.0], Dwhite(repeats / 32, repeats)),
            Dseq([-0.8, 0.1], repeats / 16)
        ], inf),
        Dseq([
            Dwhite(from, to, [repeats, repeats * 0.5]),
            Dwhite(from / 1.5, to / 1.5, [repeats, repeats * 2]),
            Dbrown(from / 10, to / 10, from / 20, [repeats, repeats * 0.25])
        ], inf) * sd
    ) * mf;
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\stochadiet3_Sd, {|out = 0, amp = 0.2, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, step = 2, start = 1, from = 2, to = 5, sdm = 0.2, min = 0.1, max = 0.9, brownStep = 0.01, doneAction = 2|
    var sig, globalEnv, iter = 2, sd = SampleDur.ir * [sdm, sdm * 1.1], mf = 0.08;
    var levels = ({ Dseries(rrand(min.neg, max.neg), rrand(min, max), from * rrand(from, to)) } ! iter) ++
    ({ Dbrown(rrand(min.neg, max.neg), rrand(min, max), brownStep, to * 2) } ! iter);
    var times = { Dseries(rrand(start, start * 2), rrand(step, step * 2), rrand(from * 5, to * 4)) } ! (iter * 2);
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    sig = DemandEnvGen.ar(
        Dseq(levels, inf),
        Dseq(times, inf) * sd
    ) * mf;
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\stochadiet4_Sd, {|out = 0, amp = 1, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, sdm = 1, repeats = 4, from = 5, to = 18, mod = 60, doneAction = 2|
    var sig, globalEnv, length = 30, sd = SampleDur.ir * sdm, mf = 0.3;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    sig = DemandEnvGen.ar(
        Dseq([Dseries(-1.0, [0.04, 0.09], 30)], inf),
        Dseq([
            Dwhite(from, to, repeats),
            Dwhite(from / 1.5, to * 3, repeats)
        ], inf) * sd
    ).clip(SinOsc.ar(mod)) * mf;
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\stochadiet5_Sd, {|out = 0, amp = 0.4, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, filtSpeed = 10, filtCenter = 200, sdm = 1, modFreq = 0.01, filtBw = 3, lpf = 2500, doneAction = 2|
    var sig, globalEnv, size = 3, from = 1, to = 25, a = 9, b = 5, min = 0.1, max = 0.3;
    var sd = SampleDur.ir * sdm;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
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

///////////////////////////////////////  Tonal

SynthDef(\fakeResSusSd, {
    arg  out = 0, pan = 0, freq = 200, peamount = 900,
    pitchAtt = 0.001, pitchDec = 0.13,
    ampAtt = 0.03, ampDec = 1.0, level = 0.5, sustain = 1, doneAction = 2;

    var sig, sig1, sig2, ampenv, pitchenv, sig2Phase;

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
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\ambitek_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 0.9, curve = (-4), envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4), sawFreq = 50, delTime = 0.1, delDecay = 2, brfRq = 2, gate = 1, doneAction = 2;
	var sig, globalEnv, envS;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), gate, doneAction: doneAction);
	// env = Linen.kr(gate, attack, 1, release, doneAction);
	envS = EnvGen.kr(Env([envSL1, envSL2, envSL3, envSL4], [envST1, envST2, envST3], envSCurve));
	sig = Saw.ar(sawFreq * envS);
	2.do{|i|
		var f = 2 ** (8 - i);
		sig = BRF.ar(
			AllpassN.ar(sig, 1, Lag2.kr(delTime, 0.2) / (12 - i), delDecay),
			Lag2.ar(80 ** TRand.ar(0, 1, Impulse.ar(f / 32, 1/2)).lag(1 / f) * 80, 0.5),
			brfRq
		);
	};
	sig = sig * globalEnv;
	// OffsetOut.ar(out, sig!2 * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\main_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0.0, release = 2, sustain = 1, envPow = 1, curve = 1, levelScale = 1, levelBias = 0, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sin1Freq = 30, envL1 = 0, envL2 = 1, envL3 = 0.01, envL4 = 1.3, envL5 = 0, envT1 = 0.01, envT2 = 0, envT3 = 0.2, envT4 = 0.01, clickCurve = (-4), clickInScale = 1, clickEnvPow = 1, clickHpf = 80, clickHpRq = 1, clickLpf = 13000, clickLpRq = 1, clickAmp = 1, sel = 0, sin2Freq = 40, sin2Amp = 0.3, noiseAmp = 1, hpffreq = 8000, revtime = 3, room = 10, distAmt = 2, distMix = 0, doneAction = 2;
	var distSig, envClick, click;
	var fmod = SinOsc.ar(freq/60, 0, freq/60);
	var sig = [
		SinOsc.ar([freq, freq + 0.6] + fmod, 0, [lev, lev - 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpffreq),
		SinOsc.ar(sin1Freq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];

	var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), 1, levelScale, levelBias, sustain, doneAction).pow(envPow);

	envClick = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum * sustain, clickCurve), levelScale: clickInScale).pow(clickEnvPow);
	click = RHPF.ar(envClick, clickHpf, clickHpRq);
	click = RLPF.ar(click, clickLpf, clickLpRq);
	click = click * clickAmp;

	sig = (click + SelectX.ar(sel.wrap(0, 3), sig).fold(-1, 1) * 0.7 + SinOsc.ar(sin2Freq, 0, sin2Amp) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpffreq)));

	distSig = Clip.ar(sig * distAmt);
	sig = SelectX.ar(distMix, [sig, distSig]);
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\windowsyncSusSd, { |out = 0, pan = 0, freq = 65.40639132515, amp = 0.1,
    syncEgTop = 20, syncRatio = 2, syncDcy = 0.5, gate = 1, sustain = 1, doneAction = 2|
    var syncEg = EnvGen.kr(Env([syncEgTop / syncRatio, 1], [syncDcy], \exp));
    var eg = EnvGen.kr(Env.adsr(0.01, 0.3, 0.6, 0.1), gate, timeScale: sustain, doneAction: doneAction);
    var fundamental = LFTri.ar(freq);
    var syncFreq = freq * syncRatio * syncEg;
    // note, Phasor here is behaving like the Sweep above (retrigger behavior)
    // but Phasor loops around its range, eliminating the need for '% 1'
    var syncPhase = Phasor.ar(fundamental, syncFreq * SampleDur.ir, 0, 1, 0);
    var sig = SinOsc.ar(0, syncPhase * 2pi) * fundamental;
    // OffsetOut.ar(out, (sig * (amp * eg)).dup);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * eg));
}).add;

SynthDef(\danUk_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.3, sustain = 1, curve = (-4), envPow = 1, globalEnvNoise = 0.3, globalEnvInv = 0, sawFreq = 50, r = 12, doneAction = 2;
	var phi, x, y, sig, globalEnv, envShape;

	envShape = [attack, release].normalizeSum * sustain;
	globalEnv = EnvGen.kr(Env.perc(envShape[0], envShape[1], 1, curve), doneAction: doneAction).pow(envPow);
	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range([0.1, 0.12], [1, 1.02]).lag(0.02);

	globalEnv = Select.ar(globalEnvInv.wrap(0, 1).round, [globalEnv, globalEnv.neg]);

    phi = LFSaw.ar([sawFreq, sawFreq + 0.1], -1).range(0, 2pi);
    x = r * cos(phi);
    y = r * sin(phi);
    sig = sin(x) - (sin(y) * log(x * x + 1)) / 10;
    sig = Limiter.ar(sig * globalEnv, 0.2);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * amp, ~dirt.numChannels, pan));
}).add;

SynthDef(\prayerBell_Sd, { |out = 0, gate = 1, amp = 0.5, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, sing_switch = 0, freq = 2434, decayscale = 1, lag = 10, level = 0.08, i_doneAction = 2|
	var sig, input, first, freqscale, mallet, sing, globalEnv, envShape;
	freq = freq.max(20).min(5000);
	freqscale = freq / 2434;
	decayscale = decayscale.min(1);
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

	envShape = [attack, release].normalizeSum * sustain;
	globalEnv = EnvGen.kr(Env.perc(envShape[0], envShape[1]), doneAction: i_doneAction).pow(envPow);

	mallet = LPF.ar(Trig.ar(gate, SampleDur.ir)!2, 10000 * freqscale);
	sing = LPF.ar(
		LPF.ar(
			{
				PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
			} ! 2,
			2434 * freqscale
		) + Dust.ar(0.1), 10000 * freqscale
	) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
	input = mallet + (sing_switch.clip(0, 1) * sing);


	sig = DynKlank.ar(`[
		[
			(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
			first + LFNoise1.kr(0.5).range(1,3),
			LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
			LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
			LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
			LFNoise1.kr(2).range(8665, 8670),
			LFNoise1.kr(2).range(8704, 8709),
			LFNoise1.kr(2).range(8807, 8817),
			LFNoise1.kr(2).range(9570, 9607),
			LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
			LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
			LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
		],
		[
			LFNoise1.kr(1).range(-10, -5).dbamp,
			LFNoise1.kr(1).range(-20, -10).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			-20.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp,
			-10.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp
		],
		[
			20 * freqscale.pow(0.2),
			20 * freqscale.pow(0.2),
			5,
			5,
			0.6,
			0.5,
			0.3,
			0.25,
			0.4,
			0.5,
			0.4,
			0.6
		] * freqscale.reciprocal.pow(0.5)
	], input, freqscale, 0, decayscale);
	// DetectSilence.ar(sig, doneAction: i_doneAction);
	sig = sig * globalEnv;
	// sig = Pan2.ar(sig, pan, level);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\sosTom_Sd, { arg out = 0, amp = 0.6, pan = 0, attack = 0.001, release = 1.2, sustain = 1, envPow = 1, curve = -6, atk = 0.005, drumRel = 0.4, stickRel = 0.01, drumModeAmp = 0.25, freq = 250, timbreIndex = 0.77, clickAtk = 0, clickRls = 0.2, clickSus = 1, clickLevScale = 5, clickEnvPow = 1, clickEnvNoiseAmp = 0.3, clickFreq = 224, clickAmp = 0.5, doneAction = 2;

	var drumMode, drumModeEnv, stick, stickEnv, snd, globalEnv, clickEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, amp, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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

	snd = Mix.ar(drumMode + stickEnv + HPF.ar(clickEnv, clickFreq, clickAmp)) * globalEnv;

	snd = LeakDC.ar(snd);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\markSamFell_Sd,{ arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, trigSpeedMin = 1, trigSpeedMax = 100, tu = 60.5, harm1 = 0, harm2 = 2, harm3 = 4, harm4 = 5, harm5 = 7, harm6 = 9, harm7 = 10, plkDec = 0.9, plkCoeff = 0.5, filtFreqMin = 500, filterFreqMax = 16000, doneAction = 2;
    var globalEnv, trig, sig, freqs;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, trigSpeedMin, trigSpeedMax));
    freqs = (tu + [harm1, harm2, harm3, harm4, harm5, harm6, harm7]).midicps;
	sig = Pluck.ar(Hasher.ar(Sweep.ar(trig)) * -10.dbamp, trig, freqs.reciprocal, freqs.reciprocal, plkDec, plkCoeff.min(1).max(-1));
    sig = LeakDC.ar(sig).sum;
    sig = MoogFF.ar(sig, LFNoise2.kr(1).linexp(-1, 1, filtFreqMin, filterFreqMax));
	/*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\markSamFellLow_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, atkf = 0.0001, rlsf = 0.4, crvf = (-8), trigSpeedMin = 1, trigSpeedMax = 100, tu = 60.5, tuDiv = 16, freqEnvMin = 1, freqEnvMax = 40, index = 2, mratio = 4, boost = 2, doneAction = 2;
    var globalEnv, freq, freqenv, trig, sig;

    trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, trigSpeedMin, trigSpeedMax));

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), trig, timeScale: sustain, doneAction: doneAction).pow(envPow);

	freqenv = EnvGen.ar(Env.perc(atkf, rlsf, curve: crvf), trig);

    freq = tu.midicps / tuDiv;
    freq = freq * freqenv.linexp(0, 1, freqEnvMin, freqEnvMax);

	index = index.mod(3);

    sig = SinOsc.ar(freq, SinOsc.ar(freq * mratio) * index);
    sig = (sig * boost).tanh * globalEnv * amp;

	/*sig = Pan2.ar(sig, pan);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\gabor_Sd, { arg out = 0, amp = 0.25, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, doneAction = 2;

    var trig = \trig.tr;

    var freqEnv = EnvGen.kr(Env([1,2,1], [0.5, 0.01], \lin), trig);
    var fltEnv = EnvGen.kr(Env([0.0125,1,0.0125], [\fAtk.kr(0.3), \fRel.kr(0.01)], \exp), trig);
    var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    var numPartials = 40;
    var n = (1..numPartials);
    var freqs = \freq.kr(150) * (n + (n * n * 0.05));
    var cutoff, amps, sig;

    cutoff = fltEnv * \fltRange.kr(8000);

    amps = (
        (freqs.log2 - cutoff.log2).squared
        * \slope.kr(-5)
    ).dbamp;

    sig = SinOsc.ar(freqs * freqEnv.midiratio, 0, amps).sum * -25.dbamp;

    sig = sig * globalEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\additiveGabor_Sd, {
    arg out = 0, amp = 0.25, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, index=1, iScale=3, time=1, doneAction = 2;

    var numPartials = 40;
    var bufAmps = LocalBuf(numPartials, 1);
    var f0 = \freq.kr(68);
    var sig, mod;

    var iEnv = EnvGen.kr(Env([index, index * iScale, index], [\iAtk.kr(0.2), \iRel.kr(0.5)], \lin), timeScale: time);
	var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    BufWr.ar(
        LFGauss.ar(
            duration: SampleDur.ir * numPartials * \factor.kr(1, 0.5).reciprocal,
            width: \width.kr(0.2, 0.5),
            iphase: LFTri.ar(\phaseModFreq.kr(0.5)).linexp(-1, 1, 1, 2),
        ),
        bufnum: bufAmps,
        phase: Phasor.ar(end: numPartials)
    );

    mod = SinOsc.ar(f0 * \mRatio.kr(1), mul: iEnv);

    sig = Array.fill(numPartials, {|i|
        var freqs, partials;
        freqs = f0 * (i + (i * i * 0.05));
        partials = SinOsc.ar(
            freq: freqs * \cRatio.kr(1),
            phase: mod.wrap(0, 4pi),
            mul: Index.ar(bufAmps, i)
        ) / numPartials;
    }).sum;

    sig = LeakDC.ar(sig);

    sig = sig * globalEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef.new(\MC808Horiuchi_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 0.5, sustain = 1, curve = (-12.843224515159), envPow = 1, freq = 250, doneAction = 2;
    var sig, fenv, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    fenv = Env([freq*1.24, freq*1.12, freq], [0.1, 0.5], -4).kr;
    sig = SinOsc.ar(fenv, pi/2);
    // sig = Pan2.ar(sig * globalEnv * amp * 2, pan);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv * amp * 2, ~dirt.numChannels, pan));
}).add;

SynthDef(\Tonic_Sd, { |  out=0,amp=0.7,pan=0,attack=0,release=0.5,sustain=1,curve=(-4),envPow=1,oscfreq=50,lfofreq=200,lfoamount=0,penvamount=200,decaycurve=(-5),patt=0.001,pdec=0.200,shamount=0,shrate=3,ampatt=0.001,ampdec=0.7,ampdecaycurve=(-5),oscwaveform=1,noiseatt=0.001,noisedec=0.164,noiseamp=0.6,mixfade=0,nfiltfreq=1800,noisereso=0.2,noisefiltselect=0,drive=2,doneAction=2 |
	var sin,tri,saw,lfo,modsh,penv,ampenv,sh,signal,noisesig,noiseenv,noisesigbp,noisesighp,noisesiglp, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	noisesig=WhiteNoise.ar*noiseamp;
	noiseenv=EnvGen.ar(Env([0,1,0],[noiseatt,noisedec],[0,-5]));
	noisesig=noisesig*noiseenv;
	noisesigbp=BPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesighp=RHPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesiglp=RLPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesig=Select.ar(noisefiltselect,[noisesigbp,noisesighp,noisesiglp]);
	sh=LFNoise0.ar(shrate)*shamount;
	penv=EnvGen.ar(Env([0,1,0],[patt,pdec],[0,decaycurve]),doneAction:0)*penvamount;
	ampenv=EnvGen.ar(Env([0,1,0],[ampatt,ampdec],[0,ampdecaycurve]));
	lfo=SinOsc.ar(lfofreq)*lfoamount;
	sin=SinOsc.ar(oscfreq+penv+lfo+sh)*ampenv;
	tri=LFTri.ar(oscfreq+ penv +lfo+sh)*ampenv;
	saw=LFSaw.ar(oscfreq+penv+lfo+sh)*ampenv;
	signal=Select.ar(oscwaveform,[sin,tri,saw]);
	signal=XFade2.ar(signal,noisesig,pan:mixfade);
	signal=((signal)*drive).tanh;
	// signal=Pan2.ar(signal,pos:pan)*amp;
	// OffsetOut.ar(out,signal);
	OffsetOut.ar(out, DirtPan.ar(signal * globalEnv * amp, ~dirt.numChannels, pan));
}).add;

SynthDef(\dx11algo3_Sd, { //v3-->v2-->v1<--v4
    arg out = 0, amp = 0.5, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, feedBack = 0.5, doneAction = 2;

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

    var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    var mk_env = {
        |voice, done_action|
        EnvGen.ar(Env.adsr(voice[\atk], voice[\dec], voice[\sus], voice[\rel]), doneAction: done_action ? 0)
    };
    var mk_freq = {
        |voice|
        (\pitch.kr(48) + voice[\tune]).midicps
    };

    var env3 = mk_env.(voice3);
    var v3 = SinOsc.ar(mk_freq.(voice3)) * env3 * voice3[\amt];

    var env2 = mk_env.(voice2);
    var v2 = SinOsc.ar(mk_freq.(voice2), v3) * env2 * voice2[\amt];

    var env4 = mk_env.(voice4);
    var v4 = SinOscFB.ar(mk_freq.(voice4), env4 * feedBack) * env4 * voice4[\amt];

    var env1 = mk_env.(voice1);
    var v1 = SinOsc.ar(mk_freq.(voice1), v2 + v4) * env1 * voice1[\amt];

    // var final = Pan2.ar(v1 * amp, pos: pan);
    //OffsetOut.ar(out, final);globalEnv
    OffsetOut.ar(out, DirtPan.ar(v1 * amp * globalEnv, ~dirt.numChannels, pan));
}).add;

SynthDef(\Sqwer_Sd, { | out = 0, amp = 0.1, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, ampattack = 0.001, ampdecay = 1, filtattack = 0.001, filtdecay = 0.500, osc1amp = 0.3, osc2amp = 0.3, osc3amp = 0.3, offset1 = -24, offset2 = -0.3, offset3 = 0.1, filterfreq = 800, res = 1, lp = 1, bp = 0, hp = 0, freq = 58, filteramount = 600, fsh = 3, mixfade = 0, doneAction = 2 |
    var sig, sig1, sig2, sig3, ampenvelope, filterenvelope, globalEnv;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
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

SynthDef(\lazaer_Sd, { arg out = 0, amp = 0.03, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, doneAction = 2;
    var lpfEnv, gainEnv, globalEnv;
    var cutoff, tension, tilt, lpf, peakEQ;
    var sig, freqs, numPartials, spectrum;

    numPartials = 64;
    spectrum = (1..numPartials);

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
    freqs = \frq.kr(103.826) * spectrum * tension;
    sig = SinOsc.ar(freqs, { Rand(0, 2pi) } ! numPartials);

    // 3db/octave spectral tilt
    tilt = (log2(spectrum) * \tilt.kr(-3)).dbamp;

    // LPF
    cutoff = \lpfCutoff.kr(100) + lpfEnv.linlin(0, 1, 0, \lpfEnvAmount.kr(8000));
    lpf = ((log2(freqs) - log2(cutoff)) * \lpfSlope.kr(-12)).min(0).dbamp;

    // Peak EQ
    peakEQ = ((log2(freqs) - log2(cutoff)).abs * \peakSlope.kr(-12) + \peakRes.kr(24)).max(0).dbamp;

    sig = (sig * tilt * lpf * peakEQ).sum;

    sig = sig * gainEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * globalEnv));
}).add;

SynthDef(\hoover_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, frq = 440, envfL1 = (-5), envfL2 = 6, envfL3 = 0, envfT1 = 0.1, envfT2 = 1.7, crvf1 = 0, crvf2 = (-4), bw = 1.035, doneAction = 2;
    var snd, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    frq = frq * Env([envfL1, envfL2, envfL3], [envfT1, envfT2], [crvf1, crvf2]).kr.midiratio;
    snd = { DelayN.ar(Saw.ar(frq * ExpRand(bw, 1 / bw)) + Saw.ar(frq * 0.5 * ExpRand(bw, 1 / bw)), 0.01, Rand(0, 0.01)) }.dup(20);
    snd = (Splay.ar(snd) * 3).atan;
    snd = snd * Env.asr(0.01, 1.0, 1.0).kr(0);
    snd = FreeVerb2.ar(snd[0], snd[1], 0.3, 0.9);
    snd = snd * globalEnv;
    /*snd = Balance2.ar(snd[0], snd[1], pan, amp);
    OffsetOut.ar(out, snd);*/
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\vowelsynth,{ arg out = 0, amp = 1, pan = 0, vel = 1, fq = 440, bend = 0, vow = 0, gate = 1, doneAction = 2;
    var a,b,c,d,e,
    vib1,vib2,vib3,vib4,vib5,vib6,vib7,vib8,
    gen1,gen2,gen3,gen4,gen5,gen6,gen7,gen8,ngen, env, snd,
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
    env = EnvGen.ar(Env.asr(2, vel, 0.005), gate, doneAction: doneAction);
	snd = pan1+pan2+pan3+pan4+pan5+pan6+pan7+pan8 * env;
	snd = Balance2.ar(snd[0], snd[1], pan, amp);
    OffsetOut.ar(out, snd);
}).add;

///////////////////////////////////////  Sequence

SynthDef(\talters1SusSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, sustain = 1, release = 10, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, modenv, harmk, ampk, ringk;
	env = EnvGen.kr(Env.perc(attack, release), gate, timeScale: sustain, doneAction: doneAction);
	input = LocalIn.ar(2) * feedBack;
	modenv = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(
				(i*k*k) * modenv,
				y.ar(i*k**i/[modenv, (i*k)+modenv]) * Decay.kr(Dust.kr(decDens - input), (y.ar(decTimeFreq)+1*k+i) * modenv, k*decamp))
		}!3).product;
	}!4).sum;
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\talters1_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 0.5, sustain = 1, curve = (-12.843224515159), envPow = 1, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, doneAction = 2;
	var sig, globalEnv, input, modenv, harmk, ampk, ringk;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	input = LocalIn.ar(2) * feedBack;
	modenv = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve));
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(
				(i*k*k) * modenv,
				y.ar(i*k**i/[modenv, (i*k)+modenv]) * Decay.kr(Dust.kr(decDens - input), (y.ar(decTimeFreq)+1*k+i) * modenv, k*decamp))
		}!3).product;
	}!4).sum;
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * globalEnv * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\padovan_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, tridDur = 1, freq = 165, doneAction = 2;
	var sig, globalEnv, input, mod, grainTr, sinMod;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	sig = SinOsc;
	mod = Trig.ar(
		Saw.ar(freq),
		tridDur // * sustain
	);
	grainTr = sig.ar(mod * freq);
	sinMod = sig.ar(mod);
	sig = GrainIn.ar(2, grainTr, grainTr / 2, sinMod, mod * sinMod, -1);
	sig = GVerb.ar(sig, 9, mul: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedDrumSeq_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.0001, release = 4, sustain = 1, curve = (-4), sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, doneAction = 2;
	var sig, globalEnv, imp, krps, kick;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	imp = Impulse.ar(_); // * gate;

	krps = Pluck.ar(
		Saw.ar(sawFrq),
		imp.(plcTrigRate),
		1,
		plcDelay,
		plcDecay,
		SinOsc.ar(
			PulseCount.ar(
				imp.(pCntTrigRate),
				imp.(pCntResetRate)
			).cos%[3,4]*20
		),
		2.5
	).sin;

	krps = krps + LPF.ar(
		HPF.ar(
			FreeVerb.ar(
				krps.mean,
				1,
				0.999,
				0.2
			)*0.3,
			krpsHpfFrq
		), // * Line.kr(0,1,16),
		krpsLpfFrq
	);

	kick = HPF.ar(
		Ringz.ar(
			LPF.ar(
				Impulse.ar(
					[0.5,1]!2,
					[1/6,0]
				).sum,
				kickLpfFrq
			),
			ringFrq,
			ringDec,
			3
		).sin * 3,
		kickHpfFrq
	).tanh.madd(0.6);

	sig = krps + kick;
	// sig = sig * curve * amp;
	sig = Mix.ar(sig) * globalEnv * amp;

	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedDrumSeq1_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.0001, release = 4, sustain = 1, curve = (-4), sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsAtt = 0, krpsRel = 0.1, krpsSus = 1, krpsEnvPow = 1, krpsLev = 1, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, doneAction = 2;
	var sig, krpsEnv, globalEnv, imp, krps, kick;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);

	krpsEnv = EnvGen.kr(Env.perc(krpsAtt, krpsRel), levelScale: krpsLev, timeScale: krpsSus).pow(krpsEnvPow);

	imp = { arg rate; Impulse.ar(rate); }; // * gate;

	krps = Pluck.ar(
		Saw.ar(sawFrq),
		imp.(plcTrigRate),
		1,
		plcDelay,
		plcDecay,
		SinOsc.ar(
			PulseCount.ar(
				imp.(pCntTrigRate),
				imp.(pCntResetRate)
			).cos%[3,4]*20
		),
		2.5
	).sin;

	krps = krps + LPF.ar(
		HPF.ar(
			FreeVerb.ar(
				krps.mean,
				1,
				0.999,
				0.2
			)*0.3,
			krpsHpfFrq
		), // * Line.kr(0,1,16),
		krpsLpfFrq
	) * krpsEnv;

	kick = HPF.ar(
		Ringz.ar(
			LPF.ar(
				Impulse.ar(
					[0.5,1]!2,
					[1/6,0]
				).sum,
				kickLpfFrq
			),
			ringFrq,
			ringDec,
			3
		).sin * 3,
		kickHpfFrq
	).tanh.madd(0.6);

	sig = krps + kick;
	// sig = sig * curve * amp;
	sig = Mix.ar(sig) * globalEnv * amp;

	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedKickSeq_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, sustain = 1, curve = (-4), trgChance1 = 0.5, trgChance2 = 0.3, trgChance3 = 0.9, trgRate1 = 4, trgRate2 = 12, trgRate3 = 6, rFreq1 = 45, rFreq2 = 50, rDec1 = 0.6, rDec2 = 0.1, rDec3 = 1, rDec4 = 0.3, rAmp1 = 9, rAmp2 = 2, rAmp3 = 3, rAmp4 = 1, gate = 1, doneAction = 2;
	var sig, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	sig = Ringz.ar(
		CoinGate.ar(
			[trgChance1, trgChance2, trgChance3],
			Impulse.ar([trgRate1, trgRate2, trgRate3])
		),
		[rFreq1, rFreq2],
		[rDec1, rDec2, rDec3, rDec4],
		[rAmp1, rAmp2, rAmp3, rAmp4]
	).sin.sum.tanh;
	sig = sig * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\dannySimple1_Sd, { arg out = 0, amp = 0.7, pan = 0, attack = 0.001, release = 0.2, sustain = 1, curve = (-4), envPow = 1, frq1_1 = 1, frq1_2 = 2, frq1_3 = 3, frq1_4 = 4, frq1_5 = 5, frq1_6 = 6, frq1_7 = 7, frq1_8 = 8, frq1_9 = 9, frq1_10 = 10, frq1_11 = 11, frq1_12 = 12, frq1_13 = 13, frq1_14 = 14, frq1_15 = 15, frq2_1 = 1, frq2_2 = 2, frq2_3 = 3, frq2_4 = 4, frq2_5 = 5, frq2_6 = 6, frq2_7 = 7, frq2_8 = 8, frq2_9 = 9, frq2_10 = 10, frq2_11 = 11, frq2_12 = 12, frq2_13 = 13, frq2_14 = 14, frq2_15 = 15, add1 = 970, add2 = 1030, div1 = 30, div2 = 30, rng1Lo = (-4), rng1Hi = 4, rng2Lo = (-4), rng2Hi = 4, thr = 0.03, doneAction = 2;
    var sig, sig1, sig2, globalEnv, frq1, frq2;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction.pow(envPow));

    frq1 = [frq1_1, frq1_2, frq1_3, frq1_4, frq1_5, frq1_6, frq1_7, frq1_8, frq1_9, frq1_10, frq1_11, frq1_12, frq1_13, frq1_14, frq1_15];
    frq2 = [frq2_1, frq2_2, frq2_3, frq2_4, frq2_5, frq2_6, frq2_7, frq2_8, frq2_9, frq2_10, frq2_11, frq2_12, frq2_13, frq2_14, frq2_15];

    sig1 = SinOsc.ar(frq1 + add1 / div1).range(rng1Lo, rng1Hi);
    sig2 = SinOsc.ar(frq2 + add2 / div2).range(rng2Lo, rng2Hi);

    sig = gcd(sig1.product.round(1), sig2.round(1));
    sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
    /*sig = Pan2.ar(sig * globalEnv, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Bass

SynthDef(\bass_Sd,{arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, dis = 0.5, freq = 60, addFreq = 1000, sousFreq = 100, frqCurve1 = 0.05, frqCurve2 = 0.1, tu = 1, doneAction = 2;
	var globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: 2).pow(envPow);
    var frequ = EnvGen.ar(Env([freq + addFreq, freq, freq - sousFreq], [frqCurve1, frqCurve2]));
    var sig = LFSaw.ar(LFSaw.ar(frequ-100,0,frequ-200,frequ*tu), 0, globalEnv);
    sig = CrossoverDistortion.ar(sig,dis,0.05)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.01)+sig;
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(globalEnv);
    //sig = LPF.ar(sig,100);
    sig = Compander.ar(sig,sig,0.05,1,0.1,0.01,0.1);
    // OffsetOut.ar(out,sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\bass3SusSd,{arg out=0, amp=1, pan = 0, tu = 1.54, sustain = 1, gate = 1;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate, timeScale: sustain, doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    // OffsetOut.ar(out,sig*amp*env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\sinBass_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.2, release = 4, sustain = 1, curve = (-4), envPow = 1, envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, tu = 1, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, fcurve = 4, hpff = 20, doneAction = 2;
	var freqEnv, globalEnv, sig;
	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6] * tu, [envTime1, envTime2, envTime3, envTime4, envTime5].normalizeSum * sustain, fcurve));
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	sig = SinOsc.ar(freqEnv);
	//sig = HPF.ar(sig, 20);
	sig = BHiPass4.ar(sig, hpff);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, Lag.kr(amp, 0.5)));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, Lag.kr(amp, 0.5)));
}).add;

SynthDef(\moogBass_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, frq = 40, ffreq = 1000, lagamount = 0.01, atkf = 0.2, stnf = 1, rlsf = 0.2, chorus = 0.7, doneAction = 2;
	var osc, filter, globalEnv, filterenv, snd, chorusfx;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: 2).pow(envPow);

	osc = Mix(VarSaw.ar(
		freq: frq.lag(lagamount) * [1.0, 1.001, 2.0],
		iphase: Rand(0.0,1.0) ! 3,
		width: Rand(0.5,0.75) ! 3,
		mul: 0.5
	)
	);

	filterenv = EnvGen.ar(Env.asr(atkf, stnf, rlsf), timeScale: sustain);

	filter =  MoogFF.ar(
		in: osc,
		freq: ffreq * (1.0 + (0.5 * filterenv)),
		gain: amp
	);

	snd = (0.7 * filter + (0.3 * filter.distort)) * globalEnv;

	chorusfx = Mix.fill(7, {

		var maxdelaytime = rrand(0.005, 0.02);
		DelayC.ar(
			in: snd,
			maxdelaytime: maxdelaytime,
			delaytime: LFNoise1.kr(
				freq: Rand(4.5, 10.5),
				mul: 0.25 * maxdelaytime,
				add: 0.75 * maxdelaytime)
		)
	});

	snd = snd + (chorusfx * chorus);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\bassSat_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, rate = 3, soundmod = 60, sat = 0.1, noiseAmp1 = 0.04, noiseAmp2 = 0.04, noiseAtk = 0.005, noiseDcy = 0.5, doneAction = 2;
	var sig, globalEnv, exc, klankArr;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(rate, 0, [noiseAmp1, noiseAmp2]), noiseAtk, noiseDcy));

    klankArr = Ref.new([soundmod, nil, Array.fill(16, {1.1})]);

    sig = (DynKlank.ar(klankArr, exc) * sat).softclip;
	// sig = Mix.ar(sig);
	/*sig = Pan2.ar(sig * globalEnv, pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\turfuBass_Sd, { arg out = 0, amp = 0.25, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, index=1, iScale=5, doneAction = 2;
    var trig = \trig.tr(1);
    var trigMod = LFNoise0.ar(8).round;
    var sig, globalEnv, iEnv, mod;
    var low, mid, high;
    var lowFreq, highFreq, phase, waveform, shaped;

    iEnv = EnvGen.ar(Env([0, index, index * iScale, index], [0.0001, 5, 1], \lin), trig);

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), (trig * trigMod).abs, timeScale: sustain, doneAction: doneAction).pow(envPow);

    mod = Sweep.ar(trig * trigMod, [51.913, 726.783]);

    phase = Phasor.ar(Impulse.ar(0), 51.913 / SampleRate.ir, 0, 1);
    waveform = (((phase % 0.5 * 2pi).sin * (2 * (phase % 0.5 < 0.25) - 1)) + (2 * (phase % 0.5 >= 0.25))) + (2 * (phase >= 0.5));
    sig = waveform + (((mod * 2pi) + (pi/3)).wrap(-pi, pi) * iEnv);
	sig = (Fold.ar(sig) * [2, 0.05]).mean;


    lowFreq = 207.652;
    highFreq = 1038.26;
    low = LPF.ar(LPF.ar(sig, lowFreq), lowFreq);
    sig = sig - low;
    mid = LPF.ar(LPF.ar(sig, highFreq), highFreq);
    high = sig - mid;

    // lows
    low = low + PitchShift.ar(low, 0.2, 2);
    k = 2 * \amount.kr(0.2) / (1 - \amount.kr(0.2));
    shaped = (1 + k) * low / (1 + (k * low.abs));
    low = XFade2.ar(low, shaped, 1);

    // highs
    high = (high * \boost.kr(3).dbamp).tanh;

    sig = low + mid + high;

    sig = sig * amp;

    sig = MidEQ.ar(sig, 13289.75, 0.7, 8);
    sig = LeakDC.ar(sig);
	/*sig = Pan2.ar(Limiter.ar(sig), pan);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(Limiter.ar(sig * globalEnv), ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Snare

SynthDef(\snaremedSusSd, { | out = 0, level = 1, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.1, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, sustain = 1, doneAction = 2|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0, timeScale: sustain, doneAction: doneAction);
	env1 = EnvGen.ar(env1);
	env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
	son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

	son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = LeakDC.ar(son,dc,30);
	son = son ;
	son = HPF.ar(son, 100, env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son =  HPF.ar(son +BrownNoise.ar(env0/2*noise)+WhiteNoise.ar(env0*noise),fratio);
	//son = son.clip2(1);

	son = Limiter.ar(son,1);
	son = son * level.distort;

	// OffsetOut.ar(out, Pan2.ar(son, pan, level)).tanh;
	//OffsetOut.ar(snd, son*level).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level)).tanh;
}).add;

SynthDef(\sosSnare_Sd, { arg out = 0, amp = 0.8, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, atk = 0.005, rls = 0.1, crv = (-4), atk1 = 0.05, rls1 = 0.6, crv1 = (-8), freq = 405,
	//drumMode Controls
	drumModeAmp = 0.25, timbreIndex = 0.385, modHarmonic = 0.452,
	//snares controls
	snareAmp = 40, nyquist = 1700, snareRez = 1000, ffreq = 40, rq = 0.1, bwr = 1,
	doneAction = 2;

	var globalEnv, drumMode, drumModeEnv, snares, snareEnv, snd;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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

	snd = Mix.new(drumMode + snares) * globalEnv * amp;

	snd = LeakDC.ar(snd);

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\squareDrumSusSd, {
	arg
	// Standard values
	out = 0, freq = 180, amp = 0.6, pan = 0,
	// Stick Controls
	atk = 0.001, dcy = 0.01, rls = 0.2,
	// Head Controls
	headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rel = 0.2,
	// Snares Controls (thresh goes from 0 to 1)
	snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
	snareGate = 0.6, rq = 0.5, sustain = 1,
	doneAction = 2;

	var freqarray, amparray, decarray, stick, head, snares, snd;

	// Setting up arrays for Klank
	freqarray = Array.fill(8, {
		arg i = 1;
		(
			Array.fill((i + 1), {
				arg j;
				(j + 1).pow(2)
			}) +
			(i + 1).pow(2)
		).sqrt

	});
	freqarray = freqarray.flatten/(2.sqrt);

	amparray = Array.fill(36, {
		arg i;
		if (freqarray[i] > 20000)
		{ 0 }
		{
			(ampSlope * (freqarray[i]).log2).dbamp
		}
	});
	amparray = amparray/amparray.max;

	decarray = Array.fill(36, {
		arg i;
		exp(-1 * i * decCoef)
	});
	decarray = decarray/decarray[0];

	// Drumstick
	stick = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: atk,
		decayTime: dcy,
		mul: 0.005); // This keeps the volume at a sane level

	// Drum Head
	head = Klank.ar(
		specificationsArrayRef:
		Ref.new([freqarray, amparray, decarray]),
		input: stick,
		freqscale: freq,
		decayscale: rel);

	// Snares
	snares = PinkNoise.ar(
		Amplitude.ar(
			in: head,
			attackTime: followAtt,
			releaseTime: followRel));
	snares = CompanderD.ar(
		in: snares,
		thresh: thresh,
		slopeBelow: 1 + snareGate.clip(0, inf));
	snares = BRF.ar(
		in: snares,
		freq: freqarray[1..6],
		rq: rq);

	//Output Stuff
	snd = (head * headAmp) + (snares * snaresAmp);
	snd = Mix.ar(snd * amp);
	snd = Limiter.ar(snd);

	// DetectSilence.ar(in: snd, doneAction: doneAction);

	snd = snd * EnvGen.kr(Env.asr(atk, 1, rls), 1, timeScale: sustain, doneAction: doneAction);

	// Out.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\squareDrum_Sd, {
    arg
    // Standard values
    out = 0, freq = 180, amp = 0.6, pan = 0,
	// global env
	attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1,
    // Stick Controls
    atk = 0.001, dcy = 0.01,
    // Head Controls
    headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rls = 0.2,
    // Snares Controls (thresh goes from 0 to 1)
    snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
    snareGate = 0.6, rq = 0.5,
	doneAction = 2;

    var globalEnv, freqarray, amparray, decarray, stick, head, snares, snd;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    // Setting up arrays for Klank
    freqarray = Array.fill(8, {
        arg i = 1;
        (
            Array.fill((i + 1), {
                arg j;
                (j + 1).pow(2)
            }) +
            (i + 1).pow(2)
        ).sqrt

    });
    freqarray = freqarray.flatten/(2.sqrt);

    amparray = Array.fill(36, {
        arg i;
        if (freqarray[i] > 20000)
            { 0 }
            {
                (ampSlope * (freqarray[i]).log2).dbamp
            }
    });
    amparray = amparray/amparray.max;

    decarray = Array.fill(36, {
        arg i;
        exp(-1 * i * decCoef)
    });
    decarray = decarray/decarray[0];

    // Drumstick
    stick = Decay2.ar(
        in: Impulse.ar(0),
        attackTime: atk,
        decayTime: dcy,
        mul: 0.005); // This keeps the volume at a sane level

    // Drum Head
    head = Klank.ar(
        specificationsArrayRef:
            Ref.new([freqarray, amparray, decarray]),
        input: stick,
        freqscale: freq,
        decayscale: rls);

    // Snares
    snares = PinkNoise.ar(
        Amplitude.ar(
            in: head,
            attackTime: followAtt,
            releaseTime: followRel));
    snares = CompanderD.ar(
        in: snares,
        thresh: thresh,
        slopeBelow: 1 + snareGate.clip(0, inf));
    snares = BRF.ar(
        in: snares,
        freq: freqarray[1..6],
        rq: rq);

    //Output Stuff
    snd = (head * headAmp) + (snares * snaresAmp);
    snd = Mix.ar(snd * amp);
	snd = snd * globalEnv;
    snd = Limiter.ar(snd);

    // Out.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\neuroSnareSusSd, { arg out = 0, amp = 0.1, pan = 0, freq = 160, curve = -4, preamp = 1.4,
	//Click Controls
	clickatt = 0.001, clicksus = 0.01, clickrel = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
	//Body Controls
	bodyatt = 0.04, bodyrel = 0.2, bodyamp = 2,
	//Rattle Controls
	rattlehold = 0.01, rattleatt = 0.05, rattlerel = 0.2, rattleamp = 0.7, rattlefreq = 4000, rq = 0.5, rattlepeak = 3,
	//Sweep Controls
	sweepatt = 0.001, sweeprel = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500, sustain = 1,
	doneAction = 2;

	var snd, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;

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
	snd = Mix.ar(click + body + rattle + sweep);

	snd = (snd * preamp).tanh * amp;

	// DetectSilence.ar(in: snd, doneAction: doneAction);
	snd = snd * EnvGen.kr(Env.perc(0, sustain), doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snare909_Sd, { arg out = 0, amp = 0.5, pan = 0, freq = 124, attack = 0, release = 0.1, sustain = 1, curve = 6, atk = 0, stn = 1, rls = 0.08, crv = 24, envNoiseAmp = 0.4, envTonePow = 12, envNoisePow = 0.63, toneRel = 0.1, toneAmp = 1, noiseRel = 0.06, noiseAmp = 0.4, nyquist = 12100, lpFreq = 14040, hpFreq = 83, doneAction = 2;
	var env, envTone, envNoise, envBlur, relTimes, globalEnv, tone, noise, snd;

	relTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

	env = Env([atk, stn, rls], relTimes, crv);

	envBlur = PinkNoise.kr(envNoiseAmp).range(0.1, 1).lag(0.02);

	envTone = EnvGen.kr(env, timeScale: toneRel) * envBlur;

	envNoise = EnvGen.kr(env, timeScale: noiseRel) * envBlur;

	globalEnv = Env.perc(attack, release, curve: curve).kr(timeScale: sustain, doneAction: doneAction);

	tone = LFTri.ar([1, 1.78] * freq, mul: toneAmp) * envTone.pow(envTonePow);

	noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

	noise = LPF.ar(noise, lpFreq, noiseAmp) * envNoise.pow(envNoisePow);

	snd = tone ++ [noise, HPF.ar(noise, hpFreq)];

	snd = Mix.ar(snd * globalEnv) * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snarenew_Sd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = (-4), sustain = 1, mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var globalEnv, sig, envp;
    /*var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));*/
	globalEnv = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3].normalizeSum * sustain, curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu * envp,0,0.5) * globalEnv;
	sig = ((PinkNoise.ar * globalEnv) * mixNoise) + (sig * (1 - mixNoise));
    sig = RHPF.ar(sig, hpFreq*tu, rqhpf);
	sig = (Mix.ar(BPF.ar(sig,[freq1bpf, freq2bpf],[rq1bpf, rq2bpf])) * mixBpf) + (sig * (1 - mixBpf));
    sig = RLPF.ar(sig, lpf, rqlpf);
    // sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),4,-8),gate, doneAction: doneAction);
    // sig = DelayL.ar(sig,0.05,0.001)+sig;
    // sig = DelayL.ar(sig,0.05,0.01)+sig;
    // sig = DelayL.ar(sig,0.1,0.1)+sig;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snarenew1_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 0.1, sustain = 1, curve = 6, envPow = 1, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, crv = (-4), stn = 1, mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var env, globalEnv, sig, envp;

	globalEnv = EnvGen.ar(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3].normalizeSum * stn, curve: [crv, crv/2, crv]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu * envp,0,0.5) * env;
	sig = ((PinkNoise.ar * env) * mixNoise) + (sig * (1 - mixNoise));
    sig = RHPF.ar(sig, hpFreq*tu, rqhpf);
	sig = (Mix.ar(BPF.ar(sig,[freq1bpf, freq2bpf],[rq1bpf, rq2bpf])) * mixBpf) + (sig * (1 - mixBpf));
    sig = RLPF.ar(sig, lpf, rqlpf);
    // sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),4,-8),gate, doneAction: doneAction);
    // sig = DelayL.ar(sig,0.05,0.001)+sig;
    // sig = DelayL.ar(sig,0.05,0.01)+sig;
    // sig = DelayL.ar(sig,0.1,0.1)+sig;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Rimshot

SynthDef(\rim_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, tu = 1, doneAction = 2;
	var sig;
	var globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var envf = EnvGen.ar(Env([\envfL1.kr(1600), \envfL2.kr(5600), \envfL3.kr(800), \envfL4.kr(250)],[\envfT1.kr(0.001), \envfT2.kr(0.001), \envfT3.kr(0.001)].normalizeSum * sustain, -4));
	var envf2 = EnvGen.ar(Env([\envf2L1.kr(1000), \envf2L2.kr(1600), \envf2L3.kr(700), \envf2L4.kr(200)],[\envf2T1.kr(0.001), \envf2T2.kr(0.001), \envf2T3.kr(0.06)].normalizeSum * sustain, -4));
	sig = SinOsc.ar(tu * \sinFreq.kr(400)) * globalEnv;
	sig = WhiteNoise.ar(globalEnv) + sig;
	sig = RHPF.ar(sig, \rhpfFreq.kr(100) * tu, \rhpfRq.kr(1)) + sig;
	sig = sig + Mix.ar(BPF.ar(sig, [\bpfFreq1.kr(327), \bpfFreq2.kr(430)], [\bpfRq1.kr(0.5), \bpfRq2.kr(0.5)]) * 0.8) + WhiteNoise.ar(globalEnv) + BrownNoise.ar(globalEnv / 8);
	sig = RLPF.ar(sig, \rlpfFreq.kr(11100) * tu, \rlpfRq.kr(0.5)) + sig;
	sig = (Ringz.ar(WhiteNoise.ar, Mix.ar([envf2, envf * 0.9, envf2 * 0.8]), 1, globalEnv) + RLPF.ar(BrownNoise.ar(globalEnv), envf * 4, 1, 1) + sig) * globalEnv;
	// sig = Pan2.ar(sig*globalEnv, pan, amp);
	sig = DirtPan.ar(sig*globalEnv, ~dirt.numChannels, pan);
	sig = CompanderD.ar(sig * 4, 0.8, 0.3, 0.5, 0.001, 0.2, globalEnv);
	OffsetOut.ar(out, sig * amp);
}).add;

///////////////////////////////////////  Generatif

SynthDef(\raisonne,{ arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, frq = 40, bwr = 0.001, doneAction = 2;
	var sig, n, env;
	env = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), frq * (i + 1), bwr, 300)}) * n.reciprocal; // scale to ensure no clipping
	sig = Pan2.ar(sig, pan, amp) * env;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\raisonne_Sd,{ arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, frq = 40, bwr = 0.001, dustFreq = 5, doneAction = 2;
	var sig, n, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(dustFreq), frq * (i + 1), bwr, 300)}) * n.reciprocal; // scale to ensure no clipping
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\lcm2Gene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, tRand1Min = 1, tRand1Max = 1000, tRand2Min = 1, tRand2Max = 1000, rate1 = 28, rate2 = 26, smooth1 = 0.4, smooth2 = 0.2, sig1RangeMin = (-100), sig1RangeMax = 100, sig2RangeMin = (-100), sig2RangeMax = 100, doneAction = 2;
    var sig, sig1, sig2, mod1, mod2, globalEnv;

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    mod1 = TExpRand.kr(tRand1Min, tRand1Max, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TExpRand.kr(tRand2Min, tRand2Max, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sig1 = Saw.ar(mod1).range(sig1RangeMin, sig1RangeMax).round(1);
    sig2 = LFCub.ar(mod2).range(sig2RangeMin, sig2RangeMax).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * globalEnv;
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdLcmDmGene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, randMin = 1, randMax = 300, mul1 = 1, mul2 = 40, mulTanh = 0.0001, modu1 = 100, modu2 = 300, rate1 = 0.6, rate2 = 0.06, smooth1 = 0.4, smooth2 = 0, doneAction = 2;
    var mod1, mod2, sin1, sin2, sig, sig1, sig2, sig3, globalEnv;

	// globalEnv = EnvGen.kr(Env.asr(attack, (1 - (attack + release)), release, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    mod1 = TRand.kr(randMin, randMax, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TRand.kr(randMin, randMax, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sin1 = SinOsc.ar(mod1).range(1,100) * mul1;
    sin2 = SinOsc.ar(mod2) * mul2;

    sig1 = gcd(sin1, sin2) % modu1;
    sig2 = lcm(sin1, sin2) % modu2;

    sig = tanh([sig1 * sig2, sin1 * sin2] * mulTanh);

    sig = Mix.ar(sig) * globalEnv;
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDm2Gene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, seq1OffSet = 41, seq1Mul = 1, seq2OffSet = 40, seq2Mul = 1, mod1 = 20, mod2 = 20, dev1 = 3, dev2 = 7, doneAction = 2;
    var sig, sig1, sig2, globalEnv;

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    sig1 = PulseCount.ar(TDuty.ar(Dseq((1..20), inf) + seq1OffSet * seq1Mul * SampleDur.ir)) % mod1;
    sig2 = PulseCount.ar(TDuty.ar(Dseq((21..1), inf) + seq2OffSet * seq2Mul * SampleDur.ir);) % mod2;

    sig = gcd(sig1, sig2 + [dev1, dev2]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

	sig = Mix.ar(sig) * globalEnv;
    // sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDm5Gene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, seqOffSet = 0, seqMul = 1, start = 10, end = 0.01, rate1 = 1, mod2 = 500, mod3 = 501, dev1 = 1, dev2 = 3, add = 400, add1 = 61, mul1 = 53, bpff = 5000, doneAction = 2;
    var seq, envMod, src1, src2, src3, sig, sig1, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    seq = Dseq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99] + seqOffSet * seqMul, inf);

    envMod = LFTri.kr(0.005, -1).exprange(start, end);

    src1 = TDuty.ar(seq * envMod * SampleDur.ir);
    src2 = PulseCount.ar(Impulse.ar(rate1)) % mod2;
    src3 = PulseCount.ar(src1) % mod3;

    sig = gcd(src2, src3 + [0, 2]);
    sig1 = gcd(lcm(src2 + [dev1, dev2], src3),sig);

    sig = SinOsc.ar(sig * 443 + add) * 0.1;
    sig1 = SinOsc.ar(sig1 * mul1 + add1) * 0.3;

    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, bpff), 0.3);
	sig = Mix.ar(sig);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\bigraph_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-12), envPow = 1, trig1Freq = 0, trig2Freq = 0, modulo1 = 128, modulo2Freq = 3, modulo2Mul = 9, modulo2Offset = 99, noteOffset = 33, srcFreq = 9, modPhaseMul = 3.1415926535898, doneAction = 2;
    var sig, modPhase, globalEnv, trig1, trig2;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    trig1 = Impulse.kr(trig1Freq);
    trig2 = Impulse.kr(trig2Freq);
    modPhase = SinOsc.ar(
        midicps(
            (
                Sweep.ar(trig1, (33..3)) % modulo1 & (Sweep.ar(trig2, (3..9)) % (LFSaw.ar(modulo2Freq) * modulo2Mul + modulo2Offset))
            ) + noteOffset
        ),
        0,
        modPhaseMul
    );
    sig = (SinOsc.ar(srcFreq, modPhase) / 3) * globalEnv;
    // sig = Pan2.ar(Splay.ar(sig), pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\floatingPointErrors_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, doneAction = 2;
    var sig, sig1, pink1, sig2, pink2, sig3, pink3, sig4, sig5, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    pink1 = PinkNoise.ar().range(0.08, 0.12) ! 2;
    sig1 = 0.5 * LeakDC.ar(Median.ar(2, Limiter.ar(99999999*(SawDPW.ar(pink1, 0) + SawDPW.ar(pink1, pi)), 0.9)));

    pink2 = PinkNoise.ar().range(0.0999/3, 0.1001/3) ! 2;
    sig2 = 0.5*LeakDC.ar(Median.ar(5, Limiter.ar(99999999*(SawDPW.ar(pink2, 0) + SawDPW.ar(pink2, pi)), 0.9)));

    pink3 = PinkNoise.ar().range(0.00999, 0.01001) ! 2;
    sig3 = 0.5 * Median.ar(20, Limiter.ar(999999*LeakDC.ar(SawDPW.ar(pink3, 0+(pi/2)) + SawDPW.ar(pink3, pi+(pi/2))), 0.1));

    sig4 = 0.5 * Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(0.005, 0) + SinOsc.ar(0.005, pi)), 0.05))) ! 2;

    sig5 = 0.5 * SVF.ar((Median.ar(10, Limiter.ar(999999*LeakDC.ar(LFPulse.ar(0.5, 0) + LFPulse.ar(0.5, pi)), 0.6))), 800) ! 2;

    sig = sig1 + sig2 + sig3 + sig4 + sig5;
    sig = Limiter.ar(sig, 0.8);
    sig = Balance2.ar(sig[0], sig[1], pan, amp);

    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels));
}).add;

SynthDef(\circSegs_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = 0, envPow = 1, tu = 1, segments = 49, xMajor = 10.0, yMajor = 1.0, rMajor = 100.1, rMinor = 1.1, circlefreq = 0.0001, doneAction = 2;
    var sig, xMinor, yMinor, freqs, amps, phase, shuheiKawachi, globalEnv;

    shuheiKawachi = { arg x, y, a, b;
        ((cos(x) * cos(y))
            + (cos((sqrt(a) * x - y) / b)
                * cos((x + (sqrt(a) * y) ) / b))
            + (cos(( sqrt(a) * x + y) /b)
                * cos((x - (sqrt(a) * y*y)) / b)))/3;
    };

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    // freqs = Array.exprand(49, 50, 1500).sort.debug;
	freqs = [50.909089430214, 63.608512393358, 65.056484949596, 67.985432742352, 68.449254734715, 71.154462801524, 75.153162666907, 80.159090540174, 88.650405760834, 89.244467136653, 89.787749814836, 94.804318696787, 97.17438072031, 104.06610340747, 105.58273927332, 105.70848787891, 118.14763403707, 122.30357892333, 125.91379530205, 138.19911121285, 157.10948972852, 194.04854760832, 198.76041832049, 198.847779932, 201.92012940761, 230.06225552661, 237.68115421845, 290.73868194269, 293.38951591388, 336.31430916388, 341.91511960964, 349.4171680391, 393.59846721581, 409.2946639466, 413.5242979, 425.15780461208, 465.90490967238, 492.76629119068, 549.91655801867, 645.03288565102, 700.87369257369, 709.96409772057, 716.96599236393, 843.4571242342, 898.23211278398, 1024.3564550409, 1077.5384208642, 1122.7178267914, 1356.4674355527] * tu;

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

SynthDef(\easel_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, selSnd = 3, doneAction = 2;
    var snd, numInputs, numOutputs, globalEnv;
    numInputs = 12;
    numOutputs = 6;
    snd = LocalIn.ar(numOutputs);

    globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    // Matrix-vector multiplication using multichannel expansion.
    snd = snd * ({ { LFNoise2.kr(0.5)/*.round*/ } ! numInputs } ! numOutputs);
    snd = snd.sum;
    // If additional modules are added, remember to update numInputs and numOutputs.
    // numInputs should equal the maximum i in snd[i], plus one.
    // numOutputs should equal the number of entries in the snd array.
    snd = [
        // Oscillator that reaches LFO range
        SinOsc.ar(snd[0].linexp(-1, 1, 0.1, 8000)),
        // Oscillator in audio range only
        SinOsc.ar(snd[1].linexp(-1, 1, 100, 8000)),
        // Wavefolder with controllable gain
        (snd[2] * snd[3].linexp(-1, 1, 1, 10)).fold2,
        // Two filters with controllable cutoff and resonance
        MoogFF.ar(snd[4], snd[5].linexp(-1, 1, 10, 8000), snd[6].linlin(-1, 1, 0, 4)) * 3.dbamp,
        MoogFF.ar(snd[7], snd[8].linexp(-1, 1, 10, 8000), snd[9].linlin(-1, 1, 0, 4)) * 3.dbamp,
        // Metallic reverb (spring reverb in the Easel)
        FreeVerb.ar(snd[10], mix: 1)
        // Five-step sequencer
        // Demand.ar(Impulse.ar(snd[11].linexp(-1, 1, 0.1, 1000)), 0, Dseq([0.1, 0.5, 0.9, 0.3, 0.4]))
    ];

    if(snd.size != numOutputs) {
        Error("Please ensure numOutputs matches number of modules").throw;
    };
    snd = Sanitize.ar(snd);
    LocalOut.ar(snd);

    snd = Select.ar(selSnd.mod(7), snd ++ snd.sum);

    snd = Limiter.ar(LeakDC.ar(snd * globalEnv));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\easelDeter_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, lfRate = 7, lfPhase = (-2), selSnd = 3, rotate = 0, doneAction = 2;
    var snd, numInputs, numOutputs, globalEnv;
    numInputs = 6;
    numOutputs = 6;
    snd = LocalIn.ar(numOutputs);

    globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    // Matrix-vector multiplication using multichannel expansion.
    snd = snd * ({arg j;
		{ arg i;
			var offset = i;
			if(i.odd, { offset = i.neg; });
			LFGauss.ar((lfRate + (offset * j)).reciprocal, 0.1, (i + j + lfPhase.round) * pi).round;
		} ! numInputs
	} ! numOutputs);

    snd = snd.sum;

    // If additional modules are added, remember to update numInputs and numOutputs.
    // numInputs should equal the maximum i in snd[i], plus one.
    // numOutputs should equal the number of entries in the snd array.
    snd = [
        // Oscillator that reaches LFO range
        SinOsc.ar(snd[0].linexp(-1, 1, 0.1, 8000)),
        // Oscillator in audio range only
        SinOsc.ar(snd[4].linexp(-1, 1, 100, 8000)),
        // Wavefolder with controllable gain
        (snd[2] * snd[3].linexp(-1, 1, 1, 8)).fold2,
        // Two filters with controllable cutoff and resonance
        MoogFF.ar(snd[4], snd[5].linexp(-1, 1, 10, 8000), snd[0].linlin(-1, 1, 0, 4)) * 3.dbamp,
        MoogFF.ar(snd[1], snd[2].linexp(-1, 1, 10, 8000), snd[3].linlin(-1, 1, 0, 4)) * 3.dbamp,
		// FreeVerb.ar(snd[0], mix: 1),
        // Five-step sequencer
        Demand.ar(Impulse.ar(snd[5].linexp(-1, 1, 0.1, 1000)), 0, Dseq([0.1, 0.5, 0.9, 0.3, 0.4]))
    ];

    if(snd.size != numOutputs) {
        Error("Please ensure numOutputs matches number of modules").throw;
    };
    snd = Sanitize.ar(snd);
    LocalOut.ar(snd);

    snd = Select.ar(selSnd.mod(7), snd ++ snd.sum);

    snd = Limiter.ar(LeakDC.ar(snd * globalEnv));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\rungler_Sd, { arg out = 0, amp = 0.2, pan = 0.3, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, lfoTrigRate = 0.4, tu = 24, ffreq = 24, doneAction = 2;
    var rungler, lfo, snd, runglerOut, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    lfo = {
        var trigger;
        trigger = Dust.ar(lfoTrigRate);
        Select.ar(ToggleFF.ar(trigger), [
            LFNoise2.ar(TExpRand.ar(0.5, 10, trigger)),
            TRand.ar(-1, 1, trigger),
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
    snd = snd * globalEnv * -10.dbamp;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\runglerDeter_Sd, { arg out = 0, amp = 0.2, pan = 0.3, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, lfSrc1Sel = 0, lfSrc1Rate = 0.7, lfSrc2Sel = 1, lfSrc2Rate = 0.24, switchSrcRate = 0.4, tu = 24, ffreq = 24, doneAction = 2;
    var rungler, lfo, lfSource1, lfSource2, snd, runglerOut, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
    snd = snd * globalEnv * -10.dbamp;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

)