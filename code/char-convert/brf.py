# Auxiliary methods for dealing with BRF files, Unicode Braille, and
# dot patterns.

'''
 The idea behind the BRF file is that each of the 64 6-dot Braille
 characters can be represented by some ASCII character. The authors of
 the format picked a correspondence, mostly driven by the meaning
 of the Braille glyph in (literary) Braille.
 
 A slight complication is that there are (at least) two such representations
 One is a North American ASCII Braille Table. The table, which we will
 abbreviate as NABT, can be found for example at 
 http://www.dotlessbraille.org/asciibrltable.htm 
 Another table is BrailleLite Display Table (BLDT) is similar in spirit, but
 with just enough differences to make life interesting. The table can be found
 at http://www.dotlessbraille.org/brllitetable.htm
 Most notable difference is that capital letters in NABT are lower-case in BLDT,
 and there are a few special ASCII characters that are different. For example,
 the the Braille cell 'Dots-4' is represented by '@' in NABT and by '`' in BLDT.

 The term "character" is sometimes ambiguous: it may refer either to a displayed
 symbol or to the code (such as ASCII code or Unicode) corresponding to the
 character. When this might cause confusion, we will use the following
 terminology. A character that is displayed will be called a 'glyph',
 and its code will be called a 'code point'.

 The Unicode Braille code points have an intuitive pattern:
 0x2800 + [ dot6 * 2^5 + dot5 * 2^4 + ... + dot1 ], where
 dotN is 0 if the Nth Braille dot is not used and is 1 otherwise. For example,
 the code point for 'Dots-1346' symbol '⠭' is
 0x2800 + 2^5+2^3+2^2+1 = 0x2800 + 45 = 0x282d, because 45 = 0x2d
 in hexadecimal system. In NABT, the symbol '⠭' is coded by 'X', and in
 BLDT by 'x'.

 The liblouis conversion produces BLDT, so this will be the default option
 below. A word of caution: liblouis seems to pass all Unicode glyphs that
 it does not recognize to BRF file as hexadecimal code points, hoping that
 maybe the embossing software will know what to do with them.
 
 For convenience, we will grab the dot patterns of the Unicode Braille
 glyphs. After importing unicodedata module, the command:
 print(unicodedata.name(chr(0x2812))) will produce
 BRAILLE PATTERN DOTS-25
 We will take the last part of the string: 25
 The only exception is the blank Braille cell, that will have the pattern 0.
'''

# First define the glyph strings, in the order of Unicode glyphs.
NABT_glyph_string =\
        " A1B'K2L@CIF/MSP\"E3H9O6R^DJG>NTQ,*5<-U8V.%[$+X!&;:4\\0Z7(_?W]#Y)="
BLDT_glyph_string =\
        " a1b\'k2l`cif/msp\"e3h9o6r~djg>ntq,*5<-u8v.%{$+x!&;:4|0z7(_?w}#y)="

# To get the dot pattern from a Unicode Braille character:
from unicodedata import name as char_name
def get_pattern(braille_char):    
    temp = char_name(braille_char).split("-")
    # All the characters except the blank cell will have 2 items in temp
    if len(temp) == 2:
        return(int(temp[1]))
    else:
        return(0)


class Encoding():
    # glyph_string is the string of ASCII characters that will be
    # paired with Braille Unicode characters at initialization.
    # Must be in the order from '\u2800' to '\u283f'.
    def __init__(self, glyph_string = BLDT_glyph_string):
        self.glyph_list = list(glyph_string)
        self.unicode_list = [chr(i) for i in range(0x2800,0x2840)]
        self.dot_patterns = [get_pattern(c) for c in self.unicode_list]
        self.brf2unicode_dict = dict(zip(self.glyph_list,self.unicode_list))
        self.unicode2brf_dict = dict(zip(self.unicode_list,self.glyph_list))
        self.dots2brf_dict = dict(zip(self.dot_patterns,self.glyph_list))
        self.brf2dots_dict = dict(zip(self.glyph_list,self.dot_patterns))

    # Python 3 has built-in string translation, but it is version-dependent
    def brf2unicode(self,brf_string):
        out = ""
        for char in brf_string:
            # Pass the end-of-line, new-page characters through
            if char in ['\n','\x0c']:
                out += char
            # Pass the 6-cell Braille Unicode characters through:
            if ord(char) in range(0x2800,0x2840):
                out += char
            # If the character is expected in BRF string, produce the
            # corresponding Braille cell
            elif char in self.glyph_list:
                out += self.brf2unicode_dict[char]
            # Don't want to crash, but at least print a warning.
            else:
                print("Invalid character {}".format(char))
                out += 'X'
        return(out)

    def dots2brf(self,dots_list):
        return("".join([self.dots2brf_dict[pattern] for pattern in dots_list]))

    # Maybe add other conversions if needed.
"""
Example of use:

convert = Encoding()
convert.brf2unicode('and')  --> outputs '⠁⠝⠙'

This is intended to be used on the output of file2brl.
"""




