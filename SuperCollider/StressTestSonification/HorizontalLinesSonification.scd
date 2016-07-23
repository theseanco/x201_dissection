//sonification of horizontal lines
(
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
)

//sonification of vertical lines
(
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
)

//sonification of strobing
(
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
)

//sonification of blocks
(
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
)

OSCFunc.trace