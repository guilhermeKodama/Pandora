#ifndef HEADER_H
#define HEADER_H

/* FLAG PARA DETERMINAR SE ENVIAR TACHYCARDIA OU NAO */
int VT = 0;

/* portas para envio do streamming */
int ECG_PORT;
int SPO2_PORT;
int AIRFLOW_PORT;
int EMG_PORT;
int TEMPERATURE_PORT;
int BLOOD_PRESSURE_PORT;
int PATIENT_POSITION_PORT;

/* velocidade do streamming (microsegundos)
 (microsegundos) 1000 = 1 (milisegundo)
 (microsegundos) 10000 = 10 (milisegundos)
 (microsegundos) 1000000 = 1 (segundo)
*/

/** trocar aqui **/
#define VT_SPEED 4000
#define ECG_SPEED 10000
#define SPO2_SPEED 500000
#define AIRFLOW_SPEED 10000
#define EMG_SPEED 10000
#define TEMPERATURE_SPEED 5000000
#define BLOOD_PRESSURE_SPEED 5000000
#define PATIENT_POSITION_SPEED 500000

/* samples por segundo de cada dataset para podermos enviar
   as informações corretas de acordo com a velocidades  que escolhemos
*/
#define APNEA_SAMPLES_PER_SECOND 100
#define EMG_SAMPLES_PER_SECOND 1000
#define VT_SAMPLES_PER_SECOND 250

#include "eHealth.h"

/* função para gerar floats randomicos*/
float random_float(float min, float max) {
  float random = ((float) rand()) / (float) RAND_MAX;
  float diff = max - min;
  float r = random * diff;
  return min + r;
}

int random_int(int min , int max){
  return rand () % (max - min + 1) + min;
}

/* numero de threads , os ids são armazenados nesse array */
pthread_t tid[7];

void* send_ecg(void* arg){

  /** trocar aqui **/
  int data_speed;
  if(VT){
    data_speed = (int) ( ECG_SPEED / VT_SAMPLES_PER_SECOND );
  }else{
    data_speed = (int) ( ECG_SPEED / APNEA_SAMPLES_PER_SECOND );
  }
  
  int column = 1;
  int row = 2;
  char message[100];
  //sending data
  while(1){

    /** trocar aqui **/
    if(VT){
      sprintf(message , "%.2f", vt_matrix[ (row * 6) + column ]);
    }else{
      sprintf(message , "%.2f", apnea_matrix[ (row * 6) + column ]);
    }
    // printf("ECG_PORT : %d\n",ECG_PORT);
    send_udp(message,ECG_PORT);

    if(VT){
      usleep(VT_SPEED);
    }else{
      usleep(ECG_SPEED);
    }

    /* velocidade que ele vai percorrer os dados */
    //row = row + data_speed;
    row = row + 1;

    //loop na matrix

    /** trocar aqui **/
    if(VT){
      if(vt_size < row){
        row = 2;
      }
    }else{
      if(apnea_size < row){
        row = 2;
      }
    }

  }
  return NULL;
}

int cont = 0;
void readPulsioximeter(){  
  cont ++;
  if (cont == 50) { //Get only of one 50 measures to reduce the latency
    eHealth.readPulsioximeter();  
    cont = 0;
  }
}

void setupPulsioximeter() {
  eHealth.initPulsioximeter();
  attachInterrupt(6, readPulsioximeter, RISING);
}

void setupPatientPosition() {
  eHealth.initPositionSensor();
}

void* send_spo2(void* arg){

  char message[100];

  while(1) {
    printf("BPM : %d", eHealth.getBPM()); 
    printf("    %%SPo2 : %d\n", eHealth.getOxygenSaturation());
    printf("=============================\n");

    sprintf(message, "%d", eHealth.getOxygenSaturation());
    send_udp(message, SPO2_PORT);

    usleep(SPO2_SPEED);
  }

  return NULL;
}

void* send_airflow(void* arg){
  
  int data_speed = (int) ( AIRFLOW_SPEED / APNEA_SAMPLES_PER_SECOND );
  int column = 3;
  int row = 2;
  char message[100];

  //sending data
  while(1){
    sprintf(message , "%.2f", apnea_matrix[ (row * 6) + column ]);

    send_udp(message,AIRFLOW_PORT);

    usleep(AIRFLOW_SPEED);

    /* velocidade que ele vai percorrer os dados */
    //row = row + data_speed;
    row = row + 1;

    //loop na matrix
    if(apnea_size < row){
      row = 2;
    }
  }

  return NULL;
}

//envia informação do dataset do EMG
void* send_emg(void* arg){

  int column = 1;
  int row = 2;

  int data_speed = (int) ( EMG_SPEED / EMG_SAMPLES_PER_SECOND );
  char message[100];

  //sending data
  while(1){
    
    sprintf(message , "%.2f", emg_matrix[ (row * 6) + column ]);

    send_udp(message,EMG_PORT);
    usleep(EMG_SPEED);

    /* velocidade que ele vai percorrer os dados */
    //row = row + data_speed;
    row = row + 1;

    //loop na matrix
    if(emg_size < row){
      row = 2;
    }
  }

  return NULL;
}

//envia informação da temperatura
void* send_temperature(void* arg){

  char message[100];

  while(1) {
    sprintf(message, "%.2f", eHealth.getTemperature());
    send_udp(message, TEMPERATURE_PORT);
    usleep(TEMPERATURE_SPEED);
  }

  return NULL;
}

//envia informação do blood pressure
void* send_blood_pressure(void* arg){
  
  char message[100];
  //sending data
  while(1){
    int systolic = random_int(90,120);
    int dyastolic = random_int(60,80);
    sprintf(message , "%d,%d",systolic,dyastolic);
    send_udp(message,BLOOD_PRESSURE_PORT);
    usleep(BLOOD_PRESSURE_SPEED);
  }

  return NULL;
}

//envia informação do blood pressure
void* send_patient_position(void* arg){
  
  char message[100];
  //sending data
  while(1){
    // int position = random_int(1,5);
    int position = eHealth.getBodyPosition();
    sprintf(message , "%d",position);
    send_udp(message,PATIENT_POSITION_PORT);
    usleep(PATIENT_POSITION_SPEED);
  }

  return NULL;
}


void init_threads(){
  int i = 0;
  int err;

  /* criando thread do ECG */
  pthread_create(&(tid[0]), NULL, &send_ecg, NULL);

  /* criando thread do SPO2 */
  setupPulsioximeter();
  pthread_create(&(tid[1]), NULL, &send_spo2, NULL);

  /* criando thread do AIRFLOW */
  pthread_create(&(tid[2]), NULL, &send_airflow, NULL);

  /* criando thread do EMG */
  pthread_create(&(tid[3]), NULL, &send_emg, NULL);

  /* criando thread do TEMPERATURE */
  pthread_create(&(tid[4]), NULL, &send_temperature, NULL);

  /* criando thread do BLOOD PRESSURE */
  pthread_create(&(tid[5]), NULL, &send_blood_pressure, NULL);

  /* criando thread do PATIENT POSITION */
  setupPatientPosition();
  pthread_create(&(tid[6]), NULL, &send_patient_position, NULL);

}

/* iniciliza as portas para o streamming de acordo com a resposta do servidor */
void set_ports_to_streamming(void *ptr,size_t nmemb){

  char *ptrChar = (char*) ptr;
    int i,j,pos;

    char key[25];
    char value[5];


    printf("PTR : %s , NMEMB : %zu \n",ptr,nmemb);

    for(i=0;i<nmemb-1;i++){
      

      //pega as chaves
      if(ptrChar[i] == '"' && ptrChar[i+1] != ':'){
        j = i+1;
        pos = 0;

        /* reinicia a variable para guardar novos valores*/
        memset(&key[0], 0, sizeof(key));

        while(ptrChar[j] != '"'){       
          key[pos] = ptrChar[j];
          j++;
          pos++;
        }
        key[pos+1] = '\0';
      }


      //pega os valores
      if(ptrChar[i] == '"' && ptrChar[i+1] == ':'){
        j = i+2;
        pos = 0;

        /* reinicia a variable para guardar novos valores*/
        memset(&value[0], 0, sizeof(value));

        while(ptrChar[j] != ',' && ptrChar[j] != '}' ){
          value[pos] = ptrChar[j];
          j++;
          pos++;
        }

        if(strcmp(key,"ECG_IN") == 0){
          ECG_PORT = atoi(value);
        }else if(strcmp(key,"SPO2_IN") == 0){
          SPO2_PORT = atoi(value);
        }else if(strcmp(key,"AIRFLOW_IN") == 0){
          AIRFLOW_PORT = atoi(value);
        }else if(strcmp(key,"EMG_IN") == 0){
          EMG_PORT = atoi(value);
        }else if(strcmp(key,"TEMPERATURE_IN") == 0){
          TEMPERATURE_PORT = atoi(value);
        }else if(strcmp(key,"BLOODPRESSURE_IN") == 0){
          BLOOD_PRESSURE_PORT = atoi(value);
        }else if(strcmp(key,"PATIENTPOSITION_IN") == 0){
          PATIENT_POSITION_PORT = atoi(value);
        }

      }
    }
}
#endif