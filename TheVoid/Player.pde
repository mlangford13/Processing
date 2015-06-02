
/**
 * Player ship object, with reactor cores, stations, etc.
 */
public class Player extends Ship
{
  //Scoring
  int score;      //for killing bad guys

  //Ship components
  private Reactor reactor;
  private int maxPowerToNode;			//Maximum power any one node may have

  //Engines
  float leftEnginePower, rightEnginePower;  
  
  //Weapons targeting
  private Shape targetCircle;
  private Physical currentTarget;         //What ship is currently looking at
  private int currentTargetIndex;         //Index into targets arraylist 

  //Power ups
  boolean bulletHellEnabled = false;        //Fire FAST!
  private int bulletHellDuration = 7000;     //How long to make bullet hell enabled
  private long bulletHellStartTime = 0;

  boolean enginesBoosted = false;         //Fly fast
  float engineSpeedModifier = 2;          //Multiplier of how fast engine can go
  private float standardSpeed;            //Store standard power to restore at the end

  private int engineBoostDuration = 7000;  
  private long engineBoostStartTime = 0;

  //Scanners
  int sensorRange = 2000;          //Units of pixels
  Shape scanRadius;               //Circle outline, when hovered over, shows sensor/weapons range

  //Behavoir Ranges for Enemy
  public Shape seekCircle, seekAgainCircle, avoidCircle;    //For collision detections
  public int seekDiameter, seekAgainDiameter, avoidDiameter;

  public Player(PVector _loc, PVector _size, PImage _sprite, int _mass, color _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super("Player", _loc, _size, _sprite, _mass, _outlineColor, _sector, _collider);

    score = 0;      //Modified when enemies die

    //Reactor setup
    reactor = new Reactor(100);
    maxPowerToNode = reactor.totalCapacity/3;
    
    //Shield setup 
    shield.online = true;
    shield.enabled = true;

    //Engine setup
    leftEnginePower = 0;
    rightEnginePower = 0;

    //Behavior Ranges for Enemies
    seekDiameter = 3000;        //All ships inside this circle will seek to destory
    seekAgainDiameter = 800;
    avoidDiameter = 400;
    
    seekCircle = new Shape("seekCircle", location, new PVector(seekDiameter,seekDiameter), color(0,255,255), ShapeType._CIRCLE_);                    //Light Blue
    seekAgainCircle = new Shape("seekAgainCircle", location, new PVector(seekAgainDiameter,seekAgainDiameter), color(255,18,200), ShapeType._CIRCLE_); //Pink
    avoidCircle = new Shape("avoidCircle",location , new PVector(avoidDiameter,avoidDiameter), color(18,255,47), ShapeType._CIRCLE_);                  //Green
  
    //Targetting circle initially transparent target circle
    targetCircle = new Shape("targetCircle", location, new PVector(200,200), color(255,0,0,125), ShapeType._CIRCLE_); 
  
    //Prepare sensors collider
    scanRadius = new Shape("Scan radius", location, new PVector(sensorRange,sensorRange), 
                color(255,0,0), ShapeType._CIRCLE_);

    localSpeedLimit = 5;
    standardSpeed = localSpeedLimit;    //To restore after engine boost 
  }	

  @Override public void Update()
  {
    super.Update();

    //Update player radius circles for seek/flee    
    seekCircle.location = location;
    seekAgainCircle.location = location;
    avoidCircle.location = location;

    //Movement input
    HandleMovement();

    //Targeting
    SearchForTargets();
    if(currentTarget != null)
    {
      targetCircle.location = currentTarget.location;
    }

    //Bullet hell updates
    if(millis() > bulletHellStartTime + bulletHellDuration)
    {
      bulletHellEnabled = false;    //Disable after duration
    }

    if(bulletHellEnabled)
    {
      currentFireInterval = minFireInterval;
    }
    else
    {
      currentFireInterval = 150;
    }

    //Engine boost update
    if(millis() > engineBoostStartTime + engineBoostDuration)
    {
      enginesBoosted = false;    //Disable after duration
    }

    if(enginesBoosted)
    {
      localSpeedLimit = standardSpeed * engineSpeedModifier;
    }
    else
    {
      localSpeedLimit = standardSpeed;
    }

    if(toBeKilled)
    {
      Ship charredHull = new Ship("Charred", location, size, charredPlayerShip, (int)mass, 
              color(255), currentSector, collider);
      charredHull.smoke1Visible = true;
      charredHull.smoke2Visible = true;
      charredHull.health.SetMaxHealth(1000000);      //Don't die....
      charredHull.localSpeedLimit = 1;
      charredHull.velocity = velocity;

      currentSector.shipsToAdd.add(charredHull);     //To add at end of update loop
    }
  }
  

  @Override public void DrawObject()
  {
    super.DrawObject();

    if(debugMode.value)
    {
      seekCircle.DrawObject();      //Circlers for where enemies seek/flee
      seekAgainCircle.DrawObject();
      avoidCircle.DrawObject();
    }

    if(currentTarget != null)
    {
      if(currentTarget.toBeKilled)
      {
        currentTarget = null;
      }
      else
      {
        targetCircle.DrawObject();
      }     
    }
  }	

  /**
   * [HandleMovement description]
   * TODO document
   */
  private void HandleMovement()
  {
    //Apply drag
    if(velocity.mag() > 0.01)
    {
      PVector drag = velocity.get();
      drag.setMag(-velocity.mag()/100);
      ApplyForce(drag);
    }


    //Calculate spin & thrust forces
    PVector spinForce = Spin();
    ApplyForce(spinForce);

    PVector thrustForce = Thrust();
    ApplyForce(thrustForce); 
  }     

  /**
   * Creates two 'spin' vectors for each of the two engines.
   * The vectors are both perpendicular to the Velocity vector and face opposite directions from one another
   * They are scaled based on the engines power and then summed to each other and passed as a steering force to be summed to the acceleration vector 
   * @return {PVector} Vector to be applied to the player's ship
   */
  PVector Spin()
  {
    PVector spinLeftEngine = new PVector(1,0);
    PVector spinRightEngine = new PVector(1,0);
    int engineThreshHold = 10;
    float spinFactor = 0.25;
    
    spinLeftEngine.rotate(velocity.heading() + HALF_PI);    //left engine vector set perdendicular to Velocity facing left.
    spinRightEngine.rotate(velocity.heading() - HALF_PI);   //right engine vector set perpendiuclar to Velocity facing right.
    spinLeftEngine.setMag(leftEnginePower);                 //Set magnitudes to Engines power ranging 0-10
    spinRightEngine.setMag(rightEnginePower); 
    PVector spinSum = PVector.add(spinRightEngine, spinLeftEngine);  //Sum the apposing facing spin vectors
    PVector desired = new PVector(0,0);
    if(leftEnginePower <= engineThreshHold && rightEnginePower <= engineThreshHold && velocity.mag() <= 1)
    {
      spinSum.setMag(map(spinSum.mag(), 0, engineThreshHold, 0, spinFactor));
      desired = PVector.add(spinSum,forward);
      if(desired.mag() == 1)
      {
        desired.setMag(0);
      }
      desired.setMag(map(desired.mag(), 0,sqrt(spinFactor*spinFactor+1), 0,0.5));
      return desired;
    }
    spinSum.x = map(spinSum.x, 0, 10, 0, 0.5);          //Limit to better turning speed 'feel'
    spinSum.y = map(spinSum.y, 0, 10, 0, 0.5);
  
    return spinSum;
    
  }

  /**
   * Calculate forward vector of ship thrusters
   * @return {PVector} thrust vector forward on the ship to apply
   */
  PVector Thrust()
  {
    PVector thrust = new PVector(1,0);
    thrust.rotate(forward.heading());
    float thrustPower = (leftEnginePower/maxThrust) + (rightEnginePower/maxThrust);
    thrustPower = map(thrustPower, 0, 2, 0, 0.1);     //Tune here to modify acceleration 'feel'

    thrust.setMag(thrustPower);

    return thrust;
  }


  /**
   * Get next target in targetlist and place in
   * currentTarget
   * @see  Interactions.pde for calling by controls
   */
  public void SelectNextTarget()
  {
    //TODO select targets besides closest
    float currentTargetDistance = 99999999;
    if(currentTarget != null)
    {
     currentTargetDistance = PVector.dist(location, currentTarget.location);
    }

    for(Physical p : targets)
    {
      float targetDistance = PVector.dist(location, p.location);
      if(targetDistance <= currentTargetDistance)
      {
        currentTargetDistance = targetDistance;
        println("[INFO] New target " + p);
        currentTarget = p;
      }
    }
          
  }

  /**
   * Search through this and surrounding sectors for targets,
   * and add them to the targets arraylist.
   */
  private void SearchForTargets()
  {
    targets.clear();
    ArrayList<Sector> neighbors = currentSector.GetSelfAndAllNeighbors();
    for(Sector sector : neighbors)
    {
      for(Ship s : sector.ships)
      {
        if(s != this)
        {
          if(PVector.dist(location, s.location) <= sensorRange)
          {
            if(!targets.contains(s))
            {
              targets.add(s);
            }
            
          }
        }
      }

    }
  }
  
  public void FireAtTarget()
  {
    if(currentTarget != null)
    {
      BuildLaserToTarget(currentTarget, LaserColor.GREEN);
    }
  }

  public void EnableBulletHell()
  {
    bulletHellStartTime = millis();
    bulletHellEnabled = true;
  }

  public void EnableEngineBoost()
  {
    engineBoostStartTime = millis();
    enginesBoosted = true;
  }


}


//---------------------------


enum NodeType{
  SHIELDS, WEAPONS, ENGINES
}

/**
 * A power reactor that controls how much power the ship gets to each of its
 * nodes. To be controlled by keyboard / external controller
 */
public class Reactor
{
	int totalCapacity;
	Map<NodeType, Node> nodes;

	public Reactor(int _capacity)
	{
		totalCapacity = _capacity;
		nodes = new HashMap<NodeType, Node>();
		nodes.put(NodeType.SHIELDS, new Node(NodeType.SHIELDS));
		nodes.put(NodeType.WEAPONS, new Node(NodeType.WEAPONS));
		nodes.put(NodeType.ENGINES, new Node(NodeType.ENGINES));
	}

	public int GetReactorPower(NodeType _type)
	{
		return nodes.get(_type).currentPower;
	}
}

/**
 * Power node on the reactor control board
 */
public class Node
{
	NodeType type;
	int currentPower;

	public Node(NodeType _type)
	{
		type = _type;
		currentPower = 0;
	}

	public void SetPower(int _power)
	{
		currentPower = _power;
	}

}
