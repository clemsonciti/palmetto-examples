#!/usr/bin/env python

## quadratic.py is a simple Python script that, given a b, and c,
## solves the two roots of ax^2+bx+c.

import sys, math

a = float(sys.argv[1])
b = float(sys.argv[2])
c = float(sys.argv[3])
d = math.sqrt(b**2 - 4. * a * c)
print 'x1=', (-b + d) / (2. * a)
print 'x2=', (-b - d) / (2. * a)
