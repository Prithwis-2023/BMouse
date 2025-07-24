// imports
import com.krab.lazy.*;
import processing.serial.*;
import processing.sound.*;

// create enums for the text display modes and the features
enum Language {English, Korean}; 
enum Feature {charGrouping, wordGrouping, slidingWindow}; // create an enum for the features
enum textMode {plainTextMode, fileMode}; // create an enum for the mode of text, either plain text or extraction from a txt file
enum textDisplayMode {buttonMode, normalMode}; // create an enum for the text display modes
Language defaultLanguage = Language.English; // default language
Feature defaultFeature = Feature.charGrouping; // default feature
textMode defaultTextMode = textMode.plainTextMode; // default text mode
textDisplayMode defaultDisplayMode = textDisplayMode.normalMode; // default text display mode

// constants
/* we have three display modes:
 * 1. charGrouping: displays characters in groups of DB_FREQ
 * 2. wordGrouping: displays words in groups  of the word length
 * 3. slidingWindow: displays a sliding window of characters
 */

final int defaultCharGrouping_FREQ = 5;  // character group frequency for charGrouping feature
final int defaultSlidingWindow_FREQ = 8;  // sliding window frequency for slidingWindow feature. Can be 1, 3, 5 or 8

/* Text and Languages Related */
int textIndex = 0; // index for the lines of the sample text
int randIndex = 0; // random start index in case of the file mode. Same for the korean file mode
String DTEXT = "This is it. \n The fight of our lives and we're going to win. Bla Bla Black Sheep have you any wool.\n Whatever it takes. \n And Hello World!";  // custom text
String korDTEXT = "시계가 물에 빠졌다. 123"; // custom Korean text
String markersString = ""; // markers for the Korean text

String[] lines;
String[] engLinesFromFile; 
String[] korLinesFromFile;

// Sound
SoundFile EOLBeep; 
SoundFile COLBeep;
SoundFile TopandBottomBeep;
boolean isEOLBeepPlayed = false;
boolean isBeyondTopnBottom = false;

// Serial Port
Serial myPort;
String portName = Serial.list()[0];  // default port

// GUI
LazyGui gui;

// Others
int previousLineIndex = -1;  // previous line index
int charGroupingFrequency; // stores the character grouping frequency
int slidingWindowFrequency; // stores the sliding window frequency
String userInput = "";
String lastSentGroup = "";
PFont fontEnglish, fontKorean; // initialize the font
int lastVerticalZone = 0; // -1 for above boundary, 0 for inside and 1 for below the boundary line

// Clears GUI Data
void clearGUIData()
{
  File autoSaveFile = new File(dataPath("BrailleMouseRefactored/saves/auto.json"));
  if (autoSaveFile.exists()) 
  {
      autoSaveFile.delete();
  }
}

// Settings function - set the window size and renderer
void settings() 
{
  size(1920, 1080, P2D); 
}

// Setup function - GUI, Serial, Sound and function calls from language based processing files
void setup()
{
  init();  // from KORHelperFunctionsm file

  surface.setResizable(true);

  // Initialize LazyGui
  gui = new LazyGui(this, new LazyGuiSettings()
    .setAutosaveOnExit(false)
    .setLoadLatestSaveOnStartup(false)
  ); 
  
  myPort = new Serial(this, portName, 9600);
  delay(500);                                 // Allow Arduino to finish resetting after serial opens
  clearBrailleCells();                        // Send a clear command right every time afer connecting
  
  EOLBeep = new SoundFile(this, "endOfLineBeep.mp3");
  COLBeep = new SoundFile(this, "ChangeOfLine.mp3");
  TopandBottomBeep = new SoundFile(this, "endOfLineBeep.mp3");
  
  fontEnglish = createFont("MapleMono-SemiBold.otf", 32);
  fontKorean = createFont("Noto Sans CJK KR", 32);

  engLinesFromFile = loadStrings("textENG.txt");
  korLinesFromFile = loadStrings("textKOR2.txt");
  for (int i = 0; i < korLinesFromFile.length; i++)
  {
    korLinesFromFile[i] = decompose(korLinesFromFile[i]);
  }
  randIndex = int(random(Math.min(korLinesFromFile.length, engLinesFromFile.length) - 9)); // because we want 10 lines, so we need to subtract. We don't need another one for the korean mode
}

// clearing all the cells upon killing the program
void exit() 
{
  clearBrailleCells();
  super.exit();         // super.exit() to ensure the sketch closes
}


// function to clear all the cells before reading starts
void clearBrailleCells() 
{
  String clearSignal = "$";  // or any special symbol you agreed on with Arduino
  myPort.clear();            // flush any garbage bytes before sending clear
  delay(100);
  myPort.write(clearSignal);
}

// function to send the group to the Arduino.
void sendToBrailleGroup(String group, String startMarker, String endMarker, int spacesLeft, int spacesRight)
{
  if (myPort != null)
  {
    if (defaultLanguage == Language.English)
    {
      String brailleString = startMarker + bUnicodesStringENG(group, spacesLeft, spacesRight) + endMarker;
      myPort.write(brailleString);
      println("Sent to Arduino ENG: " + brailleString); // Debugging output
    }
    else if (defaultLanguage == Language.Korean)
    {
      String brailleString = startMarker + bUnicodesStringKOR(group, spacesLeft, spacesRight) + endMarker;
      myPort.write(brailleString); // send the braille string to the Arduino
      println("Sent to Arduino KOR: " + brailleString); // Debugging output
    }
  }
  else
  {
    println("Serial port not initialized.");
  }
  delay(1);
}

// Function to auto generate multiple lines of text. 
// Returns an array of strings.
// This function is used to wrap the text into lines that fit within the specified width.
// It splits the text into paragraphs (based on \n) and then wraps each paragraph into lines based on the maxWidth parameter.
// It handles word wrapping and ensures that no line exceeds the specified width.
// It also trims the lines to remove any leading or trailing whitespace.
String[] wrapText(String text, float maxWidth)
{
  String[] paragraphs = splitTokens(text, "\n");
  ArrayList<String> wrappedLines = new ArrayList<String>();

  for(String para : paragraphs)
  {
    String[] words = splitTokens(para, " ");
    String currentLine = "";

    for (String word :  words)
    {
      if (word.contains(" "))
      {
        continue; // skip empty words
      }
      if (textWidth(currentLine + word) > maxWidth)
      {
        wrappedLines.add(currentLine.trim()); // add the current line to the list
        currentLine = ""; // reset the current line
      }
      currentLine += word + " "; // add the word to the current line
    }

    if (currentLine.length() > 0)
    {
      wrappedLines.add(currentLine.trim()); // add the last line if it has content
    }
  }

  return wrappedLines.toArray(new String[0]);
}


// Function to draw the text on the screen
void drawText(String presentLine, float PosX, float PosY)
{
  fill(255); // set the text color to white
  noStroke();
  text(presentLine, PosX, PosY); // draw the text
}


//call this function from any mode, passing it:
//groupX: where it starts in x
//lineY: vertical position of the line
//groupWidth: measured width
//lineHeight: height of the line box 
// This function draws a group box around the text
void drawGroupBox(float groupX, float lineY, float groupWidth, float lineHeight)
{
  noFill();
  stroke(234, 220, 0);
  rect(groupX, lineY, groupWidth, lineHeight, 10);
}

// This function plays the boundary beeps when the pointer is near the start or end of the line
// It also plays a beep when the pointer is at the top or bottom of the paragraph.
void playBoundaryBeeps(float pointerX, float pointerY, float startOfLineX, float endOfLineX, float paragraphTopY, float paragraphBottomY, float thresholdX, SoundFile EOLBeep, SoundFile TnBBeep)
{
  boolean nearStart = abs(pointerX - startOfLineX) <= thresholdX; // check if the pointer is near the start of the line
  boolean nearEnd = abs(pointerX - endOfLineX) <= thresholdX; // check if the pointer is near the end of the line
  boolean atTop = (pointerY <= paragraphTopY); // check if the pointer is near the top of the paragraph
  boolean atBottom = (pointerY >= paragraphBottomY); // check if the pointer is near the bottom of the paragraph

  /* Beep for the vertical movement */
  int currentVerticalZone;

  if (atTop)
  {
    currentVerticalZone = -1; // pointer is above the top boundary
  }
  else if (atBottom)
  {
    currentVerticalZone = 1; // pointer is below the bottom boundary
  }
  else
  {
    currentVerticalZone = 0; // pointer is inside the paragraph
  }

  // Only play sound when entering from above or below
  if ((lastVerticalZone == -1 && currentVerticalZone == 0) || (lastVerticalZone == 1 && currentVerticalZone == 0) || (lastVerticalZone == 0 && currentVerticalZone == -1) || (lastVerticalZone == 0 && currentVerticalZone == 1)) 
  {
    TnBBeep.stop();
    TnBBeep.play();
  }
  // Update the last zone
  lastVerticalZone = currentVerticalZone;

  /* Beep for the horizontal movement */
  if ((nearStart || nearEnd) && !isEOLBeepPlayed)
  {
    EOLBeep.stop();
    EOLBeep.play();
    isEOLBeepPlayed = true; // set the flag to true to prevent multiple beeps
  }
  else if (!nearStart && !nearEnd)
  {
    isEOLBeepPlayed = false; // reset the flag when the pointer is not near the start or end
  }
}

// Draw function - handles the GUI, text display, and serial communication
// This function is called repeatedly to update the display and handle user input
void draw()
{  
  // Background color adjustment
  background(gui.colorPicker("Background/Color").hex);
  
  // GUI for Language Selection
  String lang = gui.radio(
    "Language",
    new String[] {"English", "Korean"},
    defaultLanguage == Language.English ? "English" : "Korean"
  );
  if (lang.equals("English"))
  {
    defaultLanguage = Language.English;
    DTEXT = "This is it. \n The fight of our lives and we're going to win. Bla Bla Black Sheep have you any wool.\n Whatever it takes. \n And Hello World!";
    textFont(fontEnglish);
  }
  else if (lang.equals("Korean"))
  {
    defaultLanguage = Language.Korean;
    DTEXT = decompose(korDTEXT); // decompose the Korean text
    textFont(fontKorean);
  }

  // GUI for the Display Mode
  String displayMode = gui.radio(
    "Text Display/Mode",
    new String[] {"Button Mode", "Normal Mode"},
    defaultDisplayMode == textDisplayMode.normalMode ? "Normal Mode" : "Button Mode"
  );
  if (displayMode.equals("Button Mode"))
  {
    defaultDisplayMode = textDisplayMode.buttonMode;
  }
  else if (displayMode.equals("Normal Mode"))
  {
    defaultDisplayMode = textDisplayMode.normalMode;
  }

  // GUI for the Feature Selection
  String feature = gui.radio(
  "Braille Settings/Feature",
  new String[] {"Character Grouping", "Word Grouping", "Sliding Window"},
  defaultFeature == Feature.charGrouping ? "Character Grouping" :
  defaultFeature == Feature.wordGrouping ? "Word Grouping" :
  "Sliding Window"
  );

  if (feature.equals("Character Grouping"))
  {
    defaultFeature = Feature.charGrouping;
  }
  else if (feature.equals("Word Grouping"))
  {
    defaultFeature = Feature.wordGrouping;
  }
  else
  {
    defaultFeature = Feature.slidingWindow;
  }

  // Text Settings
  float extraSpacing = gui.sliderInt("Text Settings/Line Spacing", 10);
  float textSizeVal = gui.sliderInt("Text Settings/Text Size", 32);
  float boxHeightVal = gui.sliderInt("Text Settings/Box Height", 0);
  float margin = gui.sliderInt("Text Settings/ Margin", 100);

  // Handle the text input
  String text = gui.radio(
    "Text/Mode",
    new String[] {"Plain Text", "File"},
    defaultTextMode == textMode.plainTextMode ? "Plain Text" : "File"
  );
  if (text.equals("Plain Text"))
  {
    defaultTextMode = textMode.plainTextMode;
  }
  else if (text.equals("File"))
  {
    defaultTextMode = textMode.fileMode;
  }
  
  if (defaultTextMode == textMode.plainTextMode)
  {
    userInput = DTEXT; // display the text in the center of the screen
    gui.text("Text/Input", DTEXT);
    // Transformation of the text into lines
    float maxWidth = width - 2 * margin;
    lines = wrapText(userInput, maxWidth);
  }
  else if (defaultTextMode == textMode.fileMode)
  {
    lines = new String[10];
    if (defaultLanguage == Language.English)
    {
      arrayCopy(engLinesFromFile, randIndex, lines, 0, 10); // arrayCopy(src, srcPos, dest, destPos, length)
    }
    else if (defaultLanguage == Language.Korean)
    {
      arrayCopy(korLinesFromFile, randIndex, lines, 0, 10); // arrayCopy(src, srcPos, dest, destPos, length)
      //println(lines);
      String decomposed = decompose(lines[0]); 
      DTEXT = decomposed; // update text for display
    }
  }

  // // Transformation of the text into lines
  // float maxWidth = width - 2 * margin;
  // lines = wrapText(userInput, maxWidth);

  // Text Formatting 
  fill (255);                   // set the text colot to white
  textSize(textSizeVal);        // set the text size
  textAlign(LEFT, TOP);         // set the text alignment to left and top
  float textXStart = width / 2 - textWidth(userInput) / 2;            // set the text to the center of the screen
  float lineHeight = textAscent() + textDescent() + boxHeightVal;     // calculate the line height
  float totalTextHeight = lines.length * (lineHeight + extraSpacing); // calculate the total text height
  float textYStart = height / 2 - totalTextHeight / 2;                // set the text to the center of the screen 
  int currentLineIndex = -1;                                          // initialize the current line index

  // POINTER: Create and handle pointer mode using radio buttons
  String pointerMode = gui.radio("Pointer/Mode", new String[] {"Square", "Circle"});

  if (defaultDisplayMode == textDisplayMode.buttonMode)
  {
    float lineY = textYStart; // line Y position (top end)

    float lineXStart = margin; // set the line X position (left end)

    currentLineIndex = textIndex; // set the current line index to the text index
    String currentLine = lines[textIndex]; // get the current line

    if (defaultFeature == Feature.charGrouping)
    {
      charGroupingFrequency = gui.sliderInt("Braille Settings/Character Grouping Frequency", defaultCharGrouping_FREQ, 1, 8); // set the character grouping frequency
      charGroupingFeature(currentLine, charGroupingFrequency, margin, lineY, lineHeight, boxHeightVal); // call the charGroupingFeature function
    }
    else if (defaultFeature == Feature.slidingWindow)
    {
      slidingWindowFrequency = gui.sliderInt("Braille Settings/Sliding Window Frequenxcy", defaultSlidingWindow_FREQ, 1, 8); // set the sliding window frequency
      slidingWindowFeature(currentLine, slidingWindowFrequency, margin, lineY, lineHeight, boxHeightVal); // call the slidingWindowFeature function
    }
    else if (defaultFeature == Feature.wordGrouping)
    {
      wordGroupingFeature(currentLine, margin, lineY, lineHeight, boxHeightVal); // call the wordGroupingFeature function
    }

    int activeLineIndex = textIndex; // set the active line index to the text index
    float pointerX = constrain(mouseX, margin, margin + textWidth(currentLine)); // constrain the pointer X position
    float pointerY = textYStart + lineHeight / 3; // calculate the pointer Y position (centered vertically in the line)
    float paragraphTopY = textYStart; // set the paragraph top Y position
    float paragraphBottomY = textYStart + lineHeight + extraSpacing; // set the paragraph bottom Y position

    pointer(pointerMode, pointerX, pointerY); // call the pointer function to draw the pointer

    // no need for change of line beep in button mode, as the text is displayed in a single line
    
    float thresholdX = 8; // threshold for the ends of line beep in pixels
    playBoundaryBeeps(pointerX, mouseY, margin, margin + textWidth(currentLine), paragraphTopY, paragraphBottomY, thresholdX, EOLBeep, TopandBottomBeep); // play the end of line beep
  }

  else if (defaultDisplayMode == textDisplayMode.normalMode)
  {
    // iterating through the lines of text
    for (int i = 0; i < lines.length; i++)
    {
      float lineY = textYStart + i * (lineHeight + extraSpacing); // calculate the line Y position (top end)

      if (mouseY >= lineY && mouseY < (lineY + lineHeight))
      {
        currentLineIndex = i;           // set the current line index
      }
      float lineXStart = margin;        // set the line X position (left end)
    
      String currentLine = lines[i]; // get the current line  
    
      /* WHEN THE CHARACTER GROUPING FEATURE IS ACTIVE */
      if (defaultFeature == Feature.charGrouping)
      {
        // set the character grouping frequency
        charGroupingFrequency = gui.sliderInt("Braille Settings/Character Grouping Frequency", defaultCharGrouping_FREQ, 1, 8);
        charGroupingFeature(currentLine, charGroupingFrequency, margin, lineY, lineHeight, boxHeightVal); // call the charGroupingFeature function
      }

      /* WHEN THE SLIDING WINDOW FEATURE IS ACTIVE */
      else if (defaultFeature == Feature.slidingWindow)
      { 
        slidingWindowFrequency = gui.sliderInt("Braille Settings/Sliding Window Frequency", defaultSlidingWindow_FREQ, 1, 8); // set the sliding window frequency
        slidingWindowFeature(currentLine, slidingWindowFrequency, margin, lineY, lineHeight, boxHeightVal); // call the slidingWindowFeature function
      }

      /* WHEN THE WORD GROUPING FEATURE IS ACTIVE */
      else if (defaultFeature == Feature.wordGrouping)
      {
        wordGroupingFeature(currentLine, margin, lineY, lineHeight, boxHeightVal); // call the wordGroupingFeature function
      }
    }

    int activeLineIndex = (int) constrain((mouseY - textYStart) / (lineHeight + extraSpacing), 0, lines.length - 1); // calculate the active line index
    float pointerX = constrain(mouseX, margin, margin + textWidth(lines[activeLineIndex])); // constrain the pointer X position 
    float pointerY = textYStart + activeLineIndex * (lineHeight + extraSpacing) + lineHeight / 3; // calculate the pointer Y position
    float paragraphTopY = textYStart; // set the paragraph top Y position
    float paragraphBottomY = textYStart + (lines.length) * (lineHeight + extraSpacing); // set the paragraph bottom Y position
    
    pointer(pointerMode, pointerX, pointerY); // call the pointer function to draw the pointer)
    
    // Handle the change of line and end of line beeps
    if (currentLineIndex != -1 && currentLineIndex != previousLineIndex)
    {
      COLBeep.stop();  // stop any current playback
      COLBeep.play(); // play the sound
      previousLineIndex = currentLineIndex; // update the previous line index
    }
    float thresholdX = 8; // threshold for the ends of line beep in pixels
    playBoundaryBeeps(pointerX, mouseY, margin, margin + textWidth(lines[activeLineIndex]), paragraphTopY, paragraphBottomY, thresholdX, EOLBeep, TopandBottomBeep); // play the end of line beep
  }
}


void serialEvent(Serial myPort)
{
  String inString = myPort.readStringUntil('\n'); // read the string until the newline character
  if (inString != null) 
  {
    inString = trim(inString); // trim the string to remove any leading or trailing whitespace
    println(inString); // Debugging log
    if (inString.equals("NEXT"))
    {
      textIndex = (textIndex + 1) % lines.length;
      //DTEXT = lines[textIndex]; // update the text to the next sample text
      //println("Switched to next line: " + DTEXT);
    }
    else if (inString.equals("PREV"))
    {
      textIndex = (textIndex - 1 + lines.length) % lines.length; // wrap around to the last line if we go below 0
      //DTEXT = lines[textIndex]; // update the text to the previous sample text
      //println("Switched to previous line: " + DTEXT);
    }
    else if (inString.equals("IDLE"))
    {
      println("Idle command received. No action taken.");
    }
  }
}

void charGroupingFeature(String line, int frequency, float margin, float lineTopEnd, float lineHeight, float boxHeight)
{
  float lineLeftEnd = margin; // set the line left end position

  // First pass: draw the text
  drawText(line, lineLeftEnd, lineTopEnd + boxHeight / 2); // draw the text by centering it vertically in the box 

  // Second pass: create the groups and draw the box around the text
  int groupSize = frequency; // set the group size
  for (int j = 0; j < line.length(); j+= groupSize)
  {
    int endIndex = min(j + groupSize, line.length());
    String group = line.substring(j, endIndex); // create the group of characters

    // measure the width of the group
    float groupWidth = 0;
    for (int k = j; k < endIndex; k++)
    {
      groupWidth += textWidth(line.charAt(k));
    }
    // prevent text overflow
    if (lineLeftEnd + groupWidth > width - margin)
    {
      println("Text Overflow Prevented!");
      lineLeftEnd = margin; // reset the line X position
    }

    // Draw bounding box
    drawGroupBox(lineLeftEnd, lineTopEnd, groupWidth, lineHeight);

    // Sending the group to the Arduino
    if (mouseX >= lineLeftEnd && mouseX <= lineLeftEnd + groupWidth && mouseY >= lineTopEnd && mouseY <= lineTopEnd + lineHeight)
    {
      if (!group.equals(lastSentGroup))
      {
        sendToBrailleGroup(group, "*", "@", 0, 0); // send the group to the Arduino
        lastSentGroup = group; // update the last sent group
      }
    }
    lineLeftEnd += groupWidth; // update the group X position for the next group
  }
}

void slidingWindowFeature(String line, int frequency, float margin, float lineTopEnd, float lineHeight, float boxHeight)
{
  float lineLeftEnd = margin; // set the line left end position
  int slidingWindowSize = frequency; // set the sliding window size
  int leftRightChars; // number of characters to the left and right of the current character
  int startIndex, endIndex; // start and end index for the sliding window
  String tempGroup; // temporary group to hold the characters
  String group; // final group to be sent to Serial
  int spacesLeft = 0, spacesRight = 0; // used as padding for the group

  if (slidingWindowSize % 2 != 0)
  {
    leftRightChars = (slidingWindowSize - 1) / 2; // calculate the number of characters to the left and right of the current character
  }
  else
  {
    leftRightChars = slidingWindowSize / 2; // calculate the number of characters to the left and right of the current character
  }
  
  // First Pass: Draw the text
  drawText(line, lineLeftEnd, lineTopEnd + boxHeight / 2); // draw the text by centering it vertically in the box

  for (int j = 0; j < line.length(); j++)
  {
    int endIndexforBox = Math.min(j + 1, line.length());
    String groupforBox = line.substring(j, endIndexforBox); // create the group of characters for the bounding box

    float groupWidthforBox = 0; // measure the width of the group
    for (int k = j; k < endIndexforBox; k++)
    {
      groupWidthforBox += textWidth(line.charAt(k));
    }

    // Prevent text Overflow
    if (lineLeftEnd + groupWidthforBox > width - margin)
    {
      println("Text Overflow Prevented!");
      lineLeftEnd = margin; // reset the line X position
    }

    // Second Pass: Draw the bounding box around the group
    drawGroupBox(lineLeftEnd, lineTopEnd, groupWidthforBox, lineHeight); 

    char[] groupArray = new char[slidingWindowSize]; // create an array to hold the characters in the group
    for (int arrIndex = 0; arrIndex < slidingWindowSize; arrIndex++)
    {
      groupArray[arrIndex] = ' '; // fill the array with spaces
    }

    if (j - leftRightChars < 0) // Edge Case: when the mouse doesn't have enough chars to left
    {
      if (slidingWindowSize % 2 != 0)
      {
        spacesLeft = leftRightChars - j; // determine how many spaces to pad on the left
        startIndex = 0; // start index for the substring
        endIndex = Math.min(line.length(), j + leftRightChars + 1); // Use as many characters as possible from the beginning, but do not exceed the string length
        tempGroup = line.substring(startIndex, endIndex); // create the temporary group
        for (int pos = 0; pos < tempGroup.length(); pos++)
        {
          groupArray[spacesLeft + pos] = tempGroup.charAt(pos); // fill the padded array: leave left "spaces" as blank and then add the substring
        }
      }
      else
      {
        spacesLeft = leftRightChars - j - 1; // determine how many spaces to pad on the left
        startIndex = 0; // start index for the substring
        endIndex = Math.min(line.length(), j + leftRightChars + 1); // Use as many characters as possible from the beginning, but do not exceed the string length
        tempGroup = line.substring(startIndex, endIndex); // create the temporary group
        for (int pos = 0; pos < tempGroup.length(); pos++)
        {
          groupArray[spacesLeft + pos] = tempGroup.charAt(pos); // fill the padded array: leave left "spaces" as blank and then add the substring
        }
      }
    }
    else // Normal Case: there are enough characters to the left
    {
      spacesLeft = 0; // reset the spaces
      
      if (slidingWindowSize % 2 != 0)
      {
        startIndex = j - leftRightChars; // start index for the substring
        endIndex = Math.min(line.length(), j + leftRightChars + 1); // Use as many characters as possible from the left and right, but do not exceed the string length
        tempGroup = line.substring(startIndex, endIndex); // create the temporary group
        for (int pos = 0; pos < tempGroup.length(); pos++)
        {
          groupArray[pos] = tempGroup.charAt(pos); // fill the array with the characters from the temporary group
        }
      }
      else 
      {
        startIndex = j - (leftRightChars - 1); // start index for the substring
        endIndex = Math.min(line.length(), j + leftRightChars + 1); //
        tempGroup = line.substring(startIndex, endIndex); // create the temporary group
        for (int pos = 0; pos < tempGroup.length(); pos++)
        {
          groupArray[pos] = tempGroup.charAt(pos); // fill the array with the characters  
        }
      }
    }

    spacesRight = groupArray.length - spacesLeft - tempGroup.length();
    group = String.valueOf(groupArray); // convert the character array to a string

    // If the Edge case is active, prevent the text overflow by adjusting the drawing x-coordinate, which is the position of the character in the line
    // The padding is calculated based on the number of spaces in the group
    // The X position of the character is calculated by subtracting the padding width from the end of the line left end and adding the width of the characters before the current character
    // This ensures that the character is drawn at the correct position in the line, even if there are spaces in the group
    
    /*float padWidth = spaces * textWidth(' '); // calculate the padding width
    float charX = lineLeftEnd + textWidth(line.substring(0, j)) - padWidth;

    if (charX + textWidth(group) > width)
    {
      charX = margin; // reset the line X position if the character goes beyond the width of the screen
    }*/

    for (int charIndex = 0; charIndex < tempGroup.length(); charIndex++)
    {
      float charWidth = textWidth(tempGroup.charAt(charIndex)); //measure the width of the character

      if (mouseX >= lineLeftEnd && mouseX <= lineLeftEnd + charWidth / 2 && mouseY >= lineTopEnd && mouseY <= lineTopEnd + lineHeight)
      {
        if (!group.equals(lastSentGroup)) // send only if this is a new group
        {
          sendToBrailleGroup(tempGroup, "#", "+", spacesLeft, spacesRight); // send the group to the Arduino
          lastSentGroup = group; // update the last sent group
        }
      }
    }
    lineLeftEnd += groupWidthforBox; // update the line left end position for the next group
  }
}

void wordGroupingFeature(String line, float margin, float lineTopEnd, float lineHeight, float boxHeight)
{
  float lineLeftEnd = margin; // set the line left end position
  
  // First Pass: draw the text
  drawText(line, lineLeftEnd, lineTopEnd + boxHeight / 2); // draw the text by centering it vertically in the box

  // Second Pass: create the groups and draw the box around the text
  String[] words = line.split(" "); // split the line into words
  int charPointer = 0; // character pointer to track the position in the line for KOR
  for (String word : words)
  {
    float wordWidth = textWidth(word); // measure the width of the word
    
    // Prevent text Overflow
    if (lineLeftEnd + wordWidth > width - margin)
    {
      println("Text Overflow Prevented!");
      lineLeftEnd = margin; // reset the line X position
    }

    drawGroupBox(lineLeftEnd, lineTopEnd, wordWidth, lineHeight); // draw the bounding box

    int startIndex = charPointer; // start index for the word
    int endIndex = charPointer + word.length(); // end index for the word

    // Third pass: sending the group to the Arduino and handling pointer interaction
    if (mouseX >= lineLeftEnd && mouseX <= lineLeftEnd + wordWidth && mouseY >= lineTopEnd && mouseY <= lineTopEnd + lineHeight)
    {
      if (!word.equals(lastSentGroup))
      {
        sendToBrailleGroup(word, "^", "|", 0, 0); // send the group to the Arduino
        lastSentGroup = word; // update the last sent group
      }
    }
    charPointer += word.length() + 1; // update the character pointer for the next word (including space)
    lineLeftEnd += wordWidth + textWidth(' '); // update the line left end position for the next word
  }
}

void pointer(String mode, float pointerX, float pointerY)
{
  if (mode.equals("Square"))
  {
    noStroke();
    fill(255, 0, 0); // set the pointer color to red
    rect(pointerX, pointerY, 20, 20); // draw the square pointer
  }
  else if (mode.equals("Circle"))
  {
    noStroke();
    fill(0, 0, 255); // set the pointer color to blue
    ellipse(pointerX, pointerY, 20, 20); // draw the circle pointer
  }
}
