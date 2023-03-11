// s.options.dump;
// s.addr = NetAddr("169.254.3.159", 57120);


/*
//
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
To be copied and pasted in your SC startup file (in SCIde, do File > Open startup file)
//
*/


(

var on, off, cc;
var osc;
var tidalMidiChan;

// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
s.options.numBuffers = 4096 * 512; // increase this if you need to load more samples
s.options.memSize = 2.pow(20); // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 6; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 1; // set this to your hardware output channel size, if necessary
// boot the server and start SuperDirt
s.options.numWireBufs = 64 ** 2;

//110323 Ajout port osc pour controleur midi

osc = NetAddr.new("127.0.0.1", 6010);

tidalMidiChan = 0;

on = MIDIFunc.noteOn({ |val, num, chan, src|
	osc.sendMsg("/ctrl", num.asString, val/127);
}, chan: tidalMidiChan);

off = MIDIFunc.noteOff({ |val, num, chan, src|
	osc.sendMsg("/ctrl", num.asString, 0);
}, chan: tidalMidiChan);

cc = MIDIFunc.cc({ |val, num, chan, src|
	osc.sendMsg("/ctrl", num.asString, val/127);
}, chan: tidalMidiChan);

// stop controlling Tidal with Midi
~stopMidiToOsc = {
	on.free;
	off.free;
	cc.free;
};


MIDIClient.init;
MIDIClient.sources;
// 2.wait;
// contrôleur omnitronic fad9 :
	// MIDIClient.sources; // list avalaible midi sources
MIDIClient.sources.do({ arg source, i;
	// source.device.debug("device: ");
	// source.name.debug("name: ");
	if ((source.device == "FAD.9" and: source.name == "FAD.9 MIDI 1"), {
		MIDIIn.connect(0, MIDIClient.sources[i]);
	});
});
// MIDIIn.connect(0,MIDIClient.sources[4]); // connecter à l'entrée MIDI 0, la 4e valeur du tableau retourné par MIDIClient.sources; soit MIDIEndPoint("FAD.9", "FAD.9 MIDI 1") ou MIDIEndPoint("UC-33 USB MIDI Controller", "UC-33 USB MIDI Controller MIDI ")
// MIDIIn.findPort("FAD.9", "FAD.9 MIDI 1");
// MIDIFunc.trace(false);
// midi output for Carla or whatever you'll seq software / plugins with, here it will be named carla //
// ~midiOut = MIDIOut.newByName("Midi Through", "Midi Through Port-0").latency_(s.latency);

// ~stopMidiToOsc.value;

ServerQuit.add(~stopMidiToOsc);


s.waitForBoot {
	"/home/pi/.local/share/SuperCollider/downloaded-quarks/SuperDirt/hacks/scriptfabien.scd".load;
	~dirt = SuperDirt(2, s); // ?two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
	2.wait;
	// s.sync; // optionally: wait for samples to be read
	~dirt.start(57120, [0, 2, 4]);   // start listening on port 57120, create ?two? three busses each sending audio to channel 0

	// ~dirt.soundLibrary.addMIDI(\midi, ~midiOut);
	// midi hardware output via soundcard, set it up according to your needs below, here it will be named midi //
	// pd
	// ~pdOut = MIDIOut.newByName("Pure Data", "Pure Data Midi-In 1").latency_(s.latency);
	// ~dirt.soundLibrary.addMIDI(\pd, ~pdOut);

	// display more info about loaded samples in SC postwindow (bgold) https://github.com/bgold-cosmos/SuperDirt-extra/blob/master/Tidal5.scd //
	1.wait;
	~dirt.postSampleInfo;
};

s.latency = 0.99; // increase this if you get "late" messages
)