// Box settings
String[] boxNames = {"Square", "Triangle", "Star", "Freehand", "Eraser", "Configure"};
final int NUM_BOXES = boxNames.length;
final int BOX_HEIGHT = 50;
color[] boxColors = new color[NUM_BOXES];
boolean[] boxHover = new boolean[NUM_BOXES];

void setup() {
    // Set window size
    size(1280, 720);

    // Initialize box colors with different shades of gray
    for (int i = 0; i < NUM_BOXES; i++) {
        boxColors[i] = color(50 + i * 30);
        boxHover[i] = false;
    }

    noStroke();
    textAlign(CENTER, CENTER);
}

void draw() {
    background(255);

    // Draw options boxes
    drawBoxes();
    
    // Draw canvas area
    drawCanvas();
}

void mousePressed() {
    // Check if mouse is in a box
    if (mouseY < BOX_HEIGHT) {
        int boxIndex = (int)(mouseX / (width / float(NUM_BOXES)));
        if (boxIndex >= 0 && boxIndex < NUM_BOXES) {
            println("Clicked:", boxNames[boxIndex]);
        }
    }
}

void drawBoxes() {
    stroke(0);
    strokeWeight(3);
    for (int i = 0; i < NUM_BOXES; i++) {
        float boxWidth = width / float(NUM_BOXES);
        float x = i * boxWidth;
        
        // Change color slightly when hovered
        if (boxHover[i]) {
            fill(getBrightness(boxColors[i]) > 128 ? boxColors[i] - 30 : boxColors[i] + 30);
        } else {
            fill(boxColors[i]);
        }
        
        rect(x, 0, boxWidth, BOX_HEIGHT);
        
        // Add label
        fill(getBrightness(boxColors[i]) > 128 ? 0 : 255);
        text(boxNames[i], x + boxWidth/2, BOX_HEIGHT/2);
    }
    noStroke();
}

void drawCanvas() {
    fill(255);
    rect(0, BOX_HEIGHT, width, height - BOX_HEIGHT);
}

void mouseMoved() {
    // Update hover states
    if (mouseY < BOX_HEIGHT) {
        for (int i = 0; i < NUM_BOXES; i++) {
            float boxWidth = width / float(NUM_BOXES);
            boxHover[i] = (mouseX >= i * boxWidth && mouseX < (i + 1) * boxWidth);
        }
    } else {
        for (int i = 0; i < NUM_BOXES; i++) {
            boxHover[i] = false;
        }
    }
}

float getBrightness(color c) {
    return (red(c) + green(c) + blue(c)) / 3.0;
}