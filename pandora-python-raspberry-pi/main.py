import socket
import json
import random
import csv
import sys
from threading import Thread
import time

# UDP_IP = "127.0.0.1"
UDP_IP = "172.16.1.59"

class ECG(Thread):
	def __init__(self,rows,column):
		Thread.__init__(self)
		#porta para conexao do streamming do ECG
		self.UDP_PORT = 41181
		# self.UDP_PORT = 8888
		self.rows = rows
		self.column = column
		self.daemon = True
		self.start()

	def run(self):
		i = 0
		while True:
			ecg = self.rows[i][self.column]
			bpm = random.randint(80,100)
			sock.sendto(str(ecg),(UDP_IP,self.UDP_PORT))
			print 'SEND ECG'
			i = i+1
			time.sleep(0.01)

class SPO2(Thread):
	def __init__(self,rows,column):
		Thread.__init__(self)
		#porta para conexao do streamming do SPO2
		self.UDP_PORT = 41182
		self.rows = rows
		self.column = column
		self.daemon = True
		self.start()

	def run(self):
		i = 0
		while True:
			sock.sendto(str(self.rows[i][self.column]),(UDP_IP,self.UDP_PORT))
			print 'SEND SPO2'
			i = i+1
			time.sleep(0.01)

class AirFlow(Thread):
	def __init__(self,rows,column):
		Thread.__init__(self)
		#porta para conexao do streamming do AIRFLOW
		self.UDP_PORT = 41183
		self.rows = rows
		self.column = column
		self.daemon = True
		self.start()

	def run(self):
		i = 0
		while True:
			sock.sendto(str(self.rows[i][self.column]),(UDP_IP,self.UDP_PORT))
			print 'SEND AIRFLOW'
			i = i+1
			time.sleep(0.01)

class EMG(Thread):
	def __init__(self,rows,column):
		Thread.__init__(self)
		#porta para conexao do streamming do AIRFLOW
		self.UDP_PORT = 41184
		self.rows = rows
		self.column = column
		self.daemon = True
		self.start()

	def run(self):
		i = 0
		while True:
			sock.sendto(str(self.rows[i][self.column]),(UDP_IP,self.UDP_PORT))
			print 'SEND EMG'
			i = i+1
			time.sleep(0.01)

class Temperature(Thread):
	def __init__(self):
		Thread.__init__(self)
		#porta para conexao do streamming do AIRFLOW
		self.UDP_PORT = 41185
		self.daemon = True
		self.start()

	def run(self):
		while True:
			sock.sendto(str(round(random.uniform(36.5,37.5),2)),(UDP_IP,self.UDP_PORT))
			print 'SEND TEMPERATURE'
			time.sleep(5)

class BloodPressure(Thread):
	def __init__(self):
		Thread.__init__(self)
		#porta para conexao do streamming do AIRFLOW
		self.UDP_PORT = 41186
		self.daemon = True
		self.start()

	def run(self):
		while True:
			systolic = round(random.uniform(100,120),2)
			diastolic = round(random.uniform(60,80),2)
			sock.sendto(str(120)+','+str(80),(UDP_IP,self.UDP_PORT))
			print 'SEND TEMPERATURE'
			time.sleep(5)

class PatientPosition(Thread):
	def __init__(self):
		Thread.__init__(self)
		#porta para conexao do streamming do AIRFLOW
		self.UDP_PORT = 41187
		self.daemon = True
		self.start()

	def run(self):
		while True:
			position = random.randint(1,5)
			sock.sendto(str(position),(UDP_IP,self.UDP_PORT))
			print 'SEND PATIENT POSITION'
			time.sleep(5)



#server connection
sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
#open csv APNEA file
f = open('apnea.csv','rb')
reader = csv.reader(f)
rows_apnea = list(reader)
size_apnea = len(rows_apnea)
#open csv EMG file
f = open('emg.csv','rb')
reader = csv.reader(f)
rows_emg = list(reader)
size_emg = len(rows_emg)
#create threads to send sensors outputs
threadECG = ECG(rows_apnea,1)
threadSPO2 = SPO2(rows_apnea,5)
threadAirFlow = AirFlow(rows_apnea,3)
threadEMG = EMG(rows_emg,1)
threadTemp = Temperature()
threadBloodPressure = BloodPressure()
threadPatientPosition = PatientPosition()

while True:
	time.sleep(100000)