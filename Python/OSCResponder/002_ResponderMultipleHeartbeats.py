"""OSC Test Script
Written by Aaron Chamberlain Dec. 2013
The purpose of this script is to make a very simple communication structure to the popular
application touchOSC. This is achieved through the pyOSC library. However, since the pyOSC
documentation is scarce and only one large example is included, I am going to strip down
the basic structures of that file to implement a very simple bi-directional communication.
"""

# This is an edited version of the original example, getting rid of the passing-on code.

#!/usr/bin/env python

import socket, OSC, re, time, threading, math, struct
from random import randint
#interpolation tools
from numpy import interp


receive_address = '127.0.0.1', 9999 #Mac Adress, Outgoing Port
send_address = '127.0.0.1', 7700

class PiException(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)

##########################
#	OSC
##########################

# Initialize the OSC server and the client.
s = OSC.OSCServer(receive_address)

# initialise sending
c = OSC.OSCClient()
c.connect(send_address)

# load default handlers
s.addDefaultHandlers()

# define a message-handler function for the server to call.
def test_handler(addr, tags, stuff, source):
	print "---"
	print "received new osc msg from %s" % OSC.getUrlStr(source)
	print "with addr : %s" % addr
	print "typetags %s" % tags
	print "data %s" % stuff
	msg = OSC.OSCMessage()
	msg.setAddress(addr)
	msg.append(stuff)
	print "return message %s" % msg
	print "---"

# an example handler to copy:
"""
def handler1(add, tags, stuff, source):
    things.do()

s.addMsgHandler("/address/here", handler1)

"""

def heartbeat(add, tags, stuff, source):
	# print "HEARTBEAT RECIEVED!"
	decoded = OSC.decodeOSC(stuff[0])
	#supercollider CPU usage and UGens printout
	print "SuperCollider CPU usage: "+str(decoded[7])+" Number of synths: "+str(decoded[3])
	# scaling CPU values
	scaled = int(interp(decoded[7],[0.0,40.0],[20,255]))
	#print decoded[7]
	# ready the osc message
	oscmsg = OSC.OSCMessage()
	#determine which heartbeat to send
	if float(decoded[7]) < 0.8:
		oscmsg.setAddress("/heartbeat/faint")
		print "faint"
	elif decoded[7] < 2.0:
		oscmsg.setAddress("/heartbeat/weak")
		print "weak"
	elif decoded[7] < 7.0:
		oscmsg.setAddress("/heartbeat/medium")
		print "medium"
	elif decoded[7] < 15.0:
		oscmsg.setAddress("/heartbeat/strong")
		print "strong"
	elif decoded[7] < 30.0:
		oscmsg.setAddress("/heartbeat/heavy")
		print "heavy"
	else:
		oscmsg.setAddress("/heartbeat/intense")
		print "intense"

	# adding the CPU usage value to the message, this can be mapped later.
	oscmsg.append(scaled)
	c.send(oscmsg)
	#send message to QLC here. Note that decoded is now a list an i can Use
	# things within it to control stuff in QLC

    #things.do

def heartbeat_lights(add, tags, stuff, source):
	# print "heartbeat_lights"
	x = 0

s.addMsgHandler("/heartbeat/1", heartbeat)
s.addMsgHandler("/heartbeat/on", heartbeat_lights)



# just checking which handlers we have added
print "Registered Callback-functions are :"
for addr in s.getOSCAddressSpace():
	print addr

# Start OSCServer
print "\nStarting OSCServer. Use ctrl-C to quit."
st = threading.Thread( target = s.serve_forever )
st.start()

# Loop while threads are running.
try :
	while 1 :
		time.sleep(10)

except KeyboardInterrupt :
	print "\nClosing OSCServer."
	s.close()
	print "Waiting for Server-thread to finish"
	st.join()
	print "Done"
