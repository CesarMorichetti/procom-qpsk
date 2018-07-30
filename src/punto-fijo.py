import numpy as np
from tool._fixedInt import *
import random
#import DSPtools
import matplotlib.pyplot as plt
import commpy

LEN_SIGNAL = 200
OVERSAMPLING = 4
NBAUDS = 6
ROLL_OFF = 0.5
SAMPLE_RATE = 100000000
SYMBOL_RATE = SAMPLE_RATE/OVERSAMPLING


seedI = [0, 1, 0, 1, 0, 1, 0, 1, 1]
seedQ = [0, 1, 1, 1, 1, 1, 1, 1, 1]
def ff(fix):
    list = []
    for ptr in range(len(fix)):
        list.append(fix[ptr].fValue)
    return list

def list_to_dec(list):
    list = ''.join(str(e) for e in list)
    return list


def conv_tx(coef, x, y):
    #for ptr in range(len(y)):
    #    print y[ptr].fValue
    suma = DeFixedInt(roundMode='trunc',
                         signedMode='S',
                         intWidth=8,
                         fractWidth=7,
                         saturateMode='saturate')
    suma.value = 0
    for a in coef:
        if x[a] == 1:
            suma.value = (suma + y[a]).fValue
        else:
            suma.value = (suma - y[a]).fValue
    return suma

def convolve(x, y):
    mult = [DeFixedInt(9, 7) for i in range(24)]
    suma_total = DeFixedInt(9, 7)
    for i in range(24):
        mult[i].value = (x[i]*y[i]).fValue
    for i in mult:
        suma_total.value = (suma_total + i).fValue
    return suma_total

def prbs(seed):
    prbs9 = seed[0]
    prbs5 = seed[4]
    xor = (prbs9 ^ prbs5 ^ 0b1)
    seed.pop(8)
    seed.insert(0, xor)
    return seed
def prbs_test_ber(seed):
    aux = seed[8]
    seed.insert(0, aux)
    seed.pop()
    return seed
def main():
    ## PRBS
    seedI = [0, 1, 0, 1, 0, 1, 0, 1, 1]
    seedQ = [0, 1, 1, 1, 1, 1, 1, 1, 1]

    new_prbsI = seedI
    new_prbsQ = seedQ

    bit_re_o = 0
    bit_im_o = 0

    log_prbs_re = []
    log_prbs_im = []

    ## Transmisor
    count_coef = 0
    conv_tx_re = DeFixedInt(roundMode='round',
                         signedMode='S',
                         intWidth=8,
                         fractWidth=7,
                         saturateMode='wrap')
    conv_tx_im = DeFixedInt(roundMode='round',
                         signedMode='S',
                         intWidth=8,
                         fractWidth=7,
                         saturateMode='wrap')

    # Reg input
    reg_tx_re_i = [0 for i in range(24)]
    reg_tx_im_i = [0 for i in range(24)]

    # Output
    tx_re_o = DeFixedInt(9, 7)
    tx_im_o = DeFixedInt(9, 7)

    log_tx_re = []
    log_tx_im = []


    ## Receptor
    conv_rx_re = DeFixedInt(roundMode='round',
                         signedMode='S',
                         intWidth=8,
                         fractWidth=7,
                         saturateMode='wrap')
    conv_rx_im = DeFixedInt(roundMode='round',
                         signedMode='S',
                         intWidth=8,
                         fractWidth=7,
                         saturateMode='wrap')

    # Reg input
    reg_rx_re_i = [DeFixedInt(9, 7) for i in range(24)]
    reg_rx_im_i = [DeFixedInt(9, 7) for i in range(24)]

    # Output
    rx_re_o = DeFixedInt(9, 7)
    rx_im_o = DeFixedInt(9, 7)
    log_rx_re = []
    log_rx_im = []

    ## DOWN

    down_re = 0
    down_im = 0
    down_re_o = 0
    down_im_o = 0
    log_down_re = []
    log_down_im = []

    ## BER
    ber_mult = 0
    ber_re_i = 0
    ber_im_i = 0

    ber_re_tx = [0 for i in range(511*2)]
    ber_im_tx = [0 for i in range(511*2)]
    error_re = 0
    error_im = 0
    led = 0
    # Filtro SRRC
    rrcos = commpy.rrcosfilter(OVERSAMPLING * NBAUDS,
                               ROLL_OFF,
                               1. / SYMBOL_RATE,
                               SAMPLE_RATE)[1]
    rrcos = rrcos / np.sqrt(OVERSAMPLING)
    fixed_rrcos = arrayFixedInt(8,
                                7,
                                rrcos)
    #for ptr in range(len(rrcos)):
    #    print ptr, rrcos[ptr], '\t', fixed_rrcos[ptr].fValue


    for clk in range(511):

        ########################################################################
        #PRBS
        # Este modulo se ejecuta cada 4 ciclos de reloj, la salida son dos bits,
        # uno para y el otro para Q
        if clk % 4 == 0:
            new_prbsI = prbs(new_prbsI)
            new_prbsQ = prbs(new_prbsQ)
            print new_prbsI[8]

        ########################################################################

        ########################################################################
        #CONVOLUCION TX
        reg_tx_re_i.pop(0)
        reg_tx_re_i.insert(23, bit_re_o)
        reg_tx_im_i.pop(0)
        reg_tx_im_i.insert(23, bit_im_o)
        #print reg_tx_re_i
        coef = []

        for j in range(count_coef, count_coef+21, 4):
            coef.append(j)
        #print coef
        if count_coef == 3:
            count_coef = 0
        else:
            count_coef += 1
        conv_tx_re = conv_tx(coef, reg_tx_re_i, fixed_rrcos)
        conv_tx_im = conv_tx(coef, reg_tx_im_i, fixed_rrcos)
        #print conv_tx_re.fValue
        ########################################################################

        ########################################################################
        # MODULO RECEPTOR
        # input 1 bit de la senal transmitida que lo coloca en un shift register
        # para convolucionar con rrcos
        reg_rx_re_i.pop(0)
        reg_rx_re_i.insert(23, tx_re_o)
        reg_rx_im_i.pop(0)
        reg_rx_im_i.insert(23, tx_im_o)
        conv_rx_re = convolve(reg_rx_re_i, fixed_rrcos)
        conv_rx_im = convolve(reg_rx_im_i, fixed_rrcos)

        ########################################################################

        ########################################################################
        # DOWN
        # offset de 1 a 4
        offset = 2
        if (clk+offset) % 4 == 0:
            if (conv_rx_re.fValue) > 0:
                down_re = 1
            else:
                down_re = 0
            if (conv_rx_im.fValue) > 0:
                down_im = 1
            else:
                down_im = 0

        ########################################################################

        ########################################################################
        # BER
        if clk % 4 == 0:

            ber_re_tx.insert(0, bit_re_o)
            ber_re_tx.pop()
            ber_im_tx.insert(0, bit_im_o)
            ber_im_tx.pop()

            ber_re_i = down_re_o
            ber_im_i = down_im_o

            if ber_re_tx[ber_mult] ^ ber_re_i != 0:
                error_re += 1
            if ber_im_tx[ber_mult] ^ ber_im_i != 0:
                error_re += 1
            if (clk/4) % 511 == 0 and clk != 0:
                #print log_prbs_re
                #print log_down_re
                #print ber_mult
                #print error_re
                if error_re == 0:
                    led = 1
                else:
                    ber_mult += 1
                    error_re = 0
                    led = 0

        ########################################################################
        bit_re_o = new_prbsI[8]
        bit_im_o = new_prbsQ[8]
        log_prbs_re.append(new_prbsI[8])
        log_prbs_im.append(new_prbsQ[8])

        tx_re_o = conv_tx_re
        tx_im_o = conv_tx_im
        log_tx_re.append(conv_tx_re)
        log_tx_im.append(conv_tx_im)

        rx_re_o = conv_rx_re
        rx_im_o = conv_rx_im
        log_rx_re.append(conv_rx_re)
        log_rx_im.append(conv_rx_im)

        down_re_o = down_re
        down_im_o = down_im
        log_down_re.append(down_re)
        log_down_im.append(down_im)

    float_tx_re = ff(log_tx_re)
    float_tx_im = ff(log_tx_im)
    float_rx_re = ff(log_rx_re)
    float_rx_im = ff(log_rx_im)

    plt.figure(0)
    plt.title("square root raised cosine")
    plt.plot(rrcos)
    plt.figure(1)
    plt.title("senal transmitida real")
    plt.plot(float_tx_re[:200])
    plt.figure(2)
    plt.title("senal transmitida imaginaria")
    plt.plot(float_tx_im[:200])
    plt.figure(3)
    plt.title("senal recibida real")
    plt.plot(float_rx_re[:200])
    plt.figure(4)
    plt.title("senal recibida imaginaria")
    plt.plot(float_rx_im[:200])
    plt.figure(5)
    plt.title('constelacion')
    plt.plot(log_down_re, log_down_im, '.')
    eyediagram(float_rx_re[14:], 4, 1, OVERSAMPLING)
    plt.show()

    """
    # Para ver las graficas de fijo y float
    for ptr in range(len(rrcos)):
        print rrcos[ptr], '\t', fixed_rrcos[ptr].fValue
    print max(rrcos)
    float_rrcos = ff(fixed_rrcos)
    plt.figure(0)
    plt.title("float square root raised cosine")
    plt.plot(rrcos)
    plt.figure(1)
    plt.title("fixed square root raised cosine")
    plt.plot(float_rrcos)
    plt.show()
    """


if __name__ == "__main__":
    main()