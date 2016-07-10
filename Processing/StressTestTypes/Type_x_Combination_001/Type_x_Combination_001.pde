/*

master processing sketch

TODO:

- OSC Protocol for sending data to SuperCollider and Python
  - Print data to console when necessary
  - Sonification protocol for visuals
- OSC Protocol for recieving data from Python
  - Switch all content on and off

*/


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
int cyclen;
// TYPE 2 VARIABLES END

//TYPE 3 VARIABLES START
int largo3 = 1;
int count3;
float divisor3;
//TYPE 3 VARIABLES END

//TYPE 4 VARIABLES START
int len = 1;
int lenAmount = -1;
int count4;
//TYPE 4 VARIABLES END


//a master counting variable to switch between stress testing procedures
int mastercount;
int typeswitch = 1;
int switchlen = 100;

void setup() {
  size(1280, 800);
  cyclen = 200;
}

void draw() {

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













void type1() {
  for (int x = 0; x < width; x+=largo) 
  {
    for (int y = 0; y < height; y+=largo)
    {
      noStroke();
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
  }
}




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
  }

  if (count2 == cyclen && flip == 1) {
    horizontal = horizontal / 2;
    vertical = vertical / 2;
    cyclen = cyclen + 20;
    count2 = 0;
  }

  if (horizontal == 1024.0) {
    flip = 1;
  }

  if ( horizontal == 8 ) {
    flip = 0;
  }
}


void type3() {
  for (int x = 0; x < height; x+=largo3) 
  {
    for (int y = 0; y < width; y+=largo3)
    {
      noStroke();
      fill(map(r, 0, 63, 0, 255), map(g, 0, 63, 0, 255), map(b, 0, 63, 0, 255));
      rect(y, x, largo3, largo3);
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
    largo3 = width/int(divisor);
    divisor3 = divisor3*1.1;
    if (divisor3 == 1) {
      divisor3 = 2;
    }
    //scale this to the screen. Could do with this scrolling back a la arduino doublefade but we'll come back to that
    if (divisor3 > 720) {
      divisor3 = 2;
    }
    count3 = 0;
  }
}

void type4() {
  background(0);

  if (count4 >= 60 - len) {
    fill(map(random(63), 0, 63, 0, 255), map(random(63), 0, 63, 0, 255), map(random(63), 0, 63, 0, 255));
    rect(0, 0, 1280, 800);
    count4 = 0;
    //i need an in/out type statement to have this get shorter then longer again
    if (len >= 59 || len <= 1) {
      lenAmount = -lenAmount;
    };
    len = len + lenAmount; 
  }


  count4++; 
}