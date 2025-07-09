import processing.serial.*;
import java.util.Map;

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

String[] oneByteCodes =  // from the library rewritten in string format by GPT (!)
{
  "0xFF", // 0x2800
  "0xF7", // 0x2801
  "0xEF", // 0x2802
  "0xE7", // 0x2803
  "0xDF", // 0x2804
  "0xD7", // 0x2805
  "0xCF", // 0x2806
  "0xC7", // 0x2807
  "0xFE", // 0x2808
  "0xF6", // 0x2809
  "0xEE", // 0x280A
  "0xE6", // 0x280B
  "0xDE", // 0x280C
  "0xD6", // 0x280D
  "0xCE", // 0x280E
  "0xC6", // 0x280F
  "0xFD", // 0x2810
  "0xF5", // 0x2811
  "0xED", // 0x2812
  "0xE5", // 0x2813
  "0xDD", // 0x2814
  "0xD5", // 0x2815
  "0xCD", // 0x2816
  "0xC5", // 0x2817
  "0xFC", // 0x2818
  "0xF4", // 0x2819
  "0xEC", // 0x281A
  "0xE4", // 0x281B
  "0xDC", // 0x281C
  "0xD4", // 0x281D
  "0xCC", // 0x281E
  "0xC4", // 0x281F
  "0xFB", // 0x2820
  "0xF3", // 0x2821
  "0xEB", // 0x2822
  "0xE3", // 0x2823
  "0xDB", // 0x2824
  "0xD3", // 0x2825
  "0xCB", // 0x2826
  "0xC3", // 0x2827
  "0xFA", // 0x2828
  "0xF2", // 0x2829
  "0xEA", // 0x282A
  "0xE2", // 0x282B
  "0xDA", // 0x282C
  "0xD2", // 0x282D
  "0xCA", // 0x282E
  "0xC2", // 0x282F
  "0xF9", // 0x2830
  "0xF1", // 0x2831
  "0xE9", // 0x2832
  "0xE1", // 0x2833
  "0xD9", // 0x2834
  "0xD1", // 0x2835
  "0xC9", // 0x2836
  "0xC1", // 0x2837
  "0xF8", // 0x2838
  "0xF0", // 0x2839
  "0xE8", // 0x283A
  "0xE0", // 0x283B
  "0xD8", // 0x283C
  "0xD0", // 0x283D
  "0xC8", // 0x283E
  "0xC0", // 0x283F
  "0x7F", // 0x2840
  "0x77", // 0x2841
  "0x6F", // 0x2842
  "0x67", // 0x2843
  "0x5F", // 0x2844
  "0x57", // 0x2845
  "0x4F", // 0x2846
  "0x47", // 0x2847
  "0x7E", // 0x2848
  "0x76", // 0x2849
  "0x6E", // 0x284A
  "0x66", // 0x284B
  "0x5E", // 0x284C
  "0x56", // 0x284D
  "0x4E", // 0x284E
  "0x46", // 0x284F
  "0x7D", // 0x2850
  "0x75", // 0x2851
  "0x6D", // 0x2852
  "0x65", // 0x2853
  "0x5D", // 0x2854
  "0x55", // 0x2855
  "0x4D", // 0x2856
  "0x45", // 0x2857
  "0x7C", // 0x2858
  "0x74", // 0x2859
  "0x6C", // 0x285A
  "0x64", // 0x285B
  "0x5C", // 0x285C
  "0x54", // 0x285D
  "0x4C", // 0x285E
  "0x44", // 0x285F
  "0x7B", // 0x2860
  "0x73", // 0x2861
  "0x6B", // 0x2862
  "0x63", // 0x2863
  "0x5B", // 0x2864
  "0x53", // 0x2865
  "0x4B", // 0x2866
  "0x43", // 0x2867
  "0x7A", // 0x2868
  "0x72", // 0x2869
  "0x6A", // 0x286A
  "0x62", // 0x286B
  "0x5A", // 0x286C
  "0x52", // 0x286D
  "0x4A", // 0x286E
  "0x42", // 0x286F
  "0x79", // 0x2870
  "0x71", // 0x2871
  "0x69", // 0x2872
  "0x61", // 0x2873
  "0x59", // 0x2874
  "0x51", // 0x2875
  "0x49", // 0x2876
  "0x41", // 0x2877
  "0x78", // 0x2878
  "0x70", // 0x2879
  "0x68", // 0x287A
  "0x60", // 0x287B
  "0x58", // 0x287C
  "0x50", // 0x287D
  "0x48", // 0x287E
  "0x40", // 0x287F
  "0xBF", // 0x2880
  "0xB7", // 0x2881
  "0xAF", // 0x2882
  "0xA7", // 0x2883
  "0x9F", // 0x2884
  "0x97", // 0x2885
  "0x8F", // 0x2886
  "0x87", // 0x2887
  "0xBE", // 0x2888
  "0xB6", // 0x2889
  "0xAE", // 0x288A
  "0xA6", // 0x288B
  "0x9E", // 0x288C
  "0x96", // 0x288D
  "0x8E", // 0x288E
  "0x86", // 0x288F
  "0xBD", // 0x2890
  "0xB5", // 0x2891
  "0xAD", // 0x2892
  "0xA5", // 0x2893
  "0x9D", // 0x2894
  "0x95", // 0x2895
  "0x8D", // 0x2896
  "0x85", // 0x2897
  "0xBC", // 0x2898
  "0xB4", // 0x2899
  "0xAC", // 0x289A
  "0xA4", // 0x289B
  "0x9C", // 0x289C
  "0x94", // 0x289D
  "0x8C", // 0x289E
  "0x84", // 0x289F
  "0xBB", // 0x28A0
  "0xB3", // 0x28A1
  "0xAB", // 0x28A2
  "0xA3", // 0x28A3
  "0x9B", // 0x28A4
  "0x93", // 0x28A5
  "0x8B", // 0x28A6
  "0x83", // 0x28A7
  "0xBA", // 0x28A8
  "0xB2", // 0x28A9
  "0xAA", // 0x28AA
  "0xA2", // 0x28AB
  "0x9A", // 0x28AC
  "0x92", // 0x28AD
  "0x8A", // 0x28AE
  "0x82", // 0x28AF
  "0xB9", // 0x28B0
  "0xB1", // 0x28B1
  "0xA9", // 0x28B2
  "0xA1", // 0x28B3
  "0x99", // 0x28B4
  "0x91", // 0x28B5
  "0x89", // 0x28B6
  "0x81", // 0x28B7
  "0xB8", // 0x28B8
  "0xB0", // 0x28B9
  "0xA8", // 0x28BA
  "0xA0", // 0x28BB
  "0x98", // 0x28BC
  "0x90", // 0x28BD
  "0x88", // 0x28BE
  "0x80", // 0x28BF
  "0x3F", // 0x28C0
  "0x37", // 0x28C1
  "0x2F", // 0x28C2
  "0x27", // 0x28C3
  "0x1F", // 0x28C4
  "0x17", // 0x28C5
  "0x0F", // 0x28C6
  "0x07", // 0x28C7
  "0x3E", // 0x28C8
  "0x36", // 0x28C9
  "0x2E", // 0x28CA
  "0x26", // 0x28CB
  "0x1E", // 0x28CC
  "0x16", // 0x28CD
  "0x0E", // 0x28CE
  "0x06", // 0x28CF
  "0x3D", // 0x28D0
  "0x35", // 0x28D1
  "0x2D", // 0x28D2
  "0x25", // 0x28D3
  "0x1D", // 0x28D4
  "0x15", // 0x28D5
  "0x0D", // 0x28D6
  "0x05", // 0x28D7
  "0x3C", // 0x28D8
  "0x34", // 0x28D9
  "0x2C", // 0x28DA
  "0x24", // 0x28DB
  "0x1C", // 0x28DC
  "0x14", // 0x28DD
  "0x0C", // 0x28DE
  "0x04", // 0x28DF
  "0x3B", // 0x28E0
  "0x33", // 0x28E1
  "0x2B", // 0x28E2
  "0x23", // 0x28E3
  "0x1B", // 0x28E4
  "0x13", // 0x28E5
  "0x0B", // 0x28E6
  "0x03", // 0x28E7
  "0x3A", // 0x28E8
  "0x32", // 0x28E9
  "0x2A", // 0x28EA
  "0x22", // 0x28EB
  "0x1A", // 0x28EC
  "0x12", // 0x28ED
  "0x0A", // 0x28EE
  "0x02", // 0x28EF
  "0x39", // 0x28F0
  "0x31", // 0x28F1
  "0x29", // 0x28F2
  "0x21", // 0x28F3
  "0x19", // 0x28F4
  "0x11", // 0x28F5
  "0x09", // 0x28F6
  "0x01", // 0x28F7
  "0x38", // 0x28F8
  "0x30", // 0x28F9
  "0x28", // 0x28FA
  "0x20", // 0x28FB
  "0x18", // 0x28FC
  "0x10", // 0x28FD
  "0x08", // 0x28FE
  "0x00" // 0x28FF
};

String convertBDotTo1ByteCode (String bDot) // this function converts a Braille dot pattern to its corresponding one-byte code
{
    int index = unhex(hex(bDot.toCharArray()[0])) - 0x2800; // Convert dot string to integer and subtract 0x2800 to get the index
    if (index >= 0 && index < oneByteCodes.length)
    {        
        return oneByteCodes[index].substring(2); // Return the corresponding value from the array
    }
    return "00";
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
    
}

void sendToArduino(String[] hanguelBlock)
{
    print("Sending: ");

    for (int i = 0; i < hanguelBlock.length; i++)
    {
        String Str = hanguelBlock[i];
        if (Str.equals(" "))
        {
            myPort.write((byte) 0xFF); 
            print("FF ");
        }
        else if (Str.equals("-"))
        {
            continue; // Skip the dash, as it is not sent to Arduino
        }
        else
        {
            int val = unhex(Str);
            myPort.write((byte) val); // Send the byte to Arduino
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
    // sending termination signal.
    myPort.write((byte) 0xAA);
    println("Sending: AA");
}   