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

while True:
    myrand = random.random()
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress("/heartbeat/on")
    oscmsg.append(myrand)
    c.send(oscmsg)

    sleep(1)
