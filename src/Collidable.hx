package ;
import flash.display.Sprite;

/**
 * ...
 * @author Al
 */
class Collidable extends Sprite
{
	public var flying:Bool;
	public var sizeX:Int;
	public var sizeY:Int;
	public var type:String;
	public var dmg:Int;
	public var destroyAfterHit:Bool;
	public var collizionGroup:Map<Collidable,Int>;
	public var source:Unit;
	public var immovable:Bool;
	public function new() 
	{
		super();
		collizionGroup = new Map<Collidable,Int>();
		immovable = false;
	}
	
	public function tick() {
		trace("tick");
	}
	 
	public function checkCollizion(other:Collidable):Bool {
		if (( Math.abs(this.x - other.x) < (this.sizeX / 2 + other.sizeX / 2)) &&
			( Math.abs(this.y - other.y) < (this.sizeY / 2 + other.sizeY / 2)))	return true;
		return false;
	}
	
	public function push(angle:Float, dist:Float) {		
		if (!immovable) {
			x += dist * Math.cos(angle);
			y += dist * Math.sin(angle);
		}
	}
	
	public function destroy() {
		Main.collidables.remove(this);
		Main.field.removeChild(this);		
	}
	
	public function distanceTo(other:Collidable) {
		return Math.sqrt(Math.pow(this.x - other.x, 2) + Math.pow(this.y - other.y, 2));
	}
	
	private function distanceBetweenX(otherX:Float):Bool {
		return (( x - sizeX / 2 < otherX ) && (x + sizeX / 2 > otherX));
	}
	
	private function distanceBetweenY(otherY:Float):Bool {
		return (( y - sizeY / 2 < otherY ) && (y + sizeY / 2 > otherY));
	}
	
	private function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
	}
	
	public function distanceOuterTo(otherX:Float, otherY:Float):Float {
		if ( distanceBetweenX(otherX) ) {
			if ( distanceBetweenY(otherY) )	return 0;
			if ( y > otherY ) {
				return (y - sizeY / 2) - otherY;
			} else {
				return otherY - (y + sizeY / 2);
			}
		}		
		if ( distanceBetweenY(otherY) ) {
			if ( x > otherX ) {
				return (x - sizeX / 2) - otherX;
			} else {
				return otherX - (x + sizeX / 2);
			}
		}
		if (( x >= otherX ) && (y >= otherY))	return distance(x - sizeX / 2, y - sizeY / 2, otherX, otherY);
		if (( x >= otherX ) && (y <= otherY))	return distance(x - sizeX / 2, y + sizeY / 2, otherX, otherY);
		if (( x <= otherX ) && (y >= otherY))	return distance(x + sizeX / 2, y - sizeY / 2, otherX, otherY);
		if (( x <= otherX ) && (y <= otherY))	return distance(x + sizeX / 2, y + sizeY / 2, otherX, otherY);		
		return -1;
	}
	
	public function takeDamage(dmg:Int) {
		trace("damage on collidable");
	}
}