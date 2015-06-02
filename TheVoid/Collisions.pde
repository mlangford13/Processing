//Handle collisiosn between two sets of drawable objects
//ONLY VALID FOR CIRCLES/ RECTANGLES


/**
 * Handle intra-sector collisions between ships and asteroids
 * @param {Map<Integer, Sector>} _sectors Sector to do collision checks on
 */
void HandleSectorCollisions(Map<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    HandleCollisions(a.asteroids, a.ships);
    HandleCollisions(a.enemyLaserFire, playerShip);
    HandleCollisions(a.enemyLaserFire, a.asteroids);
    HandleCollisions(a.friendlyLaserFire, a.asteroids);
    HandleCollisions(a.friendlyLaserFire, a.ships);   //HACK still allows player collision with his own shots
    HandleCollisions(a.asteroids);

    for(Planet p : a.planets)
    {
      HandleCollisions(a.enemyLaserFire, p.stations);
      HandleCollisions(a.friendlyLaserFire, p.stations);
      HandleCollisions(a.asteroids, playerShip.shield);

      HandleFriendlyCollision(p.stations, playerShip);    //Heal at stations
    }

    for(Ship s : a.ships)
    {
      if(s.shield.online && s.shield.enabled)
      {
        HandleCollisions(a.asteroids, s.shield);
        HandleCollisions(a.enemyLaserFire, s.shield);   //HACK doesn't allow for enemy shields
      }
    }

    HandleFriendlyCollision(a.powerups, playerShip);
    
  }
}

void HandleCollisions(ArrayList<? extends Physical> a, ArrayList<? extends Physical> b)
{
  Shape collider1, collider2;
  for(Physical obj1 : a)
  {
    for(Physical obj2 : b)
    {
      if(obj1.collidable && obj2.collidable)
      {
        collider1 = obj1.collider;      //Grab shape objects for overlap checking
        collider2 = obj2.collider;

        if(CheckShapeToShapeOverlap(collider1, collider2))
        {
          if(debugMode.value)
          {
            print("[DEBUG] COLLISION BETWEEN: ");
            print(obj1.name + "[" + obj1.GetID() + "]");
            print(" & ");
            print(obj2.name + "[" + obj2.GetID() + "]");
            print("\n");
          }
          // collisionSound.play();
          obj1.HandleCollision(obj2);
          obj2.HandleCollision(obj1);
        }
      }

    }
  }
}

void HandleCollisions(ArrayList<? extends Physical> a, Physical obj2)
{
  Shape collider1, collider2;
  collider2 = obj2.collider;      //Grab shape object for overlap checking
  for(Physical obj1 : a)
  {
    if(obj1.collidable && obj2.collidable)
    {
      collider1 = obj1.collider;
      if(CheckShapeToShapeOverlap(collider1, collider2)) 
      {
        if(debugMode.value)
        {
          print("[DEBUG] COLLISION BETWEEN: ");
          print(obj1.name + "[" + obj1.GetID() + "]");
          print(" & ");
          print(obj2.name + "[" + obj2.GetID() + "]");
          print("\n");
        }
        // collisionSound.play();
        obj1.HandleCollision(obj2);
        obj2.HandleCollision(obj1);
      }
    }
  }
}

/**
 * Handle self collisions within physical object list
 * @param a ArrayList of physical objects to check self-collision on
 */
void HandleCollisions(ArrayList<? extends Physical> a)
{
  Shape collider1, collider2;
  for(Physical obj1 : a)
  {
    for(Physical obj2 : a)
    {
      if(obj1 != obj2)
      {
        if(obj1.collidable && obj2.collidable)
        {
          collider1 = obj1.collider;      //Grab shape objects for overlap checking
          collider2 = obj2.collider;

          if(CheckShapeToShapeOverlap(collider1, collider2))
          {
            if(debugMode.value)
            {
              print("[DEBUG] COLLISION BETWEEN: ");
              print(obj1.name + "[" + obj1.GetID() + "]");
              print(" & ");
              print(obj2.name + "[" + obj2.GetID() + "]");
              print("\n");
            }
            // collisionSound.play();
            obj1.HandleCollision(obj2);
            obj2.HandleCollision(obj1);
          }
        }
      }
    }
  }
}

/**
 * Handle a friendly object providing aid to the player (or enemy!)
 * @param a   List of objects that MIGHT be friendly
 * @param obj Physical object which will receive aid
 */
void HandleFriendlyCollision(ArrayList<? extends Physical> a, Physical obj2)
{
  Shape collider1, collider2;
  collider2 = obj2.collider;      //Grab shape object for overlap checking
  for(Physical obj1 : a)
  {
    // if(implementsInterface(a, Friendly))
    // {
      collider1 = obj1.collider;
      if(CheckShapeToShapeOverlap(collider1, collider2)) 
      {
        if(debugMode.value)
        {
          print("[DEBUG] FRIENDLY AID BETWEEN: ");
          print(obj1.name + "[" + obj1.GetID() + "]");
          print(" & ");
          print(obj2.name + "[" + obj2.GetID() + "]");
          print("\n");
        }
        Friendly friend = (Friendly)obj1;
        friend.ProvideAid(obj2);
      }
    // }
  }
}

//Check if a point falls within a drawable object
boolean CheckDrawableOverlap(Drawable obj, PVector point)
{
  if(obj != null)
  {  
    PVector collisionOffset;      //Offset due to center vs rect rendering (rect = 0 offset)
    //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self
    if(obj.renderMode == CENTER)
    {
      collisionOffset = new PVector(-obj.size.x/2, -obj.size.y/2);
    }
    else if(obj.renderMode == CORNER)
    {
      collisionOffset = new PVector(0,0);
    }
    else
    {
      collisionOffset = new PVector(obj.size.x/2, obj.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj.name);
      print("\n");
    }
    
    if(point.x >= obj.location.x + collisionOffset.x
      && point.y >= obj.location.y + collisionOffset.y
      && point.y <= obj.location.y + collisionOffset.y + obj.size.y
      && point.x <= obj.location.x + collisionOffset.x + obj.size.x)
    {
      return true;
    }
  }
  
  return false;
}

//Check if a point falls within a drawable object
boolean CheckDrawableOverlap(Drawable obj1, Drawable obj2)
{
  if(obj1 != null)
  {  
    PVector collisionOffset1, collisionOffset2;      //Offset due to center vs rect rendering (rect = 0 offset)
    //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self
    if(obj1.renderMode == CENTER)
    {
      collisionOffset1 = new PVector(-obj1.size.x/2, -obj1.size.y/2);
    }
    else if(obj1.renderMode == CORNER)
    {
      collisionOffset1 = new PVector(0,0);
    }
    else
    {
      collisionOffset1 = new PVector(obj1.size.x/2, obj1.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj1.name);
      print("\n");
    }

    if(obj2.renderMode == CENTER)
    {
      collisionOffset2 = new PVector(-obj2.size.x/2, -obj2.size.y/2);
    }
    else if(obj2.renderMode == CORNER)
    {
      collisionOffset2 = new PVector(0,0);
    }
    else
    {
      collisionOffset2 = new PVector(obj2.size.x/2, obj2.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj2.name);
      print("\n");
    }
    
    if(obj1.location.x + collisionOffset1.x >= obj2.location.x - collisionOffset2.x   //X from right
        && obj1.location.y + collisionOffset1.y >= obj2.location.y - collisionOffset2.y  //Y from top
        && obj1.location.x - collisionOffset1.x <= obj2.location.x + collisionOffset2.x  //X from left
        && obj1.location.y - collisionOffset1.y <= obj2.location.y + collisionOffset2.x)    //Y from bottom
    {
      return true;
    }
  }
  
  return false;
}


boolean CheckShapeToShapeOverlap(Shape obj1, Shape obj2)
{
  if(obj1 == obj2)    //Avoid self collision
  {
    return false;
  }

  //*Handle different combinations of collisions*//
  //Line-line collisions
  if(obj1.shapeType != ShapeType._CIRCLE_ && obj2.shapeType != ShapeType._CIRCLE_)
  {
    //Check if any of the lines in the first object overlap any of the lines
    //in the second object
    for(Line line1 : obj1.lines)     
    {
      for(Line line2 : obj2.lines)
      {
        if(LineLineCollision(line1, line2))
        {
          return true;
        }
      }
    }
  }
  //Obj1 circle, obj2 not
  else if(obj1.shapeType == ShapeType._CIRCLE_ && obj2.shapeType != ShapeType._CIRCLE_)
  {
    for(Line line2 : obj2.lines)
    {
      if(LineCircleCollision(obj1, line2))    //Check every line in obj2's line list against the circle
      {
        return true;
      }
    }
  }
  //Obj2 circle, obj1 not
  else if(obj2.shapeType == ShapeType._CIRCLE_ && obj1.shapeType != ShapeType._CIRCLE_)
  {
    for(Line line1 : obj1.lines)
    {
      if(LineCircleCollision(obj2, line1))
      {
        return true;
      }
    }
  }
  //Circle-circle
  else if(obj2.shapeType == ShapeType._CIRCLE_ && obj1.shapeType == ShapeType._CIRCLE_)
  {
    if(BallBallCollision(obj1, obj2))
    {
      return true;
    }
  }
  else
  {
    println("[WARNING] Unsupported collision type!");
  }

  return false;
}

boolean CheckShapeToPointOverlap(Shape obj1, PVector point2)
{
  println("[WARNING] Point collision not implemented!");
  return false;
}


/**
 * Credit Jeff Thompson, modified by Jeff Eitel
 * @param  {Line} line1 Line to check
 * @param  {Line} line2 Line to check
 * @return   {boolean} True if collided
 */
boolean LineLineCollision(Line line1, Line line2)
{
  float x1, x2, x3, x4, y1, y2, y3, y4;
  x1 = line1.start.x;
  y1 = line1.start.y;

  x2 = line1.end.x;
  y2 = line1.end.y;

  x3 = line2.start.x;
  y3 = line2.start.y;

  x4 = line2.end.x;
  y4 = line2.end.y;

  // find uA and uB
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // note: if the below equations is true, the lines are parallel
  // ... this is the denominator of the above equations
  // (y4-y3)*(x2-x1) - (x4-x3)*(y2-y1)

  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) 
  {
    // find intersection point, if desired
    float intersectionX = x1 + (uA * (x2-x1));
    float intersectionY = y1 + (uA * (y2-y1));
    // noStroke();
    // fill(0);
    // ellipse(intersectionX, intersectionY, 10,10);

    return true;
  }
  else 
  {
    return false;
  }
}

/**
 * Source: http://www.openprocessing.org/sketch/65771
 * Modified for use with my data types
 * @param  {Shape} ball Ball object with type circle
 * @param  {Line} line A line....
 * @return     True for any collision type, false for no collision
 */
boolean LineCircleCollision(Shape ball, Line line)
{
  // Translate everything so that line segment start point to (0, 0)
  PVector ballLoc = ball.location.get();
  ballLoc.x -= line.start.x;
  ballLoc.y -= line.start.y;
  PVector lineEnd = new PVector(line.end.x, line.end.y);
  lineEnd.x -= line.start.x;
  lineEnd.y -= line.start.y;
  float r = ball.size.x/2;

  float a = lineEnd.x; // Line segment end point horizontal coordinate
  float b = lineEnd.y; // Line segment end point vertical coordinate
  float c = ballLoc.x; // Circle center horizontal coordinate
  float d = ballLoc.y; // Circle center vertical coordinate
  
  // Collision computation
  boolean startInside = false;
  boolean endInside = false;
  boolean middleInside = false;
  if ((d*a - c*b)*(d*a - c*b) <= r*r*(a*a + b*b)) 
  {
    // Collision is possible
    if (c*c + d*d <= r*r) 
    {
      // Line segment start point is inside the circle
      startInside = true;
      return true;
    }
    if ((a-c)*(a-c) + (b-d)*(b-d) <= r*r) 
    {
      // Line segment end point is inside the circle
      endInside = true;
      return true;
    }
    if (!startInside && !endInside && c*a + d*b >= 0 && c*a + d*b <= a*a + b*b) 
    {
      // Middle section only
      middleInside = true;
      return true;
    }
  }

  return false;
}

/**
 * Credit Jeff Thompson, modified by Jeff Eitel
 * Ball-ball collision
 * @param  ball1 First shape object
 * @param  ball2 Second shape object
 * @return       True for collision, false for not
 */
boolean BallBallCollision(Shape ball1, Shape ball2) 
{
  if(ball1.shapeType != ShapeType._CIRCLE_ || ball1.shapeType != ShapeType._CIRCLE_)
  {
    println("[ERROR] Tried to determine ball-ball collision on non-circle objects!");
    return false;
  }

  float x1, x2, y1, y2, d1, d2;
  x1 = ball1.location.x;
  y1 = ball1.location.y;
  x2 = ball2.location.x;
  y2 = ball2.location.y;
  d1 = ball1.size.x;
  d2 = ball2.size.x;
  // find distance between the two objects
  float xDist = x1-x2;                                   // distance horiz
  float yDist = y1-y2;                                   // distance vert
  float distance = sqrt((xDist*xDist) + (yDist*yDist));  // diagonal distance

  // test for collision
  if (d1/2 + d2/2 > distance) {
    return true;    // if a hit, return true
  }
  else {            // if not, return false
    return false;
  }
}
