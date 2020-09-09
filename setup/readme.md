# [BootTidal.hs](https://raw.githubusercontent.com/pierstu/tidalcycles/master/setup/BootTidal.hs)
Tidalcycles _(default)_ startup file, dont forget to explicit its location in the Atom plugin options 

You might mangle a bit in your Melpa files if using Emacs

_update 09/20 : vars for ORBM synthdefs + bgold extra fx_

# [statup.scd](https://raw.githubusercontent.com/pierstu/tidalcycles/master/setup/startup.scd)

update 09 2020 

The SC conf I use, default config slightly modified: 
- automatic SD startup, 
- Audio busses : 2 ins, 4 outs in stereo pairs  
- grabbing 3 midi outputs through Jack : 
    - `carla` sequencing `Midi Through Port-0`
    - `midi` sequencing `UMC404HD 192k MIDI 1` for hardware with DIN-5 plugs __(to replace with your MIDI device, return `MIDIClient.init` in SC, see [SuperDirt MIDI tutorial](https://tidalcycles.org/index.php/SuperDirt_MIDI_Tutorial))__
    - `pd` sequencing `Pure Data Midi-In 1` - works with Jack MIDI in pd (currently using 0.51.2), no need to bridge OSC <-> MIDI 
- displays the directory and alloc mem size in the SC postwindow when everything went smooth and SD hooked to a port.

Can be copied and pasted through `File > Open Startup file` in SCIde.

_update 10/19 : increase `memSize`_
_update 09/20 : MIDI ports_

# [try-load-extra-synths.scd](https://raw.githubusercontent.com/pierstu/tidalcycles/master/setup/try-load-extra-synths.scd)
To be put or updated in `~/.local/share/SuperCollider/downladed-quarks/SuperDirt/synths`. Autoloads synthdefs provided in [the synthdefs repo](https://github.com/pierstu/tidalcycles/tree/master/synthdefs), which all go in `../library`, currently:
- 2Mo_SynthDef_from_ORBM
- bgold_fx
- default-synths-extra
- default-effects-extra


_added 10/19_

_update 09/20 : ORBM + bgold fx_

___
_init 10/19_

_update 09/20 : added links, removed crap_
