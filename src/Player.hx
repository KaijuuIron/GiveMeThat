package ;
import aze.display.TileSprite;
import flash.display.Sprite;
/**
 * ...
 * @author Al
 */
class Player
{
	private static var player:Unit;
	
	public static var grabRange:Float = 100;
    private static var attackCharges:Int = 0;
    public static var playerWeapon:String = "fists";
    public static var strikeAreaX:Float;
    public static var strikeAreaY:Float;
    
	
	public static var highlightType:String = "none";
	public static var highlightedUnit:Unit;
	private static var highlightSpriteDog:TileSprite;
	private static var highlightSpriteGun:TileSprite;
	private static var highlightSpriteHandman:TileSprite;
	private static var highlightUnitToSprite:Map<String,TileSprite> = new Map<String,TileSprite>();
	
	private static var bodySpriteBasic1:TileSprite;
	private static var bodySpriteBasic2:TileSprite;
	private static var bodySpriteBasic3:TileSprite;
    private static var bodySpriteDog1:TileSprite;
	private static var bodySpriteDog2:TileSprite;
	private static var bodySpriteDog3:TileSprite;    
    private static var bodySpriteGun1:TileSprite;
	private static var bodySpriteGun2:TileSprite;
	private static var bodySpriteGun3:TileSprite;    
    private static var bodySpriteHand1:TileSprite;
	private static var bodySpriteHand2:TileSprite;
	private static var bodySpriteHand3:TileSprite;
	
	public static function dropWeapon() {
        swapWeapon("fists");
	}
	
	public static function swapWeapon(next:String) {
        if ( next == "fists" ) {            
            player.dmg = Main.playerBaseDmg;
            player.ranged = false;
            player.spriteBody1 = bodySpriteBasic1;
            player.spriteBody2 = bodySpriteBasic2;
            player.spriteBody3 = bodySpriteBasic3;
            strikeAreaX = 100;
            strikeAreaY = 200;
        }
		if ( next == "dog" ) {
            attackCharges = 2;
            player.dmg = 20;
            player.ranged = false;
            strikeAreaX = 100;
            strikeAreaY = 200;
            player.spriteBody1 = bodySpriteDog1;
            player.spriteBody2 = bodySpriteDog2;
            player.spriteBody3 = bodySpriteDog3;
        }        
        
		if ( next == "gun" ) {
            attackCharges = 5;
            player.dmg = 10;
            player.ranged = true;
            strikeAreaX = 100;
            strikeAreaY = 200;
            player.spriteBody1 = bodySpriteGun1;
            player.spriteBody2 = bodySpriteGun2;
            player.spriteBody3 = bodySpriteGun3;
        }        
        
		if ( next == "hand" ) {
            attackCharges = 4;
            player.dmg = 25;
            player.ranged = false;
            strikeAreaX = 150;
            strikeAreaY = 200;
            player.spriteBody1 = bodySpriteHand1;
            player.spriteBody2 = bodySpriteHand2;
            player.spriteBody3 = bodySpriteHand3;
        }        
        var animState:Int = player.animState;
        player.animState = 0;
        player.setAnimTo(animState);
        playerWeapon = next;        
        player.positionSprites();
        if ( player.currentSprite != null ) {
            player.currentSprite.mirror = player.lastMirrorState;
        }
	}
    
    public static function useAttackCharge() {
        if ( playerWeapon == "fists" )  return;
        --attackCharges;
        if ( attackCharges <= 0 )   dropWeapon();
    }
	
	public static function attemptGrab():Bool {
		if (( highlightType == "unit" ) && (player.distanceXBetween(highlightedUnit) <= grabRange)) {
			if ( grabbable(highlightedUnit) ) {
				if ( highlightedUnit.unitType == "dog" ) {
					highlightedUnit.removeFromGame();
					swapWeapon("dog");
					return true;
				}
                if ( highlightedUnit.unitType == "gun" ) {
					highlightedUnit.destroyBody();
					swapWeapon("gun");
					return true;
				}
                if ( highlightedUnit.unitType == "handman" ) {
					highlightedUnit.destroyBody();
					swapWeapon("hand");
					return true;
				}
			}
		}
		return false;
	}
	
	private static function grabbable(unit:Unit):Bool {
        if ( unit.noBody )  return false;
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
   
    private static function registerSprite(sprite:TileSprite) {
        Main.layer.addChild(sprite);
        sprite.visible = false;
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
    
    public static function initWeapons() {        
        bodySpriteDog1 = new TileSprite(Main.layer, "herodog1");
        registerSprite(bodySpriteDog1);
        bodySpriteDog2 = new TileSprite(Main.layer, "herodog2");
        registerSprite(bodySpriteDog2);
        bodySpriteDog3 = new TileSprite(Main.layer, "herodog3");
        registerSprite(bodySpriteDog3);
        
        bodySpriteGun1 = new TileSprite(Main.layer, "herogun1");
        registerSprite(bodySpriteGun1);
        bodySpriteGun2 = new TileSprite(Main.layer, "herogun2");
        registerSprite(bodySpriteGun2);
        bodySpriteGun3 = new TileSprite(Main.layer, "herogun3");
        registerSprite(bodySpriteGun3);
        
        bodySpriteHand1 = new TileSprite(Main.layer, "herohand1");
        registerSprite(bodySpriteHand1);
        bodySpriteHand2 = new TileSprite(Main.layer, "herohand2");
        registerSprite(bodySpriteHand2);
        bodySpriteHand3 = new TileSprite(Main.layer, "herohand3");
        registerSprite(bodySpriteHand3);
    }
	
}