// the thing or individual which is moving, to which the butterflies react
// largely tracks motion
class Person {

  int startStillnessTime = 0;
  int stillnessDuration = 0;
  int stillnessThreshold = 10;

  int timePositionWasLastSampled = 0;
  int timeBetweenSamples = 0;
  int numVelocitiesCaptured = 0;

  int numButterfliesAttracted = 0;

  void update() {
    timeBetweenSamples = millis() - timePositionWasLastSampled;
    timePositionWasLastSampled = millis();
    captureMotion();
    printDebug();
  }
  // get the difference between the last position recorded
  // and this one to figure out velocity
  void captureMotion() {
    float distance = dist(com.x, com.y, lastCOM.x, lastCOM.y);
    println("com x " + com.x + "com y " + com.y);
    println("last com x " + lastCOM.x + " last com y " + lastCOM.y);
    println("distance " + distance);
    float velocity = distance/timeBetweenSamples;

    // if not movin
    float jitterThreshold = 3;
    if (distance < jitterThreshold) {
      // and was moving before
      if (stillnessDuration < 1) {
        // record time
        startStillnessTime = millis();
        stillnessDuration = 1;
        //  attractButterflies();
        // wasn't moving before
      } 
      else {
        // update time since last motion
        stillnessDuration = millis() - startStillnessTime;
      }
      // moving
    } 
    else {
      // reset stillness time
      stillnessDuration = 0;
      // and numButterfliesAttracted
      numButterfliesAttracted = 0;
    }
    lastCOM = new PVector(com.x, com.y);
  }
  
  void printDebug() {
    println("Time Position was Last Sampled " + timePositionWasLastSampled);
    println("Time Between Samples " + timeBetweenSamples);
   
    println("Stillness Duration " + stillnessDuration);
    println("Start Stillness Time " + startStillnessTime);
    
    // println("Number of Butterflies Attracted " + numButterfliesAttracted);
    // println("Num Bs and Stillness Thresh " + (numButterfliesAttracted*stillnessThreshold));
  }

} // end person class 


