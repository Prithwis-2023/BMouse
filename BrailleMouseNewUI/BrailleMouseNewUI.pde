import com.krab.lazy.*;
import processing.serial.*;

final String DB_FREQ = "3";
final String DTEXT = "Hello today is a nice day"; // "Enter your text here"

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
    
}

void sendToBrailleGroup(String group)
{
  if (myPort != null)
  {
    String groupSent = group + "*";
    myPort.write(groupSent);
    println("Sent to Arduino: " + groupSent); // Debugging output
  }
  
  delay(1);
}

void draw() 
{
    // Background color adjustment
    background(gui.colorPicker("Background/Color").hex);
    
    // Braille frequency settings
    String brailleFrequency = gui.radio("BrailleSettings/Character Frequency", new String[]{"1", "3", "5"}, DB_FREQ);
    
    // Handle text input
    userInput = gui.text("Text/Input", DTEXT);
    
    float extraSpacing = gui.sliderInt("Text Settings/Line Spacing", 10);
    float textSizeVal = gui.sliderInt("Text Settings/Text Size", 32);
    

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
      int groupSize = Integer.parseInt(brailleFrequency);
      
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
                sendToBrailleGroup(charGroup);
                lastSentGroup = charGroup; // Updating the last sent group
            }
        }
        // update the starting position for next group
        lineXStart += groupWidth;
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
