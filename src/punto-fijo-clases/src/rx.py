from tool._fixedInt import *

class rx(object):
    def __init__(self, coeficients):
        self.coeficients = coeficients

    def run(self, i_rx, enable):
        if enable:
            self.suma.value = 0
            for i in range(24):
                self.mult[i].value = (self.reg_rx_i[i] * self.coeficients[i]).fValue
            for i in self.mult:
                self.suma.value = (self.suma + i).fValue
        self.reg_rx_i.pop(0)
        self.reg_rx_i.insert(23, i_rx)


    @property
    def rx_out(self):
        return self.suma

    def reset(self):
        self.mult = [DeFixedInt(9, 7) for i in range(24)]
        self.suma = DeFixedInt(9, 7)
        self.reg_rx_i = [DeFixedInt(9, 7) for i in range(24)]