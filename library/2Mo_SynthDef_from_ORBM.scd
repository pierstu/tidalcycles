(

///////////////////////////////////////  SynthDef

///////////////////////////////////////  Archetype SynthDef for SuperDirt

SynthDef(\archetypeSd, {
	|out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,clamp=1|
	var line, env, volume, tone, outAudio;
	freq=freq*speed;
	line = Line.ar(begin,end,sustain/speed,doneAction: Done.freeSelf);
	env = Env.new(levels: [0, 1, 0.9, 0], times: [0.1, 0.5, 1], curve: [-5, 0, -5]);
	volume = IEnvGen.ar(env, line);
	tone = (Pulse.ar(freq,line)+Pulse.ar(freq*1.01,line)+Pulse.ar(freq*0.99,line))/3;
	outAudio = RLPF.ar(tone*volume, 20000*clamp*volume,0.3);
	OffsetOut.ar(out,DirtPan.ar(outAudio, ~dirt.numChannels, pan, volume));
}).add;

///////////////////////////////////////  Kick

SynthDef(\snapkickSd, { |out = 0, amp = 0.3, pan = 0, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, doneAction = 2|
	var body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC));
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve), doneAction: doneAction);
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

SynthDef(\IkedaBassSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.2, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, envCurve = (-5), freq = 0, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, gate = 1, doneAction = 2;
	var env, sin, sig;
	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, doneAction: doneAction);
	sin = SinOsc.ar(freq, (Sweep.ar(gate, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ikedaBassBrSd, { arg out = 0, amp = 1, pan = 0, atk = 0, dcy = 0.1, sst = 0.8, rls = 0.01, curve = -5, freq = 0, harmonic = 14.015, iphase = pi/3, gate = 1, doneAction = 2;
	var env, snd;

	env = Env.adsr(
	    	attackTime: atk,
	    	decayTime: dcy,
	    	sustainLevel: sst,
	    	releaseTime: rls,
	    	curve: curve,
	    ).kr(gate: gate, doneAction: doneAction);

	env = env * amp.curvelin(inMin: 0, inMax: 1, outMin: 0, outMax: 1, curve: log(10));

	snd = SinOsc.ar(
		    //Any value for freq here gets added to the freq of the note (n + 0 = n)
		    freq: 0,
		    //Phase sweeps around a circle at (rate / 2pi) to make a sine wave.
		    phase: (Sweep.ar(trig: gate, rate: 2pi * [freq, freq * harmonic]) + iphase).wrap(-pi, pi),
	        mul: [1, 0.01]
	    );

	snd = Mix.ar(snd).tanh;

	snd = LeakDC.ar(snd);

	snd = snd * env;

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\gabberkickSd, { arg out = 0, pan = 0, amp = 0.1, atk = 0.001, rls = 0.05;
    var snd, freq, high, lfo;
	freq = \freq.kr(440).min(1400) * (Env.perc(0.001, 0.08, curve: \curve.kr(-1)).ar * 48 * \bend.kr(1)).midiratio;
    snd = Saw.ar(freq);
    snd = (snd * 100).tanh + ((snd.sign - snd) * -8.dbamp);
    high = HPF.ar(snd, 300);
    lfo = SinOsc.ar(8, [0, 0.5pi]).range(0, 0.01);
    high = high.dup(2) + (DelayC.ar(high, 0.01, lfo) * -2.dbamp);
    snd = LPF.ar(snd, 100).dup(2) + high;
    snd = RLPF.ar(snd, 7000, 2);
    snd = BPeakEQ.ar(snd, \ffreq.kr(3000) * XLine.kr(1, 0.8, 0.3), 0.5, 15);
    snd = snd * Env.asr(atk, 1, rls).ar(2, \gate.kr(1));
    // OffsetOut.ar(out, snd * amp);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickMistSd, { arg out = 0, level = 1, pan = 0, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, curve0_1 = (-4), curve0_2 = (-2), curve0_3 = (-4), env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, curve1_1 = (-4), curve1_2 = (-5), doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [curve0_1, curve0_2, curve0_3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [curve1_1, curve1_2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig.clip2(1);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\kickhiSd, { arg out = 0, amp = 1, pan = 0, vcaLev1 = 0.5, vcaLev2 = 0.1, vcaLev3 = 0.01, vcaLev4 = 0.01, vcaLev5 = 0, vcaTime1 = 0.01, vcaTime2 = 0.5, vcaTime3 = 1.26, vcaTime4 = 0.1, vcaCurve1 = (-4), vcaCurve2 = (-2), vcaCurve3 = (-4), vcfLev1 = 122, vcfLev2 = 30, vcfLev3 = 33, vcfLev4 = 28, vcfTime1 = 0.05, vcfTime2 = 0.29, vcfTime3 = 1, vcfCurve1 = (-4), vcfCurve2 = (-5), tu = 1, doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([vcaLev1, vcaLev2, vcaLev3, vcaLev4, vcaLev5], [vcaTime1, vcaTime2, vcaTime3, vcaTime4], [vcaCurve1, vcaCurve2, vcaCurve3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([vcfLev1, vcfLev2, vcfLev3, vcfLev4], [vcfTime1, vcfTime2, vcfTime3], [vcfCurve1, vcfCurve2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = out + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig * 1.2;
	sig = sig.clip2(1);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick2Sd,{arg out = 0, gate = 1, freq = 60, tu = 1, amp = 1, atf = 80, rls =1, pan = 1;
	var env = EnvGen.ar(Env.perc(0,rls),gate,doneAction:2);
	var frequ = EnvGen.ar(Env([freq-30,freq,60],[0.001,0.01]));
	var sig = SinOsc.ar(frequ*tu,0,env);
	// sig = Pan2.ar(LPF.ar(sig,100), pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(LPF.ar(sig,100), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick2newSd,{arg out = 0, amp = 1, pan = 0, atk = 0, rls = 1, envfT1 = 0.002, envfT2 = 0.1, freq = 60, tu = 1.33, bpeqf1 = 3081, bpeqrq1 = 0.71, bpeqamp1 = (-54), bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 81, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
    var frequ = EnvGen.ar(Env([freq+1100, freq, 31.4],[envfT1, envfT2]));
    var sig = SinOsc.ar(frequ*tu, 0, env);
    sig = BPeakEQ.ar(sig, bpeqf1, bpeqrq1, bpeqamp1);
    sig = sig *0.4*(env+0.2);
    sig = BPeakEQ.ar(sig, bpeqf2, bpeqrq2, bpeqamp2);
    //sig = Limiter.ar(sig,0.5);
    //Out.ar(6,[DelayL.ar(sig*(-1),0.1,SinOsc.kr(-0.1,0,0.05,0.1)),sig]);
	sig = HPF.ar(sig, hpff);
	// sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick3Sd,{arg out = 0, amp = 0.5, pan = 0, tu = 1, atk = 0, rls = 3, freq = 60, gate = 1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
	var frequ = EnvGen.ar(Env([130,freq,30],[0.05,rls]));
	var sig = SinOsc.ar(freq*tu,0,env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick3newSd,{arg out = 0, amp = 0.5, gate = 1, tu = 1, rls = 3, freq = 60, pan = 0;
    var env = EnvGen.ar(Env.perc(0,rls), gate, doneAction:2);
    var frequ = EnvGen.ar(Env([100,50,50],[0.005,0.1]));
    var sig = SinOsc.ar(freq*tu,0,env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kicknoiseSd,{arg out = 0, amp = 0.5, pan = 0;
	var env = EnvGen.ar(Env([0,1,0],[0.01, 0.1]), doneAction: 2);
	var freq =EnvGen.ar(Env([20000,100,30],[0.005,1]));
	var sig =  SinOsc.ar(freq,0,env)+(WhiteNoise.ar(1)*env);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t1kickSd, {arg out = 0, amp = 0.5, pan = 0, rls = 0, doneAction = 2;
	var enva, envf, sig;
	enva = EnvGen.ar(Env([0.01,1,0],[0.001, rls]), doneAction: doneAction);
	envf = EnvGen.ar(Env([800,50],[0.005,1]));
	sig = SinOsc.ar(envf,0,enva);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

~synthSd = SynthDef(\t1kick2Sd, {arg out = 0, amp = 0.5, pan = 0, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = (-4), envfT1 = 0, envfL1 = 10000, envfT2 = 0.002, envfL2 = 20, envfT3 = 0.1, envfL3 = 0, envfT4 = 1, envfL4 = 4, envfCurve = (-4), pitch = 0.1, hpfFreq = 1200, hpfRq = 1, verbMix = 1, verbRoom = 1, verbDamp = 0.5, doneAction = 2;
	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve), doneAction: doneAction);
	var sig = SinOsc.ar(envf+50*pitch, 0, enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = BHiPass4.ar(sig.distort, hpfFreq, hpfRq);
	revSig = FreeVerb.ar(sig, verbMix, verbRoom.max(0.01), verbDamp);
	// revSig = GVerb.ar(sig, Lag3.kr(verbRoom).max(0.01), verbTime, verbDamp);
	sig = SelectX.ar(verbMix, [sig, revSig]);
	// sig = Pan2.ar(sig, pan, amp*enva);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp*enva));
}).add;

SynthDef(\kickmedSd, { | out = 0, level = 0.5, pan = 0, noise = 1, done = 2, dc = 1, snd = 18, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, rlsEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0|
	var env0,env1,
env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,rlsEnv0,0.5],[curve1, curve2, curve3]);
env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2,env1T3,env1T4],[curve1, curve2, curve3]);
env0 = EnvGen.ar(env0, doneAction:done);
env1 = EnvGen.ar(env1);
env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);
son = SelectX.ar(ochoose,[son,son2,son3,son4]);
son = LeakDC.ar(son,dc,30);
son = son + WhiteNoise.ar(noise);
	son = LPF.ar(son, env1m*fratio.max(0.01), env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son = son*level.distort;
	// son = Pan2.ar(son, pan);
	// OffsetOut.ar(out, son*level).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level)).tanh;
//OffsetOut.ar(snd, Mono(son)*level).tanh;
}).add;

SynthDef(\kick808Sd,{arg out = 0, amp = 0.5,  pan = 0, tu = 1, gate = 1, envL1 = 0, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, enfL1 = 1000, enfL2 = 20, enfL3 = 20, enfT1 = 0.001, enfT2 = 0.001, enfT3 = 0.001;
	var env = EnvGen.ar(Env([envL1,envL2,envL3],[envT1,envT2],-8), gate, doneAction:2);
	var enf  = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2,enfT3],-4));
	var sig = SinOsc.ar(tu*(enf+40))*env;
	sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(100,0,50,100*tu),0,0.2)*env,1000);
	// OffsetOut.ar(out, Pan2.ar(sig * env, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick808newSd, { arg out = 0, amp = 0.5, pan = 0, envL1 = 1, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, envCurve = (-8), enfL1 = 5000, enfL2 = 100, enfL3 = 50, enfT1 = 0.0001, enfT2 = 0.01, enfCurve = (-4), tu = 2, sin2Frq = 10, sin2Amp = 50, doneAction = 2;
    var env = EnvGen.ar(Env([envL1, envL2, envL3],[envT1, envT2], -8), doneAction: doneAction);
    var enf  = EnvGen.ar(Env([enfL1, enfL2, enfL3],[enfT1, enfT2, 0.1], enfCurve));
    var sig = SinOsc.ar(tu*(enf))*env;
    sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(sin2Frq, 0, sin2Amp, 40*tu), 0, 0.01) * env, 100);
    sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out,sig*env);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick808AwSd, {arg out = 0, amp = 0.2, pan = 0, freqSrt = 240, freqEnd = 60, freqTime = 0.1, ringTime = 100, envpT1 = 0, envpL1 = 0, envpT2 = 0.2, envpL2 = 1, envpT3 = 0.4, envpL3 = 0.2, envpT4 = 0.4, envpL4 = 0, envpCurve = (-4), dist = 1.5, hpfFreq = 30, tott = 1, durr = 0.01, gate = 1, doneAction = 2;
    var snd, env;
	tott = tott.max(0.01);
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freqSrt, freqEnd, freqTime),
		decaytime: ringTime
	);
	env = EnvGen.ar(Env.pairs([[envpT1, envpL1], [envpT2, envpL2], [envpT3, envpL3], [envpT4, envpL4]], envpCurve), gate, doneAction: doneAction);
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

SynthDef(\kick808BrSd, {arg out = 0, amp = 1, pan = 0, atk = 0.001, rls = 1, freq1 = 240, freq2 = 60, ringTime = 10, dist = 0.5, doneAction = 2;
	var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = Env.perc(atk, rls, amp).kr(doneAction: doneAction);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kikAwSd, { |out = 0, amp = 0.5, pan = 0, basefreq = 50, ratio = 7, sweeptime = 0.05, envL1 = 1, envL2 = 0.8, envL3 = 0, envT1 = 0.3, envT2 = 0.15|
    var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([envL1, envL2, envL3], [envT1, envT2], -4), doneAction: 2),
	sig = SinOsc.ar(fcurve, 0.5pi, env).distort * amp;
    // OffsetOut.ar(out, sig ! 2);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickbassSd, { | out = 0, level = 0.5, pan = 0, atk = 0.01, dcy = 0.2, rls = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, done = 2 |
	var env0,env1,
env1m, son, son2,son3,son4,p2;

	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[atk, dcy, rls],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0,SinOsc.kr(0.025) ,doneAction: done);
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

SynthDef(\drumkickSd, { arg out = 0, amp = 0.5, pan = 0.0, atk = 0.0001, rls = 0.09, curve = 8, attSinFreq = 0.0001, rlsSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, attBpfFreq = 0.001, rlsBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineLevBpf = 0.1, gate = 1, doneAction = 2;
	var source;

	source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, rlsSinFreq, levSin, curveSinFreq), gate, 1000, 45), 1, 1) +
	((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, rlsBpfFreq, levBpf, curveBpf), gate, levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineLevBpf)) * EnvGen.kr(Env.perc(atk, rls, curve: curve), gate, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(source, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickAwSd, {arg out = 0, amp = 0.5, pan = 0, atk = 0.01, rls = 0.45, sinfreq = 70, glissf = 0.9, doneAction = 2;
	var gliss = XLine.kr(sinfreq, sinfreq*glissf, rls);
	var snd = SinOsc.ar(gliss);
	var env = EnvGen.kr(Env.perc(atk, rls), doneAction: doneAction);
	snd = snd * env * amp;
	snd = Limiter.ar(snd,1,0.001);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick3AwSd, {arg out = 0, amp = 0.5, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.8, envL4 = 0, atk = 0.01, dcy = 0.1, rls = 0.2, punch = 1, envfLev1 = 400, envfLev2 = 66, envfTime = 0.08, envfCurve = -3, doneAction = 2;
	var freq, env, sig;
    freq = EnvGen.kr(Env([envfLev1, envfLev2], [envfTime], envfCurve));
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [atk, dcy, rls]), doneAction: doneAction);
	sig = Normalizer.ar(SinOsc.ar(freq, 0.5pi, punch).distort, 1) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kicklaserbeamSd, { arg out = 0, amp = 0.3, pan = 0.0, freq = 13007, freqenvL1 = 3.97, freqenvL2 = 5, freqenvL3 = 0, freqenvL4 = 2.97, freqenvT1 = 0.16, freqenvT2= 0.07, freqenvT3= 0.26, ampenvL1 = 1, ampenvL2 = 1, ampenvL3 = 0, ampenvL4 = 0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3]),
		levelScale: amp,
		doneAction: doneAction);
	snd = LFTri.ar(freq * freqenv, 0, ampenv);
	snd = BHiPass4.ar(snd, hpfFreq, hpfRq);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

// SynthDef(\tweetBassLeakSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, rls = 1, atk = 0.01, dcy = 0.4, freq = 2, rq = 0.1, gate = 1, doneAction = 2;
// 	var sig, demand, env, globenv;
// 	demand = Demand.kr(
// 		gate,
// 		0,
// 		Drand([0.8, 1], inf)
// 	);
// 	env = Decay2.kr(
// 		demand,
// 		atk,
// 		dcy
// 	);
// 	sig = Saw.ar(freq, env) ** 1.5;
// 	sig = BRF.ar(sig, demand * 20 + [45.1, 45], rq);
// 	//globenv = EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
// 	globenv = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
// 	sig = sig * globenv;
// 	sig = LeakDC.ar(sig).tanh;
// 	// OffsetOut.ar(out, sig * amp);
// 	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
// }).add;

// edit 060892020
SynthDef(\tweetBassLeakSd, { arg out = 0, amp = 0.2, pan = 0, atkEnv = 0.01, rlsEnv = 1, atkDec2 = 0.01, dcy = 0.4, freq = 2, rq = 0.1, gate = 1, doneAction = 2;
	var sig, demand, env, globenv;
	demand = Demand.kr(
		gate,
		0,
		Drand([0.8, 1], inf)
	);
	env = Decay2.kr(
		demand,
		atkDec2,
		dcy
	);
	sig = Saw.ar(freq, env) ** 1.5;
	sig = BRF.ar(sig, demand * 20 + [45.1, 45], rq);
	//globenv = EnvGen.kr(Env.linen(atkGlobal, 1, rlsEnv), doneAction: doneAction);
	globenv = EnvGen.kr(Env.asr(atkEnv, releaseTime: rlsEnv), gate, doneAction: doneAction);
	sig = sig * globenv;
	sig = LeakDC.ar(sig).tanh;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetKickIntSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, impfreq = 2, phRate = 64, lagFreq = 2, inAmt = 99, coef1 = 0.9, coef2 = 0.99, doneAction = 2;
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
	env = EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
	sig = SinOsc.ar(freq, phase, env);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickParallaxSd, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, kharm1 = 1, kharm2 = 2, kharm3 = 3, kharm4 = 4, kamp1 = 0.05, kamp2 = 0.05, kamp3 = 0.05, kamp4 = 0.05, kring1 = 1, kring2 = 1, kring3 = 1, kring4 = 1, frqScale = 1, decScale = 1, resoMix = 0.5, doneAction = 2;
	var sig, env_amp, env_freq, kharm, kamp, kring, reso;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, doneAction: doneAction);

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

SynthDef(\kickParallax1Sd, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, doneAction = 2;
	var sig, env_amp, env_freq;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, doneAction: doneAction);

	env_freq = Env.perc (envFrqAtt, envFrqRel, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq * env_freq, 0, env_amp);
	// sig = Pan2.ar (sig, pan);
	// OffsetOut.ar (out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\tabassSd, { arg out = 0, amp = 0.8, pan = 0, gate = 1, atk = 0.01, rls = 2, freq = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = LFTri.ar(freq);
	20.do{
		sig = BAllPass.ar(sig,80,1);
		sig = ((sig+0.02)*LFNoise0.kr(1/2)*6).tanh;
		sig = LeakDC.ar(sig,0.995);
	};
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\mcldSd, { arg out = 0, amp = 0.7, pan = 0, atk = 0.01, rls = 2, impFreq = 10, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, env, input;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	input = LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100;
	sig = DynKlank.ar(
		`[input],
		Impulse.ar(impFreq)
	);
	LocalOut.ar(sig);
	sig = HPF.ar(sig, hpfFreq).clip2;
	sig = Splay.ar(sig * env, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;*/

SynthDef(\batuhanSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, rls = 5, eSawDec = 0.6, eSinL1 = 0, eSinL2 = 1, eSinL3 = 0, eSinL4 = 0.32, eSinT1 = 0.24, eSinT2 = 0.02, eSinT3 = 0.12, eSinC1 = (-4), eSinC2 = (-4), eSinC3 = (-4), sinFreq = 33, sawMix = 1, sawFreq = 8, bpfFreq = 162, bpfRq = 1, bpfMix = 0, brfFreq1 = 45.1, brfFreq2 = 45, brfRq = 1, doneAction = 2;
	var sig, env, trig, envSaw, envSin;
	trig = Impulse.kr(0);
	env = Linen.kr(trig, atk, 1, rls, doneAction);
	envSaw = Decay2.kr(
		trig,
		0.01,
		eSawDec
	);
	envSin = EnvGen.kr(Env.new([eSinL1, eSinL2, eSinL3, eSinL4], [eSinT1, eSinT2, eSinT3], [eSinC1, eSinC2, eSinC3]), trig);
	sig = ((Saw.ar(sawFreq, envSaw) ** 1.5) * sawMix) + (SinOsc.ar(sinFreq, 0, envSin) * (1 - sawMix));
	sig = (sig * (1 - bpfMix)) + (BPF.ar(sig, bpfFreq, bpfRq.max(0.01)) * bpfMix);
	sig = BRF.ar(sig, trig * 20 + [brfFreq1, brfFreq2], brfRq.max(0.01));
	sig = Splay.ar(sig, levelComp: false);
	sig = LeakDC.ar(sig).tanh;
	sig = HPF.ar(sig, 28);
	//sig = (sig[0] + sig[1])!2; // mono
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
}).add;

SynthDef(\kickySd,{ arg out = 0, amp=1, pan = 0, startFreq=80, endFreq=15, length=6, decay=4, lowpass=800, noiseAmp=0.0, gain=1, doneAction = 2;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), length, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, length, 1, -5), 1, doneAction: doneAction);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

// SynthDef(\kickeySd,{ arg out = 0, amp = 1, pan = 0, atk = 0.0014, rls = 0.8, curve = (-5), startFreq = 60, endFreq = 10, linedur = 0.8, dcy = 0.8, lowpass = 500, rq = 1, gain = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, doneAction = 2;
// 	var sig, env, freq;
// 	freq = XLine.kr(startFreq, endFreq, linedur, 1, 0);
// 	env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
// 	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
// 	sig = sig * gain;
// 	//sig = sig.softclip * amp * env;
// 	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * env;
// 	// OffsetOut.ar(out, [sig,sig]);
// 	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
// }).add;

SynthDef(\kickBoomySd, { arg out = 0, amp=1, pan = 0, atk = 0.0014, rls=0.4, curve = (-5), frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, gain=1.1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(frq1/4) + SinOsc.ar(frq2/4) + LFTri.ar(frq3/4) + LFTri.ar(frq4/4) + BrownNoise.ar(0.1)) * env * amp;
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.perc(0.001,0.001,0.5)),500);
	sig = sig * gain;
	sig = sig.softclip * 1;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick_oto309Sd, { arg out=0, amp=0.5, pan=0, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.5, env0L4 = 0, env0T1 = 0.005, env0T2 = 0.06, env0T3 = 0.26, env0Crv1 = (-4), env0Crv2 = (-2), env0Crv3 = (-4), env1L1 = 110, env1L2 = 59, env1L3 = 29, env1T1 = 0.005, env1T2 = 0.29, env1Crv1 = (-4), env1Crv2 = (-5), doneAction = 2;
	var env0, env1, env1m, son;

	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [env0Crv1, env0Crv2, env0Crv3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [env1Crv1, env1Crv2]));
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2;
	son = son.clip2(1);

	// OffsetOut.ar(out, Pan2.ar(son * amp, pan));
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick_oto309BrSd, { arg out = 0, amp = 0.5, pan = 0, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = -4,
	//Other Controls:
	filterHarmonic = 1.5, preamp = 1.25, pulseAmp = 0.5, noiseAmp = 1, sineAmp = 1,
	doneAction = 2;
	var env, envp, snd;

	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3], curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curve, curve * 1.25]).kr.midicps;

	snd = LFPulse.ar(freq: envp).range(-1 * pulseAmp, pulseAmp);
	snd = snd + WhiteNoise.ar(mul: noiseAmp);
	snd = LPF.ar(in: snd, freq: envp * filterHarmonic, mul: env);
	snd = snd + SinOsc.ar(freq: envp, phase: 0.5, mul: env * sineAmp);

	snd = Mix.ar(snd) * preamp;
	snd = snd.clip2(1) * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickBlocksSd, { arg out = 0, amp = 0.4, pan = 0, curve = (-4),
	//tone1 arguments
	t1freq = 400, t1harmonic = 2, t1glide = 0.01,
	t1atk = 0.0005, t1rls = 0.01, t1curve = (-4), t1del = 0, t1amp = 1,
	//tone2 arguments
	t2freq = 50, t2harmonic = 3.44, t2glide = 0.01,
	t2atk = 0.0001, t2rls = 0.3, t2curve = (-4), t2del = 0.005, t2amp = 1,
	//hit1 arguments
	h1freq = 100, h1harmonic = 8, h1glide = 0.01, h1rq = 0.6,
	h1atk = 0.001, h1rls = 0.02, h1curve = (-4), h1del = 0.001, h1amp = 1,
	//hit2 arguments
	h2freq = 1320, h2harmonic = 1, h2glide = 0,
	h2atk = 0.003, h2rls = 0.03, h2curve = (-4), h2del = 0, h2amp = 0.5,
	//click arguments
	cfreq = 6100, crq = 1, camp = 1.41,
	doneAction = 2;

    var env, snd, noise, tone1, tone2, hit1, hit2, click;

	env = EnvGen.kr(Env.linen(0.01, 1, 6), doneAction: doneAction);
	noise = Hasher.ar(Sweep.ar); //deterministic white noise

    tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide),
		mul: Env.perc(attackTime: t1atk, releaseTime: t1rls, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide),
		mul: Env.perc(attackTime: t2atk, releaseTime: t2rls, level: t2amp, curve: t2curve).delay(t2del).ar);

    hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide),
		rq: h1rq,
		mul: Env.perc(attackTime: h1atk, releaseTime: h1rls, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide),
		mul: Env.perc(attackTime: h2atk, releaseTime: h2rls, level: h2amp, curve: h2curve).delay(h2del).ar);

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

SynthDef(\ringkickSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, dcy = 2.63, lpfFreq = 13760, frq = 26, envfL1 = 6416.9, envfL2 = 0, envfL3 = 66.2, envfL4 = 20, envfL5 = 0, envfT1 = 0, envfT2 = 0.04, envfT3 = 0.53, envfT4 = 2.37, curve = (-4.92), envfAmt = 0.32, lfnFrq = 59.2, lfnAmt = 0, ringAmp = 0.04, sawFreq = 20.7, sawPh = 6.18, sawDecDiv = 7, sawAmp = 0.18, sinFreq = 10010, sinFb = 0, sinDecDiv = 188, sinAmp = 0.29, doneAction = 2;
	var snd, env, trig, envf, mod;
	mod = LFNoise2.kr(lfnFrq, lfnAmt).range(1, lfnAmt);
	env = EnvGen.kr(Env.linen(atk, 1, dcy), doneAction: doneAction);
	envf = EnvGen.kr(Env([envfL1, envfL2, envfL3, envfL4, envfL5], [envfT1, envfT2, envfT3, envfT4], [curve, curve/2, curve]), levelScale: envfAmt * mod, doneAction: doneAction);
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

SynthDef(\kickRingzSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.1, envL2 = 1.2, envL3 = 3, envL4 = 2.1, envL5 = 0.1, envT1 = 0.1, envT2 = 0.2, envT3 = 0, envT4 = 0.1, curve = (-4), envpL1 = 0.1, envpL2 = 1.2, envpL3 = 3, envpL4 = 2.1, envpT1 = 0.1, envpT2 = 0, envpT3 = 1.2, curvep = (-4), freq = 40, dcy = 0.25, ffreq = 1000, doneAction = 2;
	var snd, env, envp;

	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve, curve/2, curve]), doneAction: doneAction);
	envp = EnvGen.kr(Env([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3], [curvep, curvep*1.25, curvep].midicps), doneAction: doneAction);
	snd = Ringz.ar(
		    in: LPF.ar(in: Impulse.ar(0), freq: ffreq),
		    freq: freq * envp,
		    decaytime: dcy,
		    mul: amp
	);

	snd = snd.tanh.sin * 2 * env;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick_chirpSd, { arg out = 0, amp = 0.1, pan = 0, curve = -20, atk = 0.001, rls = 0.5, maxFreq = 500, doneAction = 2;
    var env, snd;

	env = Env.perc(attackTime: atk, releaseTime: rls, curve: curve).exprange(0, maxFreq).kr(doneAction: doneAction);

    snd = SinOsc.ar(freq: env, mul: amp);
    snd = LeakDC.ar(snd);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick_electroSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.01, rls = 0.3, envbfL1 = 261, envbfL2 = 120, envbfL3 = 51, envbfRel = 0.003, envbfC = (-4), envbaL1 = 0, envbaL2 = 1, envbaL3 = 0.1, envbaL4 = 0.8, envbaL5 = 0, envbaT1 = 0.2, envbaT2 = 0.1, envbaT3 = 0.03, envbaT4 = 0.2, envbaC1 = (-4), envbaC2 = (-4), envbaC3 = (-4), envbAmp = 1, pfSt = 750, pfEnd = 261, pfDur = 0.02, envpaL1 = 0, envpaL2 = 0.4, envpaL3 = 1, envpaL4 = 0.02, envpaL5 = 0, envpaT1 = 0.1, envpaT2 = 0.4, envpaT3 = 0.03, envpaT4 = 0.2, envpaC1 = (-4), envpaC2 = (-4), envpaC3 = (-4), envpAmp = 1, envcaAtt = 0, envcaRel = 0.2, envcAmp = 1, cFundFreq = 910, cFormFreq = 4760, cBwFreq = 2110, lpfFreq = 3140, doneAction = 2;
    var env, body, bodyFreq, bodyAmp, pop, popFreq, popAmp, click, clickAmp, snd;

	env = EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = Env.new(
		    levels: [envbfL1, envbfL2, envbfL3],
		    times: [envbfRel / 8.57, envbfRel / 3.75],
		    curve: envbfC
	).kr;

	bodyAmp = Env.new(
		[envbaL1, envbaL2, envbaL3, envbaL4, envbaL5],
		[envbaT1, envbaT2, envbaT3, envbaT4],
		[envbaC1, envbaC2, envbaC3]
	).kr(levelScale: envbAmp);

    body = SinOsc.ar(freq: bodyFreq, mul: bodyAmp);

    // pop sweeps over the midrange
    popFreq = XLine.kr(start: pfSt, end: pfEnd, dur: pfDur);

	popAmp = Env.new(
		[envpaL1, envpaL2, envpaL3, envpaL4, envpaL5],
		[envpaT1, envpaT2, envpaT3, envpaT4],
		[envpaC1, envpaC2, envpaC3]
	).kr(levelScale: envpAmp);

    pop = SinOsc.ar(freq: popFreq, mul: popAmp);

    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
	clickAmp = Env.perc(
		attackTime: envcaAtt,
		releaseTime: envcaRel,
		level: envcAmp
	).kr;

	click = LPF.ar(
		in: Formant.ar(fundfreq: cFundFreq, formfreq: cFormFreq, bwfreq: cBwFreq, mul: clickAmp),
		freq: lpfFreq
	);

	//Putting it all together:
	snd = Mix.ar([body, pop, click]);
    snd = snd.tanh * env;

    // OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\kik3BrSd, { arg out = 0, amp = 1, pan = 0, freq = 66, atk = 0.01, dcy = 0.1, decaylevel = 0.8, rls = 0.3, envCurve = -4, sweeptime = 0.08, sweepCurve = \exp, harmonic = 6, preamp = 3;
	var snd, env, fenv;

	env = Env.new(levels: [0, amp, decaylevel * amp, 0], times: [atk, dcy, rls], curve: envCurve).kr(doneAction: 2);

	fenv = Env.new(levels: [freq * harmonic, freq], times: [sweeptime], curve: sweepCurve).kr;

	snd = SinOsc.ar(freq: fenv, mul: preamp).distort;

    snd = Normalizer.ar(in: snd, level: env);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;*/

// nouveau 05 09 2020
SynthDef(\kik3BrSd, { arg out = 0, amp = 1, pan = 0, freq = 66, atk = 0.01, dcy = 0.1, decaylevel = 0.8, rls = 0.3, envCurve = -4, sweeptime = 0.08, sweepCurve = 2, harmonic = 6, preamp = 3;
	var snd, env, fenv;

	env = Env.new(levels: [0, amp, decaylevel * amp, 0], times: [atk, dcy, rls], curve: envCurve).kr(doneAction: 2);

	fenv = Env.new(levels: [freq * harmonic, freq], times: [sweeptime], curve: sweepCurve).kr;

	snd = SinOsc.ar(freq: fenv, mul: preamp).distort;

    snd = Normalizer.ar(in: snd, level: env);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;


SynthDef(\sosKickSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
	// sub controls
	startsubfreq = 60, endsubfreq = 32, linesubdur = 0.08, subdecay = 0.2, sublowpass = 500,
	// drum controls
	drumFreq = 50, drumHarmonic = 2, drumSweep = 0.02, drumAtt = 0.005, drumRel = 0.4, curve = (-4),
	drumFilter = 1000, modIndex = 6.5, modFreq = 5,
	// beater controls
	beaterFreq = 500, beaterHarmonic = 12, beaterSweep = 0.03, noiseMod = 500, beaterL1 = 0, beaterL2 = 1, beaterL3 = 2.4, beaterL4 = 0, beaterT1 = 0.01, beaterT2 = 0.3, beaterT3 = 0.08,
	// click controls
	clkffreq = 500, clkres = 0,
	gate = 1, doneAction = 2;

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

	snd = snd * EnvGen.kr(Env.asr(atk, 1, rls), gate, doneAction: doneAction);
    //DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\technokickSd, {
	| out=0, amp=0.5, pan = 0, atk = 0.01, rls = 6, freq=51.913087197493, dcy=0.28571428571429, click=0.008, spread=0.1, damp=0.6, gate=1, doneAction = 2 |
	var sig, env, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env = EnvGen.kr(Env.linen(atk, rls*2, rls), doneAction: doneAction);
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -8, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rls/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(dcy, dcy/2, 1, 0.01, curve: 3), gate); // for reverb
	// separate signals for extra processing
	low  = SinOsc.ar(freq * env1 * env2);
	high = WhiteNoise.ar() * wEnv * 0.6;
	high = BBandPass.ar(high, 1000, 2);
	dry = Mix.new([low, high]) * aEnv;
	dry = CrossoverDistortion.ar(dry * 0.3, 0.9, 1);
	// dry = dry * 0.25;
	// equalizer
	dry = BPeakEQ.ar(dry, 5500, db: 10);
	dry = BPeakEQ.ar(dry, 360, db: -12, rq: 2);
	dry = BLowShelf.ar(dry, 300, db: 6).distort;
	// compression
	dry = Compander.ar(dry, dry, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 5);
	// finalize dry signal
	dry = Pan2.ar(dry * aEnv);
	// create reverb signal
	// verb = FreeVerb2.ar(dry[0],dry[1],mix: 1,room: 1, damp: 1).distort * vEnv;
	verb = GVerb.ar(dry, roomsize: 10, revtime: rls,
		damping: damp, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
		maxroomsize: 100, mul: 1) ;
	// Sum the double stereo output into a single stereo one
	verb = verb.sum;
	// eq

	verb = BLowPass.ar(verb, 400+freq,2);

	// Reduce stereo spread, and balance audio to be level no matter the spread (more or less)
	verbHi = BHiPass.ar(verb, 200);
	verbHi = Balance2.ar(verbHi[0] + (verbHi[1] * spread), // left
		verbHi[1] + (verbHi[0] * spread), level: 0.5 + (1-spread)); // right
	// Keep low frequencies in mono
	verbLo = BLowPass.ar(verb, 200);
	verbLo = Balance2.ar(verbLo[0] + verbLo[1], verbLo[1] + verbLo[0], level: 0.5);
	verb = verbHi + verbLo;
	verb = Compander.ar(verb,verb, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 0.25) * vEnv;
	// finalize signals
	sig = dry + verb;
	sig = Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1)!2;
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
}).add;

///////////////////////////////////////  Snare

SynthDef(\sdSd, { | out = 0, amp = 1, pan = 0, atk = 0, rls = 0.05, freq = 200, ffreq = 12000 |
	var osc1, osc2, env, sig;
	osc1 = WhiteNoise.ar;
	osc2 = FSinOsc.ar(freq);
	env = EnvGen.kr(Env.perc(atk, rls), doneAction: 2);
	sig = LPF.ar(Mix([osc1, osc2]), ffreq) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snareSd, { arg out=0, amp=0.1, pan = 0, tu=1, gate=1, freq=200, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,0.1));
	var enf = EnvGen.ar(Env([600,1057,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(15100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snarenewSd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = (-4), mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var sig, env, envp;
    /*var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));*/
	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3], curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu*envp,0,0.5)*env;
	sig = ((PinkNoise.ar*env) * mixNoise) + (sig * (1 - mixNoise));
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

SynthDef(\snare2Sd,{arg out=0, amp=1, pan = 0, gate = 1;
	var env = EnvGen.ar(Env.perc(0.001,0.2),gate,doneAction:2);
	var freq = EnvGen.ar(Env([12000,100,12000],[0.01,0.01]));
	var sig = WhiteNoise.ar(env);
	sig = LPF.ar(sig,freq);
	sig = sig.tanh;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp) );
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snare2newSd, { arg out = 0, amp = 0.1,  pan = 0, tu = 1, gate = 1, envAtt = 0.1, envRel = 0.1, enfL1= 1600, enfL2 = 177, enfL3 = 190, enfT1 = 0.01, enfT2 = 0.1;
    var sig;
    var env = EnvGen.ar(Env.perc(envAtt,envRel));
    var enf = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2],-4));
    var sig2 = BrownNoise.ar(1);
    sig = SinOsc.ar(tu*enf+27,0,0.1)*env;
    sig = WhiteNoise.ar(0.6)+sig+(LPF.ar(sig2,250,0.5)*env);
//    sig = RHPF.ar(sig, \hpf.kr(100)*tu, \rq.kr(1));
//    sig = sig + Mix.ar(BPF.ar(sig,[1207,4300],[0.5,0.5])*0.1);
    //sig = RLPF.ar(sig, \lpf.kr(11000)*tu, \rq.kr(1));
    //sig = CombL.ar(sig,0.2,0.1);
    sig = BRF.ar(sig,450,0.3);
    sig = HPF.ar(sig,250);
    sig = sig * EnvGen.ar(Env.perc(0.02,\rel.kr(0.4),-4),gate,doneAction:2);
    //sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\jungleSnareSd, { arg out = 0, amp = 0.1, pan = 0, envL1 = 1, envL2 = 0, envL3 = 1, envL4 = 0, envT1 = 0, envT2 = 0.004, envT3 = 0.05, envCurve = (-4), envfL1 = 1600, envfL2 = 5600, envfL3 = 800, envfL4 = 250, envfT1 = 0.001, envfT2 = 0.001, envfT3 = 0.001, envfCurve = (-4), envnAtt = 0.01, envnRel = 1, envnCurve = -4, noiseAmp = 1, tu = 1, kracter = 10, gate = 1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, doneAction: doneAction);
	var envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4],[envfT1, envfT2, envfT3], envfCurve));
	var envn = EnvGen.ar(Env.perc(envnAtt, envnRel), 1, envnCurve);
	sig = SinOsc.ar(tu*envf+107,0,0.5)*env;
	sig = (WhiteNoise.ar(envn) * noiseAmp) + sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \hpfRq.kr(1));
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+ (WhiteNoise.ar(envn)+BrownNoise.ar(envn/8) * noiseAmp);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \lpfRq.kr(0.5));
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([envf,envf*0.9,envf*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(envn) * noiseAmp,envf*4,1,1)+sig )*envn ;
	sig = CompanderD.ar(sig*kracter,0.8,0.3,0.5,0.001,0.2,env);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t5snareSd, { arg out=0, amp=0.3, pan=0, tu=1, freq=200, gate=1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.1],-4));
	//sig = SinOsc.ar(tu*enf+1207,0,0.5)*env;
	sig = WhiteNoise.ar;
	sig = FreeVerb.ar(sig,0.5,1);
	sig = RHPF.ar(sig, \hpf.kr(180)*tu, \hpfRq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(12100)*tu, \lpfRq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),-4),gate,doneAction: doneAction);
	sig = sig*amp;
	sig = CompanderD.ar(sig,1,1,0.1,0.01,0.4);
	sig = FreeVerb.ar(sig,1,1)+sig;
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snare808Sd, { arg out = 0, amp = 0.1, pan = 0, freq = 200, tu = 1, gate = 1;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction:2);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snaremedSd, { | out = 0, level = 1, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, rlsEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.1, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, doneAction = 2|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,rlsEnv0],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0, doneAction: doneAction);
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

SynthDef(\snareAwSd, {arg out = 0, amp = 0.1, pan = 0, sinfreq = 180, atk = 0.01, rls = 0.2, ffreq = 2000;
	var snd1 = WhiteNoise.ar(amp);
	var snd2 = SinOsc.ar(sinfreq,0,amp);
	var env = EnvGen.kr(Env.perc(atk, rls), doneAction: 2);
	var sum = HPF.ar(snd1, ffreq) + snd2;
	// OffsetOut.ar(out, Pan2.ar(sum * env, pan));
	OffsetOut.ar(out, DirtPan.ar(sum, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\snareySd,{ arg out = 0, amp=0.75, pan = 0, atk = 0.001, rls = 0.3, freq=120, gain=0.5, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(atk, rls, 1, -9), 1, doneAction: doneAction);
	sig = {(SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5))!2};
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\snarySd,{ arg out = 0, amp=0.75, pan = 0, atk = 0.001, rls = 0.1, curve = (-5), freq=120, gain=1, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5)) * env * amp;
	sig = sig * gain * 0.4;
	sig = sig.softclip * amp;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kraftySnareSd, { arg out = 0, amp = 1, pan = 0, freq = 6000, rq = 3, atk = 0.01, dcy = 0.2, curve = -6, doneAction = 2;
	var snd, env;

	env = Env.perc(attackTime: atk, releaseTime: dcy, curve: curve).kr(doneAction: doneAction);

	snd = PinkNoise.ar(amp);

	snd = BPF.ar(snd, freq, rq, env);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\neuroSnareSd, { arg out = 0, amp = 0.1, pan = 0, freq = 160, curve = -4, preamp = 1.4,
	//Click Controls
	clickatk = 0.001, clicksst = 0.01, clickrls = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
	//Body Controls
	bodyatk = 0.04, bodyrls = 0.2, bodyamp = 2,
	//Rattle Controls
	rattlehold = 0.01, rattleatk = 0.05, rattlerls = 0.2, rattleamp = 0.7, rattlefreq = 4000, rq = 0.5, rattlepeak = 3,
	//Sweep Controls
	sweepatk = 0.001, sweeprls = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500,
	doneAction = 2;

    var snd, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;

    // a percussive click to give it some attack
	cEnv = Env.linen(
		            attackTime: 0.001,
		            sustainTime: 0.01,
		            releaseTime: 0.001,
			        level: clickamp
	            ).ar;

	click = Hasher.ar(Sweep.ar);

	click = HPF.ar(in: click, freq: hipass);

    click = LPF.ar(in: click, freq: lopass);

	click = click * cEnv;

    // sine sweep body
	bEnvFreq = Env.new(
			        levels: [2.5, 1.225, 1],
			        times: [bodyatk, bodyrls],
			        curve: \exp
	            ).ar;

	bEnvAmp = Env.perc(
		            attackTime: bodyatk,
		            releaseTime: bodyrls,
		            level: bodyamp,
		            curve: curve
	            ).ar;

	body = SinOsc.ar(freq: freq * bEnvFreq, mul: bEnvAmp);

	body = body.tanh;

    // sound of snare coils rattling
	rEnv = Env.perc(
			        attackTime: rattleatk,
			        releaseTime: rattlerls,
			        level: rattleamp,
			        curve: curve
	            ).delay(rattlehold).ar;

	rattle = Hasher.ar(Sweep.ar);

	rattle = BPeakEQ.ar(in: rattle, freq: rattlefreq, rq: rq, db: rattlepeak);

	rattle = HPF.ar(in: rattle, freq: hipass);

	rattle = rattle * rEnv;

    // another sound sweep to improve the atk, optional
	sEnvFreq = XLine.kr(
		    	    start: sweepstart,
		    	    end: sweepend,
		    	    dur: sweeprls / 2
	            );

	sEnvAmp = Env.perc(
			        attackTime: sweepatk,
			        releaseTime: sweeprls,
			        level: sweepamp,
			        curve: curve
	            ).ar;

	sweep = SinOsc.ar(freq: sEnvFreq, mul: sEnvAmp);

    // distortion helps glue everything together and acts as a compressor
	snd = Mix.ar(click + body + rattle + sweep);

	snd = (snd * preamp).tanh * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snare909Sd, { arg out = 0, amp = 0.5, pan = 0, freq = 85, atk = 0.0005, curve = -2, toneRel = 0.075, toneAmp = 0.25, noiseRel = 0.4, noiseAmp = 0.2, nyquist = 2200, lpFreq = 7040, hpFreq = 523, doneAction = 2;
	var rlsTimes, env, tone, noise, snd;

	rlsTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

	env = Env.perc(attackTime: atk, releaseTime: rlsTimes, level: amp, curve: curve).kr;

	tone = LFTri.ar(freq: [1, 1.78] * freq, mul: toneAmp);

	noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

	noise = LPF.ar(in: noise, freq: lpFreq, mul: noiseAmp);

	snd = tone ++ [noise, HPF.ar(in: noise, freq: hpFreq)];

	snd = Mix.ar(snd * env);

	DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snareElectroSd, { arg out = 0, amp = 0.4, pan = 0, atk = 0.001, rls = 0.15, curve = -4, popfreq = 160, sweep = 0.01, noisefreq = 810, rq = 1.6, blend = 0.41, doneAction = 2;
    var pop, popEnv, popSweep, noise, noiseEnv, snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popSweep = Env.new(levels: [20.4, 2.6, 1] * popfreq, times: [sweep / 2, sweep], curve: \exp).ar;

    popEnv = Env.perc(attackTime: atk, releaseTime: 0.73 * rls, level: blend, curve: curve).kr;

	pop = SinOsc.ar(freq: popSweep, mul: popEnv);

    // bandpass-filtered white noise
    noiseEnv = Env.perc(attackTime: atk, releaseTime: rls, level: 1 - blend, curve: curve).kr(doneAction: doneAction);

	noise = BPF.ar(in: WhiteNoise.ar, freq: noisefreq, rq: rq, mul: noiseEnv);

    snd = Mix.ar(pop + noise) * amp;

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snareSteinSd, { arg out = 0, amp = 1, pan = 0, atk = 0.0005, curve = -4, tonerls = 0.075, noiserls = 0.2,
	//Other Controls, blend ranges from 0 to 1.
	noisetop = 7040, noisebottom = 523, noiseamp = 0.2, tonelo = 185, tonehi = 330, toneamp = 0.5, blend = 0.2,
	doneAction = 2;

    var env, tone, noise, snd;

	env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
	//Sines for the frequency of the drum:
    tone = SinOsc.ar(freq: [tonelo, tonehi]);

	tone = tone * Env.perc(
		                attackTime: atk,
		                releaseTime: [tonerls, 0.73 * tonerls],
		                level: toneamp,
		                curve: curve
	                ).kr;

	//Noise for the rattling of the snares: (original used WhiteNoise alone)
	noise = PinkNoise.ar(noiseamp * (1 - blend)) + WhiteNoise.ar(noiseamp * blend);

	noise = LPF.ar(in: noise, freq: noisetop);

	snd = noise * Env.perc(
		                attackTime: atk,
		                releaseTime: noiserls,
		                curve: curve
	                ).kr;

	snd = snd +	HPF.ar(
		            in: noise,
		            freq: noisebottom,
		            mul: Env.perc(
			                    attackTime: atk,
			                    releaseTime: 0.915 * noiserls,
			                    curve: curve
			                ).kr
	            );

	//Mix it all together:
	snd = Mix.ar(snd + tone) * amp * env;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosSnareSd, { arg out = 0, amp = 0.8, pan = 0, atk = 0.005, rls = 0.1, curve = -4, freq = 405,
	//drumMode Controls
	drumModeAmp = 0.25, timbreIndex = 0.385, modHarmonic = 0.452,
	//snares controls
	snareAmp = 40, nyquist = 1700, snareRez = 1000, ffreq = 2000, rq = 0.1, bwr = 1,
	doneAction = 2;

	var env, drumMode, drumModeEnv, snares, snareEnv, snd;

	env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
	drumModeEnv = Env.perc(attackTime: atk, releaseTime: rls, level: 0.5, curve: curve).kr;

	drumMode = SinOsc.ar(freq: freq * 0.53, mul: drumModeEnv);

	drumMode = drumMode + SinOsc.ar(freq: freq, mul: drumModeEnv);

	drumMode = drumMode + PMOsc.ar(
		            carfreq: Saw.ar(freq * 0.85),
					modfreq: freq * modHarmonic,
					pmindex: timbreIndex,
					mul: drumModeEnv * 10);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	snareEnv = Env.perc(attackTime: atk, releaseTime: rls, curve: curve).kr;

	snares = Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(nyquist * 2));

	snares = BRF.ar(in: snares, freq: 4 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: 2.5 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: 1.8 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: ffreq, mul: snareEnv, rq: rq);

	snares = Resonz.ar(in: snares, freq: snareRez, bwr: bwr, mul: snareAmp) ;

	snd = Mix.new(drumMode + snares) * env * amp;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  HiHat

SynthDef(\hatSd, { | out = 0, amp = 1, pan = 0 |
	var osc1, env;
	osc1 = WhiteNoise.ar(amp);
	env = EnvGen.kr(Env.perc(0, 0.01), doneAction: 2);
	// OffsetOut.ar(out, Pan2.ar(osc1, pan, env));
	OffsetOut.ar(out, DirtPan.ar(osc1, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\hatenSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, mixNoise = 0.5, sinFreq = 200, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4]), doneAction: 2);
	sig = (WhiteNoise.ar(amp) * mixNoise) + (FSinOsc.ar(sinFreq) * (1 - mixNoise));
	sig = (LFSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\haten1Sd, { arg out = 0, amp = 0.06, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, curve = (-4), mixNoise = 0.5, sinFreq = 142, sinAmp = 0.2, fsinFreq = 200, fsinAmp = 0, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4], curve), doneAction: 2);
	sig = (WhiteNoise.ar(1) * mixNoise) + ((SinOsc.ar(sinFreq, 0, sinAmp) + FSinOsc.ar(fsinFreq, 0, fsinAmp)) * (1 - mixNoise));
	sig = (VarSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env * amp;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\IkedaHiNoiseSd, { arg out = 0, level = 10, pan = 0, atk = 0.02, dcy = 0.1, rq = 0.9, amp = 0.05, gate = 0, doneAction = 2;
	var noise, sig;
	noise = WhiteNoise.ar(Decay2.kr(gate, atk, dcy, amp));
	sig = BPF.ar(noise, TRand.kr(12000, 15000, gate), rq.max(0.001));
	DetectSilence.ar(sig, 0.0001, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\IkedaClickSd, { arg out = 0, level = 1, pan = 0, gate = 0, centerFreq = 15000, rq = 0.9, modamp = 25, doneAction = 2;
	var noise, sig;
 	noise = PinkNoise.ar(Decay.kr(gate, 0.001 * LFNoise1.kr(4).abs));
	sig = BPF.ar(noise, centerFreq.max(1), rq.max(0.01), modamp * LFNoise1.kr(8).range(0, 1)).fold(-1, 1);
 	DetectSilence.ar(sig, 0.0001, doneAction: doneAction);
 	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\hatYSd,{arg gate = 1, pan = 0, amp = 1, out = 0, rls = 0.1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(0,rls), gate, doneAction: doneAction);
	var freq = EnvGen.ar(Env([12000,80,20000],[0.1,0.1]));
	var sig = PinkNoise.ar(env);
	sig = HPF.ar(sig,freq);
	// sig = Pan2.ar(sig.tanh, pan, amp);
	// OffsetOut.ar(out,sig*12);
	OffsetOut.ar(out, DirtPan.ar(sig.tanh*12, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hatnewSd, {|out=0, amp=1, pan=0, freq=230, hpf=8500, rls=0.15, fxb=0, fxv=0, bbcb=0, bbcv=0, doneAction = 2|
	var pulse, sig, env, freqs;
	freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
	pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
	sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
	env = EnvGen.kr(Env.perc(0,rls), doneAction: doneAction);
	// sig =  Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out,sig);
	OffsetOut.ar(out, DirtPan.ar(sig*env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hat909Sd, {|out=0, amp=1, pan=0, envL1 = 0, envL2 = 0.98, envL3 = 0.12, envL4 = 0.9, envT1 = 0.2, envT2 = 0.01, envT3 = 0.32, envCurve = (-4), freq=230, hpf=6500, doneAction = 2|
	var pulse, sig, env, freqs;
	freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
	pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6));
	sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
	// env = EnvGen.kr(Env.perc(0,rls),doneAction:2);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve).kr(doneAction: doneAction);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hat808Sd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, gate = 1, atk = 0.01, rls = 0.1;
	var sig;
	var env = EnvGen.ar(Env.perc(atk, rls),doneAction:2);
	sig = Saw.ar((1..9)*1000.23*env*tu);
	sig = RHPF.ar(sig, \hpf.kr(5700), \rq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1),\rel.kr(0.1),-4),gate))*tu;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \lpf.kr(2000)*env*tu, \rq.kr(0.5));
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hihatAwSd, {arg out = 0, amp = 0.5, pan = 0, atk = 0.01, rls = 0.2, ffreq = 6000, doneAction = 2;
	var snd = WhiteNoise.ar(amp);
	var env = Env.perc(atk, rls).kr(doneAction: doneAction);
	snd = HPF.ar(snd * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\hihatElectroSd, { arg out = 0, pan = 0, amp = 0.3, atk = 0.001, rls = 0.3, curve = -8, filterFreq = 4010, rq = 0.56, doneAction = 2;
	var env, snd;

	// noise -> resonance -> exponential dcy envelope
	env = Env.perc(attackTime: atk, releaseTime: rls, curve: curve).kr(doneAction: doneAction);

	snd = ClipNoise.ar(amp);
	snd = BPF.ar(
		in: snd,
		freq: [1, 1.035] * filterFreq,
		rq: [0.27, 1] * rq,
		mul: [1.0, 0.6]
	);
	snd = Mix(snd) * env;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\ikedhatSd,{arg out = 0, amp = 1, pan = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, atk= 0.0, rls = 0.01, timeScale = 1, hpf = 6000, gate = 1, doneAction = 2;
	var sig = HPF.ar(WhiteNoise.ar(1), hpf);
	var env = EnvGen.ar(Env([envLevel1, envLevel2, envLevel3], [atk, rls]), gate, levelScale, levelBias, timeScale, doneAction);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, env*amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
}).add;

SynthDef(\fabHiSd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatk = 0.001, envNrls = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatk = 0.001, envSrls = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin;
	envNoise = EnvGen.kr(Env.perc(envNatk, envNrls), gate);
	envSin = EnvGen.kr(Env.perc(envSatk, envSrls), gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	env = Env.step([envL1, envL2, envL3], [envT1, envT2, envT3]).kr(doneAction: doneAction);
	sig = HPF.ar(sig * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\fabHi1Sd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatk = 0.001, envNrls = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatk = 0.001, envSrls = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envL4 = 0, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin, delay;
	envNoise = EnvGen.kr(Env.perc(envNatk, envNrls), gate);
	envSin = EnvGen.kr(Env.perc(envSatk, envSrls), gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]).kr(doneAction: doneAction);
	sig = HPF.ar(sig * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\metroSd, {arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, impFreq=1, theta = 0.5, rho = 0.8, filterfreq=1000, rq=1.0, doneAction = 2;
	var env, signal, b1, b2;
	env = EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	signal = SOS.ar(Impulse.ar(impFreq, 0, env), 1.0, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal, filterfreq, rq);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hatySd,{ arg out = 0, pan = 0, atk = 0.001, rls = 0.1, curve = (-4), amp = 0.75, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
	sig = HPF.ar((WhiteNoise.ar(0.5, 0.5) * env * amp), 4000);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\haty48Sd,{ arg out = 0, amp = 0.75, pan = 0, atk = 0, rls = 0.12, curve = (-4), envaL1 = 1.81, envaL2 = 0, envaL3 = 2.52, envaL4 = 0.85, envaL5 = 0, envaT1 = 0.01, envaT2 = 0.02, envaT3 = 0, envaT4 = 0, envaCrv = 3.54, envpL1 = 0, envpL2 = 16936, envpL3 = 1279, envpL4 = 0, envpT1 = 0, envpT2 = 0.33, envpT3 = 0, envpT4 = 0.53, envpCrv = (-0.64), modFreq = 1, modAmt = 1.4, sinfAdd = 1.7, sinPhase = 0.28, sinpAdd = 1.7, rf1Freq = 16938.8, rf1Rq = 0.26, rf2Freq = 765, rf2Rq = 0.62, hpfFreq = 3699, doneAction = 2;
	var mod, env, enva, envp, sig;
	env = EnvGen.kr(Env.linen(atk, rls, rls/2, 1, curve), 1, doneAction: doneAction);
	enva = EnvGen.kr(Env([envaL1, envaL2, envaL3, envaL4, envaL5], [envaT1, envaT2, envaT3, envaT4], [envaCrv, envaCrv / 2, envaCrv.neg]));
	envp = EnvGen.kr(Env.circle([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3, envpT4], [envpCrv, envpCrv * 2 , envpCrv.neg, envpCrv / 2]));
	mod = LFNoise0.ar(modFreq * envp.range(0.1, 4), modAmt * enva).range(1, modAmt);
	sig = SinOsc.ar([envp, envp + sinfAdd], [sinPhase, (sinPhase + sinpAdd)]);
	sig = Resonz.ar(sig, [rf1Freq, rf2Freq] * mod, [rf1Rq, rf2Rq], enva);
	sig = HPF.ar(sig, hpfFreq);
	sig = (sig[0] + sig[1]) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sosHatsSd, { arg out = 0, amp = 0.8, pan = 0, freq = 6000, curve = -4, rootIndex = 238.5, rq = 1,
	// Initial envelopes
	initAtt = 0.005, initRel = 0.1, initAmp = 1, initStart = 15000, initEnd = 9000,
	// Body envelopes
	bodyAtt = 0.005, bodyRel = 0.1, bodyAmp = 1, bodyStart = 9000, bodyEnd = 12000,
	// General envelope
	envAtt = 0.01, envRel = 1, envCurve = (-4),
	doneAction = 2;

	var root, initialEnv, initialSweep, initial, bodyEnv, bodySweep, body, snd;

	root = Pulse.ar(freq: freq, width: 0.5, mul: 1);

	root = PMOsc.ar(
		carfreq: root,
		modfreq: freq * [1.34, 2.405, 3.09, 1.309],
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

	snd = snd * EnvGen.kr(Env.perc(envAtt, envRel, curve: envCurve), doneAction: doneAction);
    // DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\tick2Sd, {
    var sig, env, rq = \rq.kr(0.1);
    env = Env.perc(\atk.kr(0), \rel.kr(0.05)).ar(2);
    sig = Impulse.ar(0);
    sig = sig * 0.5;
    sig = RHPF.ar(sig, \freq.kr(1000), rq) * env;
    // sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(1.0);
    // OffsetOut.ar(\out.kr(0), sig);
	OffsetOut.ar(\out.kr(0), DirtPan.ar(sig, ~dirt.numChannels, \pan.kr(0), \amp.kr(1.0)));
}).add;

///////////////////////////////////////  Cymbal

SynthDef(\cymSd, { arg out=0, amp=0.5, pan=0, atk=0, rls=1, curve=(-8), tu=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.perc(atk,rls,1,curve),doneAction: doneAction);
	var freqs = geom(100, 50, 1.3434)*10.234567*Lag3.kr(tu);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cym1Sd, { arg out=0, amp=0.2, pan=0, envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, levScale = 1, envT1 = 0.1, envT2 = 0.02, envT3= 0.01, envC1 = (-8), envC2 = 4, envC3 = (-4), tu=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], [envC1, envC2, envC3]), levelScale: levScale, doneAction: doneAction);
	var freqs = geom(100, 50, 1.3434)*10.234567*Lag3.kr(tu, 10);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs).mean;
	// sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymnewSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0, rls = 4, curve = (-8), tu = 6, gate = 1, doneAction = 2;
    var sig;
    var env = EnvGen.ar(Env.perc(atk,rls,1,curve), gate, doneAction: doneAction);
	var freqs = geom(99,40,pi/3)*10.234567*tu;
	sig = WhiteNoise.ar(0.2);
    sig = Ringz.ar(sig,freqs,1).mean;

    // sig = Pan2.ar(sig*env, pan);
    // OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymnew1Sd, { arg out = 0, amp = 0.2, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envT1 = 0.12, envT2 = 0.02, envT3 = 0.23, curve = (-8), tu = 6, gate = 1, doneAction = 2;
    var sig;
	var env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], curve), gate, doneAction: doneAction);
	var freqs = geom(99,40,pi/3)*10.234567*tu;
	sig = WhiteNoise.ar(0.2);
    sig = Ringz.ar(sig,freqs,1).mean;

    // sig = Pan2.ar(sig*env, pan);
    // OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymbalicMcldSd, { |out=0, amp=0.5, pan=0, attLowf = 0.5, rlsLowf = 5, lowNoiseLev = 0.1, attHif = 1, rlsHif = 3, hiNoiseLev = 0.1, attHi = 1, rlsHi = 2, hiLev = 0.25, attTh = 0.001, rlsTh = 0.001, freq1 = 627, freq2 = 2961, freq3 = 7824, freq4 = 476, gate = 1, doneAction = 2|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

	locutoffenv = EnvGen.kr(Env.perc(attLowf, rlsLowf), gate, doneAction: doneAction) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, rlsHif), gate, doneAction: doneAction) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
	hidriver = hidriver * EnvGen.kr(Env.perc(attHi, rlsHi, hiLev));

	thwack = EnvGen.kr(Env.perc(attTh,rlsTh), gate, doneAction: doneAction);

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	//freqs  = {exprand(300, 20000)}.dup(100);

	freqs = [freq1, freq2, freq3, freq4] /** LFNoise2.kr(0.002, 0.5, 0.5)*/;

	res = Ringz.ar(
		lodriver + hidriver + thwack,
		freqs
	).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymbal808ryanSd, { arg out = 0, amp = 0.1, pan = 0, baseFreq = 300, penvL1 = 1.0, penvL2 = 0.6, ptime = 250, pcurve = (-0.5), pulsew = 0.55, rlpfFrq = 7000, rlpfRq = 0.6, rhpfFrq = 6800, rhpfRq = 1.5, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envL5 = 0, envT1 = 2, envT2 = 250, envT3 = 50, envT4 = 500, envC1 = 0, envC2 = (-0.5), envC3 = 0, envC4 = (-50), doneAction = 2;
	var freqs = [baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523];
	//var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
	//var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
	//var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];
	var signal, pulseEnv;

	pulseEnv = EnvGen.kr(Env.new([penvL1, penvL2], [ptime], [pcurve]), timeScale:(1/1000));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
	signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width: pulsew)) * 0.9);
	signal = RLPF.ar(signal, rlpfFrq, rlpfRq);
 	signal = RHPF.ar(signal, rhpfFrq, rhpfRq);
	signal = signal * EnvGen.kr(Env.new([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [envC1, envC2, envC3, envC4]), timeScale:(1/1000), doneAction: doneAction);
	signal = [signal, DelayN.ar(signal, 0.005, 0.005)];
	// OffsetOut.ar(out, signal*4*amp);
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp*4));
}).add;

SynthDef(\cymbal808Sd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.002, dcy = 0.25, rls = 0.05, freqMultiplier = 4.09, decLevel = 0.4, reverb = 0.33, size = 0.5, damp = 0.5, doneAction = 2;
	var snda, sndb, snd, env, pulseEnv, freqs;

	freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

	env = Env.new(
		levels: [0, 1, decLevel, 0],
		times: [atk, dcy, rls],
		curve: [0, -0.5, 0]
	).kr;

	pulseEnv = Env.new(
		levels: [1.0, 0.6],
		times: dcy,
		curve: -0.5
	).kr;

	snd = Mix.ar(LFPulse.ar(freq: freqs * freqMultiplier));

	snd = (BinaryOpUGen('==', snd, 6.0) * 0.6) + (BinaryOpUGen('==', snd, 2.0) * 0.2) + (BinaryOpUGen('==', snd, 1.0) * 0.9);

	snd = (snd * pulseEnv) + Mix.ar(LFPulse.ar(freq: freqs, width: 0.55, mul: 0.9));

	snd = RLPF.ar(in: snd, freq: 7000, rq: 0.6);
 	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 1200, rq: 1.5);

	snd = snd + FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp);
	snd = Mix.ar(snd);
	snd = snd * env * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Clap

SynthDef(\clapSd, {| out=0, amp = 1, pan=0, q=0.1, fq=1, rnd1=0, rnd2=0, rnd3=0, gate=1, doneAction=2 |
	var env1, env2, noise1, noise2, sig;
	env1 = EnvGen.ar(\env1.kr(Env([0, 1, 0.5, 0.5, 0, 1, 0, 0.3, 0],	[0.001, 0.0013, 0, 0.01, 0, 0.001, 0, 0.03],[0, -3, 0, -3, 0, -3, 0, -4])),doneAction:2);
	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 400);
	noise1 = BPF.ar(noise1, 1000*fq, 20*q);
	env2 = EnvGen.ar(\env2.kr(Env([0, 1, 0], [0.002, 0.1], [0, -4])), gate, doneAction: doneAction);
	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 2300);
	noise2 = BPF.ar(noise2, 2000*fq, 7*q, 0.7);
	sig = noise1 + noise2;
	sig = sig * 2;
	// sig = Pan2.ar(sig.softclip, pan, amp);
	// OffsetOut.ar(out,sig);
	OffsetOut.ar(out, DirtPan.ar(sig.softclip, ~dirt.numChannels, pan, amp));
}).add;

// SynthDef(\clappingSd, {arg out = 0, amp=0.5, pan = 0, atk = 0.01, rls = 1, atk = 0.003, rls = 0.035, noiseAmp = 1, filterfreq=120, rq=0.1, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, gate=1, doneAction=2;
// 	var env, signal, noise, hpf1, hpf2, fx;
// 	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([filterfreq/2,filterfreq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
// 	hpf1 = RLPF.ar(noise, lpfFreq, rq);
// 	hpf2 = RHPF.ar(noise,  hpfFreq, rq/4);
// 	env = EnvGen.kr(Env.perc(atk, rls));
// 	signal = (hpf1+hpf2) * env;
// 	fx = CombC.ar(signal, 0.5, delTimeL, delDecL)+CombC.ar(signal, 0.5, delTimeR, delDecR);
// 	// signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
// 	// signal = Limiter.ar(signal, 0.7, 0.01) * amp;
// 	signal = (signal * (1 - delMix)) + (fx * delMix) ;
// 	signal = signal * EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
// 	// DetectSilence.ar(signal, doneAction: doneAction);
// 	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
// 	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
// }).add;

SynthDef(\clappingSd, {arg out = 0, amp=0.5, pan = 0, atkSig = 0.01, rlsSig = 1, atkEnv = 0.003, rlsEnv = 0.035, noiseAmp = 1, filterfreq=120, rq=0.1, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, gate=1, doneAction=2;
	var env, signal, noise, hpf1, hpf2, fx;
	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([filterfreq/2,filterfreq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
	hpf1 = RLPF.ar(noise, lpfFreq, rq);
	hpf2 = RHPF.ar(noise,  hpfFreq, rq/4);
	env = EnvGen.kr(Env.perc(atkEnv, rlsEnv));
	signal = (hpf1+hpf2) * env;
	fx = CombC.ar(signal, 0.5, delTimeL, delDecL)+CombC.ar(signal, 0.5, delTimeR, delDecR);
	// signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
	// signal = Limiter.ar(signal, 0.7, 0.01) * amp;
	signal = (signal * (1 - delMix)) + (fx * delMix) ;
	signal = signal * EnvGen.kr(Env.linen(atkSig, 1, rlsSig), doneAction: doneAction);
	// DetectSilence.ar(signal, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\clap_oto309Sd, {
	arg out=0, amp = 0.1, pan=0;
	var env1, env2, son, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	son = noise1 + noise2;
	son = son * 2;
	son = son.softclip * amp;

	// OffsetOut.ar(out, Pan2.ar(son, pan));
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan));
}).add;

SynthDef(\oneclap_thorSd, {arg out=0, amp=0.1,  pan=0, filterfreq=1000, rq=0.1, attackTime = 0.003, releaseTime = 0.035, doneAction = 2;
var env, signal, atk, noise, hpf1, hpf2;
	noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
	noise = PinkNoise.ar(1)+SinOsc.ar([(filterfreq)*XLine.kr(1,0.01,3), (filterfreq+4)*XLine.kr(1,0.01,3) ], pi*0.5, XLine.kr(1,0.01,4));
	hpf1 = RLPF.ar(noise, filterfreq, rq);
	hpf2 = RHPF.ar(noise, filterfreq/2, rq/4);
	env = EnvGen.kr(Env.perc(attackTime, releaseTime), doneAction: doneAction);
	signal = (hpf1+hpf2) * env;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
	// signal = Decay2.ar(signal, 0.5);
	signal = FreeVerb.ar(signal, 0.23, 0.15, 0.2);
	// DetectSilence.ar(signal, doneAction:2);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\oneclapThorBrSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, rls = 1, atkT = 0.003, rlsT = 0.00035, tone = 0.4, noiseAmp = 1, freq = 100, rq = 0.1,
	//Other Controls
	echohz1 = 33.333, echohz2 = 33.156, curve = -4, dcy = 0.06, shelfFreq = 7000, rs = 0.5, db = -3,
	// Controls Ranging from 0 to 1
	size = 0.15, mix = 0.23, damp = 0.5,
	doneAction = 2;

	var env, snd, noise1, noise2, hpf1, hpf2, delay1, delay2;

	noise1 = (GrayNoise.ar(1 - tone) + WhiteNoise.ar(tone)) * noiseAmp;

	noise1 = noise1 + SinOsc.ar(freq: [freq / 2, freq / 2 + 4 ]);

	noise2 = PinkNoise.ar(noiseAmp);

	noise2 = noise2 + SinOsc.ar(freq: [freq, (freq * 1.04)] * XLine.kr(start: 1, end: 0.01, dur: 3));

	hpf1 = RLPF.ar(in: noise1, freq: freq, rq: rq);

	hpf2 = RHPF.ar(in: noise1, freq: freq/2, rq: rq/4);

	env = Env.perc(attackTime: atkT, releaseTime: rlsT, curve: curve).kr;

	snd = Mix.ar(hpf1 + hpf2) * env;

	delay1 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz1, delaytime: 1/echohz1, decaytime: dcy / 2);

	delay2 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz2, delaytime: 1/echohz2, decaytime: dcy);

	snd = FreeVerb.ar(in: Mix.ar(delay1 + delay2), mix: mix, room: size, damp: damp, mul: amp);

	snd = BHiShelf.ar(in: snd, freq: shelfFreq, rs: rs, db: db);

	snd = snd * EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
	// DetectSilence.ar(snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapySd, { arg out = 0, amp = 0.5, pan = 0, atk = 0.02, rls = 0.3, curve1 = 0, curve2 = (-4), hpf1 = 600, hpf2 = 1000, bpf1 = 2000, bpf2 = 1200, gain = 1.5, doneAction = 2;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [atk, rls], [curve1, curve2]), doneAction: doneAction);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), hpf1), bpf1, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), hpf2), bpf2, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = 0.4 * sig.softclip * amp;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapGraySd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.25, curve = -4, spreadRate = 75, minDelay = 0.025, maxDelay = 0.05, dcy = 0.15, rq = 0.4, blend = 0.7, reverb = 0.1, size = 0.25, damp = 1, doneAction = 2;
	var env1, env2, snd, noise1, noise2, spread;

	//Multiple Shorter Claps
	spread = LFNoise1.kr(spreadRate).range(minDelay, maxDelay);

	env1 = Env.perc(attackTime: atk / 10, releaseTime: rls / 8, curve: [0, curve]).kr;
	env1 = CombC.ar(in: env1, maxdelaytime: maxDelay, delaytime: spread, decaytime: dcy);

	noise1 = GrayNoise.ar(env1); //Play with frequencies here:
	noise1 = RHPF.ar(in: noise1, freq: 1000, rq: rq);
	noise1 = BPF.ar(in: noise1, freq: 2000, rq: 3);

	//One Longer Clap
	env2 = Env.perc(attackTime: atk, releaseTime: rls, curve: [0, curve]).kr;

	noise2 = GrayNoise.ar(env2); //Play with frequencies here:
	noise2 = RHPF.ar(in: noise2, freq: 1200, rq: rq);
	noise2 = BPF.ar(in: noise2, freq: 1400, rq: 0.7);

	//Mixing and light Reverb
	snd = Mix.ar((blend * noise1) + ((1 - blend) * noise2));
	snd = (snd * 2).softclip;
	snd = FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp, mul: amp);

	DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Noise

SynthDef(\IkedaBreathSd, { arg out = 0, level = 1, pan = 0, atk = 0.0001, dcy = 0.4, rls = 0.01, note1 = 44, note2 = 90, amp1 = 0.5, amp2 = 0.6, lpfFreq = 103.82, hpfFreq = 2400, gate = 0, doneAction = 2;
	var sin, lpf, hpf, sig;
	sin = SinOsc.ar(note1.midicps, 0, amp1) + SinOsc.ar(note2.midicps, 0, amp2);
	lpf = LPF.ar(sin, lpfFreq.max(1));
	hpf = HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), hpfFreq.max(1));
	sig = (lpf + hpf) * EnvGen.kr(Env(#[0, 1, 0.6, 0], [atk, dcy, rls]), gate, doneAction: doneAction); // # makes a totally fixed (non-dynamic) Array and is slightly cheaper, especially where you're not going to change the Array once you make it
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\noise2Sd,{arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 0.01, a = 4;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [atk, rls], [-4, -2, -4]), doneAction:2);
var sig = CuspN.ar(
		SampleRate.ir/a,
		LFNoise2.kr([4,4],1.5,1.5),
		LFNoise2.kr([2,2],1.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5);
	);
	sig = HPF.ar(sig,1000);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig ,DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*a);
	sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	// sig =  Pan2.ar(sig.tanh, pan, amp);
	// OffsetOut.ar(out,sig*env0);
	OffsetOut.ar(out, DirtPan.ar(sig.tanh, ~dirt.numChannels, pan, amp * env0));
}).add;

SynthDef(\noise2newSd,{arg out = 0, amp = 1, pan = 0, levelScale = 1, atk = 0.01, rls = 1, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 0.2, avar = 1, bvar = 1, xi = 0.5, hpf = 1000, del1 = 10, del2 = 20, doneAction = 2;
	var env, sig;
	env =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [atk, rls], [curve1, curve2, curve3]), levelScale: levelScale, doneAction: doneAction);
	sig = CuspN.ar(
        SampleRate.ir/coeff,
        LFNoise2.kr([4,4],1.5,1.5) * avar,
        LFNoise2.kr([0.2,0.2],1.5,1.5) * bvar,
        LFNoise2.kr([2,2],0.5,1.5) * xi,
        LFNoise2.kr([2,2],0.5,1.5);
    );
    sig = HPF.ar(sig,hpf);
    sig = Limiter.ar(sig,0.4);
    sig = [DelayL.ar(sig,0.1,del1/44100) ,DelayL.ar(sig,0.1,del2/44100)];
    //sig = PitchShift.ar(sig,0.2,1*coeff);
    sig = Compander.ar(sig,In.ar(out,1),0.01,1,0.01,0.01,0.1);
    sig = sig.tanh;
	// sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig * env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\noiseSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls  = 0.25, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, doneAction = 2;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [atk, rls], [curve1, curve2, curve3]), doneAction: doneAction);
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

SynthDef(\newNoise48Sd,{arg out = 0, amp = 1, pan = 0, env0L1 = 0.1, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.2, env0T3 = 0.25, env0T4 = 0.25, offset = 0, timeScale = 1, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, gate = 1, doneAction = 2;
var env0 =  EnvGen.ar(Env.step([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3, env0T4], offset), gate, timeScale: timeScale, doneAction: doneAction);
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

/*SynthDef(\cosc, { arg out = 0, gate = 1, amp = 1, pan = 0, freq = 512, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(0.5,1,1,0), gate, doneAction: doneAction);
    var sig = COsc.ar(80,[freq,freq+0.5], 1, 0.1);
    sig  = sig + COsc.ar(80,[freq,freq+0.5]*2, 1, 0.1);
    sig = FreeVerb.ar(sig*env,1);
    sig = LeakDC.ar(sig);
    OffsetOut.ar(0,sig*amp);
}).add;*/

SynthDef(\jiletSd, { arg out=0, amp=0.20, pan = 0, atk = 0.005, dcy = 0.01, sst = 1.1, rls = 0.01, envOffset=0.5, freq=4, endReflection=1.5, jetReflection=0.5, jetRatio=10.72, noiseGain=0.35, vibFreq=5.925, vibGain=0.02, gate=1, doneAction = 2;

	var adsr = (envOffset*0.2) + EnvGen.ar(Env.adsr(atk, dcy, sst, rls), gate, doneAction: doneAction);
	var noise = WhiteNoise.ar(noiseGain.max(0.1));
	var vibrato = SinOsc.ar(vibFreq, 0, vibGain);

	var delay = (freq.min(340)*0.66666).reciprocal;
	var lastOut = LocalIn.ar(1);
	var breathPressure = adsr*Mix([1.0, noise, vibrato]);
	var filter = LeakDC.ar(OnePole.ar(lastOut.neg, 0.7));
	var pressureDiff = breathPressure - (jetReflection*filter);
	var jetDelay = DelayL.ar(pressureDiff, 0.025, delay*jetRatio);
	var jet = (jetDelay * (jetDelay.squared - 1.0)).clip2(1.0);
	var boreDelay = DelayL.ar(jet + (endReflection*filter), 0.05, delay);
	LocalOut.ar(boreDelay);
	// boreDelay = Pan2.ar(boreDelay, pan, amp);
	// OffsetOut.ar(out, 0.3*boreDelay);
	OffsetOut.ar(out, DirtPan.ar(boreDelay, ~dirt.numChannels, pan, amp * 0.3));
}).add;

SynthDef(\pitchednoiseSd, { arg out = 0, amp=0.1, pan=0.0, atk=0.01, rls=10, freq=440, bandwidth=100, doneAction=2;
	var source, filter, env;
	// env = EnvGen.ar(Env([0,1,1,0],[atk, sustain, decay]), doneAction: doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	source = WhiteNoise.ar;
	filter = BPF.ar(source*env*2*amp,freq,bandwidth/freq);
	// OffsetOut.ar(out, Pan2.ar(filter,pan));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan));
}).add;

SynthDef(\plastickystringsSd, { | out= 0 freq = 440 amp = 0.1 gate=1 lforate = 5900 lfowidth= 0.01 cutoff= 12000 rq=0.5 pan=0.0, doneAction=2 |
	var lfo, saw, filter, env;
	lfo = LFTri.ar(lforate,Rand(0,2.0));
	saw = Saw.ar(freq*(1.0+(lfowidth*lfo)),0.5);
	//filter = BBandPass.ar(saw,freq,4);
	filter = BHiPass.ar(saw,freq,rq); 	//or using cutoff
	env = EnvGen.ar(Env.adsr(0.4,0.0,1.0,1.0),gate,doneAction: doneAction);
	// OffsetOut.ar(out,Pan2.ar(filter*env, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\resSd, { | out = 0, amp = 1, pan = 0, atk = 0, rls = 0.7, freqSin = 52, ampSin = 1, freqSaw = 22, ampSaw = 1, oscMix = 0.5, freqClc = 7302, harmClc = 200, ampClc = 0.5, maxL = 1, t1Clc = 0.001, t2Clc = 0.03, t3Clc = 0.01, gFreq = 12, damp = 0, fric = 0.001, doneAction = 2|
	var aEnv, osc, sig, flt, clic;
	aEnv = EnvGen.kr(Env.perc(atk, rls), doneAction: doneAction);
	osc = Mix([SinOsc.ar(freqSin, 0, ampSin), Saw.ar(freqSaw, ampSaw)]) * aEnv;
	clic = Blip.ar(freqClc, harmClc, ampClc) * EnvGen.kr(Env.step([0, maxL, 0], [t1Clc, t2Clc, t3Clc]));
	sig = (osc * oscMix) + (clic * (1 - oscMix));
	sig = sig + Ball.ar(sig, LFNoise1.kr(gFreq, 0.5, 0.5), damp, fric) * aEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*~resSynthDef = SynthDef(\res, { | out = 0, amp = 1, pan = 0, atk = 0, rls = 0.7, freqSaw = 40, freqPls = 62, wPls = 0.5, rlpfRq = 0.1, lfnFreq = 0.3, lfnMul = 1000, lfnAdd = 1500, gate = 1, doneAction = 2|
	var aEnv, osc, flt, fltBus;
	aEnv = EnvGen.kr(Env.perc(atk, rls), gate, doneAction: doneAction);
	fltBus = Bus.control(s, 1);
	osc = Mix([Saw.ar(freqSaw), Pulse.ar(freqPls, wPls)]);
	flt = RLPF.ar(osc, In.kr(fltBus, 1), rlpfRq, aEnv);
	ReplaceOut.kr(fltBus, LFNoise1.kr(lfnFreq, lfnMul, lfnAdd));

	OffsetOut.ar(out, Pan2.ar(flt, pan, amp));
}).add;*/

SynthDef(\mutantFricSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, sigFreq = 50, spring = 0.414, damp = 0.313, beltmass = 1, source = 0, hpfFreq = 50, gate = 1, doneAction = 2;
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
	sig = sig * EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

	// OffsetOut.ar(out, Splay.ar(sig * amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetSynthSd, { arg out = 0, amp = 1, pan = 0, freq = 25, rate = 8, atk = 0.01, rls = 10, sigatk = 0.01, sigdcy = 3.16, thresh = 0.5, ratio = 1, revMix = 0, revRoom = 0.5, revDamp = 0.5, gate = 1, doneAction = 2;
	var sig, demand, env, sigenv;
	demand = Demand.kr(
		gate,
		0,
		Drand(freq, inf)
	);
	sig = (
		BHiPass.ar(
			LFNoise1.ar(rate) ** 3,
			[demand, demand + 0.2].midicps,
			demand / 2e3,
			67 - demand
		)
	).tanh;
	sigenv = EnvGen.kr(Env.asr(sigatk, 1, sigdcy), gate);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = sig * sigenv * env;
	sig = Compander.ar(sig, sig, thresh.max(0.01), 1, ratio);
	sig = FreeVerb2.ar(sig[0], sig[1], Lag2.kr(revMix), revRoom, revDamp);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetFogAttackSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, sigatk = 0.01, sigdcy = 3.16, feedBack = 0.2, freq = 0.8, gate = 1, doneAction = 2;
	var sig, env, coef, sigenv;
	sig = Pulse.ar(freq*(pi/[1,2.57]),[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig * feedBack);
	sigenv = EnvGen.kr(Env.asr(sigatk, 1, sigdcy), gate);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = (sig.mean!2) * sigenv * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetErosionSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.01, rls = 10, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, div, envIndex, xyc;
	input = LocalIn.ar(2).range(0,0.9)+0.1;
	div = LagUD.ar(input, 0, 0.2);
	sig = PinkNoise.ar(1!2);
	sig = tanh(500 * (sig**(8/div)));
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	LocalOut.ar(sig * feedBack);
	sig = Splay.ar(sig,1-input);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\harshTextureSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 2, delTimeMod = 0.5, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = Impulse.ar(impFreq).lag(0.3)!2;
	5.do {
		sig = LeakDC.ar(
			AllpassC.ar(
				sig,
				1,
				LFNoise0.ar(delTimeMod).range(1e-5,0.2),
				-0.15,
				LFNoise0.ar(delTimeMod).range(1,3)
			)
		).tanh;
	};
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ultraHiSummerSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, curve = (-4), blpFreq1 = 16e3, blpFreq2 = 16150, seqRate = 0.2, seqVal1 = 70, seqVal2 = 30, seqVal3 = 0, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls, curve: curve), gate, doneAction: doneAction);
	sig = Blip.ar(
		[blpFreq1, blpFreq2],
		2,
		LFSaw.ar(
			Duty.ar(
				LFNoise0.ar(seqRate,4,6),
				0,
				Dseq([seqVal1, seqVal2, seqVal3], inf)
			)
		).clip(0, 1)
	);
	sig = (sig[0] + sig[1]) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ambiantPicSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.01, rls = 10, lfnFreq = 22, lfnAmp = 5, lfnOffset = 9, ampDst1 = 4, ampDst2 = 2, durDst1 = 0.5, durDst2 = 1, adPar1 = 1/9, adPar2 = 1/4, ddPar1 = 1/2, ddPar2 = 1/8, delTime1 = 0.13, delTime2 = 0.1, decTime = 0.2, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = LFNoise2.kr(lfnFreq, lfnAmp, lfnOffset);
	sig = CombC.ar(
		Splay.ar(
			Gendy3.ar(
				[ampDst1, ampDst2],
				[durDst1, durDst2] * decTime,
				[adPar1, adPar2]*sig,
				[ddPar1, ddPar2]*sig,
				(9,49..199)
			)
		),
		5,
		[delTime1, delTime2],
		[sig/2,sig/2.1] * decTime
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\attBreathSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, seqv1 = 1, seqv2 = 1, seqv3 = 4, seqv4 = 2, seqv5 = 2, seqFreq = 0.2, freqMin = 250, freqMax = 800, bwrMod = 0.5, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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

SynthDef(\attWindSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, seq1 = 1, seq2 = 1, seq3 = 4, seq4 = 2, seq5 = 2, seqDiv = 8, freq1 = 250, freq2 = 8000, bwrLo = 0.01, bwrHi = 0.5, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = TDuty.kr(Dseq([seq1, seq2, seq3, seq4, seq5] / seqDiv, inf));
	sig = Resonz.ar(
		WhiteNoise.ar!2,
		Demand.kr(sig, 0, Dseq([freq1, freq2], inf)),
		Demand.kr(sig, 0, Dwhite(bwrLo, bwrHi, inf))
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\dStowellSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, freq = 6/3, width = 1/5, lpf = 20000, gate = 1, doneAction = 2;
	var sig, env, spec, input;
	spec = `[{exprand(100,1000)}.dup(50)];
	input = Saw.ar(
		LFPulse.kr(freq,0,width).range(3,3000),
		0.0005
	);
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = Klank.ar(spec, input);
	sig = LPF.ar(sig, lpf);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\henonSd, { arg out = 0, amp = 0.1, pan = 0, freq = 440, a = 1.3, b = 0.3, x0 = 0.30501993062401, x1 = 0.20938865431933, atk = 0.01, sst = 1, rls = 1, ts = 1, gate = 1, doneAction = 2;
	var sig,env;
	sig = HenonN.ar(freq,a,b,x0,x1,amp);
	env = EnvGen.ar(Env.linen(atk,sst,rls),gate,1,0,ts,doneAction);
	sig = LeakDC.ar(sig);
	sig = sig*env;
	// OffsetOut.ar(out,Pan2.ar(sig,pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\harrishSd, {| out = 0, amp = 0.2, pan = 0, atk = 0, sustain = 0.2, rls = 0.1, curve = 0, clipLevel = 0.006, impFreq = 0, impPhase = 0, impLevel = 1, noiseLevel = 0.3, lpf = 20000, eqfreq = 4000, eqrq = 1, eqdb = 0, hpf = 20,  doneAction = 2|
	var env = EnvGen.ar(Env.linen(atk, sustain, rls, curve: curve), doneAction: doneAction);
	var snd = (ClipNoise.ar(clipLevel) + Impulse.ar(impFreq, impPhase, impLevel) + BrownNoise.ar(noiseLevel)) * env;
	snd = LPF.ar(snd, lpf);
	snd = BPeakEQ.ar(snd, Lag2.kr(eqfreq.max(20).min(20000), 0.5), eqrq, eqdb);
	snd = HPF.ar(snd, hpf);
	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kSpluck3Sd, { arg out = 0, amp = 0.2, pan = 0, atk = 0, rls = 0.01, midiPitch = 24, art = -3, noiseFreq = 1, noiseLev = 13000, noiseOffset = 14010, mix = 0.5, doneAction = 2;
	var burstEnv;
	var sig, delayTime;
	delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
	burstEnv = EnvGen.kr(Env.perc(atk, rls));
	sig = PinkNoise.ar([burstEnv, burstEnv]); //Noise burst
	sig = CombL.ar(sig, delayTime, delayTime, art, add: sig); //Echo chamber
	sig = XFade2.ar(sig, RLPF.ar(sig, LFNoise1.kr(noiseFreq, noiseLev, noiseOffset), 0.1), mix, amp); //Filter ADSR GELSIN BURAYA
	DetectSilence.ar(sig, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\lumbricostSd, {arg out = 0, amp = 0.2, pan = 0, attTim= 1, rlsTim=2.5, scale= 6, offset = 40, freq = 10, timescale = 10, widthmod = 0.4, width = 0.2, abc = 0, randLo = 0, randHi = 20000, bprq = 1, gate = 1, doneAction = 2;
	var generation =
	Pulse.ar(SinOsc.kr(5/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(30/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(7/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(7/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(9/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(2/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(10/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(5/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(3/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(9/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(2/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(40/freq),widthmod,width,timescale), mul: 0.1);
	var env = generation * EnvGen.kr(Env.perc(attackTime:attTim,releaseTime: rlsTim), gate, doneAction: doneAction);
	var env1 = LeakDC.ar(env);
	var sig = env1 * amp;
	sig = BPF.ar(sig, Rand(randLo-100, randHi+100), bprq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*SynthDef(\tirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	noise = PinkNoise.ar(1!2);
	rainStep = noise + Blip.ar(noise + blipFreqMod, blipHarmo);
	rainStep = BRF.ar(
		rainStep,
		brfFreq,
		brfRq,
		0.1
	);
	thunder = LPF.ar(FreeVerb2.ar(*LPF.ar(noise + 0.2 * Dust.ar(0.1), 60) ++ [1, 1, 0.2, 1e4]).tanh, 2000);
	sig = rainStep + thunder;
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

/*SynthDef(\lmcdSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\plouxSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.1, dcy = 0.1, stn = 0.8, rls = 0.1, feedBack = 0, fbPost = 0, dustfreq = 2, dustdecay = 0.7, frq = 200, fmfreq = 100, folAtt = 0.01, folDec = 0.2, sinMix = 1, a = 1, b = 3, c = 0.5, d = 0.5, xi = 0.5, yi = 0.5, gate = 1, doneAction = 2;
    var sig, dust, input, inMod, envFol, freqMod;
	input = LocalIn.ar(2);
	inMod = input * feedBack;
    dust = Dust.ar(dustfreq);
    dust = Decay.ar(dust, dustdecay);
	freqMod = SinOsc.ar(fmfreq * dust) * inMod + 1;
    sig = SinOsc.ar(frq * freqMod);
	envFol = Amplitude.kr(sig, folAtt, folDec);
	sig = (sig * sinMix) + (RHPF.ar(LatoocarfianN.ar(freqMod.range(2000, 22050), a, b, c, d, xi, yi, LFNoise0.kr(dust)), input.range(20, 20000)) * (1 - sinMix));
    sig = sig * EnvGen.kr(Env.adsr(atk, dcy, stn, rls), gate, doneAction: doneAction);
	LocalOut.ar(sig * fbPost);
	sig = sig.tanh;
    // sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}, [\kr ! 22, \tr, \ir].flat).add;

SynthDef(\complexoscSd, { arg out = 0, amp = 1, pan = 0, feedBack = 1, envL1 = 0, envL2 = 2.2, envL3 = 0.12, envL4 = 0, envT1 = 0.01, envT2 = 0.24, envT3 = 0.12, envCurve = (-4), freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, gate = 1, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, env, sigenv;
    fbk = LocalIn.ar(2) * feedBack;
	//env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, doneAction: doneAction);
    osc1 = SinOsc.ar(freq1 + (fbk[1].range(1,1000) * fm1), 0 + (fbk[1].range(-pi,pi) * pm1), amp1 + (fbk[1] * ring1), offset1);
    osc2 = SinOsc.ar(freq2 + (fbk[0].range(1,1000) * fm2), 0 + (fbk[1].range(-pi,pi) * pm2), amp2 + (fbk[0] * ring2), offset2);
    LocalOut.ar([osc1, osc2]);
    folded = Fold.ar(osc1 ! 2, fold.neg, fold);
    wrapped = Wrap.ar(osc1 ! 2, wrap.neg, wrap);
    outlet = LeakDC.ar(Select.ar(switch, [osc1!2, osc2!2, folded, wrapped]));
    // OffsetOut.ar(out, outlet * env * amp);
	OffsetOut.ar(out, DirtPan.ar(outlet, ~dirt.numChannels, pan, amp * env));
}, [\kr ! 11, \ar ! 14, \kr, \tr, \ir].flat).add;

SynthDef(\benjolisSd,{ |out = 0, amp = 0.1, pan = 0, fadeTime = 0.01, freq1= 40, freq2=4, scaler=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, rq=0.82, gain=1, filterType=0, outSignal=6, doneAction = 2|
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


	output = Select.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output = LeakDC.ar(output * amp);
	// OffsetOut.ar(out, output * EnvGate(fadeTime: fadeTime, doneAction: doneAction));
	OffsetOut.ar(out, DirtPan.ar(output * EnvGate(fadeTime: fadeTime, doneAction: doneAction), ~dirt.numChannels, pan));
}).add;

SynthDef(\bytebeatsSd, { arg out = 0, amp = 0.2, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.2, envL4 = 3.2, envL5 = 0, envT1 = 0.12, envT2 = 0.02, envT3 = 0, envT4 = 0.2, curve1 = (-4), curve2 = (-4), curve3 = (-4), curve4 = (-4), counterFreq = 1, counterMul = 3.5, counterAdd = 3.5, srDiv = 6, frq = 232, doneAction = 2;
	//var sr = SampleRate.ir/6; //fix sample rate
	var counter, env;
	var sr = SampleRate.ir/srDiv; //variable sample rate
	//var frq = 10;
	var n = 16; //bit resolution
	var t= Phasor.ar(1,frq*((2**n)/sr),0,((2**n)-1)); //creating a raising value from 0 to 2**n
	//t = t & (2**(n-1)); // few tests
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve1, curve2, curve3, curve4]), doneAction: doneAction);
	//equations: try one at the time
	t = t * 4;
	//counter = LFSaw.ar(0.5,0,3.5,3.5); // browse the equations
	counter = LFDNoise0.ar(counterFreq, counterMul, counterAdd);
	//counter.poll;
	t = SelectX.ar(counter,[

	t*(((t>>12)|(t>>8))&(63&(t>>4))),
	t*(((t>>9)|(t>>13))&(25&(t>>6))),
	t*(((t>>5)|(t>>8)) & 63),
	t*(((t>>11)&(t>>8))&(123&(t>>3))),
	t*(t>>8*((t>>15)|(t>>8))&(20|(t>>19)*5>>t|(t>>3))),
	t*(t>>((t>>9)|(t>>8))&(63&(t>>4))),
	(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
	]);

	t = t % (2**(n));// avoiding number beyond 2**(bit resolution)
	t = t*(0.5**(n-1)) - 1;//scaling to -1, 1

	t = LeakDC.ar(t * amp);
	// OffsetOut.ar(out, t * env);
	OffsetOut.ar(out, DirtPan.ar(t, ~dirt.numChannels, pan, env));
}).add;

~synthSd = SynthDef(\feedbackOscSd, {|out=0, amp = 0.2, pan = 0, atk=0.01, rls=1, mFrq= 313, mFB= 1, frq= 100, fB= 1, width= 0, mul= 500, ffreq=1000, rq=1, gate = 1, doneAction = 2|
	var w= [0, width*2pi];
	var buf= LocalBuf(1).clear;
	var buf2= LocalBuf(1, 2).clear;
	var osc= sin(LFSaw.ar(mFrq).range(0, 2pi)+(Dbufrd(buf)*mFB));
	var snd= Duty.ar(SampleDur.ir, 0, Dbufwr(osc, buf));
	var osc2= sin(LFSaw.ar(frq+(snd*mul)).range(0, 2pi)+(Dbufrd(buf2)*fB)+w);
	var snd2= Duty.ar(SampleDur.ir, 0, Dbufwr(osc2, buf2));
	//var filter= RLPF.ar(snd2, ffreq, rq);
	var filter = DFM1.ar(snd2, ffreq, rq);
	var env = EnvGen.ar(Env.perc(atk, rls),gate,doneAction: doneAction);
	// OffsetOut.ar(out,filter * amp * env/*EnvGate(gate: gate, doneAction: doneAction)*/);
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef.new(\ShaiSd, { arg out = 0, amp=0.1, pan = 0, freq=440, atk=1, rls=8, doneAction = 2;
	var sig, env;
	sig = Mix.new(
		Array.fill(32, { SinOsc.ar(freq + Line.kr(1536.0.rand,freq*1.5,8), 0, 0.05) })
	);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rls],[1,-1]),doneAction: doneAction);
	sig = sig*env*amp;
	// OffsetOut.ar(out, [sig, sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef.new(\Colleen3Sd, { arg out = 0, amp=1, pan = 0, freq=110, atk=0.01, rls=2, lpf = 4000, lpfmin = 500, lpfmax = 16000, hpfmin = 1, hpfmax = 2000, doneAction = 2;
	var sig, env;
	freq = freq*(565/250)*PinkNoise.kr(0.01,1)*BrownNoise.kr(0.00,1)*0.36;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),lpf);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rls],[1,-1]),doneAction: doneAction);
	env = env**2;
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(lpfmin,lpfmax,rls/6));
	sig = HPF.ar(sig, XLine.kr(hpfmin,hpfmax,rls/6));
	sig = (sig*env*amp)*0.7;
	// sig = Pan2.ar(sig,pan);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\combsSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, dcy = 0.1, sst = 0.7, rls = 0.5, freq = 440, rate = 6, depth = 0.2, regen = -3, sweep = 16, rq = 0.5, harmonic = 1.5, gate = 1, doneAction = 2;

	var max, min, vibrato, snd, env, filterenv;

	//Setting some values for the filters:
	max = ((1 + depth) / freq);
	min = (1 / (freq * (1 + depth)));
	vibrato = LFNoise1.ar(rate).range(min, max);

	//Amplitude and filter cutoff envelopes
	env = Env.adsr(atk, dcy, sst, rls).kr(gate: gate, doneAction: doneAction);
	filterenv = Env.perc(atk, rls).kr;
	filterenv = ((filterenv * sweep) + 1) * freq;

	//The core noise:
	snd = BrownNoise.ar(1);
	snd = CombL.ar(snd, max, vibrato, regen);
	snd = CombN.ar(snd, harmonic / freq, harmonic / freq, regen, env);

	//More filters and output stuff:
	snd = RHPF.ar(snd, freq * 4, rq);
	snd = RLPF.ar(snd, filterenv, rq, amp);
	snd = Limiter.ar(snd, amp);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\werkitSd, { arg out = 0, amp = 0.1, pan = 0.0, atk = 0.01, dcy = 0, sst = 1, rls = 1, freq = 440, rq = 0.1, gate = 1,doneAction = 2;

	var source, filter, env, snd, delayEnv;
	source = WhiteNoise.ar;
	filter = BLowPass4.ar(source, freq, rq) * 0.3;
	env = EnvGen.ar(
		envelope: Env.adsr(atk, dcy, sst, rls, amp),
		gate: gate,
		doneAction: 2);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\werkit2Sd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, dcy = 0, sst = 1, rls = 0.1, freq = 440, rq = 0.1, gate = 1, doneAction = 2;

	var source, filter, env, snd;
	source = LFSaw.ar(Array.fill(16, { Rand(100, 200) }));
	filter = BLowPass4.ar(source, freq, rq) * 0.1;
	env = EnvGen.ar(
		envelope: Env.adsr(atk, dcy, sst, rls, amp),
		gate: gate,
		doneAction: doneAction);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	snd = HPF.ar(snd, 100);
	snd = Splay.ar(snd);
	// OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\impnSd,{ arg out = 0, amp=0.75, pan = 0, atk = 0.001, rls = 0.1, curve = (-5), impRate = 10, kfreq = 1, kdcy = 1, tu = 1, freq = 10327, bwr = 1, delTime = 0.25, decTime = 1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.linen(atk, 1, rls, 1, curve), doneAction: doneAction);
	sig = Impulse.ar(impRate);
	sig = DynKlank.ar(
		Ref.new([
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421] * tu,   // harmonics
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		]),
		sig,
		kfreq,
		decayscale: kdcy
	);
	sig = Resonz.ar(sig, freq, bwr);
	sig = CombL.ar(sig, 6, delTime, decTime);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Tonal

SynthDef(\cowSd, { arg out=0, amp=0.5, pan=0, atk = 0.001, rls=1, tu=1, gate=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.asr(atk,1,rls), gate, doneAction: doneAction);
	sig = LFPulse.ar(550*tu)+LFPulse.ar(tu*400*(env+250));
	sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
	// sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\notesSd,{arg out = 0, amp = 0.5, pan = 0, atk = 0.01, rls = 0.1, freq = 69, tu = 1, gate = 1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
	var sig = WhiteNoise.ar(env);
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,1)+sig;
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,0.2)+sig;
	sig = sig *env *0.5;
	sig = CompanderD.ar(sig*2,0.5,1,0.5);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\notes2Sd, { arg out = 0, amp = 0.5, pan = 0, notes = 68, at = 0.01, sst = 0.4, snd = 18, gate = 1;
	var env = EnvGen.ar(Env.adsr(at,1,sst,1.4),gate,doneAction:2);
	//var env = EnvGen.ar(Env.perc(0.01,1),gate,doneAction:2);
	var note = (notes+(432.cpsmidi-69)).midicps;
	var sig = Mix.ar(SinOsc.ar([note,note*2,note/2]));
	sig = Splay.ar(sig*0.1);
	// OffsetOut.ar(out,sig*env*0.5);
	// Out.ar(snd,sig*env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\sinusSd,{arg out = 0, amp = 0.5, pan = 0, freq = 100, gate = 1, atk = 0, rls = 0.1, lfo = 1, doneAction = 2;
	var env  = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
	var sig = SinOsc.ar(freq+(432-69.midicps)*SinOsc.kr(lfo),0,env);
	sig = HPF.ar(sig,100);
	sig = CompanderD.ar(sig,0.3,0.3,1.5,0.0001,0.01);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\prayerBellSd, { |out = 0, gate = 1, amp = 0.5, pan = 0, sing_switch = 0, freq = 2434, decayscale = 1, lag = 10, level = 0.08, i_doneAction = 2|
	var sig, input, first, freqscale, mallet, sing;
	freq = freq.max(20).min(5000);
	freqscale = freq / 2434;
	decayscale = decayscale.min(1);
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

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
	DetectSilence.ar(sig, doneAction: i_doneAction);
	// sig = Pan2.ar(sig, pan, level);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\prayerBellBrSd, { arg out = 0, amp = 0.5, pan = 0, singSwitch = 0, freq = 2434, decayScale = 1, lag = 10, doneAction = 2;
	var snd, input, first, freqScale, mallet, sing;
	freqScale = freq / 2434;
	freqScale = Lag3.kr(freqScale, lag);
	decayScale = Lag3.kr(decayScale, lag);

	// mallet
	mallet = LPF.ar(
		in: Impulse.ar(0) ! 2 * amp,
		freq: 10000 * freqScale
	);

	// sing
	sing = LPF.ar(
		in: {PinkNoise.ar * Integrator.kr(singSwitch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp} ! 2,
		freq: 2434 * freqScale
	);

	sing = sing + Dust.ar(0.1);
	sing = LPF.ar(sing, 10000 * freqScale);
	sing = sing * LFNoise1.kr(0.5).range(-45, -30).dbamp;

	// input = mallet + sing
	input = mallet + (singSwitch.clip(0, 1) * sing);

	// resonant filter bank
	snd = DynKlank.ar(
		specificationsArrayRef: `[
			// Array of filter frequencies
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
			// Array of filter amplitudes
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
			// Array of filter decay times
			[
				20 * freqScale.pow(0.2),
				20 * freqScale.pow(0.2),
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
			] * freqScale.reciprocal.pow(0.5)
		],
		input: input,
		freqscale: freqScale,
		freqoffset: 0,
		decayscale: decayScale
	);

	DetectSilence.ar(snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(Mix.ar(snd), pan));
	OffsetOut.ar(out, DirtPan.ar(Mix.ar(snd), ~dirt.numChannels, pan));
}).add;

SynthDef(\glockenspielSd, { arg out = 0, amp = 0.01, pan = 0, atk = 0.001, rls = 6, freq = 440, exciterRel = 0.05, doneAction = 2;
	var env, snd, exciter;

	env = Env.perc(atk, exciterRel, 0.25).kr;

	exciter = WhiteNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // harmonics
			        [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
		        	[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: rls
	);

	DetectSilence.ar(
		        in: snd,
		        amp: 0.001,
		        time: 0.5,
		        doneAction: doneAction
		    );

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\rissetBellSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.005, rls = 2, freq = 400, gate = 1, doneAction = 2;
	var amps = #[1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
	var durs = #[1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
	var frqs = #[0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
	var dets = #[0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
	var doneActionEnv = Env.linen(0, atk+rls, 0).ar(gate: gate, doneAction: doneAction);
	var snd = Mix.fill(11, {arg i;
		var env = Env.perc(
			attackTime: atk,
			releaseTime: rls * durs[i],
			level: amps[i],
			curve: atk.explin(0.005, 4, -4.5, 0)
	).ar(gate: gate);
		SinOsc.ar(
			freq: freq * frqs[i] + dets[i],
			mul: amp * env
		);
	});
	snd = snd * doneActionEnv * 0.5;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosBellSd, { arg out = 0, amp = 0.1, pan = 0, freq = 440, rls = 2, curve = \lin,
	//ring Controls (wobbleDepth goes from 0 to 1)
	ringAmp = 1, ringRel = 0.9, wobbleDepth = 0.6, wobbleMin = 1, wobbleMax = 1.8,
	//strike Controls
	strikeAmp = 1, strikeDec = 0.01, strikeRel = 0.04, strikeDepth = 0.028, strikeHarmonic = 8,
	//hum Controls
	humAmp = 0.5, humAtt = 0.5, humDec = 0.5, humRel = 1,
	doneAction = 2;

	var snd, ring, ringEnv, ringFreqs, strike, strikeEnv, strikeMod, hum, humEnv;

	ringFreqs = [2, 3, 4.1, 5.43, 6.8, 8.21];

	ringEnv = Env.new(
		            levels: [1, 0.3, 0.2, 0],
		            times: [1/3, 1/3, 1/3] * ringRel * rls,
		            curve: curve).kr;

	ring = SinOsc.ar(
		            freq: ringFreqs * freq,
		            mul: Array.series(6, 1, -0.1) * ringEnv);

	ring = ring * LFTri.ar(
		            freq: {Rand(wobbleMin, wobbleMax)}.dup(6)).range((1 - wobbleDepth), 1);

	strikeEnv = Env.new(
		            levels: [1, 0.1, 0],
		            times: [strikeDec, strikeRel * rls],
		            curve: curve).kr;

	strikeMod = LFNoise1.ar(freq * 36).range(1/ (strikeDepth + 1), strikeDepth + 1);

	strike = SinOsc.ar(
                    freq: freq * strikeHarmonic * strikeMod,
		            mul: strikeEnv);

	humEnv = Env.new(
		            levels: [0, 1, 0.8, 0],
		            times: [humAtt, humDec, humRel * rls],
		            curve: curve).kr;

	hum = SinOsc.ar(
		            freq: freq * [1.01, 0.47],
		            mul: humEnv);

	snd = Mix.ar((ring * ringAmp) + (strike * strikeAmp) + (hum * humAmp)) * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\tubularBellSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.005, rls = 9, freq = 440, exciterRel = 0.05, doneAction = 2;

	var env, snd, exciter;

	env = Env.perc(atk, exciterRel, 0.05).kr;

	exciter = GrayNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1.013, 1.512, 2.113, 2.525, 3.35, 4.57, 6.48],   // harmonics
			        [1, 0.78, 0.89, 0.63, 0.31, 0.56, 0.25], // amplitudes
		        	[1, 0.9, 0.8, 0.65, 0.45, 0.3, 0.1]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: rls
	);

	snd = LPF.ar(snd, freq * 9.5);

	DetectSilence.ar(
		        in: snd,
		        amp: 0.001,
		        time: 0.5,
		        doneAction: doneAction
		    );

	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\waveguideFluteSd, { arg out = 0, amp = 0.5, pan = 0, scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1, doneAction = 2;

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);
	// overall envelope
	kenv2 = EnvGen.kr(Env.new(
		[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: doneAction
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	fdbckArray = LocalIn.ar( 1 );

	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	// OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ] );
	OffsetOut.ar(out, DirtPan.ar(signalOut, ~dirt.numChannels, pan, kenv2));
}).add;

SynthDef(\justwannahavefunSd,{|out= 0 amp = 0.1 pan=0 freq = 440 ringTime=10.0 |

	var impulse, filter, env;

  	impulse = Impulse.ar(0);

	filter = Ringz.ar(impulse,(freq.cpsmidi + (Rand(0.2,1.2)*SinOsc.kr(Rand(10,50)))).midicps,ringTime);

	env = EnvGen.ar(Env([0.0,1.0,1.0,0.0],[0.001,0.04,0.04]),doneAction:2);

	// OffsetOut.ar(out,Pan2.ar((filter.softclip(0.9))*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar(filter.softclip(0.9), ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\marimba1Sd, { arg out = 0, amp = 0.4, pan = 0, freq = 440;
	var snd, env;
	env = Env.linen(0.015, 1, 0.5, amp).kr(doneAction: 2);
	snd = BPF.ar(Saw.ar(0), freq, 0.02);
	snd = BLowShelf.ar(snd, 220, 0.81, 6);
	snd = snd * env;
	// OffsetOut.ar(out, Splay.ar(snd));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(snd), ~dirt.numChannels, pan));
}).add;

SynthDef(\kalimbaSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, freq = 44,
	// Mix control goes from 0 to 1
	mix = 0.1,
	// Release controls for different parts of the sound
	minRel = 2.5, maxRel = 3.5, clickRel = 0.01,
	doneAction = 2;

	var note, env, body, snd;

	env = Env.perc(atk * 3, Rand(minRel, maxRel), 1, -8).kr(doneAction: doneAction);
	note = SinOsc.ar(freq) * env;
	body = DynKlank.ar(
		specificationsArrayRef:
		Ref.new([
			[240 * ExpRand(0.9, 1.1), 2020 * ExpRand(0.9, 1.1), 3151 * ExpRand(0.9, 1.1)],
			[-7, 0, 3].dbamp, // same as 10.pow([-7, 0, 3] / 20),
			[0.75, 0.04, 0.06] + clickRel
		]),
		input:
		// Try BrownNoise, GrayNoise, etc. here, but you may need to change ring times above
		(PinkNoise.ar * Env.perc(atk, clickRel).kr)
	);
	snd = (note * (1 - mix)) + (body * mix) * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pmCrotalesSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0, rls = 2, curve = -6, freq = 261, tone = 3, modLo = 5.25, modHi = 5.5;
	var env, snd, mod;

	env = Env.perc(attackTime: 0, releaseTime: rls, curve: curve).kr(doneAction: 2);

	mod = Rand(modLo, modHi);

	snd = PMOsc.ar(
	    	carfreq: freq,
	    	modfreq: mod * freq,
	    	pmindex: env * tone,
	    	mul: env * amp
	    );

	snd = HPF.ar(snd, freq / 2);

	snd = Mix.ar(snd);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\steelDrumSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, dcy = 1.5, curve = -6, freq = 440, filterHarmonic = 6, doneAction = 2;
	var resFreqArray, resAmpArray, resDecArray, enva, envb, envc, snda, sndb, sndc, snd;

	//Arrays for the bank of resonators, mostly harmonics near 5ths and 9ths, and random amplitudes:
	resFreqArray = [2, 2.98, 4.75, 6.21, 9, 9.15, 11.87];
	resAmpArray = [0.35, 0.23, 0.10, 0.06, 0.07, 0.05, 0.01];
	resDecArray = [0.86, 0.72, 0.37, 0.55, 0.32, 0.21, 0.16];

	//Custom envelope shapes attempting to capture the aparrent "bloom" of a note:
	enva = Env.pairs([[0, 0], [atk, 1], [(atk + dcy), 0]], curve).kr;
	envb = Env.pairs([[0, 0], [(atk * 5), 0.25], [(atk * 6), 0.75], [((atk * 6) + (dcy / 2)), 0]], curve).kr;
	envc = Env.pairs([[0, 0], [(atk * 5), 0.1], [(atk * 8), 0.5], [((atk * 8) + (dcy / 3)), 0]], curve).kr;

	//Fundamental, octave up, and a bank of enharmonic resonators excited by a metalic sound:
	snda = SinOsc.ar(freq: freq, mul: enva);
	sndb = SinOsc.ar(freq: freq * 2.015, mul: envb);
	sndc = DynKlank.ar(
		specificationsArrayRef:
		    Ref.new([
		    	resFreqArray * freq,
		    	resAmpArray,
			    resDecArray * dcy
		    ]),
		input:
		LPF.ar(HPF.ar(CombN.ar(PinkNoise.ar(1), 1/freq, 1/freq, -1, envc), freq * 2), freq * filterHarmonic)
	);

	//Output stages with a tiny bit of compression to smooth things out:

	snd = Mix.ar([snda, sndb, sndc]) * (amp / 3);
	snd = Limiter.ar(snd, amp);
	DetectSilence.ar(in: snd, amp: 0.0001, time: 0.5, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\noisyToneSd, { arg out = 0, freq = 440, amp = 0.2, pan = 0.5;
	var snd, env;
	env = Env.perc(0.02, 0.1).kr(doneAction: 2);
	snd = Mix(LFPulse.ar(
		freq: freq * [1, 5/2],
		iphase: 0.0,
		width: 0.5,
		mul: amp));
	snd = snd * env ;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\ping_mhSd,{arg out=0, amp=0.2, pan=0, freq=440, dur=0.1, atk=0.001;
    var sig, freq2;
    freq=freq*rrand(1,1.01);
    freq2=freq*rrand(1,1.01);
	e=EnvGen.ar(Env.perc(atk,dur.max(0.01),curve:-4),doneAction:2);
    sig=SinOsc.ar([freq,freq2],0,amp*e);
    // sig=Pan2.ar(sig,pan);
    // OffsetOut.ar(out,sig)
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\pluckingSd, {arg out = 0, amp = 0.1, pan = 0, freq = 440, dcy = 5, coef = 0.1;
	var env, snd;
	env = EnvGen.kr(Env.linen(0, dcy, 0), doneAction: 2);
	snd = Pluck.ar(
		in: WhiteNoise.ar(amp),
		trig: Impulse.kr(0),

		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: dcy,
		coef: coef);
	// OffsetOut.ar(0, [snd, snd]);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pwmblingSd, { |out= 0 amp = 0.1 pan = 0.0 freq = 440 lforate = 4.85 lfowidth= 0.5 cutoff= 12000 rq=0.25 gate=1|

	var lfo, pulse, filter, env;
	var basefreq =  ((freq.cpsmidi)+[0,12.12]).midicps;

	lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);

	pulse = Pulse.ar(basefreq,lfo*lfowidth+0.5);

	env = EnvGen.ar(Env.adsr(0.0,1.0,0.2,1.5),gate,doneAction:2);

	filter = RLPF.ar(pulse,(cutoff*(env.squared))+100,rq);

	// OffsetOut.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar(Mix(filter), ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\ressquaresSd,{|out= 0 amp = 0.1 pan=(-0.1) freq = 440 cutoff=8000 rq=0.8 gate=1|

	var pulse, filter, env;

	//2 cents detune for second oscillator
	pulse = Mix(Pulse.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;

	filter =  BLowPass.ar(pulse,100+cutoff,rq);

	env = EnvGen.ar(Env.adsr(0.002,0.1,1.0,0.2),gate,doneAction:2);

	// OffsetOut.ar(out,Pan2.ar(filter*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\glaukSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, rls = 2, freq = 100, gate = 1, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = Splay.ar(
		SinOsc.ar(
			Array.fill(20,{arg i; freq+i; })
		)
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\scintySd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, rls = 10, gate = 1, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = Splay.ar(
		Array.fill(15,{Ringz.ar(Dust.ar(Rand(1,10)), Rand(50,9000).round(100), 2)},
			1,
			0.5,
			0
		)
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\bublybubSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, x = 165, gate = 1, doneAction = 2;
	var sig, env, waveForm, freq, dur, input;
	// env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	waveForm = SinOsc;
	freq = Trig.ar(Saw.ar(x),1);
	dur = waveForm.ar(freq * x);
	input = waveForm.ar(freq);
	sig = GVerb.ar(GrainIn.ar(2,dur,dur/2,input,freq*input,-1),9);
	sig = sig * env;
	//OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\chdegaulleaboutSd, { arg out = 0, amp = 1, pan = 0, freq = 0.01, atk = 0.01, rls = 10, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = SinOsc.ar(LFNoise1.kr(freq).exprange(100,{exprand(300,10000)}!120)).mean;
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t2001Sd, { arg out = 0, amp = 1, pan = 0, gate = 1, atk = 0.01, rls = 10, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = PinkNoise.ar(1);
	20.do{
		sig = BBandStop.ar(sig, LFNoise1.kr(0.05.rand).exprange(40,15000), exprand(0.1,2));
	};
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\claudTweetSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, rls = 10, gate = 1, doneAction = 2;
	var sig, env, x;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = LFTri.ar(
		Duty.ar(Dseq([3,1]/12,inf),
			0,
			Dseq(
				x = (3..6);
				allTuples(x/.t x).flat*[100,200,400]++0
			)
		)
	);
	sig = GVerb.ar(sig, 25, 5)/5;
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ambitekSd, { arg out = 0, amp = 0.5, pan = 0, atk = 0.01, rls = 10, envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4), sawFreq = 50, delTime = 0.1, delDecay = 2, brfRq = 2, gate = 1, doneAction = 2;
	var sig, env, envS;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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
	sig = sig * env;
	// OffsetOut.ar(out, sig!2 * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\mainSd, { arg out = 0, amp = 0.5, pan = 0, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sinFreq = 30, sel = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, atk = 0.0, rls = 0.1, timeScale = 1, noiseAmp = 1, hpf = 8000, revtime = 3, room = 10, damp = 0.5, revMix = 0, gate = 1, doneAction = 2;
	var revSig;
	var fmod = SinOsc.ar(freq/60, 0, freq/60);
	var sig = [
		SinOsc.ar([freq, freq + 600] + fmod, 0, [lev, 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpf),
		SinOsc.ar(sinFreq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];
	var env = EnvGen.kr(Env.new([envLevel1, envLevel2, envLevel3], [atk, rls]), gate, levelScale, levelBias, timeScale, doneAction);
	sig = (Select.ar(sel, sig) * env).fold(-1, 1) * 0.7 + SinOsc.ar(40, 0, 0.3) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpf));
	revSig = GVerb.ar(sig, Lag3.kr(room).max(0.01), revtime, damp);
	sig = SelectX.ar(revMix, [sig, revSig]);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\flashSd, { arg out = 0, amp = 0.3, pan = 0, fund = 400, dcy = 4, filter = 1, doneAction = 2;
	var sig;
	sig = Mix.ar( Array.fill(7,
		{
			arg counter;
			var partial;
			partial = counter + 1;
			SinOsc.ar(fund*partial) * EnvGen.kr(Env.linen(0, 0, dcy), levelScale: 1/(partial*filter)
			) * max(0, LFNoise1.kr(rrand(5.0, 12.0)));
		}
	)
	);
	sig = Pan2.ar(sig, Rand(-1.0, 1.0), amp);
	DetectSilence.ar(sig, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\elifmSd, { arg out = 0, freq = 500, mRatio = 1, cRatio = 1, index = 1, iScale = 5, amp = 0.2, atk = 0.01, rls = 3, cAtk = 4, cRel = (-4), pan = 0;
    var car, mod, env, iEnv;
    iEnv = EnvGen.kr(
        Env.new(
            [index, index * iScale, index],
            [atk, rls],
            [cAtk, cRel]
        )
    );
    env = EnvGen.kr(
        Env.perc(atk, rls, curve: [cAtk, cRel]),
        doneAction: 2
    );
    mod = SinOsc.ar(freq * mRatio, mul: freq * mRatio * iEnv);
    car = SinOsc.ar(freq * cRatio + mod) * env * amp;
    // car = Pan2.ar(car, pan);
    // OffsetOut.ar(out, car);
	OffsetOut.ar(out, DirtPan.ar(car, ~dirt.numChannels, pan));
}).add;

SynthDef(\polishFabSd, { arg out = 0, amp = 0.2, pan = 0, atk = 11, rls = 6, feedBack = 2, phmodFrq = 0.5, freq1 = 64, freq2 = 23, envfL1 = 0, envfL2 = 500, envfL3 = 20, envfL4 = 0, envfT1 = 0.2, envfT2 = 0.01, envfT3 = 0.12, envfCure = (-4), frqScale = 0.5, gate = 1, doneAction = 2;
	var sig, env, envf, num, input;
	num = 8;
	input = LocalIn.ar(2) * feedBack;
	envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4], [envfT1, envfT2, envfT3], envfCure), gate) * frqScale;
	sig = Mix.arFill(
		num,
		{ arg i;
			var oddHarm = i * 2 + 1;
			var evenHarm = i * 2 + 2;
			SinOsc.ar(
				[freq1 * oddHarm, freq2 * evenHarm] + envf,
				Latch.kr((input * (i + 1)) * pi, Impulse.kr((oddHarm / (3 * pi)) + phmodFrq)),
				num.reciprocal
			)
			*
			EnvGen.kr(
				Env.sine(num / i)
			)
		}
	);
	env = EnvGen.kr(
		Env.perc(atk, rls),
		gate,
		doneAction: doneAction,
		levelScale: 0.75
	);
	sig = (sig[0] + sig[1]) * env;
	LocalOut.ar(sig);
	sig = Splay.ar(sig, 1, amp);
	// OffsetOut.ar(out, sig /** amp*/);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\slatechreSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 3, gate = 1, doneAction = 2;
	var env, note, snd, delaytime, damp, size, diff, feedback, localout;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	note = Demand.kr(Impulse.kr(0) + Dust.kr(0.1), 0, Diwhite(60, 80, inf));
	delaytime = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(0.1, 0.3, inf));
	damp = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.2, 0.6, inf));
	size = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(2, 10, inf));
	diff = Demand.kr(Impulse.kr(0) + Dust.kr(0.2), 0, Dwhite(0.5, 1.0, inf));
	feedback = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.8, 1.0, inf));
	snd = SinOsc.ar(freq: [note, note+LFNoise1.kr(freq: 0.1).range(-0.25, 0.25)].midicps);
	localout = Mix.ar(3.collect({ |i|
		Pan2.ar(
			in: PitchShift.ar(in: snd, pitchRatio: i),
			pos: LFNoise1.ar(freq: TRand.ar(10.reciprocal, 1, Impulse.kr(8.reciprocal))).range(-1,1),
			level: (i+1).reciprocal
		) * -20.dbamp;
	}));
	localout = Compander.ar(in: localout, control: localout, thresh: -6.dbamp, slopeAbove: 3.reciprocal);
	LocalOut.ar(localout);
	snd = LocalIn.ar(2) * feedback;
	// OffsetOut.ar(out, (localout.tanh * env) * amp);
	OffsetOut.ar(out, DirtPan.ar(localout.tanh, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\ColleenSd, { arg out = 0, amp=1, pan = 0, atk=0.35, rls=2, freq=110, doneAction = 2;
	var sig, env;
	freq = 1*freq*(320/250)*PinkNoise.kr(0.05,1)*BrownNoise.kr(0.01,1)*2;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rls],[1,-1]),doneAction: doneAction);
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(100,700,rls*0.1));
	sig = (sig*env*amp)*4;
	// sig = Pan2.ar(sig,pan);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\zeynepSd, { arg out = 0, amp=1, pan = 0, freq=440, envL1 = 0, envL2 = 0.03, envL3 = 0.1, envL4 = 0.2, envL5 = 0, envT1=1, envT2=1, envT3=4, envT4=0.2, dur = 1, beats=1, lpf = 3200, hpf = 2000, doneAction = 2;
	var sig, env;
	sig = Resonz.ar(WhiteNoise.ar(0.5), freq, XLine.kr(0.1, 0.001, dur*beats))*50;
	env = EnvGen.kr(Env.new([envL1,envL2,envL3,envL4,envL5],[envT1,envT2,envT3,envT4],[1,-1]),doneAction: doneAction);
	sig = LPF.ar(sig, lpf);
	sig = HPF.ar(sig, hpf);
	sig = (sig*env*amp).tanh;
	// OffsetOut.ar(out, [sig, sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosTomSd, { arg out = 0, amp = 0.6, pan = 0, drumRel = 0.4, stickRel = 0.01, drumModeAmp = 0.25, freq = 250, timbreIndex = 0.77, atk = 0.005, curve = -6, doneAction = 2;

	var drumMode, drumModeEnv, stick, stickEnv, snd;

	drumModeEnv = Env.perc(
		            attackTime: atk,
		            releaseTime: drumRel,
		            level: 0.5,
		            curve: curve).kr(doneAction: doneAction);

	drumMode = PMOsc.ar(
		            carfreq: Saw.ar(freq: freq * 0.9),
					modfreq: freq * 0.85,
					pmindex: timbreIndex,
					mul: drumModeEnv * 10);

	drumMode = drumMode + SinOsc.ar(freq: [freq, freq * 0.8], mul: drumModeEnv);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	stick = Crackle.ar(chaosParam: 2.01);

	stickEnv = Env.perc(attackTime: atk, releaseTime: stickRel, level: 3, curve: curve).kr;

	snd = Mix.ar(drumMode + stickEnv) * amp;

	snd = LeakDC.ar(snd);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\beatingSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, dcy = 1, freq = 440, curve = -4, beatFreq = 15, doneAction = 2;

	var env, snd, oscillator1, oscillator2;

	env = Env.perc(atk, dcy, amp, curve).kr(doneAction: doneAction);

	oscillator1 = SinOsc.ar(freq); //Try other waveforms for the oscillators! Mix and match, collect them all!
	oscillator2 = SinOsc.ar(Line.kr(freq + beatFreq, freq, dcy));

	snd = Mix([oscillator1, oscillator2]);
	snd = snd * env;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\blip1Sd, {arg out = 0, amp = 0.1, pan = 0, atk = 0.01, rls = 1, freq = 25, numharm = 10, doneAction = 2;
	var snd, env;
	env = Env.perc(atk, rls, amp).kr(doneAction: doneAction);
	snd = Blip.ar(
		freq: freq * [1, 1.01],
		numharm: numharm,
		mul: env
	);
	snd = LeakDC.ar(snd);
	snd = Mix.ar(snd);
	// snd = Pan2.ar(snd, pan);
	// OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\laserbeamSd, { arg out = 0, amp = 0.6, pan = 0.0, freq = 40, atk = 0.01, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([4, 0.5, 1, 1], [atk, 0.01, 1.0]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([0, 1, 0.5, 0.0], [0.02, 0.2, 0.1]),
		levelScale: amp,
		doneAction: doneAction);
	snd = LFTri.ar(freq: freq * freqenv, mul: ampenv);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\ping_mhSd,{ arg out = 0, amp = 0.2, pan = 0, atk = 0.001, dur = 1, curve = -4, freq = 90, rate = 4, depth = 0.03, doneAction = 2;
	var snd, lfo, env;

	lfo = LFNoise2.ar(rate).range(1 / (1 + depth), (1 + depth));

	env = Env.perc(attackTime: atk, releaseTime: dur, level: amp, curve: curve).kr(doneAction: doneAction);

	snd = SinOsc.ar(freq: [freq, freq * lfo], mul: env);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pulseRissetSd, {arg out = 0, amp = 0.1, pan = 0, atk = 0.01, rls = 11, freq = 440, pulseFreq = 8;
    var partials, durs, amps, snd, env;
 	partials = [246.4, 247.4, 404.8, 406.5, 523.6, 748, 880, 1206, 1320, 1654, 1791]; // original freqs
	partials = (partials / 440) * freq; // consider 440 the 'root'
	durs = [11, 10, 7, 6, 4, 3.4, 3, 2.2, 2, 1.1, 1] / 11;
	amps = durs.linlin(1, 11, 0.2, 1);

	env = Env.perc(
		attackTime: atk,
		releaseTime: durs * rls,
		level: amps
	).kr(doneAction: [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]); // only longest env gets doneAction: 2

	snd = Pulse.ar(partials) * env * amp / 11;

	snd = RLPF.ar(
		in: snd,
		freq: freq * LFPulse.ar(pulseFreq).range(2, 4),
		rq: SinOsc.ar(LFNoise2.kr(1).range(4, 9)).range(0.1, 0.3)
	);

	snd = LPF.ar(snd, 12000);
	snd = Limiter.ar(Mix.ar(snd));

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pitchTrackSynthIxiSd, {arg in = 0, out = 0, pan = 0, atk = 0.51, dcy = 0.52, sst = 1, rls = 0.51, curve = (-4);
	var sig, env, input, amp, freq, hasFreq;

	// the audio input
	// input = SoundIn.ar([in, in+1]);
	input = InFeedback.ar(in, 2);
	amp = Amplitude.kr(in, 0.25, 0.25);

	// the pitch variable and the hasFreq (Pitch.kr returns a list like this [freq, hasFreq])
	# freq, hasFreq = Pitch.kr(input, ampThreshold: 0.2, median: 7);

	// when the hasFreq is true (pitch is found) we generate a ADSR envelope that is open until
	// the hasFreq is false again or the amplitude is below the ampThreshold of the Pitch.
	env = EnvGen.ar(Env.adsr(atk, dcy, sst, rls, 1, curve), gate: hasFreq);

	// we plug the envolope to the volume argument of the Sine
	sig = SinOsc.ar(freq, 0, env * amp)/* ! 2*/;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\pitcherIxSdi,{ arg out = 0, in = 0, pan = 0, threshold = 0.5, lpf = 2000;
	var input, amp, freq, hasFreq, sig, gate;

	// input = SoundIn.ar([in, in + 1]);
	input = InFeedback.ar(in, 2);

	// using a LowPassFilter to remove high harmonics
	input = LPF.ar(Mix.new(input), lpf);
	amp = Amplitude.kr(input, 0.25, 0.25);

	// # freq, hasFreq = Pitch.kr(input, ampThreshold: 0.1, median: 7);
	# freq, hasFreq = Tartini.kr(input); // Tartini performs better than Pitch

	gate = Lag.kr(amp > threshold, 0.01);

	// sig = VarSaw.ar(freq, 0, 0.2, amp*hasFreq*gate);

	// 3 sines (octave lower, pitch and octave higher mixed into one signal
	sig = Mix.new(SinOsc.ar(freq * [0.5,1,2], 0, 0.2 * amp*hasFreq*gate));
	6.do({
		sig = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
	});
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\sin_pulsarSd, { arg out = 0, pan = 0, doneAction = 2;
    var a, b, c, d, e, f, f_, fund, t, lev, formantA, formantB, overlapA, overlapB;
    lev = \lev.kr(0.3);
    f = \freq.kr(440);
    f_ = f.clip(50, 1500);
    formantA = \formantA.kr(2);
    formantB = \formantB.kr(6);
    overlapA = \overlapA.kr(2);
    overlapB = \overlapB.kr(2);

    e = EnvGen.kr(
        Env.perc(
            attackTime: f_.linlin(50, 1500, 0.1, 0.02),
            releaseTime: Rand(1, 7)
        ),
        gate: \gate.kr(1)
    );

    e = e * PinkNoise.ar(1!2).range(0.1, 1).lag(0.02);

    fund = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f),
        dur: Rand(0.5, 2) * (1.05 - e.pow(1.1))
        // Rand(0.5, 2) * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 3, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * SinOsc.ar(e * 3, {Rand(0, 6.28)}.dup).range(0.9, Rand(1, 1.5))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    a = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f + Rand(-3, 3)),
        dur: overlapA * (1.05 + e.pow(1.5))
        // overlapA * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 4, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * (formantA * SinOsc.ar(e * 4, {Rand(0, 6.28)}.dup).range(0.9, 1.1))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    b = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f + Rand(-3, 3)),
        dur: overlapB * (1.05 + e.pow(2.5))
        // overlapB * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 6, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * (formantB * SinOsc.ar(e * 5, {Rand(0, 6.28)}.dup).range(0.9, Rand(1, 1.5)))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    c = Mix([
        fund * (lev * e).pow(0.7),
        a * (lev * e).pow(f_.linlin(50, 1500, 1.1, 1.5)),
        b * (lev * e).pow(f_.linlin(50, 1500, 1.5, 2.5))
    ]);

    c =LeakDC.ar(c);

    d = c;

    4.do{ arg i;
        d = AllpassC.ar(
            d,
            delaytime: LFNoise1.kr(0.2!2).range(0.01, 0.02)
        )
    } *0.5;

    d = c * Rand(0.1, 0.9) + d;

    DetectSilence.ar(d, doneAction: doneAction);
    // Out.ar(out, d);
	OffsetOut.ar(out, DirtPan.ar(d, ~dirt.numChannels, pan));
}).add;

SynthDef(\fm_pulsarSd, { arg out = 0, pan = 0, doneAction = 2;
    var a, e, f;
    var t, overlap, carfreq, modfreq, mInd, vel, vel_;

    f = \freq.kr(100);
    f = f + SinOsc.ar(LFNoise1.kr(0.3!2).range(1, 4));

    vel = \vel.kr(0.5);
    vel_ = vel.clip(0, 1.0).linlin(0, 1, 2, 0.7);

    e = EnvGen.kr(
        Env.adsr(
            \att.kr(0.025) * vel_,
            \dec.kr(0.02) * vel_,
            \sus.kr(0.7),
            \rel.kr(4),
            curve: \curve.kr(-4)
        ),
        gate: \gate.kr(1),
        doneAction: doneAction
    ) * vel;

    e = e * PinkNoise.ar(1!2).range(0.1, 1).lag(0.02);

    carfreq = f * \cf.kr(2) + LFNoise1.kr(3).range(0, 50);
    modfreq = carfreq * \mf.kr(2) + LFNoise1.kr(3).range(0, 100);

    t = Impulse.ar(f);
    mInd = e.pow(3.3) * LFNoise2.kr(5!2).range(\mIndMin.kr(0.1), \mIndMax.kr(2.3));
    overlap = 1.1 - e.pow(0.5) * LFNoise1.kr(0.3!2).range(\olapMin.kr(1), \olapMax.kr(8));
    d = overlap/f;

    a = Mix([
        SinOsc.ar(f),
        GrainFM.ar(1, t, d, carfreq, modfreq, mInd)
    ]);

    a = LeakDC.ar(a * e);
    // OffsetOut.ar(out, a * \gain.kr(0.1));
	OffsetOut.ar(out, DirtPan.ar(a * \gain.kr(0.1), ~dirt.numChannels, pan));
}).add;

SynthDef(\pm4Sd, {

    var numops = 4;
    var fb = LocalIn.ar(numops);

    var gate = \gate.kr(1);
    var in_freq = \freq.ar(261).lag(\glis.kr(0));
    var bend = \bend.ar(0).midiratio;
    var freqbend = in_freq * bend;
    var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.000));
    var detunehz = \detunehz.kr(0);
    var vel = \vel.kr(1);

    var car = numops.collect({arg i;
        var num = i+1;
        var ratio = ('op' ++ num ++ 'ratio').asSymbol;
        var curve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
        var atk = ('op' ++ num ++ 'atk').asSymbol.kr(0.01);
        var dcy = ('op' ++ num ++ 'dcy').asSymbol.kr(0.01);
        var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
        var rls = ('op' ++ num ++ 'rls').asSymbol.kr(1);
        var env = Env.adsr(
            attackTime:atk,
            decayTime:dcy,
            sustainLevel:suslevel,
            releaseTime:rls,
            curve:curve
        ).kr(gate:gate);

        [freq * ratio.kr(1) + Rand(detunehz.neg, detunehz), env]
    });

    var mods = numops.collect({arg i;
        var y = i + 1;
        numops.collect({arg j;
            var x = j + 1;
            var key = ('m' ++ y ++ '_' ++ x).asSymbol;
            key.kr(0);
        });
    });

    var sig = numops.collect({arg i;
        var num = i+1;
        var freq = car[i][0].clip(20, 20000);
        var index = mods[i];
        var mod = (fb * index).sum;
        var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
        var coef = ('op' ++ num ++ 'coef').asSymbol.kr(0.5).clip(-1, 1);
        sig = OnePole.ar(sig, coef);
        sig;
    });

    sig = LeakDC.ar(sig);

    LocalOut.ar(sig);

    // set output level
    sig = sig * numops.collect({arg i;
        var num = i + 1;
        var key = ('op' ++ num).asSymbol;
        key.kr(1);
    }).normalizeSum;

    // set panning
    sig = numops.collect({arg i;
        var num = i + 1;
        var key = ('op' ++ num ++ 'pan').asSymbol;
        Pan2.ar(sig[i],    key.kr(0),    1)
    }).sum;

    sig = BLowPass.ar(
        BHiPass.ar(sig,
            \hpf.kr(20).clip(20, 18000),
            \hpfres.kr(0).linlin(0, 1, 1, 0.001)
        ),
        \lpf.kr(20000).clip(20, 20000),
        \lpfres.kr(0).linlin(0, 1, 1, 0.001)
    );

    sig = sig * AmpCompA.kr(freq) * \amp.kr(0.1) * vel;
    sig = sig.softclip;
    DetectSilence.ar(sig, doneAction: \doneAction.ir(2));

    // Out.ar(\out.kr(0), sig);
	OffsetOut.ar(\out.kr(0), DirtPan.ar(sig, ~dirt.numChannels, \pan.kr(0)));

}).add;

SynthDef(\sawFiltKymaSd, { |out = 0, amp = 0.1, pan = 0, freq = 440, cf = 100, wobble = 3, t_bd, t_sd, pw = 0.4, gate = 1, doneAction = 2|
    var base = Splay.ar(RLPF.ar(Pulse.ar(freq * [0.99,0.5,1.01],pw),cf.lag(0.05),0.3).madd(SinOsc.ar(wobble).range(0.5,4)).sin) * 0.5;
    var env = Linen.kr(gate, attackTime: 0.01, releaseTime: 0.5, doneAction: doneAction);
    var sig = base;
    var bd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_bd,SampleDur.ir),1000),30,0.5,5).sin*2);
    var sd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_sd,SampleDur.ir),1000),120,0.75,PinkNoise.ar(2!2)).sin*2);
    sd = HPF.ar(sd,60);
    sig = tanh(GVerb.ar(HPF.ar(base * env,30), 70, 11, 0.15)*0.5 + sig + bd + sd);
	// Out.ar(out, sig*amp*env);
	OffsetOut.ar(out, DirtPan.ar(sig*amp*env, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Sequence

SynthDef(\virgoSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, rls = 1, feedback = 7.5, freq1 = 32, freq2 = 33, delaytime = 2, decaytime = 40, gate = 1, doneAction = 2;
	var sig, input, modFreq;
	input = LocalIn.ar(2) * feedback;
	sig = input + Saw.ar([freq1, freq2], amp);
	modFreq = 2 ** LFNoise0.kr(4/3, 4) * 300;
	sig = BPF.ar(sig, modFreq, 0.1).distort;
	sig = CombN.ar(sig, 1, delaytime, decaytime);
	LocalOut.ar(sig);
	sig = sig * EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\scratchiSd, { arg out = 0, amp = 1, pan = 0, spread = 0, atk = 0.01, rls = 2, freq = 0.5, gate = 1, doneAction = 2;
	var sig, env, waveForm, trig;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	waveForm = SinOsc.ar(freq,[0,1],3,1);
	trig = Impulse.ar([waveForm+0.2,waveForm]);
	sig = FreeVerb.ar(Decay.ar(trig,waveForm,MoogFF.ar(SinOsc.ar(([waveForm.asin])*50),400)).softclip/2);
	sig = sig * env;
	// OffsetOut.ar(out, Splay.ar(sig, spread, amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig, spread, amp), ~dirt.numChannels, pan));
}).add;

SynthDef(\seqPureSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = Splay.ar({|i|
		RLPF.ar(0.6**i*40*Impulse.ar(2**i/32,1/2),4**LFNoise0.kr(1/16)*300,5e-3).sin;
	}!8);
	2.do{
		sig = FreeVerb2.ar(*sig++[0.1,1,1]);
	};
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\seqModulSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, gate = 1, doneAction = 2;
	var sig, env, buffer;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	buffer = LocalBuf(1e5,2).clear;
	sig = BufRd.ar(2,buffer,Phasor.ar(0,1,0,1e5))*0.6;
	BufWr.ar(Blip.ar([1,1.01],10)/5+sig,buffer,LFNoise1.ar(0.2)+1*5e4);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\nathanielVirgoSd, { arg out = 0, amp = 1, pan = 0, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, 0.01, 1, 20, doneAction);
	sig = LocalIn.ar(2) * feedBack + Saw.ar(
		[sawFreq1, sawFreq2],
		sawAmp
	) * env;
	sig = BPF.ar(
		sig,
		bpff ** LFNoise0.kr(bpffModSpeed, bpffModAmt) * 300,
		0.1
	).distort;
	sig = CombN.ar(sig, 2, delayTime, decayTime);
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\taltersSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, feedBack = 1, freq = 66, freqL1 = 0, freqL2 = 2, freqL3 = 4, freqL4 = 16, freqT1 = 0.01, freqT2 = 0.2, freqT3 = 0.12, freqCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, freqenv;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	input = LocalIn.ar(2) * feedBack;
	freqenv = EnvGen.ar(Env([freqL1, freqL2, freqL3, freqL4], [freqT1, freqT2, freqT3], freqCurve), gate);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(
				(i*k*k) + freq * freqenv,
				y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(decDens**i), (y.ar(decTimeFreq)+1*k+i) * input, k*decamp))
		}!3).product;
	}!4).sum;
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\talters1Sd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, modenv, harmk, ampk, ringk;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

/*SynthDef(\bozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, ctrl;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	input = LocalIn.ar(2).tanh * feedBack;
	ctrl = Latch.kr(input[0].abs, Impulse.kr(impFreq));
	sig = Blip.ar([freq1, freq2], 100 * ctrl + 50, 0.9);
	sig = CombC.ar(
		sig,
		1,
		ctrl * delTime,
		decTime * input
	);
	LocalOut.ar(sig);
	sig = Splay.ar(sig * env, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;*/

SynthDef(\padovanSd, { arg out = 0, amp = 1, pan = 0, tridDur = 1, freq = 165, roomSize = 9, gate = 1, doneAction = 2;
	var sig, env, input, mod, grainTr, sinMod;
	env = Linen.kr(gate, 0.1, 1, 5, doneAction);
	sig = SinOsc;
	mod = Trig.ar(
		Saw.ar(freq),
		tridDur
	);
	grainTr = sig.ar(mod * freq);
	sinMod = sig.ar(mod);
	sig = GrainIn.ar(2, grainTr, grainTr / 2, sinMod, mod * sinMod, -1, mul: env);
	sig = GVerb.ar(sig, roomSize, mul: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*SynthDef(\nozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, gate = 1, doneAction = 2;
	var sig, env, delayTime;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\LiljedDrumSeqSd, { arg out = 0, amp = 1, pan = 0, atk = 0.0001, rls = 4, sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, gate = 1, doneAction = 2;
	var sig, env, imp, krps, kick;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
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
		) * Line.kr(0,1,16),
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
	// sig = sig * env * amp;
	sig = Mix.ar(sig) * env * amp;

	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedKickSeqSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, trgChance1 = 0.5, trgChance2 = 0.3, trgChance3 = 0.9, trgRate1 = 4, trgRate2 = 12, trgRate3 = 6, rFreq1 = 45, rFreq2 = 50, rDec1 = 0.6, rDec2 = 0.1, rDec3 = 1, rDec4 = 0.3, rAmp1 = 9, rAmp2 = 2, rAmp3 = 3, rAmp4 = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = Ringz.ar(
		CoinGate.ar(
			[trgChance1, trgChance2, trgChance3],
			Impulse.ar([trgRate1, trgRate2, trgRate3])
		),
		[rFreq1, rFreq2],
		[rDec1, rDec2, rDec3, rDec4],
		[rAmp1, rAmp2, rAmp3, rAmp4]
	).sin.sum.tanh;
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedMetalicSd, { arg out = 0, amp = 0.05, pan = 0, atk = 0.01, rls = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rDec = 0.7, revSize = 5, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4],
		rDec
	).sum*2;

	sig = GVerb.ar(
		sin(sig),
		revSize,
		revTime,
		revDamp
	);

	sig = Mix.ar(sig) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedMetalic1Sd, { arg out = 0, amp = 0.05, pan = 0, atk = 0.01, rls = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rFreq5 = 1320, rFreq6 = 150, rDec = 0.7, revSize = 5, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4, rFreq5, rFreq6],
		rDec
	).sum;

	sig = GVerb.ar(
		sin(sig),
		revSize,
		revTime,
		revDamp
	)/2;

	sig = Mix.ar(sig) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedSoftRytmSd, { arg out = 0, amp = 0.6, pan = 0, atk = 0.01, rls = 2, impSigRate = 8, sawFreq = 3, impRevRate = 4, impRevPh = 0.5, blipFreq = 4.9, blipHarm = 7, blipAmp = 0.4, revSize = 1, revTime = 1, gate = 1, doneAction = 2;
	var sig, env, imp, rev;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	imp = Impulse;
	sig = imp.kr(impSigRate).lag * Crackle.ar(LFSaw.kr(sawFreq).abs.lag * 1.8);
	rev = GVerb.ar(
		imp.kr(impRevRate, impRevPh).lag * Blip.ar(blipFreq, blipHarm, blipAmp),
		revSize,
		revTime
	) * 5;
	sig = sig + rev;
	sig = Mix.ar(sig * env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Rimshot

SynthDef(\rimSd, { arg out = 0, amp = 0.2, pan = 0, tu = 1, envLev1 = 1, envLev2 = 0, envLev3 = 1, envLev4 = 0,  atk = 0, dcy = 0.004, rls = 0.1, gate = 1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env([envLev1, envLev2, envLev3, envLev4], [atk, dcy, rls]), gate, doneAction: doneAction);
	var enf = EnvGen.ar(Env([1600,5600,800,250],[0.001,0.001,0.001],-4));
	var enf2 = EnvGen.ar(Env([1000,1600,700,200],[0.001,0.001,0.06,0.01],-4));
	sig = SinOsc.ar(tu*400)*env;
	sig =  WhiteNoise.ar(env)+sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \hpfRq.kr(1))+sig;
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+WhiteNoise.ar(env)+BrownNoise.ar(env/8);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \lpfRq.kr(0.5))+sig;
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([enf2,enf*0.9,enf2*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(env),enf*4,1,1)+sig )*env ;
	// sig = Pan2.ar(sig*env, pan, amp);
	sig = DirtPan.ar(sig*env, ~dirt.numChannels, pan, amp);
	sig = CompanderD.ar(sig*4,0.8,0.3,0.5,0.001,0.2,env);
	OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\rimnewSd, { arg out=0, amp=0.01, pan=0, tu=1, atk = 0.0001, rls=1, freqTime1 = 0.001, freqTime2 = 0.01, gate=1, doneAction=2;
    var sig;
    var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
var frequ = EnvGen.ar(Env([1500,500,210.4],[freqTime1, freqTime2]));
    sig = SinOsc.ar(tu*frequ)*env;
    sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
    // sig = Pan2.ar(sig*env, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\rim808Sd, { arg out=0, amp=0.01, pan=0, atk = 0.001, rls=1, tu=1, tuf=1, gate=1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
	sig = SinOsc.ar(tu*400)*env;
	sig = Ringz.ar(sig,(30..35)*10.234*tuf,1).mean;
	// sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

///////////////////////////////////////  Bass

SynthDef(\bass1Sd,{arg out = 0, amp = 0.5, pan = 0, atk = 0, dcy = 8, sst = 1, rls = 4, tu = 1, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(atk, dcy, sst, rls), gate, doneAction: doneAction);
    var freq = EnvGen.ar(\freqenv.kr(Env([50, 40],[0.1, 0.3, 0.3])));
    var sig = SyncSaw.ar(freq*tu,20);
    sig = BRF.ar(sig,432,1);
    sig = HPF.ar(sig,300);
	// sig = Pan2.ar(sig.distort, pan, amp) * env;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig.distort, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\bass3Sd,{arg out=0, amp=1, pan = 0, rls = 0.1, tu = 1.54, gate = 1;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate,doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    // OffsetOut.ar(out,sig*amp*env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\bassSd,{arg out = 0, amp = 1, pan = 0, dis = 0.5, freq = 60, tu = 1, atf = 80, rls = 1, gate = 1;
    var env = EnvGen.ar(Env.adsr(0.05,0,1,rls),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([freq+1000,freq-100],[0.05,0.1]));
    var sig = LFSaw.ar(LFSaw.ar(frequ-100,0,frequ-200,frequ*tu),0,env);
    sig = CrossoverDistortion.ar(sig,dis,0.05)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.01)+sig;
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(env);
    //sig = LPF.ar(sig,100);
    sig = Compander.ar(sig,In.ar(0,1),0.05,1,0.1,0.01,0.1);
    // OffsetOut.ar(out,sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sinBassSd, { arg out = 0, gate = 1, amp = 1, pan = 0, loopNode = nil, atk = 0.2, rls = 4, curve = (-4), envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
	var freqEnv, env, sig;
	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve), gate);
	env = EnvGen.kr(Env.asr(atk, 1, rls, curve), gate, doneAction: doneAction);
	sig = SinOsc.ar(freqEnv, mul: env);
	//sig = HPF.ar(sig, 20);
	sig = BHiPass4.ar(sig, 20, 1, env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, Lag.kr(amp, 0.5)));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, Lag.kr(amp, 0.5)));
}).add;

SynthDef(\moogbasstone2Sd,{ arg out = 0, amp = 0.1, pan = 0.0, attackTime = 0.2, freq = 440, fenvamount = 0.5, cutoff =  1000, gain = 2.0, gate = 1;

	var osc, filter, env, filterenv;

	//alternative: richer source
	osc = Mix(Pulse.ar(freq.lag(0.05)*[1.0,1.001,2.0],Rand(0.45,0.5)!3,0.33));

	filterenv = EnvGen.ar(Env.adsr(attackTime,0.0,1.0,0.2),gate,doneAction:2);
	filter =  MoogFF.ar(osc,cutoff*(1.0+(fenvamount*filterenv)),gain);

	env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

	// OffsetOut.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar((0.7*filter+(0.3*filter.distort)), ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\moogBassSd, { arg out = 0, amp = 0.1, pan = 0, freq = 40, cutoff = 1000, gain = 2.0, lagamount = 0.01, atk = 0.001, dcy = 0.3, sst = 0.9, rls = 0.2, chorus = 0.7, gate = 1, doneAction = 2;
	var osc, filter, env, filterenv, snd, chorusfx;

	osc = Mix(VarSaw.ar(
		freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
		iphase: Rand(0.0,1.0) ! 3,
		width: Rand(0.5,0.75) ! 3,
		mul: 0.5));

	filterenv = EnvGen.ar(
		envelope: Env.asr(0.2, 1, 0.2),
		gate: gate);

	filter =  MoogFF.ar(
		in: osc,
		freq: cutoff * (1.0 + (0.5 * filterenv)),
		gain: gain);

	env = EnvGen.ar(
		envelope: Env.adsr(0.001, 0.3, 0.9, 0.2, amp),
		gate: gate,
		doneAction: doneAction);

	snd = (0.7 * filter + (0.3 * filter.distort)) * env;

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

SynthDef(\tweetAnaBassSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, freq = 60, ffreq = 60, tu = 9, compTresh = 0.5, gate = 1, doneAction = 2;
	var sig, env, bw;
	bw = LFNoise0.ar(_);
	sig = max(
		max(bw.(4),l=bw.(6)),
		SinOsc.ar(freq * ceil(l*tu).lag(0.1))*0.7
	);
	sig = tanh(
		BBandPass.ar(sig, ffreq, bw.(1).abs/2)*700*l.lag(1)
	);
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = sig * env;
	sig = Compander.ar(sig, sig, compTresh, 1, 1/8, 0.002);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\triangleWaveBellsSd,{ arg out = 0, amp = 1.0, pan = 0.0, atk = 0.01, dcy = 0.1, sst = 1, rls = 0.5, freq = 40, lforate = 10, lfowidth = 0.0, cutoff = 100, rq = 0.5, gate = 1, doneAction = 2;

	var osc1, osc2, vibrato, filter, env;
	vibrato = SinOsc.ar(lforate, Rand(0, 2.0));
	osc1 = Saw.ar(freq * (1.0 + (lfowidth * vibrato)), 0.75);
	osc2 = Mix(LFTri.ar((freq.cpsmidi + [11.9, 12.1]).midicps));
	filter = RHPF.ar((osc1 + (osc2 * 0.5)) * 0.5, cutoff, rq);
	env = EnvGen.ar(
		envelope: Env.adsr(atk, dcy, sst, rls, amp),
		gate: gate,
		doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(filter * env, pan));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, env));
}).add;

///////////////////////////////////////  Generative

SynthDef(\nvirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 20, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, doneAction = 2;
	var sig, env;
	// env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	// var env = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);
	sig = LocalIn.ar(2) * feedBack + Saw.ar(
		[sawFreq1, sawFreq2],
		sawAmp
	) * env;
	sig = BPF.ar(
		sig,
		bpff ** LFNoise0.kr(bpffModSpeed, bpffModAmt) * 300,
		0.1
	).distort;
	sig = CombN.ar(sig, 2, delayTime, decayTime);
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\taltersSd, { arg out = 0, pan = 0, amp = 1, doneAction = 2;
	var sig, env;
	// env = Linen.kr(gate, 0.01, 1, 10, doneAction);
	env = EnvGen.ar(Env.linen(0.01, 1, 10), doneAction: doneAction);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(i*k*k, y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(1/4**i), y.ar(0.1)+1*k+i, k*999))
		}!4).product
	}!8).sum;
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
}).add;

SynthDef(\bozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, doneAction = 2;
	var sig, env, input, ctrl;
	//env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	input = LocalIn.ar(2).tanh * feedBack;
	ctrl = Latch.kr(input[0].abs, Impulse.kr(impFreq));
	sig = Blip.ar([freq1, freq2], 100 * ctrl + 50, 0.9);
	sig = CombC.ar(
		sig,
		1,
		ctrl * delTime,
		decTime * input
	);
	LocalOut.ar(sig);
	sig = Splay.ar(sig * env, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\mcldSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 10, hpfFreq = 440, doneAction = 2;
	var sig, env, input;
	// env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	input = LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100;
	sig = DynKlank.ar(
		`[input],
		Impulse.ar(impFreq)
	);
	LocalOut.ar(sig);
	sig = HPF.ar(sig, hpfFreq).clip2;
	sig = Splay.ar(sig * env, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

// new
/*SynthDef(\rohrhuberSd, { arg out = 0, amp = 1, pan = 0, lfnFreq1 = 2, lfnFreq2 = 62, atk = 0.01, rls = 2, doneAction = 2;
	var sig, env;
	//env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	Ndef(\x, {
		SinOsc.ar(
			BrownNoise.ar(30 ! 2, 200),
			Ndef(\x).ar * LFNoise1.kr([17, 4], 1, 1)
			)
		});
	sig = Ndef(\x) * LFNoise0.kr([lfnFreq1, lfnFreq2]) * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;
*/

/* SynthDef(\padovanSd, { arg out = 0, amp = 1, pan = 0, tridDur = 1, freq = 165, roomSize = 9, doneAction = 2;
	var sig, env, input, mod, grainTr, sinMod;
	// env = Linen.kr(gate, 0.1, 1, 5, doneAction);
	env = EnvGen.ar(Env.linen(0,1, 1, 5), doneAction: doneAction);
	sig = SinOsc;
	mod = Trig.ar(
	Saw.ar(freq),
	tridDur
	);
	grainTr = sig.ar(mod * freq);
	sinMod = sig.ar(mod);
	sig = GrainIn.ar(2, grainTr, grainTr / 2, sinMod, mod * sinMod, -1, mul: env);
	sig = GVerb.ar(sig, roomSize, mul: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;
*/

/*SynthDef(\batuhanSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, tridDur = 0.125, decayTime = 0.3, sawFreq = 8, brfFreq1 = 45.1, brfFreq2 = 45, doneAction = 2;
	var sig, env, core;
	// env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	core = Duty.kr(tridDur, 0, Drand([0, Drand((0.4,0.5..1))], inf));
	sig = Decay2.kr(
		core,
		0.01,
		decayTime
	);
	sig = Saw.ar(sawFreq, sig) ** 1.5;
	sig = BRF.ar(sig, core * 20 + [brfFreq1, brfFreq2], 0.1);
	sig = LeakDC.ar(sig).tanh * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;*/

SynthDef(\lirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, gate = 1, doneAction = 0;
	var sig, env, bpf;

	env = Linen.kr(gate, atk, 1, rls, doneAction);
	//env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	sig = Ndef('x', {
		sig = Ndef('x').ar + 0.01;
		bpf = BPF.ar(sig, 6 ** Latch.ar(sig, Dust.ar(sig)) * 150, 0.2).sin;
		4.do{
			bpf = AllpassN.ar(bpf, 0.2, {0.2.rand}!2, 9)
		};
		bpf + bpf.mean;
	});
	sig = sig * env * amp * 0.1;
	OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\nozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, doneAction = 2;
	var sig, env, delayTime;
	// env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	sig = sig * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\tirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	noise = PinkNoise.ar(1!2);
	rainStep = noise + Blip.ar(noise + blipFreqMod, blipHarmo);
	rainStep = BRF.ar(
		rainStep,
		brfFreq,
		brfRq,
		0.1
	);
	thunder = LPF.ar(FreeVerb2.ar(*LPF.ar(noise + 0.2 * Dust.ar(0.1), 60) ++ [1, 1, 0.2, 1e4]).tanh, 2000);
	sig = rainStep + thunder;
	sig = sig * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\lmcdSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, atk, 1, rls, doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = sig * env;
	sig = Splay.ar(sig, 1, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\salledutempsSd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 4, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = {DynKlank.ar(`[((55/2)+ (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(55/24))))*(2**(0..8))],Crackle.ar(2,0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\salledutemps1Sd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 4, tu = 1, myst = 55, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = {DynKlank.ar(`[((myst/2)+ (tu + (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(myst/24)))))*(2**(0..8))],Crackle.ar(2, 0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cormanSd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = {DynKlank.ar(`[(tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98)))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\corman1Sd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = {DynKlank.ar(`[(tu + (tu * 52))/*Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98))))*/*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedMystSd, { arg out = 0, amp = 0.6, pan = 0, atk = 0.01, rls = 4, pNoiseFreq = 5e-3, hpfFreq = 10, modDur = 9, lfnFreq = 0.05, ringFreq = 55, ringDec = 0.2, revSize = 70, revTime = 99, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = HPF.ar(PinkNoise.ar(pNoiseFreq), hpfFreq) * Line.kr(0, 1, modDur);
	sig = GVerb.ar(
		({ |i|
			Ringz.ar(
				sig * LFNoise1.kr(lfnFreq + 0.1.rand),
				ringFreq * i + 60,
				ringDec
			)
		}!44).sum,
		revSize,
		revTime
	).tanh;
	sig = Mix.ar(sig * env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedRainSd, { arg out = 0, amp = 0.6, pan = 0, atk = 0.01, rls = 2, nFrqR = 0.08, lfnFrqR1 = 0.3, lfnFrqR2 = 0.2, lpfR = 7000, hpfR = 400, revSizeR = 250, revTimeR = 100, revDampR = 0.25, dryLevR = 0.3, modDurR = 10, lfnFrqT1 = 3, lfnFrqT2 = 2, hpfT = 20, revSizeT = 270, revTimeT = 30, revDampT = 0.7, dryLevT = 0.5, modDurT = 30, gate = 1, doneAction = 2;
	var sig, env, rain, thunder;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

	rain = PinkNoise.ar(nFrqR + LFNoise1.kr(lfnFrqR1, 0.02));
	rain = rain + LPF.ar(Dust2.ar(LFNoise1.kr(lfnFrqR2).range(40, 50)), lpfR);
	rain = tanh(
		3 * GVerb.ar(
			HPF.ar(
				rain,
				hpfR
			),
			revSizeR,
			revTimeR,
			revDampR,
			drylevel: dryLevR
		) * Line.kr(0, 1, modDurR)
	);

	thunder = 10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(lfnFrqT1).clip(0, 1) * LFNoise1.kr(lfnFrqT2).clip(0, 1) ** 1.8), hpfT);
	thunder = GVerb.ar(
		LPF.ar(
			thunder,
			LFNoise1.kr(1).exprange(100, 2500)
		).tanh,
		revSizeT,
		revTimeT,
		revDampT,
		drylevel: dryLevT
	) * Line.kr(0, 0.7, modDurT);

	sig = (rain + thunder) * env;
	sig = Mix.ar(sig);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

)
