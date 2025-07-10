import processing.serial.*;
import java.util.Map;

Serial myPort;

String s = "마마";

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


String[][] korBrailleDB =  // for choeseong and jongseong
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

String convertBDotTo1ByteCode (String bDot) // this function converts a Braille dot pattern to its corresponding one-byte code
{
    int index = unhex(hex(bDot.charAt(0))) - 0x2800; // Convert dot string to integer and subtract 0x2800 to get the index
    return hex(index);
}

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
    myPort = new Serial(this, Serial.list()[0], 9600);

    KoreanToBraille(s);
    //println(hex('⠣'));
    
}

void sendToArduino(String[] hanguelBlock)
{
    print("Sending: ");

    for (int i = 0; i < hanguelBlock.length; i++)
    {
        String Str = hanguelBlock[i];
        if (Str.equals("00000000")) // if the circle is in the choeseong, ignore
        {
            continue;
        }
        if (Str.equals(" "))
        {
            myPort.write((byte) 0x00); // Send space as 0xC0 as these are the 7th and 8th dots which are not used by any hangul character
            print("00 ");
        }
        else if (Str.equals("-"))
        {
            continue; // Skip the dash, as it is not sent to Arduino
        }
        else
        {
            int val = unhex(Str);
            myPort.write((byte) val); // Send the byte to Arduino
            delay(200);
            print(hex(val, 2) + " "); // print in 2 digits hex format
        }
    }
    println();
}
void draw(){}

String[] korBlockToBraille(char ch)
{
    if (ch>= 0xAC00 && ch <= 0xD7A3) /// check if the character is a Hanguel syllable 
    {
        int syllableIndex = ch - 0xAC00;
        int choeseongIndex = syllableIndex / (21 * 28);
        int jungseongIndex = (syllableIndex % (21 * 28)) / 28;
        int jongseongIndex = syllableIndex % 28;

        char choeseong = CHOESEONG[choeseongIndex];
        char jungseong = JUNGSEONG[jungseongIndex];
        char jongseong = JONGSEONG[jongseongIndex];

        String[] braille = {"-", "-", "-", "-"}; 
        
        for (int j = 0; j < korBrailleDB.length; j++)
        {
            if (korBrailleDB[j][0].equals(hex(choeseong)))
            {
                braille[0] = convertBDotTo1ByteCode(korBrailleDB[j][1]); // Braille for initial consonant
            }

            if (korBrailleDB[j][0].equals(hex(jongseong)))
            {
                if (!hex(jongseong).equals(hex('\0')))
                {
                    braille[3] = convertBDotTo1ByteCode(korBrailleDB[j][2]); // Braille for final consonant
                }
                else
                {
                    braille[3] = "-"; // If no final consonant, set to "-"
                }
            }
        }

        for (int j = 0; j < korBrailleDB2.length; j++)
        {
            if (korBrailleDB2[j][0].equals(hex(jungseong)))
            {
                braille[1] = convertBDotTo1ByteCode(korBrailleDB2[j][1]); // Braille for first part of medial vowel
                if (!korBrailleDB2[j][2].equals("-"))
                {
                    braille[2] = convertBDotTo1ByteCode(korBrailleDB2[j][2]); // Second part of medial vowel
                }
                else
                {
                    braille[2] = "-"; // If no second part, set to "-"
                }
            }
        }
        return braille;
    }
    else
    {
        return new String[]{str(ch), "-", "-", "-"}; // Return the character as is if not a Hanguel syllable, even for spaces between hanguel words
    }
}

void KoreanToBraille(String s)
{
    String[][] korArray = new String[s.length()][4]; // first column for initial, second and third for medial and final consonants. A '-' appears when the medial doesn't have a second braille unicode

    for (int i = 0; i < s.length(); i++)
    {
        char ch = s.charAt(i);
        String[] braille = korBlockToBraille(ch);
        
        korArray[i][0] = braille[0]; // Initial consonant
        korArray[i][1] = braille[1]; // Medial vowel
        korArray[i][2] = braille[2]; // Second part of medial vowel or "-"
        korArray[i][3] = braille[3]; // Final consonant

        sendToArduino(korArray[i]); // Send each Hanguel block to Arduino
        delay(500); // Delay to ensure Arduino can process the data
    }   
    // sending termination signal, which are the 7th and 8th dots
    myPort.write((byte) 0xC0);
    println("Sending: C0");
}   