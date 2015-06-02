
//Wrapper for a boolean to pass mutably between classes (Java doesnt support pointers or references)
public class TogglableBoolean
{
  public boolean value;
  
  TogglableBoolean(boolean _val)
  {
    value = _val;
  }
  
  public void Toggle()
  {
    value = !value;
  }
}
