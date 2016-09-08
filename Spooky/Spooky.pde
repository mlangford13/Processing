//import processing.sound.*;

/*
Michael Langford
SPOOKY GAME
3/3/15

Ghost Dying sound:
http://soundbible.com/1885-Martian-Death-Ray.html
*/

PImage backGround;
PImage ghost;
PImage flash;
String backGroundName = "room.jpg";
String ghostName = "ghost2.png";
String flashName = "blackBG2.png";

int ghostsLeft;
//SoundFile gunShot;
//SoundFile ghostDeath;

PFont font;
long prevMillis;
long instructDuration;

boolean start;
boolean end;
boolean instruct;

ArrayList<Ghost> ghosts = new ArrayList<Ghost>();
Crosshair crosshair;
Timer instructTime;
Animation explode;
Level level = new Level();
Timer timer = new Timer(level.levelTime);


void setup()
{
  
  backGround = loadImage(backGroundName);
  ghost = loadImage(ghostName);
  flash = loadImage(flashName);

  size(displayWidth, displayHeight, P3D);
  font= loadFont("Chiller-Regular-125.vlw");
  textFont(font, 125);
  
  start = true;
  instruct= false;
  end = false;
  
  //gunShot = new SoundFile(this, "gunShot.mp3");
  //ghostDeath = new SoundFile(this,"ghostDeath.mp3");
  instructDuration = 6000;
  explode = new Animation(13);
  crosshair= new Crosshair();
  instructTime = new Timer(3);
  for(int i=0; i<level.numGhosts; i++)
  {
    Ghost g = new Ghost(random(0,width-76),random(0,height-76));
    ghosts.add(g);
  }
  ghostsLeft = level.numGhosts;
  prevMillis=millis();
}

void draw()
{
  image(backGround,0,0,displayWidth,displayHeight); // (image, posX, posY, sizeX, sizeY);
  if(start)
  {
    startMenu();
    timer.holdTimer();
    instructTime.holdTimer();
    prevMillis = millis();
  }
  else if(instruct && instructDuration > millis() - prevMillis)
  {
    instruction();  
  }
  else if(!timer.timesUp() && ghostsLeft>0)
  {
    mainGame();
  }
  else if(ghostsLeft<=0)
  {
    level.nextLevel();
  }
  else
  {
    for(int i=ghosts.size()-1; i>=0; i--)
    {
      Ghost g = ghosts.get(i);
      ghosts.remove(g);
    }
    endGame();
  }
}









      
  