void mainGame()
{
  for(Ghost g: ghosts)
  {
    g.update();
    g.display();
    g.applyBehaviors(ghosts, level.separateWeight, level.avoidWeight);
  }
  crosshair.display();
  crosshair.update(); 
  fill(255, 100);
  textAlign(LEFT, CENTER);
  textFont(font, 125);
  text(ghostsLeft, 50,50);
  timer.display();
  level.display();
  if(explode.execute)
  {
    explode.display(explode.posX+37, explode.posY+37);
  }
}

void mousePressed()
{
 gunShot.play();
 for(int i=ghosts.size()-1; i>=0; i--)
  {
    Ghost g = ghosts.get(i);
    boolean hit = g.checkHit();
    if(hit)
    {
      ghostDeath.play();
      if(explode.execute == false)
      {
        explode.execute = true;
        explode.posX = g.location.x;
        explode.posY = g.location.y;
      }
      ghosts.remove(g);
      ghostsLeft--;
    }
  } 
}
