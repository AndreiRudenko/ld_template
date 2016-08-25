package physics;

import luxe.Vector;

import components.physics.Collider;

import physics.SpatialHash;
import physics.Contact;

import utils.ShapeDrawer;


class Space {


	public var colliderList : Collider;

	public var colliderCount : Float = 0;
	// public var contactsCount : Float = 0;

	public var spatialHash:SpatialHash;


	public function new(?_sizeX:Float, ?_sizeY:Float) {

		spatialHash = new SpatialHash(new Vector(-256, -256), new Vector(Luxe.screen.w + 256, Luxe.screen.h + 256), 32);
		spatialHash.space = this;
		
		colliderList = null;

	}

	public function add(c:Collider){

		// Add to space doubly linked list.
		c.prev = null;
		c.next = colliderList;

		if (colliderList != null) {
			colliderList.prev = c;
		}

		colliderList = c;

	    spatialHash.add(c);
		++colliderCount;

	}

	public function remove(c:Collider){

		// Remove world collider list.
		if (c.prev != null) {
			c.prev.next = c.next;
		}

		if (c.next != null) {
			c.next.prev = c.prev;
		}

		if (c == colliderList) {
			colliderList = c.next;
		}
		
	    spatialHash.remove(c);
	    removeContacts(c);
		--colliderCount;
		
	}

	public function addContact(collider:Collider, otherCollider:Collider){

		// Does a contact already exist?
		var c:Contact = collider.contacts;

		while (c != null){
			if (collider == c.collider && otherCollider == c.otherCollider){
				c.remove = false;

				return;
			}

			c = c.next;
		}

		// Creating new contact
		var contact:Contact = new Contact();

		contact.collider = collider;
		contact.otherCollider = otherCollider;

		// Insert into collider.
		contact.prev = null;
		contact.next = collider.contacts;

		if (collider.contacts != null) {
			collider.contacts.prev = contact;
		}

		collider.contacts = contact;

	}

	public function removeContact(c:Contact){

		// Remove world collider list.
		if (c.prev != null) {
			c.prev.next = c.next;
		}

		if (c.next != null) {
			c.next.prev = c.prev;
		}

		if (c == c.collider.contacts) {
			c.collider.contacts = c.next;
		}

		c.destroy();

	}

	inline function removeContacts(collider:Collider) {

		var c:Contact = collider.contacts;

		while (c != null){
			removeContact(c);
			c = c.next;
		}

	}

	inline public function clearContacts(collider:Collider) {

		var c:Contact = collider.contacts;

		while (c != null){
			if(c.remove) {
				removeContact(c);
				c = c.next;
				continue;
			}

			c.remove = true;// for remove on next check if not updated

			c = c.next;
		}

	}

	inline public function findContacts(collider:Collider):Contact{

	    spatialHash.findContacts(collider);
	    clearContacts(collider);

	    return collider.contacts;

	}

	public function draw(){

		#if debugSpatialHash 

			spatialHash.draw();

		#end

		var _contactsCount:Int = 0;

		var coll:Collider = colliderList;
		var c:Contact;

		while(coll != null) {
			coll.draw();

			c = coll.contacts;

			while(c != null) {
				c.draw();
				_contactsCount++;
				c = c.next;
			}

			coll = coll.next;
		}

        ShapeDrawer.drawText(50, 20, "colliderList : " + colliderCount, 12, true);
        ShapeDrawer.drawText(50, 40, "contacts : " + _contactsCount, 12, true);

        // ShapeDrawer.drawText(50, 20, "colliderList : " + colliderCount, 12, true, Main.hud_batcher);
        // ShapeDrawer.drawText(50, 40, "contacts : " + contactsCount, 12, true, Main.hud_batcher);

	}

	public function destroy(){

		spatialHash.destroy();
		spatialHash = null;
		colliderList = null;

	}

	public function empty(){

		spatialHash.empty();
		colliderList = null;

	}

}
