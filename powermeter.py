#!/usr/bin/env python
""" Library for data accisition and control of Newport's Optical Power Meter Model 1830-c

This code is a modification of a git snippet found in the folder "drivers"  on an open git repository by @imrehg of 
hackerspace Taiwan.

https://github.com/imrehg/labhardware.git

This modification supports Pyhton3

Contains one class called PowerMeter() which enables the comunication to the device along with many usefull commands.
"""
from optparse import OptionParser

import serial
import os

class PowerMeter():
    """ Newport Optical Power Meter 1830-C """

    def __init__(self):
        if os.name == "posix":
            portbase = '/dev/ttyUSB'
        else:
            portbase = 'COM'

        for i in range(10):
            try:
                self.ser = serial.Serial("%s%d" %(portbase, i),
                                         baudrate=9600,
                                         bytesize=8,
                                         stopbits=1,
                                         parity=serial.PARITY_NONE,
                                         timeout=1,
                                         xonxoff=1)
                #print(self.ser)
                self.getReading()
                break
            except:
                self.ser = None
                pass
            #print(self.ser)
        if self.ser is None:
            print( "No connection...")
            return None
        else:
            #print( "Powermeter connected")
            pass

    def sendCom(self, command):
        self.ser.write(bytes("%s\n" % (command),"UTF-8"))

    def readReply(self):
        return(self.ser.readline().strip())

    def getReading(self):
        """ Returns current value of the display
        This value may be subject to averaging and attenuation.
        """
        self.sendCom("D?")
        value = self.readReply();
        try:
            fvalue = float(value)
        except:
            fvalue = None
        return(fvalue)

    def get_custom_reading(self, samples):
        """ Returns an averaged result of a given number of measurements.        
        """
        assert isinstance(samples,int) 
        assert samples >=1 
        self.set_Averaging(3)
        ne_measures = 0 # not empty measures
        sum_of_values = 0
        for i in range(samples):
            current_value =self.getReading() 
            if isinstance(current_value, float):
                sum_of_values += current_value
                ne_measures += 1
        return sum_of_values/ne_measures        

    def Averaging_state(self):
        """Averaging query
        """
        self.sendCom("F?")
        value = self.readReply()
        return int(value)
        
    def set_Averaging(self, mode):
        """ Sets the mode of averaging.
        mode = 1: The readings are averaged in slow mode ie average of the last 16 meassurements.
        mode = 2: The readings are averaged in medium mode ie average of the last 4 meassurements.        
        mode = 3: The readings are not being averaged.
        """
        assert isinstance(mode,int) & mode >=1 & mode <=3
        self.sendCom("F"+str(mode))
        
    def Attenuator_state(self):
        """Attenuator query
        Returns the state of the attenuator. 
        If 0 then the power meter uses the calibration module's responsivity values
        associated with the photodetector-alone.
        If 1 then the power meter uses the calibration module's responsivity values
        assoiated with the photodetector attenuator combination.        
        """
        self.sendCom("A?")
        value = self.readReply()
        return value
        
    def toggleAtenuator(self):
        A = int(self.Attenuator_state())
        A=0 if A ==1  else 1
        self.sendCom("A"+str(A))
        return self.Attenuator_state()
        
    def Beeper_state(self):
        """Beeper query
        Returns the state of the Beeper. 
        If 0 beeper is off
        If 1 beeper is on 
        """
        self.sendCom("B?")
        value = self.readReply()
        return value
        
    def toggleBeeper(self):
        B = int(self.Beeper_state())
        B=0 if B ==1  else 1
        self.sendCom("B"+str(B))
        return self.Beeper_state()
        
if __name__ == "__main__":
    Newport = PowerMeter()
    parser = OptionParser(usage="Usage: python %prog [FILE]...")
    parser.add_option("-g", "--get", help = "Returns reading from Instrument", type = "int", dest = "samples")

    options, args = parser.parse_args()
    if options.samples != None:
        print(Newport.get_custom_reading(options.samples))
    else:
        print(Newport.getReading())
    
