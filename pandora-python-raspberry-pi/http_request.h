#include <curl/curl.h>

/*POST REQUEST*/
void http_post(char *URL, char *message, void *listener){
	CURL *hnd = curl_easy_init();

	curl_easy_setopt(hnd, CURLOPT_CUSTOMREQUEST, "POST");

	curl_easy_setopt(hnd, CURLOPT_URL, URL);

	struct curl_slist *headers = NULL;
	headers = curl_slist_append(headers, "cache-control: no-cache");
	headers = curl_slist_append(headers, "content-type: application/json");

	/*insere o cabeçalho HTTP*/
	curl_easy_setopt(hnd, CURLOPT_HTTPHEADER, headers);

	/*função que sera chamada para escrever o resultado*/
	curl_easy_setopt(hnd, CURLOPT_WRITEFUNCTION, listener);

	/*colocar a mensagem a ser enviada*/
	curl_easy_setopt(hnd, CURLOPT_POSTFIELDS, message);

	/*realiza o envio da requisição*/
	curl_easy_perform(hnd);
	// CURLcode ret = curl_easy_perform(hnd);
	// printf("RESPONSE : %u\n",ret);
}