/*gcc gcc -l curl main.c -o main*/
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h> /* memset() */
#include <sys/time.h> /* select() */ 
#include <pthread.h> /*thread*/
#include "upload_file.h" /*metodos de fazer upload dos datasets*/
#include "socket_udp.h" /*metodos para fazer conexão UDP*/
#include "sensor_service.h" /*metodos que disparam as threads para envio da informação dos sensores*/
#include "http_request.h" /*metodos para realizar requisições HTTP para o servidor para fins de configuração*/

char *IP;
char device_id[10];

void init_streamming(){

  printf("=====PI SERVICE======\n");
  printf("Carregando SERVIDOR UDP\n");
  //realiza conexão com o servidor
  server_connect(IP);
  //lê os datasets e carrega na memoria
  printf("Carregando APNEA\n");
  read_apnea_csv();
  printf("Carregando EMG\n");
  read_emg_csv();
  printf("Carregando VT\n");
  read_vt_csv();

  printf("Vou iniciar as threads\n");
  //inicia as threads dos sensores para enviar informação
  init_threads();
  //segura a main thread para permanecer em pé enquanto as threads dos sensores estão em pé
  pthread_join(tid[0], NULL);
}


void on_response(void *ptr, size_t size, size_t nmemb, void *stream){
  /*seta as portas retornados pelo servidor para enviarmos o streamming*/
  set_ports_to_streamming(ptr,nmemb);

  /*inicia o streamming*/
  init_streamming(); 
}


int main(int argc, char *argv[]) {
  /* inicializando a variável que guarda o IP do servidor*/
  IP = (char*)malloc(12*sizeof(char));

  /* refresh no time */
  srand((unsigned int)time(NULL));

  /* check command line args */
  if(argc<4) {
    printf("usage : %s <server_ip> <0 or 1> <device_id>\n", argv[0]);
    exit(1);
  }

  /* pega o parametro enviado na execução para enviar ou não tachycardia */
  sscanf (argv[1],"%s",IP);
  sscanf (argv[2],"%d",&VT);
  sscanf (argv[3],"%s",device_id);

  printf("IP : %s\n",IP);

  // "http://10.0.0.102:8000/device/connection/create"
  char *URL = (char*)malloc(50*sizeof(char));
  strcpy(URL,"http://");
  strcat(URL, IP);
  strcat(URL,":8000/device/connection/create");

  char *message = (char*)malloc(50*sizeof(char));
  strcpy(message, "{\"device_id\":");
  strcat(message, device_id);
  strcat(message, "}");
  
  /* pega informações com o servidor para iniciar o streamming */
  http_post(URL, message, (void*)on_response);

  return 1;

}