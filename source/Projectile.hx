package;

import flixel.group.FlxSpriteGroup;

import flixel.FlxSprite;
import flixel.FlxG;

import flixel.util.FlxRandom;
import flixel.util.FlxStringUtil;
import flixel.util.FlxVector;
import flixel.util.FlxTimer;

import flixel.tile.FlxTilemap;

class Projectile extends FlxSpriteGroup
{
  inline static var SPEED = 200;

  public var direction:FlxVector;

  var shadow:FlxSprite;
  var projectile:ProjectileSprite;
  var particles:Array<FlxSprite>;
  var particleGroup:FlxSpriteGroup;
  var explosionSprite:FlxSprite;

  public function new(X:Float, Y:Float):Void {
    super(X,Y);

    shadow = new FlxSprite();
    shadow.makeGraphic(20,10,0xff000000);
    shadow.alpha = 0.5;
    shadow.offset.x = -6;
    shadow.solid = false;
    add(shadow);
    
    particles = new Array<FlxSprite>();
    particleGroup = new FlxSpriteGroup();
    add(particleGroup);

    projectile = new ProjectileSprite();
    projectile.onCollisionCallback = onCollide;
    add(projectile);

    G.projectiles.add(this);

    spawnParticle();

    explosionSprite = new FlxSprite();
    explosionSprite.loadGraphic("assets/images/player_magic_hit.png", true, 64, 64);
    explosionSprite.animation.add("explode", [0,1,2,3,4,5], 20, false);
    explosionSprite.visible = false;
    explosionSprite.solid = false;
    add(explosionSprite);

    initialize();
  }

  public function initialize():Void {
    exists = true;
    direction = new FlxVector(FlxG.mouse.x - projectile.x - 8, FlxG.mouse.y - projectile.y + 6).normalize();
    projectile.velocity.x = direction.x * SPEED;
    projectile.velocity.y = direction.y * SPEED;
    shadow.velocity = projectile.velocity;
  }

  private function spawnParticle():FlxSprite {
    var particle:FlxSprite = null;

    for (p in particles) {
      if (!p.exists) {
        p.exists = true;
        particle = p;
        break;
      }
    }

    if (particle == null) {
      particle = new FlxSprite();
      particle.loadGraphic("assets/images/player_magic_particle.png", false, 16, 16);
      particle.animation.add("fade", [0,1,2,2,3,3,4,4,4], 15, false);
      particle.animation.play("fade");
      particle.solid = false;
      new FlxTimer().start(0.6, function(t) { particle.exists = false; });
      particleGroup.add(particle);
    }

    particle.x = projectile.x + FlxRandom.intRanged(-5, 5) + 4;
    particle.y = projectile.y + FlxRandom.intRanged(-5, 5) - 12;
    particle.velocity.x = projectile.velocity.x/4;
    particle.velocity.y = projectile.velocity.y/4;

    new FlxTimer().start(0.1, function(t) { if(projectile.exists) spawnParticle(); });
    return particle;
  }

  public override function update():Void {
    super.update();
  }

  public function onCollide():Void {
    explosionSprite.x = projectile.x - 26;
    explosionSprite.y = projectile.y - 38;
    explosionSprite.visible = true;
    explosionSprite.animation.play("explode");
    new FlxTimer().start(6.0/20.0, function(t) { exists = false; });
    projectile.exists = shadow.exists = false;
    FlxG.camera.shake(0.02, 0.3);
  }
}