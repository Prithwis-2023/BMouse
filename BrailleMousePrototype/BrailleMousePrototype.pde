import processing.serial.*;

Serial myPort;
String portName = "COM6";

float mx;
float my;
float easing = 1;
int radius = 15;
int edge = 150;  // Defines the boundary from the edges of the window where the circle is restricted.
int inner = edge + radius;  // Ensures that the circle stays within the rectangular boundary.
boolean isVertical = false; 
boolean isHorizontal = false;
boolean isOn = false;


String text = "Hello Processing! This is a multiline example. Move the cursor.";

int currentLine = 0;
int charIndex = 0;
float textSizeValue = 32;
float charWidth = textSizeValue * 0.6; // width of each character
float lineHeight = textSizeValue * 1.5;
float margin = 60; // space from top
float totalHeight;  // To hold the total height of the text area

int prevLine = -1;
char prevChar = '\0';

String[] lines;

void setup() 
{
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  
  size(640, 360);  // Canvas size. The predefined width and height variables now hold these values.
  noStroke();  // Ensures that shapes (circles, rectangles) have no outlines.
  ellipseMode(RADIUS);
  rectMode(CORNERS);
  textSize(textSizeValue);
  lines = breakText(text, width - (int)margin - ((int)margin - 10), charWidth); 
  totalHeight = lines.length * lineHeight; // Calculate total height of the text area
}

void sendToBraille(int lineNumber, char detectedChar)
{
  if (myPort != null && (lineNumber != prevLine || detectedChar != prevChar))
  {
    String data = lineNumber + " " + detectedChar;
    myPort.write(data);
    println("Sent to Arduino: " + data); // Debugging output
    
    prevLine = lineNumber;
    prevChar = detectedChar;
  }
  
  delay(1);
}
void draw() 
{ 
  background(51);
  
  // Draw the background rectangle for the text
  fill(0, 0, 0);
  rect(margin - 10, margin - textSizeValue, width - margin, margin + totalHeight, 20); 
  
  // Draw the text inside the rectangle
  fill(255);
  for (int i = 0; i < lines.length; i++)
  {
    float y = margin + i * lineHeight;
    
    // Highlight the current line
    if (my > y - lineHeight * 0.5 && my < y + lineHeight * 0.5) {
      currentLine = i; // set the current line
      charIndex = int((mx - margin) / charWidth);  // find character index based on mx position
      charIndex = constrain(charIndex, 0, lines[currentLine].length() - 1);
      fill(8, 5, 62);// Highlight color
      rect(margin - 10, y - textSizeValue, width - margin, y + lineHeight / 2);
      fill(255); // Reset fill color for text
    }
    
    // Draw rectangles around each character
    for (int j = 0; j < lines[i].length(); j++) 
    {
      float charX = margin + j * charWidth;
      float charY = y;
      noFill();
      stroke(234, 220, 0);
      rect(charX, charY - textSizeValue * 0.8, charX + charWidth, charY);
      text(lines[i].charAt(j), charX, charY);
    }
    //text(lines[i], margin, y); // x2 and y2 for position of text start
    noStroke();
  }
  
  fill(255);
  text("Detected Char: " + lines[currentLine].charAt(charIndex), 50, height - 20);
  
  //int btnY = height - 20; int btnX = 90; int btnW = 100; int btnH = 50;
  //rect(btnX, btnY, btnW, btnH, 10);  // Rounded rectangle
  
  sendToBraille(currentLine + 1, lines[currentLine].charAt(charIndex));
  
  
  // Determine horizontal or vertical movement
  if (!isHorizontal && !isVertical)
  {
    if (abs(mouseX - mx) > abs(mouseY - my))
    {
      isHorizontal = true;
    }
    else if (abs(mouseY - my) > abs(mouseX - mx))
    {
      isVertical = true;
    }
  }
  
  // Apply easing to the circle's movement
  if (isHorizontal && abs(mouseX - mx) > 0.1) 
  {
    mx = mx + (mouseX - mx) * easing;
  }
  
  if (isVertical && abs(mouseY - my) > 0.1) 
  {
    my = my + (mouseY- my) * easing;
  }
  
  float lineStartX = margin; // Left edge of the text area
  //float lineEndX = width - margin; // Right edge of the text area
  float lastCharX = margin + lines[currentLine].length() * charWidth;
  
  // Constrain circle's position to the boundary
  mx = constrain(mx, lineStartX + radius / 2, lastCharX - radius / 2);
  my = constrain(my, margin, margin + totalHeight - lineHeight); 

  // Reset movement lock if the mouse is not moving
  if (mouseX == pmouseX && mouseY == pmouseY) 
  {
    isHorizontal = false;
    isVertical = false;
  }

  // Draw the circle
  fill(50, 205, 50);  
  ellipse(mx, my, radius, radius); // x of center, y of center, w, h
}

String[] breakText(String text, int rectWidth, float charWidth)
{
  ArrayList<String> lines = new ArrayList<String>();
  String[] words = text.split(" ");
  String currentLine = "";
  
  for(String word: words)
  {
    String testLine;
    if (currentLine.isEmpty())
    {
      testLine = word;
    }
    else
    {
      testLine = currentLine + " " + word;
    }
    
    float testWidth = testLine.length() * charWidth;
    
    if (testWidth >= rectWidth)
    {
      lines.add(currentLine);
      currentLine = word;
    }
    else
    {
      currentLine = testLine;
    }
  }
  
  // for any remaining words
  if (!currentLine.isEmpty())
  {
    lines.add(currentLine);
  }
  
  return lines.toArray(new String[0]);
}
