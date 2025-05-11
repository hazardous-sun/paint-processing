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

    Square(Square other) {
        super(other.x, other.y, other.filled, other.innerColor, other.strokeColor, other.strokeWeight);
        this.size = other.size;
    }
  
    void display() {
        // Draw the outline
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();
        line(x, y, x + size, y); // Top
        line(x + size, y, x + size, y + size); // Right
        line(x + size, y + size, x, y + size); // Bottom
        line(x, y + size, x, y); // Left

        // Fill the shape
        if (filled) {
            stroke(innerColor);
            strokeWeight(1);
            for (int i = 0; i < size; i++) {
                
                line(x, y + i, x + size, y + i);
            }
        }
    }

    String getType() {
        return "Square";
    }
}

class Triangle extends Shape {
    int x2, y2, x3, y3;

    Triangle(int x1, int y1, int x2, int y2, int x3, int y3, boolean filled, color innerColor, color strokeColor, float strokeWeight) {
        super(x1, y1, filled, innerColor, strokeColor, strokeWeight);
        this.x2 = x2;
        this.y2 = y2;
        this.x3 = x3;
        this.y3 = y3;
    }

    Triangle(Triangle other) {
        super(other.x, other.y, other.filled, other.innerColor, other.strokeColor, other.strokeWeight);
        this.x2 = other.x2;
        this.y2 = other.y2;
        this.x3 = other.x3;
        this.y3 = other.y3;
    }

    void display() {
        // Draw the outline
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();
        line(x, y, x2, y2);
        line(x2, y2, x3, y3);
        line(x3, y3, x, y);

        // Fill the shape
        if (filled) {
            stroke(innerColor);
            strokeWeight(1);

            // We need to find the limits of the triangle in order to properly fill it
            int minY = min(y, min(y2, y3));
            int maxY = max(y, max(y2, y3));

            // Scanline for filling the triangle
            for (int py = minY; py <= maxY; py++) {
                ArrayList<Integer> intersections = new ArrayList<Integer>();
                addIntersection(x, y, x2, y2, py, intersections);
                addIntersection(x2, y2, x3, y3, py, intersections);
                addIntersection(x3, y3, x, y, py, intersections);

                if (intersections.size() >= 2) {
                    intersections.sort(null);
                    int startX = intersections.get(0);
                    int endX = intersections.get(1);
                    line(startX, py, endX, py);
                }
            }
        }
    }

    void addIntersection(int x1, int y1, int x2, int y2, int py, ArrayList<Integer> intersections) {
        if ((y1 <= py && y2 >= py) || (y1 >= py && y2 <= py)) {
            if (y1 != y2) {
                int px = (int)(x1 + (float)(py - y1) * (x2 - x1) / (y2 - y1));
                intersections.add(px);
            }
        }
    }

    String getType() {
        return "Triangle";
    }
}

class Star extends Shape {
    int outerRadius;
    int innerRadius;

    Star(int x, int y, int size, boolean filled, color innerColor, color strokeColor, float strokeWeight) {
        super(x, y, filled, innerColor, strokeColor, strokeWeight);
        this.outerRadius = size;
        this.innerRadius = size / 2;
    }

    Star(Star other) {
        super(other.x, other.y, other.filled, other.innerColor, other.strokeColor, other.strokeWeight);
        this.outerRadius = other.outerRadius;
        this.innerRadius = other.innerRadius;
    }

    void display() {
        // Draw the outline
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();

        // Calculate the start vertices
        float angle = TWO_PI / 5;
        float halfAngle = angle / 2;

        float[] outerPointsX = new float[5];
        float[] outerPointsY = new float[5];
        float[] innerPointsX = new float[5];
        float[] innerPointsY = new float[5];

        // Calculate the internal and external points
        for (int i = 0; i < 5; i++) {
            outerPointsX[i] = x + cos(angle * i - HALF_PI) * outerRadius;
            outerPointsY[i] = y + sin(angle * i - HALF_PI) * outerRadius;
            
            innerPointsX[i] = x + cos(angle * i - HALF_PI + halfAngle) * innerRadius;
            innerPointsY[i] = y + sin(angle * i - HALF_PI + halfAngle) * innerRadius;
        }

        // Draw the outline
        for (int i = 0; i < 5; i++) {
            int next = (i + 1) % 5;
            line(outerPointsX[i], outerPointsY[i], innerPointsX[i], innerPointsY[i]); // Linha para dentro
            line(innerPointsX[i], innerPointsY[i], outerPointsX[next], outerPointsY[next]); // Linha para fora
        }

        // Fill the shape
        if (filled) {
            stroke(innerColor);
            strokeWeight(1); // Linhas finas para preenchimento

            // Encontrar os limites da estrela
            int minY = (int)(y - outerRadius);
            int maxY = (int)(y + outerRadius);

            // Scanline para preenchimento
            for (int py = minY; py <= maxY; py++) {
                ArrayList<Float> intersections = new ArrayList<Float>();

                // Calculate intersections with all edges
                for (int i = 0; i < 5; i++) {
                    int next = (i + 1) % 5;
                    // External edge -> internal
                    addIntersection(outerPointsX[i], outerPointsY[i], innerPointsX[i], innerPointsY[i], py, intersections);
                    // Internal edge -> external (next vertex)
                    addIntersection(innerPointsX[i], innerPointsY[i], outerPointsX[next], outerPointsY[next], py, intersections);
                }

                // Order the instersections and draw lines between the pairs
                if (intersections.size() >= 2) {
                    intersections.sort(null);
                    for (int i = 0; i < intersections.size(); i += 2) {
                        if (i + 1 < intersections.size()) {
                            line(intersections.get(i), py, intersections.get(i + 1), py);
                        }
                    }
                }
            }
        }
    }

    void addIntersection(float x1, float y1, float x2, float y2, int py, ArrayList<Float> intersections) {
        if ((y1 <= py && y2 >= py) || (y1 >= py && y2 <= py)) {
            if (y1 != y2) { // Evitar divisão por zero
                float px = x1 + (py - y1) * (x2 - x1) / (y2 - y1);
                intersections.add(px);
            }
        }
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

    Line(Line other) {
        super(other.x, other.y, other.filled, other.innerColor, other.strokeColor, other.strokeWeight);
        this.x2 = other.x2;
        this.y2 = other.y2;
    }

    void display() {
        stroke(strokeColor);
        strokeWeight(strokeWeight);
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
        
        
        for (int i = 0; i < points.size() - 1; i++) {
            PVector p1 = points.get(i);
            PVector p2 = points.get(i + 1);
            line(p1.x, p1.y, p2.x, p2.y);
        }
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

    void display() {
        pushStyle();
        stroke(255);
        strokeWeight(strokeWeight);
        noFill();
        
        for (int i = 0; i < points.size() - 1; i++) {
            PVector p1 = points.get(i);
            PVector p2 = points.get(i + 1);
            line(p1.x, p1.y, p2.x, p2.y);
        }
        popStyle();
    }
    
    String getType() {
        return "Eraser";
    }
}
