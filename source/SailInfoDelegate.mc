using Toybox.WatchUi;
using Toybox.System;
using Toybox.FitContributor;
using Toybox.ActivityRecording;
using Toybox.Position;


class SailInfoDelegate extends WatchUi.BehaviorDelegate {
	var activityManager = null;                                             // set up session variable
	var dataTracker = null;
	
    function initialize() {
	    System.println("SailInfoDelegate.initialize");
        BehaviorDelegate.initialize();
        activityManager = new ActivitySessionManager();
        dataTracker = new SailingDataTracker();
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

	function onPosition(info) {
		System.println("SailInfoDelegate.onPosition");
		dataTracker.onUpdate(info);
		WatchUi.requestUpdate();
	}
	
    function onMenu() {
	    System.println("SailInfoDelegate.onMenu");
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SailInfoMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
	
	// use the select Start/Stop or touch for recording
	function onSelect() {
	   System.println("SailInfoDelegate.onSelect");
	   if (!ActivityManager.hasActiveSession()) {
		   activityManager.onStart(Toybox);
		   //TODO: UI Indicator!
	   }
	   else {
	      	System.println("Activity active, pushing menu");
 			WatchUi.pushView(new Rez.Menus.SelectMenu(), new SailInfoSessionRunningMenuDelegate(ActivityManager), WatchUi.SLIDE_UP);
	   }
	   return true;                                                 // return true for onSelect function
	}

	function onKey(evt)
	{
		System.println("SailInfoApp.onKey");
		if (evt.getKey() == KEY_MENU) {
			System.println("-> KEY_MENU");
		}																`
		else if (evt.getKey() == KEY_ENTER) {
			System.println("-> KEY_ENTER");
			onSelect();
		}
		else if (evt.getKey() == KEY_LIGHT) {
			System.println("-> KEY_LIGHT");
			// do whatever
		}
		else if (evt.getKey() == KEY_ESC) {
			System.println("-> KEY_LIGHT");
			// do whatever
		}
	}
}