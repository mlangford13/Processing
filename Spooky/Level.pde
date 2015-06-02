class Level
{
  int levelTime;
  int levelNum;
  int numGhosts;
  int avoidWeight;
  int separateWeight;
  
  Level()
  {
    levelTime = 60;
    numGhosts = 10;
    levelNum = 1;
    avoidWeight = 2;
    separateWeight = 1;
  }
  
  void resetGame()
  {
    levelTime = 60;
    numGhosts = 10;
    levelNum = 1;
    avoidWeight = 2;
    separateWeight = 1;
  }
  
  void display()
  {
    textAlign(LEFT, CENTER);
    textFont(font, 90);
    text("Level " + levelNum, 50, displayHeight-50);
  }
  
  void incrementLevel()
  {
    levelNum ++;
    numGhosts += 5;
    levelTime += 5;
  }
  
  void nextLevel()
  {
    fill(211,34,34);
    textFont(font, 250);
    textAlign(CENTER);
    text("Level  "+levelNum,displayWidth/2,displayHeight/2-90); 
    textAlign(CENTER);
    text("Complete!",displayWidth/2, displayHeight/2+90);
    fill(150);
    textFont(font,72);
    text("Press 'N' to start Level "+(levelNum+1), displayWidth/2, displayHeight*.75);
    if(keyPressed)
    {
      if(key == 'n' || key == 'N')
      {
        incrementLevel();
        timer.resetTimer(levelTime);
        setup();
        start = false;
      }
    }
  } 
}
