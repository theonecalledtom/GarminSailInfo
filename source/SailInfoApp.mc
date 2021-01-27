using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;

class SailInfoApp extends Application.AppBase {
	
    function initialize() {
    	System.println("SailInfoApp.initialize");
        AppBase.initialize();
        
    }

    // onStart() is called on application start up
    function onStart(state) {
    	System.println("SailInfoApp.onStart");
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	System.println("SailInfoApp.onStop");
    }

    // Return the initial view of your application here
    function getInitialView() {
    	var dele = new SailInfoDelegate();
    	var view = new SailInfoView(dele.dataTracker, dele.courseTracker);
        return [ view, dele ];
    }

}
