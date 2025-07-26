import java.util.Map;

HashMap<Character, String> esBrailleDB = new HashMap<Character, String>() {{
    put('a', "⠁");
    put('b', "⠃");
    put('c', "⠉");
    put('d', "⠙");
    put('e', "⠑");
    put('f', "⠋");
    put('g', "⠛");
    put('h', "⠓");
    put('i', "⠊");
    put('j', "⠚");
    put('k', "⠅");
    put('l', "⠇");
    put('m', "⠍");
    put('n', "⠝");
    put('o', "⠕");
    put('p', "⠏");
    put('q', "⠟");
    put('r', "⠗");
    put('s', "⠎");
    put('t', "⠞");
    put('u', "⠥");
    put('v', "⠧");
    put('w', "⠺");
    put('x', "⠭");
    put('y', "⠽");
    put('z', "⠵");
    put('á', "⠷");
    put('é', "⠮");
    put('í', "⠌");
    put('ó', "⠬");
    put('ú', "⠾");
    put('ñ', "⠻");
    put('ü', "⠳");
    put(',', "⠂");
    put('.', "⠄");
    put('\'', "⠄");
    put(';', "⠆");
    put(':', "⠒");
    put('*', "⠔");
    put('-', "⠤");
    put('?', "⠢");
    put('¿', "⠢");
    put('¡', "⠖");
    put('!', "⠖");
}};

String bUnicodesStringES (String group, int spacesLeft, int spacesRight)
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
                result.append(convertBDotTo1ByteCode("⠼")); // append only once
                numberMode = true;
            }

            int digit = finalGroup[i] - '0';
            char correspondingChar = (char) ('a' + digit - 1);
            if (esBrailleDB.containsKey(correspondingChar))
            {
                result.append(convertBDotTo1ByteCode(esBrailleDB.get(correspondingChar)));
            }
        }
        else 
        {
            numberMode = false;
            if (esBrailleDB.containsKey(finalGroup[i]))
            {
                result.append(convertBDotTo1ByteCode(esBrailleDB.get(finalGroup[i])));
            }
        }
    }
    return result.toString();
}