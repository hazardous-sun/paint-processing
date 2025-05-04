import processing.awt.PSurfaceAWT;
import javax.swing.*;

// Tool configuration variables
boolean showConfigPanel = false;
float fillR = 0, fillG = 0, fillB = 0;
float strokeR = 0, strokeG = 0, strokeB = 0;
boolean filled = true;
int sizeValue = 50;
int configPanelHeight = 100;

// Box settings
String[] boxNames = {"Square", "Triangle", "Line", "Freehand", "Eraser", "Configure"};
final int NUM_BOXES = boxNames.length;
final int BOX_HEIGHT = 50;
color[] boxColors = new color[NUM_BOXES];
boolean[] boxHover = new boolean[NUM_BOXES];

// Shapes to be drawn
Shape[] shapes = {
    new Square(0, 0, 50, false, color(255), color(0)),
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
    size(1280, 720);
    surface.setResizable(true);

    // Initialize box colors with different shades of gray
    for (int i = 0; i < NUM_BOXES; i++) {
        boxColors[i] = color(50 + i * 30);
        boxHover[i] = false;
    }

    // Initialize config values
    if (currentTool instanceof Shape) {
        Shape shape = (Shape)currentTool;
        fillR = red(shape.innerColor);
        fillG = green(shape.innerColor);
        fillB = blue(shape.innerColor);
        strokeR = red(shape.strokeColor);
        strokeG = green(shape.strokeColor);
        strokeB = blue(shape.strokeColor);
        filled = shape.filled;
    }

    noStroke();
    textAlign(CENTER, CENTER);
}

void draw() {
    background(255);
    
    // Draw options boxes
    drawBoxes();
    
    // Draw config panel if needed
    drawConfigPanel();
    
    // Draw canvas area (adjust for config panel height)
    float canvasTop = BOX_HEIGHT + (showConfigPanel ? configPanelHeight : 0);
    fill(255);
    rect(0, canvasTop, width, height - canvasTop);
    
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
    } 
    // Check if mouse is in config panel
    else if (showConfigPanel && mouseY < BOX_HEIGHT + configPanelHeight) {
        // Let config panel handle the click
        return;
    }
    // Otherwise use the tool
    else {
        useTool();
    }
}

void getBox(int boxIndex) {
    switch (boxIndex) {
        case 0: // Square
            currentTool = shapes[0];
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = true;
            break;
        case 1: // Triangle
            currentTool = shapes[1];
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = true;
            break;
        case 2: // Line
            currentTool = shapes[2];
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = true;
            break;
        case 3: // Freehand
            currentTool = freehand;
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = false;
            break;
        case 4: // Eraser
            currentTool = eraser;
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = false;
            break;
        case 5: // Configure (toggle panel for supported tools)
            if (currentTool instanceof Shape) {
                showConfigPanel = !showConfigPanel;
            }
            break;
    }
    
    // Update config values when switching tools
    if (currentTool instanceof Shape) {
        Shape shape = (Shape)currentTool;
        fillR = red(shape.innerColor);
        fillG = green(shape.innerColor);
        fillB = blue(shape.innerColor);
        strokeR = red(shape.strokeColor);
        strokeG = green(shape.strokeColor);
        strokeB = blue(shape.strokeColor);
        filled = shape.filled;
        
        if (currentTool instanceof Square) {
            sizeValue = ((Square)currentTool).size;
        }
    }
}

void useTool() {
    switch (currentTool.getType()) {
        case "Square":
            Square square = new Square(mouseX, mouseY, sizeValue, filled, color(fillR, fillG, fillB), color(strokeR, strokeG, strokeB));
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
                        filled, color(fillR, fillG, fillB), color(strokeR, strokeG, strokeB));
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
                Line line = new Line(lineStartX, lineStartY, mouseX, mouseY, color(strokeR, strokeG, strokeB));
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
    if (mouseY >= BOX_HEIGHT + (showConfigPanel ? configPanelHeight : 0)) {
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

void drawConfigPanel() {
    if (!showConfigPanel) return;
    
    fill(220);
    stroke(150);
    rect(0, BOX_HEIGHT, width, configPanelHeight);
    
    fill(0);
    textAlign(LEFT, TOP);
    text("Fill Color (R,G,B):", 20, BOX_HEIGHT + 10);
    text("Stroke Color (R,G,B):", 20, BOX_HEIGHT + 40);
    
    // Fill color inputs
    fillR = numberInput(180, BOX_HEIGHT + 10, fillR, 0, 255);
    fillG = numberInput(230, BOX_HEIGHT + 10, fillG, 0, 255);
    fillB = numberInput(280, BOX_HEIGHT + 10, fillB, 0, 255);
    
    // Stroke color inputs
    strokeR = numberInput(180, BOX_HEIGHT + 40, strokeR, 0, 255);
    strokeG = numberInput(230, BOX_HEIGHT + 40, strokeG, 0, 255);
    strokeB = numberInput(280, BOX_HEIGHT + 40, strokeB, 0, 255);
    
    // Filled checkbox
    filled = checkbox(350, BOX_HEIGHT + 10, "Filled", filled);
    
    // Size slider (only for Square)
    if (currentTool instanceof Square) {
        text("Size:", 350, BOX_HEIGHT + 40);
        sizeValue = (int)slider(400, BOX_HEIGHT + 40, sizeValue, 10, 200);
    }
    
    // Update the current tool's properties
    if (currentTool instanceof Shape) {
        Shape shape = (Shape)currentTool;
        shape.innerColor = color(fillR, fillG, fillB);
        shape.strokeColor = color(strokeR, strokeG, strokeB);
        shape.filled = filled;
        
        if (currentTool instanceof Square) {
            ((Square)currentTool).size = sizeValue;
        }
    }
}

float numberInput(float x, float y, float value, float min, float max) {
    fill(255);
    stroke(0);
    rect(x, y, 40, 20);
    fill(0);
    textAlign(CENTER, CENTER);
    text(nf(value, 0, 0), x + 20, y + 10);
    
    // Check if clicked
    if (mousePressed && mouseX >= x && mouseX <= x + 40 && mouseY >= y && mouseY <= y + 20) {
        String input = JOptionPane.showInputDialog("Enter new value (" + min + "-" + max + "):");
        try {
            float newValue = Float.parseFloat(input);
            return constrain(newValue, min, max);
        } catch (Exception e) {
            return value;
        }
    }
    return value;
}

float slider(float x, float y, float value, float min, float max) {
    float sliderWidth = 200;
    float sliderPos = map(value, min, max, x, x + sliderWidth);
    
    stroke(0);
    line(x, y, x + sliderWidth, y);
    fill(100);
    ellipse(sliderPos, y, 10, 10);
    
    if (mousePressed && dist(mouseX, mouseY, sliderPos, y) < 10) {
        return constrain(map(mouseX, x, x + sliderWidth, min, max), min, max);
    }
    return value;
}

boolean checkbox(float x, float y, String label, boolean checked) {
    fill(255);
    stroke(0);
    rect(x, y, 15, 15);
    if (checked) {
        line(x, y, x+15, y+15);
        line(x+15, y, x, y+15);
    }
    fill(0);
    text(label, x + 25, y + 10);
    
    if (mouseX > x && mouseX < x+15 && mouseY > y && mouseY < y+15 && mousePressed) {
        return !checked;
    }
    return checked;
}

void mouseMoved() {
    // Update hover states for tool boxes
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