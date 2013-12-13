// Kinect Physics Example by Amnon Owed (15/09/12)

// import libraries
import processing.opengl.*; // opengl
import SimpleOpenNI.*; // kinect
import blobDetection.*; // blobs
import toxi.geom.*; // toxiclibs shapes and vectors
import toxi.processing.*; // toxiclibs display
import pbox2d.*; // shiffman's jbox2d helper library
import org.jbox2d.collision.shapes.*; // jbox2d
import org.jbox2d.common.*; // jbox2d
import org.jbox2d.dynamics.*; // jbox2d

import gab.opencv.*; // opencv

import java.util.Collections;


// declare SimpleOpenNI object
SimpleOpenNI context;
// declare BlobDetection object
BlobDetection theBlobDetection;
// ToxiclibsSupport for displaying polygons
ToxiclibsSupport gfx;
// declare custom PolygonBlob object (see class for more info)
PolygonBlob poly;

// PImage to hold incoming imagery and smaller one for blob detection
PImage cam;
PImage blobs;

// the kinect's dimensions to be used later on for calculations
int kinectWidth;
int kinectHeight;
// to center and rescale from 640x480 to higher custom resolutions
float reScale;

Person person = new Person();

PVector com = new PVector();   
PVector lastCOM = new PVector(0, 0);
PVector com2d = new PVector();                                   

// background and blob color
color bgColor, blobColor;
// three color palettes (artifact from me storing many interesting color palettes as strings in an external data file ;-)
String[] palettes = {
  "-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634", 
  "-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031", 
  "-1978728,-724510,-15131349,-13932461,-4741770,-9232823,-3195858,-8989771,-2850983,-10314372"
};
color[] colorPalette;

// the main PBox2D object in which all the physics-based stuff is happening
PBox2D box2d;
// list to hold all the custom shapes (circles, polygons)
ArrayList<CustomShape> polygons = new ArrayList<CustomShape>();

int numFrames = 0;
boolean applyWind = false;
int attractToPerson = -1; // -1 = repel, 1 = attract, 0 = neutral

void setup() {
  int wWidth = 640;
  int wHeight = 320;
  kinectWidth = wWidth;
  kinectHeight = wHeight;
  // it's possible to customize this, for example 1920x1080
  size(wWidth, wHeight, OPENGL);
  context = new SimpleOpenNI(this);
  // initialize SimpleOpenNI object
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }
  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();
  // calculate the reScale value
  // currently it's rescaled to fill the complete width (cuts of top-bottom)
  // it's also possible to fill the complete height (leaves empty sides)
  reScale = (float) width / kinectWidth;
  // create a smaller blob image for speed and efficiency
  blobs = createImage(kinectWidth/3, kinectHeight/3, RGB);
  // initialize blob detection object to the blob image dimensions
  theBlobDetection = new BlobDetection(blobs.width, blobs.height);
  theBlobDetection.setThreshold(0.2);
  // initialize ToxiclibsSupport object
  gfx = new ToxiclibsSupport(this);
  // setup box2d, create world, set gravity
  box2d = new PBox2D(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  // set random colors (background, blob)
  setRandomColors(1);
}

void draw() {
  background(bgColor);
  // update the SimpleOpenNI object
  context.update();

  // get the users center of mass if it's available
  attractToPerson = 0; // neutral by default for when kinect is janky
  int[] userList = context.getUsers();
  for (int i=0;i<userList.length;i++)
  {
    // store the center of mass
    if (context.getCoM(userList[i], com))
    {
      context.convertRealWorldToProjective(com, com2d);
      // this will break with more than one person right now

      // this will track motion
      // only track if kinect isn't freaking out, though
      person.update();
    }
  } 
     
  
  // put the image into a PImage
  cam = context.userImage().get();
  // display the image
  // image(cam, 0, 0);

  // copy the image into the smaller blob image
  blobs.copy(cam, 0, 0, cam.width, cam.height, 0, 0, blobs.width, blobs.height);
  // blur the blob image
  blobs.filter(BLUR, 1);

  // select only the blue pixels - person
  blobs = grabBluePixels(blobs);  

  // detect the blobs
  theBlobDetection.computeBlobs(blobs.pixels);
  // initialize a new polygon
  poly = new PolygonBlob();
  // create the polygon from the blobs (custom functionality, see class)
  poly.createPolygon();
  // create the box2d body from the polygon
  poly.createBody();
  // update and draw everything (see method)
  updateAndDrawBox2D();
  // destroy the person's body (important!)
  poly.destroyBody();
  // set the colors randomly every 240th frame
  // setRandomColors(240);
  numFrames++;
}

void updateAndDrawBox2D() {
  // if frameRate is sufficient, add a circle
  if (frameRate > 29) {
    float randomX = random(0, kinectWidth);
    float randomY = random(0, kinectHeight);
    polygons.add(new CustomShape(randomX, randomY, 5));
  }
  
  // update stuff for shapes
  if (numFrames%2 == 0) {
    applyWind = !applyWind;
  }
  
  // take one step in the box2d physics world
  box2d.step();

  // center and reScale from Kinect to custom dimensions
  translate(0, (height-kinectHeight*reScale)/2);
  scale(reScale);

  // display the person's polygon  
  noStroke();
  fill(blobColor);
  gfx.polygon2D(poly);


  // display all the shapes (circles, polygons)
  // go backwards to allow removal of shapes
  for (int i=polygons.size()-1; i>=0; i--) {
    CustomShape cs = polygons.get(i);
    // if the shape is off-screen remove it (see class for more info)
    if (cs.done()) {
      polygons.remove(i);
      // otherwise update (keep shape outside person) and display (circle or polygon)
    } 
    else {
      cs.update();
      cs.display();
    }
  }
}

// sets the colors every nth frame
void setRandomColors(int nthFrame) {
  if (frameCount % nthFrame == 0) {
    // turn a palette into a series of strings
    String[] paletteStrings = split(palettes[int(random(palettes.length))], ",");
    // turn strings into colors
    colorPalette = new color[paletteStrings.length];
    for (int i=0; i<paletteStrings.length; i++) {
      colorPalette[i] = int(paletteStrings[i]);
    }
    // set background color to first color from palette
    bgColor = color(255);//colorPalette[0];
    // set blob color to second color from palette
    blobColor = color(0, 0, 255);//colorPalette[1];
    // set all shape colors randomly
    for (CustomShape cs: polygons) { 
      cs.col = getRandomColor();
    }
  }
}

// returns a random color from the palette (excluding first aka background color)
color getRandomColor() {
  return colorPalette[int(random(1, colorPalette.length))];
}

PImage grabBluePixels(PImage source) {
  PImage destination = createImage(source.width, source.height, RGB);
  // We are going to look at both image's pixels
  source.loadPixels();
  destination.loadPixels();

  for (int x = 0; x < source.width; x++) {
    for (int y = 0; y < source.height; y++ ) {
      int loc = x + y*source.width;
      // Check for non-grey
      if (blue(source.pixels[loc]) != red(source.pixels[loc])) {
        destination.pixels[loc]  = color(0);  // Blk
      }  
      else {
        destination.pixels[loc]  = color(255);    // White
      }
    }
  }

  // We changed the pixels in destination
  destination.updatePixels(); 

  return destination;
}

