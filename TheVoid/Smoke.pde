PImage smokeTexture;

/*
 * A smoke object that is attached to other drawable objects, and whose Draw
 * and Update functions are controlled by them. Implements a particle system
 * 
 */
public class Smoke extends Drawable implements Updatable
{
  ParticleSystem ps;
  float billowDirection;
  
  Smoke(PVector _loc, PVector _size)
  {
    super("Smoke", _loc, _size);
    sprite = smokeTexture.get();
    sprite.resize((int)size.x, (int)size.y);
    ps = new ParticleSystem(0, location, sprite);
    
    billowDirection = rand.nextFloat() * 0.1 - 0.05;
  }

  @Override public void DrawObject() //<>//
  {
    float dx = billowDirection;
    PVector wind = new PVector(dx,0);
    ps.applyForce(wind);
    ps.run();
    for (int i = 0; i < 2; i++) 
    {
      ps.addParticle();
    }
    noTint();      //Clear tint from smoke particles before returning to drawing other objects
  }
  
  public void Update()
  {
    //Translation from Drawable object location to ParticleSystem origin
    ps.origin = location;
  }
}

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {

  ArrayList<Particle> particles;    // An arraylist for all the particles
  PVector origin;                   // An origin point for where particles are birthed
  PImage img;
  
  ParticleSystem(int num, PVector v, PImage img_) {
    particles = new ArrayList<Particle>();              // Initialize the arraylist
    origin = v.get();                                   // Store the origin point
    img = img_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, img));         // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  // Method to add a force vector to all particles currently in the system
  void applyForce(PVector dir) {
    // Enhanced loop!!!
    for (Particle p: particles) {
      p.applyForce(dir);
    }
  
  }  

  void addParticle() {
    particles.add(new Particle(origin,img));
  }

}

// A simple Particle class, renders the particle as an image

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  PImage img;

  Particle(PVector l,PImage img_) {
    acc = new PVector(0,0);
    float vx = randomGaussian()*0.3;
    float vy = randomGaussian()*0.3 - 1.0;
    vel = new PVector(vx,vy);
    loc = l.get();
    lifespan = 100.0;
    img = img_;
  }

  void run() {
    update();
    render();
  }
  
  // Method to apply a force vector to the Particle object
  // Note we are ignoring "mass" here
  void applyForce(PVector f) {
    acc.add(f);
  }  

  // Method to update location
  void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= 2.5;
    acc.mult(0); // clear Acceleration
  }

  // Method to display
  void render() {
    imageMode(CENTER);
    tint(255,lifespan);
    image(img,loc.x,loc.y);
    // Drawing a circle instead
    // fill(255,lifespan);
    // noStroke();
    // ellipse(loc.x,loc.y,img.width,img.height);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
