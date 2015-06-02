PImage missileSprite;      //Loaded in setup()

/**
 * A missile gameobject, inheriting from Pilotable
 */
public class Missile extends Physical implements Clickable, Updatable
{
  TextWindow info;

  Missile(PVector _loc, PVector _moveVector, color _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super("Missile", _loc, new PVector(20,10), 10, _sector, _collider);    //mass = 10
    
    //Health
    health.max = 60;
    health.current = 60;
    
    //Damage
    damageOnHit = 250;
    
    //Physics
    velocity = _moveVector;
    // rotationRate = 0.1;          //Rotation rate on a missile is ~10x better than a ship
    
    //Override local speed limit
    //TODO test me
    localSpeedLimit = 1.25;   //Overrides physical default value
    
    //UI
    sprite = missileSprite;
    sprite.resize(int(size.x), int(size.y));
    
    //Set the overlay icon
    iconOverlay.SetIcon(_outlineColor,ShapeType._SQUARE_);
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";
    info = new TextWindow("Missile Info", location, descriptor);
  }
  
  //HACK this update() function is highly repeated through child classes
  public void Update()
  {
    super.Update();    //Call pilotable update
    
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
  }

/*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  //Handle click actions on this object
  void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  void Click()
  {
    //No action
  }
  
  //When the object moves its UI elements must as well
  void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(new PVector(wvd.pixel2worldX(location.x), wvd.pixel2worldY(location.y)));
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";

    info.UpdateText(descriptor);
  }
  
  @Override public void HandleCollision(Physical _other)
  {
    super.HandleCollision(_other);
    Explosion explosion = new Explosion(location, new PVector(64,48));    //New explosion here
    explosions.add(explosion);      //Add to list of effects to render
    
    //Explosion force!
    float explosiveForce = 0.75;
    
    PVector explosionDirection = new PVector(0,0);    //Delta of position, dP(12) = P2 - P1
    explosionDirection.x = _other.location.x - location.x;
    explosionDirection.y = _other.location.y - location.y;
    
    explosionDirection.normalize();      //Create unit vector for new direction from deltaP
    
    //Opposite vector for this object
    explosionDirection.mult(-1);
    explosionDirection.setMag(explosiveForce);
    
    if(debugMode.value)
    {
      print("Explosion from missile hit ");
      print(_other.name);
      print(" for ");
      print(damageOnHit);
      print(" damage.\n");
    }
    _other.ChangeVelocity(explosionDirection);
    
    toBeKilled = true;
  }

}
