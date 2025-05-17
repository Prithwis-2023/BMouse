import com.krab.lazy.*;
import processing.serial.*;
import processing.sound.*;

SoundFile EOLBeep; SoundFile COLBeep;
boolean isEOLBeepPlayed = false;
boolean mouseWasInsideLine = false;

int prevLineIndex = -1;

final int DB_FREQ = 5;
final String DTEXT = "Welcome to a delightful afternoon of exploration and creativity!";  // "Enter your text here"

// braille setting
final boolean slidingWindow = false; final boolean charGrouping = true; final boolean wordGrouping = false;
final int slidingWindowGrouping = 8;  // 1, 3, 5, and 8
int brailleFrequency;

String slidingWindowState; // Stores "Off" or "On"
String wordGroupingState;

Serial myPort;
String portName = "COM6";

LazyGui gui;
String userInput = "";
String lastSentGroup = "";

void clearGUIData()
{
  File autoSaveFile = new File(dataPath("gui/BrailleMouseNewUI/saves/auto.json"));
  if (autoSaveFile.exists())
  {
     autoSaveFile.delete();
  }
}

void setup()
{
    fullScreen(P2D); // Ensures compatibility with LazyGui

    gui = new LazyGui(this, new LazyGuiSettings()
      .setAutosaveOnExit(false)
      .setLoadLatestSaveOnStartup(false)
    ); // Initialize LazyGui
       
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);
    
    //slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "Off");
    
    EOLBeep = new SoundFile(this, "endOfLineBeep.mp3");
    COLBeep = new SoundFile(this, "ChangeOfLine.mp3");
}

void sendToBrailleGroup(String group, String startMarker, String endMarker)
{
  if (myPort != null)
  {
    String groupSent = startMarker + group + endMarker;
    myPort.write(groupSent);
    println("Sent to Arduino: " + groupSent); // Debugging output
  }
  
  delay(1);
}

String[] wrapText(String text, float maxWidth)
{
  ArrayList<String> wrappedLines = new ArrayList<String>();
  String[] words = splitTokens(text, " ");
  String currentLine = "";
  
  for (int i = 0; i < words.length; i++)
  {
    String testLine = currentLine.length() == 0 ? words[i] : currentLine + " " + words[i];
    if (textWidth(testLine) <= maxWidth)
    {
      currentLine = testLine;
    }
    else
    {
      wrappedLines.add(currentLine);
      currentLine = words[i];
    }
  }
  if (!currentLine.equals(""))
  {
    wrappedLines.add(currentLine);
  }
  
  return wrappedLines.toArray(new String[0]);
}

void handleEOLBeep(boolean isInsideLine, boolean wasInsideLine) 
{
  if (!isInsideLine && wasInsideLine) 
  {
    EOLBeep.stop();  // Optional: stop any current playback
    EOLBeep.play();
    isEOLBeepPlayed = true;
  }
}

void draw() 
{
    isEOLBeepPlayed = false;
    // Background color adjustment
    background(gui.colorPicker("Background/Color").hex);
    
    // Braille settings
    //int cellCount = gui.sliderInt("Braille Settings/Cell Count", 8);
    if ((!slidingWindow && charGrouping) || (slidingWindow && !charGrouping) || (wordGrouping && !slidingWindow && !charGrouping))
    {
      if (charGrouping == true)
      {
        brailleFrequency = gui.sliderInt("Braille Settings/Character Grouping", DB_FREQ, 1, 8);
        slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "Off");
        wordGroupingState = gui.radio("Braille Settings/Word Grouping", new String[] {"Off", "On"}, "Off");
        
      }
      else if (slidingWindow == true)
      {
        slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "On");
        wordGroupingState = gui.radio("Braille Settings/Word Grouping", new String[] {"Off", "On"}, "Off");
      }
      else if (wordGrouping == true)
      {
        slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "Off");
        wordGroupingState = gui.radio("Braille Settings/Word Grouping", new String[] {"Off", "On"}, "On");
      }
    }

    // Handle text input
    userInput = gui.text("Text/Input", DTEXT);
    
    float extraSpacing = gui.sliderInt("Text Settings/Line Spacing", 10);
    float textSizeVal = gui.sliderInt("Text Settings/Text Size", 32);
    float boxHeightVal = gui.sliderInt("Text Settings/Box Height", 0);
    
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
    
    
    // Display text on the canvas
    fill(255); // Set text color to white for simplicity
    textSize(textSizeVal); // Fixed text size
    textAlign(LEFT, TOP);
    float textXStart = width / 2 - textWidth(userInput) / 2;
    //float textYStart = height / 2;
    float lineHeight = textAscent() + textDescent() + boxHeightVal;
    float margin = 100;
    //text(userInput, width / 2, height / 2);
    float maxWidth = width - 2 * margin;
    
    //String[] lines = userInput.split("\n");
    String[] lines = wrapText(userInput, maxWidth);
    
    float totalTextHeight = lines.length * (lineHeight + extraSpacing);
    float textYStart = height / 2 - totalTextHeight / 2;
    
    int currentLineIndex = -1;
   
    for (int i = 0; i < lines.length; i++)
    {
      float lineY = textYStart + i * (lineHeight + extraSpacing);
      
      if (mouseY >= lineY && mouseY < (lineY + lineHeight))
      {
        currentLineIndex = i;
      }
      float lineXStart = margin;//textXStart;
      float visibleStartX = lineXStart; // for the left boundary
      float visibleEndX = lineXStart;   // track the right boundary dynamically
      
      String currentLine = lines[i];
      
      //float leftBoundary = lineXStart; float rightBoundary = lineXStart + textWidth(currentLine);
      
      //boolean mouseIsInsideLine = (mouseX > leftBoundary && mouseX < rightBoundary);
      
      //if (!mouseIsInsideLine && mouseWasInsideLine)
      //{
      //  EOLBeep.stop();  // Optional: stop any current playback.
      //  EOLBeep.play();
      //  isEOLBeepPlayed = true;
      //}
      // Updating for the next frame
      //mouseWasInsideLine = mouseIsInsideLine;

      if (slidingWindowState.equals("Off") && wordGroupingState.equals("Off"))
      {
        int groupSize = brailleFrequency;//Integer.parseInt(brailleFrequency);
        
        // process characters in groups
        for (int j = 0; j < currentLine.length(); j += groupSize)
        {
          int endIndex = Math.min(j + groupSize, currentLine.length());
          String charGroup = currentLine.substring(j, endIndex);
          
          // draw bounding box around each group
          float groupWidth = 0;
          for (int k = j; k < endIndex; k++)
          {
            groupWidth += textWidth(currentLine.charAt(k));
          }
          
          // Prevent text overflow
          if (lineXStart + groupWidth > width - margin) 
          {
              println("Text overflow prevented!");
              lineXStart = margin; //textXStart;
              //break; // Stop rendering the current group if it goes outside the canvas width
          }
          noFill();
          stroke(234, 220, 0); // yellow stroke
          rect(lineXStart, lineY, groupWidth, lineHeight, 10);
          
          // now render the characters
          fill(255);
          noStroke();
          text(charGroup, lineXStart, lineY + boxHeightVal / 2);
          
          // Check if the pointer is inside the current group's bounding box
          if (mouseX >= lineXStart && mouseX <= lineXStart + groupWidth && mouseY >= lineY && mouseY <= lineY + lineHeight) 
              {
              if (!charGroup.equals(lastSentGroup)) 
              { 
                  // Send only if this is a new group
                  sendToBrailleGroup(charGroup, "*", "@");
                  lastSentGroup = charGroup; // Updating the last sent group
              }
          }
          visibleEndX = lineXStart + groupWidth; // update the right boundary
          
          lineXStart += groupWidth; // update the starting position for next group
        }
      }
      
      else if (slidingWindowState.equals("On") && wordGroupingState.equals("Off"))
      {
        int groupSize = 1;
        int slidingWindowSize = slidingWindowGrouping;
        int leftRightChars;
        if (slidingWindowSize % 2 != 0)
        {
          leftRightChars = (slidingWindowSize - 1) / 2;
        }
        else
        {
          leftRightChars = slidingWindowSize / 2;
         }
        
         for (int j = 0; j < currentLine.length(); j += groupSize) 
         {
           boolean atBoundary = (j == 0 || j + groupSize >= currentLine.length() - 1);
           if (atBoundary && !isEOLBeepPlayed)
           {
              EOLBeep.stop();      // Optional: stop any current playback.
              //EOLBeep.rewind();    // Ensures playback starts from the beginning.
              EOLBeep.play();
              isEOLBeepPlayed = true;
           }

           int boundingBoxEndIndex = Math.min(j + groupSize, currentLine.length());
           String charGroupBoundingBox = currentLine.substring(j, boundingBoxEndIndex);
           
           float groupWidthBoundingBox = 0;
           
           for (int k = j; k < boundingBoxEndIndex; k++)
           {
              groupWidthBoundingBox += textWidth(currentLine.charAt(k));
           }
           
           // Prevent text overflow
           if (lineXStart + groupWidthBoundingBox > width) 
           {
              println("Text overflow prevented!");
              lineXStart = textXStart;
           }
           noFill();
           stroke(234, 220, 0); // yellow stroke
           rect(lineXStart, lineY, groupWidthBoundingBox, lineHeight, 10);
          
           // now render the characters
           fill(255);
           noStroke();
           text(charGroupBoundingBox, lineXStart, lineY + boxHeightVal / 2);
          
           //lineXStart += groupWidthBoundingBox;
          
           char[] groupArray = new char[slidingWindowGrouping];
           
           for (int arrIndex = 0; arrIndex < slidingWindowGrouping; arrIndex++)
           {
             groupArray[arrIndex] = ' ';
           }
           
           int startIndex, endIndex; 
           String charGroup;
           int spaces = 0;
          
           if (j - leftRightChars < 0) 
           {
             if (slidingWindowSize % 2 != 0)
             {
                // Edge case: not enough characters to the left
                // Determine how many spaces to pad on the left:
                spaces = leftRightChars - j;
                startIndex = 0;
                // Use as many characters as possible from the beginning, but do not exceed the string length.
                endIndex = Math.min(currentLine.length(), j + leftRightChars + 1);
                charGroup = currentLine.substring(startIndex, endIndex);
                // Fill the padded array: leave left "spaces" as blank and then add the substring.
                for (int pos = 0; pos < charGroup.length(); pos++) 
                {
                  groupArray[spaces + pos] = charGroup.charAt(pos);
                }
             }
             else  // this block only for the 8 cell mark
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
           
           String group = String.valueOf(groupArray);
           
           // Adjust the drawing x-coordinate if the edge case is active.
          float padWidth = spaces * textWidth(' ');
          float charX = textXStart + textWidth(currentLine.substring(0, j)) - padWidth;
           
          // Prevent text overflow
           if (charX + textWidth(charGroup) > width) 
           {
              charX = textXStart;
           }
        
            //noFill();
            //stroke(234, 220, 0); // yellow stroke
            //rect(charX, lineY, textWidth(charGroup), lineHeight, 10);
        
           // Render characters, avoiding duplicates
           for (int charIndex = 0; charIndex < charGroup.length(); charIndex++) 
           {
               float charWidth = textWidth(charGroup.charAt(charIndex));
                
                // Check if this character was already drawn (skip redundant drawing)
                //if (j + charIndex < currentLine.length()) 
                //{
                //    fill(255);
                //    noStroke();
                //    text(currentLine.charAt(j + charIndex), charX, lineY);
                //}
                
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
           
            //lineXStart += textWidth(currentLine.charAt(j)); // Move forward properly*/
            lineXStart += groupWidthBoundingBox;
         }
      }
      else if (slidingWindowState.equals("Off") && wordGroupingState.equals("On"))
      {
        String[] words = currentLine.split(" ");
        for (String word: words)
        {
          float wordWidth = textWidth(word);
          
          if (lineXStart + wordWidth > width)
          {
            println("Text overflow prevented");
            lineXStart = textXStart;
            lineY += textAscent() + textDescent() + boxHeightVal + extraSpacing;
          }
          noFill();
          stroke(234, 220, 0);
          rect(lineXStart, lineY, wordWidth, lineHeight, 10); // bounding box
          
          fill(255);
          noStroke();
          text(word, lineXStart, lineY + boxHeightVal / 2);
          
          if (mouseX >= lineXStart && mouseX <= lineXStart + wordWidth && mouseY >= lineY && mouseY <= lineY + lineHeight)
          {
            if (!word.equals(lastSentGroup))
            {
              sendToBrailleGroup(word, "^", "|");
              lastSentGroup = word;
            }
          }
          lineXStart += wordWidth + textWidth(" ");  // Move forward to next word
        }
      }
      
      //now compuing the boundaries after rendering the line
      float leftBoundary = visibleStartX; float rightBoundary = visibleEndX;
      
      boolean mouseIsInsideLine = (mouseX > leftBoundary && mouseX < rightBoundary);
      
      handleEOLBeep(mouseIsInsideLine, mouseWasInsideLine);
      
      // Updating for the next frame
      mouseWasInsideLine = mouseIsInsideLine;
    }
    
    if (currentLineIndex != -1 && currentLineIndex != prevLineIndex) 
    {
      COLBeep.stop(); 
      COLBeep.play();   
      
      // Update the previous line index.
      prevLineIndex = currentLineIndex;
    }

    // Calculate the active line based on mouseY, ensuring the index is valid
    int activeLine = Math.max(0, Math.min((int) ((mouseY - textYStart) / (lineHeight + extraSpacing)), lines.length - 1));
    
    // Restrict pointer X position to the width of the active line
    float pointerX = constrain(mouseX, margin, margin + textWidth(lines[activeLine]) - 10);
    
    // Restrict pointer Y position to the active line's center
    float pointerY = textYStart + activeLine * (lineHeight + extraSpacing) + (lineHeight) / 3;
    
    
    // handle pointer mode using radio buttons
    String mode = gui.radio("Pointer/Mode", new String[]{"square", "circle"});

    // draw pointe based on selection mode
    if (mode.equals("square"))
    {
      fill(255, 0, 0);
      rect(pointerX, pointerY, 20, 20);
    }
    else if (mode.equals("circle"))
    {
      fill(0, 0, 255);
      ellipse(pointerX, pointerY, 20, 20);
    }
}
