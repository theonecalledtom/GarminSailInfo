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

	function drawCourseVariation(dc, current, delta, segment) {
		if (current == null) {
			return;
		}
		
		var a = courseTracker.BasePointOfSail;
		var b = current;
		var badColor;
		var goodColor;
		
		if (delta.abs() < 2.0)
		{
			badColor = Graphics.COLOR_DK_GRAY;
			goodColor = Graphics.COLOR_LT_GRAY;
		}
		else if (delta.abs() < 5.0)
		{
			badColor = Graphics.COLOR_ORANGE;
			goodColor = Graphics.COLOR_DK_GREEN;
		}
		else
		{
			badColor = Graphics.COLOR_RED;
			goodColor = Graphics.COLOR_GREEN;
		}
				
        System.println("s: " + segment + ", a: " + a + ", b: " + b);
        a = AngleUtil.Anchor(a, b);
		if (a < 0.0 || b < 0.0)
		{
			a += 360.0;
			b += 360.0;
		}
		if (a <= b) {
			drawPolarSegment(dc, a-1, b+1, segment, courseTracker.wantPostiveVe() ? badColor : goodColor);
		}
		else {
			drawPolarSegment(dc, b-1, a+1, segment, courseTracker.wantPostiveVe() ? goodColor : badColor);
		}
	}

	function drawCourseSelection(dc) {
		var suggestedCourse = courseTracker.getSuggestedCourseAsAngle();
		if (courseTracker.hasCurrentCourse()) {
			var currentCourse = courseTracker.getCurrentCourseAsAngle();
			drawPolarSegment(dc, currentCourse-20, currentCourse+20, 0, Graphics.COLOR_WHITE);
		}
		drawPolarSegment(dc, suggestedCourse-10, suggestedCourse+10, 0, Graphics.COLOR_BLUE);
    }

	function drawCourseHistory(dc) {
    	if (courseTracker.isUpwind()) {
    		//Clear good / bad if working vmg
	    	drawCourseVariation(dc, courseTracker.CurrentPointOfSail_10, courseTracker.Delta_10, 1.1);
	    	//drawCourseVariation(dc, courseTracker.CurrentPointOfSail_20, courseTracker.Delta_20, 2);
	    	drawCourseVariation(dc, courseTracker.CurrentPointOfSail_30, courseTracker.Delta_30, 2.2);
    	}
	}
    
    function drawAngleMarker(dc, angle, scale) {
    	if (courseTracker.CurrentPointOfSail_10 == null) {
    		return;
    	}
    	var width = dc.getWidth();
	    var xc = width * 0.5;
        var height = dc.getHeight();
        var yc = height * 0.5;
        var radius = scale * (xc > yc ? xc : yc);
        
        //System.println("courseTracker.CurrentPointOfSail_10:" + courseTracker.CurrentPointOfSail_10);
        var currentAngle = angle;
        var x = radius * Math.sin(Math.toRadians(currentAngle));
        var y = radius * Math.cos(Math.toRadians(currentAngle));
        
        dc.drawLine(xc,yc,xc + x,yc - y);
    }
    
    function drawWindEstimate(dc) {
    	if (courseTracker.CurrentPointOfSail_10 == null) {
    		return;
    	}
    	
		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
    	drawAngleMarker(dc, dataTracker.LastTenSeconds.Bearing - courseTracker.EstimatedWind, 1.0);

    	var settledTime = courseTracker.getTimeOnSettledCourse(5.0);
		dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT); //COLOR_DK_BLUE
        dc.setPenWidth(5);
    	drawAngleMarker(dc, dataTracker.LastTenSeconds.Bearing - courseTracker.EstimatedWind, settledTime / 5.0);

		//dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
    	//drawAngleMarker(dc, courseTracker.EstimatedWind, 0.75);

		//dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
    	//drawAngleMarker(dc, dataTracker.LastTenSeconds.Bearing, 0.5);
    }
    
	function drawText(dc) {
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var largeFontHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var speed = dataTracker.LastTenSeconds.Speed;
        
        var vmg = speed * Math.cos( Math.toRadians(courseTracker.getVMGAngle()) );
        var yvel = yc-largeFontHeight;
        dc.drawText(xc*0.65,yvel,Graphics.FONT_SYSTEM_LARGE, speed.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(xc*0.65,yvel-largeFontHeight*0.5,Graphics.FONT_SYSTEM_TINY, "kts", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc*1.35,yvel,Graphics.FONT_SYSTEM_LARGE, vmg.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(xc*1.35,yvel-largeFontHeight*0.5,Graphics.FONT_SYSTEM_TINY, "vmg", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var mediumFontHeight = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var cogText = "COG: " + dataTracker.LastTenSeconds.Bearing.format("%.0f");
        dc.drawText(xc,yc,Graphics.FONT_MEDIUM, cogText, Graphics.TEXT_JUSTIFY_CENTER);
        
        //var cogTxtHeight = dc.getFontHeight( Graphics.FONT_MEDIUM );
        var labelHeight = dc.getFontHeight( Graphics.FONT_SYSTEM_TINY );
        //var cogLabelTxt = "COG";
        //var cogWidth = dc.getTextWidthInPixels(cogText, Graphics.FONT_SYSTEM_TINY);
        //dc.drawText(xc+cogWidth*0.75,yc+0.75*(cogTxtHeight - labelHeight),Graphics.FONT_SYSTEM_TINY, cogLabelTxt, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);  
        dc.drawText(xc,yc+mediumFontHeight,Graphics.FONT_MEDIUM, courseTracker.getCourseAsText(), Graphics.TEXT_JUSTIFY_CENTER);
        
        //dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);  
	    //dc.drawText(xc,yc+mediumFontHeight*2.0,Graphics.FONT_MEDIUM, courseTracker.EstimatedWind.format("%.0f"), Graphics.TEXT_JUSTIFY_CENTER);
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
        dc.drawText(xc + width*0.25,yc,Graphics.FONT_MEDIUM, dataTracker.LastTenSeconds.Speed.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc - width*0.25,yc,Graphics.FONT_MEDIUM, dataTracker.LastTenSeconds.Bearing.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);
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
	        drawWindEstimate(dc);
        	drawCourseHistory(dc);
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
