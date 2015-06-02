public enum DrawStyle {
  STANDARD, GRADIENT
}

class TextWindow extends UI
{  
  private String textData = "";
  private color backgroundColor;         //For standard background
  private color gradientColor;         //destination color background -> gradientColor
  private int textRenderMode;          //Render as center or corner
  private DrawStyle fillMode;          //How to fill the text window
  
  ArrayList<Drawable> icons;  //Icons within the window
  
  TextWindow(String _name, PVector _loc, String _text)
  {
    super(_name, _loc, new PVector(200, 125), false);      //Default size 200 by 100
    textData = _text;
    
    fillMode = DrawStyle.STANDARD;      //Solid color fill by default
    backgroundColor = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    renderMode = CORNER;            //Default render mode for a textbox is corner
    
    icons = new ArrayList<Drawable>();
  }
  
  TextWindow(String _name, PVector _loc, PVector _size, String _text)
  {
    super(_name, _loc, _size, false);      //Non-standard window size
    textData = _text;
    
    fillMode = DrawStyle.STANDARD;      //Solid color fill by default
    backgroundColor = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    renderMode = CORNER;            //Default render mode for a textbox is corner
    
    icons = new ArrayList<Drawable>();
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    pushStyle();
    translate(location.x, location.y);
    
    //BACKGROUND
    rectMode(renderMode);

    if(fillMode == DrawStyle.STANDARD)
    {
      fill(backgroundColor);
    }
    else if(fillMode == DrawStyle.GRADIENT)
    {
      DrawGradient();
    }
    else
    {
      println("WARNING: tried to render textwindow background of unsupported DrawStyle");
    }

    rect(0, 0, size.x, size.y);
    
    //TEXT
    fill(textColor);
    if(textRenderMode == CENTER)
    {
      translate(size.x/2,0);    //Shift by half text box size (fake center rendering)
    }
    
    textAlign(textRenderMode,TOP);
    
    textFont(standardFont, fontSize);    //Standard standardFont and size for drawing fonts

    text(textData, 10, 10);
    
    //Icon
    if(icons.size() > 0)
    {
      for(Drawable img : icons)
      {
        img.DrawObject();
      }
    }
    popStyle();
    popMatrix();
  }
  
  public void AddIcon(PVector _loc, PVector _size, PImage _img)
  {
    Drawable icon = new Drawable("Civ icon", _loc, _size);
    icon.sprite = _img;
    icons.add(icon);
  }
  
  public void UpdateText(String _newText)
  {
    textData = _newText;
  }
  
  //Set single color background, change fill style
  public void SetBackgroundColor(color _background)
  {
    fillMode = DrawStyle.STANDARD;
    backgroundColor = _background;
  }
  
  public void SetTextColor(color _textColor)
  {
    textColor = _textColor;
  }
  
  public void SetTextRenderMode(int _mode)
  {
    if(_mode == CENTER || _mode == CORNER)
    {
      textRenderMode = _mode;
    }
    else
    {
      print("WARNING: tried to set text render mode on TextWindow ID=");
      print(ID);
      print(" to an invalid value (not corner or center).\n");
    }
  }
  
  public void SetGradient(color c1, color c2) 
  {
    fillMode = DrawStyle.GRADIENT;
    backgroundColor = c1;
    gradientColor = c2;
  }

  
  private void DrawGradient()
  {
    noFill();
    
    int y = 0;
    int x = 0;
    int w = (int)size.x;
    int h = (int)size.y;
    
    for (int i = y; i <= y+h; i++) 
    {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(backgroundColor, gradientColor, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }
}
