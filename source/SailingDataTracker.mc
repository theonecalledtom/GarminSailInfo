using Toybox.System;
using Toybox.Position;
using Toybox.Time;


class CourseHistoryItem
{
	var Time;
	var Bearing;
	function isValid() {
		return Time != null;
	}
}

class CourseHistory
{
	hidden var courseDataSample;
	hidden var sampleCount;
	hidden var timeToTrack;
	
	var Bearing = 0.0;
	var Speed = 0.0;
	var HasData = false;
	
	function initialize(sampleCountIn, timeToTrackIn) {
		sampleCount = sampleCountIn;
		timeToTrack = timeToTrackIn;
		courseDataSample = new [sampleCount];
		for (var i=0 ; i<sampleCount ; i++)
		{
			courseDataSample[i] = new CourseHistoryItem();
		}
	}
	
	function isSettled(maxBearingRange, maxTime) {
		return getSettledCourse(maxBearingRange, maxTime) != null;
	}

	function getTimeOnSettledCourse(maxBearingRange) {
		if (courseDataSample[0].isValid()) {
			var anchor = courseDataSample[0].Bearing;
			var basetime = courseDataSample[0].Time;
			var min = anchor;
			var max = anchor;
			var maxtime = 0.0;
			for (var i=1 ; i<sampleCount ; i++) {
				if (!courseDataSample[i].isValid()) {
					return null;
				}
				var check = AngleUtil.Anchor(courseDataSample[i].Bearing, anchor);

				min = check < min ? check : min;
				max = check > max ? check : max;
				
				if (max - min > maxBearingRange) {
					return maxtime;
				}
				
				maxtime = courseDataSample[i].Time - basetime;
			}
			
			return maxtime;
		}				
		return 0.0;
	}

	function getSettledCourse(maxBearingRange, maxTime) {
		if (courseDataSample[0].isValid()) {
			var anchor = courseDataSample[0].Bearing;
			var basetime = courseDataSample[0].Time;
			var min = anchor;
			var max = anchor;
			var total = anchor;
			var count = 1;
			for (var i=1 ; i<sampleCount ; i++) {
				if (!courseDataSample[i].isValid()) {
					return null;
				}
				var check = AngleUtil.Anchor(courseDataSample[i].Bearing, anchor);

				min = check < min ? check : min;
				max = check > max ? check : max;
				
				if (max - min > maxBearingRange) {
					return null;
				}
				count ++;
				total += check;
				
				if (courseDataSample[i].Time - basetime > maxTime) {
					return total / count;
				}
			} 
			return total / count;
		}
		return null;
	}

	function addToHistory(bearing, time){
		//TODO: Looping history
		for (var iHistory = sampleCount-1 ; iHistory > 0 ; iHistory--) {
			courseDataSample[iHistory] = courseDataSample[iHistory-1];	
		}
		courseDataSample[0].Bearing = bearing;
		courseDataSample[0].Time = time;
	}
}

class DataHistory
{
	hidden var historicalData;
	hidden var sampleCount;
	hidden var timeToTrack;
	
	var Bearing = 0.0;
	var Speed = 0.0;
	var HasData = false;
	
	function initialize(sampleCountIn, timeToTrackIn) {
		sampleCount = sampleCountIn;
		timeToTrack = timeToTrackIn;
		historicalData = new [sampleCount];
		for (var i=0 ; i<sampleCount ; i++)
		{
			historicalData[i] = new [3];
			historicalData[i][0] = null; 	
		}
	}
	
	function addToHistory(info, time){
		//TODO: Looping history
		for (var iHistory = sampleCount-1 ; iHistory > 0 ; iHistory--) {
			historicalData[iHistory][0] = historicalData[iHistory-1][0];	
			historicalData[iHistory][1] = historicalData[iHistory-1][1];	
			historicalData[iHistory][2] = historicalData[iHistory-1][2];	
		}
		historicalData[0][0] = info;
		historicalData[0][1] = time;
		
		var _dist = 0.0;
		var _duration = 0.0;
		var myLocation = info.position.toDegrees();
		var lastLocation = null;
		var iData=1;
		do {
			if (historicalData[iData][0] == null) {
				break;
			}
			
			lastLocation = historicalData[iData][0].position.toDegrees();
			_dist = LocationMath.DistanceBetweenCoords(
							lastLocation[0], lastLocation[1],
							myLocation[0], myLocation[1]
						); 
			_duration = time - historicalData[iData][1];
			iData++;
		} while ((_duration<timeToTrack) && (iData<sampleCount));
			
		var lastOtherSpeed = 1.94384 * info.speed;
		var itrs = (iData-1);
		//System.println("Itrs:" + itrs + ", Dur:" + _duration + ", Dst:" + _dist + ", Spd:" + lastOtherSpeed);
					
		if ((_dist > 0.1) && (_duration > 0.0))
		{
			Bearing = LocationMath.BearingBetweenCoords(
				lastLocation[0], lastLocation[1],
				myLocation[0], myLocation[1]); 
			
			Speed = _dist * 1.94384 / _duration;

			HasData = true;
			historicalData[0][2] = Bearing;
		}
	}
}

class SailingDataTracker {
	
	//TODO: Deprecate!
	var LastTenSeconds = null;
	var LastTwentySeconds = null;
	var LastThirtySeconds = null;
	var currentlyTracking = false;
	
	function initialize() {
		LastTenSeconds = new DataHistory(10,10);
		LastTwentySeconds = new DataHistory(20,20);
		LastThirtySeconds = new DataHistory(30,30);
	}
	
	function hasGPS() {
		return false;
	}

	function onStart(){
		
	}

	function hasLocation() {
		return LastTenSeconds.HasData;
	}
				
	function onUpdate(info){
		if (info == null || info.accuracy == null) {
			return;
		}
	
		if (info.accuracy != Position.QUALITY_GOOD) {
			return;
		}	
		
		var time = System.getTimer() * 0.001;

		LastTenSeconds.addToHistory(info, time);
		LastTwentySeconds.addToHistory(info, time);
		LastThirtySeconds.addToHistory(info, time);
	}

	function onStop(){
		
	}	
}