class Ball {
  
  //Vartiable---------------------------------------------------------------------------------------------------
  PVector location;
  PVector speed;
 
  float r = 8;
  boolean ballDrop = false;
  boolean isPadCollision = false;
  boolean isBlockCollision = false;
  boolean isExplode = false;
  
  //Constructeur------------------------------------------------------------------------------------------------
  Ball() {
    location = new PVector(width/2, height/2);
    speed=new PVector(0, 0);
  }


  //GETTER SETTER----------------------------------------------------------------------------------------------
   void setSpeed(int x, int y) {
    speed.x  = x;
    speed.y = y;
  }
  
  boolean getBallDrop() { return ballDrop; }
  
  boolean getIsPadCollision() { return isPadCollision; }
  void setIsPadCollision(boolean set) { isPadCollision = set; }
  
  boolean getIsBlockCollision() { return isBlockCollision; }
  void setIsBlockCollision(boolean set) { isBlockCollision = set; }
  
  void setBallDrop(boolean status) { ballDrop = status; }


  //Methode affichage-------------------------------------------------------------------------------------------
  void show() {
    noStroke();
    fill(255,0,0);

    ellipseMode(CENTER);
    ellipse(location.x, location.y, r*2, r*2);
    point(location.x, location.y);
  }


  void edges() {
    if (location.y<0+r) {
      speed.y=speed.y*-1;
    }
    if (location.x>width-r){
      speed.x=speed.x*-1; 
    }
    else if(location.x<r){
      speed.x=speed.x*-1;
    }
    
    if (location.y > height)
    {
      ballDrop = true;
    }
  } 

  

  void update() {
    location.add(speed);
    edges();
  }
  
  
  void resetPos() {
    location.x = width / 2;
    location.y = height / 2;
    speed.x = 0;
    speed.y = 0;
  }
  
 

  
  //Methodes Collision------------------------------------------------------------------------------------------------               
  void padCollision(Player pad) {
    //Si ball collisionne Droit part vers la droite selon angle.
    //Si ball collisionne Gauche part vers la gauche selon angle.
    if ( (location.x > pad.x - 50) && (location.x < pad.x + 50) ) {
      if ( (location.y + r > pad.y - pad.padHeight/2) && (location.y < pad.y + pad.padHeight/2) ) {
        isPadCollision = true;
        
        float diff = location.x - (pad.x - 50);
        float rad = radians(45);
        float angle = map(diff, 0, 100, -rad*3/2, rad*3/2);

        speed.x = 4*sin(angle);
        speed.y = -4*cos(angle);
        collisionSound.play();
      }
    }
  }
  
  
  void blockCollision(Block block) {
    if (block.alive < 1) return;
    
    rectMode(CORNER);
    if (speed.x > 0) {
      if ( (location.y > block.y) && (location.y < block.y + block.blockHeight) ) {
        if ( (location.x + r > block.x) && (location.x - r < block.x + block.blockWidth) ) {
          location.x -= 3;
          speed.x = speed.x * -1;
          
          collisionSet(block);
        }
      }
    } 
    else if (speed.x < 0) {
      if ( (location.y > block.y) && (location.y < block.y + block.blockHeight) ) {
        if ( (location.x - r < block.x + block.blockWidth) && (location.x + r > block.x) ) {
          location.x += 3;
          speed.x = speed.x * -1;
          
          collisionSet(block);
        }
      }
    }

    if (speed.y > 0) {
      if ( (location.x > block.x) && (location.x < block.x + block.blockWidth) ) {
        if ( (location.y + r > block.y) && (location.y - r < block.y + block.blockHeight) ) {
          location.y -= 3;
          speed.y=speed.y * -1;
          
          collisionSet(block);
        }
      }
    } else if (speed.y < 0) {
      if ( (location.x > block.x) && (location.x < block.x + block.blockWidth) ) {
        if ( (location.y - r < block.y + block.blockHeight) && (location.y + r > block.y) ) {
          location.y += 3;
          speed.y = speed.y * -1;
         
          collisionSet(block);
        }
      }
    }
  }
 
 //Methodes Controlle--------------------------------------------------------------------------------------------------
 void collisionSet(Block block) {
   isBlockCollision = true;
   collisionSound.play();
   block.alive--;
   if (block.alive == 0){
     aliveBlocks--;
     score += 100;
     isExplode = true;
   }
  
   score += 20;
   counter++;
   
 }
 
}
