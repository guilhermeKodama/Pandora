
//matrix gerada do arquivo apnea.csv
float *apnea_matrix;
int apnea_size = 0;
//matrix gerada do arquivo emg.csv
float *emg_matrix;
int emg_size = 0;
//matrix gerada do arquivo cu02.csv
float *vt_matrix;
int vt_size = 0;

void read_apnea_csv(){
	//ponteiro para o arquivo em memoria
	FILE * fp;
	//"string" da linha que foi lida
    char * line = NULL;
    //tamanho do arquivo
    size_t len = 0;
    //tamanho da linha
    ssize_t read;
    //input dos sensores
    float elapse_time,ecg,resp_c,resp_a,resp_n,spo2;
    printf("Vou tentar carregar tudo na memoria\n");
    //matrix 
    apnea_matrix = (float*) malloc(195000 * 6 * sizeof(float));
    if(apnea_matrix){
      printf("apnea.csv : sucess\n");
    }else{
      printf("apnea.csv : failed\n");
    }
   
    int i = 0;
    //abre o arquivo para leitura
    fp = fopen("apnea.csv", "r");

    //se não for possível abrir solta um erro
    if (fp == NULL)
    	exit(EXIT_FAILURE);


    //lê cada linha do arquivo fp enquanto não chegar no final
    while ((read = getline(&line, &len, fp)) != -1) {
    	//printf("Retrieved line of length %zu :\n", read);
    	//printf("%s", line);

    	sscanf(line, "%f,%f,%f,%f,%f,%f",&elapse_time,&ecg,&resp_c,&resp_a,&resp_n,&spo2);
    	//passar o cabeçalho do CSV
    	if (i > 1){
    		//guarda as informações em uma matrix para ser usada posteriormente
	    	apnea_matrix[i*6 +0] = elapse_time;
	    	apnea_matrix[i*6 +1] = ecg;
	    	apnea_matrix[i*6 +2] = resp_c;
	    	apnea_matrix[i*6 +3] = resp_a;
	    	apnea_matrix[i*6 +4] = resp_n;
	    	apnea_matrix[i*6 +5] = spo2;
        apnea_size = apnea_size + 1;
    	}

    	i = i+1;
    }

    fclose(fp);

    if (line)
    	free(line);
}

void read_emg_csv(){
  //ponteiro para o arquivo em memoria
  FILE * fp;
  //"string" da linha que foi lida
  char * line = NULL;
  //tamanho do arquivo
  size_t len = 0;
  //tamanho da linha
  ssize_t read;
  //input dos sensores
  float elapse_time,emg;
  //matrix 
  emg_matrix = (float*) malloc(51000 * 6 * sizeof(float));
  int i = 0;
  //abre o arquivo para leitura
  fp = fopen("emg.csv", "r");

  //se não for possível abrir solta um erro
  if (fp == NULL)
    exit(EXIT_FAILURE);

  //lê cada linha do arquivo fp enquanto não chegar no final
  while ((read = getline(&line, &len, fp)) != -1) {
    //printf("Retrieved line of length %zu :\n", read);
    //printf("%s", line);

    sscanf(line, "%f,%f",&elapse_time,&emg);
    
    //passar o cabeçalho do CSV
    if (i > 1){
      //guarda as informações em uma matrix para ser usada posteriormente
      emg_matrix[i*6 +0] = elapse_time;
      emg_matrix[i*6 +1] = emg;
      emg_size = emg_size + 1;
    }
    
    i = i+1;
  }

  fclose(fp);

  if (line)
    free(line);
}

void read_vt_csv(){
  //ponteiro para o arquivo em memoria
  FILE * fp;
  //"string" da linha que foi lida
  char * line = NULL;
  //tamanho do arquivo
  size_t len = 0;
  //tamanho da linha
  ssize_t read;
  //input dos sensores
  float elapse_time,vt;
  //matrix 
  vt_matrix = (float*) malloc(4800 * 6 * sizeof(float));
  int i = 0;
  //abre o arquivo para leitura
  fp = fopen("vt.csv", "r");

  //se não for possível abrir solta um erro
  if (fp == NULL)
    exit(EXIT_FAILURE);

  //lê cada linha do arquivo fp enquanto não chegar no final
  while ((read = getline(&line, &len, fp)) != -1) {
    //printf("Retrieved line of length %zu :\n", read);
    //printf("%s", line);

    sscanf(line, "%f,%f",&elapse_time,&vt);
    
    //passar o cabeçalho do CSV
    if (i > 1253){
      //guarda as informações em uma matrix para ser usada posteriormente
      vt_matrix[i*6 +0] = elapse_time;
      vt_matrix[i*6 +1] = vt;
      vt_size = vt_size + 1;
    }
    
    i = i+1;
  }

  fclose(fp);

  if (line)
    free(line);
}