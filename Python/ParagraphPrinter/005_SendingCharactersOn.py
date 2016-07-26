# A separate script to print paragraphs from programs in another terminal window
# this is run in tandem with a larger script which controls Arduino switching
# To be run in a second terminal window

"""
Addresses
/character/number
/character/letter
/character/symbol
/character/linebreak
"""

import os, random, time, sys, OSC, threading, re

#declaring OSC Addresses
receive2_address = '127.0.0.1', 9998 #Mac Adress, Outgoing Port
SC_address = '127.0.0.1', 57120
qlc_address = '127.0.0.1', 7700
python_address = '127.0.0.1', 9999
# Initialize the OSC server and the client.
s = OSC.OSCServer(receive2_address)
# initialise SuperCollider connection
scclient = OSC.OSCClient()
scclient.connect(SC_address)
# initialise qlc connection
qlcclient = OSC.OSCClient()
qlcclient.connect(qlc_address)
# initialise python master connection
pythonclient = OSC.OSCClient()
pythonclient.connect(python_address)
s.addDefaultHandlers()

# Exception class (nopt used)
class PiException(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)

# switch variable
sw4 = 0
# number of characters printed
character = 0
# script to be printed
code = ''

# open code to be read and split into paragraphs
pyscript = open(os.path.join(os.path.dirname(__file__), 'TestScripts/python.py'))
pyparagraph = []
scscript = open(os.path.join(os.path.dirname(__file__), 'TestScripts/supercollider.scd'))
scparagraph = []
pdescript = open(os.path.join(os.path.dirname(__file__), 'TestScripts/processing.pde'))
pdeparagraph = []
# fill array with script names to be called later
scripts = [scparagraph, pdeparagraph, pyparagraph]

letterexp = re.compile('[a-zA-Z]')
numberexp = re.compile('[0-9]')
symbolexp = re.compile('[^0-9a-zA-Z \n  ]')

# A function which chops scripts into paragraphs
def chopscript(script,out):
    para = []
    # splits the script into paragraphs
    for line in script:
        if line == "\n":
            para.append(line)
            out.append(para)
            para = []
        else:
            para.append(line)

# calls the function on each file to chop them all up
chopscript(pyscript,pyparagraph)
chopscript(pdescript,pdeparagraph)
chopscript(scscript,scparagraph)

# when this function is triggered, it prints a letter from a block of code selected in fillScript
def scriptPrint():
    global code
    global fillCode
    global character
    global sw4
    # type part of the string at index [character]
    sys.stdout.write('%s' % code[character])
    sys.stdout.flush()

    # message sifter, checking most likely first
    matched = letterexp.match(code[character])
    if matched:
    	oscmsg = OSC.OSCMessage()
    	oscmsg.setAddress("/character/letter")
    	oscmsg.append(1)
    	qlcclient.send(oscmsg)
        scclient.send(oscmsg)
        oscmsg.append(code[character])
        pythonclient.send(oscmsg)
    else:
        matched = numberexp.match(code[character])
        if matched:
            oscmsg = OSC.OSCMessage()
            oscmsg.setAddress("/character/number")
            oscmsg.append(1)
            qlcclient.send(oscmsg)
            scclient.send(oscmsg)
            oscmsg.append(code[character])
            pythonclient.send(oscmsg)
        else:
            matched = symbolexp.match(code[character])
            if matched:
                oscmsg = OSC.OSCMessage()
                oscmsg.setAddress("/character/symbol")
                oscmsg.append(1)
                qlcclient.send(oscmsg)
                scclient.send(oscmsg)
                oscmsg.append(code[character])
                pythonclient.send(oscmsg)
            else:
                if code[character] == '\n':
                    oscmsg = OSC.OSCMessage()
                    oscmsg.setAddress("/character/linebreak")
                    oscmsg.append(1)
                    qlcclient.send(oscmsg)
                    scclient.send(oscmsg)
                    oscmsg.append(code[character])
                    pythonclient.send(oscmsg)
    #iterate character
    character = character + 1
    if character >= len(code):
        # fill up with different code, print a couple of line breaks, reset character count
        fillCode()
        print '\n\n'
        character = 0

# fill
def fillCode():
    global chosenScript
    global code
    global scripts
    global character
    # reset character index, just in case
    character = 0
    # choose out of given code files
    chosenScript = random.choice(scripts)
    # form it into a string
    code = ''.join(chosenScript[random.randrange(0,len(chosenScript))])

#fill code at init time
fillCode()
scriptPrint()

def OSCPrintScript(add, tags, stuff, source):
    global scriptprint
    global scripts
    global character
    global sw4

    if stuff[0] == 1:
        sw4 = 1
        #if the switch is on, print four characters, this can be used to scroll through entire code
        for i in range(4):
            scriptPrint()
            # this is inefficient, but it does work
            #TODO: application threading to see if i can push this across multiple threads
            # to check variable WHILE running for loop
            time.sleep(0.025)
    if stuff[0] == 0:
        if sw4 == 1:
            # when the switch changes state, grab new code and print line breaks
            fillCode()
            print '\n\n'
            #reset character and null switch
            character = 0
            sw4 = 0

# print random paragraph from random script
# scriptprint(random.choice(scripts))

s.addMsgHandler("/switch/printing",OSCPrintScript)

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
