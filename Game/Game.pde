// the real G
import ddf.minim.*;
import java.util.*;
import java.lang.Math;

private AudioPlayer audioPlayer;
private Minim minim;
private Player player;
private Graphic graphic;
private Saving saving;
private Load load;
//private SaveThread savingThread; 
private Menu menu;
private ArrayList <Catch> fish;
//private int numberOfFish = 6;
private boolean sound;
private boolean inGame;
private boolean inPauseMenu;
private boolean gameOver;
private int score;
private int spawner;


private final String STATE_MENU = "menu";
private final String STATE_NEW = "new";
private final String STATE_PLAYING = "play";
private final String STATE_QUIT = "quit";     
private final String STATE_HELP = "help";
private final String STATE_CONTINUE = "continue";
private final String STATE_TUTUROIAL = "tutorial";
private final String STATE_GAME_OVER = "game over";
private final String STATE_PAUSE = "pause";
private final String STATE_RESUME = "resume";
private String STATE = STATE_MENU;

void setup () {
  size(1000, 700);
  frameRate(60);
  player = new Player();
  graphic = new Graphic();
  menu = new Menu();
  fish = new ArrayList <Catch>();
  saving = new Saving();
  load = new Load();
  score = 0;
  sound = true;
  //Music if sound == true play background music
  playBackgroundMusic(sound);
  gameOver = false;
  inGame = false;
  inPauseMenu = false;
  spawner = 300; //How often fish are spawning. The lower the 
  saving.saveGameState( player, fish, score);
  //this.savingThread = new SaveThread(saving, this);
  //this.savingThread.start();
}

void draw () {
  run();
  //play();
}

//Runs the game
public void run() {
  switch(STATE) {
  case STATE_MENU: 
    inGame = false;
    gameOver = false;
    inPauseMenu = false;
    graphic.drawBackground();
    graphic.drawLogo();
    menu.drawMenuButton();
    break;

  case STATE_PAUSE:
    gameOver = false;
    inGame = false;
    inPauseMenu = true;
    pauseGame();
    break;


  case STATE_CONTINUE:  // check with the got catch
    gameOver = false;
    inGame = true;
    inPauseMenu = false;
    load.playerLoad();
    score = load.getScore();
    STATE = STATE_PLAYING;
    break;

  case STATE_RESUME:
    // loop();
    gameOver = false;
    inGame = true;
    inPauseMenu = false;
    STATE = STATE_PLAYING;
    break;

  case STATE_NEW:
    setup();
    STATE = STATE_PLAYING;
    break;

  case STATE_PLAYING: 
    inGame = true;
    gameOver = false;
    inPauseMenu = false;
    play();
    break;

  case STATE_TUTUROIAL: 
    // tutorial skal inn her
    text("oi, her er det ingenting", 350, 300);
    break;

  case STATE_HELP:
    println("Din score er: " + score);
    println("LagraScore:" + load.getScore());
    break;

  case STATE_QUIT:
    gameOver = false;
    inGame = false;
    inPauseMenu = false;
    exit();
    break;

  case STATE_GAME_OVER:
    gameOver = true;
    inGame = false;
    inPauseMenu = false;
    graphic.gameOverBackground();
    menu.drawGameOVerMenu();
    break;   

  default:
    // do nothing
    break;
  }
}

//Starts the game 
public void play() {
  // inGame = true;
  //gameOver = false;
  graphic.drawBackground();
  menu.scoreBoard(score);
  player.boat();

  menu.drawInGameButton();
  //Checks if its time to spawn new fish
  if (spawner >= 300) {
    spawn();
    spawner = 0;
  }

  for (int i = 0; i < fish.size(); i++) {
    fish.get(i).drawAllFish();
  }
  //There is two for-loops to prevent a bug in the fish animation
  for (int i = 0; i < fish.size(); i++) {
    if (fish.get(i).isInMotion() == false) {
      fish.remove(i);
    }
  }

  if ( (player.gotCatch() == true) && (player.checkIfDangerous() == true) ) {
    STATE = STATE_GAME_OVER;
  }

  if ( (player.gotCatch() == true) && (player.fishOnBoard() == true) ) {
    score = score + 1;
    for (int i = 0; i < fish.size(); i++) {
      if (fish.get(i).equals(player.getCatch())) {
        fish.remove(i);
      }
    }
    // må bli satt til false igjen
  }

  if (player.gotCatch() == false) {
    catchSomething();
  }

  spawner = spawner + int(random(1, 10));
}

//Creats a fish and adds it to the arraylist
private void spawn() {
  fish.add(new Catch());
}

//background music function.
private void playBackgroundMusic(boolean sound) 
{
  if (sound) {
    minim = new Minim(this);
    audioPlayer = minim.loadFile("lyd/Fishing2.mp3");
    //audioPlayer.play();
  }
  if (sound == false) {
    audioPlayer.close();
    minim.stop();
  }
}

public void pauseGame() {
  
  //noLoop(); 
  saving.saveGameState( player, fish, score);
  // inPauseMenu = true;
  menu.drawPauseMenu();
}

// Checks if the use are pressing a button
public void mousePressed() {

  String result2 = menu.isButtonPressed(menu.getInGameMenuHash()) ;
    if (result2.equals("sound")) {
      playBackgroundMusic( menu.getSoundOnOffSwitch());
    }

    if (result2.equals("pause")) {
      // else {
      STATE = STATE_PAUSE;
      //pauseGame();
    }
  

  if (inGame==false)
  {
    String result = menu.isButtonPressed(menu.getMainMenuHash()) ;
    if (!result.equals("none")) {
      STATE = result;
    }
  }
  //  //buttons for in Pause Menu
  if (inPauseMenu) {

    String result = menu.isButtonPressed(menu.getPauseMenuHash()) ;
    if (!result.equals("none")) {
      STATE = result;
      //inPauseMenu = false;
    }
  }
  if (gameOver) {
    String result = menu.isButtonPressed(menu.getGameOverMenuHash()) ;
    if (!result.equals("none")) {
      STATE = result;
      //gameOver = false;
      //inGame = false;
    }
  }
}

//Hitbox detection for catching fish
private void catchSomething() {
  float catchX;
  float catchY;
  float catchHeight;
  float rodX = player.getHitboxCenterXPos(); //centered
  float rodY = player.getHitboxCenterYPos(); //centered

  for (Catch temp : fish) {
    catchHeight = temp.getYCut();
    catchY = temp.getCenterYHit(); //centered
    catchX = temp.getCenterXHit(); //centered

    if ( dist(rodX, rodY, catchX, catchY) <= catchHeight/2 ) {
      player.myCatch(temp.isCaught());
    }
  }
}

// If the game is true and not in the menu then the game need to be saved.
public boolean needSaving() {
  return (inGame && (!inPauseMenu));
}