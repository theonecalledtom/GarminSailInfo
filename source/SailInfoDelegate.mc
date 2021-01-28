using Toybox.WatchUi;
using Toybox.System;
using Toybox.FitContributor;
using Toybox.ActivityRecording;
using Toybox.Position;
using Toybox.Attention;

class SailInfoDelegate extends WatchUi.BehaviorDelegate {
	var activityManager = null;                                             // set up session variable
	var dataTracker = null;
	var courseTracker = null;
	
    function initialize() {
	    System.println("SailInfoDelegate.initialize");
        BehaviorDelegate.initialize();
        dataTracker = new SailingDataTracker();
        activityManager = new ActivitySessionManager(dataTracker);
        courseTracker = new CourseTracker(dataTracker);
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

	function onPosition(info) {
		System.println("SailInfoDelegate.onPosition");
		dataTracker.onUpdate(info);
		courseTracker.onUpdate();
		WatchUi.requestUpdate();
	}
	
    function onMenu() {
	    System.println("SailInfoDelegate.onMenu");
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SailInfoMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
	
	function onKey(evt)
	{
		//System.println("SailInfoApp.onKey");
		//System.println(" ->" + evt.getKey());  // e.g. KEY_MENU = 7
        //System.println(" ->" + evt.getType()); // e.g. PRESS_TYPE_DOWN = 0
        
        if (evt.getKey() == KEY_MENU) {
			System.println("-> KEY_MENU");
		}																`
		else
		{
			if (!activityManager.hasActiveSession()) {
				if (evt.getKey() == KEY_ENTER) {
					System.println("-> KEY_ENTER");
					activityManager.onStart(Toybox);
				 	WatchUi.requestUpdate();
				}
				else if (evt.getKey() == KEY_ESC) {
					System.println("-> KEY_ESC == exit!");
					WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
				}
			}
			else {
				if (evt.getKey() == KEY_ESC) {
					System.println("-> KEY_ESC");
					WatchUi.pushView(new Rez.Menus.SelectMenu(), new SailInfoSessionRunningMenuDelegate(activityManager), WatchUi.SLIDE_UP);
				}
				else if (evt.getKey() == KEY_DOWN) {
					System.println("-> KEY_DOWN -> Course -1");
					Toybox.Attention.playTone(Attention.TONE_KEY);
					courseTracker.changeSuggestedCourse(-1);
					WatchUi.requestUpdate();
				}
				else if (evt.getKey() == KEY_UP) {
					System.println("-> KEY_UP -> Course +1");
					Toybox.Attention.playTone(Attention.TONE_KEY);
					courseTracker.changeSuggestedCourse(+1);
					WatchUi.requestUpdate();
				}
				else if (evt.getKey() == KEY_ENTER) {
					if (courseTracker.selectSuggestCourse()) {
						System.println("-> KEY_ENTER -> Selected Course");
						Toybox.Attention.playTone(Attention.TONE_LAP);
						WatchUi.requestUpdate();
					}
					else {
						System.println("-> KEY_ENTER -> No course change");
						Toybox.Attention.playTone(Attention.TONE_INTERVAL_ALERT);
					}
				}
			}
		}
		return true;
	}
}