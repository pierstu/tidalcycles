(
~lcmnoisePreset =  (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, spread: 1, GHsize: 1.6); // default
)

(
~lcmnoisePreset =  (amp: 0.1, atk: rrand(0.0005, 0.001), rls: rrand(0.2, 0.35), sustain: 1, spread: 1, GHsize: rrand(0.0001,5)); // default
)

(
Ndef(\lcmnoise, {
	var snd, revchain, env;

	env = EnvGen.kr(Env.asr(~lcmnoisePreset[\atk], 1, ~lcmnoisePreset[\rls]), timeScale: ~lcmnoisePreset[\sustain]);

	snd = [
		tanh(
			lcm(
				SinOsc.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
				).range(-100,100).round(1),
				SinOsc.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
				).range(-100,100).round(1)
			)*0.0001
		),
		tanh(
			lcm(
				Saw.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
				).range(-100,100).round(1),
				LFCub.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
				).range(-100,100).round(1)
			)*0.0001
		)
	];

	snd = BHiPass.ar(snd, 180);
	snd = snd.softclip * 0.8;
	snd = Splay.ar(snd, ~lcmnoisePreset[\spread]);
	revchain = snd * Lag.ar(
		LFPulse.ar(
			LFNoise0.ar(1).exprange(0.01,2),
			width:0.001
		),
		0.1
	) * LFNoise1.ar(1).range(10,10000);

	revchain = Greyhole.ar(
		in: revchain,
		delayTime: LFNoise1.ar(1).range(0.0001,0.2),
		damp: 0.5,
		size: LFNoise1.ar(~lcmnoisePreset[\GHsize]).exprange(0.0001,5),
		feedback: 0.95
	);
	revchain = LeakDC.ar(revchain);
	revchain = Limiter.ar(revchain) * LFNoise1.ar([1,1]).range(0,0.9);
	snd = snd * LFNoise0.ar([0.9,0.8]).range(0,2);
	snd = snd + revchain;
	//snd = Limiter.ar(snd, 0.7);
	snd = snd.softclip;
	snd = LPF.ar(snd, LFNoise1.ar(0.1).exprange(100,20000));
	snd * env * ~lcmnoisePreset[\amp];
})
)

Ndef(\lcmnoise).play(2);

Ndef(\lcmnoise).release(10);

Ndef(\lcmnoise).fadeTime_(5);

(
~ulysse42Preset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, mod1: 0.2, mod2: 0.71) // default
)

(
~ulysse42Preset = (amp: 0.1, atk: rrand(0.0005, 0.01), rls: rrand(0.12, 0.32), sustain: 1, mod1: rrand(0.05, 0.82), mod2: rrand(0.0, 1.0))
)

(
~ulysse42Preset = ( 'rls': 0.30146820068359, 'mod2': 0.098270654678345, 'atk': 0.0054233431816101, 'mod1': 0.7239332151413,
  'amp': 0.1, 'sustain': 1 ) // long gate
)

(
Ndef(\ulysse42, {
	var mod1, sig, sig1, sig2, sig3, z1, z2, sinFrq, env;

	env = EnvGen.kr(Env.asr(~ulysse42Preset[\atk], 1, ~ulysse42Preset[\rls]), timeScale: ~ulysse42Preset[\sustain]);

	mod1 = ~ulysse42Preset[\mod1].linlin(0, 1, -10, 10) * Ndef.ar(\mod2);
	sig1 =  LFSaw.kr(0.062).range(-10, 10);
	sig1 =  sig1 + (~ulysse42Preset[\mod2].linlin(0, 1, 0, 5) * (0..8));
	sig2 = sig1.frac;
	sig3 = 0.8 - sig2.moddif(0.5, 1);

	z1 = gcd(sig1, mod1) +  sig2;
	z2 = lcm(sig1, mod1) + sig2;
	// sinFrq = 120 * ([z1, z2].flop.abs + 1);
	sinFrq = 132 * ([z1, z2].flop.abs + 1);


	sig = (SinOsc.ar(sinFrq) * AmpComp.kr(sinFrq) * sig3).mean;
	sig * env * ~ulysse42Preset[\amp];
})
);


Ndef.ar(\mod2) *

Ndef(\ulysse42).play(2);

Ndef(\ulysse42).release(10);

Ndef(\ulysse42).fadeTime_(28);

(
~mod1Preset = (freq: 500.0, mul: 1.0, add: 0.0) // default
)

(
~mod1Preset = (freq: rrand(1, 500.0), mul: rrand(0.3, 1.0), add: 0.0)
)

Ndef(\mod1, { LFNoise1.ar(~mod1Preset[\freq], ~mod1Preset[\mul], ~mod1Preset[\add]) });

Ndef(\mod1).fadeTime = 8;

(
~mod2Preset = (freq: 440, width: 0.5, mul: 1, add: 0); // default
)

(
~mod2Preset = (freq: rrand(5,210), width: rrand(0.01, 0.5), mul: rrand(0.4,0.6), add: 0); // rrand
)

Ndef(\mod2, {Pulse.ar(~mod2Preset[\freq], ~mod2Preset[\width], ~mod2Preset[\mul], ~mod2Preset[\add]) * Ndef.ar(\mod1)});

Ndef(\mod2).fadeTime_(4);

// ajout 0804

(
// syntaxe event
~raisonnePreset = (amp: 0.6, atk: 0, dcy: 8, stn: 1, rls: 4, frq: 40, bwr: 0.001);
// default
)

// pourquoi ne sort que sur la gauche? mystère à résoudre
(
Ndef(\raisonne,{
	// arg out = 0, amp = 1, pan = 0, atk = 0, dcy = 8, stn = 1, rls = 4, frq = 40, bwr = 0.001, gate = 1, doneAction = 2;
	var sig, n, env;
	env = EnvGen.kr(Env.adsr(~raisonnePreset[\atk], ~raisonnePreset[\dcy], ~raisonnePreset[\stn], ~raisonnePreset[\rls]));
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), ~raisonnePreset[\frq] * (i + 1), ~raisonnePreset[\bwr], 300)}) * n.reciprocal; // scale to ensure no clipping
	// sig = Pan2.ar(sig, pan, amp) * env;
	sig * ~raisonnePreset[\amp] * env;
	// OffsetOut.ar(out, sig);
})
)

Ndef(\raisonne).play(2);

Ndef(\raisonne).release(6);

SynthDef(\raisonne,{ arg out = 0, amp = 1, pan = 0, atk = 0, dcy = 8, stn = 1, rls = 4, frq = 40, bwr = 0.001, gate = 1, doneAction = 2;
	var sig, n, env;
    env = EnvGen.kr(Env.adsr(atk, dcy, stn, rls), gate, doneAction: doneAction);
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), frq * (i + 1), bwr, 300)}) * n.reciprocal; // scale to ensure no clipping
	sig = Pan2.ar(sig, pan, amp) * env;
    OffsetOut.ar(out, sig);
}).add;


// a faire plus tard
SynthDef(\west, {
	arg out = 0, pan=0, fadeIn=0.01, fadeOut=0.01, freq = 220, pitchBendRatio = 1, glide = 0, fm1Ratio = 0.66, fm2Ratio = 3.3, fm1Amount = 0.0, fm2Amount = 0.0,
	vel = 0.7, pressure = 0, timbre = 0, waveShape = 0, waveFolds = 0, envType = 0, attack = 0.04, peak = 10000, decay = 1, amp = 1, lfoShape = 0, lfoFreq = 0.5,
	lfoToFreqAmount = 0, lfoToWaveShapeAmount = 0, lfoToWaveFoldsAmount = 0, lfoToFm1Amount = 0, lfoToFm2Amount = 0,
	lfoToAttackAmount = 0, lfoToPeakAmount = 0, lfoToDecayAmount = 0, lfoToReverbMixAmount = 0, drift = 0, dur=10, t_gate=1, gate=1, killGate=1, doneAction = 2;

	var i_nyquist = SampleRate.ir * 0.5, signal, controlLag = 0.005, i_numHarmonics = 44,
	modFreq, mod1, mod2, mod1Index, mod2Index, mod1Freq, mod2Freq, sinOsc, triOsc, additiveOsc, additivePhase,
	filterEnvVel, filterEnvLow, lpgEnvelope, lpgSignal, asrEnvelope, asrFilterFreq, asrSignal, killEnvelope, i_driftRate = 0.15, maxDecay=8;

	// Make lfos
	var lfo = Select.kr(lfoShape, [
		LFTri.kr(lfoFreq),
		LFSaw.kr(lfoFreq),
		LFPulse.kr(lfoFreq),
		LFDNoise0.kr(lfoFreq * 2)
	]);

	var lfoArray = Array.fill(9, 0);
	lfoArray[0] = (lfo * lfoToFreqAmount * 18).midiratio; // Freq ratio
	lfoArray[1] = (lfo * lfoToWaveShapeAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Wave Shape
	lfoArray[2] = ((lfo * lfoToWaveFoldsAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2; // Wave Folds
	lfoArray[3] = ((lfo * lfoToFm1Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM1 Amount
	lfoArray[4] = ((lfo * lfoToFm2Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM2 Amount
	lfoArray[5] = ((lfo * lfoToAttackAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Attack
	lfoArray[6] = (((lfo * lfoToPeakAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 24).midiratio; // Peak multiplier
	lfoArray[7] = ((lfo * lfoToDecayAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Decay
	lfoArray[8] = (lfo * lfoToReverbMixAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Reverb Mix


	// LFO ins
	freq = (freq * lfoArray[0]).clip(0, i_nyquist);
	waveShape = (waveShape + lfoArray[1]).clip(0, 1);
	waveFolds = (waveFolds + lfoArray[2]).clip(0, 3);
	fm1Amount = (fm1Amount + lfoArray[3]).clip(0, 1);
	fm2Amount = (fm2Amount + lfoArray[4]).clip(0, 1);
	attack = (attack + lfoArray[5]).clip(0.003, 8);
	peak = (peak * lfoArray[6]).clip(100, 10000);
	decay = (decay + lfoArray[7]).clip(0.01, maxDecay);

	// Lag inputs
	freq = Lag.kr(freq * pitchBendRatio, 0.007 + glide);
	fm1Ratio = Lag.kr(fm1Ratio, controlLag);
	fm2Ratio = Lag.kr(fm2Ratio, controlLag);
	fm1Amount = Lag.kr(fm1Amount.squared, controlLag);
	fm2Amount = Lag.kr(fm2Amount.squared, controlLag);

	vel = Lag.kr(vel, controlLag);
	waveShape = Lag.kr(waveShape, controlLag);
	waveFolds = Lag.kr(waveFolds, controlLag);
	attack = Lag.kr(attack, controlLag);
	peak = Lag.kr(peak, controlLag);
	decay = Lag.kr(decay, controlLag);

	// Modulators
	mod1Index = fm1Amount * 22;
	mod1Freq = freq * fm1Ratio * LFNoise2.kr(freq: 0.1, mul: 0.001, add: 1);
	mod1 = SinOsc.ar(freq: mod1Freq, phase: 0, mul: mod1Index * mod1Freq, add: 0);
	mod2Index = fm2Amount * 12;
	mod2Freq = freq * fm2Ratio * LFNoise2.kr(freq: 0.1, mul: 0.005, add: 1);
	mod2 = SinOsc.ar(freq: mod2Freq, phase: 0, mul: mod2Index * mod2Freq, add: 0);
	modFreq = freq + mod1 + mod2;

	// Sine and triangle
	sinOsc = SinOsc.ar(freq: modFreq, phase: 0, mul: 0.5);
	triOsc = VarSaw.ar(freq: modFreq, iphase: 0, width: 0.5, mul: 0.5);

	// Additive square and saw
	additivePhase = LFSaw.ar(freq: modFreq, iphase: 1, mul: pi, add: pi);
	additiveOsc = Mix.fill(i_numHarmonics, {
		arg index;
		var harmonic, harmonicFreq, harmonicCutoff, attenuation;

		harmonic = index + 1;
		harmonicFreq = freq * harmonic;
		harmonicCutoff = i_nyquist - harmonicFreq;

		// Attenuate harmonics that will go over nyquist once FM is applied
		attenuation = Select.kr(index, [1, // Save the fundamental
			(harmonicCutoff - (harmonicFreq * 0.25) - harmonicFreq).expexp(0.000001, harmonicFreq * 0.5, 0.000001, 1)]);

		(sin(additivePhase * harmonic % 2pi) / harmonic) * attenuation * (harmonic % 2 + waveShape.linlin(0.666666, 1, 0, 1)).min(1);
	}
	);

	// Mix carriers
	signal = LinSelectX.ar(waveShape * 3, [sinOsc, triOsc, additiveOsc]);

	// Fold
	signal = Fold.ar(in: signal * (1 + (timbre * 0.5) + (waveFolds * 2)), lo: -0.5, hi: 0.5);

	// Hack away some aliasing
	signal = LPF.ar(in: signal, freq: 12000);

	// Noise
	signal = signal + PinkNoise.ar(mul: 0.003);

	// LPG
	filterEnvVel = vel.linlin(0, 1, 0.5, 1);
	filterEnvLow = (peak * filterEnvVel).min(300);

	lpgEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.003, decay], curve: [4, -20]), gate: t_gate, timeScale: dur);
	lpgSignal = RLPF.ar(in: signal, freq: lpgEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel), rq: 0.9);
	lpgSignal = lpgSignal * EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.002, decay], curve: [4, -10]), gate: t_gate, timeScale: dur);

	// ASR with 4-pole filter
	asrEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [attack, decay], curve: -4, releaseNode: 1), gate: gate);
	asrFilterFreq = asrEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel);
	asrSignal = RLPF.ar(in: signal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = RLPF.ar(in: asrSignal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = asrSignal * EnvGen.ar(envelope: Env.asr(attackTime: attack, sustainLevel: 1, releaseTime: decay, curve: -4), gate: gate);

	signal = Select.ar(envType, [lpgSignal, asrSignal]);

	signal = signal * vel.linlin(0, 1, 0.2, 1) ;

	// Saturation amp
	signal = tanh(signal * pressure.linlin(0, 1, 1.5, 3) * amp).softclip;

	// main Envelope
	signal = signal * EnvGen.kr(
		Env([0.0,1.0,1.0,0], [fadeIn, fadeOut], releaseNode: 2),
		gate: killGate,
		doneAction: doneAction
	);

	// Pan
	signal = Pan2.ar(signal, pan);

	OffsetOut.ar(out, signal);

}).add;



SynthDef(\bigraph, { arg out = 0, amp = 0.2, pan = 0, atk = 0.0001, dcy = 0.1, stn = 1, rls = 2, crv = (-12), envPow = 1, trig1Freq = 0, trig2Freq = 0, modulo1 = 128, modulo2Freq = 3, modulo2Mul = 9, modulo2Offset = 99, noteOffset = 33, srcFreq = 9, modPhaseMul = 3.1415926535898, gate = 1, doneAction = 2;
    var sig, modPhase, env, trig1, trig2;
    env = EnvGen.kr(Env.adsr(atk, dcy, stn, rls, curve: crv), gate, doneAction: doneAction).pow(envPow);
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
    sig = (SinOsc.ar(srcFreq, modPhase) / 3) * env;
    sig = Pan2.ar(Splay.ar(sig), pan, amp);
    OffsetOut.ar(out, sig);
}).add;