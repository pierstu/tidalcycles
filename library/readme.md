Synthdefs pour 2Mo

# library update sept 20

## [try-load-extra-synths](https://github.com/pierstu/tidalcycles/edit/master/library/try-load-extra-synths.scd) to be put in `~/.local/share/SuperCollider/downloaded-quarks/SuperDirt/synths/`

## All other files go to `~/.local/share/SuperCollider/downloaded-quarks/SuperDirt/library/`

## Args are passed as Haskell vars in [../setup/BootTidal.hs](https://raw.githubusercontent.com/pierstu/tidalcycles/master/setup/BootTidal.hs) which should go in `.tidal` files directory (or `tidal-xxxxx` Melpa dir if using Emacs), that should do at Tidalcycles startup anyway

# Default values :

## [default-effects-extra.scd](https://raw.githubusercontent.com/pierstu/tidalcycles/master/library/default-effects-extra.scd)

- waveloss : 

  `# drop 1.0`

- squiz :

  `# pitchratio 1.0`

- spectraldelay :

  `# tsdelay 0.5`

  `# xsdelay 0.5`

etc, you might want to read [All effects and synths](https://tidalcycles.org/index.php/All_effects_and_synths) on Tidalcycles.org. Same for [default-synths-extra](https://github.com/pierstu/tidalcycles/raw/master/library/default-synths-extra.scd) (and I should make room here in days).

## [bgold_fx](https://github.com/pierstu/tidalcycles/raw/master/library/bgold_fx.scd)

Only the ones I kept to spare mem.

- lpg :

  `# lpg 0.0`
  
  `# lpga 0.001`
  
  `# lpgr 0.01`
  
  `# lpgg 1.0`
  
  `# lpgres 0.0`

- whammy :

  `# whammy 0.0`
  
  `# whammyshift 0.0`
  
  `# whammyfreq 0.0`
  
  `# whammydelay 0.0`

- schmidt :

  `# schmidt 0.0`

- zpulse :

  `# zpulse 0.0`

- enc :
  
  `# enc 0.0`

- match :

  `# match 0.0`
  
  `# matchf 440.0`
  
  `# matchw 20.0`

- median : 

  `# median 0.0`

- chorus2 :

  `# chorus2 0.0`

- digidest :

  `# digidest 0.0`

- djfilt :

  `# djfilt 0.0`

- fshift2 :

  `# fshift2 0.0`
  
  `# fshiftphase2 0.0`
  
  `# fshiftnote2 0.0`

- amdist :

  `# amdist 0.0`
  
  `# amdistf 0.0`

- allpass :

  `# allpass 0.0`

- sparkle :

  `# sparkle 0.0`
  
  `# sparklef 0.0`

- wall :

  `# wall 0.0`
  
  `# walllev 0.5

- comp :

  `# comp 0.0`
  
  `# compa 0.0`
  
  `# compr 0.0`
  
## [2Mo_SynthDef_from_ORBM](https://github.com/pierstu/tidalcycles/raw/master/library/2Mo_SynthDef_from_ORBM.scd)
  
???
