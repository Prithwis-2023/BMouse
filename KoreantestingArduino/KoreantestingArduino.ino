#include <BrailleDisplay.h>

#define CELL_COUNT 8
#define ON_PIN 6
#define DIN_PIN 3
#define LATCH_PIN 4
#define CLK_PIN 5
#define DOUT_PIN 2

const int PATTERN_LENGTH = 100;
uint16_t pattern[PATTERN_LENGTH];
int index = 0;

BrailleDisplay display(CELL_COUNT, ON_PIN, DIN_PIN, LATCH_PIN, CLK_PIN, DOUT_PIN);

void setup() 
{
  Serial.begin(9600);
  display.begin();
  display.clear();

  display.binaryWriteCell(1, 0xE8);
}

void loop() 
{

  // if (Serial.available())
  // {
  //   uint8_t byteVal = Serial.read();

  //   if (byteVal == 0xAA) // checking for termination signal
  //   {

  //   }
  // }
  
}
