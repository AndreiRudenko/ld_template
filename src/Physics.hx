import luxe.Vector;
import physics.Space;

import components.physics.Collider;
import physics.RaycastHit;
import physics.Contact;


class Physics {


	public static var space : Space;

	public static function init() {

		space = new Space();

	}

	public static function destroy() {

		if(space == null) {
			return;
		} 

		space.destroy();
		space = null;

	}

	public static function empty() {

		if(space == null) {
			return;
		}

		space.empty();

	}

	public static inline function AddCollider(collider:Collider){

		space.add(collider);

	}

	public static inline function RemoveCollider(collider:Collider){

		space.remove(collider);

	}

	public static inline function UpdateCollider(collider:Collider){

		Physics.debugStart_Broadphase();

		space.spatialHash.updateCollider(collider);

		Physics.debugEnd_Broadphase();

	}

	/* Find collider contacts */
	public static inline function FindContacts(collider:Collider){

		Physics.debugStart_Broadphase();

		space.findContacts(collider);

		Physics.debugEnd_Broadphase();

	}

	public static inline function ClearContacts(collider:Collider){

		Physics.debugStart_Broadphase();

		space.clearContacts(collider);

		Physics.debugEnd_Broadphase();

	}

// Debug
	public static inline function draw(){

		return space.draw();

	}


	public static var name:String = "__physics";
	public static var time:Float = 0;
	public static var stime:Float = 0;
	static var dbgobj:Dynamic;

	public static var name_CCD:String = "__physics_CCD";
	public static var time_CCD:Float = 0;
	public static var stime_CCD:Float = 0;
	static var dbgobj_CCD:Dynamic;

	public static var name_Broadphase:String = "__physics_Broadphase";
	public static var time_Broadphase:Float = 0;
	public static var stime_Broadphase:Float = 0;
	static var dbgobj_Broadphase:Dynamic;


	public static function debugUpdate(){

		// physics debug
		Luxe.debug.start(name);
		dbgobj = luxe.debug.ProfilerDebugView.lists.get(name);
		Luxe.debug.start(name);
		dbgobj.start -= time;
		Luxe.debug.end(name);
		time = 0;

		// physics debug ccd
		Luxe.debug.start(name_CCD);
		dbgobj_CCD = luxe.debug.ProfilerDebugView.lists.get(name_CCD);
		Luxe.debug.start(name_CCD);
		dbgobj_CCD.start -= time_CCD;
		Luxe.debug.end(name_CCD);
		time_CCD = 0;

		// physics debug Broadphase
		Luxe.debug.start(name_Broadphase);
		dbgobj_Broadphase = luxe.debug.ProfilerDebugView.lists.get(name_Broadphase);
		Luxe.debug.start(name_Broadphase);
		dbgobj_Broadphase.start -= time_Broadphase;
		Luxe.debug.end(name_Broadphase);
		time_Broadphase = 0;

	}

	inline public static function debugStart(){

		stime = Luxe.time;

	}

	inline public static function debugEnd(){

		time += Luxe.time - stime;

	}

	inline public static function debugStart_CCD(){

		stime_CCD = Luxe.time;

	}

	inline public static function debugEnd_CCD(){

		time_CCD += Luxe.time - stime_CCD;

	}

	inline public static function debugStart_Broadphase(){

		stime_Broadphase = Luxe.time;

	}

	inline public static function debugEnd_Broadphase(){

		time_Broadphase += Luxe.time - stime_Broadphase;

	}

	
}
