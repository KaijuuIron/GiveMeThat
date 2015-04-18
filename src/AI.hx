package ;

/**
 * ...
 * @author Al
 */
class AI
{

	var followPlayer:Bool;
	public var shootDist:Float;
	public var followDist:Float;
	public var sightDist:Float;
	public function new() 
	{
		followPlayer = true;
		followDist = 0;
	}
	
	public function tick(unit:Unit) {
		var angleToPlayer:Float = Math.atan2(Main.player.y - unit.y, Main.player.x - unit.x);
		if (  unit.distanceTo(Main.player) - unit.sizeX/2 - Main.player.sizeX/2 < sightDist ) {
			if ( followPlayer ) {
				if ( Math.abs(unit.x - Main.player.x) - unit.sizeX/2 - Main.player.sizeX/2 > followDist ) {
					if ( unit.x < Main.player.x ) {
						unit.moveDir(1);
					} else {
						unit.moveDir(-1);
					}
				}
				unit.bored = false;
			}
			if (( unit.distanceTo(Main.player) < shootDist )) {
				unit.shoot(angleToPlayer);
			}
		}
		if ( unit.bored ) {
			if ( unit.canMoveTo(unit.x + 2 * unit.movespeed * unit.aiDir, unit.y) ) {
				unit.moveDir(unit.aiDir);
			}
		}
		if ( Main.framesPassed % 120 == 0 ) {
			checkBoredom(unit);
		}
	}
	
	public function checkBoredom(unit:Unit) {
		unit.bored = ( Math.abs(unit.x - unit.prevPosX) < 100 );
		unit.aiDir = (Math.random() < 0.5) ? 1 : -1;
		unit.prevPosX = unit.x;
	}
	
}