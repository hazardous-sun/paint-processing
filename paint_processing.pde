// Box settings
String[] boxNames = {"Square", "Triangle", "Line", "Freehand", "Eraser", "Configure"};
final int NUM_BOXES = boxNames.length;
final int BOX_HEIGHT = 50;
color[] boxColors = new color[NUM_BOXES];
boolean[] boxHover = new boolean[NUM_BOXES];

// Shapes to be drawn
Shape[] shapes = {
    new Square(0, 0, 5, false, color(255), color(0)),
    new Triangle(0, 0, 0, 0, 0, 0, false, color(255), color(0)),
    new Line(0, 0, 0, 0, color(0))
};

// Curretly selected tool
Shape currentTool = shapes[0];

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
            switch (boxIndex) {
                case 0: // Square
                    currentTool = shapes[0];
                    break;
                case 1: // Triangle
                    currentTool = shapes[1];
                    break;
                case 2: // Line
                    currentTool = shapes[2];
                    break;
                case 3: // Freehand
                    break;
                case 4: // Eraser
                    break;
                case 5: // Configure
                    break;
                
            }
        } else {
            switch (currentTool.getType()) {
                case "Square":
                    // Set position of the square to mouse position and draw it
                    break;
                case "Triangle":
                    // Set position of the triangle to mouse position and draw it
                    break;
                case "Line":
                    // Set position of the line to mouse position and draw it
                    // It should require 2 clicks to set start and end points
                    break;
                case "Freehand":
                    // Draw freehand lines
                    break;
                case "Eraser":
                    // Similar to freehand but with the same color as the background
                    break;
            }
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