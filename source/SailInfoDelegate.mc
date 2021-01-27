using Toybox.WatchUi;
using Toybox.System;
using Toybox.FitContributor;
using Toybox.ActivityRecording;
using Toybox.Position;


class SailInfoDelegate extends WatchUi.BehaviorDelegate {
	var activityManager = null;                                             // set up session variable
	var dataTracker = null;
	var courseTracker = null;
	
    function initialize() {
	    System.println("SailInfoDelegate.initialize");
        BehaviorDelegate.initialize();
        activityManager = new ActivitySessionManager();
        dataTracker = new SailingDataTracker();
        courseTracker = new CourseTracker();
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

	function onPosition(info) {
		System.println("SailInfoDelegate.onPosition");
		dataTracker.onUpdate(info);
		courseTracker.onUpdate(dataTracker);
		WatchUi.requestUpdate();
	}
	
    function onMenu() {
	    System.println("SailInfoDelegate.onMenu");
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SailInfoMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
	
	// use the select Start/Stop or touch for recording
	function onActivitySelect() {
	   System.println("SailInfoDelegate.onSelect");
	   if (!activityManager.hasActiveSession()) {
		   activityManager.onStart(Toybox);
		   //TODO: UI Indicator!
	   }
	   else {
	      	System.println("Activity active, pushing menu");
 			WatchUi.pushView(new Rez.Menus.SelectMenu(), new SailInfoSessionRunningMenuDelegate(activityManager), WatchUi.SLIDE_UP);
	   }
	   return true;                                                 // return true for onSelect function
	}

	function onKey(evt)
	{
		System.println("SailInfoApp.onKey");
		System.println(" ->" + evt.getKey());  // e.g. KEY_MENU = 7
        System.println(" ->" + evt.getType()); // e.g. PRESS_TYPE_DOWN = 0
        
        if (evt.getKey() == KEY_MENU) {
			System.println("-> KEY_MENU");
		}																`
		else if (evt.getKey() == KEY_ENTER) {
			System.println("-> KEY_ENTER");
			onActivitySelect();
		}
		else if (evt.getKey() == KEY_ESC) {
			System.println("-> KEY_ESC");
			// do whatever
		}
		else if (evt.getKey() == KEY_DOWN) {
			System.println("-> KEY_DOWN");
			courseTracker.changeSuggestedCourse(-1);
			WatchUi.requestUpdate();
		}
		else if (evt.getKey() == KEY_UP) {
			System.println("-> KEY_UP");
			courseTracker.changeSuggestedCourse(+1);
			WatchUi.requestUpdate();
		}
		//Long hold on KEY_DOWN
		else if (evt.getKey() == KEY_CLOCK) {
			System.println("-> KEY_CLOCK");
			courseTracker.selectSuggestCourse();
			WatchUi.requestUpdate();
		}
		
		return true;
	}
}