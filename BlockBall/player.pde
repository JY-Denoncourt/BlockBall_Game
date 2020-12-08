class Player {
  //Variable du player--------------------------------------------------------------------------
  float x;
  float y = height - 30;
  int padWidth = 100;
  int padHeight = 15;


  //CONSTRUCTEUR--------------------------------------------------------------------------------
  Player() {
    x = width/2;
  }

  
  //GETTER - SETTER-----------------------------------------------------------------------------
  void setX(int x) { this.x = x; }
  float getPadX() { return this.x; }
  float getPadY() { return this.y; }
  int getPadwidth() { return padWidth; }
  int getPadheight() { return padHeight; }
  
  //METHODE AFFICHAGE---------------------------------------------------------------------------
  void show() {
    fill(255);
    rectMode(CENTER);
    stroke(255);
    rect(x, y, padWidth, padHeight);
  }


  void edges() {
    if (x - padWidth/2 < 0) {
      x = padWidth/2;
    }
    
    if (x + padWidth/2 > width) {
      x = width - padWidth/2;
    }
  }
  
  
  
  //METHODES CONTROLE---------------------------------------------------------------------------
  
  //Contral par mouse
  void moving(float x) {
    this.x = x;
    
    edges();
  }
  
  
  //Control par <-- -->
  void leftMove(float X) {
    x -= X;
    edges();
  }
  void rightMove(float X) {
    x += X;
    edges();
  }
  
  
  
  void resetPos() {
    x = width/2;
    y = height-30;
  }
  
}
