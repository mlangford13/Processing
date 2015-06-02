public interface Movable
{
  void Move();
  void ChangeVelocity(PVector _modifier);
  void SetVelocity(PVector _velocity);
}

public interface Collidable
{
  void HandleCollision(Physical _collider);
}

enum ClickType{
  INFO, TARGET, BUTTON
}

public interface Clickable
{
  void UpdateUIInfo();          //Update the location and any text/ UI information in the given window
  ClickType GetClickType();
  void Click();                 //Click the target
  void MouseOver();             //Mouseover the target
}

//For all classes that have information to update each loop
public interface Updatable
{
  void Update();
}

/**
 * A friendly object (e.g. station) that provides
 * aid to physical objects
 */
public interface Friendly
{
  void ProvideAid(Physical _friend);
}
