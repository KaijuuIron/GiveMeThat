package ;
import flash.display.Bitmap;

/**
 * ...
 * @author Al
 */
class ProjectileType
{
	public var dmg:Int;
	public var hbRad:Float;
	public var speed:Float;
	public var ttl:Int;
	public var bmp:String;
	public var destroyAfterHit:Bool;
	public var bmpDX:Float;
	public var bmpDY:Float;
	public function new() 
	{
		ttl = -1;
		dmg = 1;
		bmpDX = 0;
		bmpDY = 0;
		destroyAfterHit = true;
	}
	
}