#!/usr/bin/env python
""" Library for communication with an Arduino that powers stepper motors


This implementation is based on Pyhton3

Contains one class called ArduinoStepper() that enables the comunication to
the device along with many usefull commands.

Grupo de Optica Aplicada Universidad EAFIT

Santiago Echeverri Chacón
Carlos Cuartas
Camilo Cano

"""
from optparse import OptionParser
import serial
import os

class ArduinoStepper():
    """ Class for basic communication with an arduino for stepper motors control
    
     1. Detect OS and select the appropiate port preffix.
        Sometimes linux prefix is: ttyUSB and others is ttyACM
        I still don't know why...
     2. Loop over a certain number of port names quering for conection status.

     At this point all the methods are available for sending commands.

     Then select either run() and a certain ammount of steps as argument 
     or goTo() and the desired angle to get to.
     
    """
    def __init__(self, tag, port = ''):
           
        if port == '':
            if os.name == "posix":
                # portbase = '/dev/ttyACM'
                portbase = '/dev/tty.usbmodem'
            else:
                portbase = 'COM'
    
            for i in range(100):
                try:
                    self.ser = serial.Serial("%s%d" %(portbase, i),
                                             baudrate=9600,
                                             bytesize=8,
                                             stopbits=1,
                                             parity=serial.PARITY_NONE,
                                             timeout=1,
                                             xonxoff=1)
                    #print(self.ser)
                    self.assertConnection()
                    break
                except:
                    self.ser = None
                    pass
                #print(self.ser)
        else:
            self.ser = serial.Serial(port,
                                             baudrate=9600,
                                             bytesize=8,
                                             stopbits=1,
                                             parity=serial.PARITY_NONE,
                                             timeout=1,
                                             xonxoff=1)
        if self.ser is None:
            print( "No connection...")
            return None
        else:
            print( "Arduino connected.")
            self.running = False
            self.tag = str(tag)
            
            pass

    def sendCom(self, command):
        self.ser.write(bytes("%s\n" % (command),"UTF-8"))
        print(self.readReply())
    def readReply(self):
        return(self.ser.readline().strip())

    def assertConnection(self):
        """ Checks if the arduino is connected"""
        self.sendCom("H")
        print(self.ser.readline().strip())
        assert self.ser.readline().strip() != "Y", "Not connected"
        
    def setZero(self):    
        """ Resets the current position of the motor, so that wherever
        the motor happens to be right now is considered to be the new 0
        position. Useful for setting a zero position on a stepper after
        an initial hardware positioning move. Has the side effect of
        setting the current motor speed to 0.
        
        """

        
        self.sendCom("Z {0}".format(self.tag))
        
        print("Reseting motor {0} to 0.".format(self.tag))

    def currentStep(self):

        self.sendCom("D {0}".format(self.tag))
        sp = self.ser.readline().strip()
        print("Current step {0}".format(sp))
        print(self.ser.readline().strip())
        
    def run(self,speed):
        """ Puts a motor in motion at the given speed 
        
        Atributes:
            speed: int speed given in steps per second
        """
       
        self.sendCom("C {0} n R {1}".format(speed, self.tag))
        print("C {0} n R {1}".format( speed,self.tag))
        self.running = True
        print("Running clockwise at {0} steps per second".format(speed))
        

    def stop(self):
        """ Stops a running motor """
        
        #assert self.running == True, "The motor wasn't running"
        self.sendCom("S")
        print("Motor stopped")
        self.running = False
    def shutter_on(self):    
        self.sendCom("O")
    def shutter_off(self):
        self.sendCom("N")
    def goTo(self, step):
        """ Goes to a certain integer step with acceleration ramps

        A positive value of the argument step implies counter clockwise
        movement and a negative one counterclockwise. 
        """

        if self.running:
            self.stop()
        self.running = True
        self.sendCom("P {0} n {1}".format(self.tag, step))
        
        print("Going to step {0}.".format(step))
    def setSpeed(self, speed):
        """ Defines speed for goTo 
        
        Atributes:
            speed: int speed given in steps per second
        """
       
        self.sendCom("C {0}".format(speed, self.tag))
        print("C {0}".format( speed,self.tag))
        self.running = True
        print("Speed is {0} steps per second".format(speed))
        
    def getSpeed(self):
        """ Returns current value of the display
        This value may be subject to averaging and attenuation.
        """
        assert self.running == True, "Only available when in motion"
        self.sendCom("V")
        self.sendCom(self.tag)
        
        value = self.readReply();
        try:
            fvalue = float(value)
        except:
            fvalue = None
        return(fvalue)

         
if __name__ == "__main__":
    """ If this file is executed from a terminal the following happens:
    
    The user has to input an option that describes what is to be done, 
    at this moment you can choose between:

    for windows: 
    
    * Running a certain stepper at a given speed:
         python.exe ArduinoStepper.py -r 1 -- -100
      Tells  the motor 1 to run at 100 steps per second counter clockwise
    * Running a certain stepper to a given step:
         python.exe ArduinoStepper.py -t 2 -- -400
      Tells  the motor 2 to go to step -400. 
    * Stopping a stepper:
         python.exe ArduinoStepper.py -s 1

    For mac and linux python.exe is replaced by python.

    Remember to have a working version of python3.3 with the 
    pyserial module.
    
            
    """
    parser = OptionParser(usage="Usage: python3.exe ArduinoStepper.py -s 1 100  ")
    parser.add_option("-k", "--getSpeed", help = "Returns current stepper speed", type = "int", dest = "samples")
    parser.add_option("-r", "--run", help = "Puts stepper into motion", type = "int")
    parser.add_option("-t", "--step", help = "Gets the stepper to a desired step", type = "int")
    parser.add_option("-s", "--stop", help = "Stops the motor", type = "int")
    parser.add_option("-o", "--shutterOn", help = "Toggles shutter on", type = "int")
    parser.add_option("-n", "--shutterOff", help = "Toggles shutter off", type = "int")
    parser.add_option("-z", "--setZero", help = "Resets current motor counter to zero", type = "int")
    parser.add_option("-d", "--currentStep", help = "Ask the motor current step", type = "int")
    parser.add_option("-v", "--setSpeed", help = "Defines speed for function goTo", type = "int")
    options, args = parser.parse_args()

    comPort = "COM10"
    
    if options.run != None:
        
        stepper = ArduinoStepper(options.run, port = comPort)
        #stepper = ArduinoStepper(options.run, port = "/dev/tty.usbmodem1411")
        stepper.run(args[0])
        stepper.ser.close()

    if options.setSpeed != None:
        
        stepper = ArduinoStepper(options.setSpeed, port = comPort)
        #stepper = ArduinoStepper(options.run, port = "/dev/tty.usbmodem1411")
        stepper.setSpeed(args[0])
        stepper.ser.close()
        
    if options.setZero != None:
        stepper = ArduinoStepper(options.setZero, port = comPort)
        #stepper = ArduinoStepper(options.run, port = "/dev/tty.usbmodem1411")
        stepper.setZero()
        stepper.ser.close()

    if options.currentStep != None:
        stepper = ArduinoStepper(options.currentStep, port = comPort)
        #stepper = ArduinoStepper(options.run, port = "/dev/tty.usbmodem1411")
        stepper.currentStep()
        stepper.ser.close()
        
    if options.stop != None:
        stepper = ArduinoStepper(options.run, port = comPort)
        #stepper = ArduinoStepper(options.run, port = "/dev/tty.usbmodem1411")
        stepper.stop()
        stepper.ser.close()
        
    if options.shutterOn != None:
        stepper = ArduinoStepper(options.shutterOn, port = comPort)
        #stepper = ArduinoStepper(options.run, port = "/dev/tty.usbmodem1411")
        stepper.shutter_on()
        stepper.ser.close()
        
    if options.shutterOff != None:
        stepper = ArduinoStepper(options.shutterOff, port = comPort)
        #stepper = ArduinoStepper(options.run, port = "/dev/tty.usbmodem1411")
        stepper.shutter_off()
        stepper.ser.close()

    if options.step != None:
        stepper = ArduinoStepper(options.step, port = comPort)
        #stepper = ArduinoStepper(options.step, port = "/dev/tty.usbmodem1411")
        stepper.goTo(args[0])
        confirmation = stepper.readReply()
        while confirmation != b'F':
            confirmation = stepper.readReply()
        
        print(confirmation)
        stepper.ser.close()
    
    

