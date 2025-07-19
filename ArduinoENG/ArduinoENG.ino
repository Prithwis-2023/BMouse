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
char language = '\0'; // 'E' for English, 'K' for Korean, etc.
bool languageSet = false;
int scrollIndex = 0;
int scrollTimer = 0;

char digits[10] = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
char alphabets[10] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'};

bool lastButtonStatePrev = HIGH;
bool lastButtonStateIdle = HIGH;
bool lastButtonStateNext = HIGH;

unsigned long lastDebounceTimePrev = 0;
unsigned long lastDebounceTimeIdle = 0;
unsigned long lastDebounceTimeNext = 0;
const unsigned long debounceDelay = 50;

void setup()
{
  pinMode(10, INPUT_PULLUP); // the previous button
  pinMode(11, INPUT_PULLUP); // idle button (TBD)
  pinMode(12, INPUT_PULLUP); // next button

  Serial.begin(9600);
  display.begin();
  display.clear();

  cli();
  
  // set timer2 (8 bits) at the interrupt frequency 1 kHz
  TCCR2A = 0; // set entire TCCR2A register to 0
  TCCR2B = 0; // same for TCCR2B
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

// Timer 2 Interrupt
ISR(TIMER2_COMPA_vect) 
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
          if (isNumericandReplace(currentWord[i]) != '\0')
          {
            display.writeCell(isNumericandReplace(currentWord[i]), i);
          }
          else
          {
            display.writeCell(currentWord[i], i);
          }
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
            if (isNumericandReplace(currentWord[charIndex]) != '\0')
            {
              display.writeCell(isNumericandReplace(currentWord[charIndex]), i);
            }
            else
            {
              display.writeCell(currentWord[charIndex], i);
            }
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
  }
}

void loop()
{
  while (Serial.available() > 0)
  {
    serialRead(); 
  }

  checkButtons();
}

// reading the serial input and setting the variables
void serialRead()
{
  char incomingChar = Serial.read();

  if (incomingChar == 'E')
  {
    language = incomingChar;
    languageSet = true;
  }
  if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^')
  {
    newGroupReceived = true;
    receivedData = "";
  }
  else if (incomingChar == '@' || incomingChar == '+' || incomingChar == '|')
  {
    if (newGroupReceived && languageSet)
    {
      display.clear();
      newGroupReceived = false;
    }
    if (incomingChar == '|')  // end marker for word grouping feature
    {
      currentWord = receivedData;
      scrollIndex = 0; // start from the beginning
      newWordAvailable = true;
    }
    else
    {
      processBrailleGroup(receivedData, incomingChar, language);
    }

    language = '\0';
    languageSet = false;
  }
  else
  {
    receivedData += incomingChar;
  }
}

// auxillary function for detecting numeric data
char isNumericandReplace(char c)
{
  for (int i = 0; i < 10; i++)
  {
    if (c == digits[i])
    {
      return alphabets[i];
      break;
    }
  }
  return '\0';
}

// process the data and display on the cells
void processBrailleGroup(String group, char c, char lang)
{
  int groupLength = group.length(); 

  if (lang == 'E' && c == '@') // end marker for character grouping feature
  {
    for (int i = 0; i < groupLength; i++)
    {
      if (i < CELL_COUNT) 
      {
        if (isNumericandReplace(group[i]) != '\0')
        {
          display.writeCell(isNumericandReplace(group[i]), i);
        }
        else
        {
          display.writeCell(group[i], i);
        }
      }
    }
  }
  else if (lang == 'E' && c == '+') // end marker for sliding window feature
  {
    int middleIndex = (groupLength - 1) / 2;

    // Left side: Assign decreasing indices before 3
    int leftCellIndex = 3 - (middleIndex);
    
    for (int i = 0; i < middleIndex; i++) 
    {
      if (isNumericandReplace(group[i]) != '\0')
      {
        display.writeCell(isNumericandReplace(group[i]), leftCellIndex + i);
      }
      else
      {
        display.writeCell(group[i], leftCellIndex + i);
      }
    }
    // Middle character at index 3
    if (isNumericandReplace(group[middleIndex]) != '\0')
    {
      display.writeCell(isNumericandReplace(group[middleIndex]), 3);
    }
    else
    {
      display.writeCell(group[middleIndex], 3);
    }
    // Right side: Start from index 4 and continue
    for (int i = middleIndex + 1; i < groupLength; i++) 
    {
      if (isNumericandReplace(group[i]) != '\0')
      {
        display.writeCell(isNumericandReplace(group[i]), 3 + (i - middleIndex));
      }
      else 
      {
        display.writeCell(group[i], 3 + (i - middleIndex));
      }
    }
  }
}

// function for the button mode
void checkButtons()
{
  unsigned long currentTime = millis();

  bool buttonStatePrev = digitalRead(10);
  bool buttonStateIdle = digitalRead(11);
  bool buttonStateNext = digitalRead(12);
  
  // PREV button
  if (buttonStatePrev == LOW && lastButtonStatePrev == HIGH && (currentTime - lastDebounceTimePrev > debounceDelay))
  {
    Serial.println("PREV");
    lastDebounceTimePrev = currentTime;
  }
  lastButtonStatePrev = buttonStatePrev;

  // IDLE button
  if (buttonStateIdle == LOW && lastButtonStateIdle == HIGH && (currentTime - lastDebounceTimeIdle > debounceDelay))
  {
    Serial.println("IDLE");
    lastDebounceTimeIdle = currentTime;
  }
  lastButtonStateIdle = buttonStateIdle;

  // NEXT button
  if (buttonStateNext == LOW && lastButtonStateNext == HIGH && (currentTime - lastDebounceTimeNext > debounceDelay))
  {
     Serial.println("NEXT");
    lastDebounceTimeNext = currentTime;
  }
  lastButtonStateNext = buttonStateNext;
}

