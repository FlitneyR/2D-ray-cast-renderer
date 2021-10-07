class Player{
  PVector pos;
  float ang;
  float FOV;
  PVector vel;
  float windowpixelWidth, windowpixelHeight;
  
  Player(float x, float y, float theta, float FOV_){
    pos = new PVector(x, y);
    ang = theta;
    FOV = FOV_;
    vel = new PVector(0, 0);
    windowpixelWidth = 2 * tan(radians(FOV) / 2);
    windowpixelHeight = pixelHeight * windowpixelWidth / pixelWidth;
  }
  
  void addRelVec(PVector v){
    vel.add(new PVector(cos(radians(p.ang)) * v.x - sin(radians(p.ang)) * v.y,
                        sin(radians(p.ang)) * v.x + cos(radians(p.ang)) * v.y));
  }
  
  void move(){
    if(vel.x != 0 || vel.y != 0){
      vel = vecscale(vecnorm(vel), 0.1);
      r.setDir(vel);
      if(r.closestCast() < vecmag(vel)){
        PVector wDir = r.closestWall.dir;
        vel = vecscale(wDir, wDir.dot(vel));
      }
      r.setDir(vel);
      if(r.closestCast() > vecmag(vel)){
        pos.add(vel);
      }
    }
  }
}

class Ray {
  PVector pos;
  PVector dir;
  float rayDist;
  float wallDist;
  PVector r;
  Wall closestWall;
  
  Ray(float x, float y, float dx, float dy){
    pos = new PVector(x, y);
    dir = new PVector(dx, dy);
    r = vecscale(dir, 1 / vecmag(dir));
    rayDist = 0;
    wallDist = 0;
  }
  
  void setDir(PVector d){
    dir.x = d.x;
    dir.y = d.y;
    r = vecnorm(dir); //vecscale(dir, 1 / vecmag(dir));
  }
  
  float closestCast(){
    float shortestD = 1000;
    float walldist = 0;
    for(Wall w : walls){
      PVector pt = cast(w);
      if(pt != null){
        if(rayDist < shortestD){
          shortestD = rayDist;
          walldist = wallDist;
          closestWall = w;
        }
      }
    }
    wallDist = walldist;
    return shortestD;
  }
  
  PVector cast(Wall w){
    PVector l = vecminus(w.b, w.a);
    float den = crossprod(l, r);
    if(den == 0){
      return null;
    }
    wallDist = crossprod(vecminus(pos, w.a), r) / den;
    rayDist = crossprod(vecminus(pos, w.a), l) / den;
    if(rayDist >= 0 && 0 <= wallDist && wallDist <= 1){
      PVector p = vecadd(pos, vecscale(r, rayDist));
      wallDist *= vecmag(l);
      return p;
    }
    return null;
  }
}

class Wall {
  PVector a, b, dir;
  PImage texture;
  
  Wall(float ax, float ay, float bx, float by, PImage tex){
    a = new PVector(ax, ay);
    b = new PVector(bx, by);
    dir = b.copy();
    dir.sub(a).normalize();
    texture = tex;
  }
}

class Sprite extends Wall {
  Sprite(float ax, float ay, PImage texture){
    super(ax, ay, ax + 1, ay, texture);
  }
}
