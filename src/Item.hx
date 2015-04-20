package ;

import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class Item extends Sprite
{

    public var itemType:String;
    public function new(type:String) 
    {
        super();
        this.itemType = type;
        var bmp:Bitmap = null;
        if (itemType == "sign") {
            bmp = new Bitmap(Assets.getBitmapData("img/sign1.png"));
        }
        this.addChild(bmp);
    }
    
}