package physics;


import luxe.Input;
import luxe.Vector;
import luxe.utils.Maths;

import phoenix.geometry.QuadGeometry;
import phoenix.geometry.RectangleGeometry;
import phoenix.geometry.TextGeometry;

import components.physics.Collider;

import physics.collision.IntersectAABB;

import physics.RaycastHit;
import physics.Space;
import physics.AABB;

import utils.ShapeDrawer;


class SpatialHash {


	public var space:Space;

	public var pos:Vector;

		/* the square cell gridLength of the grid. Must be larger than the largest shape in the space. */
	public var cellSize(default, set):UInt;

	public var min(default, null):Vector;
	public var max(default, null):Vector;

	public var width(default, null):Float;
	public var height(default, null):Float;

		/* the world space width */
	public var w (default, null):Int;
		/* the world space height */
	public var h (default, null):Int;

		/* the number of buckets (i.e. cells) in the spatial grid */
	public var gridLength (default, null):Int;
		/* the array-list holding the spatial grid buckets */
	public var grid(default, null) : haxe.ds.Vector<Array<Collider>>;

	var powerOfTwo:UInt;
	var invCellSize:Float;

	// temp objects
	var _tmp_getGridIndexesArray:Array<Int>;
	var _tmp_getCollisionObjectsArray:Array<Collider>;

	#if debugSpatialHash 

		var debugBoxes : haxe.ds.Vector<DebugObject>;

	#end


	public function new( _min:Vector, _max:Vector, _cs:UInt) {

		min = _min.clone();
		max = _max.clone();

		pos = new Vector();

		width = max.x - min.x;
		height = max.y - min.y;

		cellSize = _cs;

		w = Math.ceil(width) >> powerOfTwo;
		h = Math.ceil(height) >> powerOfTwo;

		gridLength = Std.int(w * h);

		grid = new haxe.ds.Vector(gridLength);

		for (i in 0...gridLength) {
			grid[i] = new Array<Collider>();
		}

		space = null;

		// temp 
		_tmp_getGridIndexesArray = [];
		_tmp_getCollisionObjectsArray = [];

		#if debugSpatialHash 

			debugBoxes = new haxe.ds.Vector(gridLength);

			var iw:Int = 0;
			var ih:Int = 0;
			for (i in 0...gridLength) {

				debugBoxes[i] = new DebugObject(new Vector(pos.x + min.x + (cellSize*0.5) + cellSize * iw, pos.x + min.y + (cellSize*0.5) + cellSize * ih), cellSize);

				iw++;
				if(iw >= w){
					iw = 0;
					ih++;
				}
			}

		#end
		
	}

	function set_cellSize(value:UInt):UInt {

		powerOfTwo = numToPowerOfTwo(value);
		cellSize = PowerOfTwoToNum(powerOfTwo);
		invCellSize = 1 / cellSize;

		return cellSize;

	}

	public function add(c:Collider){

		updateIndexes(c, getAreaGridIndexes(c.aabb.min, c.aabb.max ));

	}

	public function remove(c:Collider):Void{

		removeIndexes(c);

	}

	public function updateCollider(c:Collider){

		c.updateAABB();
		updateIndexes(c, getAreaGridIndexes(c.aabb.min, c.aabb.max));

	}

	public function findAllContacts(dt:Float){

		var b:Collider = space.colliderList;

		while(b != null) {
			b.updateAABB();
			updateIndexes(b, getAreaGridIndexes(b.aabb.min, b.aabb.max));
			findContacts(b);
			b = b.next;
		}

	}

	public function empty(){

		var i:Int = 0;

		for (cell in grid) {
			if(cell.length > 0){
				for (co in cell) {
					co.gridIndex.splice(0, co.gridIndex.length);
				}
				cell.splice(0, cell.length);

				#if debugSpatialHash 

					resetCellDebug(i);

				#end

			}
			i++;
		}

	}

	public function destroy(){

		empty();

		#if debugSpatialHash 

			if(debugBoxes != null){
				for (b in debugBoxes) {
					b.box.drop();
					b.text.drop();
				}
			}

			debugBoxes = null;

		#end

		space = null;
		min = null;
		max = null;
		pos = null;
		grid = null;
		_tmp_getGridIndexesArray = null;
		_tmp_getCollisionObjectsArray = null;

	}

// internal api

	inline public function findContacts(collider:Collider) {

		// проверяем все яйчейки
		for (i in collider.gridIndex) {
			// проверяем кто есть в ней
			for (otherCollider in grid[i]) {
				if(collider == otherCollider) {
					continue;
				}
				
				if(!collider.aabb.overlaps(otherCollider.aabb)) {
					continue;
				}
				
				// проверяем на маски
				if(shouldCollide(collider.collisionMask, collider.collisionGroup, otherCollider.collisionMask, otherCollider.collisionGroup)){
					space.addContact(collider, otherCollider); // добавляем
				}
			}
		}

	}

	inline function getContacts(gridIndexes:Array<Int>, layerMask:Int):Array<Collider> {

		var ret:Array<Collider> = _tmp_getCollisionObjectsArray;

		if(ret.length != 0) {
			ret.splice(0, ret.length);
		}
		
		for (i in gridIndexes) {
			for (coll in grid[i]) {
				if(shouldCollideMask(layerMask, coll.collisionGroup)){
					var inArr:Bool = false;
					for (s in ret) {
						if(s == coll){
							inArr = true;
							break;
						}
					}

					if(inArr) continue;
					ret.push(coll);
				}
			}
		}

		return ret;

	}

	inline function getAreaGridIndexes(_min:Vector, _max:Vector):Array<Int> {

		var ret:Array<Int> = _tmp_getGridIndexesArray;

		if(ret.length != 0) {
			ret.splice(0, ret.length);
		}

		if(!overlaps(_min, _max)) {
			return ret;
		}
		
		var aabbMinX:Int = Maths.clampi(getIndex_X(_min.x), 0, w-1);
		var aabbMinY:Int = Maths.clampi(getIndex_Y(_min.y), 0, h-1);
		var aabbMaxX:Int = Maths.clampi(getIndex_X(_max.x), 0, w-1);
		var aabbMaxY:Int = Maths.clampi(getIndex_Y(_max.y), 0, h-1);

		var aabbMin:Int = getIndex1D(aabbMinX, aabbMinY);
		var aabbMax:Int = getIndex1D(aabbMaxX, aabbMaxY);

		ret.push(aabbMin);

		if(aabbMin != aabbMax) {
			ret.push(aabbMax);

			var lenX:Int = aabbMaxX - aabbMinX + 1;
			var lenY:Int = aabbMaxY - aabbMinY + 1;

			for (x in 0...lenX) {
				for (y in 0...lenY) {
					// пропускаем добавленые
					if((x == 0 && y == 0) || (x == lenX-1 && y == lenY-1) ){
						continue;
					}

					ret.push(getIndex1D(x, y) + aabbMin);
				}
			}
		}

		return ret;

	}

	function updateIndexes(c:Collider, _ar:Array<Int>) {

		for (i in c.gridIndex) {
			removeIndex(c, i);
		}

		c.gridIndex.splice(0, c.gridIndex.length);

		for (i in _ar) {
			addIndexes(c, i);
		}

	}

	function removeIndexes(c:Collider){

		for (i in c.gridIndex) {
			removeIndex(c, i);
		}

		c.gridIndex.splice(0, c.gridIndex.length);

	}

	inline function addIndexes(c:Collider, _cellPos:Int){

		grid[_cellPos].push(c);
		c.gridIndex.push(_cellPos);

	}

	inline function removeIndex(c:Collider, _pos:Int) {

		#if debugSpatialHash 

			resetCellDebug(_pos);

		#end
		
		grid[_pos].remove(c);
		// c.gridIndex.remove(_pos);

	}

	// 1D grid
	inline function getIndex1DFromVec(_pos:Vector):Int { // i = x + w * y;  x = i % w; y = i / w;

		return Std.int((Std.int(_pos.x - (pos.x + min.x)) >> powerOfTwo) + w * (Std.int(_pos.y - (pos.y + min.y)) >> powerOfTwo));

	}

	inline function getGridPos_X(_pos:Float):Float {

		return _pos - (pos.x + min.x);

	}

	inline function getGridPos_Y(_pos:Float):Float {

		return _pos - (pos.y + min.y);

	}

	inline function toGridPos(_pos:Vector) {

		_pos.x -= pos.y + min.y;
		_pos.y -= pos.y + min.y;

	}

	inline function getIndex(_pos:Float):Int {

		return Std.int(_pos) >> powerOfTwo;

	}

	inline function getIndex_X(_pos:Float):Int {

		return Std.int((_pos - (pos.x + min.x))) >> powerOfTwo;

	}

	inline function getIndex_Y(_pos:Float):Int {

		return Std.int((_pos - (pos.y + min.y))) >> powerOfTwo;

	}

	inline function getIndex1D(_x:Int, _y:Int):Int { // i = x + w * y;  x = i % w; y = i / w;

		return Std.int(_x + w * _y);

	}

	inline function getVecFromIdx1D(_i:Int):Vector { // i = x + w * y;  x = i % w; y = i / w;

		return new Vector(pos.x + min.x + (Std.int(_i % w) * cellSize + cellSize * 0.5), pos.y + min.y + (Std.int(_i / w) * cellSize + cellSize * 0.5));

	}

	inline function isValidGridIdx2D(_x:Int, _y:Int):Bool {

		if(_x < 0 || _x >= w) return false;
		if(_y < 0 || _y >= h) return false;

		return true;

	}

	inline function isValidGridIdx_X(num:Int):Bool {

		if(num < 0 || num >= w) return false;

		return true;

	}

	inline function isValidGridIdx_Y(num:Int):Bool {

		if(num < 0 || num >= h) return false;

		return true;

	}

	function isPowerOfTwo(num:UInt):Bool{

		return num > 0 && ((num & (num -1))== 0);

	}

	function numToPowerOfTwo(num:Int):Int{

		return Math.round(Math.log(num)/Math.log(2));

	}

	function PowerOfTwoToNum(num:UInt):UInt{

		return 1 << num;

	}

	inline function shouldCollide(mask1:Int, group1:Int, mask2:Int, group2:Int):Bool {

		return (mask1 & group2) != 0 && (group1 & mask2) != 0; // from box2d by Erin Catto

	}

	inline function shouldCollideMask(mask:Int, group:Int):Bool {

		return (mask & group) != 0;

	}

	inline function overlaps(_min:Vector, _max:Vector):Bool {

		if ( _max.x < (pos.x + min.x) || _min.x > (pos.x + max.x) ) return false;
		if ( _max.y < (pos.y + min.y) || _min.y > (pos.y + max.y) ) return false;

		return true;

	}

// DEBUG
	#if debugSpatialHash 

		public function draw(){

			ShapeDrawer.drawBox_MinMax(Vector.Add(pos, min), Vector.Add(pos, max), ShapeDrawer.color_pink);

			for (i in 0...grid.length) {
				if(grid[i].length > 0){

					// var gPos:Vector = getVecFromIdx1D(i).multiplyScalar(cellSize).addScalar(cellSize * 0.5);
					var gPos:Vector = getVecFromIdx1D(i);

					debugBoxes[i].text.transform.pos.copy_from(gPos);
					debugBoxes[i].box.transform.pos.copy_from(gPos);

					// debugBoxes[i].text.visible = true;
					// debugBoxes[i].text.text = "" + grid[i].length;
					debugBoxes[i].box.visible = true;

					if(grid[i].length > 1){
						debugBoxes[i].box.color = ShapeDrawer.color_orange_02;

					} else {
						debugBoxes[i].box.color = ShapeDrawer.color_gray_01;
					}

				}
			}

		}

		function resetCellDebug(_pos:Int){

			// debugBoxes[_pos].text.text = "";
			debugBoxes[_pos].box.color = ShapeDrawer.color_gray_01;

			debugBoxes[_pos].text.visible = false;
			debugBoxes[_pos].box.visible = false;

		}

	#end


}


#if debugSpatialHash 

	class DebugObject {

		public var text:TextGeometry;
		public var box:RectangleGeometry;


		public function new(_pos:Vector, _size:Float){

			box = Luxe.draw.rectangle({
				x : _pos.x,
				y : _pos.y,
				w : _size,
				h : _size,
				origin : new Vector(_size*0.5,_size*0.5),
				visible : false,
				color : ShapeDrawer.color_gray_01
			});

			text = Luxe.draw.text({
				pos : _pos,
				text : "",
				visible : false,
				point_size : 12
			});

		}

	}

#end