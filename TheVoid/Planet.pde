/*
 * A planet gameobject, inheriting from Drawable. May contain stations orbiting it
 */
public class Planet extends Physical implements Clickable, Updatable
{
  public TextWindow info;     //For mouseover

  private String[] planetDescriptions = {"Lifeless Planet", "Ocean Planet", "Lava Planet", "Crystalline Planet",
                                "Desert Planet", "Swamp Planet", "Class-M Planet", "Lifeless Planet",
                                "Class-M Planet", "Ionically Charged Planet", "Forest Planet", "Scorched Planet"};
  
  private int planetTypeIndex;
  private ArrayList<Station> stations;      //Stations around this planet

  public Planet(String _name, PVector _loc, int _diameter, int _mass, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super(_name, _loc, new PVector(_diameter, _diameter), _mass, _sector, _collider);
    
    //Select my planet image from spritesheet (total of 10 options)
    planetTypeIndex = rand.nextInt(11) + 1;    //There is no p0, add 1
    
    //Create filesystem path to sprite
    String filePath = "";
    filePath += "Assets/Planets/p";
    filePath += planetTypeIndex;
    filePath += "shaded.png";

    //Set the sprite to the random subset of the spritesheet
    sprite = loadImage(filePath);
    sprite.resize((int)size.x, (int)size.y);
    
    //Generate stations
    stations = new ArrayList<Station>();
    int maxStations = 2;
    int minStations = 0;
    int stationCount = rand.nextInt((maxStations - minStations) + 1) + minStations;
    GenerateStations(stationCount);

    //Set string descriptor for real-ish values that look pretty
    String descriptor = new String();
    descriptor += planetDescriptions[planetTypeIndex-1];
    descriptor += "\nAll planets support";
    descriptor += "\nup to 4 orbital stations.";
    info = new TextWindow("Planet info", location, descriptor);
  }

  //Create possible station locations around each planet
  private void GenerateStations(int _count)
  {
    ArrayList<PVector> stationOrbitLocationCandidates = new ArrayList<PVector>();
    
    PVector locationCandidate1 = new PVector(location.x - 75, location.y);
    PVector locationCandidate2 = new PVector(location.x + 75, location.y);
    PVector locationCandidate3 = new PVector(location.x, location.y - 75);
    PVector locationCandidate4 = new PVector(location.x, location.y + 75);
   
    stationOrbitLocationCandidates.add(locationCandidate1);
    stationOrbitLocationCandidates.add(locationCandidate2);
    stationOrbitLocationCandidates.add(locationCandidate3);
    stationOrbitLocationCandidates.add(locationCandidate4);
    
    for(int i = 0; i < _count; i++)
    {
      //Random size
      int sizeGen = rand.nextInt(Station.maxStationSize * 2/3) + Station.maxStationSize * 1/2;       //TODO how does this work again?
      PVector stationSize = new PVector(sizeGen, sizeGen);
      
      //Randomly select station location from generated list above
      int locationSelectedIndex = rand.nextInt(stationOrbitLocationCandidates.size());
      PVector stationLoc = stationOrbitLocationCandidates.get(locationSelectedIndex);
      stationOrbitLocationCandidates.remove(locationSelectedIndex);
      
      //Select station color & build station
      Station station;
      int stationLevel = rand.nextInt(2) + 1;     //to set station size
      int stationColor = rand.nextInt(2) + 1;     //to set station color
      Shape colliderGen = new Shape("collider", stationLoc, stationSize, color(0,255,0), 
          ShapeType._CIRCLE_);
      if(stationLevel == 1)
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            blueStation1, currentSector, colliderGen);
          station.friendly = true;
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            redStation1, currentSector, colliderGen);
        }
      }
      else if(stationLevel == 2)
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            blueStation2, currentSector, colliderGen);
          station.friendly = true;
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            redStation2, currentSector, colliderGen);
        }
      }
      else
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            blueStation2, currentSector, colliderGen);
          station.friendly = true;
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            redStation2, currentSector, colliderGen);
        }
      }

      stations.add(station);
    }
  }

  @Override public void DrawObject()
  {
    super.DrawObject();
    DrawObjects(stations);    //Draw child stations
  }
  public void Update()
  {    
    super.Update();    //Call physical update

    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this

    UpdatePhysicalObjects(stations);    //HACK Update child stations
  }

/*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  void Click()
  {
    
  }
  
  //When the object moves this must move as well
  void UpdateUIInfo()
  {
    info.UpdateLocation(location);
    
    String descriptor = planetDescriptions[planetTypeIndex-1];
    descriptor += "\nDiameter: ";
    descriptor += (float)size.x*150;
    descriptor += " km \nMass: ";
    descriptor += mass/10;
    descriptor += "E23 kg\n";

    info.UpdateText(descriptor);
  }
  

}
