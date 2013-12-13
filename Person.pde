// the thing or individual which is moving, to which the butterflies react
// largely tracks motion
class Person {
  float currentVelocity = 0;
  float averageVelocity = 0;
  float cumulativeVelocity = 0;

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
    captureVelocity();
    updateAverageVelocity();
  }
  // get the difference between the last position recorded
  // and this one to figure out velocity
  void captureVelocity() {
    float distance = dist(com.x, com.y, lastCOM.x, lastCOM.y);
    println("com x " + com.x + "com y " + com.y);
    println("last com x " + lastCOM.x + " last com y " + lastCOM.y);
    println("distance " + distance);
    float velocity = distance/timeBetweenSamples;
    cumulativeVelocity += velocity;
    numVelocitiesCaptured++;
    currentVelocity = velocity;

    // if not moving
    if (velocity == 0.0) {
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

  void updateAverageVelocity() {
    float newAverage = cumulativeVelocity / numVelocitiesCaptured;
    println("new average " + newAverage);
    averageVelocity = newAverage;
  }
} // end person class 


