import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Random;
import java.util.Iterator;
import java.util.LinkedList;
//import processing.sound.*;

enum GameState {
  START, INSTRUCTIONS,
  PLAY, PAUSED, GAMEOVER
}

//Random number generator
Random rand = new Random();

GameState gameState;
boolean restartFlag;    //Restart game?


//Game Name
String title = "The Void";

//Game objects and areas
HashMap<Integer,Sector> sectors;      //Sector IDs mapped against sector objects
HashMap<Integer,Sector> generatedSectors;   //Storage of mid-loop generated sectors for later merging
ArrayList<Sector> visibleSectors;     //Sectors on-screen right now (only render/update these)
ArrayList<Explosion> explosions;      //Explosions are global game object
PVector sectorSize;                   //Set to width/height for now
PVector playerSize;                   //Used to resize player image

//Start Menu stuff
float introAngle;                     //Angle used to shift background during Start menu
boolean sPressed, mPressed;
PVector startLocation;
PVector startAccel;
PVector startVel;

//Counters
long loopCounter;        //How many loop iterations have been completed
long loopStartTime;      //Millis() time main loop started

//Debugging & profiling
static boolean debuggingAllowed = true;      //Display DEBUG button on GUI?
TogglableBoolean debugMode = new TogglableBoolean(false);
boolean profilingMode = false;

//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

//UI Info
LinkedList<Clickable> toDisplay;        //List of clickable UI objects to display //<>//

Player playerShip;

void setup()
{
  size(displayWidth, displayHeight, P3D);    //Need 3D acceleration to make this game run at decent FPS
  frame.setTitle(title);

  gameState = GameState.START;
  restartFlag = false;
  background(0);        //For new game, reset  background

  //Zoom setup
  cursor(CROSS);
  minX = 0;
  minY = 0;
  maxX = width;
  maxY = height;

  //Load all image/sound assets
  LoadImageAssets();      //See AssetLoader.pde
  //LoadSoundAssets();
  PrepareUIElements();
  startupFont = loadFont("SourceCodePro-Regular-48.vlw");

  //Game area setup
  sectors = new HashMap<Integer, Sector>();
  generatedSectors = new HashMap<Integer, Sector>();
  sectorSize = new PVector(2*width,2*height);
  visibleSectors = new ArrayList<Sector>();   //TODO implement me
  explosions = new ArrayList<Explosion>();

  //Start Menu initialize
  introAngle = 0.0;
  mPressed = false;
  sPressed = false;
  startLocation = new PVector(width/2,height/2);
  startVel= new PVector(0,0);
  startAccel = new PVector(.04,0);
  
  //Player and sector setup
  PVector spawnLocation = new PVector(width, height);
  playerSize = new PVector(100,50);
  int playerMass = 100;
  Shape playerCollider = new Shape("collider", spawnLocation, playerSize, color(0,255,0), 
              ShapeType._RECTANGLE_);
  playerShip = new Player(spawnLocation, playerSize, shipSprite, playerMass, 
              color(255,0,0), null, playerCollider);     //null sector until created
  playerShip.health.SetMaxHealth(1500);    //1500

  GameObjectSetup();    //See Helpers.pde
  playerShip.currentSector = sectors.get(0);      //Now that sector is created, feed to player obj
  sectors.get(0).ships.add(playerShip);

  //Counters & framerate
  loopCounter = 0;
  frameRate(60);
  loopStartTime = millis();
  
  //Intro music
  // introMusic.play();
  // trackStartTime = millis();
  // currentTrack = introMusic;
}

void draw()
{
  // MusicHandler();      //Handle background music
  
  if(gameState == GameState.START)
  {
    DrawStartupLoop();
  }
  
  else if(gameState == GameState.INSTRUCTIONS)
  {
    DrawInstructionsLoop();
  }
  
  else if(gameState == GameState.PLAY)
  {
    DrawPlayLoop();     //See GameLoops.pde
  }

  else if(gameState == GameState.PAUSED)
  {
    DrawPauseLoop();
  }
  
  else if(gameState == GameState.GAMEOVER)
  {
    DrawGameOverLoop();
  }

}