//setup
~python = NetAddr("127.0.0.1", 9999);


//This is a simple function to print the server status to the post window whenever it is received. It is what controls the SuperCollider status bar at the bottom of the window
OSCFunc({|msg| msg.postln},'/status.reply')

//a function to bag this and send it on to Python, which will then print it and send it to a relevant channel/scene/function in QLC+
OSCFunc({|msg| ~python.sendMsg("/heartbeat/1",msg)},'/status.reply')
