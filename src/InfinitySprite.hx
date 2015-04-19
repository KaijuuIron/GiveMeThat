package ;
import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;

/**
 * ...
 * @author LonelyFlame
 */

class InfinitySprite extends Sprite {
    private var sprites:Array<Bitmap>;
    private var fullStageWidth:Int;
    private var fullStageHeight:Int;
    private var spriteHeight:Int;
    private var spriteWidth:Int;


    public function new(image) {
        super();
        sprites = new Array<Bitmap>();

        fullStageWidth = Main.fullStageWidth;
        fullStageHeight = Main.fullStageHeight;

        var bmp = Assets.getBitmapData(image);
        spriteHeight = bmp.height;
        spriteWidth = bmp.width;
        // TODO: add size exeption
        sprites.push(new Bitmap(bmp));
        sprites.push(new Bitmap(bmp));

        sprites[1].x = spriteWidth;

        this.addChild(sprites[0]);
        this.addChild(sprites[1]);
    }

    public function setX(newPos:Float = 0) {
        sprites[0].x = newPos%spriteWidth;
        sprites[1].x = newPos%spriteWidth + spriteWidth;
    }

    public function setY(newPos:Float = 0) {
        sprites[0].y = newPos%spriteHeight;
        sprites[1].y = newPos%spriteHeight;
    }

    public function moveX(speed:Int) {
        var curPos = sprites[0].x;
        var newPos = curPos + speed;
        this.setX(newPos);
    }

    public function moveY(speed:Int) {
        //TODO: add all
    }

}