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

bool lastButtonStatePrev = HIGH;
bool lastButtonStateIdle = HIGH;
bool lastButtonStateNext = HIGH;

void setup()
{
  pinMode(10, INPUT_PULLUP); // the previous button
  pinMode(11, INPUT_PULLUP); // idle button (TBD)
  pinMode(12, INPUT_PULLUP); // next button*/

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

ISR(TIMER2_COMPA_vect) // timer 2 interrupt  
{
  /*if (newWordAvailable)
  {
    scrollTimer++;

    if (scrollTimer >= 500)
    {
      scrollTimer = 0;

      int wordLength = currentWord.length() / 2; // each character is represented by 2 hex digits
      if (wordLength <= CELL_COUNT)              // word is short
      {
        for (int i = 0; i < currentWord.length() - 1; i+= 2)
        {
          String hexByteStr = currentWord.substring(i, i + 2);
          int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
          display.binaryWriteCell(i/2, decimalVal);
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
            String hexByteStr = currentWord.substring(charIndex * 2, charIndex * 2 + 2);
            int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
            display.binaryWriteCell(i, decimalVal);
          }
          else
          {
            display.binaryWriteCell(i, 0); // clear cell if no character available
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
  }*/
}

void loop()
{
  bool buttonStatePrev = digitalRead(10);
  bool buttonStateIdle = digitalRead(11);
  bool buttonStateNext = digitalRead(12);
  
  if (lastButtonStatePrev == HIGH && buttonStatePrev == LOW)
  {
    Serial.println("PREV");
    delay(200); // debounce delay
  }
  else if (lastButtonStateIdle == HIGH && buttonStateIdle == LOW)
  {
    Serial.println("IDLE");
    delay(200); // debounce delay
  }
  else if (lastButtonStateNext == HIGH && buttonStateNext == LOW)
  {
    Serial.println("NEXT");
    delay(200); // debounce delay
  }
  lastButtonStatePrev = buttonStatePrev;
  lastButtonStateIdle = buttonStateIdle;
  lastButtonStateNext = buttonStateNext;

  // Read serial input
  while (Serial.available() > 0)
  {
    char incomingChar = Serial.read();

    if (incomingChar == 'K' || incomingChar == 'E')
    {
      language = incomingChar; // Set the language
      //languageSet = true; // Mark that the language has been set
      continue; // Skip further processing for this character
    }         

    if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^') // start markers for different features
    {
      newGroupReceived = true;
      receivedData = ""; // Clear when new group starts
    }
    else if (incomingChar == '@' || incomingChar == '+' || incomingChar == '|') // end markers for different features
    {
      if (newGroupReceived)
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
      else                     // for the rest of the features
      {
        processBrailleGroupKOR(receivedData, incomingChar);
        // reset the language stuff for the next group
        language = '\0'; // Reset the language
        //languageSet = false; // Reset the language set flag
      }
    }
    else
    {
      receivedData += incomingChar;
    }
  }
}

void processBrailleGroupKOR(String group, char c)
{
  int groupLength = group.length(); 
  if (language == '\0') // If language is not set, do nothing
  {
    return;
  }
  if (c == '@') // Korean character grouping
  {
    for (int i = 0; i < groupLength - 1; i += 2)
    {
      String hexByteStr = group.substring(i, i + 2);
      int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
      display.binaryWriteCell(i / 2, decimalVal);
    }
  }
  if (c == '+')  // Korean sliding window
  {
    int numberOfChars = groupLength / 2;
    int middleCharIndex = (numberOfChars - 1) / 2;
    int startCellIndex = 3 - middleCharIndex;

    for (int i = 0; i < middleCharIndex; i++)
    {
      int hexStart = i * 2;
      String hexByteStr = group.substring(hexStart, hexStart + 2);
      int decVal = (int) strtol(hexByteStr.c_str(), NULL, 16);
      display.binaryWriteCell(startCellIndex + i, decVal);
    }

    String middleHexByteStr = group.substring(middleCharIndex * 2, middleCharIndex * 2 + 2);
    int middleDecVal = (int) strtol(middleHexByteStr.c_str(), NULL, 16);
    display.binaryWriteCell(3, middleDecVal);

    for (int i = middleCharIndex + 1; i < numberOfChars; i++)
    {
      int cellIndex = 3 + (i - middleCharIndex);
      int hexStart = i * 2;
      String hexByteStr = group.substring(hexStart, hexStart + 2);
      int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
      display.binaryWriteCell(cellIndex, decimalVal);
    }
  }
}
