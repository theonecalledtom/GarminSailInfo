using Toybox.System;
using Toybox.Position;
using Toybox.Time;

class SegmentDelta
{
	var isSet = false;
	var long1 = 0.0;
	var lat1 = 0.0;
	var long2 = 0.0;
	var lat2 = 0.0;
	var timeDelta = 0.0;
	var bearingDelta = 0.0;
	var distanceDelta = 0.0;
}

class SailingDataTracker {
	const HISTORY_COUNT = 10;
	var LastBearing = 0.0;
	var LastSpeed = 0.0;
	var LastData = null;
	var LastTime = 0.0;
	var FirstTime = 0.0;
	var HasBearing = false;
	var currentlyTracking = false;
	
	var HistoricalData = 
	[ 
		[null], 
		[null], 
		[null], 
		[null], 
		[null], 
		[null], 
		[null], 
		[null], 
		[null], 
		[null] 
	];
	
	function hasGPS() {
		return false;
	}

	function hasBearing() {
		return HasBearing;
	}
	
	function onStart(){
		
	}
		
	function addToHistory(info){
		for (var iHistory = HISTORY_COUNT-1 ; iHistory > 0 ; iHistory--) {
			HistoricalData[iHistory] = HistoricalData[iHistory-1];	
		}
		HistoricalData[0] = info;
	}
		
	function onUpdate(info){
		addToHistory(info);
		var myLocation = info.position.toDegrees();
		var time = System.getTimer() * 0.001;
		if (LastData == null) {
			FirstTime = time;
			LastTime = FirstTime;
		    System.println("first Lat,Lon:" + myLocation[0] + ", " + myLocation[1]);
		}
		else {
			var _duration = time - LastTime;
			var lastLocation = LastData.position.toDegrees();
			
			LastBearing = LocationMath.BearingBetweenCoords(
				lastLocation[0], lastLocation[1],
				myLocation[0], myLocation[1]); 
			
			LastSpeed = LocationMath.DistanceBetweenCoords(
				lastLocation[0], lastLocation[1],
				myLocation[0], myLocation[1]); 
			LastSpeed *= 1.94384 / _duration;
			var lastOtherSpeed = 1.94384 * info.speed;
			System.println("Lat,Lon:" + myLocation[0] + ", " + myLocation[1]);
			System.println(" -> bearing[" + LastBearing + "] speed[" + LastSpeed + "/" + lastOtherSpeed +"] {@" + (time - FirstTime) + "}");	
			HasBearing = true;
		}
		LastTime = time;
		LastData = info;
	}

	function onStop(){
		
	}	
}