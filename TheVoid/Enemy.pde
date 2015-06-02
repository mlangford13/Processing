public class Enemy extends Ship
{
  //AI here
  boolean fleeingPlayer;
  Player player;
  
  int avoidAsteroidWeight, avoidPlayerWeight, seekPlayerWeight, avoidShipWeight;  // Handles enemies priority of movement
  
  int firingRange;     //How far away enemy will fire

  int asteroidFleeDistance = 100;
  int shipFleeDistance = 100;

  public Enemy(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, color _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super(_name, _loc, _size, _sprite, _mass, _outlineColor, _sector, _collider);
    
    //Convenience pointer to player
    player = playerShip;

    //Flee/attack
    fleeingPlayer = false;
    targets.add(player);      //All enemies are looking for the player
    
    firingRange = (width + height)/2;

    //Weight Amounts for flee/seek
    avoidAsteroidWeight = 2;
    avoidShipWeight = 3;
    avoidPlayerWeight = 3;
    seekPlayerWeight = 1;

    localSpeedLimit = 4.5;
    maxForceMagnitude = 0.3;      //For smoother turning
  }

  @Override public void Update()
  {
   super.Update();

   ArrayList<Sector> thisSectorAndNeighbors = currentSector.GetSelfAndAllNeighbors();
   for(Sector s : thisSectorAndNeighbors)
   {
     for(Asteroid a : s.asteroids)
     {
       if(PVector.dist(a.location, location) < asteroidFleeDistance)
       {
         PVector avoidAsteroidForce = Avoid(a.location);
         avoidAsteroidForce.mult(avoidAsteroidWeight);
         ApplyForce(avoidAsteroidForce);
       }
     }

     for(Ship ship : s.ships)
     {
      if(ship != this && ship != playerShip)
      {
        if(PVector.dist(ship.location, location) < shipFleeDistance)
        {
          PVector avoidShipForce = Avoid(ship.location);
          avoidShipForce.mult(avoidShipWeight);
          ApplyForce(avoidShipForce);
        }
      }
     }
   }

   PVector avoidPlayerForce = Avoid(playerShip.location);
   avoidPlayerForce.mult(avoidPlayerWeight);
   PVector seekPlayerForce = Seek(playerShip.location);
   seekPlayerForce.mult(seekPlayerWeight);

   if(CheckDrawableOverlap(player.seekCircle, location))   //I see the player
   {
      if(CheckDrawableOverlap(player.avoidCircle, location))
      {
        fleeingPlayer = true;
      }
      else if(!CheckDrawableOverlap(player.avoidCircle, location) 
        && !CheckDrawableOverlap(player.seekAgainCircle, location))    //I am in the seek circle but NOT either of the others
      {
        fleeingPlayer = false;
      }

     if(fleeingPlayer)
     {
        ApplyForce(avoidPlayerForce);
     }
     else
     {
        ApplyForce(seekPlayerForce);
     }
   }

   //**** WEAPONS *****//
    if(millis() - lastFireTime > currentFireInterval)    //Time to fire?
    {
      if(!targets.isEmpty())
      {
        Physical closestTarget = null;    //Default go after closest target
        float closestDistance = 99999;
        for(Physical phys : targets)    //Check each target to find if it is closest
        {
          PVector distance = new PVector(0,0);
          PVector.sub(phys.location,location,distance);
          if(distance.mag() < closestDistance)
          {
            closestTarget = phys;
          }
        }
        
        if(closestTarget != null)    //Found a target
        {
          float targetRange = PVector.dist(closestTarget.location, location);
          if(targetRange < firingRange)   //I am within fire range of player
          {
            BuildLaserToTarget(closestTarget, LaserColor.RED);
            lastFireTime = millis();
          }
        }
      }
    }
  }
  
  
  PVector Seek(PVector target)
  {
    //if(seekAgainDiameter is true && seekRadius true)
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(localSpeedLimit);
    PVector steer= PVector.sub(desired, velocity);
    steer.limit(maxForceMagnitude);
    return steer;
  }
  
  PVector Avoid(PVector target)
  {
    //if(avoidDiameter is true and seekAgainDiameter is false)
    PVector steer = Seek(target);
    steer.mult(-1);      // to flip the direction of the desired vector in the opposite direction of the target
    
    return steer;
  }
}
