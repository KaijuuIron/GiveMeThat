package ;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.Lib;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import openfl.Assets;

/**
 * ...
 * @author Al
 */

class Main extends Sprite 
{
	public static var layer:TileLayer;
	var inited:Bool;
	public static var framesPassed:Int = 0;
	static var pause:Bool = false;
	
	var aiSimpleFollow:AI;
	var aiSimpleRanged:AI;
	
	public static var fullStageWidth:Int;	
	public static var fullStageHeight:Int;
	public static var fieldHeightTotal:Int;
	public static var fieldWidthTotal:Int;
	public static var screenDX:Int = 0;

	public static var field:Sprite;
	public static var player:Unit = null;
	public static var playerBaseDmg:Int = 5;
	public static var playerShootOrder:Bool = false;
	public static var collidables:Array<Collidable>;
	public static var enemies:Array<Unit>;
	public static var corpses:List<Corpse>;
	public static var particles:List<ExpandingParticle> = new List<ExpandingParticle>();
	
	public static var platfromSize:Int = 320;
	public static var stageLength:Int = 100;
	
	static var globalFilter:Sprite;
	static var hpBar:Sprite;
	
	public static var mainInstance;
	
	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		mainInstance = this;
		inited = true;
		fullStageWidth = stage.stageWidth;
		fullStageHeight = stage.stageHeight;
		fieldHeightTotal = fullStageHeight;
		fieldWidthTotal = platfromSize * stageLength;
		
		var bmp = Assets.getBitmapData("img/bg0.png");
		var sheet:TilesheetEx = new TilesheetEx(bmp);			
		var r:Rectangle = cast bmp.rect.clone();
		
		field = new Sprite();
		addChildAt(field, 0);		
				
		initSheet(sheet);
		layer = new TileLayer(sheet, false);
		field.addChildAt(layer.view, 0);		
		layer.x = 0;
		layer.y = 0;
		var back = new TileSprite(layer, "back");
		back.mirror = 1;
		back.x = fullStageWidth / 2;
		back.y = fullStageHeight / 2;
		field.addChildAt(new Bitmap(bmp), 0);
		
		globalFilter = new Sprite();
		resetGlobalFilter();
		addChild(globalFilter);
		
		initPlatforms();
		
		
		hpBar = new Sprite();
		//hpBar.addChild(new Bitmap(Assets.getBitmapData("img/frame.png")));
		hpBar.graphics.beginFill(0x00ff00);
		hpBar.graphics.drawRect(0, 0, 100, 10);
		hpBar.graphics.endFill();
		hpBar.x = 50;
		hpBar.y = 50;		
		addChild(hpBar);
		
		//AI setup
		aiSimpleFollow = new AI();
		aiSimpleFollow.shootDist = platfromSize * 0.4;
		aiSimpleFollow.followDist = platfromSize * 0.2;
		aiSimpleFollow.sightDist = platfromSize * 2;
		
		aiSimpleRanged = new AI();
		aiSimpleRanged.shootDist = platfromSize * 2;
		aiSimpleRanged.followDist = platfromSize * 1;
		aiSimpleRanged.sightDist = platfromSize * 3;
		
		collidables = new Array<Collidable>();
		enemies = new Array<Unit>();
		corpses = new List<Corpse>();
				
		player = new Unit();
		player.sizeX = 80;
		player.sizeY = 80;
		player.movespeed = 8;
		player.hpMax = 100;
		player.hp = player.hpMax;
		player.dmg = playerBaseDmg;
		player.ranged = false;		
		player.spriteLegs1 = new TileSprite(layer, "dogLeg1");
		player.spriteLegs2 = new TileSprite(layer, "dogLeg2");
		player.spriteLegsJump = new TileSprite(layer, "dogLeg3");
		Player.init();
		Player.dropWeapon();
		addUnit(player, (1 + 0.5) * platfromSize);
		trackPlayerHp();
		
		spawnUnit("dog", (2 + 0.5) * platfromSize);
		
		addEventListener(Event.ENTER_FRAME, onFrame);		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onUp);
	}

	function initSheet(sheet:TilesheetEx) {
		//addDefToSheet(sheet, "back", "img/bg0.png");
		addDefToSheet(sheet, "dog1", "img/dogbody1.png");
		addDefToSheet(sheet, "dog2", "img/evildogbody2.png");
		addDefToSheet(sheet, "dog3", "img/evildogbody3.png");		
		addDefToSheet(sheet, "dogLeg1", "img/doglegs1.png");
		addDefToSheet(sheet, "dogLeg2", "img/doglegs2.png");
		addDefToSheet(sheet, "dogLeg3", "img/doglegs3.png");
		addDefToSheet(sheet, "evildog1", "img/evildogbody1.png");
		addDefToSheet(sheet, "evildog2", "img/evildogbody2.png");
		addDefToSheet(sheet, "evildog3", "img/evildogbody3.png");
		addDefToSheet(sheet, "evildogLeg1", "img/doglegs1.png");
		addDefToSheet(sheet, "evildogLeg2", "img/doglegs2.png");
		addDefToSheet(sheet, "evildogLeg3", "img/doglegs3.png");
		addDefToSheet(sheet, "evildoglight", "img/evildoglight.png");
	}
	
	function addDefToSheet(sheet:TilesheetEx, name:String, bmp:String) {
		var bmp = Assets.getBitmapData(bmp);
		var r:Rectangle = cast bmp.rect.clone();
		sheet.addDefinition(name, r, bmp);
	}
	
	static var platformsMap:Array<Int>;
	static function initPlatforms() {
		platformsMap = generateMap(stageLength);//[50, 100, 200, 50, 150, 150, 150, 100, 200, 300, 50, 50, 50];
		for ( i in 0...platformsMap.length ) {
			var bmp = new Bitmap(Assets.getBitmapData("img/tile1.png"));
			bmp.y = fullStageHeight - platfromHeightAt(i * platfromSize);
			bmp.x = i * platfromSize;
			field.addChildAt(bmp, 1);
		}
	}
	public static function generateMap(length:Int):Array<Int> {
		var map = new Array<Int>();
		var i = 0;
		var curPlatform = 15;
		var random:Int;

		map.push(curPlatform);

		while (i <= length) {
			random = Random.int(15, fullStageHeight);
			curPlatform = (random - map[map.length-1] > 150) ? 150 : random;
			map.push(curPlatform);
			i++;
		}

		return map;
	}
	public static function platfromHeightAt(x:Float):Int {
		var index = Math.floor(x / platfromSize);
		return platformsMap[index];
	}
	public static function plaformLeftBorder(x:Float):Float {
		return platfromSize * Math.floor(x / platfromSize);
	}
	public static function plaformRightBorder(x:Float):Float {
		return platfromSize * Math.ceil(x / platfromSize);
	}
	
	public static function addUnit(unit:Unit, x:Float) {		
		unit.currentSprite = unit.spriteBody1;
		unit.currentSpriteLegs = unit.spriteLegs1;
		field.addChild(unit);
		unit.x = x;
		unit.y = fullStageHeight - platfromHeightAt(x) - unit.sizeY / 2;
		unit.draw();
		collidables.push(unit);
		if ( unit != player ) {
			enemies.push(unit);
		}
	}
	
	public function spawnUnit(monsterType:String,x:Float) {
		
		var newMonster = new Unit();				
		newMonster.unitType = monsterType;
		if ( newMonster.unitType == "dog" ) {
			newMonster.sizeX = 80;
			newMonster.sizeY = 80;
			newMonster.movespeed = 6;
			newMonster.hpMax = 10;
			newMonster.dmg = 5;
			newMonster.attackSpeed = 20;
			newMonster.ranged = false;
			newMonster.ai = aiSimpleFollow;
			newMonster.hp = newMonster.hpMax;
			//sprite
			
			newMonster.spriteBody1 = new TileSprite(layer, "evildog1");
			newMonster.spriteBody2 = new TileSprite(layer, "evildog2");
			newMonster.spriteBody3 = new TileSprite(layer, "evildog3");
			newMonster.spriteLegs1 = new TileSprite(layer, "evildogLeg1");
			newMonster.spriteLegs2 = new TileSprite(layer, "evildogLeg2");
			newMonster.spriteLegsJump = new TileSprite(layer, "evildogLeg3");
			//layer.addChild(sprite);
		}
		/*if ( newMonster.unitType == "default" ) {
			newMonster.spriteDY = -1;
			newMonster.shadow = new Bitmap(Assets.getBitmapData("img/enemy_melee_shadow.png"));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/enemy_melee_01.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/enemy_melee_02.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/enemy_melee_03.png")));
		}*/
		Main.addUnit(newMonster, x);
	}
	
	public static function trackPlayerHp() {
		hpBar.scaleX = (1 - player.hp / player.hpMax);
	}
	
	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	static function resetGlobalFilter() {
		globalFilter.graphics.clear();
		globalFilter.graphics.beginFill(0x0000ff, 0.05);
		globalFilter.graphics.drawRect(0, 0, fullStageWidth, fullStageHeight);
		globalFilter.graphics.endFill();
		globalFilter.alpha = 1.0;
	}
	function onFrame(e) {				
		layer.render();		
		/*if ( pause && tutotalOn && (tutotalLessonCurrent == 1 )) {
			if ( keymap.get(37) || keymap.get(65) ) continueGame(); 
			if ( keymap.get(38) || keymap.get(87) ) continueGame(); 
			if ( keymap.get(39) || keymap.get(68) ) continueGame(); 
			if ( keymap.get(40) || keymap.get(83) ) continueGame(); 		
		}*/
		if ( pause )	return;		
		++framesPassed;
		
		var dx:Int = 0;
		var dy:Int = 0;
		if ( keymap.get(37) || keymap.get(65) ) --dx; 
		if ( keymap.get(38) || keymap.get(87) ) --dy; 
		if ( keymap.get(39) || keymap.get(68) ) ++dx; 
		if ( keymap.get(40) || keymap.get(83) ) ++dy; 		
		if ( dx > 0 ) {
			player.moveDir(1);
		}
		if ( dx < 0 ) {
			player.moveDir( -1);
		}		
		if ( playerShootOrder ) {
			player.shoot(player.lastDirection>0?0:Math.PI);
		}
		for ( enemy in enemies ) {
			enemy.ai.tick(enemy);
		}
		for ( object in collidables ) {			
			object.tick();
			for ( another in collidables ) {
				if (( object != another ) && ((object.flying == another.flying) || (object.type == "bullet"))) {
					if ( object.checkCollizion(another) ) {
						if (( object.type == "unit" ) && (object.type == another.type)) {
							var dist:Float = 8;
							object.push(Math.atan2(another.y - object.y, another.x - object.x), -dist);
							another.push(Math.atan2(another.y - object.y, another.x - object.x), dist);
						}
						if ( object.type == "bullet" ) {
							if (( object.source == Main.player ) || (another == Main.player)) {
							if ( another.type == "unit" ) {
								if ( !object.collizionGroup.exists(another) ) {
									object.collizionGroup.set(another, framesPassed);
									another.takeDamage(object.dmg);
									if (object.destroyAfterHit)	object.destroy();
								}
							}
							}
						}
					}
				}
			}			
		}
		
		for ( corpse in corpses ) {
			corpse.decay();
		}
		
		for ( p in particles ) {
			p.tick();
		}
		traceCamera();
		Player.updateGrabHighlight();
	}
	
	function traceCamera() {
		if ( player.x + field.x > fullStageWidth * 0.7 ) {
			field.x -= Main.player.movespeed;			
			if (field.x < -fieldWidthTotal+fullStageWidth ) field.x = -fieldWidthTotal+fullStageWidth;
		}
		if ( player.x + field.x < fullStageWidth * 0.3 ) {
			field.x += Main.player.movespeed;
			if (field.x > 0 ) field.x = 0;
		}
	}
	
	static var keymap:Map<Int,Bool> = new Map<Int,Bool>();
	
	function onDown(e) {	
		//trace(e.keyCode);
		keymap.set(e.keyCode, true);						
		if (e.keyCode == 32) {
			//space
		}
		if ((e.keyCode == 38 ) || (e.keyCode == 87)) {
			player.jump();
		}
		if (e.keyCode == 40 ) {
			
		}
		if (e.keyCode == 37 ) {
			
		}
		if ( e.keyCode == 79 ) {
			//Main.resetGame();
		}
		
		if ( e.keyCode == 82 ) {
			//R
		}
		if ( e.keyCode == 69 ) {
			//E
		}
		if ( e.keyCode == 84 ) {
			//T
			
		}
		if ( e.keyCode == 74 ) {
			//J
			playerShootOrder = true;
		}
		if ( e.keyCode == 75 ) {
			//K
			Player.attemptGrab();
		}
	}
	
	function onUp(e) {
		keymap.set(e.keyCode, false);
		if (e.keyCode == 32 ) {
			//space
		}
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
