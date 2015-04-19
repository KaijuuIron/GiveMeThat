package ;
import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;
import aze.display.TileSprite;

/**
 * ...
 * @author Al
 */
class Unit extends Collidable
{	
	
	public var hp:Int;
	public var hpMax:Int;
	public var movespeed:Float;
	var dx:Float;
	var dy:Float;
	public var unitType:String;
	var cooldown:Int;
	var charge:Int;
	public var attackSpeed:Int;
	public var ranged:Bool;
	public var currentSprite:TileSprite;
	public var currentSpriteLegs:TileSprite;
	public var spriteBody1:TileSprite;
	public var spriteBody2:TileSprite;
	public var spriteBody3:TileSprite;
	public var spriteLegs1:TileSprite;
	public var spriteLegs2:TileSprite;
	public var spriteLegsJump:TileSprite;	
	
	//movement info
	public var lastDirection:Int;
	private var isMoving:Bool = false;
	
	//AI stuff
	public var prevPosX:Float;
	public var bored:Bool;
	public var aiDir:Int;
	public var ai:AI;
	public var lastDamagedTime:Int = 0;
	public var lastJumpTime:Int = 0;
	public var lastMirrorChange:Int = 0;
	public var playerDetected:Bool = false;
	public var lastMirrorState:Int = 0;
	
	public function new() 
	{
		super();		
		dx = 0;
		dy = 0;
		type = "unit";
		unitType = "default";
		hp = hpMax;
		attackSpeed = 30;
		cooldown = 0;
		dmg = 0;		
		source = null;
		charge = 0;
		ranged = false;
		
		prevPosX = 0;
		bored = false;
		ai = null;
		
		spriteBody1 = null;
		spriteBody2 = null;
		spriteBody3 = null;
        lastDirection = (this == Main.player) ? -1 : 1;
	}
	
	public static function timePassedFrom(time:Int):Int {
		return Main.framesPassed - time;
	}
	
	public function moveDir(dir:Int) {
		if(!isFlying() || (timePassedFrom(lastJumpTime) < 30 )) {
			dx = movespeed * ((dir > 0) ? 1 : -1);
		}
		//dy = movespeed * Math.sin(angle);
	}
	
	override
	public function tick() {		
		//graaavity
		if ( Main.fullStageHeight - Main.platfromHeightAt(this.x) > this.y + this.sizeY / 2) {
			dy += 3;
		}
		if ( charge > 0 ) {
			chargeAdd( -1);			
		} else {
			if (( animState != 1 ) && (attackSpeed - cooldown < 4)) {
				resetAnim();
			}
		}
		if ( cooldown > 0 ) --cooldown;
		if ( canMoveToX(x+dx)) {
			x += dx;
            if (isFlying()) {
                dx = 0.99 * dx;
            } else {
			    dx = 0.9 * dx;
            }
		} else {
			if ( ai != null) {
				if (( dx != 0 ) && ( timePassedFrom(lastJumpTime) > 60)) {
					jump();
				}
			}
			dx = 0;
		}
		if ( Math.abs(dx) < 0.5 ) {
			dx = 0;
		}
		if ( Math.abs(dy) < 0.5 ) {
			dy = 0;
		}
		if ( dx > 0 ) {
			lastDirection = 1;
			isMoving = true;
		} else if ( dx < 0 ) {
			lastDirection = -1;
			isMoving = true;
		} else {
			isMoving = false;
		}
		if ( dy != 0 ) {
			if ( canMoveToY(y+dy)) {
				y += dy;		
				dy = 0.9 * dy;		
			} else {
				dropToLowerstY();
				dy = 0;
			}
		}
		fixWallCollizion();
		//if ( this == Main.player ) {
			//if (( Math.abs(dx) > 0.3 ) || ( Math.abs(dy) > 0.3 )) {
				//if ( Main.framesPassed % 5 == 0 ) {
					//updateAnim();
				//}			
			//} else {
				//resetAnim();
			//}
		//}
		if ( isFlying() ) {
			setLegsTo(3);
		} else {
			if (( animStateLegs == 3) || (( Main.framesPassed % 15 == 0 ) && isMoving))	{
				if ( animStateLegs == 1 ) {
					setLegsTo(2);
				} else {
					setLegsTo(1);
				}
			}
			if (!isMoving) {
				setLegsTo(1);
			}
		}
		positionSprites();	
        if ( noBody ) {
            takeDamage(1);
        }
	}
	
	public function positionSprites() {		
		if ( currentSprite != null ) {
			currentSprite.x = this.x;// + currentSprite.width / 2;
			currentSprite.y = this.y - currentSprite.height / 2 + this.sizeY / 2;
			if ( timePassedFrom(lastDamagedTime) < 1 ) {
				currentSprite.x += 2;
			}
			else if ( timePassedFrom(lastDamagedTime) < 2 ) {
				currentSprite.x += 1;
			}
		}
		if ( currentSpriteLegs != null ) {
			currentSpriteLegs.x = this.x;// + currentSprite.width / 2;
			currentSpriteLegs.y = this.y - currentSpriteLegs.height / 2 + this.sizeY / 2;
			if (timePassedFrom(lastDamagedTime) < 1 ) {
				currentSpriteLegs.y += 2;
			}
			else if ( timePassedFrom(lastDamagedTime) < 2 ) {
				currentSpriteLegs.y += 1;
			}
		}	
		if ( lastDirection <= 0 ) {
			mirrorTo(0);
		} else {
			mirrorTo(1);
		}
	}
	
	private function mirrorTo(newMirror:Int) {
        if ( this == Main.player ) {
            newMirror == 0 ? newMirror = 1 : newMirror = 0;
        }
		if ( lastMirrorState == newMirror )	return;
		if (( this != Main.player ) && ( timePassedFrom(lastMirrorChange) < 30 ))	return;
		lastMirrorState = newMirror;
		lastMirrorChange = Main.framesPassed;
		if ( spriteBody1 != null ) spriteBody1.mirror = newMirror;
		if ( spriteBody2 != null ) spriteBody2.mirror = newMirror;
		if ( spriteBody3 != null ) spriteBody3.mirror = newMirror;
		if ( spriteLegs1 != null ) spriteLegs1.mirror = newMirror;
		if ( spriteLegs2 != null ) spriteLegs2.mirror = newMirror;
		if ( spriteLegsJump != null ) spriteLegsJump.mirror = newMirror;
	}
	
    public function normalDrawingType():Bool {
        return ( this != Main.player);
    }    
    
	public function draw() {
        if ( normalDrawingType()) {
            if ( spriteBody1 != null ) {
                Main.layer.addChild(spriteBody1);
            }
            if ( spriteBody2 != null ) {
                Main.layer.addChild(spriteBody2);
                spriteBody2.visible = false;
            }
            if ( spriteBody3 != null ) {
                Main.layer.addChild(spriteBody3);
                spriteBody3.visible = false;
            }
        }
		if ( spriteLegs1 != null ) {
			Main.layer.addChild(spriteLegs1);
		}
		if ( spriteLegs2 != null ) {
			Main.layer.addChild(spriteLegs2);
			spriteLegs2.visible = false;
		}
		if ( spriteLegsJump != null ) {
			Main.layer.addChild(spriteLegsJump);
			spriteLegsJump.visible = false;
		}
        if ( !normalDrawingType()) {
            if ( spriteBody1 != null ) {
                Main.layer.addChild(spriteBody1);
            }
            if ( spriteBody2 != null ) {
                Main.layer.addChild(spriteBody2);
                spriteBody2.visible = false;
            }
            if ( spriteBody3 != null ) {
                Main.layer.addChild(spriteBody3);
                spriteBody3.visible = false;
            }
        }
	    if ( false ) {
			graphics.beginFill(0xffffff);
			graphics.drawRect(-this.sizeX/2,-this.sizeY/2,this.sizeX,this.sizeY);
			graphics.endFill();
		}
		positionSprites();
	}
	
	public function jump() {
		//if ( Math.abs((Main.fullStageHeight - Main.platfromHeightAt(x)) - (this.y+this.sizeY/2)) < 5 ) {
		this.lastJumpTime = Main.framesPassed;
		if (!isFlying()) {
			this.dy = -50;
		}
	}
	
	public function isFlying():Bool {
		return canMoveToY(this.y + 5);
	}
	
	private function dropToLowerstY() {		
		var minY:Float = Main.fullStageHeight - Main.platfromHeightAt(x);
		//minY = Math.min(minY, Main.fullStageHeight - Main.platfromHeightAt(x+this.sizeX/2));
		//minY = Math.min(minY, Main.fullStageHeight - Main.platfromHeightAt(x - this.sizeX / 2));
		var destY = minY - sizeY/2;
		if (canMoveTo(x, destY)) {
			y = destY;
		} else if (canMoveTo(x, destY - 1)) {
			y = destY - 1;
		}
	}
	
	public function canMoveToX(x:Float):Bool {
		if ( x - sizeX/2 < 0 ) return false;
		if ( x + sizeX / 2 > Main.fieldWidthTotal )	return false;
		if ( Main.fullStageHeight - Main.platfromHeightAt(x) < this.y + this.sizeY / 2)	return false;
		if ( x > this.x ) {
			if ( Main.fullStageHeight - Main.platfromHeightAt(x + sizeX / 2) < this.y + this.sizeY / 2)	return false;
		} else {
			if ( Main.fullStageHeight - Main.platfromHeightAt(x - sizeX / 2) < this.y + this.sizeY / 2)	return false;
		}
		return canMoveTo(x, y);
	}
	
	public function canMoveToY(y:Float):Bool {
		//if ( y - sizeY/2 < 0 ) return false;
		if ( y + sizeY/2 > Main.fullStageHeight - Main.platfromHeightAt(this.x) )	return false;
		//if ( y + sizeY/2 > Main.fullStageHeight - Main.platfromHeightAt(this.x+this.sizeX/2) )	return false;
		//if ( y + sizeY/2 > Main.fullStageHeight - Main.platfromHeightAt(this.x-this.sizeX/2) )	return false;
		return canMoveTo(x, y);
	}
	
	public function canMoveTo(x:Float, y:Float):Bool {
		for ( another in Main.collidables ) {
			if (( this != another ) && ( another.type == "unit" )) {
				if ( this.checkFutureCollizion(x,y,another) ) {
					return false;
				}
			}
		}	
		if ( flying )	return true;
		//return Main.getTileAt(x+sizeX/2,y+sizeY).pathable;
		return true;
	}
	
	override
	public function push(angle:Float, dist:Float) {
		if ( immovable )	return;
		if ( canMoveToX(x + dist * Math.cos(angle))) {
			x += dist * Math.cos(angle);
		}
		if ( canMoveToY(y + dist * Math.sin(angle))) {
			y += dist * Math.sin(angle);
		}
	}
	
	public function shoot(angle:Float) {			
        if ( noBody )   return;
		if ( cooldown <= 0 ) {
			chargeAdd(2);
			if ( charge >= 9 ) {
				setAnimTo(3);
			} else if ( charge >= 3 ) {
				setAnimTo(2);
			} else {
				setAnimTo(1);
			}
			var dir:Int = (Math.abs(angle) < Math.PI / 2) ? 1 : -1; 
			if ( charge >= 15 ) {
				if ( this == Main.player ) {
					Main.playerShootOrder =  false;
				}
				if ( ranged ) {
					var projType:ProjectileType = null;
					if ( unitType == "gun" ) {
						projType = Main.projGun;
					}
                    if ( this == Main.player ) {
                        if ( Player.playerWeapon == "gun" ) {
                            projType = Main.projGun;
                        }
                    }
					var proj:Projectile = new Projectile(projType);
					proj.setAngle(angle);
					Main.field.addChild(proj);
					proj.x = this.x;
					proj.y = this.y;
					if ( unitType == "gun" ) {
						proj.x += lastDirection * 100;
						proj.y += -35;
					}
                    if ( this == Main.player ) {                        
                        if ( Player.playerWeapon == "gun" ) {
						    proj.x += lastDirection * 100;
						    proj.y += -20;
                        }
                    }
					Main.collidables.push(proj);
					proj.source = this;
					proj.infected = this.infected;
                    if ( this == Main.player ) {
                        Player.useAttackCharge();
                    }
				} else {										
					if ( unitType == "dog" ) {
						strike(dir, 100, 100);
					}					
					if ( unitType == "handman" ) {
						strike(dir, 200, 200);
					}
					if ( this == Main.player ) {
						if (strike(dir, Player.strikeAreaX, Player.strikeAreaY)) {
                            if (Player.playerWeapon == "fists" ) {
                                this.takeDamage(1);
                            }
                            Player.useAttackCharge();
                        }
					}
				}
			cooldown = attackSpeed;
			charge = 1;			
			if (!normalDrawingType()) {    
                setAnimTo(2);
            } else {
                setAnimTo(1);
			}		
            }
			
			if ( !isMoving ) {
				turnTo(angle);
			}
		}
	}
	
	function strike(dir:Int,strikeAreaWidth:Float=100,strikeAreaHeigth:Float=200):Bool {		
		var strikeAreaX:Float = this.x + this.sizeX / 2 * dir;
		strikeAreaX += dir * strikeAreaWidth / 2;
		var strikeAreaY:Float = this.y;
		//strikeAreaY -= strikeAreaHeigth / 2;
		if (false) {
			//highlight area
			var particale:ExpandingParticle	= ExpandingParticle.getParticle(strikeAreaX, strikeAreaY,
													0xff0000, 2, 30);
			var rect:Sprite = new Sprite();
			rect.graphics.beginFill(0xff0000);
			rect.graphics.drawRect( -strikeAreaWidth / 2, -strikeAreaHeigth / 2, strikeAreaWidth, strikeAreaHeigth);
			rect.graphics.endFill();
			particale.addChild(rect);
			Main.field.addChild(particale);										
		}
        var hitFlag:Bool = false;
		for ( another in Main.collidables ) {
			if (( this != another ) && ( another.type == "unit" )
				&& (this.infected != another.infected)) {
				if (( Math.abs(another.x - strikeAreaX) < another.sizeX / 2 + strikeAreaWidth / 2)
					&& ( Math.abs(another.y - strikeAreaY) < another.sizeY / 2 + strikeAreaHeigth / 2)) {
					if ( another.infected  || another == Main.player ) {
						another.takeDamage(this.dmg, this);
					} else {
						another.takeDamage(0);
					}
                    hitFlag = true;
					//trace(this.dmg);
				}
			}
		}
        return hitFlag;
	}
	
	function chargeAdd(val:Int) {
		charge += val;
	}
	
	override
	public function takeDamage(dmg:Int, source:Unit = null) {
		this.lastDamagedTime = Main.framesPassed;
		if ( dmg > 0 ) {
			hp -= dmg;			
			if ( this == Main.player ) {
				Main.trackPlayerHp();
				//var soundfx1 = Assets.getSound("audio/player_hit.wav");
				//soundfx1.play();
			} else {
				if ( !isMoving && (source != null)) {
					turnTo(Math.atan2(source.y - this.y, source.x - this.x));
				}
			}
			if ( hp <= 0 ) {
				kill();
			}			
		}
	}
	
	private function turnTo(angle:Float) {
		var dir:Int = (Math.abs(angle) < Math.PI / 2) ? 1 : -1; 
		if ( lastDirection != dir ) {
			lastDirection = dir;
			positionSprites();
		}
	}
	
	public function heal(val:Int) {		
		if (( this == Main.player ) && (hp<hpMax)) {
			//var soundfx1 = Assets.getSound("audio/hp_up.wav");
			//soundfx1.play();			
		}		
		this.hp += val;
		if ( hp > hpMax ) {
			hp = hpMax;
		}
		Main.trackPlayerHp();
	}
	
	public function infect() {
		if ( unitType.substr(unitType.length - 4) == "Ally" ) {			
			if ( spriteBody1 != null )	Main.layer.removeChild(spriteBody1);
			if ( spriteBody2 != null )	Main.layer.removeChild(spriteBody2);
			if ( spriteBody3 != null )	Main.layer.removeChild(spriteBody3);
			if ( spriteLegs1 != null )	Main.layer.removeChild(spriteLegs1);
			if ( spriteLegs2 != null )	Main.layer.removeChild(spriteLegs2);
			if ( spriteLegsJump != null )	Main.layer.removeChild(spriteLegsJump);
			unitType = unitType.substr(0, unitType.length - 4);			
		}
		if ( unitType == "dog" ) {			
			spriteBody1 = new TileSprite(Main.layer, "evildog1");
			spriteBody2 = new TileSprite(Main.layer, "evildog2");
			spriteBody3 = new TileSprite(Main.layer, "evildog3");
			spriteLegs1 = new TileSprite(Main.layer, "evildogLeg1");
			spriteLegs2 = new TileSprite(Main.layer, "evildogLeg2");
			spriteLegsJump = new TileSprite(Main.layer, "evildogLeg3");
			ai = Main.aiSimpleFollow;
		}
		if ( unitType == "gun" ) {			
			spriteBody1 = new TileSprite(Main.layer, "evilgun1");
			spriteBody2 = new TileSprite(Main.layer, "evilgun2");
			spriteBody3 = new TileSprite(Main.layer, "evilgun3");
			spriteLegs1 = new TileSprite(Main.layer, "gunLeg1");
			spriteLegs2 = new TileSprite(Main.layer, "gunLeg2");
			spriteLegsJump = new TileSprite(Main.layer, "gunLeg3");
			ai = Main.aiSimpleRanged;
		}		
		if ( unitType == "handman" ) {			
			spriteBody1 = new TileSprite(Main.layer, "evilhandman1");
			spriteBody2 = new TileSprite(Main.layer, "evilhandman2");
			spriteBody3 = new TileSprite(Main.layer, "evilhandman3");
			spriteLegs1 = new TileSprite(Main.layer, "evilhandmanLeg1");
			spriteLegs2 = new TileSprite(Main.layer, "evilhandmanLeg2");
			spriteLegsJump = new TileSprite(Main.layer, "evilhandmanLeg3");
			ai = Main.aiSimpleFollow;
		}
		infected = true;
		//positionSprites();
	}
	
    public var noBody:Bool = false;
    public function destroyBody() {        
		if ( spriteBody1 != null )	Main.layer.removeChild(spriteBody1);
		if ( spriteBody2 != null )	Main.layer.removeChild(spriteBody2);
		if ( spriteBody3 != null )	Main.layer.removeChild(spriteBody3);
        spriteBody1 = null;
        spriteBody2 = null;
        spriteBody3 = null;
        noBody = true;
    }
    
	public function kill() {
        
        Main.enemies.remove(this);		
		if ( spriteBody1 != null )	Main.layer.removeChild(spriteBody1);
		if ( spriteBody2 != null )	Main.layer.removeChild(spriteBody2);
		if ( spriteBody3 != null )	Main.layer.removeChild(spriteBody3);
		if ( spriteLegs1 != null )	Main.layer.removeChild(spriteLegs1);
		if ( spriteLegs2 != null )	Main.layer.removeChild(spriteLegs2);
		if ( spriteLegsJump != null )	Main.layer.removeChild(spriteLegsJump);		
		new Corpse(this);
        
		if ( this.parent == Main.field ) {
			destroy();		
		}
		hp = 0;
		if ( this == Main.player ) {
			//Main.pauseGame(Main.textDefeat);
		}
	}
    
    public function removeFromGame() {
        
        Main.enemies.remove(this);		
		if ( spriteBody1 != null )	Main.layer.removeChild(spriteBody1);
		if ( spriteBody2 != null )	Main.layer.removeChild(spriteBody2);
		if ( spriteBody3 != null )	Main.layer.removeChild(spriteBody3);
		if ( spriteLegs1 != null )	Main.layer.removeChild(spriteLegs1);
		if ( spriteLegs2 != null )	Main.layer.removeChild(spriteLegs2);
		if ( spriteLegsJump != null )	Main.layer.removeChild(spriteLegsJump);		
		if ( this.parent == Main.field ) {
			destroy();		
		}
		hp = 0;
    }
	
	override
	public function checkCollizion(other:Collidable):Bool {
		if ((other == this.source) || (this == other.source))	return false;
		if (( Math.abs(this.x - other.x) <= (this.sizeX / 2 + other.sizeX / 2)) &&
			( Math.abs(this.y - other.y) <= (this.sizeY / 2 + other.sizeY / 2)))	{
				return true;
			}		
		return false;
	}
	
	public function checkFutureCollizion(x:Float,y:Float,other:Collidable):Bool {
		if ((other == this.source) || (this == other.source))	return false;
		if (( Math.abs(x - other.x) <= (this.sizeX / 2 + other.sizeX / 2)) &&
			( Math.abs(y - other.y) <= (this.sizeY / 2 + other.sizeY / 2)))	{
				fixCollizion(other);
				return true;
			}		
		return false;
	}
	
	private function fixCollizion(other:Collidable) {
		if ( this.x > other.x) {
			this.dx = 1;
		} else {
			this.dx = -1;
		}
	}
	
	private function fixWallCollizion() {
		var depth:Float;
		//right
		if ( Main.platfromHeightAt(x) < Main.platfromHeightAt(x + this.sizeX / 2) ) {
			depth = this.x + this.sizeX / 2 - Main.plaformRightBorder(this.x);
			if ( depth > 0 ) {
				this.dx = -5 * ((depth + Main.platfromSize * 0.2) / Main.platfromSize);
			}
		}
		//left
		if ( Main.platfromHeightAt(x) < Main.platfromHeightAt(x - this.sizeX / 2) ) {
			depth = Main.plaformLeftBorder(this.x) - (this.x - this.sizeX / 2);
			if ( depth > 0 ) {
				this.dx = 5 * ((depth + Main.platfromSize * 0.2) / Main.platfromSize);
			}
		}
	}
	
	public var animState:Int = 1;
	var animStateLegs:Int = 1;
	public function resetAnim() {
		setAnimTo(1);
		animState = 1;
	}
	//
	//public function updateAnim() {
		//setAnimTo(animState);
		//++animState;
		//if ( animState >= animationBmp.length)	animState = 0;
	//}
	//
	public function setAnimTo(anim:Int) {
		if ( animState == anim ) {
			return;
		}
		animState = anim;
		if ( currentSprite != null ) {
			currentSprite.visible = false;
		}
		if ( animState == 1 )	currentSprite = spriteBody1;
		if ( animState == 2 )	currentSprite = spriteBody2;
		if ( animState == 3 )	currentSprite = spriteBody3;
		if ( currentSprite != null ) {
			currentSprite.visible = true;
		}
	}
	
	public function setLegsTo(anim:Int) {
		if ( animStateLegs == anim ) {
			return;
		}
		animStateLegs = anim;		
		if ( currentSpriteLegs != null ) {
			currentSpriteLegs.visible = false;
		}
		if ( animStateLegs == 1 )	currentSpriteLegs = spriteLegs1;
		if ( animStateLegs == 2 )	currentSpriteLegs = spriteLegs2;
		if ( animStateLegs == 3 )	currentSpriteLegs = spriteLegsJump;
		if ( currentSpriteLegs != null ) {
			currentSpriteLegs.visible = true;
		}
	}

}