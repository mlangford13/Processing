class Crosshair
{
  int middleSize = 5;
  int lightSize = 300;
  float middleX;
  float middleY;
  float middleSpeedX;
  float middleSpeedY;
  
  PVector location;
  
  Crosshair()
  {
    middleX=width/2;
    middleY=height/2;
    location= new PVector(middleX,middleY);
  }
  
  void update()
  {
    middleX= mouseX;
    middleY= mouseY;
    location.set(middleX-37,middleY-37);
  }
  
  void display()
  {
    imageMode(CENTER); // centers image
    image(flash, middleX, middleY); // flashligth mode
    imageMode(CORNER);
    fill(0,255,0);
    stroke(0,255,0);
    noCursor();
    ellipse(middleX,middleY, middleSize, middleSize);
    line(middleX, middleY-10, middleX, middleY-30); //TOP line
    line(middleX, middleY+10, middleX, middleY+30); //BOTTOM line
    line(middleX-10, middleY, middleX-30, middleY); //LEFT line
    line(middleX+10, middleY, middleX+30, middleY);
    //fill(0,0,0,100);
    //noStroke();
    //ellipse(middleX,middleY, lightSize,lightSize);
  }
  
  
}
