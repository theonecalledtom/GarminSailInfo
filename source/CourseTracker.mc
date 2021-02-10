using Toybox.System;

class CourseTracker
{
	enum 
	{
		CourseType_Stbd_Up,
		CourseType_Stbd_Reach,
		CourseType_Stbd_Dwn,
		CourseType_DDW,
		CourseType_Prt_Dwn,
		CourseType_Prt_Reach,
		CourseType_Prt_Up,
		CourseType_MAX
	}
	
	const NUM_SETTLED_SAMPLES = 10;
	var BasePointOfSail = 0.0;
	var CurrentPointOfSail_10 = null;
	var CurrentPointOfSail_20 = null;
	var CurrentPointOfSail_30 = null;
	var Delta_10 = 0.0;
	var Delta_20 = 0.0;
	var Delta_30 = 0.0;
	
	//TODO: Fill out from data
	var CourseHistory;
	var CourseHistoryTime;

	var BaseBearing = 0.0;
	var BaseWindEstimate = 0.0;
	var EstimatedWind = 0.0;
	var EstimatedAngleToWind = 0.0;
	
	var CurrentCourse = null;
	var SuggestedCourse = CourseType_Stbd_Up;
	var LastCourseSuggestionTime = 0.0;
	var HasWindEstimate = false;
	
	var dataTracker = null;
	
	function initialize(dataTrackerIn)
	{
		dataTracker = dataTrackerIn;
		
		CourseHistory = new [CourseType_MAX];
		CourseHistoryTime = new [CourseType_MAX];
		for (var i=0 ; i<CourseType_MAX ; i++) {
			CourseHistory[i] = new [NUM_SETTLED_SAMPLES];
			CourseHistoryTime[i] = new [NUM_SETTLED_SAMPLES];
		}
	}
	
	function recordDirection(direction) {
		if (CurrentCourse != null) {
			for (var i=NUM_SETTLED_SAMPLES-1 ; i>0 ; i--) {
				CourseHistory[CurrentCourse][i] = CourseHistory[CurrentCourse][i-1];
				CourseHistoryTime[CurrentCourse][i] = CourseHistoryTime[CurrentCourse][i-1];
			}
			CourseHistory[CurrentCourse][0] = direction;
			CourseHistoryTime[CurrentCourse][0] = System.getTimer() * 0.001;
		}
	}
		
	function hasSuggestedCourse() {
		return CurrentCourse != SuggestedCourse;
	}
	
	function isOnSettledCourse(maxDelta, maxTime) {
		if (CurrentCourse != null) {
			if (CourseHistory[CurrentCourse][0] != null) {
				var timeCutoff = System.getTimer() * 0.001;
				var currentDir = dataTracker.LastTenSeconds.Bearing;
				for (var i=1 ; i<NUM_SETTLED_SAMPLES ; i++) {
					if (CourseHistory[CurrentCourse][i] == null) {
						return false;
					}
					if (timeCutoff - CourseHistoryTime[CurrentCourse][i] > maxTime){
						return true;
					}
					var test = AngleUtil.Anchor(CourseHistory[CurrentCourse][i], currentDir);
					if (test - currentDir > maxDelta) {
						System.println("Not settled (too high: " + test + " vs " + currentDir + ")");
						return false;
					}
					else if (currentDir - test > maxDelta) {
						System.println("Not settled (too low: " + test + " vs " + currentDir + ")");
						return false;
					}
				}
				return true;
			}
		}
		return false;
	}
	
	function changeSuggestedCourse(dir)
	{
		SuggestedCourse = (SuggestedCourse + dir);
		if (SuggestedCourse < 0) {
			SuggestedCourse = CourseType_Prt_Up;
		}
		if (SuggestedCourse >= CourseType_MAX) {
			SuggestedCourse = CourseType_Stbd_Up;
		}
		LastCourseSuggestionTime = System.getTimer() * 0.001;
	}
	
	function updateBasePointOfSail()
	{
		if (dataTracker.LastTenSeconds.HasData) {
			BasePointOfSail = getCourseAsAngle(CurrentCourse);
			CurrentPointOfSail_10 = BasePointOfSail;
			Delta_10 = 0.0;
			CurrentPointOfSail_20 = BasePointOfSail;
			Delta_20 = 0.0;
			CurrentPointOfSail_30 = BasePointOfSail;
			Delta_30 = 0.0;
			BaseWindEstimate = dataTracker.LastTenSeconds.Bearing - BasePointOfSail;
			EstimatedWind = BaseWindEstimate; 
			BaseBearing = dataTracker.LastTenSeconds.Bearing;
			HasWindEstimate = true;
			return true;
		}
		return false;
	}

	function selectSuggestCourse()
	{
		CurrentCourse = SuggestedCourse;
		
		return updateBasePointOfSail();
	}
	
	function isReaching()
	{
		return (CurrentCourse == CourseType_Stbd_Reach) || (CurrentCourse == CourseType_Prt_Reach);
	}

	function isCourseUpwind(course)
	{
		return (course == CourseType_Stbd_Up) || (course == CourseType_Prt_Up);
	}

	function isUpwind()
	{
		return (CurrentCourse == CourseType_Stbd_Up) || (CurrentCourse == CourseType_Prt_Up);
	}

	function isDownwind()
	{
		return (CurrentCourse == CourseType_Stbd_Dwn) 
			|| (CurrentCourse == CourseType_Prt_Dwn)
			|| (CurrentCourse == CourseType_DDW);
	}

	function getVMGAngle()
	{
		if (CurrentPointOfSail_10 == null) {
			return 0.0;
		}
		
		if (isUpwind()) {
			if (CurrentPointOfSail_10 > 180.0) {
				return 360.0 - CurrentPointOfSail_10;
			}
			return CurrentPointOfSail_10;
		}
		else if (isDownwind()) {
			if (CurrentPointOfSail_10 > 180.0) {
				return CurrentPointOfSail_10 - 180.0;
			}
			return 180.0 - CurrentPointOfSail_10;
		}
		return 0.0;
	}

	function isStarboard()
	{
		return (CurrentCourse == CourseType_Stbd_Up) 
			|| (CurrentCourse == CourseType_Stbd_Reach)
			|| (CurrentCourse == CourseType_Stbd_Dwn);
	}

	function isPort()
	{
		return !isStarboard();
	}
	
	function wantPostiveVe()
	{
		switch(CurrentCourse)
		{
			case CourseType_Stbd_Up:
				return true;
			case CourseType_Stbd_Reach:
				return true;
			case CourseType_Stbd_Dwn:
				return false;
			case CourseType_Prt_Dwn:
				return true;
			case CourseType_Prt_Reach:
				return false;
			case CourseType_Prt_Up:
				return false;
			case CourseType_DDW:
				//TODO: This is wrong though!
				return false;
		}
		return false;
	}

	function getACourseAsText(Course)
	{
		switch(Course)
		{
			case CourseType_Stbd_Up:
				return "SUp";
			case CourseType_Stbd_Reach:
				return "SRe";
			case CourseType_Stbd_Dwn:
				return "SDn";
			case CourseType_DDW:
				return "DDW";
			case CourseType_Prt_Dwn:
				return "PDn";
			case CourseType_Prt_Reach:
				return "PRe";
			case CourseType_Prt_Up:
				return "PUp";
		}
		return "Unknown";
	}

	function getCourseAsText()
	{
		if (CurrentCourse != null)
		{
			return getACourseAsText(CurrentCourse);
		}
		return "Select Crs";
	}

	function getCourseAsAngle(course)
	{
		switch(course)
		{
			case CourseType_Stbd_Up:
				return 45.0;
			case CourseType_Stbd_Reach:
				return 90.0;
			case CourseType_Stbd_Dwn:
				return 135.0;
			case CourseType_DDW:
				return 180.0;
			case CourseType_Prt_Dwn:
				return 225.0;
			case CourseType_Prt_Reach:
				return 270.0;
			case CourseType_Prt_Up:
				return 315.0;
		}
		return 0.0;
	}
	
	function getPointOfSailFromWindAngle(angle)
	{
		angle = AngleUtil.ContainAngleMinus180To180(angle);
		if (angle > 165) {
			return CourseType_DDW;
		} else if (angle > 125) {
			return CourseType_Stbd_Dwn;
		} else if (angle > 65.0f) {
			return CourseType_Stbd_Reach;
		} else if (angle > 0.0f) {
			return CourseType_Stbd_Up;
		} else if (angle > -65.0f) {
			return CourseType_Prt_Up;
		} else if (angle > -125.0f) {
			return CourseType_Prt_Reach;
		} else if (angle > -165.0) {
			return CourseType_Prt_Dwn;
		}
		return CourseType_DDW;
	}
	
	function getSuggestedCourseAsAngle() {
		return getCourseAsAngle(SuggestedCourse);
	}
	
	function getCurrentCourseAsAngle() {
		return getCourseAsAngle(CurrentCourse);
	}
	
	function hasCurrentCourse() {
		return CurrentCourse != null;
	}
	
	function autoUpdateCurrentPointOfSail()
	{
		if (HasWindEstimate) {
			if (dataTracker.LastTenSeconds.HasData) {
				EstimatedAngleToWind = dataTracker.LastTenSeconds.Bearing - EstimatedWind;
				var pointOfSail = getPointOfSailFromWindAngle( EstimatedAngleToWind );
				if (pointOfSail != CurrentCourse) {
				
					if (isUpwind() && isCourseUpwind(pointOfSail)) {
						System.println("Tacking from: " + getACourseAsText(CurrentCourse) + " to: " + getACourseAsText(pointOfSail));
					}
					else {
						System.println("Course change from: " + getACourseAsText(CurrentCourse) + " to: " + getACourseAsText(pointOfSail));
					}
					CurrentCourse = pointOfSail;
					
					//TMS: 	Want to be uch more careful about this or we lose lift and header info
					//		at least with the current model.
					//if (isUpwind()) {
					//	updateBasePointOfSail();
					//}
				}
			}
		}
	}
	
	function autoUpdateBaseWindEstimate()
	{
		//Currently only tracking wind changes upwind. Will manually sync wind direction when off the wind
		//and accept it's rudimentary at best
		if (isUpwind()) {
			//Been with 5 degrees for 10 seconds?
			if (isOnSettledCourse(5.0, 10.0)) {
				var delta = dataTracker.LastTenSeconds.Bearing - BaseBearing;
				
				EstimatedWind = BaseWindEstimate + delta;
			}
		}
	}
	
	function onUpdate()
	{
		//Update estimate of the wind, different rules depending on
		//point of sail
		if (HasWindEstimate) {

			if (dataTracker.LastTenSeconds.HasData) {
				var delta = dataTracker.LastTenSeconds.Bearing - BaseBearing;
				
				//TODO: Not really whats needed, need to track lifts and downs while in upwind mode
				CurrentPointOfSail_10 = BasePointOfSail + delta;
				Delta_10 = delta;
			}

			//Did we switch point of sail?
			autoUpdateCurrentPointOfSail();

			//Can we make a guess at what the wind did
			//autoUpdateBaseWindEstimate();

			if (dataTracker.LastTwentySeconds.HasData) {
				var delta = dataTracker.LastTwentySeconds.Bearing - BaseBearing;
				
				//TODO: Not really whats needed, need to track lifts and downs while in upwind mode
				CurrentPointOfSail_20 = BasePointOfSail + delta;
				Delta_20 = delta;
			}

			if (dataTracker.LastThirtySeconds.HasData) {
				var delta = dataTracker.LastThirtySeconds.Bearing - BaseBearing;
				
				//TODO: Not really whats needed, need to track lifts and downs while in upwind mode
				CurrentPointOfSail_30 = BasePointOfSail + delta;
				Delta_30 = delta;
			}
			
			recordDirection(dataTracker.LastTenSeconds.Bearing);
		}
		else {
			
		}
	}
}