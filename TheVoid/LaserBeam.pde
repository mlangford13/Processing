enum LaserColor {
  RED, GREEN
}

public class LaserBeam extends Physical
{
  //Draw properties (limit range)
  static final float laserSpeedLimit = 20.0;    //Speed limit, static for all laserbeams
  static final int timeToFly = 2000;        //Effective range, related to speed (ms)
  private long spawnTime;
  
  LaserColor laserColor;

  LaserBeam(PVector _loc, PVector _direction, PVector _size, Sector _sector, 
                Shape _collider, LaserColor _color)
  {
    super("Laser beam", _loc, _size, .0001, _sector, _collider);    //HACK Mass very low!! For handling physics easier 
    
    //Set laser color
    laserColor = _color;
    if(_color == LaserColor.GREEN)
    {
      sprite = greenLaser.get();
    }
    else
    {
      sprite = redLaser.get();
    }
    
    sprite.resize((int)size.x, (int)size.y);
    
    //Set laser speed and lifetime
    localSpeedLimit = laserSpeedLimit;
    spawnTime = millis();
    
    //Damage settings
    damageOnHit = 20;
    
    //Velocity setter
    PVector scaledVelocity = _direction.get();
    scaledVelocity.setMag(laserSpeedLimit);
    
    velocity = scaledVelocity;
    
    //Play laser fire sound
    // laserSound.play();       //TODO too many of these play calls in one loop crashes the sound library....

    if(_color == LaserColor.GREEN)      //HACK determine team  by color
    {
      currentSector.friendlyLaserFire.add(this);
    }
    else
    {
      currentSector.enemyLaserFire.add(this);
    }
  }
  
  //Standard update() + handle time of flight
  @Override public void Update()
  {
    super.Update();

    if(spawnTime + timeToFly < millis())
    {
      toBeKilled = true;
    }
  }
  
  //Handle laser damage in addition to standard collision
  @Override public void HandleCollision(Physical _other)
  {
    _other.health.current -= damageOnHit;
  
    if(debugMode.value)
    {
      print("[DEBUG] Laser beam burn hurt ");
      print(_other.name);
      print(" for ");
      print(damageOnHit);
      print(" damage.\n");
    }
    
    // laserHitSound.play();
    toBeKilled = true;
  }

}
