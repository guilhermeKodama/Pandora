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

#define REMOTE_SERVER_PORT 41181
#define MAX_MSG 100

/* variaveis globais*/
int sd, rc, i;
struct sockaddr_in serv; /* socket info about our server */
struct hostent *h;

//realiza conexão com o servidor
void server_connect(char *IP){

  /* get server IP address (no check if input is IP address or DNS name */
  h = gethostbyname(IP);
  if(h==NULL) {
    printf("unknown host '%s' \n",IP);
    exit(1);
  }

  printf("%s: sending data to '%s' (IP : %s) \n", IP, h->h_name,
	inet_ntoa(*(struct in_addr *)h->h_addr_list[0]));

  /*criando cabeçalho do DATAGRAMA(mensage UDP)
  tipo de mensagem: internet
  IP de destino
  PORTA de destino
  */

  serv.sin_family = h->h_addrtype;
  memcpy((char *) &serv.sin_addr.s_addr , h->h_addr_list[0] , h->h_length);
  serv.sin_port = htons(REMOTE_SERVER_PORT);

  /* socket creation */
  sd = socket(AF_INET,SOCK_DGRAM,0);
  if(sd<0) {
    printf("%s: cannot open socket \n",IP);
    exit(1);
  }

}

//envia pacotes UDP
void send_udp(char* message,int server_port){
  /* thread safety */
  static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
  /* trava assim só uma thread pode executar esse codigo de um vez*/
  pthread_mutex_lock(&mutex);

  serv.sin_port = htons(server_port);
  rc = sendto(sd,message, strlen(message), 0,(struct sockaddr *) &serv, 
  sizeof(serv));

  if(rc<0) {
    printf("cannot send data\n");
    close(sd);
    exit(1);
  }

  /* libera para uso de outras threads*/
  pthread_mutex_unlock(&mutex);
}