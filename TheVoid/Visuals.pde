//******* DRAW ********//

void DrawObjects(ArrayList<? extends Drawable> _objects)
{
  for(Drawable a : _objects)
  {
    a.DrawObject();
  }
}

/**
 * Draw sectors and all child objects
 * @param {Hashmap<Int,Sector> _sectors Draw sector background
 * then all objects on top of it
 */
void DrawSectors(Map<Integer, Sector> _sectors)
{
  //Draw sector backgrounds themselves
  for(Sector a : _sectors.values())
  {
    a.DrawObject();
    a.collider.DrawObject();    //Draw sector outlines
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.planets);     //Stations drawn here too
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.asteroids);
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.ships);
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.friendlyLaserFire);
    DrawObjects(a.enemyLaserFire);
  }
  
  for(Sector a : _sectors.values())
  {
    DrawObjects(a.powerups);
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.explosions);
  }
}

/**
 * Move all objects in a sector
 * @param _sectors map of sectors by ID
 */
void MoveSectorObjects(Map<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.planets);     //Stations drawn here too
  }

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.asteroids);
  }

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.ships);
  }

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.friendlyLaserFire);
    MovePhysicalObject(a.enemyLaserFire);
  }
}

//Move an array of movable objects
void MovePhysicalObject(ArrayList<? extends Physical> physical)
{
  for(Physical a : physical)
  {
    a.Move();
  }
}

//******* ZOOM ********//

void BeginZoom()
{
  pushMatrix();
  translate(-wvd.orgX * wvd.viewRatio, -wvd.orgY * wvd.viewRatio);
  scale(wvd.viewRatio);
}

void EndZoom()
{
  popMatrix();
}

//******* EXPLOSIONS ********//

//Generate a number of explosions, generally upon the death of some ship, station, etc
void GenerateDeathExplosions(int _count, PVector _center, PVector _deadObjSize, Sector _sector)
{
  for(int i = 0; i < _count; i++)
  {
    float explosionScale = rand.nextFloat() + 0.5;    //explosion scale 0.5-1.5
    PVector explosionSize = new PVector(explosionScale * 64, explosionScale * 48);  //Scale off standard size
    PVector spawnLoc = new PVector(_center.x + _deadObjSize.x/2 * rand.nextFloat() - 0.5, 
                  _center.y + _deadObjSize.y/2 * rand.nextFloat() - 0.5);
    
    Explosion explosion = new Explosion(spawnLoc, explosionSize); 
    int frameDelay = rand.nextInt(60);                //Delay 0-60 frames
    explosion.SetRenderDelay(frameDelay);             //Setup delay on this explosion to render
    
    _sector.explosions.add(explosion);                        //Add this explosion to an ArrayList<Explosion> for rendering
  }
}
