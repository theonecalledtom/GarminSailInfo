using Toybox.WatchUi;
using Toybox.System;

class SailInfoSessionRunningMenuDelegate extends WatchUi.MenuInputDelegate {

	var Result = 0;
	hidden var ActivityManager;

    function initialize(ActivityManager_in) {
        MenuInputDelegate.initialize();
        System.println("SailInfoSessionRunningMenuDelegate.initialize");
        ActivityManager = ActivityManager_in;
    }

    function onMenuItem(item) {
        System.println("SailInfoSessionRunningMenuDelegate.onMenuItem");
        if (item == :resume) {
            System.println("-> resume");
        }
        else if (item == :save) {
            System.println("-> save");
`	        ActivityManager.onSave();
        }
        else if (item == :discard) {
            System.println("-> discard");
	        ActivityManager.onDiscard();
         }
    }

}