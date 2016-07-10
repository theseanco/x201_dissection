(
SynthDef(
	\strobe,
	{ arg f1 = 1440, f2 = 1471, f3 = 1342, amp = 0.5, width = 0.6;
		var sig, env, fenv;
		fenv = EnvGen.ar(Env.perc(0.01,0.1),1,1);
		sig = Splay.ar(Pulse.ar([f1,f2,f3]*(fenv+0.05),width,amp));
		env = EnvGen.ar(Env.perc(0.01,0.1),doneAction:2);
		sig = sig * env;
		Out.ar(0,sig);
}).add;


OSCFunc({|msg| Synth(\strobe,
	[\f1,(msg[1]+40)*3,\f2,(msg[2]+40)*3,\f3,(msg[3]+40)*3,\width,rrand(0.01,0.6)])},'/processing/strobe');
)

(
SynthDef(
	\horizontal,
	{ arg freq = 440, amp = 0.01, fb = 0.5;
		var sig, env;
		sig = SinOscFB.ar(freq,SinOsc.kr(rrand(0.01,0.2)).range(fb),amp);
		env = EnvGen.ar(Env.linen(0.01,0.1,0.4),doneAction:2);
		sig = sig * env;
		Out.ar(0,Pan2.ar(sig))
}).add;
)

(
SynthDef(
	\block,
	{arg freq = 440, amp = 0.01;
		var sig,env;
		sig = Pulse.ar(freq,0.5,amp);
		env = EnvGen.ar(Env.perc(0,0.001),doneAction:2);
		sig = sig * env;
		Out.ar(0,Pan2.ar(sig));
}).add;
)

Task({720.do({|i|Synth(\horizontal,[\freq,i*10]);0.001.wait;})}).start

Task({64400.do({|i|Synth(\block,[\freq,(i*10)%10000]);0.0001.wait;})}).start

//a function which performs a modulo on frequencies based on number of boxes on screen
//The wait time is scaled according to the number of boxes to allow for the fact that masses upon masses of boxes will be triggered
OSCFunc({|msg| Task({msg[1].do({|i|Synth(\block,[\freq,((i*100)%10000)+100]);msg[1].explin(40,655360,0.001,0.00001).wait;})}).start},'/processing/blocks')




OSCFunc.trace
Synth(\strobe)