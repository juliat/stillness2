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
    // captureVelocity();
  }
} // end person class 

/*
void trackMotion() {
  // compare blobs and lastblobs
  PImage lastFrame = lastBlobs;
  PImage thisFrame = blobs;

  if ((lastFrame == null) || (thisFrame == null)) {
    return;
  }
  // get # pixels different
  // from: http://www.learningprocessing.com/examples/chapter-16/example-16-13/
  // Begin loop to walk through every pixel
  lastFrame.loadPixels();
  thisFrame.loadPixels();
  
  int threshold = 10;
  int numPixelsDifferent = 0;
  for (int x = 0; x < thisFrame.width; x ++ ) {
    for (int y = 0; y < thisFrame.height; y ++ ) {
      
      int loc = x + y*thisFrame.width;            // Step 1, what is the 1D pixel location
      color current = thisFrame.pixels[loc];      // Step 2, what is the current color
      color previous = lastFrame.pixels[loc];     // Step 3, what is the previous color
      
      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); float g1 = green(current); float b1 = blue(current);
      float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
      float diff = dist(r1,g1,b1,r2,g2,b2);
      
      println("diff " + diff);
      
      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) { 
        numPixelsDifferent ++;
      } 
    }
  } // end nested pixel loop
  
  
  println("Num pixels different: " + numPixelsDifferent);
  // println("Time Position was Last Sampled " + timePositionWasLastSampled);
  // println("Time Between Samples " + timeBetweenSamples);
  // use this to calculate velocity/stillness
} */

