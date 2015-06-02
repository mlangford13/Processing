void endGame()
{
 if(key=='r' || key=='R')
 {
   level.resetGame();
   timer.resetTimer(level.levelTime);
   setup();
 }
 else
 {
   fill(211,34,34);
   textFont(font, 250);
   textAlign(CENTER);
   text("GAME",displayWidth/2,displayHeight/2-90); 
   textAlign(CENTER);
   text("OVER",displayWidth/2, displayHeight/2+90);
   fill(150);
   textFont(font,72);
   text("Press 'R' for Main Menu", displayWidth/2, displayHeight*.75);
   
 }
   
}
