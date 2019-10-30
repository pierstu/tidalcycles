:set -XOverloadedStrings
:set prompt ""
:set prompt-cont ""

import Sound.Tidal.Context

-- total latency = oLatency + cFrameTimespan
tidal <- startTidal (superdirtTarget {oLatency = 0.1, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/20})

:{
let p = streamReplace tidal
    hush = streamHush tidal
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    first = streamFirst tidal
    asap = once
    nudgeAll = streamNudgeAll tidal
    all = streamAll tidal
    resetCycles = streamResetCycles tidal
    setcps = asap . cps
    xfade i = transition tidal True (Sound.Tidal.Transition.xfadeIn 4) i
    xfadeIn i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
    histpan i t = transition tidal True (Sound.Tidal.Transition.histpan t) i
    wait i t = transition tidal True (Sound.Tidal.Transition.wait t) i
    waitT i f t = transition tidal True (Sound.Tidal.Transition.waitT f t) i
    jump i = transition tidal True (Sound.Tidal.Transition.jump) i
    jumpIn i t = transition tidal True (Sound.Tidal.Transition.jumpIn t) i
    jumpIn' i t = transition tidal True (Sound.Tidal.Transition.jumpIn' t) i
    jumpMod i t = transition tidal True (Sound.Tidal.Transition.jumpMod t) i
    mortal i lifespan release = transition tidal True (Sound.Tidal.Transition.mortal lifespan release) i
    interpolate i = transition tidal True (Sound.Tidal.Transition.interpolate) i
    interpolateIn i t = transition tidal True (Sound.Tidal.Transition.interpolateIn t) i
    clutch i = transition tidal True (Sound.Tidal.Transition.clutch) i
    clutchIn i t = transition tidal True (Sound.Tidal.Transition.clutchIn t) i
    anticipate i = transition tidal True (Sound.Tidal.Transition.anticipate) i
    anticipateIn i t = transition tidal True (Sound.Tidal.Transition.anticipateIn t) i
    forId i t = transition tidal False (Sound.Tidal.Transition.mortalOverlay t) i
    d1 = p 1 . (|< orbit 0)
    d2 = p 2 . (|< orbit 1)
    d3 = p 3 . (|< orbit 2)
    d4 = p 4 . (|< orbit 3)
    d5 = p 5 . (|< orbit 4)
    d6 = p 6 . (|< orbit 5)
    d7 = p 7 . (|< orbit 6)
    d8 = p 8 . (|< orbit 7)
    d9 = p 9 . (|< orbit 8)
    d10 = p 10 . (|< orbit 9)
    d11 = p 11 . (|< orbit 10)
    d12 = p 12 . (|< orbit 11)
    d13 = p 13
    d14 = p 14
    d15 = p 15
    d16 = p 16
:}

:{
let setI = streamSetI tidal
    setF = streamSetF tidal
    setS = streamSetS tidal
    setR = streamSetI tidal
    setB = streamSetB tidal
:}

:{
let spike p = ((|+| delaytime (range 0.001 0.3 $ slow 7.1 sine)) . (|+| delayfeedback (range 0.7 0.99 $ slow 6.71 sine))) $ p
    spike' p = (|+| delay "0.3") $ spike $ p
    ghost'' a f p = superimpose (((a/2 + a*2) ~>) . f) $ superimpose (((a + a/2) ~>) . f) $ p
    ghost' a p = ghost'' a ((|*| gain "0.7") . (# end "0.2") . (|*| speed "1.25")) p
    ghost p = ghost' 0.125 p
    jit start amount p = within (start, (start + 0.5)) (trunc (amount)) p
    gtfo p = (const $ sound "~") p
    shift p = (1024 <~)  p
    shift' x p = (x <~) p
    choose xs = (xs !!) <$> (irand $ fromIntegral $ length xs)
:}

:{
let
-- generative_2Mo
  -- nvirgo
  feedback = pF "feedBack"
  sf1 = pF "sawFreq1"
  sf2 = pF "sawFreq2"
  samp = pF "sawAmp"
  bpff = pF "bpff"
  bpms = pF "bpffModSpeed"
  bpma = pF "bpffModAmt"
  delt = pF "delayTime"
  -- bozkurt
  impF = pF "impFreq"
  freq1  = pF "freq1"
  freq2 = pF "freq2"
  -- mcld
  hpFf = pF "hpFFreq"
  -- batuhan
  tridur = pF "tridDur"
  dect = pF "decayTime"
  sawf = pF "sawFreq"
  bpff1 = pF "bpfFreq1"
  bpff2 = pF "bpfFreq2"
   -- nozkurt
  sinef = pF "sinFreq"
  impmin = pF "impMin"
  impmax = pF "impMax"
   -- tirgo
  blipFm = pF "bipFreqMod"
  bliph = pF "blipHarmo"
  brff = pF "brfFreq"
  brfr = pF "brfRq"
   -- lmcd
  trigdur = pF "trigDur"
  lfc = pF "lfCubTu"
-- custom
  lforate = pF "lforate"
  lfowidth = pF "lfowidth"
  rq = pF "rq"
  coef = pF "coef"
  voiceGain = pF "voiceGain"
  noiseGain = pF "noiseGain"
  sweepRate = pF "sweepRate"
  -- lfowidth = pF "lfowidth"
  freq = pF "freq"
  numharm = pF "numharm"
  noise = pF "noise"
  vibFreq = pF "vibFreq"
  vibGain = pF "vibGain"
  baseFreq = pF "baseFreq"
  time = pF "time"
  scl = pF "scl"
  ipress = pF "ipress"
  ibreath = pF "ibreath"
  ifeedbk1 = pF "ifeedbk1"
  ifeedbk2 = pF "ifeedbk2"
  cutoff2 = pF "cutoff2"
  modamount = pF "modamount"
  modrate = pF "modrate"
  releaseTime = pF "releaseTime"
  ffreq = pF "ffreq"
  bandwidth = pF "bandwidth"
  endReflection = pF "endReflection"
  jetReflection = pF "jetReflection"
  jetRatio = pF "jetRatio"
  ringTime = pF "ringTime"
  filterfreq = pF "filterfreq"
  vibratoSpeed = pF "vibratoSpeed"
  vibratoDepth = pF "vibratoDepth"
  lag = pF "lag"
  -- coopt
  a = pF "a"
  b = pF "b"
  x0 = pF "x0"
  x1 = pF "x1"
  ts = pF "ts"
  fb = pF "fb"
  f = pF "f"
  d = pF "d"
-- bgold
  voice = pF "voice"
  detune = pF "detune"
  pitch1 = pF "pitch1"
  pitch2 = pF "pitch2"
  slidedelay = pF "slidedelay"
  -- bgold fx
  lpg = pF "lpg"
  lpga = pF "lpga"
  lpgg = pF "lpgg"
  lpgres = pF "lpgres"
  whammy = pF "whammy"
  whammyshift = pF "whammyshift"
  whammyfreq = pF "whammyfreq"
  whammydelay = pF "whammydelay"
  schmidt = pF "schmidt"
  zpulse = pF "zpulse"
  enc = pF "enc"
  match = pF "match"
  matchw = pF "matchw"
  matchf = pF "matchf"
  median = pF "median"
  comb = pF "comb"
  combd = pF "combd"
  combdiff = pF "combdiff"
  chunk = pF "chunk"
  chunkspread = pF "chunkspread"
  chunksharp = pF "chunksharp"
  chorus2 = pF "chorus2"
  chorus = pF "chorus"
  digidest = pF "digidest"
  djfilt = pF "djfilt"
  fshift2 = pF "fshift2"
  fshiftphase2 = pF "fshiftphase2"
  fshiftnote2 = pF "fshiftnote2"
  lpf2 = pF "lpf2"
  -- cutoff2 = pF "cutoff2"
  amdist = pF "amdist"
  amdistf = pF "amdistf"
  fmdist = pF "fmdist"
  fmdistf = pF "fmdistf"
  allpass = pF "allpass"
  sparkle = pF "sparkle"
  sparklef = pF "sparklef"
  wall = pF "wall"
  wallev = pF "wallev"
  fattack = pF "fattack"
  fhold = pF "fhold"
  frelease = pF "frelease"
  fenv = pF "fenv"
  flfo = pF "flfo"
  flfof = pF "flfof"
  comp = pF "comp"
  compa = pF "compa"
  compr = pF "compr"
  fm = pF "fm"
  fmf = pF "fmf"
  rect = pF "rect"
  rectoff = pF "rectoff"
  wrap = pF "wrap"
  wrapoff = pF "wrapoff"
  envsaw = pF "envsaw"
  envsawf = pF "envsawf"
  -- boom = pF "boom"
  gboom = pF "gboom"
:}

:set prompt "tidal> "
