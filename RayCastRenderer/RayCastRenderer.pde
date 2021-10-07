void setup(){
  size(1280, 720); //720p
  //size(1024, 576, P2D); //576p
  frameRate(60);
  //size(400, 300);  //500p
  
  String[] worldText = loadStrings("WorldData.txt");
  
  walls = new Wall[worldText.length + spriteLimit];
  
  for(int i = 0; i < worldText.length; i++){
    String[] nums = worldText[i].split("#")[0].split(",");
    walls[i] = new Wall(Float.parseFloat(nums[0]),
                        Float.parseFloat(nums[1]),
                        Float.parseFloat(nums[2]),
                        Float.parseFloat(nums[3]),
                        wallTex);
  }
  
  for(int i = 0; i < spriteLimit; i++){
    walls[worldText.length + i] = new Sprite(-1, -1, spriteTex);
  }
  
  r = new Ray(0, 0, 1, 0);
  
  p = new Player(1, 1, 0, 110);
  
  inputs = new boolean[]{false, false, false, false, false, false};
  
  texSize = 16;
  
  floorTex = loadImage("MeshTexture.jpg");
  floorTex.resize(texSize, texSize);
  wallTex = loadImage("DoomMetalWall.jpg");
  wallTex.resize(texSize, texSize);
  //spriteTex = loadImage("");
  //spriteTex.resize(texSize, texSize);
}

Wall[] walls;
Ray r;
Player p;
int spriteLimit = 5;

int texSize;
PImage floorTex, wallTex, spriteTex;

int rayDeRes = 3;
int fcHDeRes = 1;
int fcWDeRes = 4;

//int rayDeRes = 1;
//int fcHDeRes = 1;
//int fcWDeRes = 1;

boolean FPS = true;
//boolean FPS = false;

boolean inputs[];

void draw(){
  drawFloorAndCeiling();
  
  r.pos.x = p.pos.x;
  r.pos.y = p.pos.y;
  
  noStroke();
  
  for(int col = 0; col < pixelWidth; col += rayDeRes){
    float t = atan(map(col, 0, pixelWidth, tan(-radians(p.FOV) / 2), tan(radians(p.FOV) / 2)));
    
    r.setDir(new PVector(cos(radians(p.ang) + t), sin(radians(p.ang) + t)));
    
    float shortestD = r.closestCast();
    float h = pixelHeight / (shortestD * cos(t) * p.windowpixelHeight);
    int tx = floor((r.wallDist % 1) * wallTex.pixelWidth);
    int texStepSize = 1;
    if(wallTex.pixelHeight > h){
      texStepSize = 2;
    }
    for(int ty = 0; ty < wallTex.pixelHeight; ty += texStepSize){
      color colour = wallTex.pixels[tx + ty * wallTex.pixelWidth];
      float n = (pixelHeight / 2) - (h / 2);
      fill(fade(colour, 0.5 * shortestD));
      //fill(colour);
      rect(col, map(ty, 0, wallTex.pixelHeight, n, n + h), rayDeRes, 1 + h / wallTex.pixelHeight);
    }
  }
  
  if(FPS){
    String text = "";
    text += (int) frameRate + " FPS\n";
    text += rayDeRes + " pixels per ray\n";
    text += "Floor/Ceiling horizontal clumping: " + fcHDeRes;
    text += "\nFloor/Ceiling vertical clumping: " + fcWDeRes;
    text += "\nTexture width/height: " + texSize + " pixels\n";
    text += "Position: " + p.pos.x + ", " + p.pos.y;
    fill(255);
    text(text, 0, 10);
    //text(rayDeRes + " rays per pixel", 0, 22);
    //text("Floor/Ceiling horizontal clumping: " + fcHDeRes, 0, 34);
    //text("Floor/Ceiling vertical clumping: " + fcWDeRes, 0, 46);
    //text("Texture width/height: " + texSize + " pixels", 0, 58);
  }
  
  handleInput();
  p.move();
  p.vel = new PVector(0, 0);
}

void handleInput(){
  if(inputs[0]){
    p.addRelVec(new PVector(0.1, 0));
  }
  if(inputs[1]){
    p.addRelVec(new PVector(0, -0.1));
  }
  if(inputs[2]){
    p.addRelVec(new PVector(-0.1, 0));
  }
  if(inputs[3]){
    p.addRelVec(new PVector(0, 0.1));
  }
  if(inputs[4]){
    p.ang -= 3;
  }
  if(inputs[5]){
    p.ang += 3;
  }
}

void keyPressed(){
  if(key == CODED){
    if(keyCode == LEFT){
      inputs[4] = true;
    }
    if(keyCode == RIGHT){
      inputs[5] = true;
    }
  }
  if(key == 'w'){
    inputs[0] = true;
  }
  if(key == 'a'){
    inputs[1] = true;
  }
  if(key == 's'){
    inputs[2] = true;
  }
  if(key == 'd'){
    inputs[3] = true;
  }
  if(key == 't'){
    rayDeRes = 3;
    fcHDeRes = 1;
    fcWDeRes = 4;
  }
  if(key == 'y'){
    rayDeRes = 1;
    fcHDeRes = 1;
    fcWDeRes = 1;
  }
  if(key == 'g'){
    if(texSize >= 2){
      texSize /= 2;
      floorTex = loadImage("MeshTexture.jpg");
      floorTex.resize(texSize, texSize);
      wallTex = loadImage("DoomMetalWall.jpg");
      wallTex.resize(texSize, texSize);
    }
  }
  if(key == 'h'){
    texSize *= 2;
    floorTex = loadImage("MeshTexture.jpg");
    floorTex.resize(texSize, texSize);
    wallTex = loadImage("DoomMetalWall.jpg");
    wallTex.resize(texSize, texSize);
  }
}

void keyReleased(){
  if(key == CODED){
    if(keyCode == LEFT){
      inputs[4] = false;
    }
    if(keyCode == RIGHT){
      inputs[5] = false;
    }
  }
  if(key == 'w'){
    inputs[0] = false;
  }
  if(key == 'a'){
    inputs[1] = false;
  }
  if(key == 's'){
    inputs[2] = false;
  }
  if(key == 'd'){
    inputs[3] = false;
  }
}

void drawFloorAndCeiling(){
  loadPixels();
  for(int col = 0; col < pixelWidth; col += fcWDeRes){
    float t = atan(map(col, 0, pixelWidth, tan(-radians(p.FOV) / 2), tan(radians(p.FOV) / 2)));
    r.setDir(new PVector(cos(radians(p.ang) + t), sin(radians(p.ang) + t)));
    
    for(int row = 0; row < pixelHeight / 2; row += fcHDeRes){
      float h = map(row, 0, pixelHeight / 2, p.windowpixelHeight, 0) * cos(t);
      float d = 1 / h;
      float x = p.pos.x + r.dir.x * d;
      float y = p.pos.y + r.dir.y * d;
      int tx = floor((abs(x) % 1) * floorTex.pixelWidth);
      int ty = floor((abs(y) % 1) * floorTex.pixelWidth);
      color colour = floorTex.pixels[tx + ty * floorTex.pixelWidth];
      colour = fade(colour, 0.5 * d);
      for(int i = 0; i < fcWDeRes && col + i < pixelWidth; i++){
        for(int j = 0; j < fcHDeRes && row + j < pixelHeight; j++){
          pixels[(col + i) + (row + j) * pixelWidth] = colour;
          pixels[(col + i) + (pixelHeight - (row + j + 1)) * pixelWidth] = colour;
        }
      }
    }
  }
  updatePixels();
}

color fade(color c, float fac){
  return color(red(c) / (fac + 1), green(c) / (fac + 1), blue(c) / (fac + 1));
}

float crossprod(PVector v1, PVector v2){
  return (float)(v1.x * v2.y - v2.x * v1.y);
}

PVector vecminus(PVector v1, PVector v2){
  return new PVector(v1.x - v2.x, v1.y - v2.y);
}

PVector vecadd(PVector v1, PVector v2){
  return new PVector(v1.x + v2.x, v1.y + v2.y);
}

PVector vecnorm(PVector v){
  return vecscale(v, 1 / vecmag(v));
}

float vecmag(PVector v){
  return dist(0, 0, v.x, v.y);
}

PVector vecscale(PVector v, float s){
  return new PVector(v.x * s, v.y * s);
}
