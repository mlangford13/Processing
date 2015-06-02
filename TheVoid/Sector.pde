static enum SectorType {
  ASTEROIDFIELD, EMPTY, PLANETARY, RANDOM
}

enum SectorDirection {
  UL, Above, UR, Left, Right, LL, Below, LR
}

//An area in 2D space containing asteroids, planets, ships, stations, etc
public class Sector extends Drawable implements Updatable
{
  //Contents of this sector. Built by helper functions in helpers.pde
  public ArrayList<Asteroid> asteroids;
  public ArrayList<Asteroid> debrisSpawned;       //Storage for debris spawned to be added in update
  public ArrayList<Planet> planets;
  public ArrayList<Ship> ships, shipsToAdd; //May include enemies and the player ship, to add for player charred hull
  public ArrayList<LaserBeam> enemyLaserFire, friendlyLaserFire; 
  public ArrayList<Explosion> explosions; 
  public ArrayList<Powerup> powerups;

  //Link to neighboring sectors
  public HashMap<SectorDirection, Sector> neighbors;

  //Collider shape
  Shape collider;     //For checking overlap of game objects in this sector

  private color debugViewColor;       //Color displayed over this sector in debug mode
  private SectorType sectorType;      //What kind of sector is this? Asteroid field, planetary, etc

  //Sector parameters
  int minPlanets = 1;
  int maxPlanets = 4;
  int minAsteroids = 10;
  int maxAsteroids = 60;

/**
 * [Sector description]
 * @param {Integer} _ID Unique identifier for this sector
 * @param {PVector} _loc Pixel location of this sector
 * @param {PVector} _size Pixel size of this sector
 * @param {PImage} _background Sprite of the background of this sector
 */
  public Sector(int _ID, PVector _loc, PVector _size, PImage _background, SectorType _sectorType)
  {
    super(Integer.toString(_ID), _loc, _size);

    sprite = _background;
    sprite.resize(int(size.x), int(size.y));

    renderMode = CORNER;        //Don't draw sector in center
     
    //Shape for collision detection
    collider = new Shape("collider", location, size, color(255,255,255), ShapeType._RECTANGLE_);
    collider.renderMode = CORNER;

    //Object containers
    asteroids = new ArrayList<Asteroid>();
    debrisSpawned = new ArrayList<Asteroid>();
    planets = new ArrayList<Planet>();
    ships = new ArrayList<Ship>();
    shipsToAdd = new ArrayList<Ship>();
    enemyLaserFire = new ArrayList<LaserBeam>();
    friendlyLaserFire = new ArrayList<LaserBeam>();
    explosions = new ArrayList<Explosion>();
    powerups = new ArrayList<Powerup>();

    //Neighbors
    neighbors = new HashMap<SectorDirection, Sector>();

    //Generate all objects in the sector
    GenerateSectorObjects(_sectorType);   //Build static objects (asteroids, planets, stations)
    GenerateSectorEnemies();          //Build dynamic objects (enemies)
    
    //DEBUG INFO
    debugViewColor = color(255);    //Default = white
  }
  
  /**
   * Generate the sector's objects (asteroids, planets, etc)
   * @param {SectorType} _sectorType What kind of sector to generate
   * @see  Helpers.pde for generation function
   */
  private void GenerateSectorObjects(SectorType _sectorType)
  {
    int powerupLottery = 100;//rand.nextInt((100) + 1);   //Random gen parameter 0 - 100
    if(_sectorType == SectorType.RANDOM)
    {
      //Determine what type of sector we are
      int sectorTypeRand = rand.nextInt((3 - 1) + 1) + 1;   //rand.nextInt((max - min) + 1) + min;
      if(sectorTypeRand == 1)
      {
        println("[INFO] Building asteroid field sector");
        sectorType = SectorType.ASTEROIDFIELD;
      }
      else if(sectorTypeRand == 2)
      {
        println("[INFO] Building empty sector");   
        sectorType = SectorType.EMPTY;
      }
      else if(sectorTypeRand == 3)
      {
        println("[INFO] Building planetary sector"); 
        sectorType = SectorType.PLANETARY;
      }
      else
      {
        println("[ERROR] Invalid sector type selected. Defaulting to asteroid field");  
        sectorType = SectorType.ASTEROIDFIELD;
      }
    }
    else    //Passed in parameter determines sectorType
    {
      sectorType = _sectorType;
    }

    if(sectorType == SectorType.PLANETARY)
    {
      //Generate planets
      int planetCount = rand.nextInt((maxPlanets - minPlanets) + 1) + minPlanets;
      GeneratePlanets(this, planetCount);         //See helpers.pde

      if(powerupLottery > 90)
      {
        GeneratePowerups(this, 2);
      }
    }
    else if(sectorType == SectorType.ASTEROIDFIELD)
    {
      //Generate asteroids in this sector
      int asteroidCount = rand.nextInt((maxAsteroids - minAsteroids) + 1) + minAsteroids;
      GenerateAsteroids(this, asteroidCount);     //See helpers.pde

      if(powerupLottery > 95)
      {
        GeneratePowerups(this, 3);
      }
      else if(powerupLottery > 70)
      {
        GeneratePowerups(this, 2);
      }
      else
      {
        GeneratePowerups(this,1);
      }
    }
    else
    {
      if(powerupLottery > 95)
      {
        GeneratePowerups(this, 1);
      }
    }
  }

  /**
   * Generate dynamic entities (enemies) in this sector
   * @see  Helpers.pde for generation function
   */
  private void GenerateSectorEnemies()
  {
    int maxEnemies = 6;
    int minEnemies = 0;
    int enemyCount = rand.nextInt((maxEnemies - minEnemies) + 1) + minEnemies;
    // GenerateEnemies(this, 0);
    GenerateEnemies(this, enemyCount); // GenerateEnemies(this, enemyCount);
  }

  public void SetDebugColor(color _color)
  {
    debugViewColor = _color;
  }
  
  /**
   * Draw the sector itself
   * @see Visuals.pde DrawSectors() for drawing of child objects in the sector
   */
  @Override public void DrawObject()
  {
    super.DrawObject();    //Draw using parent method
    
    //Sector's game objects are drawn in visuals.pde DrawSectors()

    if(debugMode.value)    //Draw sector ID
    {
      pushStyle();
      textFont(startupFont, 80);
      pushMatrix();
      translate(location.x + size.x/2, location.y + size.y/2);
      text(name, 0, 0);
      popMatrix();
      popStyle();
    }
  }

  public void Update()
  {
    if(!debrisSpawned.isEmpty())      //Put debris into asteroid tracking list
    {
      for(Asteroid a : debrisSpawned)
      {
        asteroids.add(a);
      }
      debrisSpawned.clear();
    }

  }
  
  /**
   * Attach a neighboring sector to this sector
   * @param {SectorDirection} _direction Where relative to this sector?
   * @param {Sector} _neighbor Neighboring sector object
   */
  public void SetNeighbor(SectorDirection _direction, Sector _neighbor)
  {
    if(neighbors.get(_direction) == null)    //If mapping already exists
    {
      neighbors.put(_direction, _neighbor);
      if(debugMode.value)
      {
        println("[DEBUG] Created neighbor relationship between " + name + " and " + _neighbor.name);
      }    
    }
  }

  /**
   * Check if this sector has already popualted and linked a neighbor
   * in the provided direction
   * @param {SectorDirection} _direction Which direction to check
   * @return {boolean} True if neighbor populated, false if none
   */
  public boolean HasNeighbor(SectorDirection _direction)
  {
    if(neighbors.get(_direction) == null)   
    {
      return false;  //If mapping already exists, already has neighbor
    }
    else
    {
      return true;
    }
  }

  /**
   * Returns the PVector coordinates of an adjacent neighbor
   * (upper left corner of that sector coordinates)
   * @param {SectorDirection} _neighbor Direction to check
   * @return {PVector} Coordinates of where this neighbor would be (raw calculation)
   */
  public PVector GetNeighborLocation(SectorDirection _neighbor)
  {
    if(_neighbor == SectorDirection.UL)
    {
      return new PVector(location.x - size.x, location.y - size.y);  
    }
    else if(_neighbor == SectorDirection.Above)
    {
      return new PVector(location.x, location.y - size.y);  
    }
    else if(_neighbor == SectorDirection.UR)
    {
      return new PVector(location.x + size.x, location.y - size.y);  
    }
    else if(_neighbor == SectorDirection.Left)
    {
      return new PVector(location.x - size.x, location.y);  
    }
    else if(_neighbor == SectorDirection.Right)
    {
      return new PVector(location.x + size.x, location.y);   
    }
    else if(_neighbor == SectorDirection.LL)
    {
      return new PVector(location.x - size.x, location.y + size.y);  
    }
    else if(_neighbor == SectorDirection.Below)
    {
      return new PVector(location.x, location.y + size.y);  
    }
    else if(_neighbor == SectorDirection.LR)
    {
      return new PVector(location.x + size.x, location.y + size.y);  
    }
    else    //A weird value was passed in....
    {
      println("[ERROR] Requested neighbor on unspecified direction. Coordinates will be invalid!");
    }

    println("[ERROR] Returned invalid sector coordinates!");
    return new PVector(0,0);
  }

  /**
   * Return arraylist of all generated neighboring cells
   * @return arraylist of sectors
   */
  public ArrayList<Sector> GetAllNeighbors()
  {
    ArrayList<Sector> allNeighbors = new ArrayList<Sector>();
    for(Sector neighbor : neighbors.values())
    {
      allNeighbors.add(neighbor);
    }

    return allNeighbors;
  }

  /**
   * Return arraylist of this sector and all neighboring sectors
   * @return arraylist of sectors
   */
  public ArrayList<Sector> GetSelfAndAllNeighbors()
  {
    ArrayList<Sector> allNeighbors = new ArrayList<Sector>();
    for(Sector neighbor : neighbors.values())
    {
      allNeighbors.add(neighbor);
    }
    allNeighbors.add(this);

    return allNeighbors;
  }

  /**
   * Get a neighbor at a given direction. Returns null if DNE
   * @param {SectorDirection} _direction Which way?
   * @return {Sector} Null / valid sector
   */
  public Sector GetNeighbor(SectorDirection _direction)
  {
    return neighbors.get(_direction);
  }


  /**
   * A new object has entered this sector -- typecast it and place in
   * appropriate container
   * @param {Physical} obj object to cast and hold
   * @see  Updaters.pde > UpdatePhysicalObjects()
   */
  public void ReceiveNewObject(Physical obj)
  {
    if(obj instanceof Ship)
    {
      ships.add((Ship)obj);
    }
    else if(obj instanceof Asteroid)
    {
      asteroids.add((Asteroid)obj);
    }
    else if(obj instanceof Planet)
    {
      planets.add((Planet)obj);
      println("[INFO] That's interesting.... a planet moved sectors.");
    }
    else if(obj instanceof LaserBeam)
    {
      LaserBeam beam = (LaserBeam)obj;
      if(beam.laserColor == LaserColor.GREEN)     //HACK team by color
      {
        friendlyLaserFire.add((LaserBeam)obj);
      }
      else
      {
        enemyLaserFire.add((LaserBeam)obj);
      }
      
    }
    else
    {
      println("[WARNING] Unknown object " + obj.name + " [" + obj.GetID() 
              + "] has entered sector");
    }

  }

  //Print debug sector ID map
  public String toString() 
  {
    String[] ids = {"~", "~", "~", "~", "~", "~", "~", "~", "~"};

    for(SectorDirection key : neighbors.keySet()) 
    {
      SectorDirection direction = key;
      Sector sector = neighbors.get(key);   //Grab sector from map
      String sectorID = sector.name;       //Get sector ID name

      if(direction == SectorDirection.UL)
      {
        ids[0] = sectorID;
      }
      else if(direction == SectorDirection.Above)
      {
        ids[1] = sectorID;
      }
      else if(direction == SectorDirection.UR)
      {
        ids[2] = sectorID;
      }
      else if(direction == SectorDirection.Left)
      {
        ids[3] = sectorID;
      }
      else if(direction == SectorDirection.Right)
      {
        ids[5] = sectorID;
      }
      else if(direction == SectorDirection.LL)
      {
        ids[6] = sectorID;
      }
      else if(direction == SectorDirection.Below)
      {
        ids[7] = sectorID;
      }
      else if(direction == SectorDirection.LR)
      {
        ids[8] = sectorID;
      }

    }
    ids[4] = this.name;

    String toReturn = "";
    toReturn += "Sector " + name + " map\n";
    toReturn += "----------\n";
    toReturn += ("| " + ids[0] + " " + ids[1] + " " + ids[2] + " |\n");
    toReturn += ("| " + ids[3] + " " + ids[4] + " " + ids[5] + " |\n");
    toReturn += ("| " + ids[6] + " " + ids[7] + " " + ids[8] + " |\n");
    toReturn += "----------\n";
    return toReturn;
  }
}
