/*************************************************************************************
* Test Sketch for Razor AHRS v1.4.1
* 9 Degree of Measurement Attitude and Heading Reference System
* for Sparkfun "9DOF Razor IMU" and "9DOF Sensor Stick"
*
* Released under GNU GPL (General Public License) v3.0
* Copyright (C) 2011-2012 Quality & Usability Lab, Deutsche Telekom Laboratories, TU Berlin
* Written by Peter Bartz (peter-bartz@gmx.de)
*
* Infos, updates, bug reports and feedback:
*     http://dev.qu.tu-berlin.de/projects/sf-razor-9dof-ahrs
*************************************************************************************/

/*
  NOTE: There seems to be a bug with the serial library in the latest Processing
  versions 1.5 and 1.5.1: "WARNING: RXTX Version mismatch ...". The previous version
  1.2.1 works fine and is still available on the web.
*/

import processing.opengl.*;
import processing.serial.*;

// IF THE SKETCH CRASHES OR HANGS ON STARTUP, MAKE SURE YOU ARE USING THE RIGHT SERIAL PORT:
// 1. Have a look at the Processing console output of this sketch.
// 2. Look for the serial port list and find the port you need (it's the same as in Arduino).
// 3. Set your port number here:
final static int SERIAL_PORT_NUM = 6;
// 4. Try again.


final static int SERIAL_PORT_BAUD_RATE = 57600;

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float magn = 0.0f;

float acc1 = 0.0f;
float acc2 = 0.0f;
float acc3 = 0.0f;


float yawOffset = 0.0f;
String inString; 
 int xPos = 1; 
 
 
PFont font;
Serial serial;

boolean synched = false;

void drawArrow(float headWidthFactor, float headLengthFactor) {
  float headWidth = headWidthFactor * 200.0f;
  float headLength = headLengthFactor * 200.0f;
  
  pushMatrix();
  
  // Draw base
  translate(0, 0, -100);
  box(100, 100, 200);
  
  // Draw pointer
  translate(-headWidth/2, -50, -100);
  beginShape(QUAD_STRIP);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
    vertex(headWidth, 0 ,0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(headWidth/2, 100, -headLength);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
  endShape();
  beginShape(TRIANGLES);
    vertex(0, 0, 0);
    vertex(headWidth, 0, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(0, 100, 0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 100, -headLength);
  endShape();
  
  popMatrix();
}

void drawBoard() {
  pushMatrix();

  rotateY(-radians(yaw - yawOffset));
  rotateX(-radians(pitch));
  rotateZ(radians(roll)); 

  // Board body
  fill(255, 127, 0);
  box(50, 20, 400);
  sphere(100);
  
  // Forward-arrow
  pushMatrix();
  translate(0, 0, -200);
  scale(0.5f, 0.2f, 0.25f);
  fill(0, 255, 0);
  drawArrow(1.0f, 2.0f);
  popMatrix();
    
  popMatrix();
}




void drawBarChart() {
  pushMatrix();

  // Board body
  fill(255, 255, 0);
  box(50, magn, 1);
  
  // Forward-arrow

  translate(0, 0, 0);
  scale(0.5f, 0.2f, 0.25f);
  fill(0, 255, 0);
    
  popMatrix();
}



void drawDirectionUp() {
  pushMatrix();

  // Board body
  fill(0, 255, 0);
  box(20, acc3-250, 1);
  
  // Forward-arrow

  translate(0, 0, 0);
  scale(0.5f, 0.2f, 0.25f);
  popMatrix();
}

void drawDirectionLeft() {
  pushMatrix();

  // Board body
  fill(0, 255, 0);
  box(acc2, 20, 1);
  
  // Forward-arrow

  translate(0, 0, 0);
  scale(0.5f, 0.2f, 0.25f);
  popMatrix();
}


void drawDirectionDiag() {
  pushMatrix();

  rotateZ(135); 
  // Board body
  fill(0, 255, 255);
  box(10, acc1, 1);
  
  // Forward-arrow

  translate(0, 0, 0);
  scale(0.5f, 0.2f, 0.25f);
  popMatrix();
}








PImage bg;

// Global setup
void setup() {
  bg = loadImage("bg2.png");
  // Setup graphics
  size(640, 480, OPENGL);
  smooth();
  noStroke();
  frameRate(50);
  
  // Load font
  font = loadFont("Univers-66.vlw");
  textFont(font);
  
  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  println(Serial.list());
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println();
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
}





void serialEvent(Serial p) { 
  
  inString = p.readStringUntil('\n'); 
  if(inString != null){
 // println(inString);
  
 if( inString.indexOf("#YPR=") != -1 ){
   
  String[] FirstSplit = split(inString, "#YPR=");
  
  
  //println(FirstSplit[1]);
  
  String[] SecondSplit = split(FirstSplit[1], ",");
  
  
  
    yaw = Float.parseFloat(SecondSplit[0]);
    pitch = Float.parseFloat(SecondSplit[1]);
    roll = Float.parseFloat(SecondSplit[2]);
    magn = Float.parseFloat(SecondSplit[3]);
    magn = magn-250;
    acc1 = Float.parseFloat(SecondSplit[4]);
    acc2 = Float.parseFloat(SecondSplit[5]);
    acc3 = Float.parseFloat(SecondSplit[6]);
    
 }
  }

  
} 







void draw() {
   // Reset scene
  background(bg);
  lights();

  // Draw board
  pushMatrix();
  translate(width/2, height/2, -350);
  drawBoard();
 popMatrix();
 
pushMatrix();
 translate(-100, height/2, -350);
    drawBarChart();
   
      
   popMatrix();
   
   
   
   pushMatrix();
   translate(700, (height/2)+(acc3/2)-50, -350);
   drawDirectionUp();
   popMatrix();
   
   pushMatrix();
   translate(700+(acc2/2), height/2, -350);
   drawDirectionLeft();
   popMatrix();

 pushMatrix();
   translate(700, height/2, -350);
   drawDirectionDiag();
   popMatrix();
   
   
   
  textFont(font, 20);
  fill(255);
  textAlign(LEFT);

  // Output info text
  text("Welcome to PhysiBall v1. Press 'a' to align", 10, 25);

  // Output angles
  pushMatrix();
  translate(10, height - 10);
  textAlign(LEFT);
  text("Yaw: " + ((int) yaw), 0, 0);
  text("Pitch: " + ((int) pitch), 150, 0);
  text("Roll: " + ((int) roll), 300, 0);
    text("Magn: " + ((int) magn), 450, 0);
    
    text("Acc1: " + ((int) acc1), 150, -50);
  text("Acc2: " + ((int) acc2), 300, -50);
  text("Acc3: " + ((int) acc3-250), 450, -50);
    
  popMatrix();
}

void keyPressed() {
  switch (key) {
    case '0':  // Turn Razor's continuous output stream off
      serial.write("#o0");
      break;
    case '1':  // Turn Razor's continuous output stream on
      serial.write("#o1");
      break;
    case 'f':  // Request one single yaw/pitch/roll frame from Razor (use when continuous streaming is off)
      serial.write("#f");
      break;
    case 'a':  // Align screen with Razor
      yawOffset = yaw;
  }
}



