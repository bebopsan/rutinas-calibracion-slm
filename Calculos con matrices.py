# -*- coding: utf-8 -*-
"""
Editor de Spyder

Este archivo temporal se encuentra aquí:
C:\Users\franjas\.spyder2\.temp.py
"""

from sympy import *
x, y = symbols('x,y')
R = Matrix([[cos(x),sin(x)],[-sin(x), cos(x)]])

X,Y,Z,W = symbols('X,Y,Z,W', real = True)
M = Matrix([[X+I*Y, Z-I*W],[-Z-I*W, X+I*Y]])
Vi = Matrix([cos(y), sin(y)])
R.transpose()*R*M*Vi