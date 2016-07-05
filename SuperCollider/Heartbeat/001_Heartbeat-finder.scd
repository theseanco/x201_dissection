//setup
~python = NetAddr("127.0.0.1", 9999);|

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


{SinOsc.ar(10,0,0.001)!10}.play

Synth(\heartbeat)
