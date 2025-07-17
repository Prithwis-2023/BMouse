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

ISR(TIMER2_COMPA_vect) // timer 2 interrupt  
{
  if (newWordAvailable)
  {
    scrollTimer++;

    if (scrollTimer >= 500)
    {
      scrollTimer = 0;

      int wordLength = currentWord.length() / 2; // each character is represented by 2 hex digits
      if (wordLength <= CELL_COUNT)              // word is short
      {
        for (int i = 0; i < wordLength; i++)
        {
          int hexStart = i * 2; 
          String hexByteStr = currentWord.substring(hexStart, hexStart + 2);
          int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
          display.binaryWriteCell(i, decimalVal);
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
  }
}

void loop()
{
  while (Serial.available() > 0)
  {
    serialRead(); // Read serial input
  }
  checkButtons(); // the function for the button mode
}

void serialRead()
{
  char incomingChar = Serial.read();
  if (incomingChar == 'K')
  {
    language = incomingChar;
    languageSet = true;
  }
  else if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^') // start markers
  {
    newGroupReceived = true;
    receivedData = ""; // resetting this everytime we receive a new group
  }
  else if (incomingChar == '@' || incomingChar == '+' || incomingChar == '|') // end markers
  {
    if (newGroupReceived && languageSet)
    {
      display.clear();
      if (incomingChar == '|')
      {
        currentWord = receivedData;
        scrollIndex = 0;
        newWordAvailable = true;

        language = '\0';
        languageSet = false;
      }
      else
      {
        processBrailleGroup(receivedData, incomingChar, language);
        //newWordAvailable = false;
      }

      language = '\0';
      languageSet = false;
      newGroupReceived = false;
    }
  }
  else
  {
    receivedData += incomingChar;
  }
}

void processBrailleGroup(String group, char c, char language)
{
  int groupLength = group.length(); 
  if (language == '\0') // If language is not set, do nothing
  {
    return;
  }
  if (language == 'K' && c == '@') // Korean character grouping
  {
    for (int i = 0; i < groupLength - 1; i += 2)
    {
      String hexByteStr = group.substring(i, i + 2);
      int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
      display.binaryWriteCell(i / 2, decimalVal);
    }
  }
  if (language == 'K' && c == '+')  // Korean sliding window
  {
    int groupLength = group.length();         // e.g., 14
    int numberOfChars = groupLength / 2;      // e.g., 7 characters
    int middleCharIndex = (numberOfChars - 1) / 2;  // e.g., index 3
    int middleCellIndex = 3;                        // fixed middle cell
    int leftmostCellIndex = middleCellIndex - middleCharIndex;

    for (int i = 0; i < numberOfChars; i++)
    {
      int hexStart = i * 2;
      if (hexStart + 2 > groupLength) break;  // avoid overflow

      String hexByteStr = group.substring(hexStart, hexStart + 2);
      int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16);

      int cellIndex = leftmostCellIndex + i;

      if (cellIndex >= 0 && cellIndex < CELL_COUNT)
      {
        display.binaryWriteCell(cellIndex, decimalVal);
      }
    }
  }
}

void checkButtons()
{
  unsigned long currentTime = millis();

  bool buttonStatePrev = digitalRead(10);
  bool buttonStateIdle = digitalRead(11);
  bool buttonStateNext = digitalRead(12);
  
  // PREV button
  if (buttonStatePrev == LOW && lastButtonStatePrev == HIGH && (currentTime - lastDebounceTimePrev > debounceDelay))
  {
    //Serial.println("PREV");
    lastDebounceTimePrev = currentTime;
  }
  lastButtonStatePrev = buttonStatePrev;

  // IDLE button
  if (buttonStateIdle == LOW && lastButtonStateIdle == HIGH && (currentTime - lastDebounceTimeIdle > debounceDelay))
  {
    //Serial.println("IDLE");
    lastDebounceTimeIdle = currentTime;
  }
  lastButtonStateIdle = buttonStateIdle;

  // NEXT button
  if (buttonStateNext == LOW && lastButtonStateNext == HIGH && (currentTime - lastDebounceTimeNext > debounceDelay))
  {
    //Serial.println("NEXT");
    lastDebounceTimeNext = currentTime;
  }
  lastButtonStateNext = buttonStateNext;
}