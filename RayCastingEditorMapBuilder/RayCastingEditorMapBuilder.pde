void setup(){
  size(500, 500);
  
  mapWidth = 20;
  mapHeight = 20;
  
  start = null;
  
  background(0);
  stroke(255);
  out = "0,0," + mapWidth + ",0" + "\n" +
        "0,0,0," + mapHeight + "\n" +
        mapWidth + "," + mapHeight + ",0," + mapHeight + "\n" +
        mapWidth + "," + mapHeight + "," + mapWidth + ",0" +
        "#End of bounding walls\n";
}

PVector start;
int mapWidth, mapHeight;
String out;

boolean click;

void draw(){
  if(mousePressed){
    if(!click){
      click = true;
      if(start == null){
        start = new PVector(mouseX, mouseY);
      } else {
        line(start.x, start.y, mouseX, mouseY);
        out += trunk(map(start.x, 0, width, 0, mapWidth), 1) + "," +
               trunk(map(start.y, 0, height, 0, mapHeight), 1) + "," +
               trunk(map(mouseX, 0, width, 0, mapWidth), 1) + "," +
               trunk(map(mouseY, 0, height, 0, mapHeight), 1);
        if(start.x == mouseX && start.y == mouseY){
          start = null;
          out += "#end of path\n";
        } else {
          start.x = mouseX;
          start.y = mouseY;
          out += "\n";
        }
        saveStrings("WorldData.txt", out.split("\n"));
      }
    }
  } else {
    click = false;
  }
}

float trunk(float f, int decimals){
  return (int)(f * pow(10, decimals)) / pow(10, decimals);
}
