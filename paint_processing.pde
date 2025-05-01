void setup() {
    background(255);
    surface.setResizable(true);
    noFill();
    noStroke();
}

void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    System.out.println(e);
}
