# -*- coding: utf-8 -*-
"""
Library with simple funcions for learning and better understanding polarization concepts.

It contains:

A function for rotating optical elements such as polarizers and waveplates 
defined by a Jones Matrix.

A function for plotting polarizarion ellipses of a given polarization state.

"""

__author__      = "Santiago Echeverri Chacon"
__copyright__   = "Universidad EAFIT"
__license__ = "MIT"
__version__ = "1"
__maintainer__ = "Santiago Echeverri"
__email__ = " santiag77e@gmail.com"
__status__ = "ongoing"


def Rotate( element, theta):     
    """Applies a rotation on any polarizing element given 
    its Jones matrix representation and a angle of rotation.
    The angle is to be ginven in radians and the matrix.  

    Examples for elements to imput are the vertical polarizer 
    and a quarter waveplate:

    V = Matrix([ [ 1 , 0],\
                        [ 0 , 0] ])

    QWP = Matrix([ [ 1 , 0],  \
                            [ 0 , -1j] ])
    """
    from sympy import Matrix, cos, sin

    assert isinstance(element, Matrix)
    assert element.shape == (2,2)
    
    rotator = Matrix([ [ cos(theta),  sin(theta)], \
                                 [-sin(theta), cos(theta) ] ])
    return rotator.transpose() * element * rotator

def plot_ellipse( state ):


    

