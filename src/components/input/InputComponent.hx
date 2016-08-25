package components.input;

import luxe.Input;
import luxe.Component;


class InputComponent extends Component {


	public var left:Bool    = false;
	public var right:Bool   = false;
	public var up:Bool      = false;
	public var down:Bool    = false;

	public var jump:Bool    = false;
	public var select:Bool    = false;
	public var attack:Bool    = false;


	public function new():Void {

		super({name : 'InputComponent'});

	}
	
	
}
