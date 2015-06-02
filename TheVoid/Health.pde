/*
 * A health class for tracking health on a given object. 
 */

public class Health
{
  int current, max;
  
  Health(int _current, int _max)
  {
    current = _current;
    max = _max;
  }

  public void SetMaxHealth(int _newMax)
  {
  	max = _newMax;
  	current = max;
  }
  
  public void Add(int _addition)
  {
    current += _addition;
    if(current > max)
    {
      current = max;
    }
  } 
}
