void instruction()
{
  timer.holdTimer();
    if(instructDuration/2 > millis() - prevMillis)
    {
    textAlign(CENTER);
    text("Shoot all ghosts before time runs out", width/2, height/2);
    instructTime.holdTimer();
    }
    else
    {
      instructTime.displayInstruct();
    }
}
