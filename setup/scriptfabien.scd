(
~tidalResArgs = #["?", "mute", "slide", "scale",/* "speed", "accelerate", "freq", "attack", "decay", "sustain", "release",*/ "spread", "legato", "octave", "unit", "loop", "offset", "nudge", "lfo", "rate", "size", "room", "dry", "cut", "cutoff", "resonance", "n", "note", "degree", "harmonic", "delay", "pan", "gain", "overgain", "lpf", "hpf", "att", "hold", "sus", "rel", "span", "out", "i_out", "in", "i_in", "input", "output", "inbus", "outbus", "doneaction", "done", "gate", "t_gate", "trig", "t_trig"];

~tidalScopeCodeGen = { arg synthDefName = \default, fromDefault = false; // copy, paste and execute code in tidal to declare args
	var arguments, name, code;
	arguments = SynthDescLib.global[synthDefName].controls;
	name = synthDefName.asString;
	if (fromDefault, {
		code = "";
	}, {
		code = "-- " ++ name ++ "\n" ++ "let ";
	});

	arguments.do({ arg control, i;
		var controlName, controlNameLower, controlValue;
		controlName = control.name.asString;
		controlNameLower = controlName.toLower;

		if (~tidalResArgs.includesEqual(controlNameLower).not, {
			if (fromDefault, {
				if ((control.defaultValue.isArray or: control.defaultValue.isNegative), {
					controlValue = "\"" ++ control.defaultValue ++ "\"";
				}, {
					controlValue = control.defaultValue.asFloat;
				});

				code = code ++ "# " ++ controlName ++ " " ++ controlValue ++ "\n";
			}, {
				code = code ++ controlName ++ " = pF \"" ++ controlName ++ "\"\n    ";
			});
		});

	});

	code = code ++ "\n";

	Post << code;
};

// ~tidalScopeCodeGen.value(\Sd_); // declare synth arguments in tidal scope, copy / paste to bootTidal.hs
// ~tidalScopeCodeGen.value(\Sd_, true); // control pattern in tidal with synth default values

~tidalScopeTotalCodeGen = { arg key = "Sd", targetSearch = 2; // look for SynthDef names which contain key at position define by targetSearch and generate the code to declare args in tidal, copy / paste to bootTidal.hs
	var code, presentCtrl/*, targetSynths*/;
	code = "let ";
	presentCtrl = List.new;
	// targetSynths = List.new;
	key = key.asString;

	SynthDescLib.global.synthDescs.do({ arg item;
		var name, nameSize, keySize, start, end;

		name = item.name.asString;
		nameSize = item.name.size;
		keySize = key.size;

		switch(targetSearch,
			0, { // search at the begining
				start = 0;
				end = keySize;
			},
			1, { // search everywhere
				start = 0;
				end = nameSize;
			},
			2, { // search at the end
				start = nameSize - keySize;
				end = nameSize;
			},
			{ // default function search at the end
				start = nameSize - keySize;
				end = nameSize;
			}
		);

		if(key.matchRegexp(name, start, end), {

			item.controls.do{ arg control;
				var controlName, controlNameLower;
				controlName = control.name.asString;
				controlNameLower = controlName.toLower;

				if ((~tidalResArgs.includesEqual(controlNameLower).not and: presentCtrl.includesEqual(controlName).not), {
					code = code ++ controlName ++ " = pF \"" ++ controlName ++ "\"\n    ";
					presentCtrl.add(controlName);
				});

			};

			// targetSynths.add(name.asSymbol);

		});

	});

	// SuperDirt.postTidalParameters(targetSynths);

	Post << code;
};

// ~tidalScopeTotalCodeGen.value;

)

