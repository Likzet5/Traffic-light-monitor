import soundfile as sof
import matplotlib.pyplot as plt
from scipy.signal import butter, sosfiltfilt
import numpy as np
from datetime import datetime


# done with sosfiltfilt
def beepFilter(block):
    lower = (3990 / (44100 / 2))
    higher = (4010 / (44100 / 2))
    n = 6  # order
    sos = butter(n, [lower, higher], 'bandpass', analog=False, output='sos')
    filteredSos = sosfiltfilt(sos, block)
    return filteredSos


def knappFilter(block):
    lower = (4790 / (44100 / 2))
    higher = (4810 / (44100 / 2))
    n = 6  # order
    sos = butter(n, [lower, higher], 'bandpass', analog=False, output='sos')
    filteredSos = sosfiltfilt(sos, block)
    return filteredSos


[originalSignal, sampleRate] = sof.read('test3.wav')

print(len(originalSignal))

knappfiltt = knappFilter(originalSignal)
beepfiltt = beepFilter(originalSignal)

amplitudArr = []
bandArr = []
# Counters for beeps, button and amount of blocks
counter_beep = 0
counter_knapp = 0
counter_blocks = 0
# Sensitivity
filtConst = 0.025  # Lower if to many values i beep counter and knapp counter
sens_green_red = 6  # Adjust
# status = 0 red light, status = 1 green light
status = 0
status_mem = 1
# File will be updated if a change of light status is detected
file = open('status_light.txt', 'w')  # Opens a new file with chosen name and makes it writeable
print('spelar in')

# decides the amount of time you wish to record. 200 with input block time of 0.1
# would result in 20s of realtime recording.
# record_time = 200
for i in range(int(round(len(originalSignal) / 4410))):
    knappfilt = knappfiltt[4410 * i:4410 + 4410 * i]
    filteredSos = beepfiltt[4410 * i:4410 + 4410 * i]

    counter_blocks = counter_blocks + 1

    # To find the desired sounds after filtering depending on amplitude.
    if np.sum(filteredSos > filtConst):
        counter_beep = counter_beep + 1
        if counter_blocks < sens_green_red:
            print('Grönt GÅGÅ')
            status = 1
        else:
            print('Rött')
            status = 0
        counter_blocks = 0
        prevstate=status
        print('beep beep ', counter_beep)

    if np.sum(knappfilt > filtConst):
        counter_knapp = counter_knapp + 1
        print('beep knapp ', counter_knapp)
        now = datetime.now()
        file.write(' Button pressed ')
        file.write(' timestamp = ')
        file.write(str(now))
        file.write(' ')

    # Print to file status_light only when the light changes.
    # Timestamp eller uppdatera hela tiden? Synca med GPS?
    # Med timestamp direkt, så kan man få tiden den varit röd eller grön och
    # när det sker
    # Men att updatera med nytt värde hela tiden till filen så måste
    # man i efterhand bestämma när det blev rött. Pga man vet att det är
    # ett block per 0.1s just nu. Och man vet när man börjar logga data.
    if status != status_mem:
        now = datetime.now()
        timestamp = datetime.timestamp(now)
        file.write(str(status))
        file.write(' ')
        file.write(' timestamp = ')
        file.write(str(now))
        file.write(' ')
        status_mem = status

    amplitudArr.append(knappfilt)
    bandArr.append(filteredSos)

file.close()
# delete
print('Klar')
plt.plot(amplitudArr, 'b', linewidth=.5)
plt.plot(bandArr, 'g', linewidth=.5)
plt.show()
