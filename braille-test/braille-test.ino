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
bool newGroupReceived = false;

char _brailleChars[60] =
{
    ' ',  // 0x2800
    'a', //  0x2801
    ',', //  0x2802
    'b', //  0x2803
    '\'', // 0x2804
    'k', //  0x2805 
    ';', //  0x2806
    'l', //  0x2807
    '⠈', //  0x2808
    'c', //  0x2809
    'i', //  0x280A
    'f', //  0x280B
    '/', //  0x280C
    'm', //  0x280D
    's', //  0x280E
    'p', //  0x280F
    '⠐', // 0x2810
    'e', //  0x2811
    ':', //  0x2812
    'h', //  0x2813
    '⠔', //  0x2814
    'o', //  0x2815
    '!', //  0x2816
    'r', //  0x2817
    '⠘', //  0x2818
    'd', //  0x2819
    'j', //  0x281A
    'g', //  0x281B 
    '⠜', // 0x281C
    'n', // 0x281D
    't', // 0x281E
    'q', // 0x281F
    '⠠', // 0x2820
    '⠡', // 0x2821
    '⠢', // 0x2822
    '⠣', // 0x2823
    '-', // 0x2824
    'u', // 0x2825
    '\'\'', // 0x2826
    'v', // 0x2827
    '.', // 0x2828
    '⠩', // 0x2829
    '⠪', // 0x282A
    '⠫', // 0x282B
    '⠬', // 0x282C
    'x', // 0x282D
    '⠮', // 0x282E
    '⠯', // 0x282F
    '⠰', // 0x2830
    '⠱', // 0x2831
    '.', // 0x2832
    '⠳', // 0x2833
    '\'\'', // 0x2834
    'z', // 0x2835
    '(', // 0x2836
};

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
    if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^')
    {
      if (newGroupReceived)
      {
        display.clear();
      }
      processBrailleGroup(receivedData, incomingChar);
      receivedData = "";
      newGroupReceived = true;
    }
    else
    {
      receivedData += incomingChar;
    }
  }
}

uint16_t charToBraille(char c)
{
  for (int i = 0; i < 256; i++)
  {
    if (_brailleChars[i] == c)
    {
      return (uint16_t)(0x2800 + i);
    }
  }
  return 0x2800; 
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
  else if (c == '^')
  {
    uint16_t charsArray[groupLength];

    if (groupLength <= CELL_COUNT)
    {
      for (int i = 0; i < groupLength; i++)
      {
        display.writeCell(group[i], i);
      }
    }
    else if (groupLength > CELL_COUNT)
    {
      for (int i = 0; i < groupLength; i++)
      {
        char c = tolower(group.charAt(i));
        uint16_t unicode = charToBraille(c);
        charsArray[i] = unicode;
      }
      
      display.writeCells(charsArray, groupLength);
    }
  }
}