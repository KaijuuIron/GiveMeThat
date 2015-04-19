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
	private static var highlightSpriteGun:TileSprite;
	private static var highlightSpriteHandman:TileSprite;
	private static var highlightUnitToSprite:Map<String,TileSprite> = new Map<String,TileSprite>();
	
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
		trace(next+"!");
	}
	
	public static function attemptGrab():Bool {
		if (( highlightType == "unit" ) && (player.distanceXBetween(highlightedUnit) <= grabRange)) {
			if ( grabbable(highlightedUnit) ) {
				if ( highlightedUnit.unitType == "dog" ) {
					highlightedUnit.kill();
					swapWeapon("dog");
					return true;
				}
			}
		}
		return false;
	}
	
	private static function grabbable(unit:Unit):Bool {
		if (unit.unitType == "dog")	return true;
		if (unit.unitType == "gun")	return true;
		if (unit.unitType == "handman")	return (unit.hp/unit.hpMax < 0.5);
		return false;
	}
	
	public static function updateGrabHighlight() {
		for ( enemy in Main.enemies ) {
			if (grabbable(enemy))  {
				if ( player.distanceXBetween(enemy) < grabRange ) {
					if(!sameHighlight(enemy))	highlightRemove();
					highlightUnit(enemy);
					return;
				}
				if ( player.distanceXBetween(enemy) < grabRange * 3 ) {
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
			if (true || ( highlightedUnit.unitType == "dog" ) || (highlightedUnit.unitType == "gun") || (highlightedUnit.unitType == "handman")) {
				highlightUnitToSprite.get(highlightedUnit.unitType).x = highlightedUnit.currentSprite.x;
				highlightUnitToSprite.get(highlightedUnit.unitType).y = highlightedUnit.currentSprite.y;
				highlightUnitToSprite.get(highlightedUnit.unitType).mirror = highlightedUnit.currentSprite.mirror;
				highlightUnitToSprite.get(highlightedUnit.unitType).alpha = (1 - player.distanceXBetween(highlightedUnit) / (3*grabRange));
			}
		}
	}
	
	private static function highlightRemove() {
		if ( highlightType == "unit" ) {
			highlightUnitToSprite.get(highlightedUnit.unitType).visible = false;
			//if ( highlightedUnit.unitType == "dog" ) {
				//highlightSpriteDog.visible = false;
			//}
			highlightType = "none";
			highlightedUnit = null;
		}
	}
	
	private static function highlightUnit(unit:Unit) {
		if (!sameHighlight(unit)) {
			highlightType = "unit";
			highlightedUnit = unit;
			highlightUnitToSprite.get(highlightedUnit.unitType).visible = true;
		}
		highlightPosUpdate();
	}
	
	private static function sameHighlight(unit:Unit) {
		return (( highlightType == "unit" ) && (highlightedUnit == unit));
	}
	
	public static function init() {
		player = Main.player;
		bodySpriteBasic1 = new TileSprite(Main.layer, "herobasic1");
		bodySpriteBasic2 = new TileSprite(Main.layer, "herobasic2");
		bodySpriteBasic3 = new TileSprite(Main.layer, "herobasic3");
		
		
		highlightSpriteDog = new TileSprite(Main.layer, "evildoglight");
		highlightSpriteDog.visible = false;
		Main.layer.addChildAt(highlightSpriteDog, 0);
		highlightUnitToSprite.set("dog", highlightSpriteDog);
		highlightSpriteGun = new TileSprite(Main.layer, "evilgunlight");
		highlightSpriteGun.visible = false;
		Main.layer.addChildAt(highlightSpriteGun, 0);
		highlightUnitToSprite.set("gun", highlightSpriteGun);		
		highlightSpriteHandman = new TileSprite(Main.layer, "evilhandmanlight");
		highlightSpriteHandman.visible = false;
		Main.layer.addChildAt(highlightSpriteHandman, 0);
		highlightUnitToSprite.set("handman", highlightSpriteHandman);
	}
	
}