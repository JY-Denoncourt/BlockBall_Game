class Block {
  //Variables---------------------------------------------------------------------------------
  float x;
  float y;
  float blockWidth = 100;
  float blockHeight = 40;
  int alive;//nombre de vie du block
  color R, G;

  //Constructeur-----------------------------------------------------------------------------
  Block(float x_, float y_) {
    x=x_;
    y=y_;
    R=int(map(x, 0, width, 0, 255));
    G=int(map(y, 0, height*2/5, 0, 255));
    
    alive = (int)random(0,5); 
    //if (alive > 0) aliveBlocks++;  
  }

  //GETTER - SETTER---------------------------------------------------------------------------
  float getBlockX() { return this.x + blockWidth/2; }
  float getBlockY() { return this.y + blockHeight/2; }


  //METHODES----------------------------------------------------------------------------------
  void show() {
    if (alive > 0) {
      rectMode(CORNER);
      stroke(255);
      noStroke();
     
      fill(255);
      rect(x, y, blockWidth, blockHeight);
      fill(100,100,100);
      if (alive == 1) fill(153,255,204);
      if (alive == 2) fill(51,255,153);
      if (alive == 3) fill(0,204,102);
      if (alive == 4) fill(0,102,51);
      rect(x+2, y+2, blockWidth-4, blockHeight-4);
      
      fill(255);
      textSize(int(20));
      //text(alive, x + 20, y + 30); 
      
      if (alive > 1) //<>//
      {
        for (int i = 1; i < alive; i++)
        {
          fill(200,0,0);
          rect((x + (12*i)), (y + 10), 10, 10);
        }
      }
      
      
    }
  }
  
  
  public float right(){
    return x + blockWidth;
  }
  
}
