import processing.serial.*;

Serial myPort;

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

String[][] korBrailleDB =   // for choeseong and jongseong
{
    {hex('\0'), "-", "-"},
    {hex('ㄱ'), "2808", "2801"},
    {hex('ㄴ'), "2809", "2812"},
    {hex('ㄷ'), "280A", "2814"},
    {hex('ㄹ'), "2810", "2802"},
    {hex('ㅁ'), "2811", "2822"},
    {hex('ㅂ'), "2818", "2803"},
    {hex('ㅅ'), "2880", "2840"},
    {hex('ㅇ'), "2800", "2836"},
    {hex('ㅈ'), "2828", "2805"},
    {hex('ㅊ'), "2830", "2806"},
    {hex('ㅋ'), "280B", "2816"},
    {hex('ㅌ'), "2813", "2826"},
    {hex('ㅍ'), "2819", "2832"},
    {hex('ㅎ'), "281A", "2834"}
};

String [][] korBrailleDB2 =  // for jungseong
{
    {hex('ㅏ'), "2823", "-"},
    {hex('ㅐ'), "2817", "-"},
    {hex('ㅑ'), "281C", "-"},
    {hex('ㅒ'), "281C", "2817"},
    {hex('ㅓ'), "280E", "-"},
    {hex('ㅔ'), "281D", "-"},
    {hex('ㅕ'), "2831", "-"},
    {hex('ㅖ'), "280C", "-"},
    {hex('ㅗ'), "2825", "-"},
    {hex('ㅘ'), "2827", "-"},
    {hex('ㅙ'), "2827", "2817"},
    {hex('ㅚ'), "283D", "-"},
    {hex('ㅛ'), "282C", "-"},
    {hex('ㅜ'), "280D", "-"},
    {hex('ㅝ'), "280F", "-"},
    {hex('ㅞ'), "280F", "2817"},
    {hex('ㅟ'), "280D", "2817"},
    {hex('ㅠ'), "2829", "-"},
    {hex('ㅡ'), "282A", "-"},
    {hex('ㅢ'), "283A", "-"},
    {hex('ㅣ'), "2815", "-"}
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
    myPort = new Serial(this, Serial.list()[0], 9600);

    KoreanToBraille(s);
}

void sendToArduino(String[] hanguelBlock)
{
    print("Sending: ");

    for (int i = 0; i < hanguelBlock.length; i++)
    {
        String Str = hanguelBlock[i];
        if (Str.equals(" "))
        {
            myPort.write((byte) 0x28); // high byte of 0x2800
            myPort.write((byte) 0x00); // low byte of 0x2800 
            print("2800 ");
        }
        else if (Str.equals("-"))
        {
            continue; // Skip the dash, as it is not sent to Arduino
        }
        else
        {
            int val = unhex(Str);
            byte highByte = (byte) (val >> 8); // Get the high byte
            byte lowByte = (byte) (val & 0xFF); // Get the low byte
            myPort.write(highByte); // Send high byte
            myPort.write(lowByte); // Send low byte
            print(hex(val, 4) + " "); // print in 4 digits hex format
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

        String[] braille = new String[4];
        
        for (int j = 0; j < korBrailleDB.length; j++)
        {
            if (korBrailleDB[j][0].equals(hex(choeseong)))
            {
                braille[0] = korBrailleDB[j][1]; // Braille for initial consonant
            }

            if (korBrailleDB[j][0].equals(hex(jongseong)))
            {
                braille[3] = korBrailleDB[j][2]; // Braille for final consonant
            }
        }

        for (int j = 0; j < korBrailleDB2.length; j++)
        {
            if (korBrailleDB2[j][0].equals(hex(jungseong)))
            {
                braille[1] = korBrailleDB2[j][1]; // Braille for first part of medial vowel
                braille[2] = korBrailleDB2[j][2]; // Second part of medial vowel or "-" (if nothing)
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
        delay(200); // Delay to ensure Arduino can process the data
    }   
    // sending termination signal. 0xFFFF is beyond the range of Braille unicode so safe to use
    myPort.write((byte) 0xFF);
    myPort.write((byte) 0xFF);
}   