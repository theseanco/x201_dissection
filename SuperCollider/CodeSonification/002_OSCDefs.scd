/*

SynthDefs for sonifying code recieved from Python script

all are related, they all use four detuned sines to produce sound

Numbers and letters have a short envelope and are 200Hz and 2000 Hz respectively

Symbols and line breaks have a long envelope and are 100 Hz and 4000 Hz respectively


*/

(
SynthDef(\number,
	{ arg freq = 200, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.01,freq*0.99,freq*1.02,freq*0.98],0,amp));
		env = EnvGen.ar(Env.perc(0.01,0.06),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
SynthDef(\symbol,
	{ arg freq = 100, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.01,freq*0.99,freq*1.02,freq*0.98],0,amp));
		env = EnvGen.ar(Env.perc(0.15,0.15),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
SynthDef(\letter,
	{ arg freq = 2000, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.01,freq*0.99,freq*1.02,freq*0.98],0,amp));
		env = EnvGen.ar(Env.perc(0.01,0.06),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
SynthDef(\linebreak,
	{ arg freq = 4000, amp = 0.2, out = 0;
		var sig,env;
		sig = Mix.ar(SinOsc.ar([freq*1.001,freq*0.999,freq*1.002,freq*0.998],0,amp));
		env = EnvGen.ar(Env.perc(0.15,0.15),1,1,0,1,2);
		sig = sig * env;
		Out.ar(out,Pan2.ar(sig));
}).add;
)

(
Synth(\number);
Synth(\letter);
Synth(\linebreak);
Synth(\symbol);
)

OSCFunc.trace

(
OSCFunc({|msg| Synth(\number)},'/character/number');
OSCFunc({|msg| Synth(\letter)},'/character/letter');
OSCFunc({|msg| Synth(\linebreak)},'/character/linebreak');
OSCFunc({|msg| Synth(\symbol)},'/character/symbol');
)

// MINIMISED VERSION

(
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