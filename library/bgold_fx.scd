~dirt.addModule('lpg', {|dirtEvent| dirtEvent.sendSynth("dirt_lpg" ++ ~dirt.numChannels,
[lpg: ~lpg, lpga: ~lpga, lpgr: ~lpgr, lpgg: ~lpgg, lpgres: ~lpgres, out: ~out])}, {~lpg.notNil});
SynthDef("dirt_lpg"++~dirt.numChannels, {|out, lpg, lpga=0.001, lpgr=0.010, lpgg=1.0, lpgres=0|
	var in = In.ar(out, ~dirt.numChannels);
	// var gate = Amplitude.ar(in*lpgg, lpga, lpgr);
	var gate = LagUD.ar(Amplitude.ar(in*lpgg, 0.001, 0.001), lpga, lpgr);
	var filt = RLPF.ar(in, gate.expexp(-60.dbamp, 0.dbamp, 20, 20000), 1.0 - lpgres);
	ReplaceOut.ar(out, SelectX.ar(lpg, [in, filt]));
}).add;

~dirt.addModule('whammy', {|dirtEvent| dirtEvent.sendSynth("dirt_whammy" ++ ~dirt.numChannels,
[whammy: ~whammy, whammyshift: ~whammyshift, whammyfreq: ~whammyfreq, whammydelay: ~whammydelay, sustain: ~sustain, out: ~out])}, {~whammy.notNil});
SynthDef("dirt_whammy"++~dirt.numChannels, {|out, whammy, whammyshift, whammyfreq, whammydelay, sustain|
	var in = In.ar(out, ~dirt.numChannels);
	var transpose = whammyshift + (12.0 * (whammyshift < 1e-6));
	var grainsize = 1.0 / (whammyfreq + (5.7 * (whammyfreq < 1e-6))); // 0.075 is a bit faster
	var grainfreq = XLine.ar(transpose.midiratio * 1.02, transpose.midiratio, sustain) / grainsize; // transpose / grainsize
	var deltime = whammydelay + (0.02 * (whammydelay < 1e-6)); // 0.05 down to zero?
	var sig = in;
	sig = DelayC.ar(sig, 1, LFSaw.ar(grainfreq, [1,0]) * grainsize / (-2.0) + deltime);
	sig = sig * SinOsc.ar(grainfreq, [-1.0,1.0]*pi/2).linlin(-1,1,0,1);
	sig = LeakDC.ar(sig);
	ReplaceOut.ar(out, SelectX.ar(whammy/2.0, [in, sig]));
}).add;

~dirt.addModule('schmidt', {|dirtEvent| dirtEvent.sendSynth("dirt_schmidt" ++ ~dirt.numChannels,
[schmidt: ~schmidt, out: ~out])}, {~schmidt.notNil});
SynthDef("dirt_schmidt"++~dirt.numChannels, {|out, schmidt|
	var in = In.ar(out, ~dirt.numChannels);
	var sig = in * Schmidt.ar(in, -0.1, 0.1);
	ReplaceOut.ar(out, SelectX.ar(schmidt, [in, sig]));
}).add;

~dirt.addModule('zpulse', {|dirtEvent| dirtEvent.sendSynth("dirt_zpulse" ++ ~dirt.numChannels,
[zpulse: ~zpulse, out: ~out])}, {~zpulse.notNil});
SynthDef("dirt_zpulse"++~dirt.numChannels, {|out, zpulse|
	var in = In.ar(out, ~dirt.numChannels);
	var sig = Blip.ar(ZeroCrossing.ar(in), numharm:5, mul:Amplitude.ar(in, 0,0));
	ReplaceOut.ar(out, SelectX.ar(zpulse, [in, sig]));
}).add;

~dirt.addModule('enc', {|dirtEvent| dirtEvent.sendSynth("dirt_enc" ++ ~dirt.numChannels,
[enc: ~enc, out: ~out])}, {~enc.notNil});
SynthDef("dirt_enc"++~dirt.numChannels, {|out, enc|
	var sig = In.ar(out, ~dirt.numChannels);
	/*var fs = [250, 300, 450, 610, 810, 1100, 1300, 1700];*/
	var fs = [60, 270, 200, 350] *.x [3, 7, 11, 17, 29, 41];
	var cutoff = clip(fs/100, 30, 60);
	var amps = LPF.ar(LPF.ar(Mix.ar(sig) * SinOsc.ar(fs), cutoff), cutoff);
	var recon = Mix.ar(2.0 * amps * SinOsc.ar(fs));
	ReplaceOut.ar(out, SelectX.ar(enc, [sig, recon]));
}).add;

~dirt.addModule('match', {|dirtEvent| dirtEvent.sendSynth("dirt_match" ++ ~dirt.numChannels,
[match: ~match, matchf: ~matchf, matchw: ~matchw, out: ~out])}, {~match.notNil});
SynthDef("dirt_match"++~dirt.numChannels, {|out, match, matchf=440, matchw=20|
	var in = In.ar(out, ~dirt.numChannels);
	var sig = LocalIn.ar(1);
	var adj = 1.0 * LPF.ar(sig * in, matchf*1.5);
	sig = SinOsc.ar(adj * matchw + matchf);
	LocalOut.ar(sig * 0.99);
	sig = SelectX.ar(match, [in, sig]);
	ReplaceOut.ar(out, sig);
}).add;

~dirt.addModule('median', {|dirtEvent| dirtEvent.sendSynth("dirt_median" ++ ~dirt.numChannels,
[median: ~median, out: ~out])}, {~median.notNil});
SynthDef("dirt_median"++~dirt.numChannels, {|out, median|
	ReplaceOut.ar(out, Median.ar(Select.kr(median*15, (0..15) * 2 + 1), In.ar(out, ~dirt.numChannels)));
}).add;

~dirt.addModule('comb', {|dirtEvent| dirtEvent.sendSynth("dirt_comb" ++ ~dirt.numChannels,
[comb: ~comb, combd: ~combd, combdiff: ~combdiff, out: ~out])}, {~comb.notNil});
SynthDef("dirt_comb"++~dirt.numChannels, {|out, comb, combd, combdiff|
	var sig= In.ar(out, ~dirt.numChannels);
	sig = sig + DelayL.ar(sig, 0.2, [combd/100+1e-4, (combd+combdiff)/100+1e-4], mul:comb);
	ReplaceOut.ar(out, sig);
}).add;

/*
~dirt.addModule('chunk', {|dirtEvent| dirtEvent.sendSynth("dirt_chunk" ++ ~dirt.numChannels,
[chunk: ~chunk, chunksharp: ~chunksharp, chunkspread: ~chunkspread, out: ~out])}, {~chunk.notNil});
SynthDef("dirt_chunk"++~dirt.numChannels, {|out, chunk, chunksharp, chunkspread|
	var sig = In.ar(out, ~dirt.numChannels);
	var scale = 2**(8-(8*(chunk**0.25)));
	var sharp = chunksharp + 2.0;
	sig = Array.fill(4, {|i| DelayL.ar(sig, 0.2, chunkspread*i/100)});
	sig = round(sig, 1/scale) + (sign(sig) * abs(sig - round(sig,1/scale))**sharp);
	sig = Mix.ar(sig) / (4-(4*chunkspread).clip(0,3));
	ReplaceOut.ar(out, sig);
}).add;
*/

~dirt.addModule('chorus2', {|dirtEvent| dirtEvent.sendSynth("dirt_chorus2" ++ ~dirt.numChannels,
[chorus2: ~chorus2, sustain: ~sustain, out: ~out])}, {~chorus2.notNil});
SynthDef("dirt_chorus2"++~dirt.numChannels, {|out, chorus2, sustain|
	var sig = In.ar(out, ~dirt.numChannels);
	var c1 = DelayN.ar(sig, 2, Sweep.ar(Impulse.ar(0), chorus2/50));
	var c2 = DelayN.ar(sig, 2, 0.001+Sweep.ar(Impulse.ar(0), chorus2/60));
	sig = Splay.ar([DelayN.ar(c2, 0.2, 0.010*chorus2), c1, sig, c2, DelayN.ar(c1, 0.2, 0.015*chorus2)], chorus2);
	ReplaceOut.ar(out, sig);
}).add;

~dirt.addModule('chorus', {|dirtEvent| dirtEvent.sendSynth("dirt_chorus" ++ ~dirt.numChannels,
[chorus: ~chorus, sustain: ~sustain, out: ~out])}, {~chorus.notNil});
SynthDef("dirt_chorus"++~dirt.numChannels, {|out, chorus, sustain|
	var sig = In.ar(out, ~dirt.numChannels);
	sig = (chorus > 0) * DelayN.ar(sig, sustain/5, Line.ar(0,chorus*sustain/100, sustain) + SinOsc.ar(0.3,mul:3e-4)) + sig;
	sig = sig / ((chorus > 0) * sqrt(2) + ((chorus < 1e-6) * 1));
	ReplaceOut.ar(out, sig);
}).add;

~dirt.addModule('digidest', {|dirtEvent| dirtEvent.sendSynth("dirt_digidest" ++ ~dirt.numChannels,
[digidest: ~digidest, sustain: ~sustain, out: ~out])}, {~digidest.notNil});
SynthDef("dirt_digidest"++~dirt.numChannels, {|out, digidest, sustain|
	var sig = In.ar(out, ~dirt.numChannels);
	digidest = digidest/2;
	sig = DelayN.ar(sig, 1, Line.ar(0,digidest*sustain, sustain).round(1/15));
	sig = Latch.ar(sig, Impulse.ar(LinExp.ar(Line.ar(4,1, sustain*digidest.linexp(0,1,10,0.1) ).round(0.2), 1,4, 20, 20000)));
	ReplaceOut.ar(out, sig);
}).add;

~dirt.addModule('djfilt', {|dirtEvent| dirtEvent.sendSynth("dirt_djfilt" ++ ~dirt.numChannels,
[djfilt: ~djfilt, out: ~out])}, {~djfilt.notNil});
SynthDef("dirt_djfilt"++~dirt.numChannels, {|out, djfilt|
	var sig = In.ar(out, ~dirt.numChannels);
	var rc = tan(pi * 800 / 44100);
	var octaves = (djfilt - 0.5) * 2 * 3;
	var r = rc / (2 ** octaves);
	var a = [3,1] * pi / 8;
	var zd = 1 + (r * r) + (2 * r * cos(a));
	var pd = 1 + (rc * rc) + (2 * rc * cos(a));
	var zx = (1 - (r*r)) / zd;
	var px = (1 - (rc*rc)) / pd;
	var zy = 2 * r * sin(a) / zd;
	var py = 2 * rc * sin(a) / pd;
	var w = (octaves < 0) * 2 - 1;
	var gain1 = (1 - (2 * w * zx[0]) + sumsqr(zx[0], zy[0])) / (1 - (2 * w * px[0]) + sumsqr(px[0], py[0]));
	var gain2 = (1 - (2 * w * zx[1]) + sumsqr(zx[1], zy[1])) / (1 - (2 * w * px[1]) + sumsqr(px[1], py[1]));
	var gain = gain1 * gain2;
	sig = SOS.ar(sig, 1, -2 * zx[0], sumsqr(zx[0], zy[0]), -2 * px[0], sumsqr(px[0], py[0]), mul:1/gain);
	sig = SOS.ar(sig, 1, -2 * zx[1], sumsqr(zx[1], zy[1]), -2 * px[1], sumsqr(px[1], py[1]));
	// sig = SOS.ar(sig, 1, -2 * px[0], sumsqr(px[0], py[0]), -2 * zx[0], sumsqr(zx[0], zy[0]), mul:1/gain);
	// sig = SOS.ar(sig, 1, -2 * px[1], sumsqr(px[1], py[1]), -2 * zx[1], sumsqr(zx[1], zy[1]));
	ReplaceOut.ar(out, sig);
}).add;


~dirt.addModule('fshiftalt', {|dirtEvent| dirtEvent.sendSynth("dirt_fshiftalt" ++ ~dirt.numChannels,
	[fshift2: ~fshift2, fshiftphase2: ~fshiftphase2, fshiftnote2: ~fshiftnote2, freq: ~freq, out: ~out])}, {~fshift2.notNil});
SynthDef("dirt_fshiftalt"++~dirt.numChannels, {|out, fshift2, fshiftphase2, fshiftnote2, freq|
	var sig = In.ar(out, ~dirt.numChannels);
	var shift = freq*fshiftnote2 + fshift2;
	var s1,s2;
	var modfreq = 3001.0;
	var demodfreq = modfreq + shift;
	// s1 = sig * SinOsc.ar(modfreq, 0);
	// s2 = sig * SinOsc.ar(modfreq, pi/2+fshiftphase2);
	s1 = DiodeRingMod.ar(sig, SinOsc.ar(modfreq, 0));
	s2 = DiodeRingMod.ar(sig, SinOsc.ar(modfreq, pi/2+fshiftphase2));
	s1 = BLowPass4.ar(s1, modfreq);
	s2 = BLowPass4.ar(s2, modfreq);
	// s1 = s1 * SinOsc.ar(demodfreq, 0);
	// s2 = s2 * SinOsc.ar(demodfreq, pi/2+fshiftphase2);
	s1 = DiodeRingMod.ar(s1, SinOsc.ar(demodfreq, 0));
	s2 = DiodeRingMod.ar(s2, SinOsc.ar(demodfreq, pi/2+fshiftphase2));
	// sig = (s1+s2)*1.3;
	sig = (s1+s2)/1.2;
	ReplaceOut.ar(out, sig);
}).add;

~dirt.addModule('amdist', {|dirtEvent| dirtEvent.sendSynth("dirt_amdist" ++ ~dirt.numChannels,
	[amdist: ~amdist, amdistf: ~amdistf, out: ~out])}, {~amdist.notNil});
SynthDef("dirt_amdist"++~dirt.numChannels, {|out, amdist, amdistf|
	var sig, ampmod, freqs;
	sig = In.ar(out, ~dirt.numChannels);
	ampmod = (1.0 + PinkNoise.kr()) * 0.05 * amdist;
	freqs = (amdistf < 1) * 9800 + amdistf + [0,10];
	sig = sig * SinOsc.ar(freqs+PinkNoise.kr(10*amdist)); // modulate
	sig = sig + PinkNoise.ar(ampmod); // add noise
	sig = sig * SinOsc.ar(freqs+PinkNoise.kr(10*amdist)); // demodulate
	ReplaceOut.ar(out, sig);
}).add;

// actually a stereo field distortion now
~dirt.addModule('fmdist', {|dirtEvent| dirtEvent.sendSynth("dirt_fmdist" ++ ~dirt.numChannels,
[fmdist: ~fmdist, fmdistf: ~fmdistf, out: ~out])}, {~fmdist.notNil});
SynthDef("dirt_fmdist"++~dirt.numChannels, {|out, fmdist, fmdistf|
	var dry, wet, lpr, lmr;
	dry = In.ar(out, ~dirt.numChannels);
	lpr = dry[0]+dry[1];
	lmr = dry[0]-dry[1];
	lmr = RLPF.ar(lmr, 800, 0.1);
	lmr = lmr + WhiteNoise.ar(fmdist*0.01);
	lmr = tanh(fmdist*lmr);
	wet = [lpr+lmr, lpr-lmr];
	ReplaceOut.ar(out, SelectX.ar(fmdist, [dry, 0.5*wet]));
}).add;

~dirt.addModule('allpass', {|dirtEvent| dirtEvent.sendSynth("dirt_allpass" ++ ~dirt.numChannels,
[allpass: ~allpass, out: ~out])}, {~allpass.notNil});
SynthDef("dirt_allpass"++~dirt.numChannels, {|out, allpass|
	var dry, wet, rez, imz, zsq, th, mag;
	th = SinOsc.ar(1).range(0,3);
	mag = 0.99;
	rez = mag*cos(th);
	imz = mag*sin(th);
	zsq = (rez*rez) + (imz*imz);
	dry = In.ar(out, ~dirt.numChannels);
	wet = SOS.ar(dry, zsq, -2.0*rez, 1.0, 2.0*rez, -1.0*zsq);
	ReplaceOut.ar(out, SelectX.ar(allpass, [dry, wet]));
}).add;

// general EQ?
~dirt.addModule('sparkle', { |dirtEvent| dirtEvent.sendSynth("dirt_sparkle" ++ ~dirt.numChannels,
			[sparkle: ~sparkle, sparklef: ~sparklef, out: ~out])}, { ~sparkle.notNil});
SynthDef("dirt_sparkle" ++ ~dirt.numChannels, {|out, sparkle, sparklef|
	var signal, freq;
	signal = In.ar(out, ~dirt.numChannels);
	freq = Select.kr(sparklef > 0, [DC.kr(2000), sparklef]);
	signal = BHiShelf.ar(signal, freq, 0.9, sparkle*10);
	// signal = Limiter.ar(signal);
	ReplaceOut.ar(out, signal);
}).add;

// trying a limiter/depopper/shaper
~dirt.addModule('wall', { |dirtEvent| dirtEvent.sendSynth("dirt_wall" ++ ~dirt.numChannels,
			[wall: ~wall, walllev: ~walllev, out: ~out])}, { ~wall.notNil});
SynthDef("dirt_wall" ++ ~dirt.numChannels, {|out, wall=0, walllev=0.5|
	var signal, mod;
	signal = In.ar(out, ~dirt.numChannels);
	mod = signal - signal.clip2(walllev/2+0.5);
	signal = signal.clip2(walllev/2+0.5) + ((1.0-wall)*mod);
	ReplaceOut.ar(out, signal);
}).add;
~dirt.addModule('comp', { |dirtEvent|
		dirtEvent.sendSynth("dirt_comp" ++ ~dirt.numChannels,
			[comp: ~comp, compa: ~compa, compr: ~compr, out: ~out])},
{ ~comp.notNil});
SynthDef("dirt_comp" ++ ~dirt.numChannels, {|out, comp=0, compa=0, compr=0|
	var signal, mod, inlev, cgain;
	signal = In.ar(out, ~dirt.numChannels);
	inlev = Amplitude.ar(HPF.ar(signal, 600, 1.5), 0.01+compa, 0.02+compr);
	mod = signal / max( inlev, 0.1) * 0.3;
	mod = SelectX.ar(comp, [signal, mod]);
	ReplaceOut.ar(out, mod);
}).add;
