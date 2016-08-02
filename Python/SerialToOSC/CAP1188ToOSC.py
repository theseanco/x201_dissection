# a program to interpret sensor data from charlie and pass it on to SC

# import random
from time import sleep

import OSC
import serial
import re

# scaling tool (no longer needed)
# from numpy import interp

# setup OSC communication
c = OSC.OSCClient()
c.connect(('127.0.0.1', 9999))
oscmsg = OSC.OSCMessage()

# setup serial communication
# port = input('port: ')
# baudrate = input('baudrate: ')
# ser = serial.Serial(port, baudrate)

# for testing
ser = serial.Serial('/dev/ttyACM0', 9600)

# regex string formatting pattern to check if serial has read correctly
pattern = re.compile("^msg=")

sensor1 = 0
sensor2 = 0
sensor3 = 0
sensor4 = 0

sleep(1)

i = 0
counter = 32

while True:

    data = ser.readline()
    data = str(data)

    # using receptors 1,3,6,8 to space out connections
    if "C1" in data:
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/1")
        sensor1 = 1
        oscmsg.append(1)
        c.send(oscmsg)
        #print "s1 ON"

    if "C3" in data:
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/2")
        sensor2 = 1
        oscmsg.append(1)
        c.send(oscmsg)
        #print "s2 ON"

    if "C6" in data:
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/3")
        sensor3 = 1
        oscmsg.append(1)
        c.send(oscmsg)
        #print "s3 ON"


    if "C8" in data:
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/4")
        sensor4 = 1
        oscmsg.append(1)
        c.send(oscmsg)
        #print "s4 ON"

    if "C1" not in data and sensor1 == 1:
        sensor1 = 0
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/1")
        oscmsg.append(0)
        c.send(oscmsg)
        #print "s1 OFF"

    if "C3" not in data and sensor2 == 1:
        sensor2 = 0
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/2")
        oscmsg.append(0)
        c.send(oscmsg)
        #print "s2 OFF"

    if "C6" not in data and sensor3 == 1:
        sensor3 = 0
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/3")
        oscmsg.append(0)
        c.send(oscmsg)
        #print "s3 OFF"

    if "C8" not in data and sensor4 == 1:
        sensor4 = 0
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress("/sensors/4")
        oscmsg.append(0)
        c.send(oscmsg)
        #print "s4 OFF"
