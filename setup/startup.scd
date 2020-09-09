/*
//
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
To be copied and pasted in your SC startup file (in SCIde, do File > Open startup file)
//
*/


(
// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
s.options.numBuffers = 2048 * 512; // increase this if you need to load more samples
s.options.memSize = 2.pow(20); // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 4; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
// boot the server and start SuperDirt
s.waitForBoot {
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
	// s.sync; // optionally: wait for samples to be read
	~dirt.start(57120, [0, 2, 4]);   // start listening on port 57120, create two busses each sending audio to channel 0
	MIDIClient.init;
  // midi output for Carla or whatever you'll seq software / plugins with, here it will be named carla //
	~carlaOut = MIDIOut.newByName("Midi Through", "Midi Through Port-0").latency_(s.latency);
	~dirt.soundLibrary.addMIDI(\carla, ~carlaOut);
  // midi hardware output via soundcard, set it up according to your needs below, here it will be named midi //
	~midiOut = MIDIOut.newByName("UMC404HD 192k", "UMC404HD 192k MIDI 1").latency_(s.latency);
	~dirt.soundLibrary.addMIDI(\midi, ~midiOut);
	// pd
	~pdOut = MIDIOut.newByName("Pure Data", "Pure Data Midi-In 1").latency_(s.latency);
	~dirt.soundLibrary.addMIDI(\pd, ~pdOut);
  // display more info about loaded samples in SC postwindow (bgold) https://github.com/bgold-cosmos/SuperDirt-extra/blob/master/Tidal5.scd //
	// ~dirt.postSampleInfo(2, s);
};

s.latency = 0.69; // increase this if you get "late" messages
);
