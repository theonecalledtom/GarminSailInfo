using Toybox.WatchUi;
using Toybox.System;


class DiscardConfirmationDelegate extends WatchUi.ConfirmationDelegate {
	hidden var activityManager;
    function initialize(activityManagerIn) {
        ConfirmationDelegate.initialize();
        activityManager = activityManagerIn;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
            System.println("SaveConfirmationDelegate -> Cancel");
        } else {
            System.println("SaveConfirmationDelegate -> Discard");
`	        activityManager.onDiscard();
        }
    }
}
class SailInfoSessionRunningMenuDelegate extends WatchUi.MenuInputDelegate {

	hidden var activityManager;
 
    function initialize(activityManagerIn) {
        MenuInputDelegate.initialize();
        System.println("SailInfoSessionRunningMenuDelegate.initialize");
        activityManager = activityManagerIn;
    }

    function onMenuItem(item) {
        System.println("SailInfoSessionRunningMenuDelegate.onMenuItem");
        if (item == :resume) {
            System.println("-> resume");
        }
        else if (item == :save) {
            System.println("-> save");
`	        activityManager.onSave();
        }
        else if (item == :discard) {
            System.println("-> discard");
            var message = "Discard?";
			var dialog = new WatchUi.Confirmation(message);
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			WatchUi.pushView(
			    dialog,
			    new DiscardConfirmationDelegate(activityManager),
			    WatchUi.SLIDE_IMMEDIATE
			);
         }
    }

}