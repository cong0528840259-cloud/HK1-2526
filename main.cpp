#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <DHT.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Servo.h>

// --- CẤU HÌNH WIFI & FIREBASE ---
#define WIFI_SSID "Danh"
#define WIFI_PASSWORD "12345678"
#define FIREBASE_HOST "congiot-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "AIzaSyApIZAUr9mADtJ8ilavySzhgiPh_7oXriI"

// --- CHÂN KẾT NỐI ---
#define DHTPIN 4
#define DHTTYPE DHT22
#define LED_PIN 14  
#define FAN_PIN 12  
#define SERVO_PIN 25 

DHT dht(DHTPIN, DHTTYPE);
Servo myServo;
Adafruit_SSD1306 display(128, 64, &Wire, -1);
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Biến điều khiển
unsigned long prevDataMillis = 0;
unsigned long lastMoveTime = 0;
bool isAuto = false;
bool direction = false;
float thresholdLow = 37.0;
float thresholdHigh = 37.5;
bool lastAlarm = false;

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  
  // Khởi tạo OLED
  Wire.begin(21, 22);
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { Serial.println("OLED Fail"); }
  display.clearDisplay();
  display.setTextColor(WHITE);
  display.display();

  // Khởi tạo Servo
  ESP32PWM::allocateTimer(0);
  myServo.setPeriodHertz(50); 
  myServo.attach(SERVO_PIN, 500, 2400); 

  dht.begin();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
}

void loop() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  // 1. Cập nhật cảm biến lên Firebase (5s/lần)
  if (millis() - prevDataMillis > 5000) {
    prevDataMillis = millis();
    if (!isnan(h) && !isnan(t)) {
      Firebase.setFloat(fbdo, "/sensor/temperature", t);
      Firebase.setFloat(fbdo, "/sensor/humidity", h);
    }
  }

  // 2. Đồng bộ Cảnh báo (Loa mô phỏng)
  bool currentAlarm = (t > 38.5);
  if (currentAlarm != lastAlarm) {
    lastAlarm = currentAlarm;
    Firebase.setBool(fbdo, "/control/buzzer", lastAlarm);
  }

  // 3. Đọc dữ liệu điều khiển
  if (Firebase.get(fbdo, "/control")) {
    FirebaseJson &json = fbdo.jsonObject();
    FirebaseJsonData jsonData;

    if (json.get(jsonData, "tempLow")) thresholdLow = jsonData.floatValue;
    if (json.get(jsonData, "tempHigh")) thresholdHigh = jsonData.floatValue;
    if (json.get(jsonData, "isAuto")) isAuto = jsonData.boolValue;

    if (isAuto) {
      // --- CHẾ ĐỘ TỰ ĐỘNG ---
      if (t < thresholdLow) {
        digitalWrite(LED_PIN, HIGH);
        Firebase.setBool(fbdo, "/control/light", true);
      } else if (t > thresholdHigh) {
        digitalWrite(LED_PIN, LOW);
        Firebase.setBool(fbdo, "/control/light", false);
      }

      // Servo xoay 180 liên tục
      if (millis() - lastMoveTime > 3000) {
        lastMoveTime = millis();
        direction = !direction;
        myServo.write(direction ? 180 : 0);
        Firebase.setBool(fbdo, "/control/servo", direction);
      }
    } else {
      // --- CHẾ ĐỘ TAY ---
      if (json.get(jsonData, "light")) digitalWrite(LED_PIN, jsonData.boolValue);
      if (json.get(jsonData, "fan")) digitalWrite(FAN_PIN, jsonData.boolValue);
      if (json.get(jsonData, "servo")) {
          if (jsonData.boolValue) {
              if (millis() - lastMoveTime > 2000) {
                  lastMoveTime = millis();
                  direction = !direction;
                  myServo.write(direction ? 180 : 0);
              }
          } else { myServo.write(0); }
      }
    }
  }

  // 4. Hiển thị OLED
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0,0);
  display.printf("L:%.1f H:%.1f", thresholdLow, thresholdHigh);
  display.setCursor(0,12);
  display.print(isAuto ? "MODE: AUTO" : "MODE: MANUAL");
  display.setTextSize(2);
  display.setCursor(0, 30); display.printf("%.1f C", t);
  display.setCursor(0, 50); display.printf("%.0f %%", h);
  display.display();
  
  delay(100);
}