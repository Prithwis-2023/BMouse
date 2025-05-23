// imports
import com.krab.lazy.*;
import processing.serial.*;
import processing.sound.*;



// TODO: Change the constants used to set the mode into an enum.   
enum Mode {charGrouping, wordGrouping, slidingWindow}; 
mode defaultMode = Mode.wordGrouping; // default mode

// constants
/* we have three display modes:
 * 1. charGrouping: displays characters in groups of DB_FREQ
 * 2. wordGrouping: displays words in groups  of the word length
 * 3. slidingWindow: displays a sliding window of characters
 */
final boolean slidingWindow = false;  // sliding window feature toggle
final boolean charGrouping = false;  // character grouping feature toggle
final boolean wordGrouping = true;  // word grouping feature toggle

final int defaultCharGrouping_FREQ = 5;  // character group frequency for charGrouping feature
final int defaultSlidingWindow_FREQ = 8;  // sliding window frequency for slidingWindow feature. Can be 1, 3, 5 or 8
final String DTEXT = "Welcome to a delightful afternoon of exploration and creativity!";  // custom text

// Sound
SoundFile EOLBeep; 
SoundFile COLBeep;
boolean isEOLBeepPlayed = false;
boolean mouseWasInsideLine = false;

// Serial Port
Serial myPort;
String portName = Serial.list()[0];  // default port

// GUI
LazyGui gui;

// Others
int previousLineIndex = -1;  // previous line index
int charGroupingFrequency;
String slidingWindowState; // stores the state of the sliding window
String wordGroupingState;  // stores the state of the word grouping
String userInput = "";
String lastSentGroup = "";

// Clears GUI Data
void clearGUIData()
{
    File autoSaveFile = new File(dataPath("BrailleMouseRefactored/saves/auto.json"));
    if (autoSaveFile.exists()) 
    {
        autoSaveFile.delete();
    }
}

// Setup function - GUI, Serial, Sound
void setup()
{
    fullScreen(P2D); // Ensures compatibility with LazyGui

    // Initialize LazyGui
    gui = new LazyGui(this, new LazyGuiSettings()
      .setAutosaveOnExit(false)
      .setLoadLatestSaveOnStartup(false)
    ); 
       
    myPort = new Serial(this, portName, 9600);
    
    EOLBeep = new SoundFile(this, "endOfLineBeep.mp3");
    COLBeep = new SoundFile(this, "ChangeOfLine.mp3");
}

// function to send the group to the Arduino
void sendToBrailleGroup(String group, String startMarker, String endMarker)
{
  if (myPort != null)
  {
    String groupSent = startMarker + group + endMarker;
    myPort.write(groupSent);
    println("Sent to Arduino: " + groupSent); // Debugging output
  }
  else
  {
    println("Serial port not initialized.");
  }
  delay(1);
}

// function to auto generate multiple lines of text
String[] wrapText(String text, float maxWidth)
{
    String[] words = splitTokens(text);
    ArrayList<String> lines = new ArrayList<String>();
    String currentLine = "";
    
    for (String word : words)
    {
        if (textWidth(currentLine + word) > maxWidth)
        {
            lines.add(currentLine);
            currentLine = "";
        }
        currentLine += word + " ";
    }
    
    if (currentLine.length() > 0)
    {
        lines.add(currentLine);
    }
    
    return lines.toArray(new String[0]);
}

// function to detect the mode of operation
void detectMode(boolean slidingWindowToggle, boolean charGroupingToggle, boolean wordGroupingToggle)
{
  if ((!slidingWindowToggle && charGroupingToggle) || (slidingWindowToggle && !charGroupingToggle) || (wordGroupingToggle && !slidingWindowToggle && !charGroupingToggle))
  {
    if (charGroupingToggle == true)
    {
      charGroupingFrequency = gui.sliderInt("Braille Settings/Character Grouping Frequency", defaultCharGrouping_FREQ, 1, 8);
      slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "Off");
      wordGroupingState = gui.radio("Braille Settings/Word Grouping", new String[] {"Off", "On"}, "Off");
    }
    else if (slidingWindowToggle == true)
    {
      slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "On");
      wordGroupingState = gui.radio("Braille Settings/Word Grouping", new String[] {"Off", "On"}, "Off");
    }
    else if (wordGroupingToggle == true)
    {
      wordGroupingState = gui.radio("Braille Settings/Word Grouping", new String[] {"Off", "On"}, "On");
      slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "Off");
    }
  }
}

void drawText(String presentLine, float PosX, float PosY)
{
  fill(255); // set the text color to white
  noStroke();
  text(presentLine, PosX, PosY); // draw the text
}

/*
call this function from any mode, passing it:
groupX: where it starts in x
lineY: vertical position of the line
groupWidth: measured width
lineHeight: height of the line box 
*/
void drawGroupBox(float groupX, float lineY, float groupWidth, float lineHeight)
{
  noFill();
  stroke(234, 220, 0);
  rect(groupX, lineY, groupWidth, lineHeight, 10);
}

void playEOLBeep(float pointerX, float startOfLineX, float endOfLineX, float threshold, SoundFile Beep)
{
  boolean nearStart = abs(pointerX - startOfLineX) <= threshold; // check if the pointer is near the start of the line
  boolean nearEnd = abs(pointerX - endOfLineX) <= threshold; // check if the pointer is near the end of the line
  if ((nearStart || nearEnd) && !isEOLBeepPlayed)
  {
    Beep.stop();
    Beep.play();
    isEOLBeepPlayed = true; // set the flag to true to prevent multiple beeps
  }
  else if (!nearStart && !nearEnd)
  {
    isEOLBeepPlayed = false; // reset the flag when the pointer is not near the start or end
  }
}
void draw()
{
  // Background color adjustment
  background(gui.colorPicker("Background/Color").hex);

  // detect the mode of operation
  detectMode(slidingWindow, charGrouping, wordGrouping);

  // Handle the text input 
  userInput = gui.text("Text/Input", DTEXT);

  // Text Settings
  float extraSpacing = gui.sliderInt("Text Settings/Line Spacing", 10);
  float textSizeVal = gui.sliderInt("Text Settings/Text Size", 32);
  float boxHeightVal = gui.sliderInt("Text Settings/Box Height", 0);
  float margin = gui.sliderInt("Text Settings/ Margin", 100);

  PFont font;
  String fontStyle = gui.radio(
    "Text Settings/Font Style",
    new String[] {
      "MapleMono-Bold",
      "MapleMono-BoldItalic",
      "MapleMono-ExtraBold",
      "MapleMono-ExtraBoldItalic",
      "MapleMono-ExtraLight",
      "MapleMono-ExtraLightItalic",
      "MapleMono-Italic",
      "MapleMono-Light",
      "MapleMono-LightItalic",
      "MapleMono-Medium",
      "MapleMono-MediumItalic",
      "MapleMono-Regular",
      "MapleMono-SemiBold",
      "MapleMono-SemiBoldItalic",
      "MapleMono-Thin",
      "MapleMono-ThinItalic"
    },
    "MapleMono-SemiBold"
  );
  String fontFileName = fontStyle + ".otf";
  font = createFont(fontFileName, 32);
  textFont(font);

  // transformation of the text into lines
  float maxWidth = width - 2 * margin;
  String[] lines = wrapText(userInput, maxWidth);

  // Text Formatting 
  fill (255);                   // set the text colot to white
  textSize(textSizeVal);        // set the text size
  textAlign(LEFT, TOP);         // set the text alignment to left and top
  float textXStart = width / 2 - textWidth(userInput) / 2;            // set the text to the center of the screen
  float lineHeight = textAscent() + textDescent() + boxHeightVal;     // calculate the line height
  float totalTextHeight = lines.length * (lineHeight + extraSpacing); // calculate the total text height
  float textYStart = height / 2 - totalTextHeight / 2;                // set the text to the center of the screen 
  
  int currentLineIndex = -1; // initialize the current line index

  // iterating through the lines of text
  for (int i = 0; i < lines.length; i++)
  {
    float lineY = textYStart + i * (lineHeight + extraSpacing); // calculate the line Y position (top end)

    if (mouseY >= lineY && mouseY < (lineY + lineHeight))
    {
      currentLineIndex = i;           // set the current line index
    }
    float lineXStart = margin;        // set the line X position (left end)
    float visibleStartX = lineXStart; // initializa the visible start X position
    float visibleEndX = lineXStart;   // initialize the visible end X position
  
    String currentLine = lines[i]; // get the current line  
  
    /* WHEN THE CHARACTER GROUPING FEATURE IS ACTIVE */
    if (defaultMode == Mode.charGrouping)
    {
      /* First Pass: draw the text */ 
      drawText(currentLine, lineXStart, lineY + boxHeightVal / 2); // draw the text

      /* Second Pass: create the groups and draw the box around the text */
      int groupSize = charGroupingFrequency; // set the group size
      for (int j = 0; j < currentLine.length(); j += groupSize)
      {
        int endIndex = min(j + groupSize, currentLine.length());
        String group = currentLine.substring(j, endIndex); // get the group of characters

        // measure the width of the group
        float groupWidth = 0;
        for (int k = j; k < endIndex; k++)
        {
          groupWidth += textWidth(currentLine.charAt(k));
        }
        // prevent text overflow
        if (lineXStart + groupWidth > width - margin)
        {
          println("Text Overflow Prevented!");
          lineXStart = margin; // reset the line X position
        }
        // Draw bounding box
        drawGroupBox(lineXStart, lineY, groupWidth, lineHeight);

        /* Handle pointer interaction */
        if (mouseX >= lineXStart && mouseX <= lineXStart + groupWidth && mouseY >= lineY && mouseY <= lineY + lineHeight)
        {
          if (!group.equals(lastSentGroup))
          {
            // send only if this is a new group
            sendToBrailleGroup(group, "*", "@");
            lastSentGroup = group; // update the last sent group
          }
        }

        lineXStart += groupWidth; // update the group X position for the next group
        visibleEndX = lineXStart; // update the visible start X position
      }
    }

    /* WHEN THE SLIDING WINDOW FEATURE IS ACTIVE */
    else if (defaultMode == Mode.slidingWindow)
    { 
      /*First Pass" Draw the text */
      drawText(currentLine, lineXStart, lineY + boxHeightVal / 2); // draw the text
      
      int slidingWindowSize = defaultSlidingWindow_FREQ; // 
      int leftRightChars;
      if (slidingWindowSize % 2 != 0)
      {
        leftRightChars = (slidingWindowSize - 1) / 2;
      }
      else
      {
        leftRightChars = slidingWindowSize / 2;
      }
      
      for (int j = 0; j < currentLine.length(); j++) 
      {
        int boundingBoxEndIndex = Math.min(j + 1, currentLine.length());
        String charGroupBoundingBox = currentLine.substring(j, boundingBoxEndIndex);
          
        float groupWidthBoundingBox = 0;
          
        for (int k = j; k < boundingBoxEndIndex; k++)
        {
          groupWidthBoundingBox += textWidth(currentLine.charAt(k));
        }
          
        // Prevent text overflow
        if (lineXStart + groupWidthBoundingBox > width - margin) 
        {
          println("Text overflow prevented!");
          lineXStart = textXStart; // reset the line X position
        }

        drawGroupBox(lineXStart, lineY, groupWidthBoundingBox, lineHeight);

        char[] groupArray = new char[slidingWindowSize];
          
        for (int arrIndex = 0; arrIndex < slidingWindowSize; arrIndex++)
        {
          groupArray[arrIndex] = ' ';
        }
          
        int startIndex, endIndex; 
        String charGroup; // temporary group to hold the characters
        String group;     // final group to be sent to Serial
        int spaces = 0;   // used as padding for the group
        // Edge case: if the mouse doesn't have enough characters to the left
        if (j - leftRightChars < 0) 
        {
          if (slidingWindowSize % 2 != 0)
          {
            spaces = leftRightChars - j; // Determine how many spaces to pad on the left
            startIndex = 0;
            endIndex = Math.min(currentLine.length(), j + leftRightChars + 1); // Use as many characters as possible from the beginning, but do not exceed the string length
            charGroup = currentLine.substring(startIndex, endIndex);
            // Fill the padded array: leave left "spaces" as blank and then add the substring
            for (int pos = 0; pos < charGroup.length(); pos++) 
            {
              groupArray[spaces + pos] = charGroup.charAt(pos);
            }
          }
          else  
          {
            spaces = leftRightChars - j - 1;
            startIndex = 0;
            endIndex = Math.min(currentLine.length(), j + leftRightChars + 1);
            charGroup = currentLine.substring(startIndex, endIndex);
              
            for (int pos = 0; pos < charGroup.length(); pos++)
            {
              groupArray[spaces + pos] = charGroup.charAt(pos);
            }
          }
        } 
        else 
        {
          // Normal case: there are enough characters on the left.
          if (slidingWindowSize % 2 != 0)
          {
            startIndex = j - leftRightChars;
            endIndex = Math.min(currentLine.length(), j + leftRightChars + 1);
            charGroup = currentLine.substring(startIndex, endIndex);
            for (int pos = 0; pos < charGroup.length(); pos++) 
            {
              groupArray[pos] = charGroup.charAt(pos);
            }
          }
          else
          {
            startIndex = j - (leftRightChars - 1);
            endIndex = Math.min(currentLine.length(), j + leftRightChars + 1);
            charGroup = currentLine.substring(startIndex, endIndex);
            for (int pos = 0; pos < charGroup.length(); pos++)
            {
              groupArray[pos] = charGroup.charAt(pos);
            }
          }
        }
          
        group = String.valueOf(groupArray);
          
        // Adjust the drawing x-coordinate if the edge case is active.
        float padWidth = spaces * textWidth(' ');
        float charX = textXStart + textWidth(currentLine.substring(0, j)) - padWidth;
          
        // Prevent text overflow
        if (charX + textWidth(charGroup) > width) 
        {
          charX = textXStart;
        }
      
        // Render characters, avoiding duplicates
        for (int charIndex = 0; charIndex < charGroup.length(); charIndex++) 
        {
          float charWidth = textWidth(charGroup.charAt(charIndex));
            
          // Check if the pointer is inside the current group's bounding box
          if (mouseX >= lineXStart && mouseX <= lineXStart + charWidth - 0.5 && mouseY >= lineY && mouseY <= lineY + lineHeight) 
          {
            if (!group.equals(lastSentGroup)) 
            { 
              // Send only if this is a new group
              sendToBrailleGroup(group, "#", "+");
              lastSentGroup = group; // Updating the last sent group
            }
          }
          charX += charWidth;
        }
        lineXStart += groupWidthBoundingBox;
        visibleEndX = lineXStart; // update the visible end X position
      }
    }

    /* WHEN THE WORD GROUPING FEATURE IS ACTIVE */
    else if (defaultMode == Mode.wordGrouping)
    {
      /* FIRST PASS: Draw the text */
      drawText(currentLine, lineXStart, lineY + boxHeightVal / 2);
      
      /* SECOND PASS: create the groups and draw the box around the text */
      String[] words = currentLine.split(" "); // split the line into words
      for (String word: words)
      {
        float wordWidth = textWidth(word); // measure the width of the word

        if (lineXStart + wordWidth > width - margin)
        {
          println("Text Overflow Prevented!");
          lineXStart = margin; // reset the line X position
        }
        drawGroupBox(lineXStart, lineY, wordWidth, lineHeight); // draw the bounding box
        
        // Handle pointer interaction
        if (mouseX >= lineXStart && mouseX <= lineXStart + wordWidth && mouseY >= lineY && mouseY <= lineY + lineHeight)
        {
          if (!word.equals(lastSentGroup))
          {
            // send only if this is a new group
            sendToBrailleGroup(word, "^", "|");
            lastSentGroup = word; // update the last sent group
          }
        }
        lineXStart += wordWidth + textWidth(' '); // update the line X position for the next word
        visibleEndX = lineXStart; // update the visible end X position
      }
    }
  }

  // POINTER: Create and handle pointer mode using radio buttons
  String mode = gui.radio("Pointer/Mode", new String[] {"Square", "Circle"});

  // draw the pointer based on the selection mode
  int activeLineIndex = (int) constrain((mouseY - textYStart) / (lineHeight + extraSpacing), 0, lines.length - 1); // calculate the active line index
  float pointerX = constrain(mouseX, margin, margin + textWidth(lines[activeLineIndex])); // constrain the pointer X position 
  float pointerY = textYStart + activeLineIndex * (lineHeight + extraSpacing) + lineHeight / 3; // calculate the pointer Y position
  
  if (mode.equals("Square"))
  {
    noStroke();
    fill(255, 0, 0); // set the pointer color to red
    rect(pointerX, pointerY, 20, 20); // draw the square pointer
  }
  else if (mode.equals("Circle"))
  {
    noStroke();
    fill(0, 0, 255); // set the pointer color to red
    ellipse(pointerX, pointerY, 20, 20); // draw the circle pointer
  }

  // Handle the change of line beep
  if (currentLineIndex != -1 && currentLineIndex != previousLineIndex)
  {
    COLBeep.stop();  // stop any current playback
    COLBeep.play(); // play the sound

    previousLineIndex = currentLineIndex; // update the previous line index
  }
  
  // Handle the end of line beep
  float threshold = 8; // threshold for the ends of line beep
  playEOLBeep(pointerX, margin, margin + textWidth(lines[activeLineIndex]), threshold, EOLBeep); // play the end of line beep
}


