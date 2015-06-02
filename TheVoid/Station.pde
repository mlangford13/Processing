PImage redStation1, redStation2, redStation3;
PImage blueStation1, blueStation2, blueStation3;

enum StationType {
  MILITARY, ENERGY
}

public class Station extends Physical implements Updatable, Friendly
{
  static final int maxStationSize = 60;      //Maximum station size
  static final int maxStationHealth = 1000;  //Maximum health for a station
  
  //Station mass-energy generation per sec
  int massEnergyGen;

  //Aid
  boolean friendly;
  int healAmount = 50;
  int healPeriod = 200;        //How long between each heal tick
  long lastHealTime = 0;
  
  //Placement parameters
  Shape placementCircle;      //Shows the area where a spawned ship/ missile may be placed around this station
  int placementRadius;
  boolean displayPlacementCircle = false;    //Whether or not to draw the placement circle
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  public Station(StationType _type, PVector _loc, PVector _size, PImage _sprite, Sector _sector, Shape _collider) 
  {
    super("Military Station", _loc, _size, 1500, _sector, _collider);
    //TODO implement something besides military station?

    sprite = _sprite.get();      //Use get() for a copy
    sprite.resize((int)size.x, (int)size.y);

    //Setup health, scaled by size
    health.max = ((int)(size.x/maxStationSize * maxStationHealth)/100)*100;      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;

    //Prepare smoke damage effect
    smoke1Loc = new PVector(size.x/4 * rand.nextFloat(), size.y/2 * rand.nextFloat());
    smoke2Loc = new PVector(size.x/4 * rand.nextFloat(), size.y/2 * rand.nextFloat());
    smokeEffect1 = new Smoke(location, new PVector(10,10));      //Place at origin for time being, use smoke locations in update
    smokeEffect2 = new Smoke(location, new PVector(10,10));  
    smoke1Visible = false;
    smoke2Visible = false;
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();
    
    //Draw smoke effects
    pushStyle();
    if(smoke1Visible)
    {
      smokeEffect1.DrawObject();
    }
    if(smoke2Visible)
    {
      smokeEffect2.DrawObject();
    }
    popStyle();
  }
  
  public void Update()
  {
    super.Update();    //Call physical update

    //Check health effect thresholds
    if(health.current <= health.max/2)
    {
      smoke1Visible = true;
    }
    if(health.current <= health.max/4)
    {
      smoke2Visible = true;
    }
    
    //Update smoke effect location
    if(smoke1Visible)
    {
      smokeEffect1.location = PVector.add(location,smoke1Loc);
      smokeEffect1.Update();
    }
    if(smoke2Visible)
    {
      smokeEffect2.location = PVector.add(location,smoke2Loc);
      smokeEffect2.Update();
    }
    
    //If the ship will die after this frame
    if(toBeKilled)
    {
      GenerateDeathExplosions(5, location, size, currentSector);
    }
  }

  /**
   * Heal the player, if friendly
   * @param _friend Friendly object
   */
  public void ProvideAid(Physical _friend)
  {
    if(friendly)
    {
      if(millis() > lastHealTime + healPeriod)
      {
        _friend.health.Add(healAmount); 
        lastHealTime = millis();
      }
    }
  }
}
