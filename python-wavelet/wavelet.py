import pywt
# import matplotlib.pyplot as plt
import socket
import sys
from threading import Thread
import time
import json
import thread
from random import randint

class ECGClass(object):
    def __init__(self, ecg, time):
        self.ecg = ecg
        self.time = time

def append_ecg(cD2):
    ECGs = []
    time = 0.02
    for i in range(len(cD2)):
        ECGs.append(ECGClass(cD2[i], time))
        time = time + 0.02
    return ECGs
    
def calculated_average(A):
    total = 0
    count = 0
    offset = int(len(A)*0.90)
    average = 1

    for i in range(offset,len(A)-1):
        total = total + A[i].ecg
        count = count + 1

    if count != 0:
        average = total / count
    return average

def new_ecg(A):
    new_array = []
    for i in range(len(A)):
        if A[i].ecg > calculated_average(A):
            new_array.append(A[i])
    # print 'NEW ARRAY PICO LEN : ',len(new_array)
    return new_array

def calculated_bpm(new_array_sorted):
    first_time = None
    for i in range(len(new_array_sorted)):
        time = new_array_sorted[i].time

        if first_time is None:
            first_time = time
        else:
            second_time = time

            delta_time = second_time - first_time
            # print 'DELTA TIME : ',delta_time
            if delta_time > 0.2:
                # print 'EH UM PICO'
                bpm = 60000 / (delta_time * 1000)
                first_time = second_time
                return bpm
    return 0




def calculateBPM(clientsocket):
    while True:
        d = clientsocket.recv(32768).decode()
        data = json.loads(d) 

        coeffs = pywt.wavedec(data['buffer'], 'db1', level=2)
        cA2, cD2, cD1 = coeffs

        ECGs = append_ecg(cD1)
        ECGs = sorted(ECGs, key = lambda x: x.ecg, reverse = False)

        cD2.sort()

        new_array = new_ecg(ECGs)
        new_array_sorted = sorted(new_array, key = lambda x: x.time, reverse = False)

        bpm = calculated_bpm(new_array_sorted)


        print 'enviado : ', bpm

        #envia reposta ao cliente(ipad)
        # sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
        # sock.sendto(str(int(bpm)),('172.16.1.36',6969))
        clientsocket.send(str(int(bpm)));

if __name__ == "__main__":
    print '============ BPM ============'

    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.bind(('127.0.0.1', 8002))
    serversocket.listen(50)
    while True:
        clientsocket, address = serversocket.accept()
        print 'NOVO CLIENTE : ',address
        thread.start_new_thread(calculateBPM,(clientsocket,))

