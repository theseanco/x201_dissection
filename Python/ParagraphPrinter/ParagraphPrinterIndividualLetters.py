# A Python script to print random (potentially) paragraphs from scripts within folders when triggered

import os, random, time, sys



# open code to be read and split into paragraphs
pyscript = open(os.path.join(os.path.dirname(__file__), 'TestScripts/python.py'))
pyparagraph = []
scscript = open(os.path.join(os.path.dirname(__file__), 'TestScripts/supercollider.scd'))
scparagraph = []
pdescript = open(os.path.join(os.path.dirname(__file__), 'TestScripts/processing.pde'))
pdeparagraph = []
# fill array with script names to be called later
scripts = [scparagraph, pdeparagraph, pyparagraph]

scripts = [scparagraph, pdeparagraph, pyparagraph]

# A function which chops scripts into paragraphs
def chopscript(script,out):
    para = []
    # splits the script into paragraphs
    for line in script:
        if line == "\n":
            para.append(line)
            out.append(para)
            para = []
        else:
            para.append(line)

# calls the function on each file to chop them all up
chopscript(pyscript,pyparagraph)
chopscript(pdescript,pdeparagraph)
chopscript(scscript,scparagraph)

# prints a random paragraph
def scriptprint(script):
    code = ''.join(script[random.randrange(0,len(script))])
    for item in code:
        sys.stdout.write('%s' % item)
        sys.stdout.flush()
        time.sleep(0.05)

# print random paragraph from random script
scriptprint(random.choice(scripts))

# i can then send this a random.choose of an array of script string names
#printscript(pyscript)

#print pyscriptlines
#print scscriptlines
#print processingscriptlines
