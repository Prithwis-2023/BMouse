#include <BrailleDisplay.h>
#include <Arduino.h>

#define CELL_COUNT 8
#define ON_PIN 6
#define DIN_PIN 3
#define LATCH_PIN 4
#define CLK_PIN 5
#define DOUT_PIN 2

BrailleDisplay display(CELL_COUNT, ON_PIN, DIN_PIN, LATCH_PIN, CLK_PIN, DOUT_PIN);
//String receivedData = "";
char receivedData[30] = {'\0'};
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
    // //DEBUG
    // Serial.print("INTERRUPTED> ");
    // Serial.println(receivedData);

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
    serialRead();
  }
  checkButtons();
}

// reading the serial input and setting the variables
void serialRead()
{
  char incomingChar = Serial.read();

  // //DEBUG
  // strncat(receivedData, &incomingChar, sizeof(incomingChar));
  // Serial.println(receivedData);

  if (incomingChar == 'K')
  {
    language = incomingChar;
    languageSet = true;
  }
  if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^')
  {
    newGroupReceived = true;
    //receivedData = "";
    receivedData[0]={'\0'};
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
      // Serial.println("Received Korean Word Group:");
      // Serial.println(receivedData);
      // Serial.print("Length: "); Serial.println(strlen(receivedData[0]));
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
    //receivedData += incomingChar;
    strncat(receivedData, &incomingChar, sizeof(incomingChar));
  }
}

// process the data and display on the cells
void processBrailleGroup(String group, char c, char lang)
{
  int groupLength = group.length(); 

  if (lang == 'K' && c == '@') // Korean character grouping
  {
    for (int i = 0; i < groupLength - 1; i += 2)
    {
      String hexByteStr = group.substring(i, i + 2);
      int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
      display.binaryWriteCell(i / 2, decimalVal);
    }
  }
  if (lang == 'K' && c == '+')  // Korean sliding window
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