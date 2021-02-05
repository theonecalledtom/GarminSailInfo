using Toybox.System;

class CourseTracker
{
	enum 
	{
		CourseType_Stbd_Up,
		CourseType_Stbd_Reach,
		CourseType_Stbd_Dwn,
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
	var CourseHistory = [null, null, null, null, null, null];

	var BaseBearing = 0.0;
	var BaseWindEstimate = 0.0;
	var EstimatedAngleToWind = 0.0;
	
	var CurrentCourse = null;
	var SuggestedCourse = CourseType_Stbd_Up;
	var LastCourseSuggestionTime = 0.0;
	var HasWindEstimate = false;
	
	var dataTracker = null;
	
	function initialize(dataTrackerIn)
	{
		dataTracker = dataTrackerIn;
		
		for (var i=0 ; i<CourseType_MAX ; i++) {
			CourseHistory[i] = new [NUM_SETTLED_SAMPLES];
		}
	}
	
	function recordDirection(direction) {
		if (CurrentCourse != null) {
			for (var i=NUM_SETTLED_SAMPLES-1 ; i>0 ; i--) {
				CourseHistory[CurrentCourse][i] = CourseHistory[CurrentCourse][i-1];
			}
			CourseHistory[CurrentCourse][0] = direction;
		}
	}
		
	function hasSuggestedCourse() {
		return CurrentCourse != SuggestedCourse;
	}
	
	function isOnSettledCourse(maxDelta) {
		if (CurrentCourse != null) {
			if (CourseHistory[CurrentCourse][0] != null) {
				var min = CourseHistory[CurrentCourse][0];
				var max = AngleUtil.Anchor(CourseHistory[CurrentCourse][0], min);
				for (var i=1 ; i<NUM_SETTLED_SAMPLES ; i++) {
					if (CourseHistory[CurrentCourse][i] == null) {
						return false;
					}
					var test = AngleUtil.Anchor(CourseHistory[CurrentCourse][i], min);
					min = min < test ? min : test;
					max = max > test ? max : test;
				}
				
				System.println("min: " + min + ", max: " + max + ", allowed: " + maxDelta);
				return (max - min) < maxDelta;
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

	function isUpwind()
	{
		return (CurrentCourse == CourseType_Stbd_Up) || (CurrentCourse == CourseType_Prt_Up);
	}

	function isDownwind()
	{
		return (CurrentCourse == CourseType_Stbd_Dwn) || (CurrentCourse == CourseType_Prt_Dwn);
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
		}
		return false;
	}

	function getCourseAsText()
	{
		if (CurrentCourse != null)
		{
			switch(CurrentCourse)
			{
				case CourseType_Stbd_Up:
					return "SUp";
				case CourseType_Stbd_Reach:
					return "SRe";
				case CourseType_Stbd_Dwn:
					return "SDn";
				case CourseType_Prt_Dwn:
					return "PDn";
				case CourseType_Prt_Reach:
					return "PRe";
				case CourseType_Prt_Up:
					return "PUp";
			}
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
		if (angle > 125) {
			return CourseType_Stbd_Dwn;
		} else if (angle > 75.0f) {
			return CourseType_Stbd_Reach;
		} else if (angle > 0.0f) {
			return CourseType_Stbd_Up;
		} else if (angle > -75.0f) {
			return CourseType_Prt_Up;
		} else if (angle > -125.0f) {
			return CourseType_Prt_Reach;
		}
		return CourseType_Prt_Dwn;
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
				EstimatedAngleToWind = dataTracker.LastTenSeconds.Bearing - BaseWindEstimate;
				var pointOfSail = getPointOfSailFromWindAngle( EstimatedAngleToWind );
				if (pointOfSail != CurrentCourse) {
					System.println("Course change from: " + CurrentCourse + " to: " + pointOfSail);
					CurrentCourse = pointOfSail;
					
					if (isUpwind()) {
						updateBasePointOfSail();
					}
				}
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
			
			recordDirection(CurrentPointOfSail_10);
		}
		else {
			
		}
	}
}