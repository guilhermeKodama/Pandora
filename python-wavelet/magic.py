#rdann -r cudb/cu01 -a atr -p [ ] ! > cu01.csv
import os
import csv
import re
import sys
from os import listdir

ALL_DATASETS = 'all'

############# UTILITARIOS
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
############# UTILITARIOS

# Load RECORD file. The File contains the name of dbs files
def load_records(db):
	if not os.path.exists(db):
	    os.makedirs(db)

	os.system('wfdbcat '+db+'/RECORDS > ./'+db+'/records.csv')
	
	f = open('./'+db+'/records.csv','r')
	reader = csv.reader(f)
	rows = list(reader)

	results = []
	for row in rows:
		results.append(row[0]) 

	return results

def download_dbs(db,amount):
	print '======= DOWNLOAD DBS ====='
	# Load records list
	datasets = load_records(db=db)
	amount = len(datasets)

	response = {'annotation':[],'sample':[]}
	for i in range(int(amount)):
		dataset = datasets[i]
		print 'DATASET : '+dataset
		outputName = dataset.replace('/', '_')

		#baixa as anotacoes e os samples do dataset, se eles ja nao foram baixados
		if exist(db,outputName) == False:
			os.system('rdann -r '+db+'/'+dataset+' -a atr -p [ ] ! + > ./'+db+'/'+outputName+'_annotation.csv')
			os.system('rdsamp -r '+db+'/'+dataset+' -p -c > ./'+db+'/'+outputName+'.csv')

		response['annotation'].append(db+'/'+outputName+'_annotation.csv')
		response['sample'].append(db+'/'+outputName+'.csv')
	return response

def get_component(row,col):
	row = row[0]
	row = row.replace('[','').replace(']','')
	if re.search('\d+/\d+/\d+', row) != None:
		row = row.replace(re.search('\d+/\d+/\d+', row).group(0),'')
	row = re.findall('\S+', row)
	if len(row) == 6:
		row.append('')
	return row[col]

def get_signals(fileName,column):
	f = open('./'+fileName,'r')
	reader = csv.reader(f)
	rows = list(reader)
	signal = []
	for row in rows:
		try:
			signal.append(float(row[column]))
		except:
			print 'ops'
	return signal

def exist(databaseName,fileName):
	hasAnnotation = False
	hasSample = False
	files = listdir('./'+databaseName+'/')
	for file in files:
		if file == fileName+'_annotation.csv':
			hasAnnotation = True
		if file == fileName+'.csv':
			hasSample = True
	if hasAnnotation and hasSample:
		return True
	else:
		return False


def export_file():

	if len(sys.argv) > 2:
		try:
			f = open('./'+sys.argv[1],'r')
			print '===== DATABASES FILE : '+'./'+sys.argv[1]+' ======'
			reader = csv.reader(f)
			dbs = list(reader)
		except:
			print('Arquivo '+sys.argv[1]+' nao encontrado')
			exit()
	else:
		print('erro nos parametros: python magic.py <dbs_name> <number_of_samples ou all> <shoud_download>(optional)')
		exit()

	for db in dbs:
		print 'DB : '+str(db)
		response = download_dbs(db=db[0], amount=sys.argv[2])

		#gera arquivo config
		print '==== GERANDO ARQUIVO DE CONFIG ===='
		dataset = open('./'+db[0]+'/dataset.csv', 'w')
		writer = csv.writer(dataset, delimiter=',',quotechar='|', quoting=csv.QUOTE_MINIMAL)
		writer.writerow(['time_ini', 'time_end','file_name','class'])

		for annotation in response['annotation']:
			try:
				f = open(annotation)
				reader = csv.reader(f)
				rows = list(reader)
				f.close()
			except:
				break

			typ = None
			ini = None
			end = None
			for index in range(len(rows)):
				t = get_component(rows[index],2)
				if ini == None:
					if t == '[' or t == '+':
						ini = get_component(rows[index], 0)
						if t == '+':
							typ = get_component(rows[index], 6)
						else:
							typ = '(VF'
						if index == len(rows) - 1:
							end = -1
							writer.writerow([ini,end,annotation,typ])
				else:
					end = get_component(rows[index], 0)
					if differ_time(ini, end) > 3.0:
						writer.writerow([ini,end,annotation,typ])
					if t == ']' or t == '+':						
						if t == '+':
							typ = get_component(rows[index], 6)
						else:
							typ = '(VF'
					ini = end
					end = None
	    		

		# for sample in response['sample']:
		# 	signals = get_signals(fileName=sample,column=1)
		# 	print signals

export_file()