using Toybox.WatchUi;
using Toybox.System;
using Toybox.FitContributor;
using Toybox.ActivityRecording;


class ActivitySessionManager {
	hidden var session = null;                                             // set up session variable
	hidden var dataTracker = null;

    function initialize(dataTrackerIn) {
	    System.println("ActivitySessionManager.initialize");
	    dataTracker = dataTrackerIn;
    }


	function hasActiveSession() {
		if (session != null) {
			return true;
		}
		return false;
	}	

	function isRecording() {
		return hasActiveSession() && session.isRecording();
	}	
        
	// use the select Start/Stop or touch for recording
	function onStart(ToyboxIn) {
	   System.println("SailInfoDelegate.onSelect");
	   if (ToyboxIn has :ActivityRecording) {                          // check device for activity recording
	       if (session == null) {
	           System.println("-> Activity Session Start");
	           session = ActivityRecording.createSession({          // set up recording session
	                 :name=>"SailInfo",                              // set session name
	                 :sport=>ActivityRecording.SPORT_SAILING,       // set sport type
	                 :subSport=>ActivityRecording.SUB_SPORT_GENERIC // set sub sport type
	           });
	           session.start();                                     // call start session
	       }
	       else if (!session.isRecording()) {
	           System.println("-> Activity Session Restart");
 			   session.start();
	       }
	       dataTracker.currentlyTracking = true;
	   }
	   else {
           System.println("NO ACTIVITY RECORDING");
	   }
	   return true;                                                 // return true for onSelect function
	}
	
	function onStop(){
        System.println("ActivitySessionManager.onStop");
        session.stop();
	    dataTracker.currentlyTracking = false;
        session = null;
    }
  
	
	function onSave(){
        System.println("ActivitySessionManager.onSave");
        session.stop();
	    dataTracker.currentlyTracking = false;
        session.save();
        session = null;
	}
	
	function onDiscard(){
        System.println("ActivitySessionManager.onStop");
        session.stop();
	    dataTracker.currentlyTracking = false;
        session = null;
	}
}