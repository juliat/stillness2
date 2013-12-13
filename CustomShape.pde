// usually one would probably make a generic Shape class and subclass different types (circle, polygon), but that
// would mean at least 3 instead of 1 class, so for this tutorial it's a combi-class CustomShape for all types of shapes
// to save some space and keep the code as concise as possible I took a few shortcuts to prevent repeating the same code
class CustomShape {
  // to hold the box2d body
  Body body;
  // to hold the Toxiclibs polygon shape
  Polygon2D toxiPoly;
  // custom color for each shape
  color col;
  // radius (also used to distinguish between circles and polygons in this combi-class
  float r;

  boolean windDirection = true;

  CustomShape(float x, float y, float r) {
    this.r = r;
    // create a body (polygon or circle based on the r)
    makeBody(x, y);
    // get a random color
    col = getRandomColor();
  }

  void makeBody(float x, float y) {
    // define a dynamic body positioned at xy in box2d world coordinates,
    // create it and set the initial values for this box2d body's speed and angle
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    body = box2d.createBody(bd);
    body.setLinearVelocity(new Vec2(random(-3, 3), random(-3, 3)));
    body.setAngularVelocity(random(-1, 1));

    // attach 4 circles to make a butterflyish shape
    int numWings = 4;
    for (int i = 0 ; i < numWings; i++) {
      // box2d circle shape of radius r
      CircleShape cs = new CircleShape();
      cs.m_radius = box2d.scalarPixelsToWorld(r);
  
  
      Vec2 offset  = new Vec2(0, 0);

      if (i == 1) {
        offset = new Vec2(0, r);
      } 
      else if (i == 2) {
        offset = new Vec2(r, 0);
      } 
      else if (i == 3) {
        offset = new Vec2(r, r);
      }
      offset = box2d.vectorPixelsToWorld(offset);
      cs.m_p.set(offset.x, offset.y);
      // tweak the circle's fixture def a little bit
      FixtureDef fd = new FixtureDef();
      fd.shape = cs;
      fd.density = 1;
      fd.friction = 0.5;
      fd.restitution = 0.5;
      // create the fixture from the shape's fixture def (deflect things based on the actual circle shape)
      body.createFixture(fd);
    }
  }

  // method to loosely move shapes outside a person's polygon
  // (alternatively you could allow or remove shapes inside a person's polygon)
  void update() {
    //if (person.stillnessDuration > (person.stillnessThreshold * person.numButterfliesAttracted)) {

    //println("attract " + attractToPerson);
    if (attractToPerson > 0) {
      attractToPoint(fakeCenter.x, fakeCenter.y);
      //println("ATTRACT");
    } 
    else if (attractToPerson < 0) {
      repelFromPoint(fakeCenter.x, fakeCenter.y);
      //println("REPEL");
    } 

    if (applyWind) {
      applyWind();
    }
    // get the screen position from this shape (circle of polygon)
    Vec2 posScreen = box2d.getBodyPixelCoord(body);

    // turn it into a toxiclibs Vec2D
    Vec2D toxiScreen = new Vec2D(posScreen.x, posScreen.y);
    // check if this shape's position is inside the person's polygon
    boolean inBody = poly.containsPoint(toxiScreen);
    // if a shape is inside the person
    if (inBody) {
      // find the closest point on the polygon to the current position
      Vec2D closestPoint = toxiScreen;
      float closestDistance = 9999999;
      for (Vec2D v : poly.vertices) {
        float distance = v.distanceTo(toxiScreen);
        if (distance < closestDistance) {
          closestDistance = distance;
          closestPoint = v;
        }
      }
      // create a box2d position from the closest point on the polygon
      Vec2 contourPos = new Vec2(closestPoint.x, closestPoint.y);
      Vec2 posWorld = box2d.coordPixelsToWorld(contourPos);
      float angle = body.getAngle();
      // set the box2d body's position of this CustomShape to the new position (use the current angle)
      body.setTransform(posWorld, angle);
    }
  }

  // display the customShape
  void display() {
    // get the pixel coordinates of the body
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    pushMatrix();
    // translate to the position
    translate(pos.x, pos.y);
    rotate(-a);
    noStroke();
    // use the shape's custom color
    fill(col);
    ellipse(0, 0, r*2, r*2);
    ellipse(0, r, r*2, r*2);
    ellipse(r, 0, r*2, r*2);
    ellipse(r, r, r*2, r*2);
    popMatrix();
  }

  // if the shape moves off-screen, destroy the box2d body (important!)
  // and return true (which will lead to the removal of this CustomShape object)
  boolean done() {
    Vec2 posScreen = box2d.getBodyPixelCoord(body);
    boolean offscreen = posScreen.y > height;
    if (offscreen) {
      box2d.destroyBody(body);
      return true;
    }
    return false;
  }

  void attractToPoint(float x, float y) {
    Vec2 worldTarget = box2d.coordPixelsToWorld(x, y);
    Vec2 bodyVec = body.getWorldCenter();
    // find the vector going from the body (the butterfly's) going to the
    // specified point
    worldTarget.subLocal(bodyVec);
    // scale the vector to the specified force
    worldTarget.normalize();

    // apply it to the body's center of bass
    body.applyForce(worldTarget, bodyVec);
  }

  void repelFromPoint(float x, float y) {
    Vec2 worldTarget = box2d.coordPixelsToWorld(x, y);
    Vec2 bodyVec = body.getWorldCenter();
    // find the vector going from the body (the butterfly's) going away from the
    // specified point
    worldTarget.addLocal(bodyVec);
    // scale the vector to the specified force
    worldTarget.normalize();

    // apply it to the body's center of bass
    body.applyForce(worldTarget, bodyVec);
  }

  void applyWind() {
    Vec2 position = box2d.getBodyPixelCoord(body);
    float randomX = random(0, width);
    float randomY = random(0, height);
    float flipY = com.y + random(0, 30);

    if (windDirection == false) {
      flipY = com.y + random(-30, 0);
    }

    Vec2 worldTarget = box2d.coordPixelsToWorld(position.x, flipY);
    Vec2 bodyVec = body.getWorldCenter();
    // find the vector going from the body (the butterfly's) going to the
    // specified point
    worldTarget.subLocal(bodyVec);
    // scale the vector to the specified force
    worldTarget.normalize();

    // apply it to the body's center of bass
    body.applyForce(worldTarget, bodyVec);

    // apply it to the body's center of bass
    body.applyForce(worldTarget, bodyVec);

    windDirection = !windDirection;
  }
}

