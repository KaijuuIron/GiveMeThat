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
	public var infected:Bool;
	
	//movement info
	public var lastDirection:Int;
	private var isMoving:Bool = false;
	
	//AI stuff
	public var prevPosX:Float;
	public var bored:Bool;
	public var aiDir:Int;
	public var ai:AI;
	
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
	}
	
	public function moveDir(dir:Int) {
		dx = movespeed * ((dir > 0) ? 1 : -1);
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
			if ( animState != 1 ) {
				resetAnim();
			}
		}
		if ( cooldown > 0 ) --cooldown;
		if ( canMoveToX(x+dx)) {
			x += dx;
			dx = 0.9 * dx;
		} else {
			if ( ai != null) {
				if ( dx != 0 ) {
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
		}
		positionSprites();	
	}
	
	private function positionSprites() {		
		if ( currentSprite != null ) {
			currentSprite.x = this.x;// + currentSprite.width / 2;
			currentSprite.y = this.y - currentSprite.height / 2 + this.sizeY / 2;
			if ( lastDirection < 0 ) {
				currentSprite.mirror = 0;
			} else if ( lastDirection > 0 ) {
				currentSprite.mirror = 1;
			}
		}
		if ( currentSpriteLegs != null ) {
			currentSpriteLegs.x = this.x;// + currentSprite.width / 2;
			currentSpriteLegs.y = this.y - currentSpriteLegs.height / 2 + this.sizeY / 2;
			if ( lastDirection < 0 ) {
				currentSpriteLegs.mirror = 0;
			} else if ( lastDirection > 0 ) {
				currentSpriteLegs.mirror = 1;
			}
		}		
	}
	
	public function draw() {
		graphics.clear();		
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
		if ( false ) {
			graphics.beginFill(0xffffff);
			graphics.drawRect(-this.sizeX/2,-this.sizeY/2,this.sizeX,this.sizeY);
			graphics.endFill();
		}
		positionSprites();
	}
	
	public function jump() {
		//if ( Math.abs((Main.fullStageHeight - Main.platfromHeightAt(x)) - (this.y+this.sizeY/2)) < 5 ) {
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
		if ( y - sizeY/2 < 0 ) return false;
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
		if ( cooldown <= 0 ) {
			chargeAdd(2);
			if ( charge >= 10 ) {
				setAnimTo(3);
			} else if ( charge >= 5 ) {
				setAnimTo(2);
			} else {
				setAnimTo(1);
			}
			if ( charge >= 15 ) {
				if ( this == Main.player ) {
					Main.playerShootOrder =  false;
				}
				if ( ranged ) {
					//var projType:ProjectileType = null;
					//if ( unitType == "default" ) {
						//projType = Main.projMeeleCrescent;
					//}
					//if ( unitType == "ranged" ) {
						//projType = Main.projRangedSmall;
					//}
					//if ( unitType == "biggun" ) {
						//projType = Main.projRangedBig;
					//}
					//var proj:Projectile = new Projectile(projType);
					//proj.setAngle(angle);
					//Main.field.addChild(proj);
					//proj.x = this.x + this.sizeX / 2;
					//proj.y = this.y + this.sizeY / 2;
					//Main.collidables.push(proj);
					//proj.source = this;
				} else {					
					var dir:Int = (Math.abs(angle) < Math.PI / 2) ? 1 : -1; 
					if ( unitType == "dog" ) {
						strike(dir, 100, 100);
					}
					if ( this == Main.player ) {
						strike(dir, 100, 200);
					}
				}
			cooldown = attackSpeed;
			charge = 1;			
			//setAnimTo(1);
			}
		}
	}
	
	function strike(dir:Int,strikeAreaWidth:Float=100,strikeAreaHeigth:Float=200) {		
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
		for ( another in Main.collidables ) {
			if (( this != another ) && ( another.type == "unit" )) {
				if (( Math.abs(another.x - strikeAreaX) < another.sizeX / 2 + strikeAreaWidth / 2)
					&& ( Math.abs(another.y - strikeAreaY) < another.sizeY / 2 + strikeAreaHeigth / 2)) {
					another.takeDamage(this.dmg);
					trace(this.dmg);
				}
			}
		}
	}
	
	function chargeAdd(val:Int) {
		charge += val;
	}
	
	override
	public function takeDamage(dmg:Int) {
		if ( dmg > 0 ) {
			hp -= dmg;			
			if ( this == Main.player ) {
				Main.trackPlayerHp();
				//var soundfx1 = Assets.getSound("audio/player_hit.wav");
				//soundfx1.play();
			}
			if ( hp <= 0 ) {
				kill();
			}
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
	
	public var animState:Int = 0;
	var animStateLegs:Int = 0;
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
		if ( animStateLegs == anim ) {
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