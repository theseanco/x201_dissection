/*

SynthDefs for sonifying code recieved from Python script

all are related, they all use four detuned sines to produce sound

Numbers and letters have a short envelope and are 200Hz and 2000 Hz respectively

Symbols and line breaks have a long envelope and are 100 Hz and 4000 Hz respectively


*/

(
SynthDef(\numbers,
	{ arg freq = 200, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.01,freq*0.99,freq*1.02,freq*0.98],0,amp));
		env = EnvGen.ar(Env.perc(0.01,0.06),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
SynthDef(\symbols,
	{ arg freq = 100, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.01,freq*0.99,freq*1.02,freq*0.98],0,amp));
		env = EnvGen.ar(Env.perc(0.6,0.06),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
SynthDef(\letters,
	{ arg freq = 2000, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.01,freq*0.99,freq*1.02,freq*0.98],0,amp));
		env = EnvGen.ar(Env.perc(0.01,0.06),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
SynthDef(\linebreaks,
	{ arg freq = 4000, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.001,freq*0.999,freq*1.002,freq*0.998],0,amp));
		env = EnvGen.ar(Env.perc(0.6,0.06),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
)
(
Synth(\numbers);
Synth(\letters);
Synth(\linebreaks);
Synth(\symbols);
)