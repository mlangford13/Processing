public static enum ShapeType {
  _SQUARE_, _TRIANGLE_, _CIRCLE_, _RECTANGLE_
}

/*
 * UI shape (Square, circle, rectangle, triangle allowed)
*/
public class Shape extends Drawable implements Updatable
{
  public ShapeType shapeType;
  public color borderColor;
  
  private color defaultColor;
  private boolean colorSet;          //Allow only one initial set of color after the constructor's default
  private color fillColor;
  
  //Shape offsets/rotations
  float rotationOffset;
  PVector positionOffset;

  //Lines for collision checking
  ArrayList<Line> lines;
  Line top, left, bottom, right;    //For rectangles
  Line edge1, edge2, edge3;         //For triangles

  public Shape(String _name, PVector _loc, PVector _size, color _color, ShapeType _shapeType)
  {
    super(_name, _loc, _size);

    //Color & shape setup
    borderColor = _color;
    defaultColor = borderColor;
    shapeType = _shapeType;
    colorSet = false;
    fillColor = color(255,255,255,0);

    //Offsets
    rotationOffset = 0;
    positionOffset = new PVector(0,0);

    //Lines for collision
    lines = new ArrayList<Line>();

    //Build lines based on shape type
    if(shapeType == ShapeType._RECTANGLE_ || shapeType == ShapeType._SQUARE_)
    {
      top = new Line(location.x - size.x/2, location.y - size.y/2, //Offset for default center-render
                            location.x + size.x/2, location.y - size.y/2);    
      left = new Line(location.x - size.x/2, location.y - size.y/2, 
                            location.x - size.x/2, location.y + size.y/2);    
      bottom = new Line(location.x - size.x/2, location.y + size.y/2, 
                            location.x + size.x/2, location.y + size.y/2);
      right = new Line(location.x + size.x/2, location.y - size.y/2, 
                            location.x + size.x/2, location.y + size.y/2);
      lines.add(top);   //add all to lines list for reading during collision
      lines.add(left);
      lines.add(bottom);
      lines.add(right);
    }
    else if(shapeType == ShapeType._TRIANGLE_)
    {
      float a = size.x;
      float r = a * sqrt(3)/6;      //See http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
      float R = r * 2;
      PVector vertex1 = new PVector(location.x,location.y);
      PVector vertex2 = new PVector(location.x + r+R, location.y + 7*a/8);
      PVector vertex3 = new PVector(location.x + r+R, location.y - 7*a/8);

      edge1 = new Line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);
      edge2 = new Line(vertex2.x, vertex2.y, vertex3.x, vertex3.y);
      edge3 = new Line(vertex3.x, vertex3.y, vertex1.x, vertex1.y);

      lines.add(edge1);
      lines.add(edge2);
      lines.add(edge3);
    }
  }
  
  /**
   * Special case of draw that does not user super.DrawObject()
   * Only draw shapes
   */
  @Override public void DrawObject()
  {
    pushMatrix();
    pushStyle();

    translate(location.x, location.y);
    rotate(baseAngle);

    stroke(borderColor);
    fill(fillColor);
    
    if(shapeType == ShapeType._SQUARE_)
    {
      rectMode(renderMode);
      rect(0, 0, size.x, size.x);    //TODO forced square here
      if(size.x != size.y)
      {
        println("[WARNING] Square shape being force-rendered with rectangle edges!");
      }
      
    }
    if(shapeType == ShapeType._RECTANGLE_)
    {
      rectMode(renderMode);
      rect(0, 0, size.x, size.y); 
    }
    else if(shapeType == ShapeType._TRIANGLE_)
    {
      // rotate(triangleRotate);
      float a = size.x;
      float r = a * sqrt(3)/6;      //See http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
      float R = r * 2;
    
      beginShape(TRIANGLES);
      vertex(0,0);
      vertex(r+R, 7*a/8);
      vertex(r+R, -7*a/8);
      endShape();

      if(size.x != size.y)
      {
        println("[WARNING] Equilateral triangle with unequal x/y parameters being drawn! This will break collision detection");
      }
    }
    else if(shapeType == ShapeType._CIRCLE_)
    {
      ellipseMode(RADIUS);
      ellipse(0, 0, size.x/2, size.y/2);
    }
    else
    {
       println("[ERROR] Invalid shape to draw!");
    }
    popStyle();
    popMatrix();
  }
  

  public void Update()
  {
    //Update line locations to move to new location, then rotate
    if(shapeType == ShapeType._RECTANGLE_ || shapeType == ShapeType._SQUARE_)
    {
      //New line locations, un-rotated
      top.start.x = location.x - size.x/2 + positionOffset.x;
      top.start.y = location.y - size.y/2 + positionOffset.y;
      top.end.x = location.x + size.x/2 + positionOffset.x;
      top.end.y = location.y - size.y/2 + positionOffset.y;

      left.start.x = location.x - size.x/2 + positionOffset.x;
      left.start.y = location.y - size.y/2 + positionOffset.y;
      left.end.x = location.x - size.x/2 + positionOffset.x;
      left.end.y = location.y + size.y/2 + positionOffset.y;

      bottom.start.x = location.x - size.x/2 + positionOffset.x;
      bottom.start.y = location.y + size.y/2 + positionOffset.y;
      bottom.end.x = location.x + size.x/2 + positionOffset.x;
      bottom.end.y = location.y + size.y/2 + positionOffset.y;

      right.start.x = location.x + size.x/2 + positionOffset.x;
      right.start.y = location.y - size.y/2 + positionOffset.y;
      right.end.x = location.x + size.x/2 + positionOffset.x;
      right.end.y = location.y + size.y/2 + positionOffset.y;

      //Rotate all lines for collision by angle
      top.UpdateByRotation(baseAngle + rotationOffset, location.get());
      left.UpdateByRotation(baseAngle + rotationOffset, location.get());
      right.UpdateByRotation(baseAngle + rotationOffset, location.get());
      bottom.UpdateByRotation(baseAngle + rotationOffset, location.get());
    }


  }

  public void SetFillColor(color _fillColor)
  {
    fillColor = _fillColor;
  }
  
  public void SetIcon(color _color, ShapeType _type)
  {
    if(!colorSet)
    {
      //Set shape type
      shapeType = _type;
      
      //Set border color
      borderColor = _color;
      defaultColor = borderColor;
      
      colorSet = true;
    }
    else
    {
      println("WARNING: Attempted to set icon color after it had been initially set. Try UpdateIcon instead?");
    }
  }
  
  void SetBorderColor(color _borderColor, ShapeType _type)
  {
    shapeType = _type;
    borderColor = _borderColor;
  }
  
  void SetBorderColor(color _borderColor)
  {
    borderColor = _borderColor;
  }
  
  public void RestoreDefaultColor()
  {
    borderColor = defaultColor;
  }
}

/**
 * Line helper for collision
 */
public class Line
{
  PVector start;      //start of the line
  PVector end;        //end of the line
  float length;       //how long the line is

  public Line(float x1, float y1, float x2, float y2)
  {
    start = new PVector(x1, y1);
    end = new PVector(x2, y2);

    start.x = x1;
    start.y = y1;
    end.x = x2;
    end.y = y2;

    length = PVector.dist(new PVector(x1,y1), new PVector(x2,y2));
  }

  /**
   * Rotate about the origin with given angle theta
   * @param theta angle in radians
   * @param location 2D coordinates (literally location from drawable)
   */
  public void UpdateByRotation(float theta, PVector location)
  {
    PVector startOffset = new PVector(start.x-location.x, start.y-location.y);
    PVector endOffset = new PVector(end.x-location.x, end.y-location.y);

    start.x = location.x + (float)((startOffset.x)*cos(theta) - (startOffset.y)*sin(theta));
    start.y = location.y + (float)((startOffset.x)*sin(theta) + (startOffset.y)*cos(theta));

    end.x = location.x + (float)((endOffset.x)*cos(theta) - (endOffset.y)*sin(theta));
    end.y = location.y + (float)((endOffset.x)*sin(theta) + (endOffset.y)*cos(theta));
  }

}