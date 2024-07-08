import numpy
import sys
import os
import time

infile = sys.argv[1]
outfile = infile.replace('inputs', 'outputs').replace('txt', 'out')
M = numpy.loadtxt(infile)
numpy.savetxt(outfile, M.T)
time.sleep(5)
print("Finished processing file ", infile)
