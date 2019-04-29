#!/usr/bin/env python
# -*- coding: utf-8 -*-
import math
from biosppy.signals import ecg
import matplotlib.pyplot as plt
import csv
import pprint
import sys
import statistics
from os import listdir

UNTIL_END = '-0.001'

#############################################
# BEGIN FUNCTIONS

def load_samples(dbs_name):
	samples = load_datasets(dbs_name)
	signals = []
	for sample in samples:
		# Recupera o sample carregado em memoria
		sample = load_signal(sample, samples)
		# Se houver conteudo ele adiciona no array de samples
		if sample:
			signals.append(sample)

	return signals

# Checa quantas amostras tem em um segundo 
# para determinar a frequencia em Hz
def get_sampling_rate(array):
	for index in range(len(array)):
		if float(array[index][0]) == 1.0:
			return index

# Converte tempo de 'HH:MM:ss.mmm' para segundos
def get_sec(time):
	l = time.replace('.',':').split(':')
	if len(l) == 1:
		return int(l[-1]) / 1000.0
	elif len(l) == 2:
		return int(l[-1]) / 1000.0 + int(l[-2])
	elif len(l) == 3:
		return int(l[-1]) / 1000.0 + int(l[-2]) + int(l[-3]) * 60
	elif len(l) == 4:
		return int(l[-1]) / 1000.0 + int(l[-2]) + int(l[-3]) * 60 + int(l[-4]) * 3600

# Calcula a diferenca entre dois tempos em segundos.
# Retorna -1 caso a diferenca seja negativa
def differ_time(ini, end):
	differ = get_sec(end) - get_sec(ini)
	return -1 if differ < 0 else differ

# Carrega os datasets de cada pasta dos BD's baixados
def load_datasets(dbs_name):
	try:
		foldersFile = open('./'+dbs_name,'r')
		reader = csv.reader(foldersFile)
		folders = list(reader)
	except:
		print('Arquivo contendo DBs nao encontrado')
		exit()

	samples = {}
	for folder in folders:
		print 'DATASET : '+str(folder)
		datasetFile = open('./'+folder[0]+'/dataset.csv','r')
		reader = csv.reader(datasetFile)
		dataset = list(reader)

		# percorre por todo array de dataset, com excecao da primeira linha que contem o cabecalho
		for index in range(1, len(dataset)):
			# recupera o tempo de inicio
			ini = dataset[index][0]
			# recupera o tempo do fim
			end = dataset[index][1]
			# recupera o nome do arquivo, pegando soh o que tem antes do _ (ex: nome_annotation)
			fileName = dataset[index][2].split('_')[0]
			# recupera a classificacao
			classification = dataset[index][3]
			print 'INDEX : '+str(index)+' INI_TIME: '+str(ini)+' END_TIME: '+str(end)+' CLASS: '+str(classification)+' FILE_NAME: '+str(fileName)
			if fileName not in samples:
				samples[fileName] = [{"time_ini":get_sec(ini), "time_end":get_sec(end), "classification":classification}]
			else:
				samples[fileName].append({"time_ini":get_sec(ini), "time_end":get_sec(end), "classification":classification})

		datasetFile.close()

	foldersFile.close()

	return samples

# Carrega o arquivo de sample passado por parametro em um array na memoria
def load_signal(file_name, samples):

	# Carrega os sinais do arquivo na memoria
	signalsFile = open('./'+file_name + '.csv','r')
	reader = csv.reader(signalsFile)
	rows = list(reader)
	signalsFile.close()

	signals = []

	if rows:
		# Checa se o tempo do sample eh maior que 3 segundos
		if float(rows[-1][0]) < 3.0:
			print 'ValueError: Nao e possivel determinar a frequencia da amostra em Hz. Amostra menor do que 3 segundos'
			return None

		for index in range(len(rows)):
			if float(rows[index][0]) >= float(samples[file_name][0]['time_ini']):
				# Alguns streamings estao vindo com '-' no meio dos dados
				# Este e um tratamento para evitar erros
				if rows[index][1] == '-':
					signals.append(0.0)
				else:	
					signals.append(float(rows[index][1]))
				
				# UNTIL_END indica que o sinal soh termina no final do arquivo
				if float(samples[file_name][0]['time_end']) != UNTIL_END:
					if float(rows[index][0]) == float(samples[file_name][0]['time_end']):
						break
		
		# Recupera a classificacao da amostra
		CLASSIFICATION = samples[file_name][0]['classification']

		return (signals, get_sampling_rate(rows), CLASSIFICATION)
	else:
		return None

# Determina os picos P e T
def wave_peak(template, qrs_complex, sampling_rate):
	
	# Inicializa o pico P com o primeiro valor do template
	p_peak = template[0]
	p_peak_index = 0
	for index in range(qrs_complex['left'] + 1):
		# Atualiza o valor do pico P caso encontre um valor maior
		if round(template[index], 2) > p_peak:
			p_peak = template[index]
			p_peak_index = index

	# Inicializa o pico T com o primeiro valor do complexo QRS
	t_peak = template[qrs_complex['right']]
	t_peak_index = qrs_complex['right']
	for index in range(qrs_complex['right'], len(template)):
		# Atualiza o valor do pico T caso encontre um valor maior
		if round(template[index], 2) > t_peak:
			t_peak = template[index]
			t_peak_index = index	
	
	# Monta todos os resultados em um dicionatio
	return {'p':p_peak_index,'t':t_peak_index}

# Determina a depressao da onda Q e S
def wave_depression(template, r_peak, qrs_complex, sampling_rate):
	
	# Inicializa a depressao Q com o primeiro valor do complexo QRS
	q_depression = round(template[qrs_complex['left']], 2)
	q_depression_index = qrs_complex['left']

	# Percorre um intervalo do inicio do complexo QRS ate o pico R
	# para determinar a depressao Q
	for index in range(qrs_complex['left'], r_peak):
		if round(template[index], 2) < q_depression:
			q_depression = template[index]
			q_depression_index = index
	
	# Inicializa a depressao S com o valor do pico R
	s_depression = round(template[r_peak], 2)
	s_depression_index = r_peak

	# Percorre um intervalo do pico R ate o final do complexo QRS
	# para determinar a depressao S
	for index in range(r_peak, qrs_complex['right']):
		if round(template[index], 2) < s_depression:
			s_depression = template[index]
			s_depression_index = index

	# Monta todos os resultados em um dicionatio
	result = {'q':q_depression_index,'s':s_depression_index}
	return result

# Determina o intervalo de uma onda
def wave_interval(template, wave_peak, sampling_rate, duration):
	offset = ((duration/2) * sampling_rate) + 1
	wave_left_index = int(wave_peak - offset)
	# Caso o indice do intervalo a esquerda exceda (seja um indice
	# negativo), o inicio do intervalo a esquerda sera o primeiro indice do array
	if wave_left_index < 0:
		wave_left_index = 0
	
	wave_right_index = int(offset + wave_peak)
	# Caso o indice do intervalo a direita exceda (eja um indice maior que o tamanho 
	# do template), o fim do intervalo a direita sera o ultimo indice do array
	if wave_right_index > len(template) - 1:
		wave_right_index = len(template) - 1

	# Monta todos os resultados em um dicionatio
	result = {'left':wave_left_index, 'right':wave_right_index}
	return result

# Determina em intervalos, picos e depressoes os templates
def wave_segmentation (templates, templates_time, sampling_rate, qrs_duration, classification, show):
	# Taxa da amostra em Hz
	SAMPLING_RATE = sampling_rate

	# Duracao da onda P em segundos
	P_DURATION = 0.06

	# Duracao da onda T em segundos
	T_DURATION = 0.08

	# Criacao e inicializacao dos indices dos picos das ondas
	p_peak_index = q_peak_index = s_peak_index = t_peak_index = 0

	# O indice do pico R eh sempre 1/3 do tamanho de um template. 
	# O pico estah sempre na posicao 0.0 seg do templatesTime
	r_peak_index = len(templates[0])/3

	# Criacao e inicializacao dos arrays qua guardam os indices dos intervalos e segmentos
	pr_interval = pr_segment = qrs_complex = qt_interval = st_segment = []

	# Array para guardar todos os resultados
	result = []

	# Percorre todos os templates do array
	for template in templates:
		wave = template

		# Determina o intevalo do complexo QRS
		qrs_complex = wave_interval(template=template, wave_peak=r_peak_index, sampling_rate=SAMPLING_RATE, duration=qrs_duration)

		# Determina as depressoes QS
		qs_depression = wave_depression(template=template, r_peak=r_peak_index, qrs_complex=qrs_complex, sampling_rate=SAMPLING_RATE)
		q_peak_index = qs_depression['q']
		s_peak_index = qs_depression['s']

		# Determina o pico P e T
		pt_peak_index = wave_peak(template=template, qrs_complex=qrs_complex, sampling_rate=SAMPLING_RATE)
		p_peak_index = pt_peak_index['p']
		t_peak_index = pt_peak_index['t']

		# Determina o intervalo da onda P
		p_interval = wave_interval(template=template, wave_peak=p_peak_index, sampling_rate=SAMPLING_RATE, duration=P_DURATION)
			
		# Determina o intervalo da onda T
		t_interval = wave_interval(template=template, wave_peak=t_peak_index, sampling_rate=SAMPLING_RATE, duration=T_DURATION)


		# Determinacao do intervalo PR
		pr_interval = [p_interval['left'], qrs_complex['left']]

		# Determinacao do segmento PR
		pr_segment = [p_interval['right'], qrs_complex['left']]
		
		# Determinacao do intervalo QT
		qt_interval = [qrs_complex['left'], t_interval['right']]
		
		# Determinacao do segmento ST
		st_segment = [qrs_complex['right'], t_interval['left']]


		# Monta todos os resultados em um dicionatio
		template_result = {'wave':wave,
						   'pr_interval':pr_interval, 
				  		   'pr_segment':pr_segment, 
				  		   'qrs_complex':qrs_complex, 
						   'qt_interval':qt_interval, 
						   'st_segment':st_segment,
						   'p_peak':p_peak_index,
						   'p_interval':p_interval,
						   'q_peak':q_peak_index,
						   'r_peak':r_peak_index,
						   's_peak':s_peak_index,
						   't_peak':t_peak_index,
						   't_interval':t_interval,
						   'classification':classification}

		# Adiciona o resultado no array de resultados
		result.append(template_result)

		# Caso esta variavel venha True, todos os dados serao plotados
		if show:
			# Plota o pico R 
			plt.plot(templates_time[r_peak_index], template[r_peak_index], 'go')

			# Plota o complexo QRS
			plt.plot(templates_time[qrs_complex['left']], template[qrs_complex['left']], 'r^')
			plt.plot(templates_time[qrs_complex['right']], template[qrs_complex['right']], 'r^')

			# Plota a depressao Q e S
			plt.plot(templates_time[qs_depression['q']], template[qs_depression['q']], 'bo')
			plt.plot(templates_time[qs_depression['s']], template[qs_depression['s']], 'bo')

			# Plota o pico P
			plt.plot(templates_time[p_peak_index], template[p_peak_index], 'go')

			# Plota o intervalo P
			plt.plot(templates_time[p_interval['left']], template[p_interval['left']], 'r^')
			plt.plot(templates_time[p_interval['right']], template[p_interval['right']], 'r^')	

			# Plota o pico T
			plt.plot(templates_time[t_peak_index], template[t_peak_index], 'go')

			# Plota o intevalo T
			plt.plot(templates_time[t_interval['left']], template[t_interval['left']], 'r^')
			plt.plot(templates_time[t_interval['right']], template[t_interval['right']], 'r^')	

			# Plota os templates
			plt.plot(templates_time, template, 'k')
			
			# Detalhes do grafico
			plt.title('Templates: ' + classification)
			plt.xlabel('Time (s)')
			plt.ylabel('Amplitude (mV)')
			plt.grid(True)

	# Mostra o grafico apos percorrer todo os templates
	if show:
		plt.show()

	return result


'''
Modificações Guilherme Kodama - 15/04/2016

As funções a baixo foram criadas para que fosse possível criar a base de treino
de sample em sample, ao invés de carregar tudo na memória. Pois alguns samples 
tem mais de 400MB de tamanho e algumas bases de dados tem mais de 20GB.

'''

#cache para impedir que o programa tente abrir novamente um sample pesado para
#extrair um outro segmento do samples
cache = {}


# retorna uma lista das bases de dados que serão utilizadas para criar a base de treino
def get_dbs(dbsFile):

	dbs = []

	try:
		f = open('./'+dbsFile,'r')
		reader = csv.reader(f)
		dbs = list(reader)
		return dbs

	except:
		print('Arquivo contendo DBs nao encontrado')
		exit()

#retorna uma lista dos samples que contém naquele dataset
def get_samples(dbName):
	samples = []
	print 'DATASET : '+str(dbName)
	datasetFile = open('./'+dbName+'/dataset.csv','r')
	reader = csv.reader(datasetFile)
	dataset = list(reader)

	# percorre por todo array de dataset, com excecao da primeira linha que contem o cabecalho
	for index in range(1, len(dataset)):
		# recupera o tempo de inicio
		ini = dataset[index][0]
		# recupera o tempo do fim
		end = dataset[index][1]
		# recupera o nome do arquivo, pegando soh o que tem antes do _ (ex: nome_annotation)
		fileName = dataset[index][2].split('_')[0]
		# recupera a classificacao
		classification = dataset[index][3]
		print 'INDEX : '+str(index)+' INI_TIME: '+str(ini)+' END_TIME: '+str(end)+' CLASS: '+str(classification)+' FILE_NAME: '+str(fileName)
		if fileName not in samples:
			samples.append({"time_ini":get_sec(ini), "time_end":get_sec(end),"file_name":str(fileName), "classification":classification})
		else:
			samples.append({"time_ini":get_sec(ini), "time_end":get_sec(end),"file_name":str(fileName), "classification":classification})
	return samples

#extrai os sinais de um sample
def extract_signals(sample):
	rows = []
	#verifica no cache
	if cache == {}:
		# Carrega os sinais do arquivo na memoria
		signalsFile = open('./'+sample['file_name'] + '.csv','r')
		cache['file_name'] = sample['file_name']
		cache['file'] = signalsFile
		reader = csv.reader(signalsFile)
		rows = list(reader)
		cache['rows'] = rows
	elif cache['file_name'] != sample['file_name']:
		cache['file'].close()
		# Carrega os sinais do arquivo na memoria
		signalsFile = open('./'+sample['file_name'] + '.csv','r')
		cache['file_name'] = sample['file_name']
		cache['file'] = signalsFile
		reader = csv.reader(signalsFile)
		rows = list(reader)
		cache['rows'] = rows
	elif cache['file_name'] == sample['file_name']:
		rows = cache['rows']

	signals = []

	if rows:
		# Checa se o tempo do sample eh maior que 3 segundos
		if float(rows[-1][0]) < 3.0:
			print 'ValueError: Nao e possivel determinar a frequencia da amostra em Hz. Amostra menor do que 3 segundos'
			return None

		for index in range(len(rows)):
			if float(rows[index][0]) >= float(sample['time_ini']):
				# Alguns streamings estao vindo com '-' no meio dos dados
				# Este é um tratamento para evitar erros
				if rows[index][1] == '-':
					signals.append(0.0)
				else:	
					signals.append(float(rows[index][1]))
				
				# UNTIL_END indica que o sinal soh termina no final do arquivo
				if float(sample['time_end']) != UNTIL_END:
					if float(rows[index][0]) == float(sample['time_end']):
						break
		
		# Recupera a classificacao da amostra
		CLASSIFICATION = sample['classification']

		return (signals, get_sampling_rate(rows), CLASSIFICATION)
	else:
		return None

'''
Metodos para feature extractio
'''
def calculate_euclidean_distance(a_x,a_y,b_x,b_y):
	return math.sqrt(math.pow((a_x - b_x),2) + (math.pow((a_y - b_y),2)))

'''
fim
'''
#extrai as instancias que contém nesse sinal (cada instância contem K features)
def extract_instancies(signal,sampling_rate,classification):

	# Cria o template de cada amostra de sinal passada
	try:
		out = ecg.ecg(signal=signal, sampling_rate=sampling_rate, show=False)
	except:
		return None

	filtered = out["filtered"]
	time = out["ts"]
	templates = out["templates"]
	templatesTime = out["templates_ts"]
	rpeaks = out["rpeaks"]

	# Segmenta todas as ondas em P, Q, R, S, T, complexo, intervalos e segmentos
	segmentations = wave_segmentation(templates=templates, templates_time=templatesTime, sampling_rate=sampling_rate, qrs_duration=0.1, classification=classification, show=False)

	instancies = []
	index = 0
	for segmentation in segmentations:
		wave = segmentation['wave']
		# Recupera os intervalos, segmentos, picos e classificacao gerada
		pr_interval = segmentation['pr_interval']
		pr_segment = segmentation['pr_segment']
		qrs_complex = segmentation['qrs_complex']
		qt_interval = segmentation['qt_interval']
		st_segment = segmentation['st_segment']
		p_peak_index = segmentation['p_peak']
		p_interval = segmentation['p_interval']
		q_peak_index = segmentation['q_peak']
		r_peak_index = segmentation['r_peak']
		s_peak_index = segmentation['s_peak']
		t_peak_index = segmentation['t_peak']
		t_interval = segmentation['t_interval']
		classification = segmentation['classification']

		#calcula distância entre os picos
		rp_distance = calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],p_peak_index,templates[index][p_peak_index])
		rq_distance = calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],q_peak_index,templates[index][q_peak_index])
		rs_distance = calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],s_peak_index,templates[index][s_peak_index])
		rt_distance = calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],t_peak_index,templates[index][t_peak_index])

		#variáveis estatísticas
		mean = statistics.mean(wave)
		median = statistics.median(wave)
		standard_deviation = statistics.stdev(wave)
		variance = statistics.variance(wave)

		p = templates[index][p_peak_index]
		q = templates[index][q_peak_index]
		r = templates[index][r_peak_index]
		s = templates[index][s_peak_index]
		t = templates[index][t_peak_index]

		# Calcula os deltas (diferenca) dos intervalos, segmentos e complexos
		pr_interval_width = templatesTime[pr_interval[1]] - templatesTime[pr_interval[0]]
		pr_segment_width = templatesTime[pr_segment[1]] - templatesTime[pr_segment[0]]
		qrs_complex_width = templatesTime[qrs_complex['left']] - templatesTime[qrs_complex['right']]
		qt_interval_width = templatesTime[qt_interval[1]] - templatesTime[qt_interval[0]]
		st_segment_width = templatesTime[st_segment[1]] - templatesTime[st_segment[0]]
		p_interval_width = templatesTime[p_interval['left']] - templatesTime[p_interval['right']]
		t_interval_width = templatesTime[t_interval['left']] - templatesTime[t_interval['right']]
		instance = {'p':p,
					'q':q,
					'r':r,
					's':s,
					't':t,
					'rp_distance':rp_distance,
					'rq_distance':rq_distance,
					'rs_distance':rs_distance,
					'rt_distance':rt_distance,
					'mean':mean,
					'median':median,
					'standard_deviation':standard_deviation,
					'variance':variance,
					'pr_interval_width':pr_interval_width,
					'pr_segment_width':pr_segment_width,
					'qrs_complex_width':qrs_complex_width,
					'qt_interval_width':qt_interval_width,
					'st_segment_width':st_segment_width,
					'p_interval_width':p_interval_width,
					't_interval_width':t_interval_width,
					'classification':classification}
		instancies.append(instance)
		index += 1
	return instancies

#escreve a nova instânci extraída para a base de treino
def write_instancies(instancies,trainingset):
	for instance in instancies:
		# Escreve no arquivo trainingset
		trainingset.writerow(['{0:.3f}'.format(instance['p']), '{0:.3f}'.format(instance['q']), '{0:.3f}'.format(instance['r']), '{0:.3f}'.format(instance['s']), '{0:.3f}'.format(instance['t']),
							  '{0:.3f}'.format(instance['mean']),'{0:.3f}'.format(instance['median']),'{0:.3f}'.format(instance['standard_deviation']),'{0:.3f}'.format(instance['variance']),
							  '{0:.3f}'.format(instance['rp_distance']),'{0:.3f}'.format(instance['rq_distance']),'{0:.3f}'.format(instance['rs_distance']),'{0:.3f}'.format(instance['rt_distance']),
							  '{0:.3f}'.format(instance['pr_interval_width']), '{0:.3f}'.format(instance['pr_segment_width']), '{0:.3f}'.format(instance['qrs_complex_width']), 
							  '{0:.3f}'.format(instance['qt_interval_width']), '{0:.3f}'.format(instance['st_segment_width']), '{0:.3f}'.format(instance['p_interval_width']), 
							  '{0:.3f}'.format(instance['t_interval_width']), instance['classification']])


'''
FIM MODIFICAÇÕES
'''

# Metodo para gerar a base de treino
# Deve ser passado o nome do arquivo que contem a header de todos os sets
def training_set():
	if len(sys.argv) > 1:
		responses = load_samples(sys.argv[1])
	else:
		print('erro nos parametros: python training.py <dbs_name>')
		exit()

	# Cria um arquivo para escrever em formato de matriz todos os resultados
	trainingsetFile = open('./trainingset.csv', 'w')
	trainingset = csv.writer(trainingsetFile, delimiter=',', quotechar='|')
	# Gera o cabecalho do arquivo
	trainingset.writerow(['p', 'q', 'r', 's', 't', 'pr_interval_width', 'pr_segment_width', 'qrs_complex_width', 'qt_interval_width', 'st_segment_width', 'p_interval_width', 't_interval_width', 'classification'])


	for response in responses:
		# Recupera o sinal
		signal = response[0]
		# Recupera o sampling rate
		samplingRate = response[1]
		# recupera a classificacao
		classification = response[2]

		# Cria o template de cada amostra de sinal passada
		out = ecg.ecg(signal=signal, sampling_rate=samplingRate, show=False)
		filtered = out["filtered"]
		time = out["ts"]
		templates = out["templates"]
		templatesTime = out["templates_ts"]
		rpeaks = out["rpeaks"]

		# Segmenta todas as ondas em P, Q, R, S, T, complexo, intervalos e segmentos
		segmentations = wave_segmentation(templates=templates, templates_time=templatesTime, sampling_rate=samplingRate, qrs_duration=0.1, classification=classification, show=False)

		index = 0
		for segmentation in segmentations:
			# Recupera os intervalos, segmentos, picos e classificacao gerada
			pr_interval = segmentation['pr_interval']
			pr_segment = segmentation['pr_segment']
			qrs_complex = segmentation['qrs_complex']
			qt_interval = segmentation['qt_interval']
			st_segment = segmentation['st_segment']
			p_peak_index = segmentation['p_peak']
			p_interval = segmentation['p_interval']
			q_peak_index = segmentation['q_peak']
			r_peak_index = segmentation['r_peak']
			s_peak_index = segmentation['s_peak']
			t_peak_index = segmentation['t_peak']
			t_interval = segmentation['t_interval']
			classification = segmentation['classification']

			p = templates[index][p_peak_index]
			q = templates[index][q_peak_index]
			r = templates[index][r_peak_index]
			s = templates[index][s_peak_index]
			t = templates[index][t_peak_index]

			# Calcula os deltas (diferenca) dos intervalos, segmentos e complexos
			pr_interval_width = templatesTime[pr_interval[1]] - templatesTime[pr_interval[0]]
			pr_segment_width = templatesTime[pr_segment[1]] - templatesTime[pr_segment[0]]
			qrs_complex_width = templatesTime[qrs_complex['left']] - templatesTime[qrs_complex['right']]
			qt_interval_width = templatesTime[qt_interval[1]] - templatesTime[qt_interval[0]]
			st_segment_width = templatesTime[st_segment[1]] - templatesTime[st_segment[0]]
			p_interval_width = templatesTime[p_interval['left']] - templatesTime[p_interval['right']]
			t_interval_width = templatesTime[t_interval['left']] - templatesTime[t_interval['right']]
			
			# Escreve no arquivo trainingset
			trainingset.writerow(['{0:.3f}'.format(p), '{0:.3f}'.format(q), '{0:.3f}'.format(r), '{0:.3f}'.format(s), '{0:.3f}'.format(t), 
								  '{0:.3f}'.format(pr_interval_width), '{0:.3f}'.format(pr_segment_width), '{0:.3f}'.format(qrs_complex_width), 
								  '{0:.3f}'.format(qt_interval_width), '{0:.3f}'.format(st_segment_width), '{0:.3f}'.format(p_interval_width), 
								  '{0:.3f}'.format(t_interval_width), classification])
			index += 1

	trainingsetFile.close()
# END FUNCTIONS
#############################################

if __name__ == "__main__":

	if len(sys.argv) > 1:

		#pega o nome do arquivo com os nomes dos datasets
		dbsFile = sys.argv[1]

		# Cria um arquivo para escrever em formato de matriz todos os resultados
		trainingsetFile = open('./trainingset.csv', 'wt')
		trainingset = csv.writer(trainingsetFile, delimiter=',', quotechar='|')
		# Gera o cabecalho do arquivo
		trainingset.writerow(['p', 'q', 'r', 's', 't','mean','median','standard_deviation','variance','rp_distance','rq_distance','rs_distance','rt_distance' ,'pr_interval_width', 'pr_segment_width', 'qrs_complex_width', 'qt_interval_width', 'st_segment_width', 'p_interval_width', 't_interval_width', 'classification'])

		#pega a lista dos nomes desses dbs
		dbs = get_dbs(dbsFile)
		
		for db in dbs:
			print 'DB : '+str(db[0])
			#pega a lista de samples que tem nesse db
			samples = get_samples(db[0])

			for sample in samples:
				print 'SAMPLE : '+str(sample)
				#extrai os sinais do sample
				signal,sampling_rate, classification = extract_signals(sample)
				#extrai instancias dos sinais
				instancies = extract_instancies(signal,sampling_rate,classification)
				if instancies != None:
					#escreve instancias na base de treino
					write_instancies(instancies,trainingset)


	else:
		print('erro nos parametros: python training.py <dbs_name>')
		exit()
	#training_set()







