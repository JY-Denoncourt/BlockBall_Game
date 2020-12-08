  import processing.sound.*;
  
//Variables
  //Variable des class-----------------------------------------------------------------------
  SoundFile themeSound, collisionSound;
  
  Player p1;    //Barre en bas
  Ball b1;      //Ball du jeux
  Block[] blocks = new Block[300];
  ParticleSystem psFin;
  ParticleSystem psHitBlock;
  ParticleSystem psHitPad;


  //Variables globale jeux----------------------
  int currentTime;
  int previousTime;
  int deltaTime;
  int time;
  boolean isTime = true;
  
  float movingSpeed = 1;     //Vitesse de la barre en bas
  float ballspeed = 1;       //Vitesse de la balle
  int maxLives = 3;          //Nb balle maximale en debut partie
  int gameLive;              //Nb de balle restante en cours de partie
  
  int Width = 1200;
  int Height = 720;
  ArrayList<Background> bgLayers; 
  boolean hitSound = false;

  color c;
  
  //Variables du menu---------------------------
  int score = 0;

  enum State {menuStart, menuSetting, inGameOn, inGameOff, endGame, gameOver};
  State gameState = State.menuStart;                      //Setter etat du jeu a menu en partant
  boolean btn_enter = false;
  boolean btn_left = false;
  boolean btn_right = false;
  boolean btn_s = false;
  boolean btn_e= false;
  boolean btn_space = false;

  int cols;
  int rows;
  int numBlocks;

  int aliveBlocks = 0;
  int counter = 0;
  //************

  void settings() {
    //fullScreen(P2D);
    size(Width, Height, P2D);
  }
//end


//SETUP-----------------------------------------------------------------------------------
  void setup() {
    currentTime = millis();
    previousTime = currentTime;
    
    //Creation des objets
    themeSound = new SoundFile(this, "Forest.wav");
    collisionSound = new SoundFile(this, "beepCollision.wav");
    p1 = new Player();
    b1 = new Ball();
    psHitPad = new ParticleSystem(10);
    psHitBlock = new ParticleSystem(20);
    
    
    //Initialisation jeu
    gameLive = maxLives;
    loadBackgroundLayers();
    
    
    //Section level
    cols = (int) width / 100;
    rows = 5;
    numBlocks = rows * cols;   

    int index=0;
    for (int i = 0; i < cols; i++) 
    {
      for (int j = 0; j < rows; j++) 
      {
        blocks[index] = new Block(i * 100, j * 40);
        if (blocks[index].alive > 0 ) 
          aliveBlocks++;
        index++;
        println(index);
        println(aliveBlocks);
      }
    }
 
 
    //aliveBlocks = 0;   //*****************************************************************************************************************************************DEBUG
    themeSound.loop();
  }
//end


//BOUCLE DE JEU---------------------------------------------------------------------------
  void draw() {
    currentTime = millis();
    deltaTime = currentTime - previousTime;
    previousTime = currentTime;
    update(deltaTime);
    
    switch (gameState)
    {
      //(OK)  Menu de depart
      case menuStart :   
          background(100, 100, 0);
          
          
          fill(200);
          textSize(int(50));
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
          
          fill(200);
          textSize(int(50));
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
          //Affichage 
          println(aliveBlocks); //debug
          for (Background bg : bgLayers) bg.display();
          showGameStat();
          p1.show();
          b1.show();
          b1.update();
          for (int i = 0; i < numBlocks; i++) blocks[i].show();
          
          
          //Regarder les collision avec pallette
          c = color(255,0,0);
          b1.padCollision(p1);            
          if (b1.getIsPadCollision()) {
            b1.setIsPadCollision(false);
            psHitPad.setupP((int)p1.getPadX(), (int)p1.getPadY());
          }
          psHitPad.update(deltaTime);
          psHitPad.display(c);
          
          //Regarder les collision avec block
          c = color(153,255,204);
          for (int i=0; i<numBlocks; i++) {
            b1.blockCollision(blocks[i]);   
            if (b1.getIsBlockCollision() && b1.isExplode) {
              b1.setIsBlockCollision(false);
              b1.isExplode = false;
              psHitBlock.setupP(((int)blocks[i].getBlockX()), (int)blocks[i].getBlockY());
            }
          }
          psHitBlock.update(deltaTime);
          psHitBlock.display(c);
          
          
          
          //Si la ball a tombe
          if (b1.getBallDrop()) gameState = State.inGameOff;
          
          //Sil ny a plus de block
          if (aliveBlocks == 0) gameState = State.endGame;
      
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
          
          fill(200);
          textSize(int(50));
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
          //background(100, 100, 100);
          for (Background bg : bgLayers) {
            bg.display();
          }  
          
          
          //Pour faire feu artifice au 2 sec aleatoire sur ecran
          if (isTime) { //<>//
            isTime = false;
            int xPs = (int)random(100, width-100);
            int yPs = (int)random(100, height-100);
            psFin = new ParticleSystem(100);
            psFin.setupP(xPs, yPs);
            time = currentTime;
          }
          
          if (currentTime > (time + 2000)) { //<>//
            isTime = true;
            c = color( (random(0,255)), (random(0,255)), (random(0,255)) );
          }
          
          
          fill(200);
          textSize(int(50));
          text("You win", 500 , 100); 
          text("Score = ", 50, 300);
          text(score, 275, 300);
          textSize(30);
          text("Press Enter to return to main menu", 50, 460);   
          
          
          psFin.update(deltaTime);
          psFin.display(c);
          
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
  void keyReleased() {
    if (keyCode == ENTER) btn_enter = true;
    if (key == 's') btn_s = true;
    if (key == 'e') btn_e = true;
    if ((key == ' ') && (gameState == State.inGameOff) ) btn_space = true;
    
  }

  void mouseMoved(){
    if (gameState == State.inGameOn)
      p1.moving(mouseX);
    
    float w = width/2;
    
    if (mouseX < width / 2){
      w += mouseX; 
      bgLayers.get(3).position.x = w * 0.25;
      bgLayers.get(2).position.x = w * 0.75;
      bgLayers.get(1).position.x = w * 1;
      
    }
    else {
      w += mouseX;
      bgLayers.get(3).position.x = w * 0.25;
      bgLayers.get(2).position.x = w * 0.75;
      bgLayers.get(1).position.x = w * 1;
    }
  }

//end


//Methode AFFICHAGE-------------------------------------------------------------------------

  //Affichage dans le jeux principale (nb ball, scrore)
  void showGameStat() {
    fill(255);
    textSize(15);
    text("Live : ", 10, height-5);
    text( gameLive, 70, height-5);
    text("SCORE:", width-120, height-10);
    text( score, width-50, height-10);  
  }


  //Affichage quand perd une balle et de presser ENTRER to start ball
  void loseBallText() {
    textSize(30);
    text(" life -1 ", width/2-137, height - 100);
    text(" Hit SPACE to launch new ball ", width/2-137, height - 150);
  }


  //Affichage quand la partie est gagner
  void winGame() {
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
  void checkWinGame() {
    
  }


  //Sert a remettre game a valeur de depart
  void resetGame() {
    gameLive = maxLives;
    //currentLvl = 0;      *******A Venir********************
    resetBlocks();
    counter = 0;
  }


  //Sert a reseter la game de block    ************TEMPORAIRE va changer avec level*********************
  void resetBlocks() {
    aliveBlocks = 0;
    for (int index = 0; index < numBlocks; index++) {

      blocks[index].alive= -1 + (int)random(2) * 2;
      if (blocks[index].alive > 0) {
        //aliveBlocks++;
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
      
      current.isParallax = true;
      current.velocity.x = 0;
      //currentSpeed += speedIncrement;
      
      current.scale = 0.5;
    }
  }


  void update(int delta) {
  
    for (Background bg : bgLayers) {
      bg.update(delta);
    }
  }
//end
