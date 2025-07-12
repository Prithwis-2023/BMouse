#include <BrailleDisplay.h>

#define CELL_COUNT 8
#define ON_PIN 6
#define DIN_PIN 3
#define LATCH_PIN 4
#define CLK_PIN 5
#define DOUT_PIN 2

BrailleDisplay display(CELL_COUNT, ON_PIN, DIN_PIN, LATCH_PIN, CLK_PIN, DOUT_PIN);

uint8_t cells[CELL_COUNT];

void binaryWriteCell(uint8_t position, byte byteVal)
{
    byte sortedByte;
    byte againSortedByte;

    bitWrite(sortedByte, 7, bitRead(byteVal, 6));
    bitWrite(sortedByte, 6, bitRead(byteVal, 7));
    bitWrite(sortedByte, 5, bitRead(byteVal, 2));
    bitWrite(sortedByte, 4, bitRead(byteVal, 1));
    bitWrite(sortedByte, 3, bitRead(byteVal, 0));
    bitWrite(sortedByte, 2, bitRead(byteVal, 5));
    bitWrite(sortedByte, 1, bitRead(byteVal, 4));
    bitWrite(sortedByte, 0, bitRead(byteVal, 3));

    sortedByte = ~sortedByte;
    // bitWrite(againSortedByte, 7, bitRead(sortedByte, 6));
    // bitWrite(againSortedByte, 6, bitRead(sortedByte, 7));
    // bitWrite(againSortedByte, 5, bitRead(sortedByte, 2));
    // bitWrite(againSortedByte, 4, bitRead(sortedByte, 1));
    // bitWrite(againSortedByte, 3, bitRead(sortedByte, 0));
    // bitWrite(againSortedByte, 2, bitRead(sortedByte, 5));
    // bitWrite(againSortedByte, 1, bitRead(sortedByte, 4));
    // bitWrite(againSortedByte, 0, bitRead(sortedByte, 3));
    

    cells[CELL_COUNT - position - 1] = sortedByte;

    digitalWrite(LATCH_PIN, LOW);
    for (int i = CELL_COUNT - 1; i >= 0; i--)
    {
      shiftOut(DIN_PIN, CLK_PIN, MSBFIRST, cells[i]);
    }
    digitalWrite(LATCH_PIN, HIGH);
}

void processBrailleGroup(char language, String group, char c)
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
      int dashIndices[tokenCount - 1]; // One less dash than tokens
      int dashIndex = 0;

      for (int i = 0; i < groupLength; i++)
      {
        if (group.charAt(i) == '-' && dashIndex < tokenCount - 1)
        {
          dashIndices[dashIndex] = i;
          dashIndex++;
        }
      }
      for (int i = 0; i < tokenCount - 1; i++)
      {
        int dashPos = dashIndices[i]; 
        char a = group.charAt(dashPos-2);
        char b = group.charAt(dashPos-1);
        int firstPart = a - '0'; // Convert char to int
        int secondPart = b - '0'; // Convert char to int
        int decimalVal = firstPart * 16 + secondPart; // Convert to decimal
        binaryWriteCell(1, decimalVal);
        delay(500);
      }
      int finalDashPos = dashIndices[tokenCount - 2];
      char finFPart = group.charAt(finalDashPos + 1);
      char finSPart = group.charAt(finalDashPos + 2);
      int firstPart = finFPart - '0';
      int secondPart = finSPart - '0';
      int finalDecimalVal = firstPart * 16 + secondPart;
      Serial.println(finalDecimalVal);
      binaryWriteCell(1, finalDecimalVal);
    }
  }
}
void setup() 
{
  //Serial.begin(9600);
  display.begin();
  display.clear();
  binaryWriteCell(1, 51);

  String group = "23-12-09-31-36-1A-23-20-1D-2C";

  //processBrailleGroup('K', group, '@');
}

void loop() 
{
  // if (Serial.available())
  // {
  //   uint8_t byteVal = Serial.read();

  //   binaryWriteCell(1, byteVal);
  // }
  
}
