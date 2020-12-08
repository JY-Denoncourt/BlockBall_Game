class ParticleSystem implements IGraphicObject{
  
  //VARIABLES--------------------------------------------------------------------------------------
  ArrayList<Particle> particles;
  
  int nbParticles = 10;
  
  boolean resetAfterDead = false; 
  
  
  //CONSTRUCTORS-----------------------------------------------------------------------------------
  ParticleSystem(int nbP) {
    particles = new ArrayList<Particle>();
    nbParticles = nbP;
    
  }
  
  
  //METHODE-----------------------------------------------------------------------------------------
  void setupP(int x, int y) {
    for (int i = 0; i < nbParticles; i++) {
      particles.add (new Particle(new PVector (x, y)));
    }
  }
  
  
  void applyForce (PVector force) {
    for (Particle p : particles) {
      if (!p.isDead()) {
        p.applyForce (force);
      }
    }
  }
  
  void update (int delta) {
    for (Particle p : particles) {
      if (p.isDead()) {
        
        if (resetAfterDead)
          p.reset();
      }
      
     p.update(delta);
    }
  }
  
  void display(color c) {
    for (Particle p : particles) {
      p.display(c);
    }
  }
  
  void display(){}
  
  void setInitialSpeed(PVector velocity) {
    for (Particle p : particles) {
      
    }    
  }
  
  void resetAll() {
    for (Particle p : particles) {
      p.reset();
    }
  }
  
  boolean isAllDead() {
    boolean result = true;
    
    for (Particle p : particles) {
      result = result && p.isDead();
      if (!result) {
        break;
      }
    }
    
    return result;
  }

}
