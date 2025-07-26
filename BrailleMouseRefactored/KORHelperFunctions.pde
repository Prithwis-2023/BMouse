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


HashMap<Character, List<String>> korBrailleDB = new HashMap<Character, List<String>>();  // for cheoseong and jongseong
HashMap<Character, List<String>> korBrailleDB2 = new HashMap<Character, List<String>>();  // for jungseong
HashMap<Character, String> otherChars = new HashMap<Character, String>(); // for punctuations and numerals
HashMap<Character, String> CONTRACTIONS = new HashMap<Character, String>(); // for contractions

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

// Helper function that checks whether a char is in an array
boolean containsChar(char[] array, char target) 
{
  for (char c : array) 
  {
    if (c == target) return true;
  }
  return false;
}

// This function decomposes an entire Hanguel text string into its individual components
// and returns the braille dot representation of the decomposed text
String decompose(String inputString)
{
  String decomposedString = "";
  for (int i = 0; i < inputString.length(); i++)
  {
    char ch = inputString.charAt(i);

    if (ch >= 0xAC00 && ch <= 0xD7A3) // if a Hanguel syllable
    {
      if (CONTRACTIONS.containsKey(ch))
      {
        decomposedString += CONTRACTIONS.get(ch); // appending the Braille Dot pattern
        //markers += 'O'; 
        continue;
      }

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
          //markers += "CC";
        }
        else
        {
          decomposedString += korBrailleDB.get(choeseong).get(0);
          //markers += str('C');
        }
      }
      // appending the jungseong
      if (korBrailleDB2.containsKey(jungseong))
      {
        if (korBrailleDB2.get(jungseong).get(1) != "-")
        {
          decomposedString += korBrailleDB2.get(jungseong).get(0) + korBrailleDB2.get(jungseong).get(1);
          //markers += "jj";
        }
        else
        {
          decomposedString += korBrailleDB2.get(jungseong).get(0);
          //markers += str('j');
        }
      }
      // appending the jongseong
      if (korBrailleDB.containsKey(jongseong) && jongseong != '\0')
      {
        if (containsChar(doubleConsonants, jongseong))
        {
          decomposedString += "⠠" + korBrailleDB.get(jongseong).get(1);
          //markers += "JJ";
        }
        else
        {
          decomposedString += korBrailleDB.get(jongseong).get(1);
          //markers += str('J');
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
  return decomposedString;
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
      result.append(convertBDotTo1ByteCode(str(decomposedArray[i])));
    }
  }
  return result.toString();
}
