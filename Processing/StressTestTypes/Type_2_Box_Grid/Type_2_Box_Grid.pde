//horizontal and vertival positions to be used
//The aspect ratio of the screen is 1.6 : 1
float horizontal = 8;
float vertical = 5;


float sqwidth;
float sqheight;

int x = 0;
int y = 0;

//counter to manage iteration
int count;

//flip to manage when to decrease
int flip = 1;

//manage legnth of cycles
int cyclen;

void setup() {
  //initialise the ints
  //grid = new int[2][2];
  //fullScreen();  
  size(1280, 800);
  cyclen = 200;
}

void draw() {
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
  
  count++;
  
  if (count == cyclen && flip == 1) {
   horizontal = horizontal * 2;
   vertical = vertical * 2;
   count = 0;
   cyclen = cyclen - 20;
   print(horizontal);
  }
  
  if (count == cyclen && flip == 1){
    horizontal = horizontal / 2;
    vertical = vertical / 2;
    cyclen = cyclen + 20;
    count = 0;
  }
  
  if (horizontal == 1024.0 || horizontal == 8.0) {
   flip = -flip;
  }
 


}