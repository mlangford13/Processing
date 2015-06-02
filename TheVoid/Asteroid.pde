//Each sprite spaced 128 pixels apart
PImage asteroidSpriteSheet;      //Loaded in setup()

/*
 * An asteroid gameobject, inheriting from Physical
 */
public class Asteroid extends Physical implements Updatable
{
  private static final int minDiameter = 10;
  private static final int maxDiameter = 30;
  private static final int maxAsteroidHealth = 100;
  
  private boolean isDebris = false;        //Is this asteroid just debris from another asteroid's death?
  
  public Asteroid(PVector _loc, int _diameter, int _mass, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super("Asteroid", _loc, new PVector(_diameter, _diameter), _mass, _sector, _collider);
    
    //Select my asteroid image from spritesheet     
    int RandomAsteroidIndex1 = rand.nextInt(8);      //x coordinate in sprite sheet
    int RandomAsteroidIndex2 = rand.nextInt(8);      //y coordinate in sprite sheet

    //Set the sprite to the random subset of the spritesheet
    sprite = asteroidSpriteSheet.get(RandomAsteroidIndex1 * 128, RandomAsteroidIndex2 * 128, 128, 128);
    
    //Scale by 128/90 where 128 is provided size above and 90 is actual size of the asteroid sprite
    sprite.resize(int(size.x * 128/90), int(size.y * 128/90));
    
    //Setup health, scaled by size relative to max size
    health.max = (int)(size.x/maxDiameter * maxAsteroidHealth);      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;
  }
  
  @Override public void Update()
  {
    super.Update();

    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
    if(toBeKilled && !isDebris)    //Generate debris asteroids iff dying and not already debris
    {
      for(int i = 0; i < 3; i++)
      {
        Shape debrisCollider = new Shape("collider", location, new PVector((int)size.x/2, (int)(size.y/2)), color(0,255,0), ShapeType._CIRCLE_);
        Asteroid debris = new Asteroid(location, (int)size.x/2, (int)(mass/2), currentSector, debrisCollider);
        
        //New velocity with some randomness based on old velocity
        debris.SetVelocity(new PVector(velocity.x/4 + rand.nextFloat()*localSpeedLimit/6,
                                        velocity.y/4 + rand.nextFloat()*localSpeedLimit/6));
        debris.isDebris = true;
        
        //See AsteroidFactory for details on this implementation
        debris.SetMaxSpeed(2.5);      //Local speed limit for asteroid
        
        //Setup health, scaled by size relative to max size. 1/4 health of std asteroid
        //HACK this just overwrites the constructor
        debris.health.max = (int)(debris.size.x/maxDiameter * maxAsteroidHealth)/8;
        debris.health.current = health.max;
        
        currentSector.debrisSpawned.add(debris);
      }
    }
  }

  /*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }

  

}
