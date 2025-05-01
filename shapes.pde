abstract class Shape {
    int x, y;
    boolean filled;
    color innerColor;
    color strokeColor;
    
    Shape(int x, int y, boolean filled, color innerColor, color strokeColor) {
        this.x = x;
        this.y = y;
        this.filled = filled;
        this.innerColor = innerColor;
        this.strokeColor = strokeColor;
    }
    
    abstract void display();
    
    void move(int newX, int newY) {
        x = newX;
        y = newY;
    }
}

class Square extends Shape {
    int w, h;
  
    Square(int x, int y, int w, int h, boolean filled, color innerColor, color strokeColor) {
        super(x, y, filled, innerColor, strokeColor);
        this.w = w;
        this.h = h;
    }
  
    void display() {
        stroke(strokeColor);
        if (filled) {
            fill(innerColor);
        } else {
            noFill();
        }
        
        // Draw the four sides of the rectangle
        line(x, y, x + w, y);         // Top line
        line(x + w, y, x + w, y + h); // Right line
        line(x + w, y + h, x, y + h); // Bottom line
        line(x, y + h, x, y);         // Left line
    }
    
    void resize(int newW, int newH) {
        w = newW;
        h = newH;
    }
}

class Triangle extends Shape {
    int x2, y2, x3, y3;
    
    Triangle(int x1, int y1, int x2, int y2, int x3, int y3, 
             boolean filled, color innerColor, color strokeColor) {
        super(x1, y1, filled, innerColor, strokeColor);
        this.x2 = x2;
        this.y2 = y2;
        this.x3 = x3;
        this.y3 = y3;
    }
    
    void display() {
        stroke(strokeColor);
        if (filled) {
            fill(innerColor);
        } else {
            noFill();
        }
        
        // Draw the three sides of the triangle
        line(x, y, x2, y2);
        line(x2, y2, x3, y3);
        line(x3, y3, x, y);
    }
}

class Line extends Shape {
    int x2, y2;
    
    Line(int x1, int y1, int x2, int y2, color strokeColor) {
        super(x1, y1, false, 0, strokeColor); // Lines can't be filled
        this.x2 = x2;
        this.y2 = y2;
    }
    
    void display() {
        stroke(strokeColor);
        noFill();
        line(x, y, x2, y2);
    }
}