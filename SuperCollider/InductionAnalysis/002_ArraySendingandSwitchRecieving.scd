/*

TODO:

- Send low/mid/high messages as an array
- Handle the messages in Python and turn printing them on and off when switch 2 is triggered
- Turn on and off the sending of these values anywhere by recieving values from switch 2 in Python and sending them on to SC. Use the same protocol as used for the sending of envelope on/offsets
- Turn on and off a sound pass-through according to OSC signals recieved from Python

*/

//
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