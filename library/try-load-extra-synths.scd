if(\MembraneHexagon.asClass.isNil) {
	"Dirt could not load some synths from default-synths.scd, because sc3plugins are necessary and missing.".warn
} {
	loadRelative("../library/default-synths-extra.scd");
	loadRelative("../library/default-effects-extra.scd");
	loadRelative("../library/custom-synthdefs.scd");
	loadRelative("../library/bgold-tidal5.scd");
	loadRelative("../library/coopt-synthdefs.scd");
	loadRelative("../library/generative_SynthDef_2Mo.scd");
};
