#include <BrailleDisplay.h>
#include <Arduino.h>

#define CELL_COUNT 8
#define ON_PIN 6
#define DIN_PIN 3
#define LATCH_PIN 4
#define CLK_PIN 5
#define DOUT_PIN 2

BrailleDisplay display(CELL_COUNT, ON_PIN, DIN_PIN, LATCH_PIN, CLK_PIN, DOUT_PIN);
String receivedData = "";

void setup()
{
  Serial.begin(9600);
  display.begin();
  display.clear();
}

void loop()
{
  while (Serial.available() > 0)
  {
    char incomingChar = Serial.read();
    if (incomingChar == '*' || incomingChar == '#')
    {
      processBrailleGroup(receivedData, incomingChar);
      receivedData = "";
    }
    else
    {
      receivedData += incomingChar;
    }
  }
}

void processBrailleGroup(String group, char c)
{
  int groupLength = group.length(); 

  if (c == '*')
  {
    for (int i = 0; i < groupLength; i++)
    {
      if (i < CELL_COUNT) 
      {
        display.writeCell(group[i], i);
      }
    }
  }
  else if (c == '#')
  {
    int middleIndex = (groupLength - 1) / 2;

    // Left side: Assign decreasing indices before 3
    int leftCellIndex = 3 - (middleIndex);
    
    for (int i = 0; i < middleIndex; i++) 
    {
        display.writeCell(group[i], leftCellIndex + i);
    }

    // Middle character at index 3
    display.writeCell(group[middleIndex], 3);

    // Right side: Start from index 4 and continue
    for (int i = middleIndex + 1; i < groupLength; i++) 
    {
        display.writeCell(group[i], 3 + (i - middleIndex));
    }
  }
}
