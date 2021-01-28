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
	
	var CurrentWindEstimate = 0.0;
	var LastWindEstimate = 0.0;
	var LastBearing = 0.0;
	var LastCapturedBearing = 0.0;
	
	var CurrentCourse = CourseType_Stbd_Up;
	var SuggestedCourse = CourseType_Stbd_Up;
	var LastCourseSuggestionTime = 0.0;
	var HasWindEstimate = false;
	
	var dataTracker = null;
	
	function initialize(dataTrackerIn)
	{
		dataTracker = dataTrackerIn;
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
	
	function selectSuggestCourse()
	{
		if (CurrentCourse != SuggestedCourse) {
			CurrentCourse = SuggestedCourse;
			if (dataTracker.hasBearing()) {
				var AngleOffWind = getCourseAsAngle(CurrentCourse);
				LastCapturedBearing = dataTracker.LastBearing;
				CurrentWindEstimate = dataTracker.LastBearing - AngleOffWind;
				HasWindEstimate = true;
			}
			return true;
		}
		else {
			//Consider fixing up the "on the wind" idea
		}
		return false;
	}

	function getCourseAsText()
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
				return "Pre";
			case CourseType_Prt_Up:
				return "PUp";
		}
		return "Unknown";
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
	
	function getSuggestedCourseAsAngle()
	{
		return getCourseAsAngle(SuggestedCourse);
	}
	
	function getCurrentCourseAsAngle()
	{
		return getCourseAsAngle(CurrentCourse);
	}
	
		
	function onUpdate()
	{
		//Update estimate of the wind, different rules depending on
		//point of sail
		if (HasWindEstimate) {
			if (dataTracker.hasBearing()) {
				var delta = dataTracker.LastBearing - LastCapturedBearing;
				
				//TODO: Not really whats needed, need to track lifts and downs while in upwind mode
				LastWindEstimate = CurrentWindEstimate + delta;
			}
		}
		else {
			
		}
	}
}