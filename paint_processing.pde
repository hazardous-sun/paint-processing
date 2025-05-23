import processing.awt.PSurfaceAWT;
import javax.swing.*;

// Tool configuration variables
boolean showConfigPanel = true;
float fillR = 0, fillG = 0, fillB = 0;
float strokeR = 0, strokeG = 0, strokeB = 0;
boolean filled = true;
int sizeValue = 50;
float strokeWeightValue = 1;
int configPanelHeight = 120;
boolean numberInputActive = false;
boolean prevMousePressed = false;

// Box settings
String[] boxNames = {"Square", "Triangle", "Line", "Star", "Freehand", "Eraser", "Configure"};
final int NUM_BOXES = boxNames.length;
final int BOX_HEIGHT = 50;
color[] boxColors = new color[NUM_BOXES];
boolean[] boxHover = new boolean[NUM_BOXES];

// Shapes to be drawn
Shape[] shapes = {
    new Square(0, 0, 50, false, color(255), color(0), 1),
    new Triangle(0, 0, 0, 0, 0, 0, false, color(255), color(0), 1),
    new Line(0, 0, 0, 0, color(0), 1),
    new Star(0, 0, 30, false, color(255), color(0), 1) 
};

// Star shape parameters
int starOuterRadius = 30;
int starInnerRadius = 15;
int starSize = 30;

// Freehand and Eraser tools
Freehand freehand = new Freehand(color(0), 1);
Eraser eraser = new Eraser(10);

// Currently selected tool
Tool currentTool = shapes[0];

// Line shape parameters
boolean lineFirstClick = true;
int lineStartX, lineStartY;

// Triangle shape parameters
int trianglePointsSet = 0;
int[] triangleX = new int[3];
int[] triangleY = new int[3];

// List of all drawn shapes
ArrayList<Tool> drawnShapes = new ArrayList<Tool>();

// Undo/Redo stacks
ArrayList<ArrayList<Tool>> undoStack = new ArrayList<ArrayList<Tool>>();
ArrayList<ArrayList<Tool>> redoStack = new ArrayList<ArrayList<Tool>>();

// =================================================================
// Core Framework Methods
// =================================================================

/**
 * Initializes the canvas, surface settings, and initial tool states.
 * Called once at program start.
 */
void setup() {
    size(1280, 720);
    surface.setResizable(true);

    // Initialize box colors with different shades of gray
    for (int i = 0; i < NUM_BOXES; i++) {
        boxColors[i] = color(50 + i * 30);
        boxHover[i] = false;
    }

    // Initialize config values
    updateConfigFromCurrentTool();

    noStroke();
    textAlign(CENTER, CENTER);
}

/**
 * Main drawing loop (60fps). Handles:
 * - Canvas background refresh
 * - Persistent shape rendering
 * - UI element drawing (toolbar + config panel)
 * - Live preview of current tool
 */
void draw() {
    background(255);
    
    // Draw canvas area
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

    // Draw options boxes
    drawBoxes();
    
    // Draw config panel if needed
    if (showConfigPanel) {
        drawConfigPanel();
    }
    
    // Update mouse state tracking
    prevMousePressed = mousePressed;
    if (!mousePressed) {
        numberInputActive = false; // Reset when mouse is released
    }
}

// =================================================================
// Input Handling Methods
// =================================================================

/**
 * Handles mouse clicks for:
 * - Tool selection (top toolbar)
 * - Config panel interactions
 * - Shape placement/drawing initiation
 */
void mousePressed() {
    // Check if mouse is in a box
    if (mouseY < BOX_HEIGHT) {
        int boxIndex = (int)(mouseX / (width / float(NUM_BOXES)));
        if (boxIndex >= 0 && boxIndex < NUM_BOXES) {
            // Reset stroke weight before switching tools
            strokeWeight(1);
            getBox(boxIndex);
        }
    } 
    // Check if mouse is in the config panel
    else if (showConfigPanel && mouseY < BOX_HEIGHT + configPanelHeight) {
        // Let config panel handle the click
        return;
    }
    // Otherwise, use the tool
    else {
        useTool();
    }
}

/**
 * Handles mouse drag events for:
 * - Freehand drawing
 * - Eraser strokes
 * Updates continuously during drag.
 */
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
            Freehand newFreehand = new Freehand(color(strokeR, strokeG, strokeB), strokeWeightValue);
            newFreehand.points = new ArrayList<PVector>(freehand.points);
            drawnShapes.add(newFreehand);
            freehand = new Freehand(color(strokeR, strokeG, strokeB), strokeWeightValue);
            currentTool = freehand;
            saveStateForUndo();
            break;
            
        case "Eraser":
            eraser.stopDrawing();
            Eraser newEraser = new Eraser(strokeWeightValue);
            newEraser.points = new ArrayList<PVector>(eraser.points);
            drawnShapes.add(newEraser);
            eraser = new Eraser(strokeWeightValue);
            currentTool = eraser;
            saveStateForUndo();
            break;
    }
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

void keyPressed() {
    if (key == 'z') {
        undo();
    } 
    else if (key == 'y') {
        redo();
    }
}

// =================================================================
// UI Rendering Methods
// =================================================================

/**
 * Draws the tool selection toolbar with:
 * - Colored boxes for each tool
 * - Hover effects
 * - Text labels
 */
void drawBoxes() {
    noStroke();
    
    for (int i = 0; i < NUM_BOXES; i++) {
        float boxWidth = width / float(NUM_BOXES);
        float x = i * boxWidth;
        
        if (boxHover[i]) {
            fill(getBrightness(boxColors[i]) > 128 ? boxColors[i] - 30 : boxColors[i] + 30);
        } else {
            fill(boxColors[i]);
        }
        
        rect(x, 0, boxWidth, BOX_HEIGHT);
        
        // Draw text with consistent formatting
        noStroke();
        textSize(12);
        fill(getBrightness(boxColors[i]) > 128 ? 0 : 255);
        textAlign(CENTER, CENTER);
        text(boxNames[i], x + boxWidth/2, BOX_HEIGHT/2);
    }
    noStroke();
}

/**
 * Renders the configuration panel with dynamic controls:
 * - Color pickers (RGB values)
 * - Size sliders
 * - Checkboxes
 * Updates tool properties in real-time.
 */
void drawConfigPanel() {
    if (!showConfigPanel) return;
    
    // Reset all drawing styles before rendering UI
    pushStyle();
    stroke(150);
    strokeWeight(1);
    fill(220);
    rect(0, BOX_HEIGHT, width, configPanelHeight);
    
    // Set consistent text styling
    fill(0);
    textAlign(LEFT, CENTER);
    noStroke();

    // Define consistent row positions
    float row1Y = BOX_HEIGHT + 25;
    float row2Y = BOX_HEIGHT + 55;
    float row3Y = BOX_HEIGHT + 85;

    // Common options for all tools
    text("Stroke Weight:", 20, row3Y);
    strokeWeightValue = slider(180, row3Y, strokeWeightValue, 1, 20);
    text(nf(strokeWeightValue, 1, 1), 400, row3Y);

    // Tool-specific options
    if (currentTool instanceof Shape) {
        if (!(currentTool instanceof Line)) {
            text("Fill Color (R,G,B):", 20, row1Y);
            fillR = numberInput(180, row1Y, fillR, 0, 255);
            fillG = numberInput(230, row1Y, fillG, 0, 255);
            fillB = numberInput(280, row1Y, fillB, 0, 255);
            
            // Fixed checkbox positioning and functionality
            if (mousePressed && mouseX >= 350 && mouseX <= 365 && mouseY >= row1Y - 8 && mouseY <= row1Y + 7) {
                filled = !filled;
                mousePressed = false; // Prevent multiple toggles
            }
            filled = checkbox(350, row1Y - 8, "Filled", filled);
        }
        
        text("Stroke Color (R,G,B):", 20, row2Y);
        strokeR = numberInput(180, row2Y, strokeR, 0, 255);
        strokeG = numberInput(230, row2Y, strokeG, 0, 255);
        strokeB = numberInput(280, row2Y, strokeB, 0, 255);
        
        if (currentTool instanceof Square || currentTool instanceof Star) {
            text("Size:", 350, row2Y);
            if (currentTool instanceof Square) {
                sizeValue = (int)slider(400, row2Y, sizeValue, 10, 200);
            } else {
                starSize = (int)slider(400, row2Y, starSize, 10, 200);
                starOuterRadius = starSize;
                starInnerRadius = starSize/2;
            }
        }
    } 
    else if (currentTool instanceof Freehand && !(currentTool instanceof Eraser)) {
        text("Line Color (R,G,B):", 20, row1Y);
        strokeR = numberInput(180, row1Y, strokeR, 0, 255);
        strokeG = numberInput(230, row1Y, strokeG, 0, 255);
        strokeB = numberInput(280, row1Y, strokeB, 0, 255);
    }

    popStyle();
    updateToolProperties();
}

// =================================================================
// UI Component Helpers
// =================================================================

/**
 * Renders a draggable slider control
 * @param x,y Position
 * @param value Current value
 * @param min,max Value range
 * @return Updated value based on interaction
 */
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

/**
 * Renders a numeric input field with popup dialog
 * @return Updated value after user input
 */
float numberInput(float x, float y, float value, float min, float max) {
    fill(255);
    stroke(0);
    rect(x, y, 40, 20);
    fill(0);
    textAlign(CENTER, CENTER);
    text(nf(value, 0, 0), x + 20, y + 10);
    
    // Check for NEW mouse press that isn't already handling an input
    if (!numberInputActive && mousePressed && !prevMousePressed && 
        mouseX >= x && mouseX <= x + 40 && 
        mouseY >= y && mouseY <= y + 20) {
        
        String input = JOptionPane.showInputDialog("Enter new value (" + min + "-" + max + "):");
        try {
            float newValue = Float.parseFloat(input);
            value = constrain(newValue, min, max);
            numberInputActive = true; // Prevent multiple triggers
        } catch (Exception e) {
            // Invalid input, keep current value
        }
    }
    return value;
}

boolean checkbox(float x, float y, String label, boolean checked) {
    // Draw checkbox
    fill(255);
    stroke(0);
    rect(x, y, 15, 15);
    
    // Draw checkmark if checked
    if (checked) {
        line(x, y, x+15, y+15);
        line(x+15, y, x, y+15);
    }
    
    // Draw label
    fill(0);
    textAlign(LEFT, CENTER);
    text(label, x + 20, y + 7.5);
    
    return checked;
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
        case 3: // Star
            currentTool = shapes[3];
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = true;
            break;
        case 4: // Freehand
            currentTool = freehand;
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = true;
            break;
        case 5: // Eraser
            currentTool = eraser;
            lineFirstClick = true;
            trianglePointsSet = 0;
            showConfigPanel = true;
            break;
        case 6: // Configure (toggle panel)
            showConfigPanel = !showConfigPanel;
            break;
    }
    
    updateConfigFromCurrentTool();
}

float getBrightness(color c) {
    return (red(c) + green(c) + blue(c)) / 3.0;
}

// =================================================================
// State Management Methods
// =================================================================

/**
 * Saves current canvas state to undo stack:
 * - Deep clones all shapes
 * - Maintains 20-state history limit
 * Called before any destructive operation
 */
void saveStateForUndo() {
    ArrayList<Tool> stateCopy = new ArrayList<Tool>();
    for (Tool tool : drawnShapes) {
        if (tool instanceof Square) {
            stateCopy.add(new Square((Square)tool));
        } 
        else if (tool instanceof Triangle) {
            stateCopy.add(new Triangle((Triangle)tool));
        }
        else if (tool instanceof Line) {
            stateCopy.add(new Line((Line)tool));
        }
        else if (tool instanceof Star) {
            stateCopy.add(new Star((Star)tool));
        }
        else if (tool instanceof Freehand) {
            stateCopy.add(new Freehand((Freehand)tool));
        }
        else if (tool instanceof Eraser) {
            stateCopy.add(new Eraser((Eraser)tool));
        }
    }
    
    undoStack.add(stateCopy);
    // Limit undo stack size to 20 in order to prevent memory issues
    if (undoStack.size() > 20) {
        undoStack.remove(0);
    }
    redoStack.clear();
}

/**
 * Restores previous state from undo stack:
 * - Pushes current state to redo stack
 * - Loads last saved state
 * Triggered by Z
 */
void undo() {
    if (!undoStack.isEmpty()) {
        // Save current state to redo stack first
        ArrayList<Tool> currentState = new ArrayList<Tool>();
        for (Tool tool : drawnShapes) {
            if (tool instanceof Square) {
                currentState.add(new Square((Square)tool));
            } 
            else if (tool instanceof Triangle) {
                currentState.add(new Triangle((Triangle)tool));
            }
            else if (tool instanceof Line) {
                currentState.add(new Line((Line)tool));
            }
            else if (tool instanceof Star) {
                currentState.add(new Star((Star)tool));
            }
            else if (tool instanceof Freehand) {
                currentState.add(new Freehand((Freehand)tool));
            }
            else if (tool instanceof Eraser) {
                currentState.add(new Eraser((Eraser)tool));
            }
        }
        redoStack.add(currentState);
        
        // Restore previous state
        drawnShapes = undoStack.remove(undoStack.size() - 1);
    }
}

void redo() {
    if (!redoStack.isEmpty()) {
        // Save current state to undo stack first
        ArrayList<Tool> currentState = new ArrayList<Tool>();
        for (Tool tool : drawnShapes) {
            if (tool instanceof Square) {
                currentState.add(new Square((Square)tool));
            } 
            else if (tool instanceof Triangle) {
                currentState.add(new Triangle((Triangle)tool));
            }
            else if (tool instanceof Line) {
                currentState.add(new Line((Line)tool));
            }
            else if (tool instanceof Star) {
                currentState.add(new Star((Star)tool));
            }
            else if (tool instanceof Freehand) {
                currentState.add(new Freehand((Freehand)tool));
            }
            else if (tool instanceof Eraser) {
                currentState.add(new Eraser((Eraser)tool));
            }
        }
        undoStack.add(currentState);
        
        // Restore next state
        drawnShapes = redoStack.remove(redoStack.size() - 1);
    }
}

// =================================================================
// Tool Logic Methods
// =================================================================

/**
 * Handles shape creation based on current tool:
 * - Squares: Instant placement
 * - Triangles: Multi-click placement
 * - Lines: Click-drag creation
 * - Stars: Instant placement
 * - Freehand/Eraser: Path recording
 */
void useTool() {
    switch (currentTool.getType()) {
        case "Square":
            Square square = new Square(mouseX, mouseY, sizeValue, filled, 
                                    color(fillR, fillG, fillB), 
                                    color(strokeR, strokeG, strokeB), 
                                    strokeWeightValue);
            saveStateForUndo();
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
                        filled, 
                        color(fillR, fillG, fillB), 
                        color(strokeR, strokeG, strokeB),
                        strokeWeightValue);
                    drawnShapes.add(triangle);
                    trianglePointsSet = 0;
                    saveStateForUndo();
                }
            }
            break;
        case "Line":
            if (lineFirstClick) {
                lineStartX = mouseX;
                lineStartY = mouseY;
                lineFirstClick = false;
            } else {
                Line line = new Line(lineStartX, lineStartY, mouseX, mouseY, 
                                   color(strokeR, strokeG, strokeB),
                                   strokeWeightValue);
                drawnShapes.add(line);
                lineFirstClick = true;
                saveStateForUndo();
            }
            break;
        case "Star":
            Star star = new Star(mouseX, mouseY, starSize, 
                            filled, color(fillR, fillG, fillB), 
                            color(strokeR, strokeG, strokeB),
                            strokeWeightValue);
            drawnShapes.add(star);
            saveStateForUndo();
            break;
        case "Freehand":
            Freehand fh = (Freehand) currentTool;
            fh.strokeColor = color(strokeR, strokeG, strokeB);
            fh.strokeWeight = strokeWeightValue;
            if (!fh.isDrawing) {
                fh.startDrawing(mouseX, mouseY);
            }
            break;
        case "Eraser":
            Eraser es = (Eraser) currentTool;
            es.strokeWeight = strokeWeightValue;
            if (!es.isDrawing) {
                es.startDrawing(mouseX, mouseY);
            }
            break;
    }
}

/**
 * Syncs UI control values with active tool properties:
 * - Colors
 * - Stroke weight
 * - Size parameters
 * Called after tool changes or UI updates
 */
void updateConfigFromCurrentTool() {
    if (currentTool instanceof Shape) {
        Shape shape = (Shape)currentTool;
        fillR = red(shape.innerColor);
        fillG = green(shape.innerColor);
        fillB = blue(shape.innerColor);
        strokeR = red(shape.strokeColor);
        strokeG = green(shape.strokeColor);
        strokeB = blue(shape.strokeColor);
        filled = shape.filled;
        strokeWeightValue = shape.strokeWeight;
        
        if (currentTool instanceof Square) {
            sizeValue = ((Square)currentTool).size;
        }
    } else if (currentTool instanceof Freehand) {
        Freehand fh = (Freehand)currentTool;
        strokeR = red(fh.strokeColor);
        strokeG = green(fh.strokeColor);
        strokeB = blue(fh.strokeColor);
        strokeWeightValue = fh.strokeWeight;
    } else if (currentTool instanceof Eraser) {
        strokeWeightValue = ((Eraser)currentTool).strokeWeight;
    }
}

void updateToolProperties() {
    if (currentTool instanceof Shape) {
        Shape shape = (Shape)currentTool;
        if (!(currentTool instanceof Line)) {
            shape.innerColor = color(fillR, fillG, fillB);
            shape.filled = filled; // Ensure filled state is updated
        }
        shape.strokeColor = color(strokeR, strokeG, strokeB);
        shape.strokeWeight = strokeWeightValue;
        
        if (currentTool instanceof Square) {
            ((Square)currentTool).size = sizeValue;
        }
        else if (currentTool instanceof Star) {
            ((Star)currentTool).outerRadius = starOuterRadius;
            ((Star)currentTool).innerRadius = starInnerRadius;
        }
    } 
    else if (currentTool instanceof Freehand) {
        Freehand fh = (Freehand)currentTool;
        fh.strokeColor = color(strokeR, strokeG, strokeB);
        fh.strokeWeight = strokeWeightValue;
    } 
    else if (currentTool instanceof Eraser) {
        ((Eraser)currentTool).strokeWeight = strokeWeightValue;
    }
}
