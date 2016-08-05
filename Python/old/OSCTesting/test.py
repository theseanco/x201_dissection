# a sample program to use ipwhois to dump info about a random IP address
import OSC
from time import sleep
import random

# scaling tool (no longer needed)
# from numpy import interp

# setup OSC communication
c = OSC.OSCClient()
c.connect(('127.0.0.1', 7700))
oscmsg = OSC.OSCMessage()

address = "/switch/4/on"

while True:
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress(address)
    oscmsg.append(1)
    c.send(oscmsg)

    sleep(1)
