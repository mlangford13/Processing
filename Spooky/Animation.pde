class Animation 
{
  PImage[] images;
  int imageCount;
  int frame;
  float posX, posY;
  boolean execute;
  
  Animation(int count) 
  {
    frame = 0;
    execute = false;
    imageCount = count;
    images = new PImage[imageCount];
    for (int i = 0; i < imageCount; i++) 
    {
      // Use nf() to number format 'i' into four digits
      String filename = "ring_blast" + nf((i+1), 4) + "@2x.png";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos) 
  {
    imageMode(CENTER);
    image(images[frame], xpos, ypos);
    imageMode(CORNER);
    frame++;
    if(frame >= imageCount)
    {
      frame = 0;
      execute = false;
    }
  }
  
  int getWidth() 
  {
    return images[0].width;
  }
}
