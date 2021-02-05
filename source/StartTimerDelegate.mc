using Toybox.WatchUi;
using Toybox.System;
using Toybox.Timer;
using Toybox.Attention as Attention;

class StartTimerData
{
	const BASE_TIME = 60 * 5;
	var TimeRemaining = BASE_TIME;
	var IsPaused = false;
}

class StartTimerDelegate extends WatchUi.BehaviorDelegate {
	
	const STATE_MINUTE = 0;
	const STATE_SIGNAL = 1;
	const STATE_COUNTDOWN = 2;
	const STATE_START = 3;
	const STATE_STARTED = 4;
	
	var updateTimerData;
	var updateTimer;
	var timeOfStart = 0.0;
	
	hidden var vibes = false;
	hidden var tones = false;

    function initialize(timerData) {
        BehaviorDelegate.initialize();
        System.println("StartTimerDelegate.initialize");
        
        updateTimerData = timerData;
    	updateTimerData.IsPaused = true;
        
        updateTimer = new Timer.Timer();
    	
    	timeOfStart = System.getTimer();
    	
    	if(Attention has :VibeProfile && vibes == false) {
			vibes = [
				[ new Attention.VibeProfile(30, 300) ], // STATE_MINUTE
				[ new Attention.VibeProfile(50, 500) ], // STATE_SIGNAL
				[ new Attention.VibeProfile(50, 300) ], // STATE_COUNTDOWN
				[ new Attention.VibeProfile(50, 1000) ], // STATE_START
				false // STATE_STARTED
			];
		}

		if(Attention has :playTone && tones == false) {
			tones = [
				false, // STATE_MINUTE
				Attention.TONE_ALARM, // STATE_SIGNAL
				Attention.TONE_MSG, // STATE_COUNTDOWN
				Attention.TONE_ALARM, // STATE_START
				Attention.TONE_ALARM // STATE_STARTED
			];
		}
    }
    
    function toggleTimer() {
    	updateTimerData.IsPaused = !updateTimerData.IsPaused;
    	if (!updateTimerData.IsPaused) {
	   	 	updateTimer.start(method(:timerCallback), 1000, true);
    	}
    	else {
    		updateTimer.stop();
    	}
    	WatchUi.requestUpdate();
    }
    
    function resyncTimer() {
    	if (!updateTimerData.IsPaused) {
    		updateTimer.stop();
	   	 	updateTimer.start(method(:timerCallback), 1000, true);
    	}
    }

	function notify(state) {
		if (!updateTimerData.IsPaused) {
			if(vibes != false && vibes[state] != false) {
				Attention.vibrate(vibes[state]);
			}
	
			if(tones != false && tones[state] != false) {
				Attention.playTone(tones[state]);
			}
		}
	}
	
	function onTimerChange() {
		// vibrate
		if(updateTimerData.TimeRemaining == 0) { // pulse at start
			notify(STATE_START);
		} else {
			var isMainMinute = (updateTimerData.TimeRemaining % 60) == 0;
			if(isMainMinute) { // pulse on minute
				var isSignalMinute = false;
				if(isMainMinute) {
					var min = updateTimerData.TimeRemaining / 60;
					if(min == 5 || min == 4 || min == 1) { // tone on signal
						isSignalMinute = true;
					}
				}
				notify(isSignalMinute ? STATE_SIGNAL : STATE_MINUTE);
			}
			else if (updateTimerData.TimeRemaining <= 30) {
				if (updateTimerData.TimeRemaining < 10) {
					notify(STATE_COUNTDOWN);
				}
				else {
					if ((updateTimerData.TimeRemaining % 10) == 0){
						notify(STATE_SIGNAL);
					}
				}
			}
		}
		
    	if (updateTimerData.TimeRemaining <= 0.0) {
    		updateTimer.stop();
    		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    	}
    	else {
    		WatchUi.requestUpdate();
    	}
	}
	
    function timerUpdate() {
    	updateTimerData.TimeRemaining--;
    	onTimerChange();
    }
    
    function timerCallback() {
	  	timerUpdate();
	}
    
    function onKey(evt)
	{
		System.println("StartTimerDelegate.onKey");
		System.println(" ->" + evt.getKey());  // e.g. KEY_MENU = 7
        System.println(" ->" + evt.getType()); // e.g. PRESS_TYPE_DOWN = 0
        if (evt.getKey() == KEY_ENTER) {
        	toggleTimer();
			return true;
		}
        else if (evt.getKey() == KEY_ESC) {
			updateTimerData.TimeRemaining -= updateTimerData.TimeRemaining % 60;
			resyncTimer();
			onTimerChange();
			return true;
		}
		else if (evt.getKey() == KEY_UP) {
			updateTimerData.TimeRemaining += 60;
   			onTimerChange();
			return true;
 		}
		else if (evt.getKey() == KEY_DOWN) {
			updateTimerData.TimeRemaining -= 60;
 		  	onTimerChange();
			return true;
 		}
		return false;
	}
}