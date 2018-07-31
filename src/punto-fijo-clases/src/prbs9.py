class prbs9(object):
    def __init__(self, seed):
        self.seed = seed
        self.buffer = [0 for i in range(9)]

    def new_bit(self, enable):
        if enable:
            prbs9 = self.buffer[0]
            prbs5 = self.buffer[4]
            xor = (prbs9 ^ prbs5 ^ 0b1)
            self.buffer.pop(8)
            self.buffer.insert(0, xor)

    @property
    def prbs_out(self):
        return self.buffer[8]
    
    
    def reset(self):
        self.buffer = self.seed