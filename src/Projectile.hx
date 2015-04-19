package ;
import flash.display.Bitmap;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class Projectile extends Collidable
{
	var speed:Float;
	var angle:Float;	
	var dx:Float;
	var dy:Float;
	var projType:ProjectileType;
	var ttl:Int;
	var bmp:Bitmap;

	public function new(pt:ProjectileType) 
	{
		super();
		flying = true;
		type = "bullet";
		angle = 0;
		projType = pt;
		speed = projType.speed;
		dmg = projType.dmg;
		ttl = projType.ttl;
		sizeX = Math.round(projType.hbRad);
		//graphics.beginFill(0xff8080);
		//graphics.drawCircle(0, 0, projType.hbRad);
		//graphics.endFill();
		bmp = new Bitmap(Assets.getBitmapData(projType.bmp));
		bmp.x = -bmp.width/2;
		bmp.y = -bmp.height/2;
		addChild(bmp);
		destroyAfterHit = projType.destroyAfterHit;
	}
	
	public function setSpeed(speed:Float) {
		this.speed = speed;
		dx = speed * Math.cos(angle);
		dy = speed * Math.sin(angle);
	}
	
	public function setAngle(angle:Float) {
		this.angle = angle;
		dx = speed * Math.cos(angle);
		dy = speed * Math.sin(angle);
		rotation = (angle * 180 / Math.PI) + 180;
	}
		
	override
	public function tick() {
		//if ( this.projType == Main.projRangedBig ) {
			//rotation += 3;
		//}
		--ttl;
		if ( ttl <= 0 ) {
			this.destroy();
		}
		if ( canMoveToX(x+dx)) {
			x += dx;
		} else {
			dx = 0;
			ttl = 0;
		}
		if ( canMoveToY(y+dy)) {
			y += dy;
		} else {
			dy = 0;
			ttl = 0;
		}		
	}
	
	public function canMoveToX(x:Float):Bool {
		if ( x + Main.field.x < 0 ) return false;
		if ( x + Main.field.x + sizeX/2 > Main.fullStageWidth )	return false;
		return true;
	}
	
	public function canMoveToY(y:Float):Bool {
		if ( y + Main.field.y < 0 ) return false;
		if ( y + Main.field.y + sizeY > Main.fullStageHeight )	return false;
		return true;
	}	
	
	override
	public function checkCollizion(other:Collidable):Bool {
		if ( other == this.source )	return false;
		if ( this.infected == other.infected )	return false;
		if ( other.type == this.type ) {
			return (distanceTo(other) < this.sizeX + other.sizeX);
		} else {
			return (other.distanceOuterTo(this.x, this.y) < this.sizeX);
		}
	}
}