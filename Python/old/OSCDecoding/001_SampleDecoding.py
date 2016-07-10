#a script to convert a static message from TCPdump to a human-readable OSC message

# sample message 17:22:53.483179 IP localhost.58799 > localhost.57120: UDP, length 20
#E..0Z.@.@.............. ...//testing....,f..?X9.

import OSC
import binascii

samplemessage = 'E..0Z.@.@.................//testing....,f..?X9.'
# strip out full stops to aid in
stripped = samplemessage.replace(".","")
edited = '/testing,f?X9'


blob = OSC.OSCMessage()
blob.append("","b")
blob.append("b","b")
blob.append("bl","b")
blob.append("blo","b")
blob.append("blob","b")
blob.append("blobs","b")
blob.append(42)

oscmsg = OSC.OSCMessage()
oscmsg.append(edited)

print OSC.decodeOSC(oscmsg.getBinary())
