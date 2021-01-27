using Toybox.WatchUi;

class SailInfoView extends WatchUi.View {

	hidden var dataTracker;

    function initialize(dataTrackerIn) {
        View.initialize();
        dataTracker = dataTrackerIn;
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

	function drawArc(dc) {

		drawPolarSegment(dc, 90, 180, 0, Graphics.COLOR_GREEN);
		drawPolarSegment(dc, 315, 85, 1, Graphics.COLOR_PINK);
		drawPolarSegment(dc, -30, 30, 2, Graphics.COLOR_RED);
    }
    
	function drawGrid(dc) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);
        var width = dc.getWidth();
        var x1 = width*0.125;
        var x2 = width - x1;
        var xc = width * 0.5;
        var height = dc.getHeight();
        var y1 = height*0.125;
        var y2 = height - y1;
		var yc = height * 0.5;
		dc.drawRectangle(x1,y1,width*0.75, height * 0.375);
        //dc.drawLine(x1, yc, x2, yc);
        //dc.drawLine(xc, y1, xc, y2);
        dc.setPenWidth(1);    
    }

	function drawText(dc) {
        var width = dc.getWidth();
        var xc = width * 0.5;
        var height = dc.getHeight();
		var yc = height * 0.5;
		var fontHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc,yc-fontHeight,Graphics.FONT_SYSTEM_LARGE, dataTracker.LastSpeed.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xc,yc,Graphics.FONT_MEDIUM, dataTracker.LastBearing.format("%.1f"), Graphics.TEXT_JUSTIFY_CENTER);
	}
    
    // Update the view
    function onUpdate(dc) {
    //System.println("SailInfoView.onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
  		
        
        drawGrid(dc);
        drawArc(dc);
        drawText(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
