class PrimitiveRectangle {
    float x, y;
    float w, h;
    boolean filled;
    color innerColor;
    color strokeColor;
  
    PrimitiveRectangle(float x, float y, float w, float h, boolean filled, color innerColor, color strokeColor) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.filled = filled;
        this.innerColor = innerColor;
        this.strokeColor = strokeColor;
    }
  
    // Method to display the rectangle using only point() and line()
    void display() {
        stroke(c);
        noFill(); // Since we can't use fill() with point/line
        
        // Draw the four sides of the rectangle
        line(x, y, x + w, y);         // Top line
        line(x + w, y, x + w, y + h); // Right line
        line(x + w, y + h, x, y + h); // Bottom line
        line(x, y + h, x, y);         // Left line
    }
    
    // Optional: method to change position
    void move(float newX, float newY) {
        x = newX;
        y = newY;
    }
    
    // Optional: method to change size
    void resize(float newW, float newH) {
        w = newW;
        h = newH;
    }
}