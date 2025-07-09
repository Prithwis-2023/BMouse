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

    bitWrite(againSortedByte, 3, bitRead(sortedByte, 0));
    bitWrite(againSortedByte, 4, bitRead(sortedByte, 1));
    bitWrite(againSortedByte, 5, bitRead(sortedByte, 2));
    bitWrite(againSortedByte, 0, bitRead(sortedByte, 3));
    bitWrite(againSortedByte, 1, bitRead(sortedByte, 4));
    bitWrite(againSortedByte, 2, bitRead(sortedByte, 5));
    bitWrite(againSortedByte, 6, bitRead(sortedByte, 7));
    bitWrite(againSortedByte, 7, bitRead(sortedByte, 6));

    cells[CELL_COUNT - position - 1] = againSortedByte;

    digitalWrite(LATCH_PIN, LOW);
    for (int i = CELL_COUNT - 1; i >= 0; i--)
    {
      shiftOut(DIN_PIN, CLK_PIN, MSBFIRST, cells[i]);
    }
    digitalWrite(LATCH_PIN, HIGH);
}

void setup() 
{
  //display.begin();
  //display.clear();
  //binaryWriteCell(1, 0xC5);
}

void loop() 
{
  if (Serial.available()) 
  {
    byte b = Serial.read();
  }
  // if (Serial.available())
  // {
  //   uint8_t byteVal = Serial.read();

  //   if (byteVal == 0xAA) // checking for termination signal
  //   {

  //   }
  // }
  
}
