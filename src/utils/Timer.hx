package utils;

class Timer {
	static var timers:Array<Timer> = [];
	
	public static function empty() {
		for (t in timers) {
			t.destroy();
		}
		timers = timers.splice(0, timers.length);
	}
	
	/**
	 * Cycles through timers and calls update() on each one.
	 */
	@:noCompletion public static function update(elapsed:Float):Void {
		for (timer in timers){
			if (timer.active && !timer.finished && timer.timeLimit >= 0){
				timer._update(elapsed);
			}
		}
	}

	public static function schedule(_timeLimit:Float = 1):Timer {
		var t:Timer = new Timer();
		t.start(_timeLimit);
		return t;
	}

	public static function scheduleFrom(_currentTime:Float = 0, _timeLimit:Float = 1):Timer {
		var t:Timer = new Timer();
		t.startFrom(_currentTime, _timeLimit);
		return t;
	}

	/** The amount of milliseconds that have elapsed since the timer was started */
	public var elapsedTime:Float;
	/** How much time the timer was set for. */
	public var timeLimit:Float = 0;
	/** How many loops the timer was set for. 0 means "looping forever". */
	public var loops:Int = 0;
	/** Pauses or checks the pause state of the timer. */
	public var active:Bool = false;
	/** Check to see if the timer is finished. */
	public var finished:Bool = false;

	var _onComplete:Void->Void;
	var _onRepeat:Void->Void;
	var _onUpdate:Void->Void;

	/** Read-only: check how much time is left on the timer. */
	public var timeLeft(get, never):Float;
	/** Read-only: check how many loops are left on the timer. */
	public var loopsLeft(get, never):Int;
	/** Read-only: how many loops that have elapsed since the timer was started. */
	public var elapsedLoops(get, never):Int;
	/** Read-only: how far along the timer is, on a scale of 0.0 to 1.0. */
	public var progress(get, never):Float;

	/** Internal tracker for the loops counting up. */
	var _loopsCounter:Int = 0;
	
	var _inArray:Bool = false;
	
	@:noCompletion public function new() {}

	public function destroy() {
		timers.remove(this);
		active = false;
		finished = true;
		_inArray = false;
		_onComplete = null;
		_onRepeat = null;
		_onUpdate = null;
	}

	public function start(_timeLimit:Float = 1):Timer {
		if (!_inArray) {
			timers.push(this);
			_inArray = true;
		}
		
		active = true;
		finished = false;

		elapsedTime = 0;
		timeLimit = Math.abs(_timeLimit);
		
		loops = 1;
		_loopsCounter = 0;
		return this;
	}

	public function startFrom(_currentTime:Float = 0, _timeLimit:Float = 1):Timer {
		if (!_inArray) {
			timers.push(this);
			_inArray = true;
		}
		
		active = true;
		finished = false;

		elapsedTime = Math.abs(_currentTime);
		timeLimit = Math.abs(_timeLimit);
		
		loops = 1;
		_loopsCounter = 0;
		return this;
	}

	public function reset(_newTime:Float = -1):Timer {
		if (_newTime < 0) {
			_newTime = timeLimit;
		}
		start(_newTime);
		return this;
	}

	public function repeat(_times:Int = 0):Timer {
		if (_times < 0) {
			_times *= -1;
		}
		loops = _times;
		return this;
	}

	public function stop():Void {
		finished = true;
		active = false;
		
		if (_onComplete != null) _onComplete();

		if (_inArray){
			timers.remove(this);
			_inArray = false;
		}
	}

	inline public function elapsed(_t:Float):Bool {
		return elapsedTime >= _t;
	}


	public function onComplete(?_onCompleteFunc:Void->Void):Timer {
		_onComplete = _onCompleteFunc;
		return this;
	}

	public function onRepeat(?_onRepeatFunc:Void->Void):Timer {
		_onRepeat = _onRepeatFunc;
		return this;
	}

	public function onUpdate(?_onUpdateFunc:Void->Void):Timer {
		_onUpdate = _onUpdateFunc;
		return this;
	}

	@:noCompletion public function _update(elapsed:Float):Void {
		elapsedTime += elapsed;
		
		if (_onUpdate != null) _onUpdate();
		
		while ((elapsedTime >= timeLimit) && active && !finished) {
			elapsedTime -= timeLimit;
			_loopsCounter++;
			
			if (loops > 0 && (_loopsCounter >= loops)) {
				stop();
			} else {
				if (_onRepeat != null) _onRepeat();
			}
		}
	}

	inline function get_timeLeft():Float {
		return timeLimit - elapsedTime;
	}
	
	inline function get_loopsLeft():Int {
		return loops - _loopsCounter;
	}
	
	inline function get_elapsedLoops():Int {
		return _loopsCounter;
	}
	
	inline function get_progress():Float {
		return (timeLimit > 0) ? (elapsedTime / timeLimit) : 0;
	}
	
}
