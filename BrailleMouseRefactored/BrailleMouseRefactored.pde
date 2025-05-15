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

final int charGrouping_FREQ = 5;  // character group frequency for charGrouping feature
final int slidingWindow_FREQ = 8;  // sliding window frequency for slidingWindow feature. Can be 1, 3, 5 or 8
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
int brailleFrequency;
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

