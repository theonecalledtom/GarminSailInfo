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
		drawPolarSegment(dc, currentCourse-20, currentCourse+20, 0, Graphics.COLOR_WHITE);
		//if (courseTracker.hasSuggestedCourse()) {
			drawPolarSegment(dc, suggestedCourse-10, suggestedCourse+10, 0, Graphics.COLOR_BLUE);
    	//}
    	
    	var a = courseTracker.BasePointOfSail;
    	var b = courseTracker.CurrentPointOfSail;
    	//System.println("a: " + a + ", b: " + b);
    	if (courseTracker.isReaching()) {
    		//No clear up or down
			if (a <= b) {
				drawPolarSegment(dc, a-1, b+1, 1, courseTracker.isPort() ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY);
			}
			else {
				drawPolarSegment(dc, b-1, a+1, 1, courseTracker.isPort() ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY);
			}
    	}
    	else
    	{
    		//Clear good / bad if working vmg
			if (a <= b) {
				drawPolarSegment(dc, a-1, b+1, 1, courseTracker.wantPostiveVe() ? Graphics.COLOR_RED : Graphics.COLOR_GREEN);
			}
			else {
				drawPolarSegment(dc, b-1, a+1, 1, courseTracker.wantPostiveVe() ? Graphics.COLOR_GREEN : Graphics.COLOR_RED);
			}
		}
			
    }
    
	function drawText(dc) {
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var largeFontHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var speed = dataTracker.LastSpeed;
        
        var vmg = speed * Math.cos( Math.toRadians(courseTracker.getVMGAngle()) );
        var yvel = yc-largeFontHeight;
        dc.drawText(xc*0.5,yvel,Graphics.FONT_SYSTEM_LARGE, speed.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc*1.5,yvel,Graphics.FONT_SYSTEM_LARGE, vmg.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var mediumFontHeight = dc.getFontHeight(Graphics.FONT_MEDIUM);
        dc.drawText(xc,yc,Graphics.FONT_MEDIUM, dataTracker.LastBearing.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(xc,yc+mediumFontHeight,Graphics.FONT_MEDIUM, courseTracker.getCourseAsText(), Graphics.TEXT_JUSTIFY_CENTER);
	}
	
	function drawStart(dc) {
        //System.println("SailInfoView.drawStart");
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var largeFontHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc,yc-largeFontHeight,Graphics.FONT_SYSTEM_LARGE, "START", Graphics.TEXT_JUSTIFY_CENTER);
        
        drawPolarSegment(dc, 50, 70, 0, Graphics.COLOR_GREEN);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc + width*0.25,yc,Graphics.FONT_MEDIUM, dataTracker.LastSpeed.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc - width*0.25,yc,Graphics.FONT_MEDIUM, dataTracker.LastBearing.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);
}
    
    function drawWaitingGPS(dc) {
    	System.println("SailInfoView.drawWaitingGPS");
    	var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var largeFontHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc,yc-largeFontHeight,Graphics.FONT_SYSTEM_LARGE, "WAITING", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(xc,yc,Graphics.FONT_SYSTEM_LARGE, "FOR GPS...", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    // Update the view
    function onUpdate(dc) {
    //System.println("SailInfoView.onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        if (dataTracker.currentlyTracking) {
        	drawCourseSelection(dc);
 	        drawText(dc);
        }
        else {
        	if (dataTracker.hasLocation()) {
	        	drawStart(dc);
    		}
    		else {
    			drawWaitingGPS(dc);
    		}
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
