/*
 * A helper class to aid in zooming in/out and panning
 * Sourced & modified from Processing forum user 'quarks' on post:
 * http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
*/
class WorldViewData {
  // Pan offsets Made public to speed up get access
  public float orgX = 0.0f;
  public float orgY = 0.0f;
  // viewRatio = number of pixels that represents a distance
  // of 1.0 in real world coordinates - bigger the value the
  // greater the magnification
  public float viewRatio = 1.0f;

  public WorldViewData() {
    orgX = 0.0f;
    orgY = 0.0f;
    viewRatio = 1.0f;
  }

  /**
   * Resize the world due to changes in magnification
   * so that the image is centred on the screen
   * @param f    new viewRatio
   * @param pw    width of view area in pixels
   * @param ph    height of view area in pixels
   */
  public void resizeWorld(float zf, int pw, int ph) {
    float newX, newY;
    float w = pw;
    float h = ph;
    // Calculate new origin so as to centre the image
    newX = orgX + w/(2.0f*viewRatio) - w/(2.0f*zf);
    newY = orgY + h/(2.0f*viewRatio) - h/(2.0f*zf);
    orgX = newX;
    orgY = newY;
    viewRatio = zf;
  }

  // Calculate the world X position corresponding to
  // pixel position
  public float pixel2worldX(float px) {
    return orgX + px / viewRatio;
  }

  // Calculate the world Y position corresponding to
  // pixel position
  public float pixel2worldY(float py) {
    return orgY + py / viewRatio;
  }

  // Calculate the display X position corresponding to
  // world position
  public float world2pixelX(float wx) {
    return viewRatio / (wx - orgX);
  }

  // Calculate the display Y position corresponding to
  // world position
  public float world2pixelY(float wy) {
    return viewRatio / (wy - orgY);
  }

  /**
   * Set origin of top left to x, y
   * @param x
   * @param y
   * @return true if the origin has changed else return false
   */
  public boolean setXY(float x, float y) {
    if (orgX != x || orgY != y) {
      orgX = x;
      orgY = y;
      return true;
    }
    else
      return false;
  }

  public void Reset()
  {
    viewRatio = 1;
    orgX = 0.0f;
    orgY = 0.0f;
  }
}
