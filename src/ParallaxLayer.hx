package ;
import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;

/**
 * ...
 * @author LonelyFlame
 */

class ParallaxLayer extends Sprite {
    private static var sprite:InfinitySprite;
    private static var speed;


    public function new(image, initialSpeed) {
        super(); 
        sprite = new InfinitySprite(image);
        speed = initialSpeed;
        this.addChild(sprite);
    }

    public function onFrame(cameraX:Float = 0, cameraY:Float = 0) {
        sprite.setX(cameraX * speed);
        sprite.setY(cameraY * speed);
    }

}