#------------------------------------------------------------------------
# runFromMonster            by otaku
#------------------------------------------------------------------------
#  Runs from a designated moster.
#------------------------------------------------------------------------
#  You need to add to your control/config.txt file this line:
#
#    runFromMonster_name <monster name(s)>
# 
#  Example 1: (Run away from Poring)
#
#    runFromMonster_name Poring
#
#  Example 2: (Run away from Poporing and Fabre)
#
#    runFromMonster_name  Poporing, Fabre
#
#  **Do not use this for monsters with a high spawn
# on the map or else your bot will just run around.**
#------------------------------------------------------------------------
#  Licensed under the GNU General Public License v2.0
#------------------------------------------------------------------------

package runFromMonster;

use strict;
use Globals;
use Log qw(warning);
use Utils;

Plugins::register('runFromTarget','kore will try to run from the target',\&unload);

my $hook = Plugins::addHook('packet/actor_display',\&runAway);

sub unload {
	Plugins::delHook('packet/actor_display',$hook);
}

sub runAway {
	my ($self, $args) = @_;
	
	my $type = $args->{object_type};
	my $target = Actor::get($args->{ID})->{name}; # $args->{name} is empty... don't know why
	
	if ($type == 5) {
		return if not existsInList($config{'runFromMonster_name'}, $target); # If the monster is not on the list, do nothing
		consoleWrite("Monster ". $target ." is near! Trying to run...");
		moving(50);
	}
}

sub moving {
	my ($posX,$posY,$map,$tiles_away);
	$posX = $char->{'pos'}{'x'};
	$posY = $char->{'pos'}{'y'};
	$map = $field->baseName;
	$tiles_away = shift;
	
	# Kore will go <$tiles_away> tiles away from the target when he finds a walkable direction
	if ($field->isWalkable($posX+$tiles_away,$posY)) {
		consoleWrite("Taking escape route #1 to: ". $map ." ". ($posX+$tiles_away) .", ". $posY);
		clear();		
		$char->route($map,$posX+$tiles_away,$posY);
		return;
	} elsif ($field->isWalkable($posX-$tiles_away,$posY)) {
		consoleWrite("Taking escape route #2 to: ". $map ." ". ($posX-$tiles_away) .", ". $posY); 
		clear();
		$char->route($map,$posX-$tiles_away,$posY);
		return;
	} elsif ($field->isWalkable($posX,$posY+$tiles_away)) {
		consoleWrite("Taking escape route #3 to: ". $map ." ". $posX .", ". ($posY+$tiles_away)); 
		clear();
		$char->route($map,$posX,$posY+$tiles_away);
		return;
	} elsif ($field->isWalkable($posX,$posY-$tiles_away)) {
		consoleWrite("Taking escape route #4 to: ". $map ." ". $posX .", ". ($posY-$tiles_away)); 
		clear();
		$char->route($map,$posX,$posY-$tiles_away);
		return;
	} else {
		# No walkable tile found, trying a little further away
		return moving($tiles_away+1);
	}
}

sub clear {
	undef @ai_seq;
	undef @ai_seq_args;
}

sub consoleWrite {
	warning "[runFromTarget] ". shift ."\n";
}

return 1;
