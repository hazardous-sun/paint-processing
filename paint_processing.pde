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

Freehand freehand = new Freehand(color(0));
Eraser eraser = new Eraser();

// Currently selected tool
Tool currentTool = shapes[0];

// For line drawing
boolean lineFirstClick = true;
int lineStartX, lineStartY;

// For triangle drawing
int trianglePointsSet = 0;
int[] triangleX = new int[3];
int[] triangleY = new int[3];

// List of all drawn shapes
ArrayList<Tool> drawnShapes = new ArrayList<Tool>();

void setup() {
    // Set window size
    size(1280, 720);
    surface.setResizable(true);

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
    
    // Draw all shapes
    for (Tool shape : drawnShapes) {
        if (shape instanceof Shape) {
            ((Shape)shape).display();
        } else if (shape instanceof Freehand) {
            ((Freehand)shape).display();
        }
    }
    
    // Draw current preview
    if (currentTool instanceof Shape) {
        ((Shape)currentTool).display();
    } else if (currentTool instanceof Freehand && ((Freehand)currentTool).isDrawing) {
        ((Freehand)currentTool).display();
    }
}

void mousePressed() {
    // Check if mouse is in a box
    if (mouseY < BOX_HEIGHT) {
        int boxIndex = (int)(mouseX / (width / float(NUM_BOXES)));
        if (boxIndex >= 0 && boxIndex < NUM_BOXES) {
            getBox(boxIndex);
        }
    } else {
        useTool();
    }
}

void getBox(int boxIndex) {
    switch (boxIndex) {
        case 0: // Square
            currentTool = shapes[0];
            lineFirstClick = true;
            trianglePointsSet = 0;
            break;
        case 1: // Triangle
            currentTool = shapes[1];
            lineFirstClick = true;
            trianglePointsSet = 0;
            break;
        case 2: // Line
            currentTool = shapes[2];
            lineFirstClick = true;
            trianglePointsSet = 0;
            break;
        case 3: // Freehand
            currentTool = freehand;
            lineFirstClick = true;
            trianglePointsSet = 0;
            break;
        case 4: // Eraser
            currentTool = eraser;
            lineFirstClick = true;
            trianglePointsSet = 0;
            break;
        case 5: // Configure
            break;
    }
}

void useTool() {
    switch (currentTool.getType()) {
        case "Square":
            Square square = new Square(mouseX, mouseY, 50, true, color(255, 0, 0), color(0));
            drawnShapes.add(square);
            break;
        case "Triangle":
            if (trianglePointsSet < 3) {
                triangleX[trianglePointsSet] = mouseX;
                triangleY[trianglePointsSet] = mouseY;
                trianglePointsSet++;
                
                if (trianglePointsSet == 3) {
                    Triangle triangle = new Triangle(
                        triangleX[0], triangleY[0],
                        triangleX[1], triangleY[1],
                        triangleX[2], triangleY[2],
                        true, color(0, 255, 0), color(0));
                    drawnShapes.add(triangle);
                    trianglePointsSet = 0;
                }
            }
            break;
        case "Line":
            if (lineFirstClick) {
                lineStartX = mouseX;
                lineStartY = mouseY;
                lineFirstClick = false;
            } else {
                Line line = new Line(lineStartX, lineStartY, mouseX, mouseY, color(0));
                drawnShapes.add(line);
                lineFirstClick = true;
            }
            break;
        case "Freehand":
            Freehand fh = (Freehand) currentTool;
            if (!fh.isDrawing) {
                fh.startDrawing(mouseX, mouseY);
            }
            break;
        case "Eraser":
            Eraser es = (Eraser) currentTool;
            if (!es.isDrawing) {
                es.startDrawing(mouseX, mouseY);
            }
            break;
    }
}

void mouseDragged() {
    if (mouseY >= BOX_HEIGHT) {
        switch (currentTool.getType()) {
            case "Freehand":
                ((Freehand) currentTool).addPoint(mouseX, mouseY);
                break;
            case "Eraser":
                ((Eraser) currentTool).addPoint(mouseX, mouseY);
                break;
        }
    }
}

void mouseReleased() {
    switch (currentTool.getType()) {
        case "Freehand":
            freehand.stopDrawing();
            drawnShapes.add(new Freehand(freehand));
            break;
        case "Eraser":
            eraser.stopDrawing();
            drawnShapes.add(new Eraser((Eraser)eraser));
            break;
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