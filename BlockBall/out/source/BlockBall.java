import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class BlockBall extends PApplet {

//VARIABLES
  //Variable des class-----------------------------------------------------------------------
  Player p1;    //Barre en bas
  Ball b1;      //Ball du jeux
  Level lv1;    //A venir*********


  //Variables globale jeux----------------------
  int currentTime;
  int previousTime;
  int deltaTime;
  float movingSpeed = 1;     //Vitesse de la barre en bas
  float ballspeed = 1;       //Vitesse de la balle
  int maxLives = 3;          //Nb balle maximale en debut partie
  int gameLive;              //Nb de balle restante en cours de partie
  int currentLvl = 0;        //Lvl en cours     A venir********   
  int Width = 1200;
  int Height = 720;
  ArrayList<Background> bgLayers; 


  //Variables du menu---------------------------
  int score=0;

  enum State {menuStart, menuSetting, inGameOn, inGameOff, endGame, gameOver};
  State gameState = State.menuStart;                      //Setter etat du jeu a menu en partant
  boolean btn_enter = false;
  boolean btn_left = false;
  boolean btn_right = false;
  boolean btn_s = false;
  boolean btn_e= false;
  boolean btn_space = false;


  //section level
  Block[] blocks = new Block[300];
    
  int cols;
  int rows;
  int numBlocks;

    int aliveBlocks = 0;
    int deadBlocks = 0;
    int counter = 0;
  //************

  public void settings() {
    //fullScreen(P2D);
    size(Width, Height, P2D);
  }
//end


//SETUP-----------------------------------------------------------------------------------
  public void setup() {
    currentTime = millis();
    previousTime = currentTime;
    
    //Creation des objets
    p1 = new Player();
    b1 = new Ball();
    
    
    //Initialisation jeu
    gameLive = maxLives;
    loadBackgroundLayers();
    
    
    //Section level
    cols = (int) width / 60;
    rows = 8;
    numBlocks = rows * cols;   

    int index=0;
    for (int i=0; i<cols; i++) 
    {
      for (int j=0; j<rows; j++) 
      {
        blocks[index] = new Block(i * 60, j * 40);

        if (blocks[index].alive > 0) 
        {
          aliveBlocks++;
        } 
        else 
        {
          deadBlocks++;
        }      
        index++;
      }
    }
    //****************
    
  }
//end


//BOUCLE DE JEU---------------------------------------------------------------------------
  public void draw() {
    currentTime = millis();
    deltaTime = currentTime - previousTime;
    previousTime = currentTime;
    
    switch (gameState)
    {
      //(OK)  Menu de depart
      case menuStart :   
          background(100, 100, 0);
          textSize(PApplet.parseInt(50));
          text("BlockBall Game", 500 , 100); 
          text("Press ENTER to start", 50, 300);
          text("Press s to option menu", 50, height-50);
          textSize(30);
          text("Press SPACE to launch the ball", 50, 460);
          text("Press RIGHT to move right", 50, 500);
          text("Press LEFT to move left", 50, 540);
          
          //lv1 = new Level();
          
          //Gestion des controles
          b1.setBallDrop(false);
          if (btn_enter) {
            gameState = State.inGameOff;
            btn_enter = false;
          }
          else if (btn_s) {
            gameState = State.menuSetting;
            btn_s = false;
          }
        
          break;
          
      //=================================================
      
      //(OK) Menu setting  ***************A venir*******************
      case menuSetting :            
          background(100, 100, 0);
          textSize(PApplet.parseInt(50));
          text("Setting", 500 , 100); 
          
          
          textSize(30);
          text("Press e to exit and return to menu", 50, 460);
          if (btn_e) {
            gameState = State.menuStart;
            btn_e = false;
          }

          break;
          
      //=================================================
      
      //(OK) Partie commencer avec ball en jeux
      case inGameOn :     
          //background(0);
          for (Background bg : bgLayers) {
            bg.display();
          }  
          
          showGameStat();
          p1.show();
          b1.show();
          b1.update();
          
          
          
          //Eventuellement remplacer par un level
          for (int i = 0; i < numBlocks; i++)   
            blocks[i].show();
          
          //Regarder les collision
          b1.padCollision(p1);
          for (int i=0; i<numBlocks; i++) b1.blockCollision(blocks[i]);
          
          //Si la ball a tombe
          if (b1.getBallDrop()) gameState = State.inGameOff;
          
          
          checkWinGame();
          break;
        
      //=================================================
      
      //(OK)  Partie commencer mais ball pas en jeux
      case inGameOff :     
          //background(0);
          for (Background bg : bgLayers) {
            bg.display();
          }  
          
          showGameStat();
          for (int i = 0; i < numBlocks; i++)   
            blocks[i].show();
          p1.show();
          p1.resetPos();
          b1.show();
          b1.update();
          b1.resetPos();
          loseBallText(); 
          
          

          //Si on arrive en cet etat par la perte balle
          if (b1.getBallDrop()) {
            b1.setBallDrop(false);
            
            if (gameLive <= 0) gameState = State.gameOver; 
            else gameLive --;
          }
        
          //Si presse Space pour relancer balle
          if (btn_space) {
            btn_space = false;
            b1.setBallDrop(false);
            b1.setSpeed(0,5);
            gameState = State.inGameOn;
          }
          
          break;
        
        //=================================================  
        
        //(OK)  Menu de la partie terminer en perdant
        case gameOver :       //Si la partie est terminer
          background(0, 100, 100);
          textSize(PApplet.parseInt(50));
          text("BlockBall Game", 500 , 100); 
          text("Game Over", 50, 300);
          textSize(30);
          text("Press Enter to return to main menu", 50, 460);
            
          //Si presse ENTER pour revenir menu depart
          if (btn_enter) {
            btn_enter = false;
            gameState = State.menuStart;
            resetGame();
          }
              
          break;
        
        //=================================================  
        
        //(OK)  Menu de la partie terminer en gagnant
        case endGame :          
          background(100, 100, 100);
          
          //Si presse ENTER pour revenir menu depart
          if (btn_enter) {
            btn_enter = false;
            gameState = State.menuStart;
            resetGame();
          }
        
          break;
        
        //=================================================    
          
        default :
          break;
    }
    
    
    update(deltaTime);
  }
//end
 
 
//Methode control---------------------------------------------------------------------------
  public void keyReleased() {
    if (keyCode == ENTER) btn_enter = true;
    if (key == 's') btn_s = true;
    if (key == 'e') btn_e = true;
    if ((key == ' ') && (gameState == State.inGameOff) ) btn_space = true;
    
  }

  public void mouseMoved(){
    if (gameState == State.inGameOn)
      p1.moving(mouseX);
    
    float w = width/2;
    
  
    if (mouseX < width / 2){
      w += mouseX; 
      bgLayers.get(2).position.x = w * 0.25f;
      bgLayers.get(1).position.x = w * 0.5f;
      //bgLayers.get(0).position.x = w * 0.75;
    }
    else {
      w += mouseX;
      bgLayers.get(2).position.x = w * 0.25f;
      bgLayers.get(1).position.x = w * 0.5f;
      //bgLayers.get(0).position.x = w * 0.75;
    }
   
    
          
      
    
      
  }

  public void keyPressed() {
    //if ((keyCode == LEFT) && (gameState == State.inGameOn) ) btn_left = true;
    //if ((keyCode == RIGHT) && (gameState == State.inGameOn) ) btn_right = true;
  }
//end


//Methode AFFICHAGE-------------------------------------------------------------------------

  //Affichage dans le jeux principale (nb ball, scrore)
  public void showGameStat() {
    fill(255);
    textSize(15);
    text("Live : ", 10, height-5);
    text( gameLive, 70, height-5);
    //text("SCORE:", width-120, height-15);
    //text( score, width-50, height-15);
    
  }


  //Affichage quand perd une balle et de presser ENTRER to start ball
  public void loseBallText() {
    textSize(30);
    //text(" life -1 ", width/2-137, height - 100);
    text(" Hit SPACE to launch new ball ", width/2-137, height - 150);
  }


  //Affichage quand la partie est gagner
  public void winGame() {
    noStroke();
    fill(120, 120, 0);
    rect(0, 0, width, height);
    fill(255);
    textSize(43);
    text("Press SPACEBAR to start again", 147, 450);
    textSize(30);
    text("You win", width/2-75, height/2);
  }
//end


//METHODE UTILITAIRES--------------------------------------------------------------------------
  //Regarde si il reste des blocks vivants
  public void checkWinGame() {
    if (aliveBlocks == 0) {
    //A faire **************
    }
  }


  //Sert a remettre game a valeur de depart
  public void resetGame() {
    gameLive = maxLives;
    //currentLvl = 0;      *******A Venir********************
    resetBlocks();
    counter = 0;
  }


  //Sert a reseter la game de block    ************TEMPORAIRE va changer avec level*********************
  public void resetBlocks() {
    aliveBlocks = 0;
    for (int index = 0; index < numBlocks; index++) {

      blocks[index].alive= -1 + (int)random(2) * 2;
      if (blocks[index].alive > 0) {
        aliveBlocks++;
      }
    }
  }
//end



//METHODES PARALLAX-----------------------------------------------------------------------------
  private void loadBackgroundLayers() {
    bgLayers = new ArrayList<Background>();
    bgLayers.add( new Background("forest4.png"));
    bgLayers.add( new Background("forest3.png"));
    bgLayers.add( new Background("forest2.png"));
    bgLayers.add( new Background("forest1.png"));
  
    //float speedIncrement = 0.25;
    //float currentSpeed = 1;
    
    
    for (int i = 0; i < bgLayers.size(); i++) {
      Background current = bgLayers.get(i);
      
      if (i > 1) {      
        current.isParallax = true;
        current.velocity.x = 0;
        //currentSpeed += speedIncrement;
      } 
      
      current.scale = 0.5f;
    }
  }


  public void update(int delta) {
  
    for (Background bg : bgLayers) {
      bg.update(delta);
    }
  }
//end
class Background implements IActable {
  
  PImage img;
  float scale = 1.0f;
  PVector position;
  PVector velocity;
    
  boolean isParallax = false;
 
  Background (String imgPath) {
    img = loadImage(imgPath);
    initValues();
    img.resize(width, height);
  }
  
  Background (PImage img) {
    this.img = img;
    initValues();
  }
  
  private void initValues() {
    position = new PVector();
    velocity = new PVector();
  }
  
  
  public void update(int deltaTime) {
    position.add(velocity);
    position.x = position.x % width;
  }
  
  float posX;
  float posY;
  
  public void display () {
    
    image (img, position.x, position.y, img.width, img.height);

    if (isParallax) {
      if (position.x < 0) {
        image (img, (position.x + img.width), position.y, img.width, img.height);
      } else if (position.x + img.width > width) {
        image (img, (position.x - img.width), position.y, img.width, img.height);
      }
    }
  }
}
class Ball {
  
  //Vartiable---------------------------------------------------------------------------------------------------
  PVector location;
  PVector speed;
 
  float r = 8;
  boolean ballDrop = false;
 

  //Constructeur------------------------------------------------------------------------------------------------
  Ball() {
    location = new PVector(width/2, height/2);
    speed=new PVector(0, 0);
  }


  //GETTER SETTER----------------------------------------------------------------------------------------------
   public void setSpeed(int x, int y) {
    speed.x  = x;
    speed.y = y;
  }
  
  public boolean getBallDrop() { return ballDrop; }
  public void setBallDrop(boolean status) { ballDrop = status; }


  //Methode affichage-------------------------------------------------------------------------------------------
  public void show() {
    noStroke();
    fill(255,0,0);

    ellipseMode(CENTER);
    ellipse(location.x, location.y, r*2, r*2);
    point(location.x, location.y);
  }


  public void edges() {
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

  

  public void update() {
    location.add(speed);
    edges();
  }
  
  
  public void resetPos() {
    location.x = width / 2;
    location.y = height / 2;
    speed.x = 0;
    speed.y = 0;
  }
  
 

  
  //Methodes Collision------------------------------------------------------------------------------------------------               
  public void padCollision(Player pad) {
    
    //Si ball collisionne Droit part vers la droite selon angle.
    //Si ball collisionne Gauche part vers la gauche selon angle.
    if ( (location.x > pad.x - 50) && (location.x < pad.x + 50) ) {
      if ( (location.y + r > pad.y - pad.padHeight/2) && (location.y < pad.y + pad.padHeight/2) ) {
        float diff = location.x - (pad.x - 50);
        float rad = radians(45);
        float angle = map(diff, 0, 100, -rad*3/2, rad*3/2);

        speed.x = 4*sin(angle);
        speed.y = -4*cos(angle);
      }
    }
  }
  
  
  public void blockCollision(Block block) {
    rectMode(CORNER);
    if (block.alive == 1) {
      if (speed.x > 0) {
        if ( (location.y > block.y) && (location.y < block.y + block.blockHeight) ) {
          if ( (location.x + r > block.x) && (location.x - r < block.x + block.blockWidth) ) {
            location.x -= 3;
            speed.x = speed.x * -1;
            block.alive--;
            aliveBlocks--;
            deadBlocks++;
            //score+=20;
            counter++;
          }
        }
      } 
      else if (speed.x < 0) {
        if ( (location.y > block.y) && (location.y < block.y + block.blockHeight) ) {
          if ( (location.x - r < block.x + block.blockWidth) && (location.x + r > block.x) ) {
            location.x += 3;
            speed.x = speed.x * -1;
            block.alive--;
            aliveBlocks--;

            deadBlocks++;
            //score+=20;
            counter++;
          }
        }
      }

      if (speed.y > 0) {
        if ( (location.x > block.x) && (location.x < block.x + block.blockWidth) ) {
          if ( (location.y + r > block.y) && (location.y - r < block.y + block.blockHeight) ) {
            location.y -= 3;
            speed.y=speed.y * -1;
            block.alive--;
            aliveBlocks--;
            deadBlocks++;
            //score+=20;
            counter++;
          }
        }
      } else if (speed.y < 0) {
        if ( (location.x > block.x) && (location.x < block.x + block.blockWidth) ) {
          if ( (location.y - r < block.y + block.blockHeight) && (location.y + r > block.y) ) {
            location.y += 3;
            speed.y = speed.y * -1;
            block.alive--;
            aliveBlocks--;
            deadBlocks++;
            //score+=20;
            counter++;
          }
        }
      }
    }
  }
 
 //Methodes Controlle--------------------------------------------------------------------------------------------------
}
class Block {
  //Variables---------------------------------------------------------------------------------
  float x;
  float y;
  float blockWidth=60;
  float blockHeight=40;
  int alive = -1 + (int)random(2) * 2;
  int R, G;

  //Constructeur-----------------------------------------------------------------------------
  Block(float x_, float y_) {
    x=x_;
    y=y_;
    R=PApplet.parseInt(map(x, 0, width, 0, 255));
    G=PApplet.parseInt(map(y, 0, height*2/5, 0, 255));
  }

  public void show() {
    if (alive>0) {
      rectMode(CORNER);
      stroke(255);
      noStroke();
      fill(255);

      rect(x, y, blockWidth, blockHeight);
      fill(R, G, 0);
      rect(x+2, y+2, blockWidth-4, blockHeight-4);
    }
  }
  
  
}
interface IActable {

  public abstract void update(int deltaTime);
  public abstract void display();
}
class Rectangle {
  

  
 
  
  
  
  
}
class Level {
  //Variable de chaque level--------------------------------------------------------------------------------
  Block[] blocks = new Block[300];
  int cols;
  int rows;
  int numBlocks;
  
  int aliveBlocks = 0;
  int deadBlocks = 0;
  int counter = 0;
  
  //Constructors-----------------------------------------------------------------------------------------
  Level () {
    cols = 20;
    rows = 8;
    numBlocks = rows * cols; 
  }
  
    
  
}
class Player extends Rectangle {
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
  public void setX(int x) { this.x = x; }
  public float getPadX() { return this.x; }
  public float getPadY() { return this.y; }
  public int getPadwidth() { return padWidth; }
  public int getPadheight() { return padHeight; }
  
  //METHODE AFFICHAGE---------------------------------------------------------------------------
  public void show() {
    fill(255);
    rectMode(CENTER);
    stroke(255);
    rect(x, y, padWidth, padHeight);
  }


  public void edges() {
    if (x - padWidth/2 < 0) {
      x = padWidth/2;
    }
    
    if (x + padWidth/2 > width) {
      x = width - padWidth/2;
    }
  }
  
  
  
  //METHODES CONTROLE---------------------------------------------------------------------------
  
  //Contral par mouse
  public void moving(float x) {
    this.x = x;
    
    edges();
  }
  
  
  //Control par <-- -->
  public void leftMove(float X) {
    x -= X;
    edges();
  }
  public void rightMove(float X) {
    x += X;
    edges();
  }
  
  
  
  public void resetPos() {
    x = width/2;
    y = height-30;
  }
  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "BlockBall" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
