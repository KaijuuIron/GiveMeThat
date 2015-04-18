package ;
import flash.display.BlendMode;
import flash.display.Sprite;
import aze.display.TileSprite;

/**
 * ...
 * @author Al
 */
class Corpse extends Sprite
{
	var ttlMax:Int;
	var ttlRem:Int;
	var sprite:TileSprite;
	var sprite2:TileSprite;
	public function new(source:Unit) 
	{
		super();
		if ( source != null) {
			//TODO: something
			if ( source.spriteBody1 != null )	{
				sprite = source.spriteBody1;
				sprite.visible = true;
				//sprite.blendMode = BlendMode.DARKEN;
				Main.layer.addChild(sprite);				
				sprite.x = source.x;
				sprite.y = source.y;
			}
			if ( source.spriteLegs1 != null )	{
				sprite2 = source.spriteLegs1;
				sprite2.visible = true;
				//sprite.blendMode = BlendMode.DARKEN;
				Main.layer.addChild(sprite2);
			}
		}
		//Main.field.addChild(this);
		Main.corpses.add(this);
		ttlMax = 300;
		ttlRem = ttlMax;
	}
	
	public function decay() {
		--ttlRem;
		if ( ttlRem <= 0 ) {
			Main.layer.removeChild(sprite);
			Main.layer.removeChild(sprite2);
			Main.corpses.remove(this);
			return;
		}
		sprite.alpha = 0.1 + 0.9 * ttlRem / ttlMax;		
		sprite2.alpha = 0.1 + 0.9 * ttlRem / ttlMax;		
	}
	
}