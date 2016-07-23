# A separate script to print paragraphs from programs in another terminal window
# this is run in tandem with a larger script which controls Arduino switching
# To be run in a second terminal window

import os, random, time, sys, OSC, threading

#declaring OSC Addresses
receive_address = '127.0.0.1', 9998 #Mac Adress, Outgoing Port
SC_address = '127.0.0.1', 57120
# Initialize the OSC server and the client.
s = OSC.OSCServer(receive_address)
# initialise SuperCollider connection
scclient = OSC.OSCClient()
scclient.connect(SC_address)
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

# prints a letter every time the scriptprint is triggered
# if the character to be printed is out of the scope, refresh the code(??)
def scriptPrint():
    global code
    global fillCode
    global character
    for item in code
    sys.stdout.write('%s' % code[character])
    sys.stdout.flush()
    character = character + 1
    if character >= len(code):
        # fill up code, print a couple of line breaks
        fillCode()
        # TODO: replace with line breaks if successful
        print ''
        print ''
        character = 0

# fill
def fillCode():
    global chosenScript
    global code
    global scripts
    global character
    character = 0
    chosenScript = random.choice(scripts)
    code = ''.join(chosenScript[random.randrange(0,len(chosenScript))])

#fill code at init time
fillCode()

def OSCPrintScript(add, tags, stuff, source):
    global scriptprint
    global scripts
    global character
    global sw4
    # checks if the variable has already changed
    if sw4 == 0:
        # if it does, print things
        if stuff[0] == 1:
            sw4 = 1

    if stuff[0] == 0:
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
