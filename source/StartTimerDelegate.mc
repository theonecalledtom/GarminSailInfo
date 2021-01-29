using Toybox.WatchUi;
using Toybox.System;

class StartTimerDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
        System.println("StartTimerDelegate.initialize");
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
	}
}