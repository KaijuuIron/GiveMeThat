package ;

/**
 * ...
 * @author Al
 */
class AI
{

	public var followPlayer:Bool;
	public var shootDist:Float;
	public var followDist:Float;
	public var sightDist:Float;
	var alternativeTarget:Unit;
	public function new() 
	{
		followPlayer = true;
		followDist = 0;
	}
	
	public function tick(unit:Unit) {
		var target:Unit = null;		
		if ( unit.playerDetected || unit.bored ) {
			if ( unit.distanceTo(Main.player) - unit.sizeX/2 - Main.player.sizeX/2 < sightDist ) {
				if ( followPlayer ) {
					target = Main.player;
					unit.playerDetected = true;
				}
			}
		} else {
			if ( unit.distanceTo(Main.player) - unit.sizeX/2 - Main.player.sizeX/2 < Main.fullStageWidth * 0.2 ) {
				if ( followPlayer ) {
					target = Main.player;
					unit.playerDetected = true;
				}
			}
		}
		if ( target == null ) {
			if ( unit.infected ) {
				target = selectAltTarget(unit);
			}
		}
		if ( target != null ) {
			if ( Math.abs(unit.x - target.x) - unit.sizeX/2 - target.sizeX/2 > followDist ) {
				if ( unit.x < target.x ) {
					unit.moveDir(1);
				} else {
					unit.moveDir(-1);
				}
			}
			unit.bored = false;
		} else {
			target = Main.player;
		}				
		if ( unit.infected ) {
			var angleToTarget:Float = Math.atan2(target.y - unit.y, target.x - unit.x);
			if (( unit.distanceTo(target) < shootDist )) {
				unit.shoot(angleToTarget);
				unit.bored = false;
			}			
			if ( unit.bored ) {
				if ( unit.canMoveTo(unit.x + 2 * unit.movespeed * unit.aiDir, unit.y) ) {
					unit.moveDir(unit.aiDir);
				}
			}
			if ( Main.framesPassed % 120 == 0 ) {
				checkBoredom(unit);
			}
		} else {
			if ( Main.framesPassed - unit.lastDamagedTime > 120 ) {
				if (unit.x > unit.sizeX / 2 + 16 ) {
					unit.moveDir( -1);
				}
			}
		}
	}
	
	public function checkBoredom(unit:Unit) {
		unit.bored = ( Math.abs(unit.x - unit.prevPosX) < 100 );
		unit.aiDir = (Math.random() < 0.5) ? 1 : -1;
		unit.prevPosX = unit.x;
	}
	
	private function selectAltTarget(me:Unit):Unit {
		var target:Unit = null;
		var dist:Float = Main.fieldWidthTotal;
		for ( candidate in Main.enemies ) {
			if ( candidate.infected != me.infected ) {
				var tmpDist:Float = candidate.distanceTo(me);
				if ( tmpDist < dist ) {
					dist = tmpDist;
					target = candidate;
				}
			}
		}
		if ( dist < sightDist ) {
			return target;
		}
		return null;
	}
}