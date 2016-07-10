int len = 1;
int lenAmount = -1;
int count = 0;


void setup() {
  size(1280, 800);
  //fullScreen();
  frameRate(60);
}


void draw() {
  
  background(0);

  if (count >= 60 - len) {
    fill(map(random(63), 0, 63, 0, 255), map(random(63), 0, 63, 0, 255), map(random(63), 0, 63, 0, 255));
    rect(0, 0, 1280, 800);
    count = 0;
    //i need an in/out type statement to have this get shorter then longer again
    if (len >= 59 || len <= 1) {
      lenAmount = -lenAmount;
    };
    len = len + lenAmount;
    print(len); 
  }


  count++;
}