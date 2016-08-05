//spoofing Processing, Python and QLC OSC Addresses for speed
(
~processingfake = NetAddr.new("127.0.0.1",12000);
~pythonfake = NetAddr.new("127.0.0.1",9998);
~qlcfake = NetAddr.new("127.0.0.1",7700);