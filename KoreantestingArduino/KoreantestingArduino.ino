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
  Serial.begin(9600);
  display.begin();
  display.clear();
  language = 'K';
  String group = "2303202A0309";
  processBrailleGroup(group, '@', language);                                                                     
}

void loop()
{
  
}


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

void slidingKor(String group, char c, char language)
{
  int groupLength = group.length();
  if (c == '+' && language == 'K') // Korean sliding window
  {
    int numberOfChars = groupLength / 2;
    int middleCharIndex = (numberOfChars - 1) / 2;
    Serial.print("Left: ");
    int leftCellStart = 3 - middleCharIndex;
    for (int i = 0; i < middleCharIndex; i++)
    {
      int cellIndex = leftCellStart + i;
      if (cellIndex >= 0 && cellIndex < CELL_COUNT) // checking if inbound
      {
        int hexStart = i * 2;
        String hexByteStr = group.substring(hexStart, hexStart + 2);
        int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
        display.binaryWriteCell(cellIndex, decimalVal);
      }
      Serial.print(cellIndex + " ");
    }
    Serial.println();
    Serial.print("Middle: ");
    String middleCharHexByteStr = group.substring(middleCharIndex * 2, middleCharIndex * 2 + 2);
    int middleCharDecimalVal = (int) strtol(middleCharHexByteStr.c_str(), NULL, 16);
    display.binaryWriteCell(3, middleCharDecimalVal);

    for (int i = middleCharIndex + 1; i < numberOfChars; i++)
    {
      int cellIndex = 3 + (i - middleCharIndex);
      if (cellIndex >= 0 && cellIndex < CELL_COUNT)
      {
        int hexStart = i * 2;
        String hexByteStr = group.substring(hexStart, hexStart + 2);
        int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
        display.binaryWriteCell(cellIndex, decimalVal);
      }
    }                                                                                                        
  }
}

void processBrailleGroup(String group, char c, char language)
{
  int groupLength = group.length(); 
  if (language == '\0') // If language is not set, do nothing
  {
    return;
  }
  else if (c == '@' && language == 'K') // Korean character grouping
  {
    for (int i = 0; i < groupLength - 1; i += 2)
    {
      String hexByteStr = group.substring(i, i + 2);
      int decimalVal = (int) strtol(hexByteStr.c_str(), NULL, 16); // Convert hex to decimal
      display.binaryWriteCell(i / 2, decimalVal);
    }
  }
}