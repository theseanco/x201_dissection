//analysing induction microphones, getting low/mid/high and translating them into light


~python = NetAddr("127.0.0.1", 9999);
~qlc = NetAddr("127.0.0.1",7700);

//by the looks of the helpfile I can use FFTPower to determine the power of an FFT chain. If i can evenly split the frequency spectrum into 3 I can get the power of each one of these three chains and translate them into values which I can then parse as DMX.

/*

UGens that will be useful

FFTPower - for determining the power of a signal
PV_BrickWall - to zero bins at particular points

What i need is a selective brickwall

-1 - -0.333333
-0.3333 - 0.3333
0.3333 - 1

will also work

I also need a simple playthrough of SoundIn.ar

The issue with BrickWall is that I can't do a band pass with it. Might have to do that in the time domain first?
*/

//this polls everything below -0.3333
//the CPU use actually isn't too excessive, so this won't be too much of an issue
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.3333);
	chain1 = FFTPower.kr(chain1).poll(10);
}.play;
)


//polling 2 chains(z) of FFT
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.3333);
	chain1 = FFTPower.kr(chain1).poll(10);
	chain2 = PV_BrickWall(fft,0.3333);
	chain2 = FFTPower.kr(chain2).poll(10);
}.play;
)

//subtracting chains from master FFT to grab remaining bins
//THIS CRASHES THE SERVER(!!)
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.3333);
	chain1 = FFTPower.kr(chain1).poll(10);
	chain2 = PV_BrickWall(fft,0.3333);
	chain2 = FFTPower.kr(chain2).poll(10);
	chain3 = fft - chain1 - chain2;
	chain3 = FFTPower.kr(chain3).poll(10);
}.play;
)

//PV_MagMinus is probably the answer to this, simple subtraction doesn't do the same thing for reasons
// A meaningful, working spectral analysis of three equal bands
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.3333);
	chain1 = FFTPower.kr(chain1).poll(10);
	chain2 = PV_BrickWall(fft,0.3333);
	chain2 = FFTPower.kr(chain2).poll(10);
	chain3 = PV_MagMinus(fft,chain1);
	chain3 = PV_MagMinus(chain3,chain2);
	chain3 = FFTPower.kr(chain3).poll(10);
}.play;
)


//grabbing the values of the bin powers and sending them as OSC to places
//An issue with sending these values on to QLC directly is that .asInt might not work on them with it being a UGen, although having said that I can probablt just handle this with OSCFuncs going out.
//this is working, although I initially had some issues that were solved by restarting the system
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.3333);
	chain1 = SendReply.kr(Impulse.kr(60),'/induction/low',FFTPower.kr(chain1));
	chain2 = PV_BrickWall(fft,0.3333);
	chain2 = SendReply.kr(Impulse.kr(60),'/induction/high',FFTPower.kr(chain2));
	chain3 = PV_MagMinus(fft,chain1);
	chain3 = PV_MagMinus(chain3,chain2);
	chain3 = SendReply.kr(Impulse.kr(60),'/induction/mid',FFTPower.kr(chain3));
}.play;
)

//adding OSCdefs to send this on to QLC and get some lighting started. What would be a nice idea though would be to do some multichannel expansion on the SendReply to send it as an array of low-mid-hi.
//If this was sent as an array it would be much easier to package up and send to Python for display on one line in the terminal and to do other things in one function with all three values.
//issues: low and mid are almost the same for some reason
(
{
	var in, fft, chain1, chain2, chain3;
	in = SoundIn.ar(0);
	fft = FFT(LocalBuf(2048),in);
	chain1 = PV_BrickWall(fft,-0.33333);
	chain1 = SendReply.kr(Impulse.kr(60),'/induction/low',FFTPower.kr(chain1));
	chain2 = PV_BrickWall(fft,0.33333);
	chain2 = SendReply.kr(Impulse.kr(60),'/induction/high',FFTPower.kr(chain2));
	chain3 = PV_MagMinus(fft,chain1);
	chain3 = PV_MagMinus(chain3,chain2);
	chain3 = SendReply.kr(Impulse.kr(60),'/induction/mid',FFTPower.kr(chain3));
}.play;
OSCdef(\inductionlow,{|msg| ~qlc.sendMsg("/inductionlights/low",msg[3].linlin(0,1,0,255).asInt)},'/induction/low');
OSCdef(\inductionmid,{|msg| ~qlc.sendMsg("/inductionlights/mid",msg[3].linlin(0,1,0,255).asInt)},'/induction/mid');
OSCdef(\inductionhigh,{|msg| ~qlc.sendMsg("/inductionlights/high",msg[3].linlin(0,1,0,255).asInt)},'/induction/high');
)


//this optimisation is much better, skewing the overall balance MUCH lower.
/*

the scale now becomes

-1 -0.993333 : low
-0.99333 0.13333 : mid
0.1333 1 : hi

This is to account for the logarithmic nature of the frequency spectrum (which I had forgotten about prior)

*/
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
OSCdef(\inductionlow,{|msg| ~qlc.sendMsg("/inductionlights/low",msg[3].linlin(0,1,0,255).asInt)},'/induction/low');
OSCdef(\inductionmid,{|msg| ~qlc.sendMsg("/inductionlights/mid",msg[3].linlin(0,1,0,255).asInt)},'/induction/mid');
OSCdef(\inductionhigh,{|msg| ~qlc.sendMsg("/inductionlights/high",msg[3].linlin(0,1,0,255).asInt)},'/induction/high');
)



//adjusting sensitivity
//This is now the working prototype
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
