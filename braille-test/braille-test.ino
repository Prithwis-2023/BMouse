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

void setup()
{
  Serial.begin(9600);
  display.begin();
  display.clear();
}

void loop()
{
  while (Serial.available() > 0)
  {
    char incomingChar = Serial.read();
    // if (incomingChar == '\n')
    // {
    //   int spaceIndex = receivedData.indexOf(" ");
    //   if (spaceIndex != -1)
    //   {
    //     int lineNumber = receivedData.substring(0, spaceIndex).toInt();
    //     char detectedChar = receivedData.charAt(spaceIndex + 1);

    //     // Serial.print("Line: ");
    //     // Serial.print(lineNumber);
    //     // Serial.print(", Char: ");
    //     // Serial.println(detectedChar);
    //     display.writeCell(detectedChar, 0);
    //   }

      //receivedData = "";
   //}
    // else
    // {
    //   receivedData += incomingChar;
    // }

    display.writeCell(incomingChar, 0);
//    delay(500);
  }
}
