package ;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class ExpandingParticle extends Sprite
{
	//var color:UInt;
	var size:Float;
	var dSize:Float;
	var dAlpha:Float;
	var ttl:Int;
	var time:Int;
	var dx:Float;
	var dy:Float;
	
	public function new(x:Float,y:Float,col:Int,size:Float,ttl:Int,dSize:Float,dAlpha:Float,dx:Float=0,dy:Float=0) 
	{
		super();
		this.x = x;
		this.y = y;
		this.size = size;
		this.ttl = ttl;
		time = 0;
		this.dSize = dSize;
		this.dAlpha = dAlpha;
		//graphics.beginFill(color);
		//graphics.drawCircle(0, 0, size);
		//graphics.endFill();		
		Main.particles.add(this);
		this.dx = dx;
		this.dy = dy;
		//var bmp:Bitmap = new Bitmap(Assets.getBitmapData("img/E_particles.png"));
		//this.addChild(bmp);
	}		
	
	public function tick() {		
		if ( time >= ttl ) {
			if ( this.parent != null ) {
				Main.particles.remove(this);
				this.parent.removeChild(this);
				particleCache.add(this);
			}
		} else {
			++time;
			scaleX += dSize;
			scaleY += dSize;
			if (Math.abs(dAlpha) > 0) alpha -= dAlpha;            
			if (Math.abs(dx) > 0) x += dx;
			if (Math.abs(dy) > 0) y += dy;
		}
	}
	
	private static var particleCache:List<ExpandingParticle> = new List<ExpandingParticle>();
	
	public static function getParticle(x:Float, y:Float, col:Int, size:Float, ttl:Int, dSize:Float = 0, dAlpha:Float = 0, dx:Float = 0, dy:Float = 0):ExpandingParticle {
		var particle:ExpandingParticle;
		if ( particleCache.length > 0 ) {
			particle = particleCache.pop();
			particle.x = x;
			particle.y = y;
			//particle.color = col;
			particle.size = size;
			particle.ttl = ttl;
			particle.dSize = dSize;
			particle.dAlpha = dAlpha;
			particle.dx = dx;
			particle.dy = dy;
			particle.time = 0;
			particle.graphics.clear();
			//particle.graphics.beginFill(col);
			//particle.graphics.drawRect( -size / 2, -size / 2, size, size);
			//particle.graphics.endFill();					
			particle.scaleX = 1.0;
			particle.scaleY = 1.0;
			particle.alpha = 1.0;
			Main.particles.add(particle);
		} else {
			particle = new ExpandingParticle(x, y, col, size, ttl, dSize, dAlpha, dx, dy);
		}
		return particle;
	}
}