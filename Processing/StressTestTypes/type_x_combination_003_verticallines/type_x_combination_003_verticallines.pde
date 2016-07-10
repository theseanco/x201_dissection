/*

 master processing sketch
 
 TODO:
 
 - OSC Protocol for sending data to SuperCollider and Python
 - Print data to console when necessary
 - Sonification protocol for visuals
 - OSC Protocol for recieving data from Python
 - Figure out how to send numbers of boxes/lines/etc
 - Supercollider-side message handling & checking
 
 */

//importing OSC modules
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress python;
NetAddress supercollider;


//TODO: place these global variables as local ones, globalising all of these is excessive.


//TYPE 1 VARIABLES START
int largo = 1;
int r = 0;
int g = 0 ;
int b = 0;
//iterator
int count = 0;
//divisor
float divisor = 1;
//TYPE 1 VARIABLES END

// TYPE 2 VARIABLES START
//horizontal and vertival positions to be used
//The aspect ratio of the screen is 1.6 : 1
float horizontal = 8;
float vertical = 5;
float sqwidth;
float sqheight;
//counter to manage iteration
int count2;
//flip to manage when to decrease
int flip;
//manage legnth of cycles
int cyclen = 200;
// TYPE 2 VARIABLES END

//TYPE 3 VARIABLES START
int largo3 = 1;
int count3;
float divisor3 = 1;
int x3;
int y3;
//TYPE 3 VARIABLES END

//TYPE 4 VARIABLES START
int len = 1;
int lenAmount = -1;
int count4;
//strobe colours
float sr;
float sg;
float sb;
//TYPE 4 VARIABLES END


//a master counting variable to switch between stress testing procedures
int mastercount;
int typeswitch = 2;
int switchlen = 1000000;
int masterswitch = 1;

void setup() {
  size(1280, 800);
  oscP5 = new OscP5(this, 12000);
  python = new NetAddress("127.0.0.1", 9999);
  supercollider = new NetAddress("127.0.0.1", 57120);
  background(0);
}

void draw() {


  if (masterswitch != 1) {
    background(0);
  }

  if (masterswitch == 1) {
    if (typeswitch == 1) {
      type1();
      mastercount ++;
    }

    if (typeswitch == 2) {
      type2();
      mastercount ++;
    }

    if (typeswitch == 3) {
      type3();
      mastercount ++;
    }

    if (typeswitch == 4) {
      type4();
      mastercount ++;
    }

    //reset master counter, grab new legnth and switch test type
    if (mastercount == switchlen) {
      mastercount = 0;
      switchlen = int(random(1000));
      typeswitch = int(random(1, 5));
      print(typeswitch);
    }
  }
}



//vertical lines
void type1() {

  //local variable to detect when number of lines changes
  int prev;
  prev = int(divisor);


  for (int x = 0; x < width; x+=largo) 
  {
    for (int y = 0; y < height; y+=largo)
    {
      noStroke();
      //variables need to be used for colours here so that lines are drawn rather than noise
      fill(map(r, 0, 63, 0, 255), map(g, 0, 63, 0, 255), map(b, 0, 63, 0, 255));
      rect(x, y, largo, largo);
    }

    //adds a random number
    r += int(random(0, 63));
    g += int(random(0, 63));
    b += int(random(0, 63));

    //wraps that number to 63, which will then be mapped to 0-255
    r = r%63;
    g = g%63;
    b = b%63;
  }

  count++;

  //this increases the size of the blocks every ten counts
  //would be nice to do this according to the scale of the screen
  if (count > 30) {
    //casting divisor as an int here to avoid math problems later on down the line
    largo = width/int(divisor);
    divisor = divisor*1.1;
    if (divisor == 1) {
      divisor = 2;
    }
    //scale this to the screen. Could do with this scrolling back a la arduino doublefade but we'll come back to that
    if (divisor > 720) {
      divisor = 2;
    }
    count = 0;

    //conditional to only send message when divisor changes
    if (prev != int(divisor)) {
      OscMessage verticalMsg = new OscMessage("/processing/verticallines");
      verticalMsg.add(int(divisor));
      //send strobe information to Python at the same address but different port
      oscP5.send(verticalMsg, python);
      oscP5.send(verticalMsg, supercollider);
    }
  }
}



//boxes
void type2() {

  //width of square
  sqwidth = width/horizontal;
  //height of square
  sqheight = height/vertical;

  //stop outlines
  noStroke();

  //nested for loop to do horizontal and vertical stacking of boxes
  for (int i=0; i<=horizontal; i++) {
    for (int j=0; j<=vertical; j++) {
      fill(map(random(63), 0, 63, 0, 255), map(random(63), 0, 63, 0, 255), map(random(63), 0, 63, 0, 255));
      rect(sqwidth*i, sqheight*j, sqwidth, sqheight);
    }
  }

  count2++;

  if (count2 == cyclen && flip == 0) {
    horizontal = horizontal * 2;
    vertical = vertical * 2;
    count2 = 0;
    cyclen = cyclen - 20;

    //package and send block information
    OscMessage blockMsg = new OscMessage("/processing/blocks");
    blockMsg.add(int(horizontal*vertical));
    //send strobe information to Python at the same address but different port
    oscP5.send(blockMsg, python);
    oscP5.send(blockMsg, supercollider);
  }

  if (count2 == cyclen && flip == 1) {
    horizontal = horizontal / 2;
    vertical = vertical / 2;
    cyclen = cyclen + 20;
    count2 = 0;

    //package and send block information
    OscMessage blockMsg = new OscMessage("/processing/blocks");
    blockMsg.add(int(horizontal*vertical));
    //send strobe information to Python at the same address but different port
    oscP5.send(blockMsg, python);
    oscP5.send(blockMsg, supercollider);
  }

  if (horizontal == 1024.0) {
    flip = 1;
  }

  if ( horizontal == 8 ) {
    flip = 0;
  }
}


//horizontal lines
void type3() {
  int prev;
  prev = int(divisor3);

  for (int x3 = 0; x3 < height; x3+=largo3) 
  {
    for (int y3 = 0; y3 < width; y3+=largo3)
    {
      noStroke();
      fill(map(r, 0, 63, 0, 255), map(g, 0, 63, 0, 255), map(b, 0, 63, 0, 255));
      rect(y3, x3, largo3, largo3);
    }

    //adds a random number
    r += int(random(0, 63));
    g += int(random(0, 63));
    b += int(random(0, 63));

    //wraps that number to 63, which will then be mapped to 0-255
    r = r%63;
    g = g%63;
    b = b%63;
  }

  count3++;

  //this increases the size of the blocks every ten counts
  //would be nice to do this according to the scale of the screen
  if (count3 > 30) {
    //casting divisor as an int here to avoid math problems later on down the line
    largo3 = height/int(divisor3);
    divisor3 = divisor3*1.1;
    if (divisor3 <= 1) {
      divisor3 = 2;
    }
    //scale this to the screen. Could do with this scrolling back a la arduino doublefade but we'll come back to that
    if (divisor3 > 720) {
      divisor3 = 2;
    }
    count3 = 0;

    //horizontal message to be sent on line number change
    if (prev != int(divisor3)) {
      OscMessage horizontalMsg = new OscMessage("/processing/horizontallines");
      horizontalMsg.add(int(divisor3));
      //send strobe information to Python at the same address but different port
      oscP5.send(horizontalMsg, python);
      oscP5.send(horizontalMsg, supercollider);
    }
  }
}

//strobing lights
void type4() {

  //using a variable to determine strobe colours because they will be used later
  sr = map(int(random(63)), 0, 63, 0, 255);
  sg = map(int(random(63)), 0, 63, 0, 255);
  sb = map(int(random(63)), 0, 63, 0, 255);


  background(0);

  if (count4 >= 60 - len) {
    fill(sr, sg, sb);
    rect(0, 0, 1280, 800);
    count4 = 0;
    //i need an in/out type statement to have this get shorter then longer again
    if (len >= 59 || len <= 1) {
      lenAmount = -lenAmount;
    };
    len = len + lenAmount;
    //package all relevant information about strobe colours
    OscMessage strobeMsg = new OscMessage("/processing/strobe");
    strobeMsg.add(int(sr));
    strobeMsg.add(int(sg));
    strobeMsg.add(int(sb));
    //send strobe information to Python at the same address but different port
    oscP5.send(strobeMsg, python);
    oscP5.send(strobeMsg, supercollider);
  }
  count4++;
}

//osc event responder, used for switching stress testing on and off
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.get(0).intValue() == 1) {
    masterswitch = 1; 
    print("on!");
  };
  if (theOscMessage.get(0).intValue() == 0) {
    masterswitch = 0; 
    print("off!");
    background(0);
  };
}



//strobe message sender
void strobeMsg() {
  OscMessage strobeMsg = new OscMessage("/processing/strobe");
  strobeMsg.add(1);
  //send strobe information to Python at the same address but different port
  oscP5.send(strobeMsg, python);
}