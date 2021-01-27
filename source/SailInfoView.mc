using Toybox.WatchUi;

class SailInfoView extends WatchUi.View {

	hidden var dataTracker;
	hidden var courseTracker;

    function initialize(dataTrackerIn, courseTrackerIn) {
        View.initialize();
        dataTracker = dataTrackerIn;
        courseTracker = courseTrackerIn;
    }
    
    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
 	    System.println("view shown");
    }

	function drawPolarSegment(dc, min, max, segmentLayer, color) {
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;

		var linewidth = 10;
		dc.setPenWidth(linewidth);
        dc.setColor(color,Graphics.COLOR_BLUE);
        dc.drawArc(xc, yc, xc-linewidth*(0.5 + segmentLayer), Graphics.ARC_CLOCKWISE, 90-min, 90-max);
	}

	function drawCourseSelection(dc) {
		var suggestedCourse = courseTracker.getSuggestedCourseAsAngle();
		var currentCourse = courseTracker.getCurrentCourseAsAngle();
		drawPolarSegment(dc, currentCourse-20, currentCourse+20, 0, Graphics.COLOR_GREEN);
		drawPolarSegment(dc, suggestedCourse-10, suggestedCourse+10, 1, Graphics.COLOR_PINK);
    }
    
	function drawText(dc) {
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var largeFontHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc,yc-largeFontHeight,Graphics.FONT_SYSTEM_LARGE, dataTracker.LastSpeed.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var mediunmFontHeight = dc.getFontHeight(Graphics.FONT_MEDIUM);
        dc.drawText(xc,yc,Graphics.FONT_MEDIUM, dataTracker.LastBearing.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(xc,yc+mediunmFontHeight,Graphics.FONT_MEDIUM, courseTracker.getCourseAsText(), Graphics.TEXT_JUSTIFY_CENTER);
	}
    
    // Update the view
    function onUpdate(dc) {
    //System.println("SailInfoView.onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        drawCourseSelection(dc);
        drawText(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
