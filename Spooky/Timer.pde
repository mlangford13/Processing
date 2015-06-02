class Timer
{
  int totalTime;
  int endTime;
  int holdTime;
  
  Timer(int time) // in seconds
  {
    totalTime=(time+1)*1000;
    endTime=time+1;
  }
  
  void holdTimer()
  {
    holdTime=millis();
  }
    
  void display()
  {
    int displayMinutes=endTime/60;
    int displaySeconds=endTime-(displayMinutes*60);
    
    textAlign(RIGHT, CENTER);
    if(displaySeconds<10)
      text(displayMinutes + ":0" + displaySeconds, width-50,50);
    else
      text(displayMinutes + ":" + displaySeconds, width-50,50);
  }
  
  void displayInstruct()
  {
    int displayMinutes=endTime/60;
    int displaySeconds=endTime-(displayMinutes*60);

    textAlign(CENTER);
    textFont(font, 125);
    text(displaySeconds, width/2,height/2);
    endTime=(totalTime-(millis()-holdTime))/1000;
  }
  
  boolean timesUp()
  {
    endTime = (totalTime-(millis()-holdTime))/1000;
    if(endTime<1)
      return true;
    else
      return false;
  }
  
  void clearTimer()
  {
    totalTime = 0;
    endTime = 0;
    holdTime = 0;
  }
  
  void resetTimer(int newTime) // in seconds
  {
    totalTime = (newTime+1)*1000;
    endTime = newTime +1;
    holdTime = millis();
  }
}
  
