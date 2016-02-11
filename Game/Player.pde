
public class Player {
  
private Control control;
private int boatPosition = 215;
private int boatSpeed = 4;


  public Player() {
    control = new Control();
    control.setSpeedX(boatSpeed);
    control.setPositionX(boatPosition);
  }
  
  //Manages the boatMovement
  public void boat() {
    int xPos = control.horizontalMove();
    rect(xPos,178,50,30);
  }
  
  //Sets new boat speed
  public void setBoatSpeed(int newSpeed) {
    boatSpeed = newSpeed;
    control.setSpeedX(boatSpeed);
  }
  
  //Sets new start x position
  public void setStartPosition(int newPositionX) {
    boatPosition = newPositionX;
    control.setPositionX(boatPosition);
  }
}