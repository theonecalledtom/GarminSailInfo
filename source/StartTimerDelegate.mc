using Toybox.WatchUi;
using Toybox.System;
using Toybox.Timer;

class StartTimerData
{
	const BASE_TIME = 60.0 * 5.0;
	var TimeToUse = BASE_TIME;
	var TimeRemaining = BASE_TIME;
}

class StartTimerDelegate extends WatchUi.BehaviorDelegate {
	
	var updateTimerData;
	var updateTimer;
	var timeOfStart = 0.0;

    function initialize(timerData) {
        BehaviorDelegate.initialize();
        System.println("StartTimerDelegate.initialize");
        
        updateTimerData = timerData;
        
        updateTimer = new Timer.Timer();
   	 	updateTimer.start(method(:timerCallback), 1000, true);
    
    	timeOfStart = System.getTimer();
    }

    function timerUpdate() {
    	var timeSpent = System.getTimer() - timeOfStart; 
    	updateTimerData.TimeRemaining = updateTimerData.TimeToUse - timeSpent*0.001;
    	if (updateTimerData.TimeRemaining <= 0.0) {
    		updateTimer.stop();
    		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    	}
    	else {
    		WatchUi.requestUpdate();
    	}
    }
    
    function timerCallback() {
    	timerUpdate();
	}
    
    function onKey(evt)
	{
		System.println("StartTimerDelegate.onKey");
		System.println(" ->" + evt.getKey());  // e.g. KEY_MENU = 7
        System.println(" ->" + evt.getType()); // e.g. PRESS_TYPE_DOWN = 0
        if (evt.getKey() == KEY_ESC) {
			System.println("-> KEY_ESC == exit!");
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		}
		else if (evt.getKey() == KEY_UP) {
			updateTimerData.TimeToUse += 60.0;
			timerUpdate();
		}
		else if (evt.getKey() == KEY_DOWN) {
			updateTimerData.TimeToUse -= 60.0;
			timerUpdate();
		}
	}
	
	function onPosition(info) {
		System.println("StartTimerDelegate.onPosition");
		WatchUi.requestUpdate();
	}
	
    //function onMenu() {
    //}
	
}