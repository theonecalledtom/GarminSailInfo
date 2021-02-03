using Toybox.WatchUi as UI;
using Toybox.Lang as Lang;

class StartTimerView extends UI.View {

	const FORMAT_TIME = "$1$:$2$$3$";
	const FORMAT_TIMER = "$1$:$2$";
	const FORMAT_MIN_SEC = "%02d";
	
	var updateTimerData;
    function initialize(timerDataIn) {
        View.initialize();
        updateTimerData = timerDataIn;
    }
    
    // Load your resources here
    function onLayout(dc) {
 	    System.println("StartTimerView.onLayout");
        setLayout(Rez.Layouts.StartTimer(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
 	    System.println("StartTimerView.onShow");
    }

 	function getTimerString(seconds) {
		var min = seconds.toNumber() / 60;
		var sec = seconds.toNumber() % 60;
		
		return Lang.format(FORMAT_TIMER, [min, sec.format(FORMAT_MIN_SEC)]);
 	}
    
    function drawText(dc) {
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var largeFontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var TimerValue = updateTimerData.TimeRemaining;
        dc.drawText(xc,yc-largeFontHeight*0.5,Graphics.FONT_NUMBER_THAI_HOT, getTimerString(TimerValue), Graphics.TEXT_JUSTIFY_CENTER);
 	}
	
     // Update the view
    function onUpdate(dc) {
	    System.println("SailInfoView.onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        drawText(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
 	    System.println("StartTimerView.onHide");
    }
    
}