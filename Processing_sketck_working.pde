// Start Arduino code, then run this, it will print the port name to which your 
// Arduino is connected, change line 28 (portName) accordingly
import processing.serial.*;

int n = 1000;

float[] m = new float[n];
float[] x = new float[n];
float[] y = new float[n];
float[] vx = new float[n];
float[] vy = new float[n];
float[] redchannel = new float[n];
float[] bluechannel = new float[n];
float[] greenchannel = new float[n];
float[] shape = new float[n];

Serial myPort;
String val = "";
int sensorVal = 0;

void setup() {
  size(1280, 720);  // Safe windowed mode (instead of fullScreen)
  fill(0, 10);
  reset();

  // Print available ports
  printArray(Serial.list());
  String portName = Serial.list()[0];  // Adjust port index as needed
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  if (myPort.available() > 0) {
    val = myPort.readStringUntil('\n');
    if (val != null) {
      try {
        sensorVal = Integer.parseInt(val.trim());
      } catch (Exception e) {
        println("Invalid input: " + val);
      }
    }
  }

  noStroke();
  fill(0, 30);
  rect(0, 0, width, height);

  float sensorMappedY = map(sensorVal, 0, 255, 0, height);

  for (int i = 0; i < n; i++) {
    float dx = mouseX - x[i];              // horizontal control from mouse
    float dy = sensorMappedY - y[i];       // vertical control from ultrasonic

    float d = sqrt(dx * dx + dy * dy);
    if (d < 1) d = 1;

    float f = cos(d * 0.06) * m[i] / d * 2;

    vx[i] = vx[i] * 0.4 - f * dx;
    vy[i] = vy[i] * 0.2 - f * dy;
  }

  for (int i = 0; i < n; i++) {
    x[i] += vx[i];
    y[i] += vy[i];

    if (x[i] < 0) x[i] = width;
    else if (x[i] > width) x[i] = 0;

    if (y[i] < 0) y[i] = height;
    else if (y[i] > height) y[i] = 0;

    if (shape[i] > 2) fill(bluechannel[i], greenchannel[i], 255);
    else fill(255, bluechannel[i], redchannel[i]);

    if (shape[i] > 2) rect(x[i], y[i], 10, 10);
    else if (shape[i] > 1 && shape[i] <= 2) rect(x[i], y[i], 2, 2);
    else ellipse(x[i], y[i], 10, 10);
  }
}

void reset() {
  for (int i = 0; i < n; i++) {
    m[i] = randomGaussian() * 8;
    x[i] = random(width);
    y[i] = random(height);
    bluechannel[i] = random(255);
    redchannel[i] = random(255);
    greenchannel[i] = random(255);
    shape[i] = random(0, 3);
  }
}

void mousePressed() {
  reset();
}
