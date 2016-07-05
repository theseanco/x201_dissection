//setup
~python = NetAddr("127.0.0.1", 9999);

//This is a simple function to print the server status to the post window whenever it is received. It is what controls the SuperCollider status bar at the bottom of the window
OSCFunc({|msg| msg.postln},'/status.reply')

//a function to bag this and send it on to Python, which will then print it and send it to a relevant channel/scene/function in QLC+
OSCFunc({|msg| ~python.sendMsg("/heartbeat/1",msg)},'/status.reply')

//heartbeat synth, basic enveloped sine
(
SynthDef(\heartbeat,{
	arg freq = 440, atk = 0.001, rel = 1, amp = 0.4;
	var sig, env, fenv;
	env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
	sig = SinOsc.ar(env*freq,0,amp);
	sig = sig * env;
	Out.ar(0,Pan2.ar(sig));
}).add;
)

(
//a function to trigger SuperCollider heartbeat
//bearing in mind i'm going to need some kind of master function to trigger all of this when the right switch is pressed
OSCFunc({|msg| ~python.sendMsg("/heartbeat/1",msg); Synth(\heartbeat,[\freq,msg[6].linlin(0.0,50.0,70,2000),\amp,msg[6].linlin(0.0,50.0,0.1,3),\rel,msg[6].linlin(0.0,50.0,0.05,1)])},'/status.reply');
//OSC functions about Envelopes to send on
OSCFunc({|msg| ~python.sendMsg("/env/on","on")},'/n_go');
OSCFunc({|msg| ~python.sendMsg("/env/off","off")},'/n_end');
)


//So, when i recieve information that switch 1 has been triggered, I should activate a bunch of OSCFuncs, when I recieve information that Switch1  is back off, I should un-activate those funcs.
//I NEED TO DO THIS IN DEF STYLE, THE FUNCTIONS ARE PERMANENT ONCE SENT TO THE SERVER
//Don't forget, the master one has to be a Func because Defs can't contain if statements for reasons.
(
OSCFunc({|msg|
	if (msg[1] == 1) {
		OSCFunc({|msg|
			~python.sendMsg("/heartbeat/1",msg);
			Synth(\heartbeat,[\freq,msg[6].linlin(0.0,50.0,70,2000),
				\amp,msg[6].linlin(0.0,50.0,0.1,3),
				\rel,msg[6].linlin(0.0,50.0,0.05,1)])},
		'/status.reply');
		//OSC functions about Envelopes to send on
		OSCFunc({|msg| ~python.sendMsg("/env/on","on")},'/n_go');
		OSCFunc({|msg| ~python.sendMsg("/env/off","off")},'/n_end');
		"switch on".postln
	} {
		OSCFunc({|msg|},'/status.reply');
		OSCFunc({|msg|},'/n_go');
		OSCFunc({|msg|},'/n_end');
		"switch off".postln
	}
},'/switch/1');
)


//def style
//also sends a glow to qlc+
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