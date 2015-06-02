/**
 * A ship gameobject, inheriting from Pilotable. Expensive purchase cost, but great at shooting 
 * down enemy missiles.
 */
public class Ship extends Physical implements Clickable, Updatable
{
  TextWindow info;
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  //Scanners
  protected int scanInterval = 500;         //ms between scans
  protected long lastScanTime;              //When last scan occured
  protected int sensorRange = 250;          //Units of pixels
  protected Shape scanRadius;               //Circle outline, when hovered over, shows sensor/weapons range
  
  //Weapons
  protected long lastFireTime;
  protected float minFireInterval = 1;          //ms between shots
  protected float currentFireInterval = 850;
  protected boolean canFire = true;

  ArrayList<Physical> targets;    //Firing targets selected after scan
  
  //Shields
  Shield shield;

  //Engines
  float minThrust, maxThrust;
  
  public Ship(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, 
    color _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, _sector, _collider);
    sprite = _sprite.get(); 
    sprite.resize(int(size.x), int(size.y));

    //Setup health, scaled by size relative to max size
    //TODO implement this into constructor (it is redundantly over-written in many places)
    health.max = 200;      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;
    
    //Set the overlay icon
    iconOverlay.SetIcon(_outlineColor,ShapeType._TRIANGLE_);
    
    //Prepare smoke damage effect
    smoke1Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smoke2Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smokeEffect1 = new Smoke(location, new PVector(10,10));      //Place at origin for time being, use smoke locations in update
    smokeEffect2 = new Smoke(location, new PVector(10,10));  
    smoke1Visible = false;
    smoke2Visible = false;
    
    //Shield setup
    int shieldSize = (int)size.x;      //HACK this sort of doesn't matter because the shield class over-writes this size in its constructor...
    Shape shieldCollider = new Shape("collider", location, new PVector(shieldSize, shieldSize), color(0,255,0), 
            ShapeType._CIRCLE_);

    int shieldCapacity = 500;
    shield = new Shield(this, shieldCapacity, currentSector, shieldCollider);

    //Prepare engines
    minThrust = 0.0;
    maxThrust = 10.0;

    //Prepare sensors
    scanRadius = new Shape("Scan radius", location, new PVector(sensorRange,sensorRange), 
                color(255,0,0), ShapeType._CIRCLE_);
    
    //Prepare laser
    targets = new ArrayList<Physical>();
    lastScanTime = 0;
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nHealth: ";
    descriptor += health.current ;
    info = new TextWindow("Ship Info", location, descriptor);
    
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();

    if(shield.online && shield.enabled)
    {
      collidable = false;     //Make double sure no collisions happen on the ship inside the shield
      shield.DrawObject();
    }
    else
    {
      collidable = true;
    }
    
    //Draw smoke effects
    if(smoke1Visible)
    {
      smokeEffect1.DrawObject();
    }
    if(smoke2Visible)
    {
      smokeEffect2.DrawObject();
    }

  }
  
  /**
   * Set the sector this ship is currently in.
   * @param {Sector} _sector Sector object of current location
   */
  public void UpdateCurrentSector(Sector _sector)
  {
    currentSector = _sector;
  }

  @Override public void Update()
  {
    super.Update();    //Call Physical update (movement occurs here)
    
    //Shield info update
    shield.Update();

  //**** UI ****//
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    
    if(millis() > lastFireTime + currentFireInterval)
    {
      canFire = true;
    }
    else
    {
      canFire = false;
    }

    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);

   //**** HEALTH *****//
    //Check health effect thresholds
    if(health.current <= health.max/2)
    {
      smoke1Visible = true;
    }
    if(health.current <= health.max/4)
    {
      smoke2Visible = true;
    }
    
  //**** EFFECTS *****//
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
    
  //**** DEATH *****//
    //If the ship will die after this frame
    if(toBeKilled)
    {
      shield.toBeKilled = true;
      GenerateDeathExplosions(3, location, size, currentSector);
    }
  }

  /**
   * Calculates shoot vector and builds a laser object to fire.
   * Note that the laser object adds itself to the sector in its
   * constructor, and does not need explicit appending.
   * @param {PVector} _target Target to shoot at
   * @param _color Laser color red/green
   */
  protected void BuildLaserToTarget(PVector _target, LaserColor _color)     //Replaced 'Physical _target' to a 'PVector _target';
  {
    if(canFire)
    {
      PVector targetVector = PVector.sub(_target,location);
      targetVector.normalize();
      
      //Create laser object
      PVector laserSize = new PVector(20,3);
      PVector laserSpawn;
      if(shield.enabled)
      {
        if(shield.size.x > size.x || shield.size.y > size.y)    //Fire outside shield
        { 
          laserSpawn = new PVector(location.x + targetVector.x * shield.size.x/2 * 1.25, 
            location.y + targetVector.y * shield.size.y/2 * 1.25);
        }
        else  //Weird case of a small shield -- just fire outside
        {
          laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1, 
              location.y + targetVector.y * size.y * 1.1);
        }
      }
      
      else
      {
        laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1, 
          location.y + targetVector.y * size.y * 1.1);
      }
      
      Shape laserCollider = new Shape("collider", laserSpawn, laserSize, color(0,255,0), 
            ShapeType._RECTANGLE_);
      LaserBeam beam = new LaserBeam(laserSpawn, targetVector, laserSize, currentSector, 
                  laserCollider, _color);
      
      lastFireTime = millis();
      canFire = false;
    }
    
  }
    
  protected void BuildLaserToTarget(Physical _target, LaserColor _color)
  {
    if(canFire)
    {
      //Calculate laser targeting vector
      PVector targetVector = PVector.sub(_target.location, location);
      targetVector.normalize();        //Normalize to simple direction vector
      targetVector.x += rand.nextFloat() * 0.5 - 0.25;
      targetVector.y += rand.nextFloat() * 0.5 - 0.25;
      
      //Create laser object
      PVector laserSize = new PVector(20,3);
      PVector laserSpawn;
      if(shield.enabled)    //Fire outside sheild to prevent self collision
      {
        laserSpawn = new PVector(location.x + targetVector.x * shield.size.x/2 * 1.1, 
          location.y + targetVector.y * shield.size.y/2 * 1.1);    //Where to spawn the laser outside ship
      }
      else
      {
        laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1, 
          location.y + targetVector.y * size.y * 1.1);    //Where to spawn the laser outside ship
      }
      Shape laserCollider = new Shape("collider", laserSpawn, laserSize, color(0,255,0), 
            ShapeType._RECTANGLE_);
      LaserBeam beam = new LaserBeam(laserSpawn, targetVector, laserSize , currentSector, 
            laserCollider, _color);

      lastFireTime = millis();
      canFire = false;
    }
    
  }

/*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  //Handle click actions on this object
  void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  void Click()
  {
    println("[INFO] No interaction defined for ship click");
  }
  
  //When the object moves its UI elements must as well
  void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(location);
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nHealth: ";
    descriptor += health.current;
    
    info.UpdateText(descriptor);
  }

}
