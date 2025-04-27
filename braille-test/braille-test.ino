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
String currentWord = "";
bool newGroupReceived = false;
bool newWordAvailable = false;
int scrollIndex = 0;
int scrollTimer = 0;

void setup()
{
  Serial.begin(9600);
  display.begin();
  display.clear();

  cli();

  // set timer2 (8 bits) at the interrupt frequency 1 kHz
  TCCR2A = 0; // set entire TCCR1A register to 0
  TCCR2B = 0; // same for TCCR1B
  TCNT2  = 0; // initialize counter variable to 0

  // set compare match register for 1 kHz increments
  OCR2A = 222; // (16 * 10^6) / (1000 * 64) - 1 [ must be  < 256]
  // turn on CTC mode
  TCCR2A |= (1 << WGM21);
  // Set CS22 bit for 64 prescaler
  TCCR2B |= (1 << CS22);
  // enable timer compare interrupt
  TIMSK2 |= (1 << OCIE2A);

  sei(); // allow interrupts
}

ISR(TIMER2_COMPA_vect) // timer 2 interrupt  
{
  if (newWordAvailable)
  {
    scrollTimer++;

    if (scrollTimer >= 500)
    {
      scrollTimer = 0;

      int wordLength = currentWord.length();
      if (wordLength <= CELL_COUNT)
      {
        // word is short
        for (int i = 0; i < wordLength; i++)
        {
          display.writeCell(currentWord[i], i);
        }
        newWordAvailable = false; // done and no scrolling needed
      }
      else
      {
        display.clear(); // clear once per frame

        // scroll the word
        for (int i = 0; i < CELL_COUNT; i++)
        {
          int charIndex = scrollIndex + i;
          if (charIndex < wordLength)
          {
            display.writeCell(currentWord[charIndex], i);
          }
          else
          {
            display.writeCell(' ', i);
          }
        }
        scrollIndex++;

        // if scrolling has finished
        if (scrollIndex > (wordLength - CELL_COUNT))
        {
          scrollIndex = 0;
          newWordAvailable = false;
        }
      }
    }
    //display.clear();
    //processBrailleGroup(currentWord, '|');
    //newWordAvailable = false;
  }
}

void loop()
{
  while (Serial.available() > 0)
  {
    char incomingChar = Serial.read();

    if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^')
    {
      newGroupReceived = true;
      receivedData = ""; // Clear when new group starts
    }
    else if (incomingChar == '@' || incomingChar == '+' || incomingChar == '|')
    {
      if (newGroupReceived)
      {
        display.clear();
        newGroupReceived = false;
      }
      if (incomingChar == '|')
      {
        currentWord = receivedData;
        scrollIndex = 0; // start from the beginning
        newWordAvailable = true;
      }
      else
      {
        processBrailleGroup(receivedData, incomingChar);
      }

      /*receivedData = "";
      newGroupReceived = false;*/
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
    if (display._brailleChars[i] == c)
    {
      return (uint16_t)(0x2800 + i);
    }
  }
  return 0x2800; 
}

void processBrailleGroup(String group, char c)
{
  int groupLength = group.length(); 

  if (c == '@')
  {
    for (int i = 0; i < groupLength; i++)
    {
      if (i < CELL_COUNT) 
      {
        display.writeCell(group[i], i);
      }
    }
  }
  else if (c == '+')
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
  else if (c == '|')
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