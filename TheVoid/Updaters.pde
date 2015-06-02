/*
 *  Updater methods on physical objects that run update loop and check for
 *  death condition.
 */

/**
 * Update all physical objects using their Update() function
 * Check if objects should be killed (remove them from their arraylist)
 * Check if object has left its parent sector, removing them from that sector's list
 * and adding them to another sector's.
 * @param _object List of objects to update/delete
 * @return {Integer} Number of items destroyed in this loop
 */
int UpdatePhysicalObjects(ArrayList<? extends Physical> _object)
{
  int objectsDestroyed = 0;
  for (Iterator<? extends Physical> iterator = _object.iterator(); iterator.hasNext();) 
  {
    Physical obj = iterator.next();
    obj.Update();
    if (obj.toBeKilled) 
    {
      // Remove the current element from the iterator and the list.
      objectsDestroyed++;
      iterator.remove();
    }

    else if(obj.velocity.mag() > 0)      //If moving, check if it has left the sector
    {
      if(!CheckDrawableOverlap(obj.currentSector.collider, obj.location))   //Is object inside the sector still?
      {
        boolean newSectorFound = false;
        if(debugMode.value)
        {
          println("[DEBUG] " + obj.name + " has left its parent sector...");
        }
        
        //TODO should be doing rectangle-rectangle collision, not point-point. This should do for now
        //Object left sector -- find new sector it is in
        for(Sector sector : sectors.values())
        {
          if(CheckDrawableOverlap(sector.collider, obj.location))
          {
            obj.currentSector = sector;
            if(debugMode.value)
            {
              println("[DEBUG] " + obj.name + " moved to sector " + sector.name);
            }
            //HACK check if this is the playership to generate more sectors
            if(obj instanceof Player)
            {
              //Add to temp hashmap, merge at end (see GameLoops & AssetLoader's MergeSectorMaps)
              generatedSectors = BuildSectors(obj.currentSector);
            }

            //Remove from current sector's objects, add to next sector's objects
            sector.ReceiveNewObject(obj);

            try
            {
              iterator.remove();      //Remove from current list inside sector
              newSectorFound = true;
            }
              
            catch(Exception e)
            {
              println("[ERROR] deleting object " + obj.name);
              println("[ERROR] " + e);
            }
            break;
          }
        }
        if(!newSectorFound)
        {
          println("[WARNING] " + obj.name + " moved into empty sector");
          obj.toBeKilled = true;
        }
        
      }
    }
  }
  return objectsDestroyed;
}

void UpdateSectorMap(HashMap<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    a.Update();      //Update the sector object
    int enemiesKilled = UpdatePhysicalObjects(a.ships);
    UpdatePhysicalObjects(a.asteroids);
    UpdatePhysicalObjects(a.planets);  //Station updates occur in planet update loop
    UpdatePhysicalObjects(a.friendlyLaserFire);
    UpdatePhysicalObjects(a.enemyLaserFire);
    UpdatePhysicalObjects(a.enemyLaserFire);
    UpdatePhysicalObjects(a.powerups);

    if(!a.shipsToAdd.isEmpty())       //Add in ships generated during update loop (currently only charred hull)
    {
      for(Ship s : a.shipsToAdd)
      {
        a.ships.add(s);
      }
      a.shipsToAdd.clear();
    }
    if(gameState != GameState.GAMEOVER)
    {
      playerShip.score += enemiesKilled * 50;     //Update score 50 points per enemy killed
    }
    
  }
}

