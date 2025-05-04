abstract class Tool {
    float strokeWeight;
    abstract String getType();
}

abstract class Shape extends Tool {
    int x, y;
    boolean filled;
    color innerColor;
    color strokeColor;
    
    Shape(int x, int y, boolean filled, color innerColor, color strokeColor, float strokeWeight) {
        this.x = x;
        this.y = y;
        this.filled = filled;
        this.innerColor = innerColor;
        this.strokeColor = strokeColor;
        this.strokeWeight = strokeWeight;
    }
    
    abstract void display();
}

class Square extends Shape {
    int size;
  
    Square(int x, int y, int size, boolean filled, color innerColor, color strokeColor, float strokeWeight) {
        super(x, y, filled, innerColor, strokeColor, strokeWeight);
        this.size = size;
    }
  
    void display() {
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        if (filled) {
            fill(innerColor);
        } else {
            noFill();
        }
        rect(x, y, size, size);
    }

    String getType() {
        return "Square";
    }
}

class Triangle extends Shape {
    int x2, y2, x3, y3;
    
    Triangle(int x1, int y1, int x2, int y2, int x3, int y3, 
             boolean filled, color innerColor, color strokeColor, float strokeWeight) {
        super(x1, y1, filled, innerColor, strokeColor, strokeWeight);
        this.x2 = x2;
        this.y2 = y2;
        this.x3 = x3;
        this.y3 = y3;
    }
    
    void display() {
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        if (filled) {
            fill(innerColor);
        } else {
            noFill();
        }
        triangle(x, y, x2, y2, x3, y3);
    }

    String getType() {
        return "Triangle";
    }
}

class Star extends Shape {
    int outerRadius;
    int innerRadius;
    
    Star(int x, int y, int size, boolean filled, 
        color innerColor, color strokeColor, float strokeWeight) {
        super(x, y, filled, innerColor, strokeColor, strokeWeight);
        this.outerRadius = size;
        this.innerRadius = size/2;  // Inner radius is always half of size
    }
    
    void display() {
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        if (filled) {
            fill(innerColor);
        } else {
            noFill();
        }
        
        beginShape();
        float angle = TWO_PI / 10;
        for (int i = 0; i < 10; i++) {
            float radius = i % 2 == 0 ? outerRadius : innerRadius;
            float px = x + cos(angle * i - HALF_PI) * radius;
            float py = y + sin(angle * i - HALF_PI) * radius;
            vertex(px, py);
        }
        endShape(CLOSE);
    }
    
    String getType() {
        return "Star";
    }
}

class Line extends Shape {
    int x2, y2;
    
    Line(int x1, int y1, int x2, int y2, color strokeColor, float strokeWeight) {
        super(x1, y1, false, color(0), strokeColor, strokeWeight);
        this.x2 = x2;
        this.y2 = y2;
    }
    
    void display() {
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();
        line(x, y, x2, y2);
    }

    String getType() {
        return "Line";
    }
}

class Freehand extends Tool {
    ArrayList<PVector> points;
    color strokeColor;
    boolean isDrawing;
    
    Freehand(color strokeColor, float strokeWeight) {
        this.strokeColor = strokeColor;
        this.strokeWeight = strokeWeight;
        this.points = new ArrayList<PVector>();
        this.isDrawing = false;
    }

    Freehand(Freehand other) {
        this.strokeColor = other.strokeColor;
        this.strokeWeight = other.strokeWeight;
        this.points = new ArrayList<PVector>(other.points);
        this.isDrawing = false;
    }
    
    void startDrawing(int x, int y) {
        points.clear();
        points.add(new PVector(x, y));
        isDrawing = true;
    }
    
    void addPoint(int x, int y) {
        if (isDrawing) {
            points.add(new PVector(x, y));
        }
    }
    
    void stopDrawing() {
        isDrawing = false;
    }
    
    void display() {
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();
        beginShape();
        for (PVector point : points) {
            vertex(point.x, point.y);
        }
        endShape();
    }
    
    String getType() {
        return "Freehand";
    }
}

class Eraser extends Freehand {
    Eraser(float strokeWeight) {
        super(color(255), strokeWeight);
    }

    Eraser(Eraser other) {
        super(other);
    }
    
    String getType() {
        return "Eraser";
    }
}