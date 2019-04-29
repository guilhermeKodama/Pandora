from socketIO_client import SocketIO, LoggingNamespace
import json
import thread
import time

SERVER_IP = '172.16.1.59'
#SERVER_IP = '127.0.0.1'
#ECG PORT
ECG_PORT = 8443
#SPO2 PORT
SPO2_PORT = 8444
#AIRFLOW PORT
AIRFLOW_PORT = 8445
#EMG PORT
EMG_PORT = 8446
#TEMPERATURE PORT
TEMPERATURE_PORT = 8447
#BLOOD PRESSURE PORT
BLOOD_PRESSURE_PORT = 8448
#PATIENT POSITION PORT
PATIENT_POSITION_PORT = 8449

count = 0

def ecg(*args):
	global count
	count = count + 1
	print('toECG:', args)

def spo2(*args):
	pass
	# print('toSPO2:', args)

def airflow(*args):
	pass
	# print('toAirFlow:', args)

def emg(*args):
	pass
	# print('toEMG:', args)

def temperature(*args):
	pass
    # print('toTemperature:', args)

def bloodpressure(*args):
	pass
    # print('toBloodPressure:', args)

def patientposition(*args):
	pass
    # print('toPatientPosition:', args)

#ECG connection
def startECGListener():
	socketECG = SocketIO(SERVER_IP ,ECG_PORT, LoggingNamespace)
	socketECG.on('ecg',ecg)
	socketECG.wait()
#SPO2 connection
def startSPO2Listener():
	socketSPO2 = SocketIO(SERVER_IP ,SPO2_PORT, LoggingNamespace)
	socketSPO2.on('spo2',spo2)
	socketSPO2.wait()
def startAirFlowListener():
	socketAirFlow = SocketIO(SERVER_IP ,AIRFLOW_PORT, LoggingNamespace)
	socketAirFlow.on('airflow',airflow)
	socketAirFlow.wait()
def startEMGListener():
	socketEMG = SocketIO(SERVER_IP ,EMG_PORT, LoggingNamespace)
	socketEMG.on('emg',emg)
	socketEMG.wait()
def startTemperatureListener():
	socketEMG = SocketIO(SERVER_IP ,TEMPERATURE_PORT, LoggingNamespace)
	socketEMG.on('temperature',temperature)
	socketEMG.wait()
def startBloodPressureListener():
	socketEMG = SocketIO(SERVER_IP ,BLOOD_PRESSURE_PORT, LoggingNamespace)
	socketEMG.on('bloodpressure',bloodpressure)
	socketEMG.wait()
def startPatientPositionListener():
	socketPP = SocketIO(SERVER_IP ,PATIENT_POSITION_PORT, LoggingNamespace)
	socketPP.on('patientposition',patientposition)
	socketPP.wait()

#listeners para resposta do servidor
thread.start_new_thread( startECGListener,())
thread.start_new_thread( startSPO2Listener,())
thread.start_new_thread( startAirFlowListener,())
thread.start_new_thread( startEMGListener,())
thread.start_new_thread( startTemperatureListener,())
thread.start_new_thread( startBloodPressureListener,())
thread.start_new_thread( startPatientPositionListener,())

while True:
	print 'Mensagens por minuto : %s'%count
	count = 0
	time.sleep(60)
