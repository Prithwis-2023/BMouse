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

void setup()
{
  pinMode(11, INPUT_PULLUP); // the previous button
  pinMode(12, INPUT_PULLUP); // idle button (TBD)
  pinMode(13, INPUT_PULLUP); // next button

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
  bool buttonStatePrev = digitalRead(11);
  bool buttonStateIdle = digitalRead(12);
  bool buttonStateNext = digitalRead(13);
  
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

    if (incomingChar == 'E' || incomingChar == 'K')
    {
      language = incomingChar; // Set the language
      languageSet = true; // Mark that the language has been set
      continue; // Skip further processing for this character
    }

    if (incomingChar == '*' || incomingChar == '#' || incomingChar == '^') // start markers for different features
    {
      if (languageSet)
      {
        newGroupReceived = true;
        receivedData = ""; // Clear when new group starts
      }
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
      else
      {
        processBrailleGroup(receivedData, incomingChar);
      }

      // reset the language stuff for the next group
      language = '\0'; // Reset the language
      languageSet = false; // Reset the language set flag
    }
    else
    {
      receivedData += incomingChar;
    }
  }
}

// uint16_t charToBraille(char c)
// {
//   for (int i = 0; i < 256; i++)
//   {
//     if (display._brailleChars[i] == c)
//     {
//       return (uint16_t)(0x2800 + i);
//     }
//   }
//   return 0x2800; 
// }

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


void processBrailleGroup(String group, char c)
{
  int groupLength = group.length(); 
  if (language == '\0') // If language is not set, do nothing
  {
    return;
  }
  else if (language == 'K') // Korean
  {
    if (c == '@') // end marker for character grouping feature
    {
      int start = 0;
      // count the number of tokens (segments between '-')
      int tokenCount = 1;
      for (int i = 0; i < groupLength; i++)
      {
        if (group.charAt(i) == '-') tokenCount++;
      }

      int currentIndex = 0; int nextIndex = 0;
      for (int i = 0; i < CELL_COUNT; i++)
      {
        nextIndex = group.indexOf('-', currentIndex);
        if (nextIndex == -1) // no more '-' found, take the rest of the string
        {
          nextIndex = groupLength;
        }
        String token = group.substring(currentIndex, nextIndex);

        unsigned long fullValue = strtoul(token.c_str(), NULL, 16);  // Convert to unsigned long (hex base 16)

        byte b = (byte)(fullValue & 0xFF); // Extract lowest byte

        display.binaryWriteCell(i, b); // Write the byte to the display

        currentIndex = nextIndex + 1; // Move to the next segment
      }
    }
  }
  else if (language == 'E') // English
  {
    if (c == '@') // end marker for character grouping feature
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
    else if (c == '+') // end marker for sliding window feature
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
}
