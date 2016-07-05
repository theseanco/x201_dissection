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
ser = serial.Serial('/dev/ttyACM1', 9600)

# regex string formatting pattern to check if serial has read correctly
pattern = re.compile("^msg=")

sleep(1)

i = 0
counter = 32

while True:

    q = 0
    # a while statement to make sure only proper lines of data are parsed
    while q == 0:
        check = ser.readline()
        matched = pattern.match(check)
        if matched:
            result = check.split(" ")
            q = 1
        else:
            print '_dropped_'

    # printing all sensors
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress("/sensors/1")
    oscmsg.append(int(result[1]))
    c.send(oscmsg)
