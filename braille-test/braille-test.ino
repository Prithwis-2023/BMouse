#include <BrailleDisplay.h>
#include <Arduino.h>

#define CELL_COUNT 8
#define ON_PIN 6
#define DIN_PIN 3
#define LATCH_PIN 4
#define CLK_PIN 5
#define DOUT_PIN 2

#define interruptFreq 0.3

BrailleDisplay display(CELL_COUNT, ON_PIN, DIN_PIN, LATCH_PIN, CLK_PIN, DOUT_PIN);
String receivedData = "";
String currentWord = "";
bool newGroupReceived = false;
bool timerTick = false;
bool newWordAvailable = false;

void setup()
{
  Serial.begin(9600);
  display.begin();
  display.clear();

  cli();

  // set timer1 at the interrupt frequency
  TCCR1A = 0; // set entire TCCR1A register to 0
  TCCR1B = 0; // same for TCCR1B
  TCNT1  = 0; // initialize counter variable to 0

  // set compare match register for increments
  OCR1A = 52082; // (16 * 10^6) / (0.3 * 1024) - 1 [ must be  < 65536]
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS10 and CS12 bits for 1024 prescaler
  TCCR1B |= (1 << CS12) | (1 << CS10);
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);

  sei(); // allow interrupts
}

ISR(TIMER1_COMPA_vect) // timer 1 interrupt  
{
  timerTick = true;
}
void loop()
{
  while (Serial.available() > 0)
  {
    char incomingChar = Serial.read();

    if (incomingChar == '$')
    {
      newGroupReceived = true;
    }
    else if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^')
    {
      if (newGroupReceived)
      {
        display.clear();
      }
      if (incomingChar == '^')
      {
        currentWord = receivedData;
        newWordAvailable = true;
      }
      else
      {
        processBrailleGroup(receivedData, incomingChar);
      }
      receivedData = "";
      newGroupReceived = false;
    }
    else
    {
      receivedData += incomingChar;
    }
  }
  if (timerTick)
  {
    timerTick = false;
    if (newWordAvailable)
    {
      display.clear();
      processBrailleGroup(currentWord, '^');
      newWordAvailable = false;
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