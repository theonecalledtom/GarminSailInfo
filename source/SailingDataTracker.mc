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
	var LastTime = null;
	var FirstTime = null;
	
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
		if (LastData == null) {
			FirstTime =info.when;
		    System.println("first Lat,Lon:" + myLocation[0] + ", " + myLocation[1]);
		}
		else {
			var _duration = info.when.subtract(LastTime);
			var _offset = info.when.subtract(FirstTime);
			var lastLocation = LastData.position.toDegrees();
			
			LastBearing = LocationMath.BearingBetweenCoords(
				lastLocation[0], lastLocation[1],
				myLocation[0], myLocation[1]); 
			
			LastSpeed = LocationMath.DistanceBetweenCoords(
				lastLocation[0], lastLocation[1],
				myLocation[0], myLocation[1]); 
			LastSpeed *= 1.94384 / _duration.value();
			var lastOtherSpeed = 1.94384 * info.speed;
			System.println("Lat,Lon:" + myLocation[0] + ", " + myLocation[1]);
			System.println(" -> bearing[" + LastBearing + "] speed[" + LastSpeed + "/" + lastOtherSpeed +"] {@" + _offset.value() + "}");	
		}
		LastTime = info.when;
		LastData = info;
	}

	function onStop(){
		
	}	
}