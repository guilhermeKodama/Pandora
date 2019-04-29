#!/usr/bin/env python
# -*- coding: utf-8 -*-
import math
from biosppy.signals import ecg
import statistics

class WaveSegmentation:

	def __init__(self):
		pass

	def calculate_euclidean_distance(self,a_x,a_y,b_x,b_y):
		return math.sqrt(math.pow((a_x - b_x),2) + (math.pow((a_y - b_y),2)))

	# Checa quantas amostras tem em um segundo 
	# para determinar a frequencia em Hz
	def get_sampling_rate(self,array):
		for index in range(len(array)):
			if float(array[index][0]) == 1.0:
				return index

	# Determina os picos P e T
	def wave_peak(self,template, qrs_complex, sampling_rate):
		
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
	def wave_depression(self,template, r_peak, qrs_complex, sampling_rate):
		
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
	def wave_interval(self,template, wave_peak, sampling_rate, duration):
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
	def wave_segmentation (self,templates, templates_time, sampling_rate, qrs_duration, show):
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
			qrs_complex = self.wave_interval(template=template, wave_peak=r_peak_index, sampling_rate=SAMPLING_RATE, duration=qrs_duration)

			# Determina as depressoes QS
			qs_depression = self.wave_depression(template=template, r_peak=r_peak_index, qrs_complex=qrs_complex, sampling_rate=SAMPLING_RATE)
			q_peak_index = qs_depression['q']
			s_peak_index = qs_depression['s']

			# Determina o pico P e T
			pt_peak_index = self.wave_peak(template=template, qrs_complex=qrs_complex, sampling_rate=SAMPLING_RATE)
			p_peak_index = pt_peak_index['p']
			t_peak_index = pt_peak_index['t']

			# Determina o intervalo da onda P
			p_interval = self.wave_interval(template=template, wave_peak=p_peak_index, sampling_rate=SAMPLING_RATE, duration=P_DURATION)
				
			# Determina o intervalo da onda T
			t_interval = self.wave_interval(template=template, wave_peak=t_peak_index, sampling_rate=SAMPLING_RATE, duration=T_DURATION)


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
							   't_interval':t_interval}

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
				plt.title('Templates: ')
				plt.xlabel('Time (s)')
				plt.ylabel('Amplitude (mV)')
				plt.grid(True)

		# Mostra o grafico apos percorrer todo os templates
		if show:
			plt.show()

		return result

	def extract_features(self,signal,sampling_rate):

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
		segmentations = self.wave_segmentation(templates=templates, templates_time=templatesTime, sampling_rate=sampling_rate, qrs_duration=0.1, show=False)

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

			#calcula distância entre os picos
			rp_distance = self.calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],p_peak_index,templates[index][p_peak_index])
			rq_distance = self.calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],q_peak_index,templates[index][q_peak_index])
			rs_distance = self.calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],s_peak_index,templates[index][s_peak_index])
			rt_distance = self.calculate_euclidean_distance(r_peak_index,templates[index][r_peak_index],t_peak_index,templates[index][t_peak_index])

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
			instance = [p,
						q,
						r,
						s,
						t,
						rp_distance,
						rq_distance,
						rs_distance,
						rt_distance,
						mean,
						median,
						standard_deviation,
						variance,
						pr_interval_width,
						pr_segment_width,
						qrs_complex_width,
						qt_interval_width,
						st_segment_width,
						p_interval_width,
						t_interval_width]
			instancies.append(instance)
			index += 1
		return instancies