package utils;

import luxe.Text;
import luxe.Color;
import luxe.Vector;
import luxe.Log.*;
import luxe.options.TextOptions;

class FPS extends Text {

    public function new( ?_options:luxe.options.TextOptions ) {

        def(_options, {});
        def(_options.name, "fps");
        def(_options.pos, new Vector(Luxe.screen.w - 5, 5));
        def(_options.point_size, 14);
        def(_options.align, TextAlign.right);
        _options.depth = 1000;
        super(_options);

    } //new

    public override function update(dt:Float) {

        // text = 'fps : ' + Math.round(1.0/dt);
        text = 'FPS : ' + Math.round(1.0/Luxe.debug.dt_average);

    } //update

} //FPS
