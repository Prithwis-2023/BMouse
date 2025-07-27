import java.util.*;
import java.util.regex.*;

HashMap <Character, String> brailleMap = new HashMap<Character, String>()
{{
    put('ঁ', "⠄");
    put('ং', "⠰");
    put('ঃ', "⠠");
    put('।', "⠲");
    put('অ', "⠁");
    put('আ', "⠜");
    put('ই', "⠊");
    put('ঈ', "⠔");
    put('উ', "⠥");
    put('ঊ', "⠳");
    put('ঋ', "⠗");
    put('ঌ', "⠇");
    put('এ', "⠑");
    put('ঐ', "⠌");
    put('ও', "⠕");
    put('ঔ', "⠭");
    put('ক', "⠅");
    put('খ', "⠨");
    put('গ', "⠛");
    put('ঘ', "⠣");
    put('ঙ', "⠬");
    put('চ', "⠉");
    put('ছ', "⠡");
    put('জ', "⠚");
    put('ঝ', "⠴");
    put('ঞ', "⠒");
    put('ট', "⠾");
    put('ঠ', "⠺");
    put('ড', "⠻");
    put('ঢ', "⠿");
    put('ণ', "⠼");
    put('ত', "⠞");
    put('থ', "⠹");
    put('দ', "⠙");
    put('ধ', "⠮");
    put('ন', "⠝");
    put('প', "⠏");
    put('ফ', "⠖");
    put('ব', "⠃");
    put('ভ', "⠘");
    put('ম', "⠍");
    put('য', "⠽");
    put('র', "⠗");
    put('ল', "⠇");
    put('শ', "⠩");
    put('ষ', "⠯");
    put('স', "⠎");
    put('হ', "⠓");
    put('ক্ষ', "⠟");
    put('জ্ঞ', "⠱");
    put('ৎ', "⠞");
    put('ড়', "⠻");
    put('ঢ়', "⠻");
    put('য়', "⠢");
    put('ঽ', "⠂");
    put('া', "⠜");
    put('ি', "⠊");
    put('ী', "⠔");
    put('ু', "⠥");
    put('ূ', "⠳");
    put('ৃ', "⠗");
    put('ে', "⠑");
    put('ৈ', "⠌");
    put('ো', "⠕");
    put('ৌ', "⠪");
    put('্', "⠈");
    put('০', "⠚");
    put('১', "⠁");
    put('২', "⠃");
    put('৩', "⠉");
    put('৪', "⠙");
    put('৫', "⠑");
    put('৬', "⠋");
    put('৭', "⠛");
    put('৮', "⠓");
    put('৯', "⠊");
    put(',', "⠂");
    put(';', "⠆");
    put(':', "⠒");
    put('!', "⠖");
    put('?', "⠦");
    put('/', "⠌");
}};

final String indicPunctuations =  "\u0964\u0965\uAAF1\uAAF0\uABEB\uABEC\uABED\uABEE\uABEF\u1C7E\u1C7F";
final Pattern indicPunctuationPattern = Pattern.compile("([\\p{Punct}" + indicPunctuations + "])");
final Pattern multiSpacePattern = Pattern.compile("\\s+");
final Pattern numberSeqPattern = Pattern.compile("([0-9]+[ ,.:/])+[0-9]+");

List<String> trivialTokenizeIndic(String text)
{
    // Step 1: add spaces around punctuation
    String temp = indicPunctuationPattern.matcher(text.replace("\t", " ")).replaceAll(" $1 ");

    // Step 2: replace multiple spaces with a single space
    temp = multiSpacePattern.matcher(temp).replaceAll(" ").trim();

    // Step 3: protect number sequences (remove spaces in them)
    Matcher numMatcher = numberSeqPattern.matcher(temp);
    StringBuilder result =  new StringBuilder();
    int lastEnd = 0;

    while (numMatcher.find()) 
    {
        result.append(temp, lastEnd, numMatcher.start());
        result.append(temp.substring(numMatcher.start(), numMatcher.end()).replace(" ", ""));
        lastEnd = numMatcher.end();
    }   
    result.append(temp.substring(lastEnd));

    // Step 4: split into tokens
    return Arrays.asList(result.toString().split(" "));
}

List<String> trivialTokenize(String text, String language)
{
    if (language.equals("bn")) 
    {
        return trivialTokenizeIndic(text);
    }
    return Arrays.asList(text.split("\\s+"));
}
