import java.util.Map;
import java.util.List;
import java.util.Arrays;

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

final char[] doubleConsonants = 
{
  'ㄲ', 'ㄸ', 'ㅃ', 'ㅆ', 'ㅉ', 'ㄳ', 'ㄵ', 'ㄶ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅄ'
};


HashMap<Character, List<String>> korBrailleDB = new HashMap<Character, List<String>>();
HashMap<Character, List<String>> korBrailleDB2 = new HashMap<Character, List<String>>();
HashMap<Character, String> otherChars = new HashMap<Character, String>();
HashMap<Character, String> CONTRACTIONS = new HashMap<Character, String>();

void init()
{
  korBrailleDB.put('\0', Arrays.asList("-", "-"));
  korBrailleDB.put('ㄱ', Arrays.asList("⠈", "⠁"));
  korBrailleDB.put('ㄴ', Arrays.asList("⠉", "⠒"));
  korBrailleDB.put('ㄷ', Arrays.asList("⠊", "⠔"));
  korBrailleDB.put('ㄹ', Arrays.asList("⠐", "⠂"));
  korBrailleDB.put('ㅁ', Arrays.asList("⠑", "⠢"));
  korBrailleDB.put('ㅂ', Arrays.asList("⠘", "⠃"));
  korBrailleDB.put('ㅅ', Arrays.asList("⠠", "⠄"));
  korBrailleDB.put('ㅇ', Arrays.asList("\u2800", "⠶"));
  korBrailleDB.put('ㅈ', Arrays.asList("⠨", "⠅"));
  korBrailleDB.put('ㅊ', Arrays.asList("⠰", "⠆"));
  korBrailleDB.put('ㅋ', Arrays.asList("⠋", "⠖"));
  korBrailleDB.put('ㅌ', Arrays.asList("⠓", "⠦"));
  korBrailleDB.put('ㅍ', Arrays.asList("⠙", "⠲"));
  korBrailleDB.put('ㅎ', Arrays.asList("⠚", "⠴"));
  korBrailleDB.put('ㄲ', Arrays.asList("⠈", "⠁"));
  korBrailleDB.put('ㄸ', Arrays.asList("⠊", "⠔"));
  korBrailleDB.put('ㅃ', Arrays.asList("⠘", "⠃"));
  korBrailleDB.put('ㅆ', Arrays.asList("⠠", "⠄"));
  korBrailleDB.put('ㅉ', Arrays.asList("⠨", "⠅"));

  korBrailleDB2.put('ㅏ', Arrays.asList("⠣", "-"));
  korBrailleDB2.put('ㅐ', Arrays.asList("⠗", "-"));
  korBrailleDB2.put('ㅑ', Arrays.asList("⠜", "-"));
  korBrailleDB2.put('ㅒ', Arrays.asList("⠜", "⠗"));
  korBrailleDB2.put('ㅓ', Arrays.asList("⠎", "-"));
  korBrailleDB2.put('ㅔ', Arrays.asList("⠝", "-"));
  korBrailleDB2.put('ㅕ', Arrays.asList("⠱", "-"));
  korBrailleDB2.put('ㅖ', Arrays.asList("⠌", "-"));
  korBrailleDB2.put('ㅗ', Arrays.asList("⠥", "-"));
  korBrailleDB2.put('ㅘ', Arrays.asList("⠧", "-"));
  korBrailleDB2.put('ㅙ', Arrays.asList("⠧", "⠗"));
  korBrailleDB2.put('ㅚ', Arrays.asList("⠽", "-"));
  korBrailleDB2.put('ㅛ', Arrays.asList("⠬", "-"));
  korBrailleDB2.put('ㅜ', Arrays.asList("⠍", "-"));
  korBrailleDB2.put('ㅝ', Arrays.asList("⠏", "-"));
  korBrailleDB2.put('ㅞ', Arrays.asList("⠏", "⠗"));
  korBrailleDB2.put('ㅟ', Arrays.asList("⠍", "⠗"));
  korBrailleDB2.put('ㅠ', Arrays.asList("⠩", "-"));
  korBrailleDB2.put('ㅡ', Arrays.asList("⠪", "-"));
  korBrailleDB2.put('ㅢ', Arrays.asList("⠺", "-"));
  korBrailleDB2.put('ㅣ', Arrays.asList("⠕", "-"));

  otherChars.put(',', "⠂");
  otherChars.put('.', "⠲");
  otherChars.put('!', "⠖");
  otherChars.put('?', "⠦");
  otherChars.put('1', "⠁");
  otherChars.put('2', "⠃");
  otherChars.put('3', "⠉");
  otherChars.put('4', "⠙");
  otherChars.put('5', "⠑");
  otherChars.put('6', "⠋");
  otherChars.put('7', "⠛");
  otherChars.put('8', "⠓");
  otherChars.put('9', "⠊");
  otherChars.put('0', "⠚");

  CONTRACTIONS.put('가', "⠫");
  CONTRACTIONS.put('나', "⠉");
  CONTRACTIONS.put('다', "⠊");
  CONTRACTIONS.put('마', "⠑");
  CONTRACTIONS.put('바', "⠘");
  CONTRACTIONS.put('사', "⠇");
  CONTRACTIONS.put('자', "⠨");
  CONTRACTIONS.put('카', "⠋");
  CONTRACTIONS.put('타', "⠓");
  CONTRACTIONS.put('파', "⠙");
  CONTRACTIONS.put('하', "⠚");
  CONTRACTIONS.put('억', "⠹");
  CONTRACTIONS.put('옹', "⠿");
  CONTRACTIONS.put('울', "⠯");
  CONTRACTIONS.put('옥', "⠭");
  CONTRACTIONS.put('연', "⠡");
  CONTRACTIONS.put('운', "⠛");
  CONTRACTIONS.put('온', "⠷");
  CONTRACTIONS.put('언', "⠾");
  CONTRACTIONS.put('얼', "⠞");
  CONTRACTIONS.put('열', "⠳");
  CONTRACTIONS.put('인', "⠟");
  CONTRACTIONS.put('영', "⠻");
  CONTRACTIONS.put('을', "⠮");
  CONTRACTIONS.put('은', "⠵");
}

boolean containsChar(char[] array, char target) {
  for (char c : array) {
    if (c == target) return true;
  }
  return false;
}


// This function converts a Braille dot pattern to its corresponding one-byte code
String convertBDotTo1ByteCodeKOR (String bDot) // this function converts a Braille dot pattern to its corresponding one-byte code
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
    if (ch >= 0xAC00 && ch <= 0xD7A3) // if a Hanguel syllable
    {
      if (CONTRACTIONS.containsKey(ch))
      {
        decomposedString += CONTRACTIONS.get(ch); // appending the Braille Dot pattern
        //markers += 'O'; 
      }
      else
      {
        int syllableIndex = ch - 0xAC00;
        int choeseongIndex = syllableIndex / (21 * 28);
        int jungseongIndex = (syllableIndex % (21 * 28)) / 28;
        int jongseongIndex = syllableIndex % 28;

        char choeseong = CHOESEONG[choeseongIndex];
        char jungseong = JUNGSEONG[jungseongIndex];
        char jongseong = JONGSEONG[jongseongIndex];

        // appending the choeseong
        if (korBrailleDB.containsKey(choeseong) && choeseong != 'ㅇ')
        {
          if (containsChar(doubleConsonants, choeseong))
          {
            decomposedString += "⠠" + korBrailleDB.get(choeseong).get(0); 
            markers += "CC";
          }
          else
          {
            decomposedString += korBrailleDB.get(choeseong).get(0);
            markers += str('C');
          }
        }
        // appending the jungseong
        if (korBrailleDB2.containsKey(jungseong))
        {
          if (korBrailleDB2.get(jungseong).get(1) != "-")
          {
            decomposedString += korBrailleDB2.get(jungseong).get(0) + korBrailleDB2.get(jungseong).get(1);
            markers += "jj";
          }
          else
          {
            decomposedString += korBrailleDB2.get(jungseong).get(0);
            markers += str('j');
          }
        }
        // appending the jongseong
        if (korBrailleDB.containsKey(jongseong) && jongseong != '\0')
        {
          if (containsChar(doubleConsonants, jongseong))
          {
            decomposedString += "⠠" + korBrailleDB.get(jongseong).get(1);
            markers += "JJ";
          }
          else
          {
            decomposedString += korBrailleDB.get(jongseong).get(1);
            markers += str('J');
          }
        }
      }
    }
    else  // If not a Hanguel syllable 
    {
      if (otherChars.containsKey(ch)) // if among the known list of punctuations and numerals
      {
        if (Character.isDigit(ch))
        {
          if (i == 0 || !Character.isDigit(inputString.charAt(i - 1)))
          {
            decomposedString += "⠼";
          }
          decomposedString += otherChars.get(ch);
        }
        else
        {
          decomposedString += otherChars.get(ch);
        }
      }
      else  // beyond the otherChars list, for example spaces
      {
        decomposedString += str(ch);
      }
    }
  }
  return  new String[] {decomposedString, markers};
}

String bUnicodesStringKOR (String group, int spacesLeft, int spacesRight)
{
  StringBuilder result = new StringBuilder(); // StringBuilder objects are mutable, allowing for modifications
  
  int paddedLength = spacesLeft + group.length() + spacesRight;  
  char[] originalChars = group.toCharArray();
  char[] decomposedArray = new char[paddedLength];
  for (int i = 0; i < spacesLeft; i++) decomposedArray[i] = ' '; 
  for (int i = 0; i < originalChars.length; i++) decomposedArray[spacesLeft + i] = originalChars[i];
  for (int i = spacesLeft + originalChars.length; i < paddedLength; i++) decomposedArray[i] = ' ';

  for (int i = 0; i < decomposedArray.length; i++)
  {
    if (decomposedArray[i] == ' ')
    {
      result.append("00");
    }
    else
    {
      result.append(convertBDotTo1ByteCodeKOR(str(decomposedArray[i])));
    }
  }
  return result.toString();
}

/*String bUnicodesStringKOR (String group, String markerString, int startIndex, int endIndex, int spacesLeft, int spacesRight)
{
  // Extract markers for the current group
  String filteredMarkersString = markerString.substring(startIndex, endIndex); 
  char[] originalMarkersArray = filteredMarkersString.toCharArray();
  
  // Pad the markers array with 'O' (non-Hangul) on both sides
  int paddedLength = spacesLeft + originalMarkersArray.length + spacesRight;
  char[] markersArray = new char[paddedLength];
  for (int i = 0; i < spacesLeft; i++) markersArray[i] = 'O';
  for (int i = 0; i < originalMarkersArray.length; i++) markersArray[spacesLeft + i] = originalMarkersArray[i];
  for (int i = spacesLeft + originalMarkersArray.length; i < paddedLength; i++) markersArray[i] = 'O';

  // Pad the decomposed group with spaces (matching marker padding)
  char[] originalChars = group.toCharArray();
  char[] decomposedArray = new char[paddedLength];
  for (int i = 0; i < spacesLeft; i++) decomposedArray[i] = ' '; // space padding
  for (int i = 0; i < originalChars.length; i++) decomposedArray[spacesLeft + i] = originalChars[i];
  for (int i = spacesLeft + originalChars.length; i < paddedLength; i++) decomposedArray[i] = ' ';

  StringBuilder result = new StringBuilder(); // StringBuilder objects are mutable, allowing for modifications
  
  for (int i = 0; i < decomposedArray.length; i++)
  {
    char ch = decomposedArray[i]; // Get the character which is either a choeseong, jungseong, or jongseong

    if (markersArray[i] != 'O')
    {
      result.append(convertBDotTo1ByteCodeKOR(str(ch)));
    }
    else 
    {
      if (decomposedArray[i] == ' ')
      {
        result.append("00");
      }
      else if (Character.isDigit(decomposedArray[i]))
      {
        if (i == 0 || !Character.isDigit(decomposedArray[i - 1])) // putting the numeric marker only once
        {
          result.append(convertBDotTo1ByteCodeKOR("⠼"));
        }
        result.append(convertBDotTo1ByteCodeKOR(otherChars.get(decomposedArray[i])));
      }
      else if (otherChars.containsKey(decomposedArray[i]))
      {
        result.append(convertBDotTo1ByteCodeKOR(otherChars.get(decomposedArray[i])));
      }
      else if (CONTRACTIONS.containsKey(decomposedArray[i]))
      {
        result.append(convertBDotTo1ByteCodeKOR(CONTRACTIONS.get(decomposedArray[i])));
      }
      else
      {
        result.append("00");
      }
    }
  }
  return result.toString(); // Convert StringBuilder to String and return the resulting string





    // if (markersArray[i] == 'C') // if the next character is 'C', it is a choeseong. We don't need to check whether choeseong is the voiceless circle as decompose() already handles that
    // {
    //   for (int j = 0; j < korBrailleDB.length; j++)
    //   {
    //     if (korBrailleDB[j][0].equals(hex(ch)))
    //     {
    //       result.append(convertBDotTo1ByteCodeKOR(korBrailleDB[j][1])); // Append the Braille representation of the choeseong
    //       break;
    //     }
    //   }
    // }
    // else if (markersArray[i] == 'J') // if the next character is 'J', its a jongseong. We don't need to check whether jongseong is not present as decompose() already handles that
    // {
    //   for (int j = 0; j < korBrailleDB.length; j++)
    //   {
    //     if (korBrailleDB[j][0].equals(hex(ch)))
    //     {
    //       result.append(convertBDotTo1ByteCodeKOR(korBrailleDB[j][2])); // Append the Braille representation of the jongseong
    //       break;
    //     }
    //   }
    // }
    // else if (markersArray[i] == 'j') // if the next character is 'j', its a jungseong
    // {
    //   for (int j = 0; j < korBrailleDB2.length; j++)
    //   {
    //     if (korBrailleDB2[j][0].equals(hex(ch)))
    //     {
    //       result.append(convertBDotTo1ByteCodeKOR(korBrailleDB2[j][1])); // Append the Braille representation of the jungseong
    //       if (!korBrailleDB2[j][2].equals("-")) // If there is a second part of the jungseong
    //       {
    //         result.append(convertBDotTo1ByteCodeKOR(korBrailleDB2[j][2])); // Append the second part of the jungseong
    //       }
    //       break;
    //     }
    //   }
    // }
    else if (markersArray[i] == 'O') // if the next character is 'O', its a non-Hanguel character
    {
      if (decomposedArray[i] == ' ')
      {
        result.append("00");
      }
      else if (Character.isDigit(decomposedArray[i]))
      {
        if (i == 0 || !Character.isDigit(decomposedArray[i - 1])) // putting the numeric marker only once
        {
          result.append(convertBDotTo1ByteCodeKOR("⠼"));
        }
        result.append(convertBDotTo1ByteCodeKOR(otherChars.get(decomposedArray[i])));
      }
      else if (otherChars.containsKey(decomposedArray[i]))
      {
        result.append(convertBDotTo1ByteCodeKOR(otherChars.get(decomposedArray[i])));
      }
      else if (CONTRACTIONS.containsKey(decomposedArray[i]))
      {
        result.append(convertBDotTo1ByteCodeKOR(CONTRACTIONS.get(decomposedArray[i])));
      }
      else
      {
        result.append("00");
      }
    }
  }
  return result.toString(); // Convert StringBuilder to String and return the resulting string
}*/