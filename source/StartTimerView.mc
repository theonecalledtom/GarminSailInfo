using Toybox.WatchUi;

class StartTimerView extends WatchUi.View {

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
    
    function drawText(dc) {
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var largeFontHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var TimerValue = updateTimerData.TimeRemaining;
        dc.drawText(xc,yc-largeFontHeight*0.5,Graphics.FONT_SYSTEM_LARGE, TimerValue.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
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