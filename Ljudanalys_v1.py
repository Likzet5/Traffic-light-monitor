# Made by Mattias Johansson for Utvecklingsprojekt Smart pedestrian crossing
# Python 3.6
import pyaudio
import struct
import math
import matplotlib.pyplot as plt
from scipy.signal import butter, sosfiltfilt
import numpy as np
from datetime import datetime
import sys

# puAudio settings
FORMAT = pyaudio.paInt16
SHORT_NORMALIZE = (1.0 / 32768.0)
CHANNELS = 1    # Needs to be set to 1 for bandpass filter to work
RATE = 44100    # Sets rate you wish to record in
INPUT_BLOCK_TIME = 0.1  # change to make the block smaller or bigger. Smaller number works better
INPUT_FRAMES_PER_BLOCK = int(RATE * INPUT_BLOCK_TIME)    # The final size each block will be
# 44100*0.1= 4410
# 4410 värden varje 0.1 sec
# Bör få ett rött tick 1 gång på sec och 2 gånger för grönt tick.


# Filter for normal beep, using butter for filter parameters and filtering
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

# unpack data stream from pyAudio, and puts them in a array so filtering can be done
def unpack(block):
    #amplitude = get_rms(block)
    count = len(block) / 2
    format = "%dh" % (count)  # results in '2048h' as format: 2048 short
    shorts = struct.unpack(format, block)
    block = np.array(shorts)
    #block = block * amplitude
    return block

# Can be used to normalize the data, as you can get some big numbers. But does not work that well
def get_rms(block):
    # RMS amplitude is defined as the square root of the
    # mean over time of the square of the amplitude.
    # so we need to convert this string of bytes into
    # a string of 16-bit samples...

    # we will get one short out for each
    # two chars in the string.
    count = len(block) / 2
    format = "%dh" % count
    shorts = struct.unpack(format, block)

    # iterate over the block.
    sum_squares = 0.0
    for sample in shorts:
        # sample is a signed short in +/- 32768.
        # normalize it to 1.0
        n = sample * SHORT_NORMALIZE
        sum_squares += n * n
    amplitude = math.sqrt(sum_squares / count)
    block = np.array(shorts)
    block = block * amplitude
    return block


pa = pyaudio.PyAudio()                                      # ]
                                                            # |
stream = pa.open(format=FORMAT,                             # |
                 channels=CHANNELS,                         # |---- You always use this in pyaudio...
                 rate=RATE,                                 # |
                 input=True,                                # |
                 frames_per_buffer=INPUT_FRAMES_PER_BLOCK)  # |
errorcount = 0                                              # ]
# For data plot
amplitudArr = []
bandArr = []
# Counters for beeps, button and amount of blocks
counter_beep = 0
counter_knapp = 0
counter_blocks = 0
# Sensitivity
filtConst = 30      # Lower if to many values i beep counter and knapp counter
sens_green_red = 6  # Adjust
# status = 0 red light, status = 1 green light
status = 0
status_mem = 1
# File will be updated if a change of light status is detected
file = open('status_light.txt', 'w')    # Opens a new file with chosen name and makes it writeable
print('spelar in')

# decides the amount of time you wish to record. 200 with input block time of 0.1
# would result in 20s of realtime recording.

# record_time = 200
record_time = int(sys.argv[1])
for i in range(record_time):
    try:                                                     # ]
        block = stream.read(INPUT_FRAMES_PER_BLOCK)          # |
    except IOError as e:                                     # |---- just in case there is an error!
        errorcount += 1                                      # |
        print("(%d) Error recording: %s" % (errorcount, e))  # |
        noisycount = 1                                       # ]

    # Unpacks input stream and apply filter
    block = unpack(block)
    filteredSos = beepFilter(block)
    knappfilt = knappFilter(block)

    counter_blocks = counter_blocks+1

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
