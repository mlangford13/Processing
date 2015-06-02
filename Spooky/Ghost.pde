class Ghost
{
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxSpeed;
  float maxForce;
  float velX= random(-5,5);
  float velY= random(-5,5);
  int ghostSize = 75;
  int leftBound = 13;
  int rightBound = 56;
  int topBound = 9;
  int bottomBound = 61;
  
  
  Ghost(float x, float y)
  {
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-4,4),random(-4,4));
    location = new PVector(x,y);
    r=75;
    maxSpeed = 10;
    maxForce = .4;
  }
  
  void update()
  {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    location.add(velocity);
    acceleration.mult(0);
  }
  
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  void applyBehaviors(ArrayList<Ghost> ghosts, int _separateWeight, int _avoidWeight)
  {
    PVector separateForce = separate(ghosts);
    //PVector seekForce = seek(new PVector(mouseX-ghostSize/2,mouseY-ghostSize/2));
    PVector avoidForce = avoid(new PVector(mouseX-ghostSize/2, mouseY-ghostSize/2));
    separateForce.mult(_separateWeight);
    avoidForce.mult(_avoidWeight);
    applyForce(separateForce);
    applyForce(avoidForce);
  }
  
  PVector seek(PVector target)
  {
    PVector none= new PVector(0,0);
    if(location.x < crosshair.middleX + crosshair.lightSize/2 && 
       location.x + ghostSize > crosshair.middleX - crosshair.lightSize/2 &&
       location.y < crosshair.middleY + crosshair.lightSize/2 &&
       location.y + ghostSize > crosshair.middleY - crosshair.lightSize/2)
       { 
         PVector desired = PVector.sub(target,location);
         desired.normalize();
         desired.mult(maxSpeed);
         PVector steer= PVector.sub(desired,velocity);
         steer.limit(maxForce);
         //applyForce(steer);
         return steer;
       }
       return none;
  }
  
  PVector avoid(PVector target)
  {
    PVector none= new PVector(0,0);
    if(location.x < crosshair.middleX + crosshair.lightSize/2 && 
       location.x + ghostSize > crosshair.middleX - crosshair.lightSize/2 &&
       location.y < crosshair.middleY + crosshair.lightSize/2 &&
       location.y + ghostSize > crosshair.middleY - crosshair.lightSize/2)
       { 
         PVector desired = PVector.sub(target,location);
         desired.normalize();
         desired.mult(maxSpeed);
         PVector steer= PVector.sub(desired,velocity);
         steer.limit(maxForce);
         steer.mult(-1); // to flip the direction of the desired vector in the opposite direction of the target
         //applyForce(steer);
         return steer;
       }
       return none;
  }
  
  boolean checkHit()
  {
    //Height 10 - 60 pixels
    //Width  14 - 55 pixels
    if( location.x + leftBound < crosshair.middleX &&
        location.x + rightBound > crosshair.middleX &&
        location.y + topBound < crosshair.middleY &&
        location.y + bottomBound > crosshair.middleY)
    {
      return true;
    }
    return false;
  }
    
  
  void display()
  {
    image(ghost,location.x,location.y);
  }
  
  PVector separate(ArrayList<Ghost> ghosts)
  {
    PVector sum = new PVector();
    PVector none = new PVector(0,0);
    int count = 0;
    float desiredSeparation = r;
    for(Ghost g : ghosts)
    {
      float dist = PVector.dist(location, g.location);
      if((dist>0) && (dist<desiredSeparation))
      {
        PVector diff = PVector.sub(location, g.location);
        diff.normalize();
        diff.div(dist);
        sum.add(diff);
        count++;
      }
    }
    if(count >0)
    {
      sum.div(count);
      sum.setMag(maxSpeed);
      PVector steer = PVector.sub(sum,velocity);
      steer.limit(maxForce);
      return steer;
    }
    if(location.x + ghostSize < 0)
    {
      location.x = width;
    }
    if(location.x > width)
    {
      location.x = -ghostSize;
    }
    if(location.y + ghostSize < 0)
    {
      location.y = height;
    }
    if(location.y > height)
    {
      location.y = -ghostSize;
    }
    return none;
  }
}
