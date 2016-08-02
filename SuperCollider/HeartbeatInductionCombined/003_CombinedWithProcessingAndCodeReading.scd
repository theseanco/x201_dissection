//combining the 'heartbeat' and 'induction mic' code

//this (or a version of this) can be used to sonify induction data
(
SynthDef(\sinblip,
	{
		arg freq = 8000, b1 = 1.01, b2 = 0.99, b3 = 1.02;
		var sig, env;
		env = EnvGen.ar(Env.perc(0.01,Rand(0.05,0.3)),1,1,0,1,2);
		sig = Splay.ar(SinOsc.ar([freq,freq*b1,freq*b2,freq*b3]+(env*Rand(-500,2000)),0,0.6));
		sig = sig * env;
		Out.ar(0,sig);
}).add;
);


//original heartbeat code
/*
(
~python = NetAddr("127.0.0.1", 9999);
~qlc = NetAddr("127.0.0.1",7700);
(
SynthDef(\heartbeat,{
	arg freq = 440, atk = 0.001, rel = 1, amp = 0.4;
	var sig, env, fenv;
	env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
	sig = SinOsc.ar(env*freq,0,amp);
	sig = sig * env;
	Out.ar(0,Pan2.ar(sig));
}).add;
);
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
)
*/

//heartbeat code with new synth and switching added
(
s.boot;
~python = NetAddr("127.0.0.1", 9999);
~qlc = NetAddr("127.0.0.1",7700);
(
SynthDef(\heartbeat,{
	arg freq = 440, atk = 0.001, rel = 1, amp = 0.4;
	var sig, env, fenv;
	env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
	sig = SinOsc.ar(env*freq,0,amp);
	sig = sig * env;
	Out.ar(0,Pan2.ar(sig));
}).add;
);
(
SynthDef(\sinblip,
	{
		arg freq = 8000, b1 = 1.01, b2 = 0.99, b3 = 1.02;
		var sig, env;
		env = EnvGen.ar(Env.perc(0.01,Rand(0.05,0.3)),1,1,0,1,2);
		sig = Splay.ar(SinOsc.ar([freq,freq*b1,freq*b2,freq*b3]+(env*Rand(-500,2000)),0,0.6));
		sig = sig * env;
		Out.ar(0,sig);
}).add;
);
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
		//sonify the induction analysis OSC traffic
		OSCdef(\inductionsonification,{|msg| Synth(\sinblip)},'/induction/master');
		//send a message to trigger a glow in light 1
		~qlc.sendMsg("/light1/glow",1);
		"switch on".postln
	} {
		OSCdef(\heartbeat,{|msg|},'/status.reply');
		OSCdef(\envon,{|msg|},'/n_go');
		OSCFunc(\envoff,{|msg|},'/n_end');
		OSCdef(\inductionsonification,{|msg|},'/induction/master');
		"switch off".postln
	}
},'/switch/1');
)


//combined with induction code AND SONIFICATION CODE
(
s.boot;
~python = NetAddr("127.0.0.1", 9999);
~qlc = NetAddr("127.0.0.1",7700);
(
SynthDef(\heartbeat,{
	arg freq = 440, atk = 0.001, rel = 1, amp = 0.4;
	var sig, env, fenv;
	env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
	sig = SinOsc.ar(env*freq,0,amp);
	sig = sig * env;
	Out.ar(0,Pan2.ar(sig));
}).add;
);
(
SynthDef(\sinblip,
	{
		arg freq = 8000, b1 = 1.01, b2 = 0.99, b3 = 1.02;
		var sig, env;
		env = EnvGen.ar(Env.perc(0.01,Rand(0.05,0.3)),1,1,0,1,2,doneAction:2);
		sig = Splay.ar(SinOsc.ar([freq,freq*b1,freq*b2,freq*b3]+(env*Rand(-500,2000)),0,0.6));
		sig = sig * env;
		Out.ar(0,sig);
}).add;
);
(
SynthDef(\inductionpassthrough,
	{
		arg gate = 1, amp = 1;
		var sig, env;
		sig = Pan2.ar(SoundIn.ar(0),amp);
		env = EnvGen.ar(Env.asr(1,1,1),gate,doneAction:2);
		sig = sig * env;
		Out.ar(0,sig);
}).add;
);
//HEARTBEAT OSC FUNC
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
		//sonify the induction analysis OSC traffic
		OSCdef(\inductionsonification,{|msg| Synth(\sinblip)},'/induction/master');
		//send a message to trigger a glow in light 1
		~qlc.sendMsg("/light1/glow",1);
		"switch on".postln
	} {
		OSCdef(\heartbeat,{|msg|},'/status.reply');
		OSCdef(\envon,{|msg|},'/n_go');
		OSCFunc(\envoff,{|msg|},'/n_end');
		OSCdef(\inductionsonification,{|msg|},'/induction/master');
		"switch off".postln
	}
},'/switch/1');
//INDUCTION OSC FUNC
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
//sonification of horizontal lines
SynthDef(
	\horizontal,
	{ arg freq = 440, amp = 0.1, fb = 1;
		var sig, env;
		sig = SinOscFB.ar(freq,SinOsc.kr(rrand(0.01,0.2)).range(fb),amp);
		env = EnvGen.ar(Env.linen(0.01,0.1,0.01),doneAction:2);
		sig = sig * env;
		Out.ar(0,Pan2.ar(sig))
}).add;
OSCFunc({|msg| Task({msg[1].do({|i, f = 100|Synth(\horizontal,[\freq,(f+((i*40)))%2000]);msg[1].linlin(1,720,0.01,0.02).wait;})}).start},'/processing/horizontallines');

//sonification of vertical lines
SynthDef(
	\vertical,
	{ arg freq = 440, amp = 0.1, fb = 1;
		var sig, env;
		sig = SinOscFB.ar(freq,SinOsc.kr(rrand(0.01,0.2)).range(fb),amp);
		env = EnvGen.ar(Env.linen(0.01,0.1,0.01),doneAction:2);
		sig = sig * env;
		Out.ar(0,Pan2.ar(sig))
}).add;
OSCFunc({|msg| Task({msg[1].do({|i, f = 100|Synth(\vertical,[\freq,(f-((i*40)))%2000]);msg[1].linlin(1,720,0.01,0.02).wait;})}).start},'/processing/verticallines');

//sonification of strobing
SynthDef(
	\strobe,
	{ arg f1 = 1440, f2 = 1471, f3 = 1342, amp = 0.5, width = 0.6;
		var sig, env, fenv;
		fenv = EnvGen.ar(Env.perc(0.01,0.15),1,1);
		sig = Splay.ar(Pulse.ar([f1,f2,f3]*(fenv+0.05),width,amp));
		env = EnvGen.ar(Env.perc(0.01,0.15),doneAction:2);
		sig = sig * env;
		Out.ar(0,sig);
}).add;
OSCFunc({|msg| Synth(\strobe,
	[\f1,(msg[1]+40)*3,\f2,(msg[2]+40)*3,\f3,(msg[3]+40)*3,\width,rrand(0.01,0.6)])},'/processing/strobe');

//sonification of blocks
SynthDef(
	\block,
	{arg freq = 440, amp = 0.5;
		var sig,env;
		sig = Pulse.ar(freq,0.5,amp);
		env = EnvGen.ar(Env.perc(0.001,0.001),doneAction:2);
		sig = sig * env;
		Out.ar(0,Pan2.ar(sig));
}).add;
OSCFunc({|msg| Task({|i|msg[1].do({Synth(\block,[\freq,rrand(100,10000),\amp,msg[1].linlin(8,1024,0.5,0.2)]);msg[1].linlin(8,1024,0.01,0.005).wait;})}).start;},'/processing/horizontalblocks');

//Sonification of code reading
SynthDef(\character,
	{ arg freq = 1000, amp = 0.1, out = 0, atk = 0.01, rel = 0.06;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.001,freq*0.999,freq*1.002,freq*0.998],0,amp));
		env = EnvGen.ar(Env.perc(atk,rel),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
OSCFunc({|msg| Synth(\character,[\freq,200])},'/character/number');
OSCFunc({|msg| Synth(\character,[\freq,2000])},'/character/letter');
OSCFunc({|msg| Synth(\character,[\atk,0.15,\rel,0.15,\freq,4000])},'/character/linebreak');
OSCFunc({|msg| Synth(\character,[\atk,0.15,\rel,0.15,\freq,100])},'/character/symbol');
)


OSCFunc.trace