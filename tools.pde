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
        // Desenhar o contorno com a espessura definida pelo usuário
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();
        line(x, y, x + size, y); // Topo
        line(x + size, y, x + size, y + size); // Direita
        line(x + size, y + size, x, y + size); // Base
        line(x, y + size, x, y); // Esquerda

        // Preenchimento com strokeWeight fixo em 1
        if (filled) {
            stroke(innerColor);
            strokeWeight(1); // Linhas finas para preenchimento
            for (int i = 0; i < size; i++) {
                // Linhas horizontais dentro do quadrado
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

    void display() {
        // Desenhar o contorno com a espessura definida pelo usuário
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();
        line(x, y, x2, y2); // Aresta 1
        line(x2, y2, x3, y3); // Aresta 2
        line(x3, y3, x, y); // Aresta 3

        // Preenchimento com strokeWeight fixo em 1
        if (filled) {
            stroke(innerColor);
            strokeWeight(1); // Linhas finas para preenchimento

            // Encontrar os limites verticais do triângulo
            int minY = min(y, min(y2, y3));
            int maxY = max(y, max(y2, y3));

            // Scanline para preenchimento
            for (int py = minY; py <= maxY; py++) {
                ArrayList<Integer> intersections = new ArrayList<Integer>();
                addIntersection(x, y, x2, y2, py, intersections);
                addIntersection(x2, y2, x3, y3, py, intersections);
                addIntersection(x3, y3, x, y, py, intersections);

                // Desenhar linhas horizontais entre as interseções
                if (intersections.size() >= 2) {
                    intersections.sort(null);
                    int startX = intersections.get(0);
                    int endX = intersections.get(1);
                    line(startX, py, endX, py);
                }
            }
        }
    }

    // Método auxiliar para calcular interseções
    void addIntersection(int x1, int y1, int x2, int y2, int py, ArrayList<Integer> intersections) {
        if ((y1 <= py && y2 >= py) || (y1 >= py && y2 <= py)) {
            if (y1 != y2) { // Evitar divisão por zero
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

    void display() {
        // Desenhar o contorno com a espessura definida pelo usuário
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        noFill();

        // Calcular os vértices da estrela (5 pontas)
        float angle = TWO_PI / 5; // 5 vértices externos
        float halfAngle = angle / 2;

        // Arrays para armazenar os pontos
        float[] outerPointsX = new float[5];
        float[] outerPointsY = new float[5];
        float[] innerPointsX = new float[5];
        float[] innerPointsY = new float[5];

        // Calcular pontos externos e internos
        for (int i = 0; i < 5; i++) {
            // Pontos externos
            outerPointsX[i] = x + cos(angle * i - HALF_PI) * outerRadius;
            outerPointsY[i] = y + sin(angle * i - HALF_PI) * outerRadius;
            
            // Pontos internos (entre os vértices externos)
            innerPointsX[i] = x + cos(angle * i - HALF_PI + halfAngle) * innerRadius;
            innerPointsY[i] = y + sin(angle * i - HALF_PI + halfAngle) * innerRadius;
        }

        // Desenhar o contorno da estrela
        for (int i = 0; i < 5; i++) {
            int next = (i + 1) % 5;
            line(outerPointsX[i], outerPointsY[i], innerPointsX[i], innerPointsY[i]); // Linha para dentro
            line(innerPointsX[i], innerPointsY[i], outerPointsX[next], outerPointsY[next]); // Linha para fora
        }

        // Preenchimento com strokeWeight fixo em 1
        if (filled) {
            stroke(innerColor);
            strokeWeight(1); // Linhas finas para preenchimento

            // Encontrar os limites da estrela
            int minY = (int)(y - outerRadius);
            int maxY = (int)(y + outerRadius);

            // Scanline para preenchimento
            for (int py = minY; py <= maxY; py++) {
                ArrayList<Float> intersections = new ArrayList<Float>();

                // Calcular interseções com todas as arestas
                for (int i = 0; i < 5; i++) {
                    int next = (i + 1) % 5;
                    // Aresta externa -> interna
                    addIntersection(outerPointsX[i], outerPointsY[i], innerPointsX[i], innerPointsY[i], py, intersections);
                    // Aresta interna -> externa (próximo vértice)
                    addIntersection(innerPointsX[i], innerPointsY[i], outerPointsX[next], outerPointsY[next], py, intersections);
                }

                // Ordenar interseções e desenhar linhas entre pares
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

    // Método auxiliar para calcular interseções
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

    void display() {
        stroke(strokeColor);
        strokeWeight(strokeWeight);
        line(x, y, x2, y2); // Já usa line()!
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
        stroke(255); // Sempre branco (simula borracha)
        strokeWeight(strokeWeight);
        noFill();
        
        // Mesma lógica do Freehand, mas com cor fixa
        for (int i = 0; i < points.size() - 1; i++) {
            PVector p1 = points.get(i);
            PVector p2 = points.get(i + 1);
            line(p1.x, p1.y, p2.x, p2.y); // Usa apenas line()!
        }
    }
    
    String getType() {
        return "Eraser";
    }
}
