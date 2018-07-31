import prbs9
import tx
import rx
import commpy
from tool._fixedInt import *
import numpy as np

LEN_SIGNAL = 200
OVERSAMPLING = 4
NBAUDS = 6
ROLL_OFF = 0.5
SAMPLE_RATE = 100000000
SYMBOL_RATE = SAMPLE_RATE/OVERSAMPLING

def main():
    seedI = [0, 1, 0, 1, 0, 1, 0, 1, 1]
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

    prbs_r = prbs9.prbs9(seedI)
    tx_r = tx.tx(fixed_rrcos)
    rx_r = rx.rx(fixed_rrcos)

    prbs_r.reset()
    tx_r.reset()
    rx_r.reset()

    out_prbs = prbs_r.prbs_out
    tx_r.print_buffer()
    tx_r.run(out_prbs, 1)

    enable_prbs = 0
    enable_tx = 1
    enable_rx = 1
    counter = 0

    #cables
    out_prbs = 0
    out_tx = 0
    for clk in range(511):
        if counter == 0:
            enable_prbs = 1
        else:
            enable_prbs = 0
        counter = (counter + 1) % 4

        prbs_r.new_bit(enable_prbs)
        out_prbs = prbs_r.prbs_out

        #tx_r.print_buffer()
        tx_r.run(out_prbs,enable_tx)
        out_tx = tx_r.tx_out

        rx_r.run(out_tx, enable_rx)
        print rx_r.rx_out.fValue



if __name__ == "__main__":
    main()