

//this is the working prototype from the previous file
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.993333);
	SendReply.kr(Impulse.kr(60),'/induction/low',FFTPower.kr(chain1));
	chain2 = PV_BrickWall(fft,0.13333);
	SendReply.kr(Impulse.kr(60),'/induction/high',FFTPower.kr(chain2));
	chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
	SendReply.kr(Impulse.kr(60),'/induction/mid',FFTPower.kr(chain3));
}.play;
OSCdef(\inductionlow,{|msg| ~qlc.sendMsg("/inductionlights/low",msg[3].linlin(0,0.2,0,255).asInt)},'/induction/low');
OSCdef(\inductionmid,{|msg| ~qlc.sendMsg("/inductionlights/mid",msg[3].linlin(0,0.2,0,255).asInt)},'/induction/mid');
OSCdef(\inductionhigh,{|msg| ~qlc.sendMsg("/inductionlights/high",msg[3].linlin(0,0.2,0,255).asInt)},'/induction/high');
)


//Now sending all results as array
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.993333);
	chain2 = PV_BrickWall(fft,0.13333);
	chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
	SendReply.kr(Impulse.kr(60),'/induction/master',[FFTPower.kr(chain1),FFTPower.kr(chain2),FFTPower.kr(chain3)]);
}.play;
)

//Sending whole array to QLC
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.993333);
	chain2 = PV_BrickWall(fft,0.13333);
	chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
	SendReply.kr(Impulse.kr(60),'/induction/master',[FFTPower.kr(chain1),FFTPower.kr(chain2),FFTPower.kr(chain3)]);
}.play;
OSCdef(\inductionmics,{|msg|
	~qlc.sendMsg("/inductionlights/low",msg[3].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/mid",msg[4].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/high",msg[5].linlin(0,0.2,0,255).asInt);
	~python.sendMsg("/induction/master",msg);
},'/induction/master')
)

/*

So, i need to control both the volume and the messages sent dealing with the induction coils with the switching function. Model it based on this:


OSCFunc({|msg|
	if (msg[1] == 1) {
		OSCdef(\heartbeat,{|msg|
			~python.sendMsg("/heartbeat/1",msg);
			Synth(\heartbeat,[\freq,msg[6].linlin(0.0,50.0,70,2000),
				\amp,msg[6].linlin(0.0,50.0,0.1,3),
				\rel,msg[6].linlin(0.0,50.0,0.05,1)])},
		'/status.reply');
		//OSC functions about Envelopes to send on
		OSCdef(\envon,{|msg| ~python.sendMsg("/env/on","on")},'/n_go');
		OSCdef(\envoff,{|msg| ~python.sendMsg("/env/off","off")},'/n_end');
		//send a message to trigger a glow in light 1
		~qlc.sendMsg("/light1/glow",1);
		"switch on".postln
	} {
		OSCdef(\heartbeat,{|msg|},'/status.reply');
		OSCdef(\envon,{|msg|},'/n_go');
		OSCFunc(\envoff,{|msg|},'/n_end');
		"switch off".postln
	}
},'/switch/1');

*/

//this function mutes all OSC activity when the switch is removed, zero-ing all QLC channels
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.993333);
	chain2 = PV_BrickWall(fft,0.13333);
	chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
	SendReply.kr(Impulse.kr(60),'/induction/master',[FFTPower.kr(chain1),FFTPower.kr(chain2),FFTPower.kr(chain3)]);
}.play;
OSCFunc({|msg|
	if (msg[1] == 1) {
		OSCdef(\inductionmics,{|msg|
	~qlc.sendMsg("/inductionlights/low",msg[3].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/mid",msg[4].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/high",msg[5].linlin(0,0.2,0,255).asInt);
	~python.sendMsg("/induction/master",msg);
},'/induction/master')
	} {
		OSCdef(\inductionmics,{|msg|
			~qlc.sendMsg("/inductionlights/low",0);
			~qlc.sendMsg("/inductionlights/mid",0);
			~qlc.sendMsg("/inductionlights/high",0);
		},'/induction/master')
	}
},'/switch/2');
)

// TODO: Implement volume fade when the switch is triggered and volume fade-down when switch is released
// This probably needs to be re-written as a synthdef with a linen on the volume which is triggered when the switch is pressed and un-triggered when it is released

(
SynthDef(\inductionpassthrough,
	{
		arg gate = 1, amp = 1;
		var sig, env;
		sig = Pan2.ar(SoundIn.ar(0),amp);
		env = EnvGen.ar(Env.asr(1,1,1),gate);
		sig = sig * env;
		Out.ar(0,sig);
}).add;
)

~one = Synth(\inductionpassthrough)
~one.release



//SynthDef added for triggering and releasing sound channels
//This is a working prototype
(
(
SynthDef(\inductionpassthrough,
	{
		arg gate = 1, amp = 1;
		var sig, env;
		sig = Pan2.ar(SoundIn.ar(0),amp);
		env = EnvGen.ar(Env.asr(1,1,1),gate);
		sig = sig * env;
		Out.ar(0,sig);
}).add;
);
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.993333);
	chain2 = PV_BrickWall(fft,0.13333);
	chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
	SendReply.kr(Impulse.kr(60),'/induction/master',[FFTPower.kr(chain1),FFTPower.kr(chain2),FFTPower.kr(chain3)]);
}.play;
OSCFunc({|msg|
	if (msg[1] == 1) {
		OSCdef(\inductionmics,{|msg|
	~qlc.sendMsg("/inductionlights/low",msg[3].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/mid",msg[4].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/high",msg[5].linlin(0,0.2,0,255).asInt);
	~python.sendMsg("/induction/master",msg);
},'/induction/master');
		~inductionsound = Synth(\inductionpassthrough);
	} {
		OSCdef(\inductionmics,{|msg|
			~qlc.sendMsg("/inductionlights/low",0);
			~qlc.sendMsg("/inductionlights/mid",0);
			~qlc.sendMsg("/inductionlights/high",0);
		},'/induction/master');
		~inductionsound.release;
	}
},'/switch/2');
)

//THIS DOES NOT WORK
(
SynthDef(\inductionanalysis,
	{
		arg gate = 1;
		var in, fft, chain1, chain2, chain3, env, sig;
		in = SoundIn.ar(0);
		fft = FFT(LocalBuf(2048),in);
		chain1 = PV_BrickWall(fft,-0.993333);
		chain2 = PV_BrickWall(fft,0.13333);
		chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
		SendReply.kr(Impulse.kr(60),'/induction/master',[FFTPower.kr(chain1),FFTPower.kr(chain2),FFTPower.kr(chain3)]);
		env = EnvGen.ar(Env.asr(0,0,0),gate);
		sig = SinOsc.ar(210,0,0);
		sig = chain1 * chain2 * chain3 * sig * env;
		Out.ar(0,sig);
}).add;
)

//let's try Ndefs

Ndef(\induction, {
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.993333);
	chain2 = PV_BrickWall(fft,0.13333);
	chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
	SendReply.kr(Impulse.kr(60),'/induction/master',[FFTPower.kr(chain1),FFTPower.kr(chain2),FFTPower.kr(chain3)]);
});
Ndef(\induction).clear
~induction.clear


//NDEFS WORK.

OSCFunc.trace


//a SynthDef which would work nicely to sonify the transfer of SendReply OSC packets




//A version adding the SendReply code as an Ndef which is triggered and released according to the switch state
//IT WORKS!!!!!!!!!!!
/*

EXPLANATION:

This

-contains a synthdef of an audio pass-through on an envelope which is triggered and released by switch 2
- contains an Ndef which splits the incoming audio signal into three hi/mid/low channels in the frequency domain, then sends information about the power of each channel to Q light controller which renders them as r/g/b light and to python which displays the information whtn the information switch is on
- when the switch is released, the Ndef is also released, meaning there are no extraneous signals and no unnecessary stress is placed on the processor, staying true to the stressing of the heartbeat and its discovery by the audience

*/
(
(
SynthDef(\inductionpassthrough,
	{
		arg gate = 1, amp = 1;
		var sig, env;
		sig = Pan2.ar(SoundIn.ar(0),amp);
		env = EnvGen.ar(Env.asr(1,1,1),gate);
		sig = sig * env;
		Out.ar(0,sig);
}).add;
);
OSCFunc({|msg|
	if (msg[1] == 1) {
		Ndef(\induction, {
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.993333);
	chain2 = PV_BrickWall(fft,0.13333);
	chain3 = PV_MagMinus(PV_MagMinus(fft,chain2),chain1);
	SendReply.kr(Impulse.kr(60),'/induction/master',[FFTPower.kr(chain1),FFTPower.kr(chain2),FFTPower.kr(chain3)]);
});
		OSCdef(\inductionmics,{|msg|
	~qlc.sendMsg("/inductionlights/low",msg[3].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/mid",msg[4].linlin(0,0.2,0,255).asInt);
	~qlc.sendMsg("/inductionlights/high",msg[5].linlin(0,0.2,0,255).asInt);
	~python.sendMsg("/induction/master",msg);
},'/induction/master');
		~inductionsound = Synth(\inductionpassthrough);
	} {
		OSCdef(\inductionmics,{|msg|
			~qlc.sendMsg("/inductionlights/low",0);
			~qlc.sendMsg("/inductionlights/mid",0);
			~qlc.sendMsg("/inductionlights/high",0);
		},'/induction/master');
		~inductionsound.release;
		Ndef(\induction).clear;
	}
},'/switch/2');
)


//TODO: Write a new light function to handle incoming OSC messages
//TODO: once i've found a way to cancel the SendReply, sonify each OSC packet. In order to do this i'll need to combine code from the switching  heartbeat and the
