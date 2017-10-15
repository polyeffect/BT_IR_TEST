#include <SoftwareSerial.h>
#include <IRremote.h>

// PIN Setting
const int RX_PIN = 10;
const int TX_PIN = 11;
const int RECV_PIN = 9;
const int BTN_PIN = 12;
const int LED_PIN = 13;
const int BUFFER_SIZE = 128;

SoftwareSerial BTSerial(RX_PIN, TX_PIN); //RX|TX
IRsend irsend;

String incomingData;
char data;
char packetBuffer[BUFFER_SIZE];
uint8_t ReplyBuffer = 1;
int index = 0;
int buttonState = 0;;
boolean isOn = false;

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;

void setup() {
  Serial.begin(9600);
  while (!Serial); //if it is an Arduino Micro
  BTSerial.begin(9600); // default baud rate 9600
  pinMode(BTN_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  Serial.println("AT commands: ");
}

void loop() {
  Serial.flush();
  buttonState = digitalRead(BTN_PIN);

//  while (!BTSerial.available());
  while (BTSerial.available()) {
    data = (char)BTSerial.read();

    if (data == '\n' || data == '\r' || data == '\0' || data == 0) {
      String str(packetBuffer);
      Serial.println("end PACKET: " + str);
      if (str == "on") {
        isIROn();
      }
      if (str == "ledon") {
        digitalWrite(LED_PIN, HIGH);
      }
      if (str == "ledoff") {
        digitalWrite(LED_PIN, LOW);
      }
      for (int i = 0; i < BUFFER_SIZE; i++) packetBuffer[i] = 0;
      index = 0;
    } else {
      packetBuffer[index++] = data;
    }
    delay(1);
  }

//  if (buttonState == HIGH) {
//    digitalWrite(LED_PIN, HIGH);
//    //    isIROn();
//  } else {
//    digitalWrite(LED_PIN, LOW);
//  }



  /*
    //read from the HM-10 and print in the Serial
    if (BTSerial.available())
    Serial.write(BTSerial.read());
  */
  //read from the Serial and print to the HM-10
  if (Serial.available())
    BTSerial.write(Serial.read());
}

void isIROn() {
  if (!isOn) {
    isOn = true;
    for (int i = 0; i < random(3, 10) ; i++) {
      irsend.sendLG(0x8800347, 28);
    }
  } else {
    isOn = false;
    for (int i = 0; i < random(3, 10) ; i++) {
      irsend.sendLG(0x88C0051, 28);
    }
  }
}
