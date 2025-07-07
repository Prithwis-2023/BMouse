import processing.serial.*;

String s = "안녕하세요 반갑습니다";

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

PFont koreanFont;

void setup()
{
  size(500, 500);
  // Create a font that supports Korean. You must have this font installed on your system.
  koreanFont = createFont("Noto Sans CJK KR", 32); // Try "NanumGothic" or another if this doesn't work
  textFont(koreanFont);
  textSize(32);
}

void draw()
{
    for (int i = 0; i < s.length(); i++)
    {
        char ch = s.charAt(i);
        if (ch >= 0xAC00 && ch <= 0xD7A3)
        {
            int syllableIndex = ch - 0xAC00;
            int choseongIndex = syllableIndex / (21 * 28);          // initial
            int jungseongIndex = (syllableIndex % (21 * 28)) / 28;  // medial
            int jongseongIndex = syllableIndex % 28;                // final

            char choseong = CHOESEONG[choseongIndex];
            char jungseong = JUNGSEONG[jungseongIndex];
            char jongseong = JONGSEONG[jongseongIndex];

            println(choseong);
            println(jungseong);
            println(jongseong);
        }
        println("-");
    }
}
