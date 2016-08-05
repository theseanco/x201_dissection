"""
MODIFIED FROM :
OSC Test Script
Written by Aaron Chamberlain Dec. 2013
The purpose of this script is to make a very simple communication structure to the popular
application touchOSC. This is achieved through the pyOSC library. However, since the pyOSC
documentation is scarce and only one large example is included, I am going to strip down
the basic structures of that file to implement a very simple bi-directional communication.
"""

# This is an edited version of the original example, getting rid of the passing-on code.

#!/usr/bin/env python

# TODO: Switch de-bouncing
# TODO: Format other code to be printed by paragraph
# TODO: ask tom about conditional statements for the letter printer: How can I print when it is on, and not print when it is OFF
# TODO: using the format /switch/x/on show light 'blooming' when switches triggered
# TODO: use overall CPU usage rather than CPU usage from SuperCollider?

import socket, OSC, re, time, threading, math, struct, random, os, psutil
from numpy import interp

# Declaring OSC addresses
receive_address = '127.0.0.1', 9999 #Mac Adress, Outgoing Port
qlc_address = '127.0.0.1', 7700
SC_address = '127.0.0.1', 57120
Processing_address = '127.0.0.1', 12000
pythonslave_address = '127.0.0.1', 9998

# Declaring global switch variable and switch sensitivity
sw1 = 0
sw2 = 0
sw3 = 0
sw4 = 0
# this used to be adjusting for CapSense but is now handled by Adafruit board
swsens = 1
inductioniter = 0

# Exception class (nopt used)
class PiException(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)

# Initialize the OSC server and the client.
s = OSC.OSCServer(receive_address)
# initialise QLC+ connecyion
qlcclient = OSC.OSCClient()
qlcclient.connect(qlc_address)
# initialise SuperCollider connection
scclient = OSC.OSCClient()
scclient.connect(SC_address)
# initialise Processing connection
processingclient = OSC.OSCClient()
processingclient.connect(Processing_address)
# initialise python printer connection
pythonclient = OSC.OSCClient()
pythonclient.connect(pythonslave_address)
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

#capacitive sensor responder
# This sends to SuperCollider, as there's already global variable magic controlling other functions in here
# This is used to define and re-define OSC responders which control heartbeat and assorted ticking functions
def sensor_1(add,tags,stuff,source):
	global sw1
	# a bit of threshold logic to prevent messages being sent repeatedly
	if int(stuff[0]) == swsens:
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
def sensor_2(add,tags,stuff,source):
	global sw1
	global sw2
	# a bit of threshold logic to prevent messages being sent repeatedly
	if int(stuff[0]) == swsens:
		if sw2 == 0:
			sw2 = 1
			if sw1 == 1:
				print "SWITCH 2 ON"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/2")
			oscmsg.append(1)
			scclient.send(oscmsg)
			# Send glow message to QLC
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/2/on")
			oscmsg.append(1)
			qlcclient.send(oscmsg)
	else:
		if sw2 == 1:
			sw2 = 0
			if sw1 == 1:
				print "SWITCH 2 OFF"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/2")
			oscmsg.append(0)
			scclient.send(oscmsg)

def sensor_3(add, tags, stuff, source):
	global sw3
	global sw1
	if int(stuff[0]) == swsens:
		if sw3 == 0:
			sw3 = 1
			if sw1 == 1:
				print "SWITCH 3 ON"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/3")
			oscmsg.append(1)
			# messages to be sent to processing to trigger stress testing procedures
			processingclient.send(oscmsg)
			# Send glow message to QLC
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/3/on")
			oscmsg.append(1)
			qlcclient.send(oscmsg)
	else:
		if sw3 == 1:
			sw3 = 0
			if sw1 == 1:
				print "SWITCH 3 OFF"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/3")
			oscmsg.append(0)
			processingclient.send(oscmsg)

# Paragraph printer goes here
def sensor_4(add, tags, stuff, source):
	# global variables for switch, scripts & script printing
	global sw1
	global sw4
	global scripts
	global scriptprint
	if int(stuff[0]) == swsens:
		if sw4 == 0:
			sw4 = 1
			if sw1 == 1:
				print "SWITCH 4 ON"
			# Send glow message to QLC
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/4/on")
			oscmsg.append(1)
			qlcclient.send(oscmsg)
		if sw4 == 1:
				oscmsg = OSC.OSCMessage()
				oscmsg.setAddress("/switch/printing")
				oscmsg.append(1)
				pythonclient.send(oscmsg)
	else:
		if sw4 == 1:
			sw4 = 0
			if sw1 == 1:
				print "SWITCH 4 OFF"
			oscmsg = OSC.OSCMessage()
			oscmsg.setAddress("/switch/printing")
			oscmsg.append(0)
			pythonclient.send(oscmsg)


# Responder which detects SuperCollider CPU load and puts out a corresponding OSC message
# OSC messages are recieved by QLC+
def heartbeat(add, tags, stuff, source):
	global sw1
	cpu = psutil.cpu_percent()
	if sw1 == 1:
		# print "HEARTBEAT RECIEVED!"
		decoded = OSC.decodeOSC(stuff[0])
		#supercollider CPU usage and UGens printout
		print "CPU %/Number of Sounds: "+str(cpu)+"/"+str(decoded[3])
		# scaling CPU values
		cpufloat = float(cpu)
		#print decoded[7]
		# ready the osc message
		oscmsg = OSC.OSCMessage()
		#determine which heartbeat to send
		if cpufloat < 2.0:
			oscmsg.setAddress("/heartbeat/faint")
		elif cpufloat < 6.0:
			oscmsg.setAddress("/heartbeat/weak")
		elif cpufloat < 10.0:
			oscmsg.setAddress("/heartbeat/medium")
		elif cpufloat < 20.0:
			oscmsg.setAddress("/heartbeat/strong")
		elif cpufloat < 30.0:
			oscmsg.setAddress("/heartbeat/heavy")
		else:
			oscmsg.setAddress("/heartbeat/intense")

		# adding the CPU usage value to the message, this can be mapped later.
		oscmsg.append(cpufloat)
		qlcclient.send(oscmsg)
		#send message to QLC here. Note that decoded is now a list an i can Use
		# things within it to control stuff in QLC

# detects supercollider envelope onsets
def supercollider_envelope_on(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		oscmsg = OSC.OSCMessage()
		oscmsg.setAddress("/sc_envelope/on")
		oscmsg.append(1)
		qlcclient.send(oscmsg)
		# print "on"

# detects supercollider envelope offsets
def supercollider_envelope_off(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		oscmsg = OSC.OSCMessage()
		oscmsg.setAddress("/sc_envelope/off")
		oscmsg.append(1)
		qlcclient.send(oscmsg)
		# print "off"

# evil global variable for iteration control
indictioniter = 0
def inductionmics(add,tags,stuff,source):
	global sw1
	global sw2
	global inductioniter
	# check if the switch is on, this is the same switch that controls the inducton light/sound
	if sw2 == 1:
		# this should only be displayed if the 'information' switch (switch 1) is on
		if sw1 == 1:
			# decoded OSC message, this needs to be done to the whole message and then
			# the goodies need to be parsed out because OSC and arrays don't mix well
			# indices 5, 6 and 7 of the 'stuff' contains hi/mid/low figures
			decoded = OSC.decodeOSC(stuff[0])
			#TODO: Sort this out. Print this every ten times this function is run
			if inductioniter % 30 == 0:
				print "Induction Power: Low - "+str(round(decoded[4],3))+" Mid - "+str(round(decoded[5],3))+" Hi - "+str(round(decoded[6],3))
			inductioniter = inductioniter + 1

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
		print("strobe colour = "+str(stuff[0])+" "+str(stuff[1])+" "+str(stuff[2]))

# handler for processing sending number of vertical lines drawn
def processingvertical(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		print("vertical bands: "+str(stuff[0]))

# handler for processing sending number of horizontal lines drawn
def processinghorizontal(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		print("horizontal bands: "+str(stuff[0]))

# handler for processing sending block numbers
def processingblocks(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		print("blocks: "+str(stuff[0]))

def printLetter(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		print("letter printed:"+stuff[1])

def printNumber(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		print("number printed:"+stuff[1])

def printSymbol(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		print("symbol printed:"+stuff[1])

def printLinebreak(add,tags,stuff,source):
	global sw1
	if sw1 == 1:
		print("line break printed")

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
s.addMsgHandler("/processing/strobe", processingstrobe)
s.addMsgHandler("/processing/verticallines",processingvertical)
s.addMsgHandler("/processing/horizontallines",processinghorizontal)
s.addMsgHandler("/processing/blocks",processingblocks)

# Handlers for displaying information about printed code characters
s.addMsgHandler("/character/letter",printLetter)
s.addMsgHandler("/character/number",printNumber)
s.addMsgHandler("/character/symbol",printSymbol)
s.addMsgHandler("/character/linebreak",printLinebreak)

# just checking which handlers we have added
print "Registered Callback-functions are :"
for addr in s.getOSCAddressSpace():
	print addr

# Start OSCServer
print "\nStarting OSCServer. Use ctrl-C to quit."
st = threading.Thread( target = s.serve_forever )
st.start()

# Now that OSCServer has started, start Capacitive Sensor script
os.system("python ../SerialToOSC/CAP1188ToOSC.py")
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
