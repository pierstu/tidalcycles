/* to be put or updated in ~/.local/share/SuperCollider/downloaded-quarks/SuperDirt/synths/ */

if(\MembraneHexagon.asClass.isNil) {
	"Dirt could not load some synths from default-synths.scd, because sc3plugins are necessary and missing.".warn
} {
	loadRelative("../library/2Mo_SynthDef_from_ORBM.scd"); 
	loadRelative("../library/bgold_fx.scd");
	loadRelative("../library/default-synths-extra.scd");
	loadRelative("../library/default-effects-extra.scd");
};
