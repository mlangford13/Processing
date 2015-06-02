PImage[] explosionImgs = new PImage[90];
int explosionImgCount = 90;

/*
 * Displays a range of png images to simulate an explosion, and plays a sound
*/
public class Explosion extends Drawable
{
  PImage[] images;                  //Array of images to display
  int imageFrames;                  //How many images (frames) are to be displayed              
  
  //Sound
  SoundFile sound;
  boolean soundPlayed = false;
  
  //Delay action
  int frameDelay = 0;                 //Delay how many frames after creation to draw?
  long frameCountAtSpawn;             //At creation what was the framecount
  
  private int frameCounter = 0;      //Count how many frames of total we have gone thru
  
  Explosion(PVector _loc, PVector _size)
  {
    super("Explosion", _loc, _size);
    
    frameCountAtSpawn = frameCount;
    
    imageFrames = 90;        //based on image count
    images = explosionImgs;  //TODO: add constructor support for different explosion images
    renderMode = CENTER;
    
    sound = explosionSound;
  }
  
  //Delay how many frames from creation to actually render?
  public void SetRenderDelay(int _frames)
  {
    frameDelay = _frames;
  }
  
  @Override public void DrawObject()
  {
    //Have we passed the 'start' point for drawing? If frameDelay = 0, begin immediately
    if(frameCount >= frameCountAtSpawn + frameDelay)     
    {
      if(!soundPlayed)        //Play the explosion sound
      {
        sound.amp(0.5);
        sound.play();
        soundPlayed = true;
      }
      if(frameCounter < imageFrames)        //Have all frames been drawn?
      {
        sprite = images[frameCounter];      //Update current sprite to the next frame of the explosion
        super.DrawObject();                 //Invoke parent draw function
        frameCounter++;                     //Prepare for next frame
      }
      else
      {
        toBeKilled = true;
      }
    }
  }
}
