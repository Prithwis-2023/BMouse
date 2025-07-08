import processing.serial.*;

String s = "안녕하세요 반갑습니다 각";

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

String[][] korBrailleDB = 
{
    {hex('\0'), "FF", "FF"},
    {hex('ㄱ'), "FE", "F7"},
    {hex('ㄴ'), "F6", "ED"},
    {hex('ㄷ'), "EE", "DD"},
    {hex('ㄹ'), "FD", "EF"},
    {hex('ㅁ'), "F5", "EB"},
    {hex('ㅂ'), "FC", "E7"},
    {hex('ㅅ'), "BF", "7F"},
    {hex('ㅇ'), "FF", "C9"},
    {hex('ㅈ'), "FA", "D7"},
    {hex('ㅊ'), "F9", "CF"},
    {hex('ㅋ'), "E6", "CD"},
    {hex('ㅌ'), "E5", "CB"},
    {hex('ㅍ'), "F4", "E9"},
    {hex('ㅎ'), "EC", "D9"}
};

String [][] korBrailleDB2 = 
{
    {hex('ㅏ'), "E3", "-"},
    {hex('ㅐ'), "C5", "-"},
    {hex('ㅑ'), "DC", "-"},
    {hex('ㅒ'), "DC", "C5"},
    {hex('ㅓ'), "CE", "-"},
    {hex('ㅔ'), "D4", "-"},
    {hex('ㅕ'), "F1", "-"},
    {hex('ㅖ'), "DE", "-"},
    {hex('ㅗ'), "D3", "-"},
    {hex('ㅘ'), "C3", "-"},
    {hex('ㅙ'), "C3", "C5"},
    {hex('ㅚ'), "D0", "-"},
    {hex('ㅛ'), "DA", "-"},
    {hex('ㅜ'), "D6", "-"},
    {hex('ㅝ'), "C6", "-"},
    {hex('ㅞ'), "C6", "C5"},
    {hex('ㅟ'), "D6", "C5"},
    {hex('ㅠ'), "F2", "-"},
    {hex('ㅡ'), "EA", "-"},
    {hex('ㅢ'), "E8", "-"},
    {hex('ㅣ'), "D5", "-"}
};

PFont koreanFont;

void setup()
{
    //size(1000, 500, P2D);
    // Create a font that supports Korean. You must have this font installed on your system.
    //koreanFont = createFont("Noto Sans CJK KR", 32); // Try "NanumGothic" or another if this doesn't work
    //textFont(koreanFont);
    //fill(255);
    //background(0);
    //textSize(32);

    String[][] result = KoreanToBraille(s);

    for (int i = 0; i < result.length; i++) 
    {
        println(result[i][0], result[i][1], result[i][2], result[i][3]);
    }



}

void draw()
{

}


String[][] KoreanToBraille(String s)
{
    String[][] korArray = new String[s.length()][4]; // first column for initial, second and third for medial and final consonants. A '-' appears when the medial doesn't have a second braille unicode

    for (int i = 0; i < s.length(); i++)
    {
        char ch = s.charAt(i);
        if (ch >= 0xAC00 && ch <= 0xD7A3)
        {
            int syllableIndex = ch - 0xAC00;
            int choeseongIndex = syllableIndex / (21 * 28);
            int jungseongIndex = (syllableIndex % (21 * 28)) / 28;
            int jongseongIndex = syllableIndex % 28;

            char choeseong = CHOESEONG[choeseongIndex];
            char jungseong = JUNGSEONG[jungseongIndex];
            char jongseong = JONGSEONG[jongseongIndex];

            for (int j = 0; j < korBrailleDB2.length; j++)
            {
                if (korBrailleDB2[j][0].equals(hex(jungseong)))
                {
                    korArray[i][1] = korBrailleDB2[j][1]; 
                    
                    if (korBrailleDB2[j][2].equals("-"))
                    {
                        korArray[i][2] = "-"; // No final consonant
                    }
                    else
                    {
                        korArray[i][2] = korBrailleDB2[j][2]; // Braille for medial vowel
                    }
                }
            }
            
            for (int j = 0; j < korBrailleDB.length; j++)
            {
                if (korBrailleDB[j][0].equals(hex(choeseong)))
                {
                    korArray[i][0] = korBrailleDB[j][1]; // Braille for initial consonant
                }

                if (korBrailleDB[j][0].equals(hex(jongseong)))
                {
                    korArray[i][3] = korBrailleDB[j][2]; // Braille for final consonant
                }
            }
        }
        else
        {
            // Handle other characters if necessary (also including spaces)
            korArray[i][0] = str(ch); // Just store the character as is
            korArray[i][1] = str(ch); // For 
            korArray[i][2] = str(ch); // all
            korArray[i][3] = str(ch); // parts
        }
    }

    return korArray;    
}