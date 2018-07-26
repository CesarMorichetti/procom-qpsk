import numpy as np
import matplotlib.pyplot as plt
import random
import DSPtools
import commpy

LEN_SIGNAL = 200
OVERSAMPLING = 4
NBAUDS = 6
ROLL_OFF = 0.5
SAMPLE_RATE = 100000000
SYMBOL_RATE = SAMPLE_RATE/OVERSAMPLING


def main():

    # Senal generada
    re = [(random.randint(0, 1)*2) - 1 for _ in range(LEN_SIGNAL)]
    img = [(random.randint(0, 1)*2) - 1 for _ in range(LEN_SIGNAL)]

    # Obersampling
    over_re = [re[i / OVERSAMPLING] if (i % OVERSAMPLING == 0) else 0
                for i in range(LEN_SIGNAL*4)]
    over_img = [img[i / OVERSAMPLING] if (i % OVERSAMPLING == 0) else 0
                for i in range(LEN_SIGNAL*4)]
    # Filtro SRRC
    rrcos = commpy.rrcosfilter(OVERSAMPLING*NBAUDS,
                               ROLL_OFF,
                               1./SYMBOL_RATE,
                               SAMPLE_RATE)[1]
    rrcos = rrcos/np.sqrt(OVERSAMPLING)

    # Respuesta en frecunecia
    H, A, F = DSPtools.resp_freq(rrcos, 1. / SYMBOL_RATE, 256)

    # Senal transmitida
    tx_re = np.convolve(over_re, rrcos, "same")
    tx_img = np.convolve(over_img, rrcos, "same")

    # Plot
    plt.figure(0)
    plt.title("square root raised cosine")
    plt.plot(rrcos)
    plt.figure(1)
    plt.semilogx(F, 20 * np.log(H))
    plt.figure(2)
    plt.title("senal transmitida real")
    plt.plot(tx_re[:100])

    # Senal recibida
    rx_re = np.convolve(tx_re, rrcos, "same")
    rx_img = np.convolve(tx_img, rrcos, "same")
    print rx_re
    # Downsampling
    offset = 2
    down_re = [rx_re[i] for i in range(offset, len(rx_re), 4)]
    down_img = [rx_img[i] for i in range(offset, len(rx_img), 4)]

    # Detection
    detection_re = [-1 if i < 0 else 1 for i in down_re]
    detection_img = [-1 if i < 0 else 1 for i in down_img]

    # Plot
    plt.figure(3)
    plt.title("senal recivida real")
    plt.plot(rx_re[:100])
    plt.figure(4)
    plt.title('constelacion')
    plt.plot(down_re,down_img, '.')
    DSPtools.eyediagram(rx_re, 4, 2, OVERSAMPLING)
    plt.show()


if __name__ == "__main__":
    main()
