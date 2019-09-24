# BootTidal.hs
Tidalcycles _(default)_ startup file, dont forget to explicit its location in the Atom plugin options

# statup.scd
The SC conf I use, default config slightly modified: 
- automatic SD startup, 
- allowing 4 audio in/outs to be auto-connected through Jack,
- grabbing 2 midi outputs through Jack, 
- hooking one on my hardware soundcard (replace this part by the values corresponding to your model), named `midi`, 
- and the other to be assigned to the Jack/Alsa Midi through port #0, named `carla`,
- displays the directory and alloc mem size in the SC postwindow when everything went smooth and SD hooked to a port.

Can be copied and pasted through `File > Open Startup file` in SCIde.
