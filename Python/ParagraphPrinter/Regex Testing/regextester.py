import re, random

letter = 'a'
number = '9'
symbol = '%'
linebreak = '\n'
spaces = ' '

chars = random.choice([letter, number, symbol, linebreak, spaces])

# regex for newline not needed
letterexp = re.compile('[a-zA-Z]')
numberexp = re.compile('[0-9]')
symbolexp = re.compile('[^0-9a-zA-Z \n  ]')

matched = letterexp.match(chars)
if matched:
    print 'LETTER!'
    print chars
else:
    matched = numberexp.match(chars)
    if matched:
        print 'NUMBER!'
        print chars
    else:
        matched = symbolexp.match(chars)
        if matched:
            print 'SYMBOL!'
            print chars
        else:
            if chars == '\n':
                print chars
                print "linebreak!"
            else:
                print chars+'space!'
