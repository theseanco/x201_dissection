int clock  = 0;
color c1;

void setup() {
  size(600, 400);
}


void draw() {
  
  if(clock == 1) {
   //reset colours here
   //I need a whole bunch of colours as variables
   //when this clock
   c1 = newcolor();
   clock=0;
  }
  
  loadPixels();
  for (int i = 0; i < (width*height/2)-width/2; i++) {
    pixels[i] = c1;
  }
  updatePixels();
  
  clock++;
}


//a function to create a random colour to come back to later
void newColor() {
  color(map(int(random(0,63)),0,63,0,255),map(int(random(0,63)),0,63,0,255),map(int(random(0,63)),0,63,0,255));
}