class ConfigWindow extends PApplet {
    Shape currentShape;
    boolean isOpen = false;
    
    // For color selection
    float fillR, fillG, fillB;
    float strokeR, strokeG, strokeB;
    boolean filled = true;
    
    // For size control
    int sizeValue;

    ConfigWindow(Shape shape) {
        currentShape = shape;
        if (currentShape instanceof Square) {
            Square sq = (Square) currentShape;
            sizeValue = sq.size;
        }
    }

    void settings() {
        size(300, 400);
    }

    void setup() {
        getSurface().setTitle("Tool Configuration");
        getSurface().setResizable(true);
        isOpen = true;
        extractColors();
    }

    void draw() {
        background(240);
        drawControls();
    }

    void extractColors() {
        fillR = red(currentShape.innerColor);
        fillG = green(currentShape.innerColor);
        fillB = blue(currentShape.innerColor);
        strokeR = red(currentShape.strokeColor);
        strokeG = green(currentShape.strokeColor);
        strokeB = blue(currentShape.strokeColor);
        filled = currentShape.filled;
    }

    void drawControls() {
        // Fill color controls
        fill(0);
        text("Fill Color:", 20, 30);
        fillR = slider(20, 50, "Red", fillR);
        fillG = slider(20, 90, "Green", fillG);
        fillB = slider(20, 130, "Blue", fillB);

        // Stroke color controls
        fill(0);
        text("Stroke Color:", 20, 170);
        strokeR = slider(20, 190, "Red", strokeR);
        strokeG = slider(20, 230, "Green", strokeG);
        strokeB = slider(20, 270, "Blue", strokeB);

        // Size control for Square
        if (currentShape instanceof Square) {
            fill(0);
            text("Size:", 20, 310);
            sizeValue = (int) slider(20, 330, "Size", sizeValue, 10, 200);
        }

        // Filled checkbox
        filled = checkbox(20, 360, "Filled", filled);

        // Update the actual shape properties
        updateShapeProperties();
    }

    float slider(float x, float y, String label, float value) {
        return slider(x, y, label, value, 0, 255);
    }

    float slider(float x, float y, String label, float value, float min, float max) {
        float sliderWidth = 200;
        float sliderPos = map(value, min, max, x, x + sliderWidth);
        
        // Draw slider
        stroke(0);
        line(x, y, x + sliderWidth, y);
        fill(100);
        ellipse(sliderPos, y, 10, 10);
        
        // Label
        fill(0);
        textAlign(LEFT, CENTER);
        text(label + ": " + (int)value, x + sliderWidth + 10, y);
        
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
        
        if (mouseX > x && mouseX < x+15 && mouseY > y && mouseY < y+15) {
            if (mousePressed) return !checked;
        }
        return checked;
    }

    void updateShapeProperties() {
        currentShape.innerColor = color(fillR, fillG, fillB);
        currentShape.strokeColor = color(strokeR, strokeG, strokeB);
        currentShape.filled = filled;
        
        if (currentShape instanceof Square) {
            ((Square)currentShape).size = sizeValue;
        }
    }

    void mousePressed() {
        // Bring main window to front
        getSurface().setAlwaysOnTop(true);
        getSurface().setAlwaysOnTop(false);
    }
}