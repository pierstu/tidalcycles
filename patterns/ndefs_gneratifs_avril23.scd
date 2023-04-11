(
~lcmnoisePreset =  (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, spread: 1, GHsize: 1.6); // default
)

(
~lcmnoisePreset =  (amp: 0.1, atk: rrand(0.0005, 0.001), rls: rrand(0.2, 0.35), sustain: 1, spread: 1, GHsize: rrand(0.0001,5)); // rrand
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
~raisonnePreset = (amp: 1, atk: 0, dcy: 8, stn: 1, rls: 4, frq: 40, bwr: 0.001);
// default
)

(
~raisonnePreset = ( 'bwr': 0.004189851512312889, 'atk': 0.000175008106231689, 'dcy': 6.7661636948586, 'stn': 1, 'amp': 1, 'rls': 2.7912724018097, 'frq': 51 )
)

(
~raisonnePreset = ( 'bwr': 0.0065117617845535, 'atk': 0.00088335227966309, 'dcy': 9.3432914495468, 'stn': 1, 'amp': 1, 'rls': 4.8408409953117, 'frq': 68 )
)

(
~raisonnePreset = (amp:1, atk: rrand(0.0, 0.02), dcy: rrand(4.3, 8), stn: 1, rls: rrand(2.5, 5), frq: rrand(30, 90), bwr: rrand(0.0005, 0.01));
// rrand
)


// pourquoi ne sort que sur la gauche? mystère à résoudre
(
Ndef(\raisonne,{
	// arg out = 0, amp = 1, pan = 0, atk = 0, dcy = 8, stn = 1, rls = 4, frq = 40, bwr = 0.001, gate = 1, doneAction = 2;
	var sig, n, env;
	env = EnvGen.kr(Env.adsr(~raisonnePreset[\atk], ~raisonnePreset[\dcy], ~raisonnePreset[\stn], ~raisonnePreset[\rls]));
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), ~raisonnePreset[\frq] * (i + 1), ~raisonnePreset[\bwr], 300)}) * n.reciprocal; // scale to ensure no clipping
	sig = (sig * ~raisonnePreset[\amp] * env);
	// sig * ~raisonnePreset[\amp] * env;
	// OffsetOut.ar(out, sig);
})
)

Ndef(\raisonne).play(2);

Ndef(\raisonne).release(6);

Ndef(\raisonne).fadeTime_(8);


// ok
(
~bigraphPreset = ( 'crv': -12, 'atk': 6.8707007169724e-05, 'trig1Freq': 0.045016779899597, 'amp': 0.1, 'modulo2Offset': 96, 'dcy': 0.071771189570427, 'modulo1': 128, 'noteOffset': 30, 'envPow': 0.7401768684387, 'modulo2Mul': 5.7536766052246, 'modulo2Freq': 1.8303462028503, 'stn': 1, 'trig2Freq': 0.054256244897842, 'rls': 1.8505662679672, 'srcFreq': 14, 'modPhaseMul': 2.2369314063435 )
)


(
~bigraphPreset = (amp: 0.1, atk: 0.0001, dcy: 0.1, stn: 1, rls: 2, crv: (-12), envPow: 1, trig1Freq: 0, trig2Freq: 0, modulo1: 128, modulo2Freq: 3, modulo2Mul: 9, modulo2Offset: 99, noteOffset: 33, srcFreq: 9, modPhaseMul: 3.1415926535898);
) // default

(
~bigraphPreset = ( 'crv': -12, 'atk': 8.2314211130142e-05, 'trig1Freq': 0.067522730827332, 'amp': 0.1, 'modulo2Offset': 43, 'dcy': 0.074790847301483, 'modulo1': 128, 'noteOffset': 53, 'envPow': 0.67135314583778, 'modulo2Mul': 1.8178494691849, 'modulo2Freq': 0.7831169128418, 'stn': 1, 'trig2Freq': 0.16879383325577, 'rls': 1.9973884224892, 'srcFreq': 67, 'modPhaseMul': 2.8165145701781 )
)


(
~bigraphPreset = ( 'crv': -12, 'atk': 9.4498956203461e-05, 'trig1Freq': 2.34856629371643, 'amp': 0.1, 'modulo2Offset': 87, 'dcy': 0.2085665157437325, 'modulo1': 128, 'noteOffset': 39, 'envPow': 0.8292261826992, 'modulo2Mul': 5.8483431577682, 'modulo2Freq': 2.3814787745476, 'stn': 1, 'trig2Freq': 0.18152314662933, 'rls': 1.8441705107689, 'srcFreq': 39, 'modPhaseMul': 3.9519720880263 )
)

(
~bigraphPreset = (amp: 0.1, atk: rrand(0.00005, 0.0001), dcy: rrand(0.025, 0.1), stn: 1, rls: rrand(1.5, 2), crv: (-12), envPow: rrand(0.01, 1), trig1Freq: rrand(0, 0.120), trig2Freq: rrand(0,0.17), modulo1: 128, modulo2Freq: rrand(0.1,3), modulo2Mul: rrand(0.8,9), modulo2Offset: rrand(12,99), noteOffset: rrand(12,53), srcFreq: rrand(4,89), modPhaseMul: rrand(1.12, 3.1415926535898));
)

(
Ndef(\bigraph, {
	// arg out = 0, amp = 0.2, pan = 0, atk = 0.0001, dcy = 0.1, stn = 1, rls = 2, crv = (-12), envPow = 1, trig1Freq = 0, trig2Freq = 0, modulo1 = 128, modulo2Freq = 3, modulo2Mul = 9, modulo2Offset = 99, noteOffset = 33, srcFreq = 9, modPhaseMul = 3.1415926535898, gate = 1, doneAction = 2;
    var sig, modPhase, env, trig1, trig2;
	env = EnvGen.kr(Env.adsr(~bigraphPreset[\atk], ~bigraphPreset[\dcy], ~bigraphPreset[\stn], ~bigraphPreset[\rls], curve: ~bigraphPreset[\crv])).pow(~bigraphPreset[\envPow]);
		trig1 = Impulse.kr(~bigraphPreset[\trig1Freq]);
		trig2 = Impulse.kr(~bigraphPreset[\trig2Freq]);
    modPhase = SinOsc.ar(
        midicps(
            (
					Sweep.ar(trig1, (33..3)) % ~bigraphPreset[\modulo1] & (Sweep.ar(trig2, (3..9)) % (LFSaw.ar(~bigraphPreset[\modulo2Freq]) * ~bigraphPreset[\modulo2Mul] + ~bigraphPreset[\modulo2Offset]))
				) + ~bigraphPreset[\noteOffset]
        ),
        0,
			~bigraphPreset[\modPhaseMul]
    );
		sig = (SinOsc.ar(~bigraphPreset[\srcFreq], modPhase) / 3) * env;
	sig = (Splay.ar(sig) * ~bigraphPreset[\amp]);
		// OffsetOut.ar(out, sig);
});
)

Ndef(\bigraph).play(2);

Ndef(\bigraph).release(8);

Ndef(\bigraph).fadeTime_(8);

// fonctionne
(
~modelAixPreset = ( 'atk': 0.0010641890645027, 'pan': 0, 'revtSel': 1, 'out': 2, 'amp': 0.1, 'rls': 0.25551299858093, 'sustain': 1 )
)


(
~modelAixPreset = (out: 2, amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, revtSel: 0)
) // default

(
~modelAixPreset = ( 'atk': 0.00071098121404648, 'revtSel': 1, 'out': 2, 'amp': 0.1, 'rls': 0.16832694339752, 'sustain': 1 )
)

(
~modelAixPreset = ( 'atk': 0.0008523430109024, 'pan': 0, 'revtSel': 0, 'out': 2, 'amp': 0.1, 'rls': 0.16422292542458, 'sustain': 1 )
)

(
~modelAixPreset = (out: 2, amp: 0.1, pan: 0, atk: rrand(0.0005, 0.0012), rls: rrand(0.162, 0.3), sustain: 1, revtSel: rrand(0,1))
) // rrand

(
Ndef(\modelAix, {
	// arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, revtSel = 0, gate = 1, doneAction = 2;
	var snd, revt, revt1, revt2, revt3, env;

	env = EnvGen.kr(Env.asr(~modelAixPreset[\atk], 1, ~modelAixPreset[\rls]), timeScale: ~modelAixPreset[\sustain]);

	snd = Pulse.ar(freq: LFNoise0.ar([2,3]).exprange(50,5000));
	snd = snd * LFPulse.ar(
		freq: LFNoise0.ar(1).exprange(0.5,8),
		width:0.02,
		mul: LFNoise1.ar(3).exprange(0.01,1000));
	snd = HPF.ar(snd, 50);

	// reverb time - various optons:
	revt1 = LFNoise0.ar(1).exprange(0.0001, 0.01);
	revt2 = LFTri.ar(0.0165, -1).exprange(1, 0.0001);
	revt3 = LFTri.ar(1/10, 1).range(0.01, 0.0001);

	revt = Select.ar(~modelAixPreset[\revtSel], [revt1, revt2, revt3, K2A.ar(0.000001)]);
	snd = Greyhole.ar(snd, revt, 0.5, revt);
	snd = Limiter.ar(snd, 0.9);
	snd = (snd * env * ~modelAixPreset[\amp]);
	// OffsetOut.ar(out, snd);
});
)

Ndef(\modelAix).play(2);

Ndef(\modelAix).release(8);

Ndef(\modelAix).fadeTime_(9);

(
~dannySimplePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, add1: 0, add2: 0, div1: 0.03, div2: 5, rng1Lo: (-3), rng1Hi: 2, rng2Lo: (-2), rng2Hi: 3 )
// default
)

(
~dannySimplePreset = ( 'rls': 0.2763254404068, 'rng1Hi': 1.9994381666183, 'div2': 6, 'add2': 1.1983327865601,
  'rng2Hi': 1.7402127385139, 'rng2Lo': -2, 'add1': 27, 'div1': 0.035431569814682, 'atk': 0.0008384296298027,
  'rng1Lo': -3, 'amp': 0.1, 'sustain': 1 )
)

(
~dannySimplePreset = (amp: 0.1, atk: rrand(0.0005,0.001), rls: rrand(0.2, 0.4), sustain: 1, add1: rrand(0, 30), add2: rrand(0, 4.0), div1: rrand(0.03, 0.3), div2: rrand(5, 8), rng1Lo: (-3), rng1Hi: rrand(1.0,2), rng2Lo: (-2), rng2Hi: rrand(1.5,3) )
// rrand
)

(
~dannySimplePreset = ( 'rls': 0.39076561927795, 'rng1Hi': 1.0371713638306, 'div2': 7, 'add2': 1.2977290153503,
  'rng2Hi': 2.2433305978775, 'rng2Lo': -2, 'add1': 23, 'div1': 0.14185033679008, 'atk': 0.0007648029923439,
  'rng1Lo': -3, 'amp': 0.1, 'sustain': 1 )
)

(
~dannySimplePreset = ( 'rls': 0.34209322929382, 'rng1Hi': 1.363156080246, 'div2': 7, 'add2': 3.1031847000122,
  'rng2Hi': 2.9404816031456, 'rng2Lo': -2, 'add1': 6, 'div1': 0.23246762037277, 'atk': 0.00096376663446426,
  'rng1Lo': -3, 'amp': 0.1, 'sustain': 1 )
)

(
Ndef(\dannySimple, {
	// arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, add1 = 0, add2 = 0, div1 = 0.03, div2 = 5, rng1Lo = (-3), rng1Hi = 2, rng2Lo = (-2), rng2Hi = 3, gate = 1, doneAction = 2;
	var sig, sig1, sig2, env, thr, frq1, frq2;

	thr = 0.03;
	env = EnvGen.kr(Env.asr(~dannySimplePreset[\atk], 1, ~dannySimplePreset[\rls]), timeScale: ~dannySimplePreset[\sustain]);

	frq1 = \freq1.kr(#[5, 6, 7, 8]);
	frq2 = \freq2.kr(#[ 3, 4, 5, 6, 7 ]);

	sig1 = SinOsc.ar(frq1 + ~dannySimplePreset[\add1] / ~dannySimplePreset[\div1]).range(~dannySimplePreset[\rng1Lo], ~dannySimplePreset[\rng1Hi]);
	sig2 = SinOsc.ar(frq2 + ~dannySimplePreset[\add2] / ~dannySimplePreset[\div2]).range(~dannySimplePreset[\rng2Lo], ~dannySimplePreset[\rng2Hi]);

	sig = gcd(sig1.product.round(1), sig2.round(1));
	sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
	sig = (sig * env * ~dannySimplePreset[\amp]);
}).add;
)

Ndef(\dannySimple).play(2);

Ndef(\dannySimple).release(10);

Ndef(\dannySimple).fadeTime_(19);

// fonctionne
(
~dannySimplePreset = ( 'add2': 607, 'pan': 0, 'rng1Lo': -3.3587653636932, 'rng2Lo': -4, 'amp': 0.51, 'sustain': 1, 'atk': 0.0026928461182117, 'rng1Hi': 2.1515865325928, 'div2': 28, 'add1': 698, 'div1': 37, 'out': 2, 'rng2Hi': 4, 'rls': 0.13813012003899 )
)

(
~dannySimple1Preset = (out: 2, amp: 0.4, pan: 0, atk: 0.001, rls: 0.2, sustain: 1, add1: 970, add2: 1030, div1: 30, div2: 30, rng1Lo: (-4), rng1Hi: 4, rng2Lo: (-4), rng2Hi: 4)
// default
)

(
~dannySimple1Preset = ( 'add2': 1559, 'pan': 0, 'rng1Lo': -2.1913464546204, 'rng2Lo': (-4),
  'amp': 0.51, 'sustain': 1, 'atk': 0.0090056415855885, 'rng1Hi': 1.8232978820801, 'div2': 35,
  'add1': 1087, 'div1': 16, 'out': 2, 'rng2Hi': 4, 'rls': 0.12155921936035 )
)

(
~dannySimple1Preset = ( 'add2': 1215, 'pan': 0, 'rng1Lo': -1.9456105232239, 'rng2Lo': (-4),
  'amp': 0.51, 'sustain': 1, 'atk': 0.0064284901106358, 'rng1Hi': 1.6333084106445, 'div2': 20,
  'add1': 1666, 'div1': 16, 'out': 2, 'rng2Hi': 4, 'rls': 0.14686702728271 )
)

(
~dannySimple1Preset = (out: 2, amp: 0.51, pan: 0, atk: rrand(0.00051,0.01), rls: rrand(0.1,0.23), sustain: 1, add1: rrand(430, 1970), add2: rrand(230, 1930), div1: rrand(15, 50), div2: rrand(20,35), rng1Lo: rrand(-4, -1.2), rng1Hi: rrand(1.3, 4.5) , rng2Lo: (-4), rng2Hi: 4)
// rrand
)

(
Ndef(\dannySimple1, {
	// arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, add1 = 970, add2 = 1030, div1 = 30, div2 = 30, rng1Lo = (-4), rng1Hi = 4, rng2Lo = (-4), rng2Hi = 4, gate = 1, doneAction = 2;
	var sig, sig1, sig2, env, thr, frq1, frq2;

	thr = 0.03;
	env = EnvGen.kr(Env.asr(~dannySimple1Preset[\atk], 1, ~dannySimple1Preset[\rls]), timeScale: ~dannySimple1Preset[\sustain]);

	frq1 = \freq1.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
	frq2 = \freq2.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

	sig1 = SinOsc.ar(frq1 + ~dannySimple1Preset[\add1] / ~dannySimple1Preset[\div1]).range(~dannySimple1Preset[\rng1Lo], ~dannySimple1Preset[\rng1Hi]);
	sig2 = SinOsc.ar(frq2 + ~dannySimple1Preset[\add2] / ~dannySimple1Preset[\div2]).range(~dannySimple1Preset[\rng2Lo], ~dannySimple1Preset[\rng2Hi]);

	sig = gcd(sig1.product.round(1), sig2.round(1));
	sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
	sig = (sig * env * ~dannySimple1Preset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\dannySimple1).play(2);

Ndef(\dannySimple1).release(10);

Ndef(\dannySimple1).fadeTime_(18);


(
~gcdGenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, sig1Frq: 0.02, sig2Frq: 1.24, dev: 0.1, mod: 30)
// default
)

(
~gcdGenePreset = ( 'sig1Frq': 0.084199857711792, 'dev': 0.11412018537521, 'atk': 0.020571499824524, 'amp': 0.1, 'sustain': 1, 'sig2Frq': 1.8425592184067, 'rls': 0.13843827724457, 'mod': 33.63659992218 )
)

(
~gcdGenePreset = ( 'sig1Frq': 0.031851263046265, 'dev': 0.17276584506035, 'atk': 0.068906693696976, 'amp': 0.1, 'sustain': 1, 'sig2Frq': 1.4190643310547, 'rls': 0.12680888414383, 'mod': 30.971354675293 )
)


(
~gcdGenePreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.12, 0.3), sustain: 1, sig1Frq: rrand(0.02, 0.1), sig2Frq: rrand(1.24, 2), dev: rrand(0.1, 0.25), mod: rrand(30, 41.2))
// rrand
)

(
Ndef(\gcdGene, {
	// arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 0.02, sig2Frq = 1.24, dev = 0.1, mod = 30, gate = 1, doneAction = 2;
	var sig, sig1, sig2, env;

	env = EnvGen.kr(Env.asr(~gcdGenePreset[\atk], 1, ~gcdGenePreset[\rls]), timeScale: ~gcdGenePreset[\sustain]);

	sig1 = LFSaw.ar(~gcdGenePreset[\sig1Frq]) * 300 + 1;
	sig2 = LFSaw.ar(~gcdGenePreset[\sig2Frq] + [0, ~gcdGenePreset[\dev]]) * 200 + 1;

	sig = SinOsc.ar(gcd(sig1, sig2) * ~gcdGenePreset[\mod] + 300);

	sig = sig * env;
	sig = (sig * ~gcdGenePreset[\amp]);
	// OffsetOut.ar(out, sig);
}).add;
)


Ndef(\gcdGene).play(2);

Ndef(\gcdGene).release(8);

Ndef(\gcdGene).fadeTime_(19);

(
~gcdDmGenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, sig1Frq: 3000, sig2Frq: 2995, mod1: 100, mod2: 100, dev: 25)
// default
)

(
~gcdDmGenePreset = ( 'mod1': 127, 'sig2Frq': 2356, 'mod2': 52, 'dev': 13,
  'rls': 0.389476776123, 'amp': 0.1, 'atk': 0.0076756017446518,  'sig1Frq': 825,
  'sustain': 1 )
)

(
~gcdDmGenePreset = ( 'mod1': 77, 'sig2Frq': 1356, 'mod2': 122, 'dev': 23,
  'rls': 0.2389476776123, 'amp': 0.1, 'atk': 0.076756017446518, 'pan': 0, 'sig1Frq': 3225,
  'sustain': 1 )
)

(
~gcdDmGenePreset = (amp: 0.1, pan: 0, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, sig1Frq: rrand(500, 3000), sig2Frq: rrand(300, 2995), mod1: rrand(30, 100), mod2: rrand(100, 140), dev: rrand(10, 25))
// rrand
)

(
Ndef(\gcdDmGene, {
	// arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 3000, sig2Frq = 2995, mod1 = 100, mod2 = 100, dev = 25, gate = 1, doneAction = 2;
	var sig, sig1, sig2, env;

	env = EnvGen.kr(Env.asr(~gcdDmGenePreset[\atk], 1, ~gcdDmGenePreset[\rls]), timeScale: ~gcdDmGenePreset[\sustain]);

	sig1 = PulseCount.ar(Impulse.ar(~gcdDmGenePreset[\sig1Frq])) % ~gcdDmGenePreset[\mod1];
	sig2 = PulseCount.ar(Impulse.ar(~gcdDmGenePreset[\sig2Frq])) % ~gcdDmGenePreset[\mod2];

	sig = gcd(sig1, sig2 + [30, ~gcdDmGenePreset[\dev]]);
	sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

	sig = sig * env;
	sig = (sig * ~gcdDmGenePreset[\amp]);
	// OffsetOut.ar(out, sig);
}).add;
)

Ndef(\gcdDmGene).play(2);

Ndef(\gcdDmGene).release(9);

Ndef(\gcdDmGene).fadeTime_(29);


(
// default
~gcdDm2GenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, sig1Frq: 3000, sig2Frq: 2995, mod1: 20, mod2: 20, dev1: 3, dev2: 7);
)

(
~gcdDm2GenePreset = ( 'mod1': 50, 'sig2Frq': 5260, 'mod2': 41, 'dev2': 6.611711025238, 'dev1': 1.9007163047791, 'rls': 0.48945752382278, 'amp': 0.1, 'atk': 0.095970043182373, 'sig1Frq': 4133,  'sustain': 1 )
)

(
~gcdDm2GenePreset = ( 'mod1': 27, 'sig2Frq': 1492, 'mod2': 54, 'dev2': 8.2843285799026,  'dev1': 2.2288902401924, 'rls': 0.41433293819427, 'amp': 0.1, 'atk': 0.084589762926102, 'sig1Frq': 7338, 'sustain': 1 )
)

(
~gcdDm2GenePreset = ( 'mod1': 17, 'sig2Frq': 7492, 'mod2': 24, 'dev2': 8.2843285799026,  'dev1': 2.2288902401924, 'rls': 0.21433293819427, 'amp': 0.1, 'atk': 0.0184589762926102, 'sig1Frq': 1338, 'sustain': 1 )
)

(
// rrand
~gcdDm2GenePreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, sig1Frq: rrand(3000, 8000), sig2Frq: rrand(1500, 8995), mod1: rrand(20, 60), mod2: rrand(15, 60), dev1: rrand(0.5, 3), dev2: rrand(5.5, 9));
)

(
Ndef(\gcdDm2Gene, {
	/*amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 3000, sig2Frq = 2995, mod1 = 20, mod2 = 20, dev1 = 3, dev2 = 7;*/
	var sig, sig1, sig2, env;

	env = EnvGen.kr(Env.asr(~gcdDm2GenePreset[\atk], 1, ~gcdDm2GenePreset[\rls]), timeScale: ~gcdDm2GenePreset[\sustain]);

	sig1 = PulseCount.ar(TDuty.ar(Dseq((1..20), inf) + 41 * SampleDur.ir))
	% ~gcdDm2GenePreset[\mod1];
	sig2 = PulseCount.ar(TDuty.ar(Dseq((21..1), inf) + 40 * SampleDur.ir);)
	% ~gcdDm2GenePreset[\mod2];

	sig = gcd(sig1, sig2 + [~gcdDm2GenePreset[\dev1], ~gcdDm2GenePreset[\dev2]]);
	sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

	sig = sig * env;
	sig = (sig * ~gcdDm2GenePreset[\amp]);
	// OffsetOut.ar(out, sig);
})
)

Ndef(\gcdDm2Gene).play(2);

Ndef(\gcdDm2Gene).fadeTime_(22);

Ndef(\gcdDm2Gene).release(10);


(
~gcdDm3GenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, sig1Size: 10, sig2Size: 10, sig3Size: 10, add1: 102, add2: 101, add3: 100, mod1: 100, mod2: 101, mod3: 102, dev1: 10, dev2: 20);
// default
)

(
~gcdDm3GenePreset = ( 'atk': 0.06398223733902, 'dev1': 9, 'sig1Size': 8.2920808792114, 'add1': 93, 'mod2': 42, 'amp': 0.1, 'mod3': 92, 'sig2Size': 9, 'add2': 94, 'add3': 86, 'dev2': 20, 'mod1': 95, 'sig3Size': 11, 'rls': 0.21757351160049,  'sustain': 1 )
)

(
~gcdDm3GenePreset = ( 'atk': 0.014672823309898, 'dev1': 9, 'sig1Size': 9.0137581825256, 'add1': 82, 'mod2': 92, 'amp': 0.1, 'mod3': 49, 'sig2Size': 9, 'add2': 79,   'add3': 88, 'dev2': 22, 'mod1': 60, 'sig3Size': 10, 'rls': 0.40523991584778, 'sustain': 1 )
)

(
~gcdDm3GenePreset = ( 'atk': 0.09078190100193, 'dev1': 10, 'sig1Size': 7.770126760006, 'add1': 99, 'mod2': 46, 'amp': 0.1, 'mod3': 101, 'sig2Size': 9, 'add2': 75,   'add3': 75, 'dev2': 21, 'mod1': 92, 'sig3Size': 8, 'rls': 0.2850227355957, 'sustain': 1 )
)

(
~gcdDm3GenePreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, sig1Size: rrand(5.5, 10), sig2Size: rrand(8, 10), sig3Size: rrand(8, 11), add1: rrand(80, 102), add2: rrand(60, 100), add3: rrand(75, 90), mod1: rrand(40, 100), mod2: rrand(30, 101), mod3: rrand(42, 102), dev1: rrand(8, 10), dev2: rrand(15, 25));
// rrand
)


(
Ndef(\gcdDm3Gene, {
	// arg amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, sig1Size = 10, sig2Size = 10, sig3Size = 10, add1 = 102, add2 = 101, add3 = 100, mod1 = 100, mod2 = 101, mod3 = 102, dev1 = 10, dev2 = 20;
	var sig, sig1, sig2, sig3, env;

	env = EnvGen.kr(Env.asr(~gcdDm3GenePreset[\atk], 1, ~gcdDm3GenePreset[\rls]), timeScale: ~gcdDm3GenePreset[\sustain]);

	sig1 = TDuty.ar(Dseq([Dser(\seq1.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
		11, 12]), ~gcdDm3GenePreset[\sig1Size])], inf) + ~gcdDm3GenePreset[\add1] * SampleDur.ir);
	sig2 = TDuty.ar(Dseq([Dser(\seq2.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
		11, 12]), ~gcdDm3GenePreset[\sig2Size])], inf) + ~gcdDm3GenePreset[\add2] * SampleDur.ir);
	sig3 = TDuty.ar(Dseq([Dser(\seq3.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
		11, 12]), ~gcdDm3GenePreset[\sig3Size])], inf) + ~gcdDm3GenePreset[\add3] * SampleDur.ir);

	sig1 = PulseCount.ar(sig1) % ~gcdDm3GenePreset[\mod1];
	sig2 = PulseCount.ar(sig2) % ~gcdDm3GenePreset[\mod2];
	sig3 = PulseCount.ar(sig3) % ~gcdDm3GenePreset[\mod3];

	sig = gcd(gcd(sig1 + [0, 0], sig2 + [0, ~gcdDm3GenePreset[\dev1]]), sig3 + [0, ~gcdDm3GenePreset[\dev2]]);
	sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

	sig = sig * env;
	sig = (sig * ~gcdDm3GenePreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)


Ndef(\gcdDm3Gene).play(2);

Ndef(\gcdDm3Gene).fadeTime_(18);

Ndef(\gcdDm3Gene).release(10);

(
~gcdLcmDmGenePreset = (amp: 0.1, spread: 0.5, atk: 0.001, rls: 0.2, sustain: 1, mul1: 1, mul2: 40, mulTanh: 0.0001, modu1: 100, modu2: 300, rate1: 0.6, rate2: 0.06, smooth1: 0.4, smooth2: 0);
// default
)

(
~gcdLcmDmGenePreset = ( 'rate1': 0.66003608703613, 'rate2': 0.08333221912384, 'mulTanh': 0.00078034864664078, 'smooth2': 0, 'amp': 0.1, 'sustain': 1, 'modu1': 80, 'atk': 0.090585555791855, 'mul1': 1.1539040088654, 'modu2': 289, 'mul2': 11, 'smooth1': 0.41847088336945, 'spread': 0.3523308634758, 'rls': 0.27332791090012 );
)

(
~gcdLcmDmGenePreset = ( 'rate1': 0.61352477073669, 'rate2': 0.060503163337708, 'mulTanh': 0.00045209368467331, 'smooth2': 0,
  'amp': 0.1, 'sustain': 1, 'modu1': 88, 'atk': 0.047958358049393, 'mul1': 0.81992778778076,
  'modu2': 234, 'mul2': 34, 'smooth1': 0.48425145149231, 'spread': 0.41102212667465, 'rls': 0.34053097963333 )
)

(
~gcdLcmDmGenePreset = ( 'rate1': 0.48810939788818, 'rate2': 0.070423121452332, 'mulTanh': 0.00071299312114716, 'smooth2': 0, 'amp': 0.1, 'sustain': 1, 'modu1': 68, 'atk': 0.059621265888214, 'mul1': 0.93580513000488, 'modu2': 186, 'mul2': 37, 'smooth1': 0.33775401115417, 'spread': 0.34417432546616, 'rls': 0.23200072050095 )
)

(
~gcdLcmDmGenePreset = (amp: 0.1, spread: rrand(0.25, 0.75), atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, mul1: rrand(0.8, 1.2), mul2: rrand(8, 40), mulTanh: rrand(0.0001, 0.001), modu1: rrand(50,100), modu2: rrand(120, 300), rate1: rrand(0.4, 0.8), rate2: rrand(0.06, 0.1), smooth1: rrand(0.3, 0.5), smooth2: 0);
// rrand
)

(
Ndef(\gcdLcmDmGene, {
	// amp = 0.1, spread = 0.5, atk = 0.001, rls = 0.2, sustain = 1, mul1 = 1, mul2 = 40, mulTanh = 0.0001, modu1 = 100, modu2 = 300, rate1 = 0.6, rate2 = 0.06, smooth1 = 0.4, smooth2 = 0;
	var mod1, mod2, sin1, sin2, sig, sig1, sig2, sig3, env;

	env = EnvGen.kr(Env.asr(~gcdLcmDmGenePreset[\atk], 1, ~gcdLcmDmGenePreset[\rls]), timeScale: ~gcdLcmDmGenePreset[\sustain]);

	mod1 = TRand.kr(1, 300, Impulse.kr(~gcdLcmDmGenePreset[\rate1]));
	mod1 = Lag2.kr(mod1, ~gcdLcmDmGenePreset[\smooth1]);

	mod2 = TRand.kr(1, 300, Dust.kr(~gcdLcmDmGenePreset[\rate2]));
	mod2 = Lag2.kr(mod2, ~gcdLcmDmGenePreset[\smooth2]);

	sin1 = SinOsc.ar(mod1).range(1,100) * ~gcdLcmDmGenePreset[\mul1];
	sin2 = SinOsc.ar(mod2) * ~gcdLcmDmGenePreset[\mul2];

	sig1 = gcd(sin1, sin2) % ~gcdLcmDmGenePreset[\modu1];
	sig2 = lcm(sin1, sin2) % ~gcdLcmDmGenePreset[\modu2];

	sig = tanh([sig1 * sig2, sin1 * sin2] * ~gcdLcmDmGenePreset[\mulTanh]);

	sig = Splay.ar(sig, ~gcdLcmDmGenePreset[\spread]) * env;
	sig = (sig * ~gcdLcmDmGenePreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\gcdLcmDmGene).play(2);

Ndef(\gcdLcmDmGene).fadeTime_(18);

Ndef(\gcdLcmDmGene).release(10);


(
~gcdDm4GenePreset = ( 'atk': 0.042787989258766, 'mul1': 46, 'dev1': 0.087901091575623, 'mod2': 129,  'add1': 59, 'amp': 0.1, 'mod3': 99, 'end': 0.38251852989197, 'rate1': 8.4022823572159,  'serSize': 23, 'dev2': 1.254590690136, 'add': 271, 'start': 68, 'rls': 0.45941503047943,  'sustain': 1 ) ;
)


(
~gcdDm4GenePreset = ( 'atk': 0.094803431391716, 'mul1': 49, 'dev1': 0.095498728752136, 'mod2': 216, 'add1': 43, 'amp': 0.1, 'mod3': 91, 'end': 0.38516335487366, 'rate1': 9.1425079107285, 'serSize': 20, 'dev2': 1.0559352040291, 'add': 157, 'start': 58, 'rls': 0.40772210359573, 'sustain': 1 );
)


(
~gcdDm4GenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, serSize: 27, start: 100, end: 0.1, rate1: 10, mod2: 300, mod3: 101, dev1: 0, dev2: 2, add: 600, add1: 61, mul1: 43);
// default
)

(
~gcdDm4GenePreset = ( 'atk': 0.065175143361092, 'mul1': 36, 'dev1': 0.095331811904907, 'mod2': 228, 'add1': 43, 'amp': 0.1, 'mod3': 86, 'end': 0.41456122398376, 'rate1': 7.0137279629707, 'serSize': 23, 'dev2': 0.86043810844421, 'add': 346, 'start': 93, 'rls': 0.26504782438278, 'sustain': 1 );
)

(
~gcdDm4GenePreset = ( 'atk': 0.096913956522942, 'mul1': 46, 'dev1': 0.030357098579407, 'mod2': 181,
  'add1': 23, 'amp': 0.1, 'mod3': 90, 'end': 0.32150664329529, 'rate1': 8.1436048746109,
  'serSize': 21, 'dev2': 0.61037647724152, 'add': 202, 'start': 100, 'rls': 0.35190583467484,
  'sustain': 1 );
)

(
~gcdDm4GenePreset = ( 'atk': 0.014392709493637, 'mul1': 51, 'dev1': 0.037323355674744, 'mod2': 233,
  'add1': 23, 'amp': 0.1, 'mod3': 84, 'end': 0.42436208724976, 'rate1': 9.3435113430023,
  'serSize': 13, 'dev2': 1.5269731283188, 'add': 186, 'start': 54, 'rls': 0.4651416182518,
  'sustain': 1 );
)

(
~gcdDm4GenePreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, serSize: rrand(10, 27), start: rrand(40, 100), end: rrand(0.1, 0.5), rate1: rrand(6.5, 10), mod2: rrand(30,300), mod3: rrand(80,101), dev1: rrand(0, 0.1), dev2: rrand(0.5,2), add: rrand(100,600), add1: rrand(20,61), mul1: rrand(30,53));
// rrand
)

(
Ndef(\gcdDm4Gene, {
	// arg out = 0, amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, serSize = 27, start = 100, end = 0.1, rate1 = 10, mod2 = 300, mod3 = 101, dev1 = 0, dev2 = 2, add = 600, add1 = 61, mul1 = 43 ;
	var seq, envMod, src1, src2, src3, sig, sig1, env;

	env = EnvGen.kr(Env.asr(~gcdDm4GenePreset[\atk], 1, ~gcdDm4GenePreset[\rls]), timeScale: ~gcdDm4GenePreset[\sustain]);

	seq = Dseq([Dser(\ser.kr(#[ 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,
		62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77 ]),
	~gcdDm4GenePreset[\serSize])], inf);

	// envMod = XLine.kr(start, end, 100);

	envMod = LFTri.kr(0.005, -1).exprange(~gcdDm4GenePreset[\start], ~gcdDm4GenePreset[\end]);

	src1 = TDuty.ar(seq * envMod * SampleDur.ir);
	src2 = PulseCount.ar(Impulse.ar(~gcdDm4GenePreset[\rate1])) % ~gcdDm4GenePreset[\mod2];
	src3 = PulseCount.ar(src1) % ~gcdDm4GenePreset[\mod3];

	sig = gcd(src2, src3 + [0, 2]);
	sig1 = gcd(lcm(src2 + [~gcdDm4GenePreset[\dev1], ~gcdDm4GenePreset[\dev2]], src3),sig);

	sig = SinOsc.ar(sig * 443 + ~gcdDm4GenePreset[\add]) * 0.1;
	sig1 = SinOsc.ar(sig1 * ~gcdDm4GenePreset[\mul1] + ~gcdDm4GenePreset[\add1]) * 0.4;

	sig = (Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, 5000), 0.3) *
		env * ~gcdDm4GenePreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\gcdDm4Gene).play(2);

Ndef(\gcdDm4Gene).fadeTime_(15);

Ndef(\gcdDm4Gene).release(10);


(
~gcdDm5GenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, serSize: 99, start: 10, end: 0.01, rate1: 1, mod2: 500, mod3: 501, dev1: 1, dev2: 3, add: 400, add1: 61, mul1: 53);
// default
)

(
~gcdDm5GenePreset = ( 'atk': 0.020083911776543, 'mul1': 32, 'dev1': 1, 'mod2': 430, 'add1': 57, 'amp': 0.1, 'mod3': 431, 'end': 0.01, 'rate1': 0.64504569768906, 'serSize': 63, 'dev2': 2.3495795488358, 'add': 363, 'start': 8, 'rls': 0.45287276506424, 'sustain': 1 );
)

(
~gcdDm5GenePreset = ( 'atk': 0.094500693678856, 'mul1': 51, 'dev1': 1, 'mod2': 349, 'add1': 24, 'amp': 0.1, 'mod3': 61, 'end': 0.01, 'rate1': 0.73858630657196, 'serSize': 35, 'dev2': 2.4337140083313, 'add': 247, 'start': 7, 'rls': 0.43925658464432, 'sustain': 1 );
)

(
~gcdDm5GenePreset = ('atk': 0.07861684179306, 'mul1': 49, 'dev1': 1, 'mod2': 162, 'add1': 25, 'amp': 0.1, 'mod3': 487, 'end': 0.01, 'rate1': 0.70557272434235, 'serSize': 72, 'dev2': 2.4129635810852, 'add': 346, 'start': 5, 'rls': 0.35922583341599, 'sustain': 1);
)

(
~gcdDm5GenePreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, serSize: rrand(30, 99), start: rrand(5, 10), end: 0.01, rate1: rrand(0.5, 1), mod2: rrand(25, 500), mod3: rrand(45, 501), dev1: 1, dev2: rrand(1.2, 3), add: rrand(200, 400), add1: rrand(20, 61), mul1: rrand(30, 53));
)

(
Ndef(\gcdDm5Gene, {
	// arg amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, serSize = 99, start = 10, end = 0.01, rate1 = 1, mod2 = 500, mod3 = 501, dev1 = 1, dev2 = 3, add = 400, add1 = 61, mul1 = 53;
	var seq, envMod, src1, src2, src3, sig, sig1, env;

	env = EnvGen.kr(Env.asr(~gcdDm5GenePreset[\atk], 1, ~gcdDm5GenePreset[\rls]), timeScale: ~gcdDm5GenePreset[\sustain]);

	seq = Dseq([Dser(\ser.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
		14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
		32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
		50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67,
		68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85,
		86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99]), ~gcdDm5GenePreset[\serSize])],
	inf);

	//envMod = XLine.kr(start, end, 100);

	envMod = LFTri.kr(0.005, -1).exprange(~gcdDm5GenePreset[\start], ~gcdDm5GenePreset[\end]);

	src1 = TDuty.ar(seq * envMod * SampleDur.ir);
	src2 = PulseCount.ar(Impulse.ar(~gcdDm5GenePreset[\rate1])) % ~gcdDm5GenePreset[\mod2];
	src3 = PulseCount.ar(src1) % ~gcdDm5GenePreset[\mod3];

	sig = gcd(src2, src3 + [0, 2]);
	sig1 = gcd(lcm(src2 + [~gcdDm5GenePreset[\dev1], ~gcdDm5GenePreset[\dev2]], src3),sig);

	sig = SinOsc.ar(sig * 443 + ~gcdDm5GenePreset[\add]) * 0.1;
	sig1 = SinOsc.ar(sig1 * ~gcdDm5GenePreset[\mul1] + ~gcdDm5GenePreset[\add1]) * 0.3;

	sig = (Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, 5000), 0.3) * env * ~gcdDm5GenePreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\gcdDm5Gene).fadeTime_(19);

Ndef(\gcdDm5Gene).play(2);

Ndef(\gcdDm5Gene).release(12);

(
~gcdDmFbGenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, ser1Size: 4, ser2Size: 5, add1: 50, add2: 50.1, mod: 50, sinFmin: 70, div: 10, sigSel: 0, fbSel: 0);
// default
)

(
~gcdDmFbGenePreset = ( 'add1': 57, 'sustain': 1, 'fbSel': 0, 'rls': 0.2647763133049, 'atk': 0.095083946466446, 'amp': 0.1, 'ser2Size': 3.5095220208168, 'sigSel': 0, 'ser1Size': 2.8815880775452, 'mod': 58, 'sinFmin': 107, 'add2': 114.15673396587, 'div': 11 );
)

(
~gcdDmFbGenePreset = ( 'add1': 143, 'sustain': 1, 'fbSel': 0, 'rls': 0.43422375917435,  'atk': 0.094964017391205, 'amp': 0.1, 'ser2Size': 4.7962199449539, 'sigSel': 0, 'ser1Size': 3.3565378665924,  'mod': 67, 'sinFmin': 142, 'add2': 73.579010593891, 'div': 16 );
)

(
~gcdDmFbGenePreset = ( 'add1': 187, 'sustain': 1, 'fbSel': 0, 'rls': 0.36143919229507, 'atk': 0.0184901835799217, 'amp': 0.1, 'ser2Size': 6.5922054052353, 'sigSel': 0, 'ser1Size': 3.0188598155975, 'mod': 171, 'sinFmin': 85, 'add2': 122.65872319937, 'div': 9 ) ;
)

(
~gcdDmFbGenePreset = ( 'add1': 132, 'sustain': 1, 'fbSel': 0, 'rls': 0.21065083742142, 'atk': 0.045341633558273, 'amp': 0.1, 'ser2Size': 4.9993562698364, 'sigSel': 0, 'ser1Size': 1.1673916339874, 'mod': 54, 'sinFmin': 89, 'add2': 50.905527365208, 'div': 15 ) ;
)

(
~gcdDmFbGenePreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, ser1Size: rrand(0.6, 4), ser2Size: rrand(2.5, 6), add1: rrand(50, 150), add2: rrand(50.1, 125), mod: rrand(50, 76), sinFmin: rrand(70, 200), div: rrand(10, 16), sigSel: 0, fbSel: 0);
// rrand
)


(
Ndef(\gcdDmFbGene, {
	// arg amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, ser1Size = 4, ser2Size = 5, add1 = 50, add2 = 50.1, mod = 50, sinFmin = 70, div = 10, sigSel = 0, fbSel = 0;
	var seq1, seq2, src1, src2, count1, count2, in, sinFrq, sig, sig1,
	sig2, sig3, sig4, sig5, fb, env;

	env = EnvGen.kr(Env.asr(~gcdDmFbGenePreset[\atk], 1, ~gcdDmFbGenePreset[\rls]), timeScale: ~gcdDmFbGenePreset[\sustain]);

	seq1 = Dseq([Dser(\ser1.kr(#[0, 1, 2, 3]), ~gcdDmFbGenePreset[\ser1Size])], inf);
	seq2 = Dseq([Dser(\ser2.kr(#[4, 3, 2, 1, 0]), ~gcdDmFbGenePreset[\ser2Size])], inf);

	src1 = TDuty.ar(seq1 + ~gcdDmFbGenePreset[\add1] * SampleDur.ir);
	src2 = TDuty.ar(seq2 + ~gcdDmFbGenePreset[\add2] * SampleDur.ir);

	count1 = PulseCount.ar(src1) % ~gcdDmFbGenePreset[\mod];
	count2 = PulseCount.ar(src2) % ~gcdDmFbGenePreset[\mod];

	in = LocalIn.ar(2);
	sig1 = gcd(count1, count2 + [0, 1]);
	sinFrq = sig1.linexp(0, ~gcdDmFbGenePreset[\mod], ~gcdDmFbGenePreset[\sinFmin], 10000);
	sig2 = SinOsc.ar(sinFrq, 0, in / 2);
	sig3 = SinOsc.ar(sinFrq * (in / ~gcdDmFbGenePreset[\div ]+ 1));
	sig4 = SinOsc.ar(sinFrq);
	sig5 = SinOsc.ar(sinFrq) + BPF.ar(in * 0.95,
		LFDNoise3.ar(0.2).range(100, 10000));

	~gcdDmFbGenePreset[\sigSel] = ~gcdDmFbGenePreset[\sigSel].min(3).max(0);
	sig = Select.ar(~gcdDmFbGenePreset[\sigSel], [sig2, sig3, sig4, sig5]);

	~gcdDmFbGenePreset[\fbSel] = ~gcdDmFbGenePreset[\fbSel].min(3).max(0);
	fb = Select.ar(~gcdDmFbGenePreset[\fbSel], [sinFrq.reverse, in.reverse, sig * in, sig]);
	LocalOut.ar(fb);

	sig = (Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3) * env * ~gcdDmFbGenePreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\gcdDmFbGene).fadeTime_(19);

Ndef(\gcdDmFbGene).play(2);

Ndef(\gcdDmFbGene).release(20);

(
~factorFunPreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, mod: 0.5);
// default
)

(
~factorFunPreset = ( 'amp': 0.1, 'atk': 0.090930897712708, 'mod': 0.66605740785599, 'rls': 0.2730535030365,
  'sustain': 1 )
)

(
~factorFunPreset = ( 'amp': 0.1, 'atk': 0.012270016789436, 'mod': 0.37186467647552, 'rls': 0.42715688943863,
  'sustain': 1 )
)

(
~factorFunPreset = ( 'amp': 0.1, 'atk': 0.043364680290222, 'mod': 0.96812121868134, 'rls': 0.32145382165909,
  'sustain': 1 )
)

(
~factorFunPreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.5), sustain: 1, mod: rrand(0.05, 0.75));
)


// ne joue que sur la gauche !!
(
Ndef(\factorFun, {
	// arg amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, mod = 0.5;
	var sig, env, factorfunc, scaling, gcdoutput;

	env = EnvGen.kr(Env.asr(~factorFunPreset[\atk], 1, ~factorFunPreset[\rls]), timeScale: ~factorFunPreset[\sustain]);

	scaling = gcd(\f1.kr(#[1, 1, 1, 1]).product, \f2.kr(#[1, 1, 1,
		1]).product);

	factorfunc = {|factors|
		var fprod = factors.product;

		//either 1 or factor randomly over time
		factors.collect{|f| (ToggleFF.ar(Dust.ar(LFNoise0.kr(f).range(1,
			~factorFunPreset[\mod].linexp(0, 1, 16, 440)))) * (f-1)) + 1;
		};

	};

	gcdoutput =
	gcd(factorfunc.(\f1.kr).product,factorfunc.(\f2.kr).product) / scaling;

	sig = SinOsc.ar(~factorFunPreset[\mod].linlin(0, 1, 20, 2000) * gcdoutput) * 0.3;

	sig = (sig * env * ~factorFunPreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\factorFun).fadeTime_(17);

Ndef(\factorFun).play(2);

Ndef(\factorFun).release(12);

(
~factorFun1Preset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, hiRange: 0.5, pmIdx: 0.2, sigSel: 0);
// default
)

(
~factorFun1Preset = ( 'sigSel': 1, 'atk': 0.096793208837509, 'pmIdx': 0.4054794549942, 'amp': 0.1, 'sustain': 1, 'rls': 0.31651903390884, 'hiRange': 0.35225427150726 );
)

(
~factorFun1Preset = ( 'sigSel': 0, 'atk': 0.096793208837509, 'pmIdx': 0.1054794549942, 'amp': 0.1, 'sustain': 1, 'rls': 0.41651903390884, 'hiRange': 0.65225427150726 )
)

(
~factorFun1Preset = ( 'sigSel': 0, 'atk': 0.18950800025463, 'pmIdx': 0.44989132881165, 'amp': 0.1, 'sustain': 1, 'rls': 0.2683856010437, 'hiRange': 0.70070533752441 );
)

(
~factorFun1Preset = ( 'sigSel': 0, 'atk': 0.091273785948753, 'pmIdx': 0.20537732839584, 'amp': 0.1, 'sustain': 1, 'rls': 0.68173505067825, 'hiRange': 0.31282923221588 );
)

(
~factorFun1Preset = (amp: 0.1, atk: rrand(0.001, 0.19), rls: rrand(0.2, 0.7), sustain: 1, hiRange: rrand(0.2, 0.8), pmIdx: rrand(0.2, 0.5), sigSel: rrand(0, 1));
// rrand
)


(
Ndef(\factorFun1, {
	// arg amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, hiRange = 0.5, pmIdx = 0.2, sigSel = 0;
	var sig, sig1, sig2, sig3, env, factorfunc, scaling, scaling1,
	gcdoutput, lcmoutput, f3, f4;
	~factorFun1Preset[\hiRange] = ~factorFun1Preset[\hiRange].min(1).max(0);
	~factorFun1Preset[\pmIdx] = ~factorFun1Preset[\pmIdx].min(1).max(0);
	~factorFun1Preset[\sigSel] = ~factorFun1Preset[\sigSel].min(2).max(0);

	env = EnvGen.kr(Env.asr(~factorFun1Preset[\atk], 1, ~factorFun1Preset[\rls]), timeScale: ~factorFun1Preset[\sustain]);

	scaling = gcd(\f1.kr(#[1, 1, 1, 1, 1, 1, 1]).product, \f2.kr(#[1, 1, 1,
		1, 1]).product);
	scaling1 = lcm(\f1.kr.product, \f2.kr.product);

	factorfunc = {|factors|
		var fprod = factors.product;

		//either 1 or factor randomly over time
		factors.collect{|f| (ToggleFF.ar(Dust.ar(LFNoise0.kr(f).range(1,
			~factorFun1Preset[\hiRange].linexp(0, 1, 1, 440)))) * (f-1)) + 1 };

	};

	f3 = factorfunc.(\f1.kr).product;
	f4 = factorfunc.(\f2.kr).product;

	gcdoutput = gcd(f3, f4) / scaling;
	lcmoutput = lcm(f3, f4) / scaling1;

	sig1 = SinOsc.ar(~factorFun1Preset[\pmIdx].linlin(0, 1, 20, [2000, 4001]) * [gcdoutput,
		lcmoutput]);
	sig2 = SinOsc.ar(([gcdoutput, lcmoutput] * 2000) + (gcdoutput *
		~factorFun1Preset[\pmIdx].linexp(0, 1, 0.1, 10) * SinOsc.ar(lcmoutput))) * 0.8;
	sig3 = PMOsc.ar(lcmoutput*[5000,5001], gcdoutput*[700,703],
		~factorFun1Preset[\pmIdx].linlin(0, 1, 1, 10)) * 0.74;

	sig = Select.ar(~factorFun1Preset[\sigSel], [sig1, sig2, sig3]);
	sig = (sig * env * ~factorFun1Preset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\factorFun1).fadeTime_(17);

Ndef(\factorFun1).play(2);

Ndef(\factorFun1).release(12);

(
~lcm1Preset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, rate1: 200, loRange1: 1, rate2: 6, loRange2: 10);
// default
)

(
~lcm1Preset = ( 'rate1': 1820, 'loRange2': 10, 'atk': 0.0075817074775696, 'amp': 0.1, 'sustain': 1, 'rls': 0.52527899742126, 'loRange1': 1, 'rate2': 5 )
)

(
~lcm1Preset = ( 'rate1': 588, 'loRange2': 10, 'atk': 0.011537132620811, 'amp': 0.1, 'sustain': 1, 'rls': 0.34017815589905, 'loRange1': 1, 'rate2': 5 )
)

(
~lcm1Preset = (amp: 0.1, atk: rrand(0.001, 0.014), rls: rrand(0.2, 0.6), sustain: 1, rate1: rrand(300, 2000), loRange1: 1, rate2: 5, loRange2: 10);
// rrand
)

// ne sort qu'à gauche?
(
Ndef(\lcm1, {
	// arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, rate1 = 200, loRange1 = 1, rate2 = 6, loRange2 = 10;
	var sig, sig1, sig2, env;
	env = EnvGen.kr(Env.asr(~lcm1Preset[\atk], 1, ~lcm1Preset[\rls]), timeScale: ~lcm1Preset[\sustain]);
	sig1 = SinOsc.ar(LFNoise2.ar(~lcm1Preset[\rate1], 500, 501)).range(~lcm1Preset[\loRange1],
		100).round(1);
	sig2 = SinOsc.ar(LFNoise1.kr(~lcm1Preset[\rate2], 500, 501)).range(~lcm1Preset[\loRange2],
		100).round(1);
	sig = tanh(lcm(sig1, sig2)*0.1);
	// sig = sig * env;
	sig = (sig * env * ~lcm1Preset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\lcm1).fadeTime_(9);

Ndef(\lcm1).play(2);

Ndef(\lcm1).release(9);


(
~lcm2GenePreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, rate1: 28, rate2: 26, smooth1: 0.4, smooth2: 0.2);
// default
)

(
~lcm2GenePreset = ( 'rate1': 18.416101551056, 'smooth1': 0.26401857733727, 'atk': 0.0062176464796066, 'amp': 0.1,
  'sustain': 1, 'rls': 0.54321409463882, 'smooth2': 0.29533241391182, 'rate2': 29 );
)

(
~lcm2GenePreset = ( 'rate1': 16.22926671505, 'smooth1': 0.31869168281555, 'atk': 0.080930144071579, 'amp': 0.1,
  'sustain': 1, 'rls': 0.62533481121063, 'smooth2': 0.41831920742989, 'rate2': 24 );
)

(
~lcm2GenePreset = ( 'rate1': 26.347225594521, 'smooth1': 0.29038656949997, 'atk': 0.018025007367134, 'amp': 0.1,
  'sustain': 1, 'rls': 0.24922437667847, 'smooth2': 0.20402170419693, 'rate2': 40 );
)

(
~lcm2GenePreset = ( 'rate1': 15.715190243721, 'smooth1': 0.26995588541031, 'atk': 0.095597262263298, 'amp': 0.1,
  'sustain': 1, 'rls': 0.68452371358871, 'smooth2': 0.27485747337341, 'rate2': 35 )
)

(
~lcm2GenePreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.7), sustain: 1, rate1: rrand(4.6, 28), rate2: rrand(20, 40), smooth1: rrand(0.2, 0.45), smooth2: rrand(0.2, 0.45));
// rrand
)

(
Ndef(\lcm2Gene, {
	// arg amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, rate1 = 28, rate2 = 26, smooth1 = 0.4, smooth2 = 0.2;
	var sig, sig1, sig2, mod1, mod2, env;

	env = EnvGen.kr(Env.asr(~lcm2GenePreset[\atk], 1, ~lcm2GenePreset[\rls]), timeScale: ~lcm2GenePreset[\sustain]);

	mod1 = TExpRand.kr(1, 1000, Impulse.kr(~lcm2GenePreset[\rate1]));
	mod1 = Lag2.kr(mod1, ~lcm2GenePreset[\smooth1]);

	mod2 = TExpRand.kr(1, 1000, Dust.kr(~lcm2GenePreset[\rate2]));
	mod2 = Lag2.kr(mod2, ~lcm2GenePreset[\smooth2]);

	sig1 = Saw.ar(mod1).range(-100,100).round(1);
	sig2 = LFCub.ar(mod2).range(-100,100).round(1);

	sig = tanh(lcm(sig1, sig2) * 0.001);

	sig = sig * env;
	sig = (sig * ~lcm2GenePreset[\amp]);
});
)

Ndef(\lcm2Gene).fadeTime_(6);

Ndef(\lcm2Gene).play(2);

Ndef(\lcm2Gene).release(14);

(
~lcm2Preset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, mod1: 3.09431, mod2: 54.0487);
// default
)

(
~lcm2Preset = ( 'rls': 0.35175914764404, 'mod2': 52.63974693085, 'atk': 0.046337085008621, 'mod1': 3.004041007688, 'amp': 0.1, 'sustain': 1 )
)

(
~lcm2Preset = ( 'rls': 0.45175914764404, 'mod2': 32.63974693085, 'atk': 0.0146337085008621, 'mod1': 2.004041007688, 'amp': 0.1, 'sustain': 1 )
)

(
~lcm2Preset = ( 'rls': 0.25828251838684, 'mod2': 35.203470209682, 'atk': 0.0180271938562393, 'mod1': 2.3404990996182, 'amp': 0.1, 'sustain': 1 )
)

(
~lcm2Preset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.6), sustain: 1, mod1: rrand(1.4, 4.09431), mod2: rrand(20, 54.0487));
// rrand
)


(
Ndef(\lcm2, {
	// amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 3.09431, mod2 = 54.0487;
	var sig, sig1, sig2, env;

	env = EnvGen.kr(Env.asr(~lcm2Preset[\atk], 1, ~lcm2Preset[\rls]), timeScale: ~lcm2Preset[\sustain]);

	~lcm2Preset[\mod1] = ~lcm2Preset[\mod1].min(1000).max(1);
	~lcm2Preset[\mod2] = ~lcm2Preset[\mod2].min(1000).max(1);

	sig1 = Saw.ar(~lcm2Preset[\mod1]).range(-100,100).round(1);
	sig2 = LFCub.ar(~lcm2Preset[\mod2]).range(-100,100).round(1);

	sig = tanh(lcm(sig1, sig2) * 0.001);

	sig = sig * env;
	sig = Pan2.ar(sig * ~lcm2Preset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\lcm2).fadeTime_(19);

Ndef(\lcm2).play(2);

Ndef(\lcm2).release(10);

(
~modelBitsPreset = (amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, mod1: 1, mod2: 1);
// default
)

(
~modelBitsPreset = ( 'rls': 0.38701448440552, 'mod2': 0.94951220750809, 'atk': 0.099110740423203, 'mod1': 0.7352654337883, 'amp': 0.1, 'sustain': 1 )
)

(
~modelBitsPreset = ( 'rls': 0.43033952713013, 'mod2': 0.87577879428864, 'atk': 0.072004798531532, 'mod1': 0.81842906475067, 'amp': 0.1, 'sustain': 1 )
)

(
~modelBitsPreset = ( 'rls': 0.25742192268372, 'mod2': 0.83238798379898, 'atk': 0.031174141168594, 'mod1': 0.90378706455231, 'amp': 0.1, 'sustain': 1 )
)

(
~modelBitsPreset = ( 'rls': 0.950352067947388, 'mod2': 0.7035672664642, 'atk': 0.00130132615804672, 'mod1': 0.52691388130188, 'amp': 0.1, 'sustain': 1 )
)

(
~modelBitsPreset = (amp: 0.1, atk: rrand(0.001, 0.1), rls: rrand(0.2, 0.6), sustain: 1, mod1: rrand(0.5, 1), mod2: rrand(0.7, 1));
// rrand
)

(
// need this: s.options.memSize_(16384*10);
Ndef(\modelBits, {
	// arg amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 1, mod2 = 1 ;
	var sig, sig1, sig2, count1, count2, env;

	env = EnvGen.kr(Env.asr(~modelBitsPreset[\atk], 1, ~modelBitsPreset[\rls]), timeScale: ~modelBitsPreset[\sustain]);

	count1 = PulseCount.ar(Impulse.ar(8e3 * ~modelBitsPreset[\mod1]));
	count2 = PulseCount.ar(Impulse.ar(7009 * ~modelBitsPreset[\mod2]));

	sig1 = HPF.ar(
		(
			((count1 * 15) & (count1 >> 5)) |
			((count1 * 5) & (count1 >> [3, 4])) |
			((count1 * 2) & (count1 >> 9)) |
			((count1 * 8) & (count1 >> 11)) |
			(((count1 * count1) & count1) | (count1 >> 3))
			- 3 % 256
		) / 127-1 * 3
		, 20
	) * 0.1;

	sig2 = LPF.ar(HPF.ar(gcd(count1 * count2, count2 + count1),
		WhiteNoise.ar()*2000 + 1000), 20);
	sig2 = sig2 * sig1;
	sig = Splay.ar(Limiter.ar(Greyhole.ar(sig1 + sig2, sig1, 0.5, sig1),
		0.5).flatten);
	sig = (sig * env * ~modelBitsPreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\modelBits).fadeTime_(8);

Ndef(\modelBits).play(2);

Ndef(\modelBits).release(10);


 // fin gene_afinir
// generative_sd_2mo

(
~nVirgoPreset = (amp: 1, att: 0.01, rel: 20, feedBack: 7.5, sawFreq1: 32, sawFreq2: 33, sawAmp: 0.2, bpff: 2, bpffModSpeed: 1.33, bpffModAmt: 4, delayTime: 2, decayTime: 40);
// default
)

(
~nVirgoPreset = ( 'att': 0.089472068548203, 'sawAmp': 0.2, 'bpffModAmt': 3.0938064455986, 'rel': 15, 'sawFreq2': 552, 'bpff': 2, 'delayTime': 1.8205498456955, 'feedBack': 5.5620234012604, 'bpffModSpeed': 2.9549210321903, 'decayTime': 40, 'amp': 0.2, 'sawFreq1': 225 )
)

(
~nVirgoPreset = ( 'att': 0.11469817638397, 'sawAmp': 0.2, 'bpffModAmt': 2.12881731987, 'rel': 12, 'sawFreq2': 524, 'bpff': 2, 'delayTime': 1.1182125210762, 'feedBack': 0.84835304915905, 'bpffModSpeed': 2.9216046774387, 'decayTime': 40, 'amp': 0.2, 'sawFreq1': 69 )
)

(
~nVirgoPreset = ( 'att': 0.17509307265282, 'sawAmp': 0.2, 'bpffModAmt': 3.5155351161957, 'rel': 13,
  'sawFreq2': 279, 'bpff': 2, 'delayTime': 0.257721811532974, 'feedBack': 0.6553511619568, 'bpffModSpeed': 1.3605163013935,
  'decayTime': 40, 'amp': 0.2, 'sawFreq1': 166 )
)

(
~nVirgoPreset = ( 'att': 0.11383947849274, 'sawAmp': 0.2, 'bpffModAmt': 1.4050741195679, 'rel': 6, 'sawFreq2': 444, 'bpff': 2, 'delayTime': 1.8397490978241, 'feedBack': 1.61629204154015, 'bpffModSpeed': 2.0261113810539, 'decayTime': 40, 'amp': 0.2, 'sawFreq1': 188 )
)

(
~nVirgoPreset = ( 'att': 0.18990749120712, 'sawAmp': 0.2, 'bpffModAmt': 2.2081257104874, 'rel': 13, 'sawFreq2': 694, 'bpff': 2, 'delayTime': 0.87268024682999, 'feedBack': 2.393406867981, 'bpffModSpeed': 2.7786209928989, 'decayTime': 40, 'amp': 0.2, 'sawFreq1': 105 )
)

(
~nVirgoPreset = (amp: 0.2, att: rrand(0.01, 0.2), rel: rrand(1,20), feedBack: rrand(4, 7.5), sawFreq1: rrand(32, 230), sawFreq2: rrand(33, 820), sawAmp: 0.2, bpff: 2, bpffModSpeed: rrand(1.33, 3), bpffModAmt: rrand(0.5, 4), delayTime: rrand(0.5, 2), decayTime: 40);
// rrand à faire
)

(
Ndef(\nVirgo, {
	// arg amp = 1, att = 0.01, rel = 20, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40;
	var sig, env;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(~nVirgoPreset[\att], 1, ~nVirgoPreset[\rel]));
	// var env = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);
	sig = LocalIn.ar(2) * ~nVirgoPreset[\feedBack] + Saw.ar(
		[~nVirgoPreset[\sawFreq1], ~nVirgoPreset[\sawFreq2]],
		~nVirgoPreset[\sawAmp]
	) * env;
	sig = BPF.ar(
		sig,
		~nVirgoPreset[\bpff] ** LFNoise0.kr(~nVirgoPreset[\bpffModSpeed], ~nVirgoPreset[\bpffModAmt]) * 300,
		0.1
	).distort;
	sig = CombN.ar(sig, 2, ~nVirgoPreset[\delayTime], ~nVirgoPreset[\decayTime]);
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	// OffsetOut.ar(out, DirtPan.ar(sig * amp, ~dirt.numChannels, pan, env))
	sig = (sig * ~nVirgoPreset[\amp] * env);
});
)

Ndef(\nVirgo).fadeTime_(19);

Ndef(\nVirgo).play(2);

Ndef(\nVirgo).release(10);

// edit 08 03 22 : remplace Env.linen par Env.asr() ok
// rajouter des gate = 1 comme dans batuhan
(
~taltersPreset = (amp: 0.1);
)

(
Ndef(\talters, {
	// amp = 1;
	var sig, env;
	// env = Linen.kr(gate, 0.01, 1, 10, doneAction);
	env = EnvGen.ar(Env.asr(0.01, 1, 10));
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(i*k*k, y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(1/4**i), y.ar(0.1)+1*k+i, k*999))
		}!4).product
	}!8).sum;
	// OffsetOut.ar(out, sig * env * amp);
	sig = (sig * env * ~taltersPreset[\amp])
});
)

Ndef(\talters).play(2);

Ndef(\talters).release(9);

(
~bozkurtPreset = (amp: 0.21, att: 0.01, rel: 10, impFreq: 0.25, freq1: 4, freq2: 6, delTime: 0.3, decTime: 50, feedBack: 1);
// default
)

(
~bozkurtPreset = ( 'delTime': 0.25894921898842, 'rel': 4.3807460069656, 'att': 0.053788027763367, 'feedBack': 0.85149073600769, 'freq1': 9.2091425895691, 'decTime': 31.394058465958, 'amp': 0.21, 'impFreq': 0.36753037571907, 'freq2': 8.2406767845154 )
)

(
~bozkurtPreset = ( 'delTime': 0.16357867717743, 'rel': 6.9976888895035, 'att': 0.091488406658173, 'feedBack': 0.73556730747223, 'freq1': 11.467145872116, 'decTime': 34.696674346924, 'amp': 0.21, 'impFreq': 0.74586114287376, 'freq2': 7.4439162254333 )
)

(
~bozkurtPreset = ( 'delTime': 0.21283552646637, 'rel': 6.5413566827774, 'att': 0.016543077230453, 'feedBack': 0.79398288726807, 'freq1': 5.8135765552521, 'decTime': 40.379449725151, 'amp': 0.21, 'impFreq': 0.80025678873062, 'freq2': 8.3558935403824 )
)

(
~bozkurtPreset = ( 'delTime': 0.27248809337616, 'rel': 3.4016854763031, 'att': 0.088343280553818, 'feedBack': 0.80513486862183, 'freq1': 3.3835899829865, 'decTime': 39.665528535843, 'amp': 0.21, 'impFreq': 0.92727735638618, 'freq2': 7.4780132770538 )
)

(
~bozkurtPreset = (amp: 0.21, att: rrand(0.01, 0.1), rel: rrand(1.5, 10), impFreq: rrand(0.25, 1), freq1: rrand(4, 12.4), freq2: rrand(6, 10.2), delTime: rrand(0.1, 0.43), decTime: rrand(25.0, 50), feedBack: rrand(0.4, 1));
// rrand
)

(
Ndef(\bozkurt, {
	//  amp = 1, att = 0.01, rel = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1;
	var sig, env, input, ctrl;
	//env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(~bozkurtPreset[\att], 1, ~bozkurtPreset[\rel]));
	input = LocalIn.ar(2).tanh * ~bozkurtPreset[\feedBack];
	ctrl = Latch.kr(input[0].abs, Impulse.kr(~bozkurtPreset[\impFreq]));
	sig = Blip.ar([~bozkurtPreset[\freq1], ~bozkurtPreset[\freq2]], 100 * ctrl + 50, 0.9);
	sig = CombC.ar(
		sig,
		1,
		ctrl * ~bozkurtPreset[\delTime],
		~bozkurtPreset[\decTime] * input
	);
	LocalOut.ar(sig);
	sig = Splay.ar(sig * env, 1, ~bozkurtPreset[\amp]);
	// OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
});
)

Ndef(\bozkurt).fadeTime_(19);

Ndef(\bozkurt).play(2);

Ndef(\bozkurt).release(10);

(
~mcldPreset = (amp: 0.21, att: 0.01, rel: 10, impFreq: 10, hpfFreq: 440);
// default
)

(
~mcldPreset = ( 'amp': 0.21, 'att': 0.18903653979301, 'rel': 15, 'impFreq': 7.5887405872345, 'hpfFreq': 276.54161472321 )
)

(
~mcldPreset = ( 'amp': 0.21, 'att': 0.1143148291111, 'rel': 15, 'impFreq': 17.715059459209,
  'hpfFreq': 370.55721702576 )
)

(
~mcldPreset = ( 'amp': 0.21, 'att': 0.17803493738174, 'rel': 7.5, 'impFreq': 12.890402913094, 'hpfFreq': 391.78939743042 )
)

(
~mcldPreset = (amp: 0.21, att: rrand(0.01, 0.2), rel: rrand(5, 15), impFreq: rrand(4.5, 20), hpfFreq: rrand(230.4, 440));
// rrand
)

(
Ndef(\mcld, {
	// amp = 1, att = 0.01, rel = 10, impFreq = 10, hpfFreq = 440;
	var sig, env, input;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(~mcldPreset[\att], 1, ~mcldPreset[\rel]));
	input = LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100;
	sig = DynKlank.ar(
		`[input],
		Impulse.ar(~mcldPreset[\impFreq])
	);
	LocalOut.ar(sig);
	sig = HPF.ar(sig, ~mcldPreset[\hpfFreq]).clip2;
	sig = Splay.ar(sig * env, level: ~mcldPreset[\amp]);
	// OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
});
)

Ndef(\mcld).fadeTime_(9);

Ndef(\mcld).play(2);

Ndef(\mcld).release(10);

(
~padovanPreset = (amp: 0.21, tridDur: 1, freq: 165, roomSize: 9)
// default
)

(
~padovanPreset = ( 'roomSize': 3.6036995053291, 'freq': 245.55842895508, 'tridDur': 0.65141571164131, 'amp': 0.21 );
)

(
~padovanPreset = ( 'roomSize': 8.4315677285194, 'freq': 224.36461868286, 'tridDur': 0.86605371832848, 'amp': 0.21 );
)

(
~padovanPreset = ( 'roomSize': 5.2112172245979, 'freq': 299.78749885559, 'tridDur': 0.8859096467495, 'amp': 0.21) ;
)

(
~padovanPreset = (amp: 0.21, tridDur: rrand(0.65, 1), freq: rrand(165, 320.2), roomSize: rrand(0.5, 9))
// rrand
)


(
Ndef(\padovan, {
	// amp = 0.21, tridDur = 1, freq = 165, roomSize = 9;

	var sig, env, input, mod, grainTr, sinMod;
	// env = Linen.kr(gate, 0.1, 1, 5, doneAction);
	env = EnvGen.ar(Env.asr(0,1, 1, 5));
	sig = SinOsc;
	mod = Trig.ar(
		Saw.ar(~padovanPreset[\freq]),
		~padovanPreset[\tridDur]
	);
	grainTr = sig.ar(mod * ~padovanPreset[\freq]);
	sinMod = sig.ar(mod);
	sig = GrainIn.ar(2, grainTr, grainTr / 2, sinMod, mod * sinMod, -1, mul: env);
	sig = GVerb.ar(sig, ~padovanPreset[\roomSize], mul: ~padovanPreset[\amp]);
	// OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
});
)

Ndef(\padovan).fadeTime_(12);

Ndef(\padovan).play(2);

Ndef(\padovan).release(12);

(
~batuhanPreset = ( 'rel': 4.7409770965576, 'att': 0.086210913658142, 'brfFreq2': 43, 'tridDur': 0.070336336493492, 'amp': 0.1, 'brfFreq1': 23.311715126038, 'sawFreq': 8.8473773002625, 'decayTime': 0.28642593860626 )
)

(
~batuhanPreset = (amp: 0.1, att: 0.01, rel: 5, tridDur: 0.125, decayTime: 0.3, sawFreq: 8, brfFreq1: 45.1, brfFreq2: 45)
// default
)

(
~batuhanPreset = ( 'rel': 4.1670804977417, 'att': 0.068860658407211, 'brfFreq2': 32, 'tridDur': 0.163059398531914, 'amp': 0.1, 'brfFreq1': 50.390841627121, 'sawFreq': 9.8006906509399, 'decayTime': 0.36700299620628 )
)

(
~batuhanPreset = (amp: 0.1, att: rrand(0.01, 0.1), rel: rrand(3.4, 5), tridDur: rrand(0.0625, 0.12), decayTime: rrand(0.23, 0.4), sawFreq: rrand(6.0, 18), brfFreq1: rrand(20, 45.1), brfFreq2: rrand(30, 45))
// rrand
)

(
Ndef(\batuhan, {
	// amp = 1, att = 0.01, rel = 5, tridDur = 0.125, decayTime = 0.3, sawFreq = 8, brfFreq1 = 45.1, brfFreq2 = 45;
	var sig, env, core;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(~batuhanPreset[\att], 1, ~batuhanPreset[\rel]));
	core = Duty.kr(~batuhanPreset[\tridDur], 0, Drand([0, Drand((0.4,0.5..1))], inf));
	sig = Decay2.kr(
		core,
		0.01,
		~batuhanPreset[\decayTime]
	);
	sig = Saw.ar(~batuhanPreset[\sawFreq], sig) ** 1.5;
	sig = BRF.ar(sig, core * 20 + [~batuhanPreset[\brfFreq1], ~batuhanPreset[\brfFreq2]], 0.1);
	sig = LeakDC.ar(sig).tanh * env * ~batuhanPreset[\amp];
	// OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
});
)

Ndef(\batuhan).fadeTime_(19);

Ndef(\batuhan).play(2);

Ndef(\batuhan).release(10);

(
~nozkurtPreset = (amp: 0.21, att: 0.01, rel: 5, sinFreq: 55, impMin: 0.0002, impMax: 0.7, impFreq: 8);
// default
)

(
~nozkurtPreset = ( 'impMin': 0.0003625140786171, 'att': 0.043915095329285, 'rel': 5, 'impFreq': 13, 'impMax': 0.64299078464508, 'amp': 0.21, 'sinFreq': 56 )
-> Ndef('nozkurt')
)

(
~nozkurtPreset = ( 'impMin': 0.00020394860506058, 'att': 0.012375417947769, 'rel': 5, 'impFreq': 14, 'impMax': 0.31409510111809, 'amp': 0.21, 'sinFreq': 55 )
)

(
~nozkurtPreset = (amp: 0.21, att: rrand(0.01, 0.1), rel: 5, sinFreq: rrand(55, 90), impMin: rrand(0.0002, 0.0005), impMax: rrand(0.254, 0.7), impFreq: rrand(8, 18));
// rrand
)

(
Ndef(\nozkurt, {
	// amp = 1, att = 0.01, rel = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8;
	var sig, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(~nozkurtPreset[\att], 1, ~nozkurtPreset[\rel]));
	sig = SinOsc.ar(~nozkurtPreset[\sinFreq]).tanh;
	delayTime = TExpRand.ar(~nozkurtPreset[\impMin], ~nozkurtPreset[\impMax], Impulse.ar(~nozkurtPreset[\impFreq])).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	sig = sig * env * ~nozkurtPreset[\amp];
	// OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
});
)

Ndef(\nozkurt).fadeTime_(9);

Ndef(\nozkurt).play(2);

Ndef(\nozkurt).release(10);

(
~tirgoPreset = (amp: 0.21, att: 0.01, rel: 5, blipFreqMod: 2, blipHarmo: 400, brfFreq: 150, brfRq: 2);
// default
)

(
~tirgoPreset = ( 'brfRq': 0.93783041238785, 'att': 0.044967068433762, 'rel': 4, 'brfFreq': 326, 'amp': 0.21, 'blipHarmo': 471, 'blipFreqMod': 3.0236197412014 );
)

(
~tirgoPreset = ( 'brfRq': 1.7299792766571, 'att': 0.020413483381271, 'rel': 3, 'brfFreq': 237,  'amp': 0.21, 'blipHarmo': 201, 'blipFreqMod': 0.87983870506287 );
)

(
~tirgoPreset = ( 'brfRq': 1.8334934711456, 'att': 0.091781142950058, 'rel': 4, 'brfFreq': 298, 'amp': 0.21, 'blipHarmo': 515, 'blipFreqMod': 2.7309162318707);
)

(
~tirgoPreset = (amp: 0.21, att: rrand(0.01, 0.1), rel: rrand(3,5), blipFreqMod: rrand(0.75, 4), blipHarmo: rrand(200, 600), brfFreq: rrand(150, 400), brfRq: rrand(0.9, 2))
// rrand
)

(
Ndef(\tirgo, {
	// amp = 1, att = 0.01, rel = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(~tirgoPreset[\att], 1, ~tirgoPreset[\rel]));
	noise = PinkNoise.ar(1!2);
	rainStep = noise + Blip.ar(noise + ~tirgoPreset[\blipFreqMod], ~tirgoPreset[\blipHarmo]);
	rainStep = BRF.ar(
		rainStep,
		~tirgoPreset[\brfFreq],
		~tirgoPreset[\brfRq],
		0.1
	);
	thunder = LPF.ar(FreeVerb2.ar(*LPF.ar(noise + 0.2 * Dust.ar(0.1), 60) ++ [1, 1, 0.2, 1e4]).tanh, 2000);
	sig = rainStep + thunder;
	sig = sig * env * ~tirgoPreset[\amp];
	// OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
});
)

Ndef(\tirgo).fadeTime_(9);

Ndef(\tirgo).play(2);

Ndef(\tirgo).release(12);


(
~lmcdPreset = (amp: 0.21, att: 0.01, rel: 5, trigDur: 0.1, lfCubTu: 1, hpfFreq: 440);
// default
)

(
~lmcdPreset = ( 'att': 0.036224783658981, 'hpfFreq': 440, 'lfCubTu': 0.83353449106216, 'rel': 4.0325203537941, 'trigDur': 0.067111976146698, 'amp': 0.21 )
)

(
~lmcdPreset = ( 'att': 0.080523428916931, 'hpfFreq': 440, 'lfCubTu': 0.96023582220078, 'rel': 4.3934026360512, 'trigDur': 0.036587396860123, 'amp': 0.21 )
)

(
~lmcdPreset = ( 'att': 0.054452003240585, 'hpfFreq': 440, 'lfCubTu': 0.2589919090271, 'rel': 4.8915323615074, 'trigDur': 0.012462729215622, 'amp': 0.21 )
)

(
~lmcdPreset = (amp: 0.21, att: rrand(0.01, 0.1), rel: rrand(2.5, 5), trigDur: rrand(0.01, 0.1), lfCubTu: rrand(0.1, 1), hpfFreq: 440);
// rrand
)

(
Ndef(\lmcd, {
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(~lmcdPreset[\att], 1, ~lmcdPreset[\rel]));
	sig = Duty.kr(~lmcdPreset[\trigDur], 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * ~lmcdPreset[\lfCubTu]);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, ~lmcdPreset[\hpfFreq]).clip2 / 9;
	sig = sig * env;
	sig = Splay.ar(sig, 1, ~lmcdPreset[\amp]);
	// OffsetOut.ar(out, sig);
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
});
)

Ndef(\lmcd).fadeTime_(10);

Ndef(\lmcd).play(2);

Ndef(\lmcd).release(12);

// pb syntaxe ?

(
~duryGenePreset = (out: 2, amp: 0.1, atk: 0.001, rls: 0.2, sustain: 1, impFreq1: 0.02, impFreq2: 0.04, smooth1: 4, smooth2: 1.7, smooth3: 0.9)
) // default

(
~duryGenePreset = (amp: 0.1, atk: rrand(0.0005, 0.001), rls: rrand(0.15, 0.25), sustain: 1, impFreq1: rrand(0.02, 0.1), impFreq2: rrand(0.04, 0.15), smooth1: rrand(0.5, 4), smooth2: rrand(0.7, 2), smooth3: rrand(0.65, 0.8)) // rrand
)

// ERROR: Message '*' not understood.

(
Ndef(\duryGene, {
    var snd, rep, repCh, randNum, fac, fac1, fac2, fac3;

    rep = [4, 8, 16, 24, 32];
	repCh = TChoose.kr(Impulse.kr(~duryGenePreset[\impFreq1]), rep);
    randNum = [

        54, 60, 66, 72, 81, 90, 96, 102,
        108, 128, 132, 144, 162, 180, 192, 204,
        216, 240, 264, 288, 324, 360, 384, 408,
        432, 480, 528, 576, 648, 720, 768, 816,
        864, 960, 1056, 1152, 1296, 1440, 1536, 1632,
        1728, 1920, 2112, 2304, 2592, 2880, 3072, 3264,
        3456, 3840, 4224, 4608, 5184, 5760, 6144, 6528,
        6912, 7680, 8448, 9216, 10368, 11520, 12288, 528

    ];
    fac = [1, 10, 100, 1000];
	fac1 = Lag2.kr(TChoose.kr(Impulse.kr(~duryGenePreset[\impFreq2]), fac), ~duryGenePreset[\smooth1]);
	fac2 = Lag3.kr(TChoose.kr(Impulse.kr(~duryGenePreset[\impFreq1] * 0.76), fac), ~duryGenePreset[\smooth2]);
	fac3 = Lag2.kr(TChoose.kr(Impulse.kr(~duryGenePreset[\impFreq2] * 0.86), fac), ~duryGenePreset[\smooth3]);

    snd = Mix.fill(8, { arg i;
        var detune;
        var saw;
        var tri;
        var sig;
        detune = LFNoise1.kr(0.003 + Rand(0, 0.9)).range(0.1, 1 + Rand(0, 250.0)) * Rand(0, 2.0) * TChoose.kr(Impulse.kr(0), [1,-1]);
        tri = LFTri.ar(TChoose.kr(Impulse.kr(0), randNum) * ( 1 + ( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac1) * TChoose.kr(Impulse.kr(0), randNum) / fac2 )) + detune, Rand(0, 1)/*, 0.25*/);
        saw = RLPF.ar(Saw.ar(TChoose.kr(Impulse.kr(0), randNum) * 0.01 + detune, 0.75), TChoose.kr(Impulse.kr(0), randNum), Rand(0, 2));
        saw = TChoose.kr(Impulse.kr(0), [
            saw,
            saw.fold2( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(0.1, 1) ),
            saw.wrap2( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(0.1, 1) ),
            saw *  SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / 2),
            ( saw *  SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(1, 20) ).tanh / 2
        ]);
        sig = (tri + saw) * EnvGen.kr(Env.asr(rrand(4,20), 1, 1/repCh);
        sig = Limiter.ar(sig * 1/(i + 0.1));
    );

		snd = (snd * ~duryGenePreset[\amp]);
});
})
)

Ndef(\duryGene).play(2);

Ndef(\duryGene).release(8);

Ndef(\duryGene).fadeTime_(8);

// en cours

(
~gcdFuncPreset = (out: 0, amp: 0.2, pan: 0, atk: 0.001, rls: 0.2, sustain: 1, thr: 0.1);
) // default

(
~gcdFuncPreset = (out: 0, amp: 0.3, pan: 0, atk: rrand(0.001, 0.1), rls: rrand(0.15,0.25), sustain: 1, thr: 0.1);
) // rrand


(
Ndef(\gcdFunc, {
    var sig, src, gcdFunc, env;

	env = EnvGen.kr(Env.asr(~gcdFuncPreset[\atk], 1, ~gcdFuncPreset[\rls]), gate: 1, timeScale: ~gcdFuncPreset[\sustain]);

    gcdFunc = { |a| (a.size > 2).if { gcd(a[0], gcdFunc.(a.drop(1))) } { gcd(a[0], a[1]) } };

    src = { SinOsc.ar([40, 51], LFDNoise3.ar(0.05).range(0, 2pi)).range(-4, 4) } ! 4;
    sig = gcdFunc.(src);
	sig = Limiter.ar(LPF.ar(LeakDC.ar(Splay.ar(sig)), 10000), ~gcdFuncPreset[\thr]).clip2(~gcdFuncPreset[\thr]);
	sig = (sig * env * ~gcdFuncPreset[\amp]);
	// OffsetOut.ar(out, sig);
});
)

Ndef(\gcdFunc).play(2);

Ndef(\gcdFunc).release(6);

Ndef(\gcdFunc).fadeTime_(6);


(
~westPreset = (fadeIn: 0.01, fadeOut: 0.01, freq: 220, pitchBendRatio: 1, glide: 0, fm1Ratio: 0.66, fm2Ratio: 3.3, fm1Amount: 0.0, fm2Amount: 0.0, vel: 0.7, pressure: 0, timbre: 0, waveShape: 0, waveFolds: 0, envType: 0, attack: 0.04, peak: 10000, decay: 1, amp: 1, lfoShape: 0, lfoFreq: 0.5, lfoToFreqAmount: 0, lfoToWaveShapeAmount: 0, lfoToWaveFoldsAmount: 0, lfoToFm1Amount: 0, lfoToFm2Amount: 0, lfoToAttackAmount: 0, lfoToPeakAmount: 0, lfoToDecayAmount: 0, lfoToReverbMixAmount: 0, drift: 0, dur: 10, t_gate: 1, /*gate=1, */ killGate: 1 );
// default
)

(
~westPreset = (fadeIn: rrand(0.005, 0.01), fadeOut: rrand(0.005, 0.01), freq: rrand(60,420), pitchBendRatio: rrand(0.3,1), glide: rrand(0.0,1), fm1Ratio: rrand(0.1, 0.66), fm2Ratio: rrand(1, 3.3), fm1Amount: 0.0, fm2Amount: 0.0, vel: 0.7, pressure: 0, timbre: 0, waveShape: 0, waveFolds: 0, envType: 0, attack: 0.04, peak: 10000, decay: 1, amp: 1, lfoShape: 0, lfoFreq: 0.5, lfoToFreqAmount: 0, lfoToWaveShapeAmount: 0, lfoToWaveFoldsAmount: 0, lfoToFm1Amount: 0, lfoToFm2Amount: 0, lfoToAttackAmount: 0, lfoToPeakAmount: 0, lfoToDecayAmount: 0, lfoToReverbMixAmount: 0, drift: 0, dur: 10, t_gate: 1, /*gate=1, */ killGate: 1 );
// rrand
) ;


// Ne fonctionne pas
// ERROR: Primitive '_ClipFloat' failed.
// Wrong type.
// RECEIVER: 220.0

(
Ndef(\west, {
	var i_nyquist = SampleRate.ir * 0.5, signal, controlLag = 0.005, i_numHarmonics = 44,
	modFreq, mod1, mod2, mod1Index, mod2Index, mod1Freq, mod2Freq, sinOsc, triOsc, additiveOsc, additivePhase,
	filterEnvVel, filterEnvLow, lpgEnvelope, lpgSignal, asrEnvelope, asrFilterFreq, asrSignal, killEnvelope, i_driftRate = 0.15, maxDecay=8;

	// Make lfos
	var lfo = Select.kr(~westPreset[\lfoShape], [
		LFTri.kr(~westPreset[\lfoFreq]),
		LFSaw.kr(~westPreset[\lfoFreq]),
		LFPulse.kr(~westPreset[\lfoFreq]),
		LFDNoise0.kr(~westPreset[\lfoFreq]* 2)
	]);

	var lfoArray = Array.fill(9, 0);
	lfoArray[0] = (lfo * ~westPreset[\lfoToFreqAmount] * 18).midiratio; // Freq ratio
	lfoArray[1] = (lfo * ~westPreset[\lfoToWaveShapeAmount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift]); // Wave Shape
	lfoArray[2] = ((lfo * ~westPreset[\lfoToWaveFoldsAmount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift])) * 2; // Wave Folds
	lfoArray[3] = ((lfo * ~westPreset[\lfoToFm1Amount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift])) * 0.5; // FM1 Amount
	lfoArray[4] = ((lfo * ~westPreset[\lfoToFm2Amount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift])) * 0.5; // FM2 Amount
	lfoArray[5] = ((lfo * ~westPreset[\lfoToAttackAmount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift])) * 2.2; // Attack
	lfoArray[6] = (((lfo * ~westPreset[\lfoToPeakAmount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift])) * 24).midiratio; // Peak multiplier
	lfoArray[7] = ((lfo * ~westPreset[\lfoToDecayAmount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift])) * 2.2; // Decay
	lfoArray[8] = (lfo * ~westPreset[\lfoToReverbMixAmount]) + LFNoise1.kr(freq: i_driftRate, mul: ~westPreset[\drift]); // Reverb Mix


	// LFO ins
	~westPreset[\freq] = (~westPreset[\freq] * lfoArray[0]).clip(0, i_nyquist);
	~westPreset[\waveShape] = (~westPreset[\waveShape] + lfoArray[1]).clip(0, 1);
	~westPreset[\waveFolds] = (~westPreset[\waveFolds] + lfoArray[2]).clip(0, 3);
	~westPreset[\fm1Amount] = (~westPreset[\fm1Amount] + lfoArray[3]).clip(0, 1);
	~westPreset[\fm2Amount] = (~westPreset[\fm2Amount] + lfoArray[4]).clip(0, 1);
	~westPreset[\attack] = (~westPreset[\attack] + lfoArray[5]).clip(0.003, 8);
	~westPreset[\peak] = (~westPreset[\peak] * lfoArray[6]).clip(100, 10000);
	~westPreset[\decay] = (~westPreset[\decay] + lfoArray[7]).clip(0.01, maxDecay);

	// Lag inputs
	~westPreset[\freq] = Lag.kr(~westPreset[\freq] * ~westPreset[\pitchBendRatio], 0.007 + ~westPreset[\glide]);
	~westPreset[\fm1Ratio] = Lag.kr(~westPreset[\fm1Ratio], controlLag);
	~westPreset[\fm2Ratio] = Lag.kr(~westPreset[\fm2Ratio], controlLag);
	~westPreset[\fm1Amount] = Lag.kr(~westPreset[\fm1Amount].squared, controlLag);
	~westPreset[\fm2Amount] = Lag.kr(~westPreset[\fm2Amount].squared, controlLag);

	~westPreset[\vel] = Lag.kr(~westPreset[\vel], controlLag);
	~westPreset[\waveShape] = Lag.kr(~westPreset[\waveShape], controlLag);
	~westPreset[\waveFolds] = Lag.kr(~westPreset[\waveFolds], controlLag);
	~westPreset[\attack] = Lag.kr(~westPreset[\attack], controlLag);
	~westPreset[\peak] = Lag.kr(~westPreset[\peak], controlLag);
	~westPreset[\decay] = Lag.kr(~westPreset[\decay], controlLag);

	// Modulators
	~westPreset[\mod1Index] = ~westPreset[\fm1Amount] * 22;
	~westPreset[\mod1Freq] = ~westPreset[\freq] * ~westPreset[\fm1Ratio] * LFNoise2.kr(freq: 0.1, mul: 0.001, add: 1);
	~westPreset[\mod1] = SinOsc.ar(freq: ~westPreset[\mod1Freq], phase: 0, mul: ~westPreset[\mod1Index] * ~westPreset[\mod1Freq], add: 0);
	~westPreset[\mod2Index] = ~westPreset[\fm2Amount] * 12;
	~westPreset[\mod2Freq] = ~westPreset[\freq] * ~westPreset[\fm2Ratio] * LFNoise2.kr(freq: 0.1, mul: 0.005, add: 1);
	~westPreset[\mod2] = SinOsc.ar(freq: ~westPreset[\mod2Freq], phase: 0, mul: ~westPreset[\mod2Index] * ~westPreset[\mod2Freq], add: 0);
	~westPreset[\modFreq] = ~westPreset[\freq] + ~westPreset[\mod1] + ~westPreset[\mod2];

	// Sine and triangle
	sinOsc = SinOsc.ar(freq: modFreq, phase: 0, mul: 0.5);
	triOsc = VarSaw.ar(freq: modFreq, iphase: 0, width: 0.5, mul: 0.5);

	// Additive square and saw
	additivePhase = LFSaw.ar(freq: modFreq, iphase: 1, mul: pi, add: pi);
	additiveOsc = Mix.fill(i_numHarmonics, {
		arg index;
		var harmonic, harmonicFreq, harmonicCutoff, attenuation;

		harmonic = index + 1;
		harmonicFreq = ~westPreset[\freq] * harmonic;
		harmonicCutoff = i_nyquist - harmonicFreq;

		// Attenuate harmonics that will go over nyquist once FM is applied
		attenuation = Select.kr(index, [1, // Save the fundamental
			(harmonicCutoff - (harmonicFreq * 0.25) - harmonicFreq).expexp(0.000001, harmonicFreq * 0.5, 0.000001, 1)]);

		(sin(additivePhase * harmonic % 2pi) / harmonic) * attenuation * (harmonic % 2 + ~westPreset[\waveShape].linlin(0.666666, 1, 0, 1)).min(1);
	}
	);

	// Mix carriers
	signal = LinSelectX.ar(~westPreset[\waveShape] * 3, [sinOsc, triOsc, additiveOsc]);

	// Fold
	signal = Fold.ar(in: signal * (1 + (~westPreset[\timbre] * 0.5) + (~westPreset[\waveFolds] * 2)), lo: -0.5, hi: 0.5);

	// Hack away some aliasing
	signal = LPF.ar(in: signal, freq: 12000);

	// Noise
	signal = signal + PinkNoise.ar(mul: 0.003);

	// LPG
	filterEnvVel = ~westPreset[\vel].linlin(0, 1, 0.5, 1);
	filterEnvLow = (~westPreset[\peak] * filterEnvVel).min(300);

	lpgEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.003, ~westPreset[\decay]], curve: [4, -20]), gate: ~westPreset[\t_gate], timeScale: ~westPreset[\dur]);
	lpgSignal = RLPF.ar(in: signal, freq: lpgEnvelope.linlin(0, 1, filterEnvLow, ~westPreset[\peak] * filterEnvVel), rq: 0.9);
	lpgSignal = lpgSignal * EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.002, ~westPreset[\decay]], curve: [4, -10]), gate: ~westPreset[\t_gate], timeScale: ~westPreset[\dur]);

	// ASR with 4-pole filter
	asrEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [~westPreset[\attack], ~westPreset[\decay]], curve: -4, releaseNode: 1), gate: ~westPreset[\gate]);
	asrFilterFreq = asrEnvelope.linlin(0, 1, filterEnvLow, ~westPreset[\peak ]* filterEnvVel);
	asrSignal = RLPF.ar(in: signal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = RLPF.ar(in: asrSignal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = asrSignal * EnvGen.ar(envelope: Env.asr(attackTime: ~westPreset[\attack], sustainLevel: 1, releaseTime: ~westPreset[\decay], curve: -4)/*, gate: gate*/);

	signal = Select.ar(~westPreset[\envType], [lpgSignal, asrSignal]);

	signal = signal * ~westPreset[\vel].linlin(0, 1, 0.2, 1) ;

	// Saturation amp
	signal = tanh(signal * ~westPreset[\pressure].linlin(0, 1, 1.5, 3) * ~westPreset[\amp]).softclip;

	// main Envelope
	signal = signal * EnvGen.kr(
		Env([0.0,1.0,1.0,0], [~westPreset[\fadeIn], ~westPreset[\fadeOut]], releaseNode: 2)
		/*,
		gate: ~westPreset[\killGate]
		doneAction: doneAction*/
	);

	// Pan
	// signal = Pan2.ar(signal, pan);

	// OffsetOut.ar(out, signal);

});
)


Ndef(\west).play(2);

Ndef(\west).release(9);

Ndef(\west).fadeTime_(8);