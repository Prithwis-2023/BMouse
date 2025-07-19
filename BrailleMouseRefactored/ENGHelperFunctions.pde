final int[] numerals = {1, 2, 3, 4, 5, 6, 7, 8, 9, 0};

final char[] alphabets = 
{
    'a', 'b', 'c', 'd',  'e', 'f', 'g', 'h', 'i', 
    'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
    's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
};

String[][] engBrailleDB = 
{             
    {hex('a'),  "⠁"},                                    // 0x2801
    {hex(','), "⠂"},                                    // 0x2802
    {hex('b'), "⠃"},                                   // 0x2803
    {hex('\''), "⠄"},                                 // 0x2804
    {hex('k'), "⠅"},                                 // 0x2805 
    {hex(';'), "⠆"},                                // 0x2806
    {hex('l'), "⠇"},                               // 0x2807
    {hex('c'), "⠉"},                              // 0x2809
    {hex('i'), "⠊"},                             // 0x280A
    {hex('f'), "⠋"},                            // 0x280B
    {hex('/'), "⠌"},                           // 0x280C
    {hex('m'), "⠍"},                          // 0x280D
    {hex('s'), "⠎"},                         // 0x280E
    {hex('p'), "⠏"},                        // 0x280F
    {hex('e'), "⠑"},                       // 0x2811
    {hex('h'), "⠓"},                      // 0x2813
    {hex('o'), "⠕"},                     // 0x2815
    {hex('!'), "⠖"},                    // 0x2816
    {hex('r'), "⠗"},                   // 0x2817
    {hex('d'), "⠙"},                  // 0x2819
    {hex('j'), "⠚"},                 // 0x281A
    {hex('g'), "⠛"},                // 0x281B 
    {hex('n'), "⠝"},               // 0x281D
    {hex('t'), "⠞"},              // 0x281E
    {hex('q'), "⠟"},             // 0x281F
    {hex('-'), "⠤"},            // 0x2824
    {hex('u'), "⠥"},           // 0x2825
    {hex('"'), "⠦"},          // 0x2826
    {hex('v'), "⠧"},         // 0x2827
    {hex('x'), "⠭"},        // 0x282D
    {hex('.'), "⠲"},       // 0x2832
    {hex('"'), "⠴"},      // 0x2834
    {hex('z'), "⠵"},     // 0x2835
    {hex('('), "⠶"},    // 0x2836
    {hex('w'), "⠺"},   // 0x283A
    {hex('y'), "⠽"},  // 0x283D
    {hex('#'), "⠼"}  // 0x283C
};

// This function converts a Braille dot pattern to its corresponding one-byte code
String convertBDotTo1ByteCodeENG (String bDot) // this function converts a Braille dot pattern to its corresponding one-byte code
{
  int index = unhex(hex(bDot.charAt(0))) - 0x2800; // Convert dot string to integer and subtract 0x2800 to get the index
  return hex(index).substring(hex(index).length() - 2); // Convert the index to hex and return the last two characters
}

String bUnicodesStringENG (String group, int spacesLeft, int spacesRight)
{
    group = group.toLowerCase();
    char[] charsArray = group.toCharArray();
    int paddedLength = spacesLeft + charsArray.length + spacesRight;
    char[] finalGroup = new char[paddedLength];
    StringBuilder result = new StringBuilder(); // StringBuilder objects are mutable, allowing for modifications
    boolean numberMode = false;
    // Fill the left-padding with ' '
    for (int i = 0; i < spacesLeft; i++) 
    {
        finalGroup[i] = ' ';
    }
    // Copying the original array into the rest
    for (int i = 0; i < charsArray.length; i++) 
    {
        finalGroup[spacesLeft + i] = charsArray[i];
    }
    // Fill the right-padding with ' '
    for (int i = spacesLeft + charsArray.length; i < paddedLength; i++) 
    {
        finalGroup[i] = ' ';
    }

    for (int i = 0; i < finalGroup.length; i++)
    {
        if (finalGroup[i] == ' ')
        {
            result.append("00");
            numberMode = false;
        }
        else if (Character.isDigit(finalGroup[i]))
        {
            if (!numberMode)
            {
                result.append(convertBDotTo1ByteCodeENG("⠼")); // append only once
                numberMode = true;
            }

            int digit = finalGroup[i] - '0';
            char correspondingChar = (char) ('a' + digit - 1);
            for (int j = 0; j < engBrailleDB.length; j++)
            {
                if (engBrailleDB[j][0].equals(hex(correspondingChar)))
                {
                    result.append(convertBDotTo1ByteCodeENG(engBrailleDB[j][1]));
                    break;
                }
            }
        }
        else 
        {
            numberMode = false;
            for (int j = 0; j < engBrailleDB.length; j++)
            {
                if (engBrailleDB[j][0].equals(hex(finalGroup[i])))
                {
                    result.append(convertBDotTo1ByteCodeENG(engBrailleDB[j][1]));
                    break;
                }
            }
        }
    }
    return result.toString();
}