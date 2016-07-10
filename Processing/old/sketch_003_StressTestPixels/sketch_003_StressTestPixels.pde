int clock  = 0;
color[] pix = new color[128];

//i probably need an array of colors which I can then set with a for loop at the start of each frame

void setup() {
  size(600, 400);
}


void draw() {
  
  //a for loop to set the colour of every pixel in the array
  if(clock == 1) {
   for (int i=0; i < pix.length; i++) {
    pix[i] = color(map(int(random(0,63)),0,63,0,255),map(int(random(0,63)),0,63,0,255),map(int(random(0,63)),0,63,0,255)); 
   }
   clock=0;
  }
  
  loadPixels();
  for (int i = 0; i < (width*height/2)-width/2; i++) {
    pixels[i] = pix[0];
  }
  updatePixels();
  
  clock++;
}