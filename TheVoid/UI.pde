
public class UI extends Drawable
{
  PFont font;
  int fontSize;
  protected color textColor;      //Used by inhereted classes only
  
  boolean visibleNow;      //Is this part of the UI being rendered right now?
  boolean scalesWithZoom;
  
  public UI(String _name, PVector _loc, PVector _size, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size);
    scalesWithZoom = _scalesWithZoom;
    
    font = standardFont;      //Use pre-generated font
    if(font == null)
    {
      println("[ERROR] PFont null!");
    }
    fontSize = 14;
    visibleNow = false;
  }
  
  //Update the absolute coordinates of this UI
  public void UpdateLocation(PVector _newlocation)
  {
    location = _newlocation;
  }
}
