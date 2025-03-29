import com.krab.lazy.*;
import processing.serial.*;

final int DB_FREQ = 3;
final String DTEXT = "Hello today is a nice day"; // "Enter your text here"
final int slidingWindowGrouping = 5;

String slidingWindowState; // Stores "Off" or "On"

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
    
    slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, "Off");
}

void sendToBrailleGroup(String group, String marker)
{
  if (myPort != null)
  {
    String groupSent = group + marker;
    myPort.write(groupSent);
    println("Sent to Arduino: " + groupSent); // Debugging output
  }
  
  delay(1);
}

void draw() 
{
    // Background color adjustment
    background(gui.colorPicker("Background/Color").hex);
    
    // Braille settings
    //int cellCount = gui.sliderInt("Braille Settings/Cell Count", 8);
    slidingWindowState = gui.radio("Braille Settings/Sliding Window", new String[] {"Off", "On"}, slidingWindowState);
    
    int brailleFrequency = gui.sliderInt("Braille Settings/Character Grouping", DB_FREQ, 1, 5);
    
    
    // Handle text input
    userInput = gui.text("Text/Input", DTEXT);
    
    float extraSpacing = gui.sliderInt("Text Settings/Line Spacing", 10);
    float textSizeVal = gui.sliderInt("Text Settings/Text Size", 32);
    
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
    float textYStart = height / 2;
    float lineHeight = textAscent() + textDescent();
    //text(userInput, width / 2, height / 2);
    
    String[] lines = userInput.split("\n");
    
    
    for (int i = 0; i < lines.length; i++)
    {
      float lineY = textYStart + i * (lineHeight + extraSpacing);
      float lineXStart = textXStart;
      
      String currentLine = lines[i];
      
      if (slidingWindowState.equals("Off"))
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
          if (lineXStart + groupWidth > width) 
          {
              println("Text overflow prevented!");
              lineXStart = textXStart;
              //break; // Stop rendering the current group if it goes outside the canvas width
          }
          noFill();
          stroke(234, 220, 0); // yellow stroke
          rect(lineXStart, lineY, groupWidth, lineHeight, 10);
          
          // now render the characters
          fill(255);
          noStroke();
          text(charGroup, lineXStart, lineY);
          
          // Check if the pointer is inside the current group's bounding box
          if (mouseX >= lineXStart && mouseX <= lineXStart + groupWidth && mouseY >= lineY && mouseY <= lineY + lineHeight) 
              {
              if (!charGroup.equals(lastSentGroup)) 
              { 
                  // Send only if this is a new group
                  sendToBrailleGroup(charGroup, "*");
                  lastSentGroup = charGroup; // Updating the last sent group
              }
          }
          // update the starting position for next group
          lineXStart += groupWidth;
        }
      }
      else
      {
        int groupSize = 1;
        int slidingWindowSize = slidingWindowGrouping;
        int leftRightChars = (slidingWindowSize - 1) / 2; // Calculate left/right char count
        
         for (int j = 0; j < currentLine.length(); j += groupSize) 
         {
            int startIndex = Math.max(0, j - leftRightChars);
            int endIndex = Math.min(currentLine.length(), j + leftRightChars + 1);
             
            String charGroup = currentLine.substring(startIndex, endIndex);
        
            float charX = textXStart + textWidth(currentLine.substring(0, j)); // Correct X position
        
            // Prevent text overflow
            if (charX + textWidth(charGroup) > width) 
            {
                println("Text overflow prevented!");
                charX = textXStart;
            }
        
            noFill();
            stroke(234, 220, 0); // yellow stroke
            rect(charX, lineY, textWidth(charGroup), lineHeight, 10);
        
            // Render characters, avoiding duplicates
            for (int charIndex = 0; charIndex < charGroup.length(); charIndex++) 
            {
                float charWidth = textWidth(charGroup.charAt(charIndex));
                
                // Check if this character was already drawn (skip redundant drawing)
                if (j + charIndex < currentLine.length()) 
                {
                    fill(255);
                    noStroke();
                    text(currentLine.charAt(j + charIndex), charX, lineY);
                }
                charX += charWidth;
                
                // Check if the pointer is inside the current group's bounding box
                if (mouseX >= lineXStart && mouseX <= lineXStart + charWidth && mouseY >= lineY && mouseY <= lineY + lineHeight) 
                {
                    if (!charGroup.equals(lastSentGroup)) 
                    { 
                        // Send only if this is a new group
                        sendToBrailleGroup(charGroup, "#");
                        lastSentGroup = charGroup; // Updating the last sent group
                    }
                }
            }
           
            lineXStart += textWidth(currentLine.charAt(j)); // Move forward properly
         }
      }
    }
    
    // Calculate the active line based on mouseY, ensuring the index is valid
    int activeLine = Math.max(0, Math.min((int) ((mouseY - textYStart) / (lineHeight + extraSpacing)), lines.length - 1));
    
    // Restrict pointer X position to the width of the active line
    float pointerX = constrain(mouseX, textXStart, textXStart + textWidth(lines[activeLine]) - 10);
    
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
