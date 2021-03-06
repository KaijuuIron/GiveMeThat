package ;
import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;

/**
 * ...
 * @author LonelyFlame
 */

class Bonus extends Sprite {

    var progres = 0;
    var progresMax = 100;
    var startCoords:Float;

    public function new(startY:Float = 0) {
        super();

        var bmp = new Bitmap(Assets.getBitmapData("img/heal.png"));
        bmp.x = -bmp.width/2;
        bmp.y = -bmp.height/2;
        addChild(bmp);
        this.x = 0;
        this.y = startY;
        // startCoords = Main.player.x + Main.field.x;
        
    }

    public function onFrame() {
        ++progres;
        this.x = Math.min(Math.max(this.progres * (Main.player.x + Main.field.x) / progresMax - Main.field.x, this.x), Main.player.x);
//        this.y = -1 * (1 - Math.sqrt(Math.abs(this.progres - progresMax / 2) / (progresMax / 2))) * (Main.fullStageHeight / 2) + Main.player.y;
        var playerY:Float = Main.player.y;
        if ( this.y > playerY + Main.player.sizeY/4 ) {
            //this.y -= 2;
            this.y -= (progresMax - progres > 15 ) ? 2 : 10;
        }
        if ( this.y < playerY - Main.player.sizeY/4 ) {
            this.y += (progresMax - progres > 15 ) ? 2 : 10;
        }
        if (progres < progresMax / 2) {
            this.y -= 4;
        }
        //this.y = Main.player.y;
        if ((progres > progresMax) && (Math.sqrt(Math.pow(Main.player.x - this.x, 2) + Math.pow(Main.player.y - this.y, 2)) < Main.player.sizeY/2)) {
            Main.healOn();
            Main.player.heal(25);            //refactor this shit out from here
            Main.field.removeChild(this);
            Main.bonuses.remove(this);
        }
    }

}