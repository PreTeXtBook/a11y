import sys, argparse, codecs
from brf import Encoding, NABT_glyph_string, BLDT_glyph_string

parser = argparse.ArgumentParser()
parser.add_argument("-s", help = \
                    "Treat input as a string and print the translation",
                    action = "store_true")
parser.add_argument("-alt", help =\
                    "Use an alternative NABT table for the conversion",
                    action = "store_true")
parser.add_argument("-d", help =\
                    "Produce both Unicode and BRF underneath",
                    action = "store_true")
parser.add_argument("name_string", help =\
                    "BRF file name or a string, if the switch -s is present")
args = parser.parse_args()

if args.alt:
    convert = Encoding(NABT_glyph_string)
else:
    convert = Encoding(BLDT_glyph_string)

if args.s:
    # if we are just translating a string:
    print(convert.brf2unicode(args.name_string))
    if args.d:
        # Print the original BRF underneath
        print(args.name_string)
else:
    # If -s switch is not provided, we are translating a file
    # The output will have the txt extension
    brf_file = args.name_string
    out_file = brf_file.split('.')[0]+'.txt'
    f = open(brf_file,'r')
    out = codecs.open(out_file,'w','utf-8-sig')

    for line in f.readlines():
        out.write(convert.brf2unicode(line))
        if args.d:
            # Print the original BRF underneath followed by a blank line
            out.write(line)
            out.write('\n')
    f.close()
    out.close()
