#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
20/04/2016

Esse programa recebe como entrada sinais de ECG (array de números decimais) com duração de 3 segundos,
utiliza um modelo baseado em técnicas de aprendizado de máquina para fazer previsões se aquele segmento
de onda é ou não uma arritmia e que tipo de arritmia é.

Entrada : [0.5,0.2,0.4....]
Saída : {prediction:'(N'}

Possíveis classes que podem ser retornadas pelo programa :

(T        Trigeminismo Ventricular | Ventricular Trigeminy
(N        Coração Normal | Normal Heart
(PREX     Pré-excitação | Pre-excitation (WPW)
(VT       Taquicardia Ventricular | Ventricular tachycardia
(AF       Fibrilação Atrial | Atrial fibrillation
(VF       Fibrilação Ventricular | Ventricular Fibrilation
(B        Coração bloqueado | Bundle branch block beat 

Fonte : https://www.physionet.org/physiobank/annotations.shtml#aux


Como usar : 

@input : {"ECG":[],
		  "S":{ 
		  		"BPM":[],
		  		"AIRFLOW":[],
		  		"EMG":[],
		  		"SPO2":[],
		  		"SYSTOLE":[],
		  		"DIASTOLE":[],
		  		"TEMPERATURE":[],
		  		"PACIENT_POSITION":[]
		  	}
		  "device_id":1
		  }

@output : Nenhum, o algoritmo vai persistir diretamente tudo na base de dados para não fazer o nodejs
esperar por nada, isso permite que o nodejs não fique travado.
Apenas envie e feche a conexão.


'''

import numpy as np
import matplotlib.pyplot
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn import svm
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.cross_validation import train_test_split
from sklearn.metrics import f1_score
from sklearn import cross_validation
from sklearn import preprocessing
import socket
import json
import pprint
import csv
from WaveSegmentation import WaveSegmentation
import psycopg2
import sys
import thread

def build_model():
	#carrega base
	df = pd.read_csv('trainingset_test.csv')

	#delete random instances of normal waves to balance the dataset
	def balance_class(df,target,num_instances):
	    df_target = df[df['classification'] == target]
	    df =  df[df['classification'] != target]
	    df = df.append(df_target.ix[1:num_instances])
	    return df

	df = balance_class(df,'(AFIB',10000)
	df = balance_class(df,'(SBR',10000)
	df = balance_class(df,'(AB',10000)
	df = balance_class(df,'(B',10000)
	df = balance_class(df,'(N',10000)

	#tirando classes que eu nao sei o que sao
	df =  df[df['classification'] != '(WPWAF']
	df =  df[df['classification'] != '(SVTA']
	df =  df[df['classification'] != '(SAB']
	df =  df[df['classification'] != '(PREX']
	df =  df[df['classification'] != '(T']

	#transform to numpy array
	train, test = train_test_split(df, test_size = 0.33,random_state=2)
	train_values = train.values
	test_values = test.values

	#KNN
	model_knn = KNeighborsClassifier(n_neighbors=10)
	model_knn = model_knn.fit(train_values[:,0:5], train_values[:,12])
	return model_knn

def get_chunks(sample_path='./cudb/cu01.csv'):

	signals = []
	chunk = []
	seconds = 0.0

	f = open(sample_path,'r')
	reader = csv.reader(f)
	rows = list(reader)

	offset = float(rows[1][0]) - float(rows[0][0])

	for row in rows:
		seconds += offset
		if seconds <= 3:
			try:
				chunk.append(float(row[1]))
			except:
				pass
		else:
			seconds = 0.0
			signals.append(chunk)
			chunk = []

	return signals

def predict(signal):
	#processa o sinal de entrada em um array de features
	features = segmentation.extract_features(signal,len(signal)/3)
	if features == None:
		print 'Erro na segmentação'
		return None
	else:
		features = np.array(features)
		#utiliza o modelo para fazer uma previsão baseada no array de features do sinal de entrada
		predictions = model.predict(features[:,0:5])
		prediction_prob = model.predict_proba(features[:,0:5])

		#tira a média das probabilidades das classes para definir que tipo de arritimia
		#foi soberana nesse segmento ,temos que investigar por que ele atribui a várias
		#classes diferentes a um mesmo segmento de 3 segundos
		probabilities = {}
		for i in range(len(predictions)):
			if predictions[i] not in probabilities:
				probabilities[predictions[i]] = {}
				probabilities[predictions[i]]['probability'] = 0.0
				probabilities[predictions[i]]['total'] = 0
			max_prob = 0
			for j in range(len(prediction_prob[i])):
				if prediction_prob[i][j] > max_prob:
					max_prob = prediction_prob[i][j]
			probabilities[predictions[i]]['probability'] += max_prob
			probabilities[predictions[i]]['total'] += 1
		
		max_prob = 0
		max_class = ''
		for key, value in probabilities.iteritems():
			value['probability'] = value['probability'] / value['total']
			if value['probability'] > max_prob:
				max_prob = value['probability']
				max_class = key

		return {'class':max_class,'probability':max_prob}

'''
 Inicializa o gerenciamento de uma timeline no dicionário 'tt'
'''
def initialize_timeline(device_id):
	TT[device_id] = {'ECG':[],
					 'BPM':[],
					 'AIRFLOW':[],
					 'EMG':[],
					 'SPO2':[],
					 'SYSTOLE':[],
					 'DIASTOLE':[],
					 'TEMPERATURE':[],
					 'PACIENT_POSITION':[],
					 'row_id':None,
					 'prediction':{'class':None,'probability':0.0},
					 'num_concat':0,
					 'time_ini':0,
					 'time_end':0
					 }

'''
 Envia notificação para os médicos responsáveis
'''
def send_alert():
	print '++Alert sended'

'''
 Atualiza um evento na timeline de um dispositivo no banco de dados

 @param id: ID do evento na timeline
 @param event: Informações para atualizar

'''
def update(id,event):
	con = psycopg2.connect(database='pandora', user='guilherme',password='multi@media2')
	con.autocommit = True
	cur = con.cursor()

	cur.execute('UPDATE "public"."timeline" SET "prediction"=%s,"probability"=%s,"ecg"=%s,"bpm"=%s,"airflow"=%s,"emg"=%s,"spo2"=%s,"systole"=%s,"diastole"=%s,"temperature"=%s,"pacient_position"=%s  WHERE id = %s',(event['prediction']['class'],event['prediction']['probability'],event['ECG'],event['BPM'],event['AIRFLOW'],event['EMG'],event['SPO2'],event['SYSTOLE'],event['DIASTOLE'],event['TEMPERATURE'],event['PACIENT_POSITION'],id))

	con.close()

	json.dump({'prediction':event['prediction'],
	'num_concat':event['num_concat'],
	'time_ini':event['time_ini'],
	'time_end':event['time_end'],
	}, open('./timeline/event_'+str(id),'w'))
	

'''
 Salva um novo evento na timeline no banco de dados

 @param event: Evento a ser salvo
 @param visible: Indica se esse evento deve ficar visível imediatamente ou só quando aparecer outro
 				 evento similar

 @return row_id: Retorna o ID do evento que foi salvo
'''
def save(event,device_id):
	con = psycopg2.connect(database='pandora', user='guilherme',password='multi@media2')
	con.autocommit = True
	cur = con.cursor()

	cur.execute('INSERT INTO "public"."timeline"("device_id","prediction","probability","ecg","bpm","airflow","emg","spo2","systole","diastole","temperature","pacient_position") VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id',(device_id,event['prediction']['class'],event['prediction']['probability'],event['ECG'],event['BPM'],event['AIRFLOW'],event['EMG'],event['SPO2'],event['SYSTOLE'],event['DIASTOLE'],event['TEMPERATURE'],event['PACIENT_POSITION']))
	event_id = cur.fetchone()[0]

	con.close()

	json.dump({'prediction':event['prediction'],
		'num_concat':event['num_concat'],
		'time_ini':event['time_ini'],
		'time_end':event['time_end'],
		},
		open('./timeline/event_'+str(event_id),'w'))

	return event_id

'''
 Concatena os eventos detectados na timeline
'''
def timeline_maintaince(ECG=None,S=None,device_id=None,time=10.0):
	global TT

	#verifica se é necessário inicializar a timeline desse dispositivo
	if device_id not in TT:
		initialize_timeline(device_id = device_id)

	#realiza a previsão das arritmias baseado em um streamming de 3 segundos
	prediction = predict(ECG)

	if prediction == None:
		return

	if prediction['class'] == TT[device_id]['prediction']['class']:
		#se a classe que eu previ for igual a ultima classe prevista
		#eu vou concatenar as informações e atualizar a timeline

		TT[device_id]['ECG'] += ECG
		TT[device_id]['BPM'] += S['BPM']
		TT[device_id]['AIRFLOW'] += S['AIRFLOW']
		TT[device_id]['EMG'] += S['EMG']
		TT[device_id]['SPO2'] += S['SPO2']
		TT[device_id]['SYSTOLE'] += S['SYSTOLE']
		TT[device_id]['DIASTOLE'] += S['DIASTOLE']
		TT[device_id]['TEMPERATURE'] += S['TEMPERATURE']
		TT[device_id]['PACIENT_POSITION'] += S['PACIENT_POSITION']
		TT[device_id]['num_concat'] += 1
		TT[device_id]['time_end'] = time / 60

		#envia novamente alerta para os médicos
		send_alert()
		#atualiza a base de dados com o novo evento concatenado
		update(TT[device_id]['row_id'],TT[device_id])

	elif prediction['class'] != '(N':
		#se o que foi previsto é diferente do anterior e ele não foi uma batida normal
		#significa que foi outro tipo de arritimia, então substitui e começa a concatenar

		TT[device_id]['prediction'] = prediction
		TT[device_id]['ECG'] += ECG
		TT[device_id]['BPM'] += S['BPM']
		TT[device_id]['AIRFLOW'] += S['AIRFLOW']
		TT[device_id]['EMG'] += S['EMG']
		TT[device_id]['SPO2'] += S['SPO2']
		TT[device_id]['SYSTOLE'] += S['SYSTOLE']
		TT[device_id]['DIASTOLE'] += S['DIASTOLE']
		TT[device_id]['TEMPERATURE'] += S['TEMPERATURE']
		TT[device_id]['PACIENT_POSITION'] += S['PACIENT_POSITION']
		TT[device_id]['num_concat'] += 1
		TT[device_id]['time_ini'] = time / 60
		TT[device_id]['time_end'] = (time+3) / 60

		TT[device_id]['row_id'] = save(event = TT[device_id],device_id=device_id)

	else:
		#entrará nesse caso quando ele detectar uma batida normal
		#nesse caso apenas atualiza a tabela para determina o fim de uma arritmia
		#Os eventos normais não são concatenados e não vão aparecer na
		#timeline.
		TT[device_id]['prediction'] = {'class':None,'probability':0.0}
		TT[device_id]['ECG'] = []
		TT[device_id]['S'] = []


def classify_on_demand(clientsocket):
	while True:
		print '++++ esperando streamming +++++'
		data = clientsocket.recv(102400).decode("utf-8", "ignore")
		data = json.loads(data)
		print '++RECEBIDO (JSON) : '
		# pp.pprint(data)
		timeline_maintaince(ECG=data['ECG'],S=data['S'],device_id=data['device_id'])

if __name__ == "__main__":

	#id para simular persistir na base de dados
	event_id = 0

	pp = pprint.PrettyPrinter(indent=4)

	#timeline table - responsável por guardar os eventos da timeline
	TT = {}

	

	segmentation = WaveSegmentation()
	model = build_model()

	time = 0.0
	'''
		Descomente as linhas a baixo para rodar o teste do que se espera do input
		A variável time é opcional
	'''
	# signals = get_chunks('./cudb/cu02.csv')
	# for signal in signals:
	# 	time += 3.0
	# 	print time
	# 	S = {
	# 		'BPM':signal,
	# 		'AIRFLOW':signal,
	# 		'EMG':signal,
	# 		'SPO2':signal,
	# 		'SYSTOLE':signal,
	# 		'DIASTOLE':signal,
	# 		'TEMPERATURE':signal,
	# 		'PACIENT_POSITION':signal
	# 	}
		
	# 	timeline_maintaince(ECG=signal,S=S,device_id=1,time=time)

	'''
		Comente as linhas abaixo para rodar o teste
	'''

	# Levantando serviço
	serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	serversocket.bind(('localhost', 2428))
	serversocket.listen(50)

	while True:
		#aceita e estabelece conexão
		print '+++ esperando conexão do cliente +++'
		clientsocket, address = serversocket.accept()
		thread.start_new_thread(classify_on_demand,(clientsocket,))






