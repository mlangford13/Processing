
int sectorID = 1;      //Unique sector ID. Begin generating @ 1 because the startSector has ID = 0
SectorDirection[] sectorDirections = new SectorDirection[]{SectorDirection.UL, SectorDirection.Above, 
  SectorDirection.UR, SectorDirection.Left, SectorDirection.Right, SectorDirection.LL, 
  SectorDirection.Below, SectorDirection.LR};
/**
 * Generate sectors around the provided sector. Check which sectors have already been
 * generated by using the sector's neighbor pointers.
 * @param {Sector} _origin The starting sector from which to generate surrounding sectors
 * @return {HashMap<Integer,Sector>} Mapping of sector IDs to sector objects
 */
HashMap<Integer,Sector> BuildSectors(Sector _origin)
{
  //Hold a list of sectors to generate linkings
  Sector[] sectorGenArray = new Sector[9];
  sectorGenArray[4] = _origin;      //origin is at core of these 9 sectors
  int sectorCounter = 0;

  HashMap<Integer,Sector> generatedSectors = new HashMap<Integer,Sector>();

  //Check all 8 surrounding sectors 
  for(SectorDirection direction : sectorDirections)
  {
    Sector neighbor;     //Sector to generate or grab below
    if(!_origin.HasNeighbor(direction))
    {
      //No neighbor in this direction -- generate one
      PVector sectorLocation = _origin.GetNeighborLocation(direction);
      neighbor = new Sector(sectorID, sectorLocation, sectorSize, bg, SectorType.RANDOM);
      generatedSectors.put(sectorID, neighbor);
      sectorID++;     //Next unique ID for this sector!
    }
    else
    {
      neighbor = _origin.GetNeighbor(direction);
    }

    sectorGenArray[sectorCounter] = neighbor;   //Track an adjacent sector

    sectorCounter++;            //Next sector!
    if(sectorCounter == 4)      //Skip -- this is the core
    {
      sectorCounter++;
    }
  }

  //Attach adjacent sectors to each other
  // [ 1 2 3 ]
  // [ 4 5 6 ]      Sector layout for adjacency check
  // [ 7 8 9 ]
  for(int i = 1; i < 10; i++)
  {
    if(i%3 != 0)    //If not far right side
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Right, sectorGenArray[i]);
      if(i > 3)   //Not top row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.UR, sectorGenArray[i-3]);
      }
      if( i < 7)   //Not bottom row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.LR, sectorGenArray[i+3]);
      }
    }
    if(i != 1 && i != 4 && i != 7)    //Not far left side
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Left, sectorGenArray[i-2]);
      if(i > 3)   //Not top row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.UL, sectorGenArray[i-5]);
      }
      if( i < 7)   //Not bottom row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.LL, sectorGenArray[i+1]);
      }
    }
    if(i > 3)     //Not top row
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Above, sectorGenArray[i-4]);
    }
    if(i < 7)     //Not bottom row
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Below, sectorGenArray[i+2]);
    }   
  }
  return generatedSectors;
}


/**
 * Load assets such as sprites, music, and build all sectors.
 */
void GameObjectSetup()
{
  LoadImageAssets();
  //LoadSoundAssets();
  
  Sector startSector = new Sector(0, new PVector(0,0), sectorSize, bg, SectorType.PLANETARY);
  sectors.put(0, startSector);

  //Generate other sectors around this one
  println("[INFO] Generating sectors around the origin...");
  sectors.putAll(BuildSectors(startSector));     //Generate new sectors, force into current
  println("[INFO] Start sector generation complete! There are now " + sectorID + " sectors generated.");

  //DEBUG FOR LINKING SECTORS
  if(debugMode.value)
  {
    println(startSector);
  }
  
}

/**
 * Merge the provided mapping into the current secto rmap
 * @param toMerge Generated sectors we want to merge in after all loops are complete
 */
void MergeSectorMaps(HashMap<Integer,Sector> toMerge)
{
  if(toMerge != null)
  {
    Iterator it = toMerge.entrySet().iterator();
    while (it.hasNext()) 
    {
      Map.Entry pair = (Map.Entry)it.next();
      sectors.put((Integer)pair.getKey(), (Sector)pair.getValue());   //HACK unchecked cast
      
      if(debugMode.value)
      {
        println("[DEBUG] Added new entry pair to sector map");
      }
      it.remove();      //Avoids a ConcurrentModificationException
    }
  }

}



int generationPersistenceFactor = 5;     //How hard should I try to generate the requested asteroids?
AsteroidFactory asteroidFactory = new AsteroidFactory();
/**
* This function will generate asteroids in random locations on a given game area. If too 
* many asteroids are requested the function will only generate as many as it can without
* overlapping.
* @param  {Sector} sector Sector to render these asteroids on
* @param  {Integer} initialAsteroidCount how many asteroids to generate (max)
* @see  Sector.pde for implementation, AsteroidFactory.pde for generation of asteroids
*/
void GenerateAsteroids(Sector sector, int initialAsteroidCount)
{
  println("[INFO] Generating asteroids");
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;    //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < initialAsteroidCount)
  {
    //Generate new asteroid location, size, etc parameters
    asteroidFactory.SetNextAsteroidParameters(sector);
    
    PVector roidLoc = asteroidFactory.GetNextAsteroidLocation();    //Asteroid location
    int roidSize = asteroidFactory.Size();
    noOverlap = true;    //Assume this coordinate is good to begin
    for(Asteroid roid : sector.asteroids)
    {
      //Check if this asteroid's center + diameter overlaps with roid's center + diameter
      if( Math.abs(roid.GetLocation().x-roidLoc.x) < roid.GetSize().x/2 + roidSize/2 
            && Math.abs(roid.GetLocation().y-roidLoc.y) < roid.GetSize().y/2 + roidSize/2 )
      {
        noOverlap = false;
        println("[INFO] Asteroid location rejected!");
        break;
      }
    }
    
    if(noOverlap)
    { 
      Asteroid toAdd = asteroidFactory.GenerateAsteroid();
      toAdd.baseAngle = radians(rand.nextInt((360) + 1));
      sector.asteroids.add(toAdd);
      i++;
    }
    else
    {
      //Failed to generate the asteroid
      timeoutCounter++;
      if(timeoutCounter > generationPersistenceFactor * initialAsteroidCount)
      {
        print("[WARNING] Asteroid generation failed for ");
        print(initialAsteroidCount - i);
        print(" asteroid(s)\n");
        break;    //abort the generation loop
      }
    }
  }
}


PVector planetSizeRange = new PVector(50, 100);      //Min, max planet size
int borderSpawnDistance = 1;      //How far from the gameArea border should the planet spawn?
/**
* Generate planets in random locations on a given sector
* @param  {Sector} sector Sector to render these planets on
* @param  Integer} count How many planets to spawn
* @see  Sector.pde for implementation
*/
void GeneratePlanets(Sector sector, int count)
{
  //Guarantee no planets within 3 diameters from the edge of the game area
  println("[INFO] Generating Planets");  
  int minX = int(sector.GetLocation().x + planetSizeRange.y * borderSpawnDistance);
  int minY = int(sector.GetLocation().y + planetSizeRange.y * borderSpawnDistance);
  int maxX = int(sector.GetLocation().x + sector.GetSize().x - planetSizeRange.y * borderSpawnDistance);
  int maxY = int(sector.GetLocation().y + sector.GetSize().y - planetSizeRange.y * borderSpawnDistance);
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;      //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < count)
  {
    int size = rand.nextInt(int(planetSizeRange.y - planetSizeRange.x))+ int(planetSizeRange.x);
    
    //Generate a random X/Y coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size

    int xCoor = rand.nextInt(maxX-minX)+minX;
    int yCoor = rand.nextInt(maxY-minY)+minY;
    
    //Check that this planet will not spawn too near one another 
    noOverlap = true;    //Assume this coordinate is good to begin
    
    //TODO re-implement
    for(Planet planet : sector.planets)
    {
      //Check if this planet's center + diameter overlaps with planet's center + 4 * diameter
      if( Math.abs(planet.GetLocation().x-xCoor) < planet.GetSize().x * 1.5 + size * 1.5
            && Math.abs(planet.GetLocation().y-yCoor) < planet.GetSize().y * 1.5 + size * 1.5 )
      {
        noOverlap = false;
        println("[INFO] Planet location rejected!");
        break;
      }
    }
    
    //Guarantee planets are too close to each oher
    if(noOverlap)
    {  
      Shape colliderGenerated = new Shape("collider", new PVector(xCoor, yCoor), new PVector(size, size), 
            color(0,255,0), ShapeType._CIRCLE_);
      Planet toBuild = new Planet("Planet", new PVector(xCoor, yCoor), size, int(10000*size/planetSizeRange.y), 
            sector, colliderGenerated);
      toBuild.SetMaxSpeed(0);        //Local speed limit for planet (don't move)
      toBuild.baseAngle = radians(rand.nextInt((360) + 1));
      sector.planets.add(toBuild);
      println("[INFO] Generated a new planet at " + toBuild.location + " in sector " + sector.name);
      i++;
    }
    else
    {
      //Failed to generate the planet
      timeoutCounter++;
      if(timeoutCounter >  4 * count)    //Try to generate 4x as many planets
      {
        print("[WARNING] Planet generation failed for ");
        print(count - i);
        print(" planet(s)\n");
        break;    //abort the generation loop
      }
    }
  }
}


float shipScaleFactor = 0.25;     //Scale down ship sprite sizes by this factor
/**
 * Build a given number of enemies on the provided Sector. If there
 * are planets, generate around the planet. If asteroid, generate
 * around asteroids. Else just generate anywhere in free space.
 * @param {Sector} sector Sector to build the enemies on
 * @param {Integer} count How many enemies to make
 */
void GenerateEnemies(Sector sector, int count)
{
  PVector position = sector.location.get();   //Default position at origin of sector

  int minX, minY, maxX, maxY;                 //Max allowed positions

  int enemyShipRandomIndex = rand.nextInt((enemyShipTypeCount -1) + 1);
  PImage enemySprite = enemyShipSprites.get(enemyShipRandomIndex).get();    //Make sure to get a COPY of the vector
  PVector enemyShipSize = enemyShipSizes.get(enemyShipRandomIndex).get();

  //Scale enemyshipsize
  enemyShipSize.x = int(shipScaleFactor * enemyShipSize.x);
  enemyShipSize.y = int(shipScaleFactor * enemyShipSize.y);

  if (enemyShipSize.x <= 0 || enemyShipSize.y <= 0)
  {
    println("[ERROR] Ship Scale error! Returning ship to standard size (large)");
    enemyShipSize = enemyShipSizes.get(enemyShipRandomIndex).get();
  }

  for(int i = 0; i < count; i++)
  {
    PVector shipSize = new PVector(75,30);
    if(sector.asteroids.size() > 0)   //This sector has asteroids -- check for overlap
    {
      boolean validLocation = false;
      while(!validLocation)
      {
        //Generation parameters
        minX = int(sector.GetLocation().x + enemyShipSize.x);
        minY = int(sector.GetLocation().y + enemyShipSize.y);
        maxX = int(sector.GetSize().x - enemyShipSize.x);
        maxY = int(sector.GetSize().y - enemyShipSize.y);

        //Generate position offsets from the sector location
        position.x = rand.nextInt(maxX - int(shipSize.x)) + minX + int(shipSize.x/2);
        position.y = rand.nextInt(maxY)+minY;

        for(Asteroid roid : sector.asteroids)
        {
          //Check if this asteroid's center + diameter overlaps with ships center = size
          if( Math.abs(roid.GetLocation().x-position.x) < roid.GetSize().x/2 + shipSize.x 
                && Math.abs(roid.GetLocation().y-position.y) < roid.GetSize().y/2 + shipSize.y )
          {
            validLocation = false;
            println("[INFO] Enemy placement location rejected!");
            break;
          }
          validLocation = true;   //Went thru each asteroid -- no overlap
        }
      }

    }
    else
    {      
      //Generation parameters
      minX = int(sector.GetLocation().x);
      minY = int(sector.GetLocation().y);
      maxX = int(sector.GetSize().x);
      maxY = int(sector.GetSize().y);

      //Generate position offsets from the sector location
      position.x = rand.nextInt(maxX - int(shipSize.x)) + minX + int(shipSize.x/2);
      position.y = rand.nextInt(maxY)+minY;
    }

    Shape colliderGenerated = new Shape("collider", position, enemyShipSize, color(0,255,0), ShapeType._RECTANGLE_);
    Enemy enemyGen = new Enemy("Bad guy", position, enemyShipSize, enemySprite, 
      1000, color(255,0,0), sector, colliderGenerated);
    enemyGen.baseAngle = radians(rand.nextInt((360) + 1));     //Random rotation 0-360

    //TODO: fix rendering of enemy shields when in another sector
    // Small chance for enemy with shields....
    // int shieldOdds = 95;     //percentage of enemies with shield
    // int rolledNumber = rand.nextInt((100) + 1);
    // if(rolledNumber <= shieldOdds)
    // {
    //   enemyGen.shield.enabled = true;
    //   enemyGen.shield.online = true;
    // }

    sector.ships.add(enemyGen);
  }

}

void GeneratePowerups(Sector sector, int count)
{
  PVector position = sector.location.get();   //Default position at origin of sector

  int minX, minY, maxX, maxY;                 //Max allowed positions

  PImage sprite;      //What the powerup looks like
  PVector powerupSize = new PVector(width/64, width/64);

  for(int i = 0; i < count; i++)
  {
    int typeGenerator = rand.nextInt((2) + 1);    //0-2 to select type of powerup
    PowerupType type;
    if(typeGenerator == 0)
    {
      type = PowerupType.BULLETHELL;
      sprite = redPowerupSprite.get();
    }
    else if(typeGenerator == 1)
    {
      type = PowerupType.SHIELDS;
      sprite = shieldPowerupSprite.get();
    }
    else
    {
      type = PowerupType.ENGINES;
      sprite = enginePowerupSprite.get();
    }

    if(sector.asteroids.size() > 0)   //This sector has asteroids -- check for overlap
    {
      boolean validLocation = false;
      while(!validLocation)
      {
        //Generation parameters
        minX = int(sector.GetLocation().x + powerupSize.x);
        minY = int(sector.GetLocation().y + powerupSize.y);
        maxX = int(sector.GetSize().x - powerupSize.x);
        maxY = int(sector.GetSize().y - powerupSize.y);

        //Generate position offsets from the sector location
        position.x = rand.nextInt(maxX - int(powerupSize.x)) + minX + int(powerupSize.x/2);
        position.y = rand.nextInt(maxY)+minY;

        for(Asteroid roid : sector.asteroids)
        {
          //Check if this asteroid's center + diameter overlaps with ships center = size
          if( Math.abs(roid.GetLocation().x-position.x) < roid.GetSize().x/2 + powerupSize.x 
                && Math.abs(roid.GetLocation().y-position.y) < roid.GetSize().y/2 + powerupSize.y )
          {
            validLocation = false;
            println("[INFO] Enemy placement location rejected!");
            break;
          }
          validLocation = true;   //Went thru each asteroid -- no overlap
        }
      }

    }
    else
    {      
      //Generation parameters
      minX = int(sector.GetLocation().x);
      minY = int(sector.GetLocation().y);
      maxX = int(sector.GetSize().x);
      maxY = int(sector.GetSize().y);

      //Generate position offsets from the sector location
      position.x = rand.nextInt(maxX - int(powerupSize.x)) + minX + int(powerupSize.x/2);
      position.y = rand.nextInt(maxY)+minY;
    }

    Shape colliderGenerated = new Shape("collider", position, powerupSize, color(0,255,0), ShapeType._RECTANGLE_);
    Powerup powerupGen = new Powerup(position, powerupSize, sprite, type, sector, colliderGenerated);

    sector.powerups.add(powerupGen);
  }

}

/**
 * Checks if an object implements an interface, returns boo
 * @param  object Any object
 * @param  interf Interface to compare against
 * @return {Boolean} True for implements, false if doesn't
 */
public static boolean implementsInterface(Object object, Class interf)
{
    return interf.isInstance(object);
}