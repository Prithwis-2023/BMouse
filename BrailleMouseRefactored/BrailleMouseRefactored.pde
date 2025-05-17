// imports
import com.krab.lazy.*;
import processing.serial.*;
import processing.sound.*;

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

// GUI and Arduino
Serial myPort;
String portName = Serial.list()[0];  // default port

LazyGui gui;

void clearGUIData()
{
    File autoSaveFile = new File(dataPath("BrailleMouseRefactored/saves/auto.json"));
    if (autoSaveFile.exists()) 
    {
        autoSaveFile.delete();
    }
}

// Others
int prevLineIndex = -1;  // previous line index
int charGroupingFrequency;
String slidingWindowState; // stores the state of the sliding window
String wordGroupingState;  // stores the state of the word grouping
String userInput = "";
String lastSentGroup = "";

// setup function
void setup()
{
    fullScreen(P2D); // Ensures compatibility with LazyGui

    // Initialize LazyGui
    gui = new LazyGui(this, new LazyGuiSettings()
      .setAutosaveOnExit(false)
      .setLoadLatestSaveOnStartup(false)
    ); 
       
    String portName = Serial.list()[0];
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

// function to handle the end of line sound beep
void handleEOLBeep(boolean isInsideLine, boolean wasInsideLine)
{
  if (!isInsideLine && wasInsideLine)
  {
    EOLBeep.stop();  // stop any current playback
    EOLBeep.play();
    isEOLBeepPlayed = true;
  }
}

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

void drawText(String presentLine, float startPosX, float startPosY, float boundingBoxHeight)
{
  fill(255); // set the text color to white
  noStroke();
  text(presentLine, startPosX, startPosY + boundingBoxHeight / 2); // draw the text
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
  float margin = gui.sliderInt("Text Settings/ Margin", 100)

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

  // Text Formatting 
  fill (255); // set the text colot to white
  textSize(textSizeVal); // set the text size
  textAlign(LEFT, TOP); // set the text alignment to left and top
  float textXStart = width / 2 - textWidth(userInput) / 2; // set the text to the center of the screen
  float lineHeight = textAscent() + textDescent() + boxHeightVal; // calculate the line height
  float totalTextHeight = lines.length * (lineHeight + extraSpacing); // calculate the total text height
  float textYStart = height / 2 - totalTextHeight / 2; // set the text to the center of the screen 
  
  // transformation of the text into lines
  float maxWidth = width - 2 * margin;
  String[] lines = wrapText(userInput, maxWidth);

  int currentLineIndex = -1; // initialize the current line index

  // iterating through the lines of text
  for (int i = 0; i < lines.length; i++)
  {
    float lineY = textYStart + i * (lineHeight + extraSpacing); // calculate the line Y position (top end)

    if (mouseY >= lineY && mouseY < (lineY + lineHeight))
    {
      currentLineIndex = i; // set the current line index
    }
    float lineXStart = margin; // set the line X position (left end)
    float visibleStartX = lineXStart; // initializa the visible start X position
    float visibleEndX = lineXStart; // initialize the visible end X position
  
    String currentLine = lines[i]; // get the current line
  
    // when the character grouping feature is active
    if (slidingWindowState.equals("Off") && wordGroupingState.equals("Off"))
    {
      /* First Pass: draw the text */ 
      drawText(currentLine, lineXStart, lineY + boxHeightVal / 2); // draw the text

      /* Second Pass: draw the box around the text */
      int groupSize = charGroupingFrequency; // set the group size
      int groupX = lineXStart; // set the group X position
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
        if (groupX + groupWidth > width - margin)
        {
          println("Text Overflow Prevented!");
          lineXStart = margin; // reset the line X position
        }
        // Draw bounding box
        noFill();
        stroke(234, 220, 0);
        rect(groupX, lineY, groupWidth, lineHeight, 10); 

        /* Handle pointer interaction */
        if (mouseX >= groupX && mouseX <= groupX + groupWidth && mouseY >= lineY && mouseY <= lineY + lineHeight)
        {
          if (!group.equals(lastSentGroup))
          {
            // send only if this is a new group
            sendToBrailleGroup(group, "*", "@");
            lastSentGroup = group; // update the last sent group
          }
        }

        groupX += groupWidth; // update the group X position for the next group
        visibleEndX = groupX; // update the visible start X position
      }
    }
  
  }
}


