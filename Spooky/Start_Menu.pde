

void startMenu()
{
 if(key=='s' || key=='S')
 {
   start=false;
   instruct = true;
 }
 else
 {
   fill(211,34,34);
   textFont(font, 250);
   textAlign(RIGHT);
   text("Ghost",displayWidth/2+100,displayHeight/2-90); 
   textAlign(CENTER);
   text("Killer",displayWidth/2+100, displayHeight/2+90);
   fill(150);
   textFont(font,72);
   text("Press 'S' to start", displayWidth/2, displayHeight*.75);
 }
   
}
