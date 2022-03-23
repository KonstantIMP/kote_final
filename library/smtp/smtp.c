#include "smtp.h"

#include <curl/curl.h>
#include <curl/easy.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define HEADER_SIZE 1024

void get_time(char * buf) {
    time_t tm = time(NULL); char * time_str = ctime(&tm);

    memcpy(buf, time_str, 3);      buf += 3;
    memcpy(buf, ", ", 2);          buf += 2;
    memcpy(buf, time_str + 11, 2); buf += 2;

    if ((buf - 1)[0] != ' ') { buf[0] = ' '; buf++; }

    memcpy(buf, time_str +  4, 3); buf += 3; buf[0] = ' '; buf++;
    memcpy(buf, time_str + 20, 4); buf += 4; buf[0] = ' '; buf++;
    memcpy(buf, time_str + 11, 8); buf += 8;
}

void gen_id(char * buf) {
    char time_str[64]; memset(time_str, 0, 64); get_time(time_str);

    for (size_t i = 0; i < strlen(time_str); i++) {
        if (time_str[i] != ' ' && time_str[i] != ',' && time_str[i] != ':'){
            buf[0] = time_str[i]; buf++;
        }
    }

    memcpy(buf, "jopa@zosima.com", 15);
}

int send_email(const char * to, const char * sbj, const char * text, const char * attach) {
    char * header_str = (char *)malloc(HEADER_SIZE); memset(header_str, 0, HEADER_SIZE);
    char * start = header_str;

    memcpy(header_str, "Date: ", 6); header_str += 6; get_time(header_str);
    header_str = header_str + strlen(header_str);
    memcpy(header_str, "\r\n", 2); header_str += 2;
    
    memcpy(header_str, "To: <", 5); header_str += 5; memcpy(header_str, to, strlen(to));
    header_str = header_str + strlen(header_str);
    memcpy(header_str, ">\r\n", 3); header_str += 3;

    memcpy(header_str, "From: KOTE <kote_nto@mail.ru>\r\n", 31); header_str += 31;

    memcpy(header_str, "Message-ID: <", 13); header_str += 13; gen_id(header_str);
    header_str = header_str + strlen(header_str);
    memcpy(header_str, ">\r\n", 3); header_str += 3;

    memcpy(header_str, "Subject: ", 9); header_str += 9; memcpy(header_str, sbj, strlen(sbj));
    header_str = header_str + strlen(header_str);
    memcpy(header_str, "\r\n", 2); header_str += 2;

    header_str = start;

    CURL * email_msg = curl_easy_init();

    if (!email_msg) return -1;

    curl_mimepart * part = NULL;

    struct curl_slist * header = NULL;
    struct curl_slist * slist = NULL;
    struct curl_slist * rec = NULL;

    curl_mime * mime = NULL;
    curl_mime * alt = NULL;

    CURLcode err = CURLE_OK;

    curl_easy_setopt(email_msg, CURLOPT_USERNAME, "mihedovkos@gmail.com");//"konstantimp@vk.com");
    curl_easy_setopt(email_msg, CURLOPT_PASSWORD, "afgwuzlateaowski");
    //curl_easy_setopt(email_msg, CURLOPT_USERNAME, "kote_nto@mail.ru");//"konstantimp@vk.com");
    //curl_easy_setopt(email_msg, CURLOPT_PASSWORD, "VSfqqPVAmb3Dfra1zQHT");
    //curl_easy_setopt(email_msg, CURLOPT_USERNAME, "Kuzka30z");
    //curl_easy_setopt(email_msg, CURLOPT_PASSWORD, "jwaiiaeruirprwtl");

    curl_easy_setopt(email_msg, CURLOPT_URL, "smtps://smtp.gmail.com");//"smtps://smtp.yandex.ru");

    #ifdef  SKIP_PEER_VERIFICATION
        curl_easy_setopt(mail_message, CURLOPT_SSL_VERIFYPEER , 0L);
    #endif

    #ifdef  SKIP_HOSTNAME_VERIFICATION
        curl_easy_setopt(mail_message, CURLOPT_SSL_VERIFYHOST , 0L);
    #endif

    curl_easy_setopt(email_msg, CURLOPT_MAIL_FROM, "mihedovkos@gmail.com");

    char to_email [256]; memset(to_email, 0, 256);
    to_email[0] = '<'; memcpy(to_email, to, strlen(to));
    to_email[strlen(to_email)] = '>';

    rec = curl_slist_append(rec, to_email);
    curl_easy_setopt(email_msg, CURLOPT_MAIL_RCPT, rec);

    for(size_t i = 0; i < strlen(header_str); i++) header = curl_slist_append(header, header_str + i);
    curl_easy_setopt(email_msg, CURLOPT_HTTPHEADER, header);

    mime = curl_mime_init(email_msg);
    alt = curl_mime_init(email_msg);

    part = curl_mime_addpart(alt);
    curl_mime_data(part, text, CURL_ZERO_TERMINATED);

    part = curl_mime_addpart(mime);
    curl_mime_subparts(part, alt);
    //curl_mime_encoder(part, "base64");
    curl_mime_type(part, "multipart/alternative");

    slist = curl_slist_append(slist, "Content-Disposition: inline");
    curl_mime_headers(part, header, 1);

    if (attach != NULL) {
        part = curl_mime_addpart(mime);
        curl_mime_encoder(part, "base64");
        curl_mime_filedata(part, attach);
    } curl_easy_setopt(email_msg, CURLOPT_MIMEPOST, mime);

    curl_easy_setopt(email_msg, CURLOPT_VERBOSE, 1L);

    err = curl_easy_perform(email_msg);

    curl_slist_free_all(rec);
    curl_slist_free_all(header);

    curl_easy_cleanup(email_msg);

    free(header_str);

    return err == CURLE_OK ? 0 : -1;
}


