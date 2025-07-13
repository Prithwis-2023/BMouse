/* Create the DBs for the Hanguel */ 
final char[] CHOESEONG = 
{
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
};

final char[] JUNGSEONG = 
{
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
    'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'
};

final char[] JONGSEONG = 
{
    '\0', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ',
    'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
};

// DB for choeseong and jongseong (the first and the last consonants of the syllable)
String[][] korBrailleDB =  
{
    {hex('\0'), "-", "-"},
    {hex('ㄱ'), "⠈", "⠁"},
    {hex('ㄴ'), "⠉", "⠒"},
    {hex('ㄷ'), "⠊", "⠔"},
    {hex('ㄹ'), "⠐", "⠂"},
    {hex('ㅁ'), "⠑", "⠢"},
    {hex('ㅂ'), "⠘", "⠃"},
    {hex('ㅅ'), "⠠", "⠄"},
    {hex('ㅇ'), "\u2800", "⠶"},
    {hex('ㅈ'), "⠨", "⠅"},
    {hex('ㅊ'), "⠰", "⠆"},
    {hex('ㅋ'), "⠋", "⠖"},
    {hex('ㅌ'), "⠓", "⠦"},
    {hex('ㅍ'), "⠙", "⠲"},
    {hex('ㅎ'), "⠚", "⠴"}
};
// DB for jungsung (the middle vowel of the syllable, which sometimes has two parts)
String [][] korBrailleDB2 = 
{
    {hex('ㅏ'), "⠣", "-"},
    {hex('ㅐ'), "⠗", "-"},
    {hex('ㅑ'), "⠜", "-"},
    {hex('ㅒ'), "⠜", "⠗"},
    {hex('ㅓ'), "⠎", "-"},
    {hex('ㅔ'), "⠝", "-"},
    {hex('ㅕ'), "⠱", "-"},
    {hex('ㅖ'), "⠌", "-"},
    {hex('ㅗ'), "⠥", "-"},
    {hex('ㅘ'), "⠧", "-"},
    {hex('ㅙ'), "⠧", "⠗"},
    {hex('ㅚ'), "⠽", "-"},
    {hex('ㅛ'), "⠬", "-"},
    {hex('ㅜ'), "⠍", "-"},
    {hex('ㅝ'), "⠏", "-"},
    {hex('ㅞ'), "⠏", "⠗"},
    {hex('ㅟ'), "⠍", "⠗"},
    {hex('ㅠ'), "⠩", "-"},
    {hex('ㅡ'), "⠪", "-"},
    {hex('ㅢ'), "⠺", "-"},
    {hex('ㅣ'), "⠕", "-"}
};

// This function converts a Braille dot pattern to its corresponding one-byte code (for Hanguel)
String convertBDotTo1ByteCode (String bDot) // this function converts a Braille dot pattern to its corresponding one-byte code
{
  int index = unhex(hex(bDot.charAt(0))) - 0x2800; // Convert dot string to integer and subtract 0x2800 to get the index
  return hex(index).substring(hex(index).length() - 2); // Convert the index to hex and return the last two characters
}

// This function decomposes an entire Hanguel text string into its individual components
// and returns a string representation of the decomposed text
String[] decompose(String inputString)
{
  String markers = ""; String decomposedString = "";
  for (int i = 0; i < inputString.length(); i++)
  {
    char ch = inputString.charAt(i);
    if (ch >= 0xAC00 && ch <= 0xD7A3)  // check if the character is a Hanguel syllable
    {
      int syllableIndex = ch - 0xAC00;
      int choeseongIndex = syllableIndex / (21 * 28);
      int jungseongIndex = (syllableIndex % (21 * 28)) / 28;
      int jongseongIndex = syllableIndex % 28;

      char choeseong = CHOESEONG[choeseongIndex];
      char jungseong = JUNGSEONG[jungseongIndex];
      char jongseong = JONGSEONG[jongseongIndex];

      if (choeseong == 'ㅇ') // If the choeseong is the voiceless circle, we don't need to append it
      {
        decomposedString += str(jungseong);
        markers += str('j'); // j for jungseong
      }
      else
      {
        decomposedString += str(choeseong) + str(jungseong);
        markers += str('C') + str('j'); // C for choeseong, j for jungseong
      }

      if (jongseong != '\0')
      {
        decomposedString += str(jongseong);
        markers += 'J'; // J for jongseong
      }
    }
    else
    {
      markers += 'O'; // If not a Hanguel syllable, just append the 'O' marker
      decomposedString += ch; // If not a Hanguel syllable, just append the character
    }
  }
  return  new String[] {decomposedString, markers};
}

String bUnicodesString (String group, String markerString, int startIndex, int endIndex, int spaces)
{
  char[] decomposedArray = group.toCharArray();
  String filteredMarkersString = markerString.substring(startIndex, endIndex); // Get the markers for the current group
  char[] originalMarkersArray = filteredMarkersString.toCharArray();
  
  // Create a new array with padding for the sliding window feature edge case
  char[] markersArray = new char[spaces + originalMarkersArray.length];
  // Fill the left-padding with 'O' as per the protocol
  for (int i = 0; i < spaces; i++) 
  {
    markersArray[i] = 'O';
  }
  // Copying the original markers into the rest
  for (int i = 0; i < originalMarkersArray.length; i++) 
  {
    markersArray[spaces + i] = originalMarkersArray[i];
  }
  
  StringBuilder result = new StringBuilder(); // StringBuilder objects are mutable, allowing for modifications
  
  for (int i = 0; i < decomposedArray.length; i++)
  {
    char ch = decomposedArray[i]; // Get the character which is either a choeseong, jungseong, or jongseong
    if (markersArray[i] == 'C') // if the next character is 'C', it is a choeseong. We don't need to check whether choeseong is the voiceless circle as decompose() already handles that
    {
      for (int j = 0; j < korBrailleDB.length; j++)
      {
        if (korBrailleDB[j][0].equals(hex(ch)))
        {
          result.append(convertBDotTo1ByteCode(korBrailleDB[j][1])); // Append the Braille representation of the choeseong
          break;
        }
      }
    }
    else if (markersArray[i] == 'J') // if the next character is 'J', its a jongseong. We don't need to check whether jongseong is not present as decompose() already handles that
    {
      for (int j = 0; j < korBrailleDB.length; j++)
      {
        if (korBrailleDB[j][0].equals(hex(ch)))
        {
          result.append(convertBDotTo1ByteCode(korBrailleDB[j][2])); // Append the Braille representation of the jongseong
          break;
        }
      }
    }
    else if (markersArray[i] == 'j') // if the next character is 'j', its a jungseong
    {
      for (int j = 0; j < korBrailleDB2.length; j++)
      {
        if (korBrailleDB2[j][0].equals(hex(ch)))
        {
          result.append(convertBDotTo1ByteCode(korBrailleDB2[j][1])); // Append the Braille representation of the jungseong
          if (!korBrailleDB2[j][2].equals("-")) // If there is a second part of the jungseong
          {
            result.append(convertBDotTo1ByteCode(korBrailleDB2[j][2])); // Append the second part of the jungseong
          }
          break;
        }
      }
    }
    else if (markersArray[i] == 'O') // if the next character is 'O', its a non-Hanguel character
    {
      if (decomposedArray[i] == ' ')
      {
        result.append("00");
      }
      else
      {
        result.append(ch); // If not a Hanguel syllable, just append the character
      }
    }
  }
  String RESULT = result.toString(); // Convert StringBuilder to String
  return RESULT; // Return the result
}