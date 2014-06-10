# -*- coding: utf-8 -*-
"""
Library with simple funcions for learning and better understanding polarization concepts.

It contains:

A function for rotating optical elements such as polarizationizers and waveplates 
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


def Rotate( element, theta ):     
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

def plot_ellipse( J, name = '', show = True):
    """ Given a Jones vector representation of a wave
    this routine plots its correspondent polarization ellipse.

    Use a vector in the form:

    J =  sympy.Matrix([ [ 1 ],  \
                                    [ 0] ])
    
    """
    
    #import sympy as sy
    import matplotlib as mpl
    from mpl_toolkits.mplot3d import Axes3D
    import numpy as np
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec

    
    assert isinstance(J, np.matrix)
    assert J.shape == (2,1)
    

    "Convert elements of the vector to complex numbers"
    J_aux = np.zeros((2,1), dtype = complex)
    for i in [0,1]:
        J_aux[i] = J[i]
        
    J = J_aux
    
    mpl.rcParams['legend.fontsize'] = 10

    fig = plt.figure()
    fig2 = plt.figure()
    
    gs1 = gridspec.GridSpec(1, 1)

    axes = [ ]
    axes.append(fig.add_subplot( gs1[0,0], projection='3d'))
    axes.append(fig2.add_subplot( gs1[0,0] ))

    theta = np.linspace(-4 * np.pi, 4 * np.pi, 100)

    Ex = np.abs( J[0])
    Ey = np.abs( J[1])

    phi1 = np.angle( J[0] )
    phi2 =  np.angle( J[1] )

    X = np.linspace(-2, 2, 100)
    Y = Ex * np.cos(theta + phi1)
    Z = Ey * np.cos(theta + phi2)

    lim = np.sqrt(Ex**2+Ey**2)
       
    axes[0].set_xlim(-2, 2)
    
    axes[0].set_ylim(-1, 1)
    axes[0].set_zlim(-1, 1)
     #axes[0].view_init(elev=0, azim=0)
    axes[0].set_aspect('equal')

    axes[0].set_axis_off()

    #axes[0].set_autoscale_on(False)
    #axes[0].legend()    axes[0].set_yticklabels([])
    axes[0].set_xticklabels([])
    axes[0].set_zticklabels([])
   
    #axes[1].ylim([-1,1])
    #axes[1].xlim([-1,1])
    #axes[1].zlim([-1,1])
    axes[1].axis([-lim,lim,-lim,lim])
    axes[1].set_xlabel('Normalized $x$ component of $E$')
    axes[1].set_ylabel('Normalized $y$ component of $E$')
    axes[1].set_aspect('equal')
    axes[0].plot([-4, 4],[0, 0],zs=[0,0], color='green')
    axes[0].plot([-2, -2],[0, 0],zs=[-2,2], color='green')
    axes[0].plot([-2, -2],[-2, 2],zs=[0,0],color='green')
    #axes[1].plot([-1, 1],[-1, 1], color='blue')
    #axes[1].plot([-1, 1],[-0.41421356237309503, 0.41421356237309503], color='blue')
    axes[1].plot([-2, 2],[0, 0], color='green')
    axes[1].plot([0, 0],[-2, 2], color='green')


    axes[0].plot(X, Y, Z, zdir ='Z', color='red')
    axes[1].plot(Y, Z, color='red')
    
    0.41421356237309503
    if show == True:
        plt.show()
    else:
        plt.close()
    if name != '':
        fig.savefig('trayectory_'+name)
        fig2.savefig('ellipse_'+name)        
    return "done"


