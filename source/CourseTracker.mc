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
	
	var BasePointOfSail = 0.0;
	var CurrentPointOfSail = 0.0;

	var BaseBearing = 0.0;
	var BaseWindEstimate = 0.0;
	
	var CurrentCourse = CourseType_Stbd_Up;
	var SuggestedCourse = CourseType_Stbd_Up;
	var LastCourseSuggestionTime = 0.0;
	var HasWindEstimate = false;
	
	var dataTracker = null;
	
	function initialize(dataTrackerIn)
	{
		dataTracker = dataTrackerIn;
	}
	
	function hasSuggestedCourse()
	{
		return CurrentCourse != SuggestedCourse;
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
		CurrentCourse = SuggestedCourse;
		if (dataTracker.hasBearing()) {
			BasePointOfSail = getCourseAsAngle(CurrentCourse);
			CurrentPointOfSail = BasePointOfSail;
			BaseWindEstimate = dataTracker.LastBearing - BasePointOfSail;
			BaseBearing = dataTracker.LastBearing;
			HasWindEstimate = true;
			return true;
		}
		return false;
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
		if (isUpwind()) {
			if (CurrentPointOfSail > 180.0) {
				return 360.0 - CurrentPointOfSail;
			}
			return CurrentPointOfSail;
		}
		else if (isDownwind()) {
			if (CurrentPointOfSail > 180.0) {
				return CurrentPointOfSail - 180.0;
			}
			return 180.0 - CurrentPointOfSail;
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
				var delta = dataTracker.LastBearing - BaseBearing;
				
				//TODO: Not really whats needed, need to track lifts and downs while in upwind mode
				CurrentPointOfSail = BasePointOfSail + delta;
			}
			
			//Did we switch point of sail?
		}
		else {
			
		}
	}
}