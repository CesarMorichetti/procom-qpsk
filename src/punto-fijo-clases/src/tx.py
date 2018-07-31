from tool._fixedInt import *
class tx(object):
    def __init__(self, coeficients):
        self.coeficients = coeficients
        self.count_coef = 0
        self.pos = []
        self.reg_tx_i = [0 for i in range(24)]


    def run(self, i_tx, enable):
        if enable:
            self.refresh_pos()
            self.suma.value = 0
            for a in self.pos:
                if self.reg_tx_i[a] == 1:
                    self.suma.value = (self.suma + self.coeficients[a]).fValue
                else:
                    self.suma.value = (self.suma - self.coeficients[a]).fValue
            self.reg_tx_i.pop(0)
            self.reg_tx_i.insert(23, i_tx)

    @property
    def tx_out(self):
        return self.suma

    def reset(self):
        self.reg_tx_i = [0 for i in range(24)]
        self.pos = []
        self.count_coef = 0
        self.suma = DeFixedInt(roundMode='trunc',
                               signedMode='S',
                               intWidth=8,
                               fractWidth=7,
                               saturateMode='saturate')

    def refresh_pos(self):
        self.pos = []
        for j in range(self.count_coef, self.count_coef+21, 4):
            self.pos.append(j)
        if self.count_coef == 3:
            self.count_coef = 0
        else:
            self.count_coef += 1
    
    def print_buffer(self):
        print self.reg_tx_i
