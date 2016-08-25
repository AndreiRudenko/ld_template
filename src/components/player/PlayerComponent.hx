package components.player;

import luxe.Component;


class PlayerComponent extends Component {


	public var playerName:String = 'UnnamedPlayer';
	public var team:Int = 0;


	public function new() {

		super({name : 'PlayerComponent'});

	}


}
