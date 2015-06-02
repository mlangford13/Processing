/*
 * Mouse & keyboard input here.
 */

void mouseWheel(MouseEvent e)
{
  float wmX = wvd.pixel2worldX(mouseX);
  float wmY = wvd.pixel2worldY(mouseY);
  
  wvd.viewRatio -= e.getAmount() / 20;
  wvd.viewRatio = constrain(wvd.viewRatio, 0.05, 200.0);
  
  wvd.orgX = wmX - mouseX / wvd.viewRatio;
  wvd.orgY = wmY - mouseY / wvd.viewRatio;
}

// Panning
void mouseDragged() {
  if(gameState == GameState.PAUSED)
  {
    wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
    wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;
  }
}


//Check for keypresses
void keyPressed() 
{
  if(key == 'r')    //Reset zoom DEBUG ONLY
  {
    wvd.Reset();
  }

  if(key == 'p' || key == 'P')
  {
    if(gameState == GameState.PLAY)
    {
      gameState = GameState.PAUSED;
    }
    else if(gameState == GameState.PAUSED)
    {
      gameState = GameState.PLAY;
    }
  }

  
  //ENGINE DEBUG CONTROLS
  if(key == 'h' || key == 'H')
  {
    if(playerShip.leftEnginePower > playerShip.minThrust)
    {
      playerShip.leftEnginePower -= 1;
    }
    else
    {
      playerShip.leftEnginePower = playerShip.minThrust;
    }
  }
  if(key =='y' || key == 'Y')
  {
    if(playerShip.leftEnginePower < playerShip.maxThrust)
    {
      playerShip.leftEnginePower += 1;
    }
    else
    {
      playerShip.leftEnginePower = playerShip.maxThrust;
    }
  }
  if(key == 'k' || key == 'K')
  {
    if(playerShip.rightEnginePower > playerShip.minThrust)
    {
      playerShip.rightEnginePower -= 1;
    }
    else
    {
      playerShip.rightEnginePower = playerShip.minThrust;
    }
  }
  if(key =='i' || key == 'I')
  {
    if(playerShip.rightEnginePower < playerShip.maxThrust)
    {
      playerShip.rightEnginePower += 1;
    }
    else
    {
      playerShip.rightEnginePower = playerShip.maxThrust;
    }
  }

  //WEAPON DEBUG CONTROLS
  if(key == 'q' || key == 'Q')    //Cycle targets
  {
    playerShip.SelectNextTarget();
  }
  if(key == 'e' || key == 'E')    //Cycle targets
  {
    playerShip.FireAtTarget();
  }
  
  //Start menu options
  if(key == 's' || key == 'S')
  {
    sPressed=true;
  }
  if(key == 'm' || key == 'M')
  {
    mPressed=true;
  }
  if(key == 'n' || key == 'N')
  {
    instructionNumber++;
  }

  //Game over restart
  if(gameState == GameState.GAMEOVER)
  {
    if(keyCode == ENTER)
    {
      restartFlag = true;
    }
  }


}
