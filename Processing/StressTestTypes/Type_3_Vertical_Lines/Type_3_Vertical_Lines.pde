//TODO: Sonification protocol and response


int largo = 1;
int r = 0;
int g = 0 ;
int b = 0;
//iterator
int count = 0;
//divisor
float divisor = 1;
void setup() {
  size(1280, 800);
}

void draw() 
{

  for (int x = 0; x < height; x+=largo) 
  {
    for (int y = 0; y < width; y+=largo)
    {
      noStroke();
      fill(map(r, 0, 63, 0, 255), map(g, 0, 63, 0, 255), map(b, 0, 63, 0, 255));
      rect(y, x, largo, largo);
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