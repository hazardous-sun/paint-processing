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
}

class Square extends Shape {
    int size;
  
    Square(int x, int y, int size, boolean filled, color innerColor, color strokeColor) {
        super(x, y, filled, innerColor, strokeColor);
        this.size = size;
    }
  
    void display() {
        stroke(strokeColor);
        if (filled) {
            fill(innerColor);
        } else {
            noFill();
        }
        
        // Draw the four sides of the rectangle
        line(x, y, x + size, y);               // Top line
        line(x + size, y, x + size, y + size); // Right line
        line(x + size, y + size, x, y + size); // Bottom line
        line(x, y + size, x, y);               // Left line
    }
    
    void resize(int newSize) {
        this.size = newSize;
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

    void resize(float scaleFactor) {
        float centerX = (x + x2 + x3) / 3.0f;
        float centerY = (y + y2 + y3) / 3.0f;
        
        // Scale each point relative to the center
        this.x  = (int)(centerX + (x - centerX) * scaleFactor);
        this.y  = (int)(centerY + (y - centerY) * scaleFactor);
        this.x2 = (int)(centerX + (x2 - centerX) * scaleFactor);
        this.y2 = (int)(centerY + (y2 - centerY) * scaleFactor);
        this.x3 = (int)(centerX + (x3 - centerX) * scaleFactor);
        this.y3 = (int)(centerY + (y3 - centerY) * scaleFactor);
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

    void resize(int newX2, int newY2) {
        this.x2 = newX2;
        this.y2 = newY2;
    }
}