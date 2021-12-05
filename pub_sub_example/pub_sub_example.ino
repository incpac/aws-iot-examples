#include "secrets.h"

#include <ArduinoJson.h>
#include <PubSubClient.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>

#include <Blynk.h> # included purely to use it's timer function

#define AWS_IOT_PUB_TOPIC "example/pub"
#define AWS_IOT_SUB_TOPIC "example/sub"

BlynkTimer timer;
WiFiClientSecure net = WiFiClientSecure();
PubSubClient client(net);


void connectToWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("[CORE] Connecting to WiFi ...");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println(" connected");
}

void connectToIOT() {
  Serial.print("[CORE] Connecting to AWS IOT ...");
  
  // configure wifi client to use the aws iot device credentials
  net.setCACert(AWS_CERT_CA);
  net.setCertificate(AWS_CERT_CRT);
  net.setPrivateKey(AWS_CERT_PRIVATE);

  // connect to the mqtt broker
  client.setServer(AWS_IOT_ENDPOINT, 8883);
  client.setCallback(messageHandler);

  bool res = client.connect(THING_NAME);
  while (!res) {
    Serial.print(res);
    delay(500);
    res = client.connect(THING_NAME);
  }

//  while (!client.connect(THING_NAME)) {
//    Serial.print(".");
//    delay(100);
//  }

  if (!client.connected()) {
    Serial.println(" connection failed");
    return;
  }

  client.subscribe(AWS_IOT_SUB_TOPIC);
  Serial.println(" connected");
}

void messageHandler(char* topic, byte* payload, unsigned int length) {
  Serial.print("[SUB] ");
  Serial.print(topic);
  Serial.print(": ");

  StaticJsonDocument<200> doc;
  deserializeJson(doc, payload); 
  serializeJson(doc, Serial);
  Serial.println();
}

void sendMessage() {
  StaticJsonDocument<200> doc;
  doc["message"] = "Hello World!";

  char jsonBuffer[512];
  serializeJson(doc, jsonBuffer);

  client.publish(AWS_IOT_PUB_TOPIC, jsonBuffer);
  Serial.print("[PUB] ");
  Serial.print(AWS_IOT_PUB_TOPIC);
  Serial.print(": ");
  Serial.println(jsonBuffer);
}

void setup() {
  Serial.begin(9600);
  
  connectToWiFi();
  connectToIOT();

  timer.setInterval(5000l, sendMessage);
}

void loop() {
  timer.run();
  client.loop();
}
