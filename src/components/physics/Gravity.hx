package components.physics;

import luxe.Component;

import components.physics.Collider;


class Gravity extends Component{


    public var active:Bool = true;

    public var gravityScale:Float = 1;

    public var x:Float = 0;
    public var y:Float = 0;

    var collider:Collider;


    public function new(_x:Float = 0, _y:Float = 0){

        super({name : "Gravity"});

        x = _x;
        y = _y;

    }

    override public function init() {

        collider = get("Collider");

        if(collider == null) {
            throw(entity.name + " must have Collider component");
        }

    }    

    override public function onremoved() {

        collider = null;

    }

    override public function update(dt:Float) {
        
        if(!active){
            return;
        }

        collider.velocity.x += gravityScale * x * dt;
        collider.velocity.y += gravityScale * y * dt;

    }


}
