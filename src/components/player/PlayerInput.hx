package components.player;

import luxe.Input;
import luxe.Component;
import components.input.InputComponent;


class PlayerInput extends InputComponent {


	public function new():Void {

		super();

	}

	override function init()  {

        if(entity.name == 'player'){
            Luxe.input.bind_key( entity.name + "_left",  Key.key_a );
            Luxe.input.bind_key( entity.name + "_right", Key.key_d );
            Luxe.input.bind_key( entity.name + "_up",    Key.key_w );
            Luxe.input.bind_key( entity.name + "_down",  Key.key_s );
            Luxe.input.bind_key( entity.name + "_jump",  Key.space );
            Luxe.input.bind_key( entity.name + "_fire",  Key.lshift );
        } else if(entity.name == 'player2'){
            Luxe.input.bind_key( entity.name + "_left",  Key.left );
            Luxe.input.bind_key( entity.name + "_right", Key.right );
            Luxe.input.bind_key( entity.name + "_up",    Key.up );
            Luxe.input.bind_key( entity.name + "_down",  Key.down );
            Luxe.input.bind_key( entity.name + "_jump",  Key.rctrl );
            Luxe.input.bind_key( entity.name + "_fire",  Key.rshift );
        } 

	}

	override function update(dt:Float) {

        updateKeys();

	}

    function updateKeys() {

        right = Luxe.input.inputdown( entity.name + "_right" );
        left = Luxe.input.inputdown( entity.name + "_left" );
        up = Luxe.input.inputdown( entity.name + "_up" );
        down = Luxe.input.inputdown( entity.name + "_down" );
        jump = Luxe.input.inputdown( entity.name + "_jump" );

        if(left && right){
            left = right = false;
        }

        if(up && down){
            up = down = false;
        } 

    }


}
