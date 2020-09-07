Synthdefs pour 2Mo

# library update sept 20

## [try-load-extra-synths](https://github.com/pierstu/tidalcycles/edit/master/library/try-load-extra-synths.scd) to be put in `~/.local/share/SuperCollider/downloaded-quarks/SuperDirt/synths/`

## All other files go to `~/.local/share/SuperCollider/downloaded-quarks/SuperDirt/library/`

## Args are passed as Haskell vars in [../setup/BootTidal.hs](https://raw.githubusercontent.com/pierstu/tidalcycles/master/setup/BootTidal.hs) which should go in `.tidal` files directory (or `tidal-xxxxx` MELPA setup directory if using Emacs), that should do it at Tidalcycles startup

Default values :

# default-effects-extra.scd

- waveloss : 

  `# drop 1.0`

- squiz :

  `# pitchratio 1.0`

- spectraldelay :

  `# tsdelay 0.5`

  `# xsdelay 0.5`

etc

