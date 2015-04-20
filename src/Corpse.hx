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
    public var noBody:Bool = true;
    public var sourceUnittype:String = "none";
    public var sizeX:Float = 0;
	public function new(source:Unit) 
	{
		super();
		if ( source != null) {
            sizeX = source.sizeX;
            sourceUnittype = source.unitType;
            this.noBody = source.noBody;
			if (( source.spriteBody1 != null ) && !noBody)	{
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
			if(sprite!=null)    Main.layer.removeChild(sprite);
			if(sprite2!=null)    Main.layer.removeChild(sprite2);
			Main.corpses.remove(this);
			return;
		}
		if (sprite != null) {
            sprite.alpha = 0.1 + 0.7 * ttlRem / ttlMax;		
            this.x = sprite.x;
            this.y = sprite.y;
        }
		if (sprite2 != null) sprite2.alpha = 0.1 + 0.7 * ttlRem / ttlMax;		
        
	}
	
    public function getMirror():Int {
        if (sprite != null)    return sprite.mirror;
        if (sprite2 != null)    return sprite2.mirror;
        return 0;
    }
    
    public function removeBodyPart() {
        if ( !noBody) {
            noBody = true;
            if (sprite != null) {                
                Main.layer.removeChild(sprite);
                sprite = null;
            }
        }
    }
}