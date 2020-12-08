abstract class Mover implements IGraphicObject {
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  float mass;
  
  
  color strokeColor = color(200, 100, 20);
  color fillColor = color(200, 0, 0);
  
  public void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);
    acceleration.add(f);
  }
}
