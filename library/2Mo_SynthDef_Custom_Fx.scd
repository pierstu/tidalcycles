(
~dirt.addModule('elements', { |dirtEvent|
	dirtEvent.sendSynth('elements' ++ ~dirt.numChannels,
		[
			elementspitch: ~elementspitch,
			elementsstrength: ~elementsstrength,
			elementscontour: ~elementscontour,
			elementsbowlevel: ~elementsbowlevel,
			elementsblowlevel: ~elementsblowlevel,
			elementsstrikelevel: ~elementsstrikelevel,
			elementsflow: ~elementsflow,
			elementsmallet: ~elementsmallet,
			elementsbowtimb: ~elementsbowtimb,
			elementsblowtimb: ~elementsblowtimb,
			elementsstriketimb: ~elementsstriketimb,
			elementsgeom: ~elementsgeom,
			elementsbright: ~elementsbright,
			elementsdamp: ~elementsdamp,
			elementspos: ~elementspos,
			elementsspace: ~elementsspace,
			elementsmodel: ~elementsmodel,
			elementseasteregg: ~elementseasteregg,
			out: ~out
		]
	)
}, {~elementsstrength.notNil});

SynthDef("elements" ++ ~dirt.numChannels, {|out,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,
	elementspitch=48, elementsstrength=0.5, elementscontour=0.2, elementsbowlevel=0,elementsblowlevel=0, elementsstrikelevel=0,
	elementsflow=0.5, elementsmallet=0.5, elementsbowtimb=0.5, elementsblowtimb=0.5,
	elementsstriketimb=0.5, elementsgeom=0.25, elementsbright=0.5, elementsdamp=0.7, elementspos=0.2, elementsspace=0.3, elementsmodel=0,
	elementseasteregg=0|
	var signal = In.ar(out, ~dirt.numChannels);
	ReplaceOut.ar(out, MiElements.ar(
		blow_in: signal,
		strike_in: signal,
		gate: 1,
		pit: elementspitch,
		strength: elementsstrength,
		contour: elementscontour,
		bow_level: elementsbowlevel,
		blow_level: elementsblowlevel,
		strike_level: elementsstrikelevel,
		flow: elementsflow,
		mallet: elementsmallet,
		bow_timb: elementsbowtimb,
		blow_timb: elementsblowtimb,
		strike_timb: elementsstriketimb,
		geom: elementsgeom,
		bright: elementsbright,
		damp: elementsdamp,
		pos: elementspos,
		space: elementsspace,
		model: elementsmodel,
		easteregg: elementseasteregg
	));
}).add;

~dirt.addModule('mu', { |dirtEvent|
	dirtEvent.sendSynth('mu' ++ ~dirt.numChannels,
		[ mu: ~mu, out: ~out ]
	)
}, {~mu.notNil});

SynthDef("mu" ++ ~dirt.numChannels, {|out,mu=0|
	var signal = In.ar(out, ~dirt.numChannels);
	ReplaceOut.ar(out, MiMu.ar(signal, mu));
}).add;

~dirt.addModule('rings', { |dirtEvent|
	dirtEvent.sendSynth('rings' ++ ~dirt.numChannels,
		[
			ringstrig: ~ringstrig,
			ringsfreq: ~ringsfreq,
			ringsstruct: ~ringsstruct,
			ringsbright: ~ringsbright,
			ringsdamp: ~ringsdamp,
			ringspos: ~ringspos,
			ringsmodel: ~ringsmodel,
			ringspoly: ~ringspoly,
			ringsinternal: ~ringsinternal,
			ringseasteregg: ~ringseasteregg,
			out: ~out
		]
	)
}, {~ringsbright.notNil});

SynthDef("rings" ++ ~dirt.numChannels, { |out, ringsfreq=440,ringsstruct=0,ringsbright=0,ringsdamp=0.5,ringspos=0,ringsmodel=0,ringspoly=0,ringsinternal=0,ringseasteregg=0,ringsbypass=0|
	var signal = In.ar(out, ~dirt.numChannels);
	signal = MiRings.ar(
		signal,
		trig: ringsinternal,
		pit: ringsfreq.cpsmidi,
		struct: ringsstruct,
		bright: ringsbright,
		damp: ringsdamp,
		pos: ringspos,
		model: ringsmodel,
		poly: ringspoly,
		intern_exciter: ringsinternal,
		easteregg: ringseasteregg
	);
	ReplaceOut.ar(out, signal)
}).add;

~dirt.addModule('ripples', { |dirtEvent|
	dirtEvent.sendSynth('ripples' ++ ~dirt.numChannels,
		[
			ripplescf: ~ripplescf,
			ripplesreson: ~ripplesreson,
			ripplesdrive: ~ripplesdrive,
			out: ~out
		]
	)
}, {~ripplescf.notNil});

SynthDef("ripples" ++ ~dirt.numChannels, { |out, ripplescf=0, ripplesreson=0, ripplesdrive=1|
	var signal = In.ar(out, ~dirt.numChannels);
	signal = MiRipples.ar(
		signal,
		cf: ripplescf,
		reson: ripplesreson,
		drive: ripplesdrive,
	);
	ReplaceOut.ar(out, signal)
}).add;

~dirt.addModule('warps', { |dirtEvent|
	dirtEvent.sendSynth('warps' ++ ~dirt.numChannels,
		[
			warpsalgo: ~warpsalgo,
			warpstimb: ~warpstimb,
			warpsosc: ~warpsosc,
			warpsfreq: ~warpsfreq,
			warpsvgain: ~warpsvgain,
			warpseasteregg: ~warpseasteregg,
			out: ~out
		]
	)
}, {~warpsalgo.notNil});

SynthDef("warps" ++ ~dirt.numChannels, { |out, warpsalgo=0, warpstimb=0, warpsosc=1, warpsfreq=440, warpsvgain=1, warpseasteregg=0|
	var signal = In.ar(out, ~dirt.numChannels);
	signal = MiWarps.ar(
		modulator: signal,
		algo: warpsalgo,
		lev1: 1,
		lev2: 1,
		timb: warpstimb,
		osc: warpsosc,
		freq: warpsfreq,
		vgain: warpsvgain,
		easteregg: warpseasteregg
	);
	ReplaceOut.ar(out, signal)
}).add;

~dirt.addModule('mi_verb', { |dirtEvent|
	dirtEvent.sendSynth('mi_verb' ++ ~dirt.numChannels,
		[
			verbwet: ~verbwet,
			verbtime: ~verbtime,
			verbdamp: ~verbdamp,
			verbhp: ~verbhp,
			verbfreeze: ~verbfreeze,
			verbdiff: ~verbdiff,
			verbgain: ~verbgain,
			out: ~out
		]
	)
}, {~verbwet.notNil});

SynthDef("mi_verb" ++ ~dirt.numChannels, { |out, verbwet=0, verbtime=0, verbdamp=0, verbhp=0, verbfreeze=0, verbdiff=0.625, verbgain=1|
	var signal = In.ar(out, ~dirt.numChannels);
	ReplaceOut.ar(out, MiVerb.ar(
		signal,
		verbtime,
		verbwet,
		verbdamp,
		verbhp,
		verbfreeze,
		verbdiff
	) * verbgain);
}, [\ir]).add;

~dirt.addModule('mi_clouds', { |dirtEvent|
	dirtEvent.sendSynth('mi_clouds' ++ ~dirt.numChannels,
		[
			cloudspitch: ~cloudspitch,
			cloudspos: ~cloudspos,
			cloudssize: ~cloudssize,
			cloudsdens: ~cloudsdens,
			cloudstex: ~cloudstex,
			cloudswet: ~cloudswet,
			cloudsgain: ~cloudsgain,
			cloudsspread: ~cloudsspread,
			cloudsrvb: ~cloudsrvb,
			cloudsfb: ~cloudsfb,
			cloudsfreeze: ~cloudsfreeze,
			cloudsmode: ~cloudsmode,
			cloudslofi: ~cloudslofi,
			out: ~out
		]
	)
}, {~cloudspitch.notNil});

SynthDef("mi_clouds" ++ ~dirt.numChannels, { |out, cloudspitch=0, cloudspos=0, cloudssize=0, cloudsdens=0, cloudstex=0, cloudswet=0, cloudsgain=3, cloudsspread=0, cloudsrvb=0, cloudsfb=0, cloudsfreeze=0, cloudsmode=0, cloudslofi=0|
	var signal = In.ar(out, ~dirt.numChannels);
	ReplaceOut.ar(out, MiClouds.ar(
		inputArray: signal,
		pit: cloudspitch,
		pos: cloudspos,
		size: cloudssize,
		dens: cloudsdens,
		tex: cloudstex,
		drywet: cloudswet,
		in_gain: cloudsgain,
		spread: cloudsspread,
		rvb: cloudsrvb,
		fb: cloudsfb,
		freeze: cloudsfreeze,
		mode: cloudsmode,
		lofi: cloudslofi
	));
}, [\ir]).add;

~dirt.addModule('greyHole', { |dirtEvent|
	dirtEvent.sendSynth('greyHole' ++ ~dirt.numChannels,
		[
			ghdeltime: ~ghdeltime,
			ghdamp: ~ghdamp,
			ghsize: ~ghsize,
			ghdiff: ~ghdiff,
			ghfb: ~ghfb,
			ghmoddepth: ~ghmoddepth,
			ghmodfreq: ~ghmodfreq,
			ghwet: ~ghwet,
			out: ~out
		]
	)
}, {~ghdeltime.notNil});

SynthDef("greyHole" ++ ~dirt.numChannels, { |out, ghdeltime = 2, ghdamp = 0, ghsize = 1, ghdiff = 0.707, ghfb = 0.7, ghmoddepth = 0.1, ghmodfreq = 2, ghwet = 1 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = Greyhole.ar(
		dry,
		delayTime: ghdeltime,
		damp: ghdamp,
		size: ghsize,
		diff: ghdiff,
		feedback: ghfb,
		modDepth: ghmoddepth,
		modFreq: ghmodfreq,
	);
	var sig = SelectX.ar(ghwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;


// ajout 230324

~dirt.addModule('anaPhaserMod', { |dirtEvent|
	dirtEvent.sendSynth('anaPhaser' ++ ~dirt.numChannels,
		[
			phaserSkew: ~phaserSkew,
			phaserMod: ~phaserMod,
			phaserStages: ~phaserStages,
			phaserwet: ~phaserwet,
			out: ~out
		]
	)
}, {~phaserSkew.notNil});

SynthDef("anaPhaser" ++ ~dirt.numChannels, {|out, phaserSkew = 0, phaserMod = 0.5, phaserStages = 8, phaserwet = 1 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = AnalogPhaserMod.ar(
		dry,
		skew: phaserSkew,
		modulation: phaserMod,
		stages: phaserStages
	);
	var sig = SelectX.ar(phaserwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;

~dirt.addModule('diodef', { |dirtEvent|
	dirtEvent.sendSynth('diodef' ++ ~dirt.numChannels,
		[
			out: ~out,
			diodeffreq: ~diodeffreq,
			diodefres: ~diodefres,
			diodefdrive: ~diodefdrive,
			diodefwet: ~diodefwet
		]
	)
}, {~diodeffreq.notNil});

SynthDef("diodef" ++ ~dirt.numChannels, {|out, diodefwet = 1, diodeffreq = 500, diodefres = 0.1, diodefdrive = 0 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = VADiodeFilter.ar(
		dry,
		freq: diodeffreq,
		res: diodefres,
		overdrive: diodefdrive
	);
	var sig = SelectX.ar(diodefwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;


~dirt.addModule('korgf', { |dirtEvent|
	dirtEvent.sendSynth('korgf' ++ ~dirt.numChannels,
		[
			out: ~out
			korgfwet: ~korgfwet,
			korgffreq: ~korgffreq,
			korgfres: ~korgfres,
			korgfdrive: ~korgfdrive,
			korgftype: ~korgftype
		]
	)
}, {~korgfwet.notNil});

SynthDef("korgf" ++ ~dirt.numChannels, {|out, korgffreq = 500, korgfres = 0.1, korgfdrive = 0, korgftype = 0, korgfwet = 1 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = VAKorg35.ar(
		dry,
		freq: korgffreq,
		res: korgfres,
		overdrive: korgfdrive,
		type: korgftype
	);
	var sig = SelectX.ar(korgfwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;


~dirt.addModule('ladderf', { |dirtEvent|
	dirtEvent.sendSynth('ladderf' ++ ~dirt.numChannels,
		[
			ladderffreq: ~ladderffreq,
			ladderres: ~ladderres,
			ladderdrive: ~ladderdrive,
			laddertype: ~laddertype,
			ladderwet: ~ladderwet,
			out: ~out
		]
	)
}, {~ladderwet.notNil});

SynthDef("ladderf" ++ ~dirt.numChannels, {|out, ladderffreq = 500, ladderres = 0.1, ladderdrive = 0.0, laddertype = 0, ladderwet = 1 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = VALadder.ar(
		dry,
		freq: ladderffreq,
		res: ladderres,
		overdrive: ladderdrive,
		type: laddertype
	);
	var sig = SelectX.ar(ladderwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;


~dirt.addModule('semfilter', { |dirtEvent|
	dirtEvent.sendSynth('semfilter' ++ ~dirt.numChannels,
		[
			semwet: ~semwet,
			semfreq: ~semfreq,
			semres: ~semres,
			semtrans: ~semtrans,
			out: ~out
		]
	)
}, {~semtrans.notNil});

SynthDef("semfilter" ++ ~dirt.numChannels, {|out, semwet = 1, semfreq = 500, semres = 0.1, semtrans = 0|
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = VASEM12.ar(
		dry,
		freq: semfreq,
		res: semres,
		transition: semtrans
	);
	var sig = SelectX.ar(semwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;




~dirt.addModule('vadimfilter', { |dirtEvent|
	dirtEvent.sendSynth('vadimfilter' ++ ~dirt.numChannels,
		[
			vadimfreq: ~vadimfreq,
			vadimres: ~vadimres,
			vadimtype: ~vadimtype,
			out: ~out
		]
	)
}, {~vadimfreq.notNil});

SynthDef("vadimfilter" ++ ~dirt.numChannels, {|out, vadimfreq = 500, vadimres = 1.0, vadimtype = 0, vadimwet = 1 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = VadimFilter.ar(
		dry,
		freq: vadimfreq,
		resonance: vadimres,
		type: vadimtype
	);
	var sig = SelectX.ar(vadimwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;





~dirt.addModule('phasorModal', { |dirtEvent|
	dirtEvent.sendSynth('phasorModal' ++ ~dirt.numChannels,
		[
			phasorModalWet: ~phasorModalWet,
			phasorModalFreq: ~phasorModalFreq,
			phasorModalDecay: ~phasorModalDecay,
			phasorModalDamp: ~phasorModalDamp,
			out: ~out
		]
	)
}, {~phasorModalWet.notNil});

SynthDef("phasorModal" ++ ~dirt.numChannels, {|out, phasorModalFreq = 100, phasorModalDecay = 0.25, phasorModalDamp = 1, phasorModalWet = 1|
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = PhasorModal.ar(
		dry,
		freq: phasorModalFreq,
		decay: phasorModalDecay,
		damp: phasorModalDamp,
		amp: 0.5,
		phase: 0
	);
	var sig = SelectX.ar(phasorModalWet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;



~dirt.addModule('chowfilter', { |dirtEvent|
	dirtEvent.sendSynth('chowfilter' ++ ~dirt.numChannels,
		[
			chowffreq: ~chowffreq,
			chowq: ~chowq,
			chowfgain: ~chowfgain,
			chowfshape: ~chowfshape,
			chowfsat: ~chowfsat,
			chowwet: ~chowwet,
			out: ~out
		]
	)
}, {~chowwet.notNil});

SynthDef("chowfilter" ++ ~dirt.numChannels, {|out, chowwet = 1, chowffreq = 500, chowq = 0.5, chowfgain = 1, chowfshape = 5, chowfsat = 3 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = NonlinearFilter.ar(
		dry,
		freq: chowffreq,
		q: chowq,
		gain: chowfgain,
		shape: chowfshape,
		saturation: chowfsat
	);
	var sig = SelectX.ar(chowwet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;



~dirt.addModule('anaDist', { |dirtEvent|
	dirtEvent.sendSynth('anaDist' ++ ~dirt.numChannels,
		[
			distDrive: ~distDrive,
			distBias:~distBias,
			distLogain: ~distLogain,
			distHigain: ~distHigain,
			distFreq: ~distFreq,
			distOversample: ~distOversample,
			distWet: ~distWet,
			out: ~out
		]
	)
}, {~distWet.notNil});

SynthDef("anaDist" ++ ~dirt.numChannels, {|out, distDrive = 0.5, distBias = 0, distLogain = 0.1, distHigain = 0.1, distFreq = 600, distOversample = 0, distWet = 1|
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = AnalogVintageDistortion.ar(
		dry,
		drivegain: distDrive,
		bias: distBias,
		lowgain: distLogain,
		highgain: distHigain,
		shelvingfreq: distFreq,
		oversample: 0,
		// out: ~out
	);
	var sig = SelectX.ar(distWet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;


~dirt.addModule('anaTape', { |dirtEvent|
	dirtEvent.sendSynth('anaTape' ++ ~dirt.numChannels,
		[
			tapeBias: ~tapeBias,
			tapeSat: ~tapeSat,
			tapeDrive: ~tapeDrive,
			tapeWet: ~tapeWet,
			out: ~out
		]
	)
}, {~tapeBias.notNil});

SynthDef("anaTape" ++ ~dirt.numChannels, {|out, tapeBias = 0.5, tapeSat = 0.5, tapeDrive = 0.5, tapeWet = 1 |
	var dry = In.ar(out, ~dirt.numChannels);
	var wet = AnalogTape.ar(
		dry,
		bias: tapeBias,
		saturation: tapeSat,
		drive: tapeDrive,
		oversample: 1,
		mode: 0,
		// out: ~out
	);
	var sig = SelectX.ar(tapeWet, [dry, wet]);
	ReplaceOut.ar(out, sig);
}, [\ir]).add;



)