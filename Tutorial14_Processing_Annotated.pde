// Start Arduino code, then run this, it will print the port name to which your 
// Arduino is connected, change line 28 (portName) accordingly
import processing.serial.*;

int n = 1000;  // Number of particles

// Arrays to store particle properties
float[] m = new float[n];             // Mass (affects movement force)
float[] x = new float[n];             // X position
float[] y = new float[n];             // Y position
float[] vx = new float[n];            // X velocity
float[] vy = new float[n];            // Y velocity
float[] redchannel = new float[n];    // Red color channel
float[] bluechannel = new float[n];   // Blue color channel
float[] greenchannel = new float[n];  // Green color channel
float[] shape = new float[n];         // Shape type (controls shape and size)

Serial myPort;     // Serial port for Arduino
String val = "";   // Input string from serial
int sensorVal = 0; // Parsed sensor value from Arduino

void setup() {
  size(1280, 720);  // Set window size (instead of fullScreen)
  fill(0, 10);      // Initial background fill color
  reset();          // Initialize all particle values

  // Print available serial ports to console
  printArray(Serial.list());

  // Select the first available port (change index if needed)
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);  // Open serial port at 9600 baud
}

void draw() {
  // Read sensor value from Arduino (if available)
  if (myPort.available() > 0) {
    val = myPort.readStringUntil('\n');  // Read until newline
    if (val != null) {
      try {
        sensorVal = Integer.parseInt(val.trim());  // Convert string to int
      } catch (Exception e) {
        println("Invalid input: " + val);  // Print error if parsing fails
      }
    }
  }

  // Fading background to create motion trail effect
  noStroke();
  fill(0, 30);  // Semi-transparent black
  rect(0, 0, width, height);  // Cover screen with fade layer

  // Map sensor value (0–255) to vertical screen coordinate
  float sensorMappedY = map(sensorVal, 0, 255, 0, height);

  // Calculate forces and update velocities for each particle
  for (int i = 0; i < n; i++) {
    float dx = mouseX - x[i];              // Distance from mouse in X
    float dy = sensorMappedY - y[i];       // Distance from sensor-mapped Y
    float d = sqrt(dx * dx + dy * dy);     // Euclidean distance
    if (d < 1) d = 1;                      // Prevent divide-by-zero

    float f = cos(d * 0.06) * m[i] / d * 2;  // Force magnitude (oscillating)

    // Apply force with damping to velocity
    vx[i] = vx[i] * 0.4 - f * dx;
    vy[i] = vy[i] * 0.2 - f * dy;
  }

  // Update positions and draw particles
  for (int i = 0; i < n; i++) {
    x[i] += vx[i];  // Update X position
    y[i] += vy[i];  // Update Y position

    // Screen wrapping for X
    if (x[i] < 0) x[i] = width;
    else if (x[i] > width) x[i] = 0;

    // Screen wrapping for Y
    if (y[i] < 0) y[i] = height;
    else if (y[i] > height) y[i] = 0;

    // Set fill color based on shape
    if (shape[i] > 2) fill(bluechannel[i], greenchannel[i], 255);        // Mostly blue
    else fill(255, bluechannel[i], redchannel[i]);                      // White-tinted

    // Draw shape based on shape value
    if (shape[i] > 2) rect(x[i], y[i], 10, 10);               // Large square
    else if (shape[i] > 1 && shape[i] <= 2) rect(x[i], y[i], 2, 2);  // Small square
    else ellipse(x[i], y[i], 10, 10);                         // Circle
  }
}

void reset() {
  // Initialize all particle properties
  for (int i = 0; i < n; i++) {
    m[i] = randomGaussian() * 8;       // Mass from Gaussian distribution
    x[i] = random(width);              // Random X position
    y[i] = random(height);             // Random Y position
    bluechannel[i] = random(255);      // Random blue value
    redchannel[i] = random(255);       // Random red value
    greenchannel[i] = random(255);     // Random green value
    shape[i] = random(0, 3);           // Random shape type (0 to 3)
  }
}

void mousePressed() {
  reset();  // Reset particles on mouse click
}
