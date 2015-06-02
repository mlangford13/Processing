/**
 * Tools to generate asteroid parameters, and return asteroid objects.
 */
public class AsteroidFactory
{
  //Default values
  private PVector maxVelocity = new PVector(.2,.1);                 //Max velocity in given x/y direction of asteroid

  //Generator values (keep these stored for next asteroid to create
  private int minX, minY, maxX, maxY, size, xCoor, yCoor;
  private float xVelocity, yVelocity;
  private PVector asteroidSizeRange = new PVector(Asteroid.minDiameter, Asteroid.maxDiameter);
  private Sector nextAsteroidSector;      //Sector to place next asteroid on

  /**
   * Constructor for default asteroid factory generation
   */
  AsteroidFactory(){
  }

  /**
   * Constructor for asteroid generation over provided size range
   * @param {PVector} _sizeRange Overriding size range (min, max) of asteroids
   */
  AsteroidFactory(PVector _sizeRange)
  {
    asteroidSizeRange = _sizeRange;
  }
  
  void SetMaxVelocity(PVector _maxVelocity)
  {
    maxVelocity = _maxVelocity;
  }
  
  /**
   * Generate parameters for the next asteroid generated
   * @param {Sector} _sector Sector to generate on
   * @see  Helpers.pde for implementation
   * @see  GenerateAsteroid() for object construction
   */
  void SetNextAsteroidParameters(Sector _sector)
  {
    minX = int(_sector.GetLocation().x + asteroidSizeRange.x);
    minY = int(_sector.GetLocation().y + asteroidSizeRange.y);
    maxX = int(_sector.GetSize().x - asteroidSizeRange.x);
    maxY = int(_sector.GetSize().y - asteroidSizeRange.y);
  
    size = rand.nextInt(int(asteroidSizeRange.y - asteroidSizeRange.x))+ int(asteroidSizeRange.x);
    
    //Generate a random X coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size
    xCoor = rand.nextInt(maxX - int(asteroidSizeRange.y)) + minX + int(asteroidSizeRange.y/2);
    yCoor = rand.nextInt(maxY)+minY;
    
    //Generate random movement vector
    //TODO velocity unused in asteroids!
    xVelocity = 2 * maxVelocity.x * rand.nextFloat() - maxVelocity.x;    //Desensitize in x direction
    yVelocity = 2 * maxVelocity.y * rand.nextFloat() - maxVelocity.y;

    nextAsteroidSector = _sector;
  }
  
  /**
   * Build asteroid with parameters generated in SetNextAsteroidParameters and return it
   * @return {Asteroid} Generated asteroid
   */
  Asteroid GenerateAsteroid()
  {
    Shape colliderGenerated = new Shape("collider", new PVector(xCoor, yCoor), new PVector(size, size), 
                color(0,255,0), ShapeType._CIRCLE_);
    Asteroid toBuild = new Asteroid(new PVector(xCoor, yCoor), size, int(1000*size/asteroidSizeRange.y),
                nextAsteroidSector, colliderGenerated);
    toBuild.SetVelocity(new PVector(xVelocity, yVelocity));
    toBuild.SetMaxSpeed(2.5);      //Local speed limit for asteroid
    toBuild.iconOverlay.SetIcon(color(#E8E238),ShapeType._CIRCLE_);
    toBuild.drawOverlay = false;      //Dont draw overlay by default
    
    return toBuild;
  }
  
  PVector GetNextAsteroidLocation()
  {
    return new PVector(xCoor, yCoor);
  }
  
  int Size()
  {
    return size;
  }
  
  //Force the asteroid's Y direction to have this sign (for use with spawn areas)
  void OverrideYDirection(float _sign)
  {
    if(_sign > 0)    //DOWN, positive
    {
      if(yVelocity < 0)    //Flip, making positive
      {
        yVelocity *= -1;
      }
    }
    else            //UP, negative
    {
      if(yVelocity > 0)
      {
        yVelocity *= -1;    //Flip, making negative
      }
    }
  }
}
