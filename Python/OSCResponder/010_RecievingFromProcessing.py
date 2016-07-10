"""OSC Test Script
Written by Aaron Chamberlain Dec. 2013
The purpose of this script is to make a very simple communication structure to the popular
application touchOSC. This is achieved through the pyOSC library. However, since the pyOSC
documentation is scarce and only one large example is included, I am going to strip down
the basic structures of that file to implement a very simple bi-directional communication.
"""

# This is an edited version of the original example, getting rid of the passing-on code.

#!/usr/bin/env python

# TODO: Switch de-bouncing

import socket, OSC, re, time, threading, math, struct
from random import randint
#interpolation tools
from numpy import interp
import os

# Declaring OSC addresses
receive_address = '127.0.0.1', 9999 #Mac Adress, Outgoing Port
send_address = '127.0.0.1', 7700
SC_address = '127.0.0.1', 57120
Processing_address = '127.0.0.1', 12000

sw1 = 0
sw2 = 0
sw3 = 0
sw4 = 0

class PiException(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)

##########################
#	OSC##########################

# Initialize the OSC server and the client.
s = OSC.OSCServer(receive_address)

# initialise sending
c = OSC.OSCClient()
c.connect(send_address)

# initialise SuperCollider connection
scclient = OSC.OSCClient()
scclient.connect(SC_address)

# initialise Processing connection
processingclient = OSC.OSCClient()
processingclient.connect(Processing_address)

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

#capacitive sensor responder
# TODO: Ask tom if using a global variable is the most efficient way of doing this
# This sends to SuperCollider, as there's already global variable magic controlling other functions in here
# This is used to define and re-define OSC responders which control heartbeat and assorted ticking functions
def sensor_1(add,tags,stuff,source):
	global sw1
	# a bit of threshold logic to prevent messages being sent repeatedly
	if int(stuff[0]) > 2000:
		if sw1 == 0:
			sw1 = 1
			print "SWITCH 1 ON"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/1")
			oscmsg.append(1)
			scclient.send(oscmsg)
	else:
		if sw1 == 1:
			sw1 = 0
			print "SWITCH 1 OFF"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/1")
			oscmsg.append(0)
			scclient.send(oscmsg)

# second sensor, sending this one to SuperCollider also, this controls the induction coil lights & sound
# TODO: handle switching on/off of signals within SuperCollider
def sensor_2(add,tags,stuff,source):
	global sw2
	# a bit of threshold logic to prevent messages being sent repeatedly
	if int(stuff[0]) > 2000:
		if sw2 == 0:
			sw2 = 1
			print "SWITCH 2 ON"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/2")
			oscmsg.append(1)
			scclient.send(oscmsg)
	else:
		if sw2 == 1:
			sw2 = 0
			print "SWITCH 2 OFF"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/2")
			oscmsg.append(0)
			scclient.send(oscmsg)

# TODO: write functions for remaning 2 switches
def sensor_3(add, tags, stuff, source):
	global sw3
	if int(stuff[0]) > 2000:
		if sw3 == 0:
			sw3 = 1
			print "SWITCH 3 ON"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/3")
			oscmsg.append(1)
			# messages to be sent to processing to trigger stress testing procedures
			processingclient.send(oscmsg)
	else:
		if sw3 == 1:
			sw3 = 0
			print "SWITCH 3 OFF"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/3")
			oscmsg.append(0)
			processingclient.send(oscmsg)

def sensor_4(add, tags, stuff, source):
	x = 0


def heartbeat(add, tags, stuff, source):
	global sw1
	if sw1 == 1:
		# print "HEARTBEAT RECIEVED!"
		decoded = OSC.decodeOSC(stuff[0])
		#supercollider CPU usage and UGens printout
		print "SuperCollider CPU usage: "+str(round(decoded[7],4))+" Number of synths: "+str(decoded[3])
		# scaling CPU values
		scaled = int(interp(decoded[7],[0.0,40.0],[20,255]))
		#print decoded[7]
		# ready the osc message
		oscmsg = OSC.OSCMessage()
		#determine which heartbeat to send
		if float(decoded[7]) < 2.0:
			oscmsg.setAddress("/heartbeat/faint")
			print "faint"
		elif decoded[7] < 6.0:
			oscmsg.setAddress("/heartbeat/weak")
			print "weak"
		elif decoded[7] < 10.0:
			oscmsg.setAddress("/heartbeat/medium")
			print "medium"
		elif decoded[7] < 20.0:
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

# detects supercollider envelope onsets
def supercollider_envelope_on(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		oscmsg = OSC.OSCMessage()
		oscmsg.setAddress("/sc_envelope/on")
		oscmsg.append(1)
		c.send(oscmsg)
		# print "on"

# detects supercollider envelope offsets
def supercollider_envelope_off(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		oscmsg = OSC.OSCMessage()
		oscmsg.setAddress("/sc_envelope/off")
		oscmsg.append(1)
		c.send(oscmsg)
		# print "off"

# indices 5, 6 and 7 of the 'stuff' contains hi/mid/low figures
# An issue with this is that I want to slow down printing, but can't within this function
# Iterating within functions is becoming an issue
# I want to print the values within the message every ten times this function is run.
def inductionmics(add,tags,stuff,source):
	global sw1
	global sw2
	# check if the switch is on, this is the same switch that controls the inducton light/sound
	if sw2 == 1:
		# this should only be displayed if the 'information' switch (switch 1) is on
		if sw1 == 1:
			# decoded OSC message, this needs to be done to the whole message and then
			# the goodies need to be parsed out because OSC and arrays don't mix well
			decoded = OSC.decodeOSC(stuff[0])
			#TODO: Sort this out. Print this every ten times this function is run
			print "Induction Power: Low - "+str(round(decoded[4],3))+" Mid - "+str(round(decoded[5],3))+" Hi - "+str(round(decoded[6],3))


# Print information from processing where relevant
def processingprint(add,tags,stuff,source):
	global sw1
	# if information switch is on, prints anything recieved from Processing
	if sw1 == 1:
		print(stuff)

# handler for processing sending strobing information
def processingstrobe(add,tags,stuff,source):
	global sw1
	#if information switch is on
	if sw1 == 1:
		print("Stress Test: Strobe!")



# These are coming from SuperCollider
s.addMsgHandler("/heartbeat/1", heartbeat)
s.addMsgHandler("/env/on", supercollider_envelope_on)
s.addMsgHandler("/env/off", supercollider_envelope_off)

# Handlers for sensor messages
s.addMsgHandler("/sensors/1", sensor_1)
s.addMsgHandler("/sensors/2", sensor_2)
s.addMsgHandler("/sensors/3", sensor_3)
s.addMsgHandler("/sensors/4", sensor_4)

# Handler for induction mic data
s.addMsgHandler("/induction/master", inductionmics)

# Handler for printing processing
s.addMsgHandler("/processing/printing", processingprint)



# just checking which handlers we have added
print "Registered Callback-functions are :"
for addr in s.getOSCAddressSpace():
	print addr

# Start OSCServer
print "\nStarting OSCServer. Use ctrl-C to quit."
st = threading.Thread( target = s.serve_forever )
st.start()

# Now that OSCServer has started, start Capacitive Sensor script
os.system("python ../SerialToOSC/SerialToOSC.py")
print "Serial to OSC initialised"

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
