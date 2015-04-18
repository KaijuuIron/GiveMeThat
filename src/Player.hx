package ;
import aze.display.TileSprite;
/**
 * ...
 * @author Al
 */
class Player
{
	private static var player:Unit;
	
	public static var grabRange:Float = 100;
	
	public static var highlightType:String = "none";
	public static var highlightedUnit:Unit;
	private static var highlightSpriteDog:TileSprite;
	
	private static var bodySpriteBasic1:TileSprite;
	private static var bodySpriteBasic2:TileSprite;
	private static var bodySpriteBasic3:TileSprite;
	
	public static function dropWeapon() {
		player.dmg = Main.playerBaseDmg;
		player.ranged = false;
		player.spriteBody1 = bodySpriteBasic1;
		player.spriteBody2 = bodySpriteBasic2;
		player.spriteBody3 = bodySpriteBasic3;
		var animState:Int = player.animState;
		player.animState = 0;
		player.setAnimTo(animState);
	}
	
	public static function swapWeapon(next:String) {
		trace("dog!");
	}
	
	public static function attemptGrab() {		
		if ( highlightType == "unit" ) {
			if ( highlightedUnit.unitType == "dog" ) {
				highlightedUnit.kill();
				swapWeapon("dog");
			}
		}
	}
	
	public static function updateGrabHighlight() {
		for ( enemy in Main.enemies ) {
			if ( enemy.unitType == "dog" ) {
				if ( player.distanceXBetween(enemy) < grabRange ) {
					if(!sameHighlight(enemy))	highlightRemove();
					highlightUnit(enemy);
					return;
				}
			}
		}
		highlightRemove();
	}
	
	public static function highlightPosUpdate() {
		if ( highlightType == "unit" ) {
			if ( highlightedUnit.unitType == "dog" ) {
				highlightSpriteDog.x = highlightedUnit.currentSprite.x;
				highlightSpriteDog.y = highlightedUnit.currentSprite.y;
				highlightSpriteDog.mirror = highlightedUnit.currentSprite.mirror;
				highlightSpriteDog.alpha = (1 - player.distanceXBetween(highlightedUnit) / grabRange);
			}
		}
	}
	
	private static function highlightRemove() {
		if ( highlightType == "unit" ) {
			if ( highlightedUnit.unitType == "dog" ) {
				highlightSpriteDog.visible = false;
			}
			highlightType = "none";
			highlightedUnit = null;
		}
	}
	
	private static function highlightUnit(unit:Unit) {
		if (!sameHighlight(unit)) {
			highlightType = "unit";
			highlightedUnit = unit;
			highlightSpriteDog.visible = true;
		}
		highlightPosUpdate();
	}
	
	private static function sameHighlight(unit:Unit) {
		return (( highlightType == "unit" ) && (highlightedUnit == unit));
	}
	
	public static function init() {
		player = Main.player;
		bodySpriteBasic1 = new TileSprite(Main.layer, "dog1");
		bodySpriteBasic2 = new TileSprite(Main.layer, "dog2");
		bodySpriteBasic3 = new TileSprite(Main.layer, "dog3");
		
		highlightSpriteDog = new TileSprite(Main.layer, "evildoglight");
		highlightSpriteDog.visible = false;
		Main.layer.addChildAt(highlightSpriteDog, 0);
	}
	
}