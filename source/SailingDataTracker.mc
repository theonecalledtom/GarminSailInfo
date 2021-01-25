using Toybox.System;
using Toybox.Position;
using Toybox.Time;

class SailingDataTracker {
	const HISTORY_COUNT = 10;
	var LastSpeed = 0.0;
	var LastData = null;
	var LastTime = null;
	
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
		for (var iHistory = HISTORY_COUNT ; iHistory > 0 ; iHistory--) {
			HistoricalData[iHistory] = HistoricalData[iHistory-1];	
		}
		HistoricalData[0] = info;
	}
		
	function onUpdate(info){
		addToHistory(info);
		var myLocation = info.position.toDegrees();
		if (LastData == null) {
		    System.println("first Lat,Lon:" + myLocation[0] + ", " + myLocation[1]);
		}
		else {
			var _duration = info.when.subtract(LastTime);
			System.println("first Lat,Lon:" + myLocation[0] + ", " + myLocation[1] + " {@" + _duration.value() + "}");	
		}
		LastTime = info.when;
		LastData = info;
	}

	function onStop(){
		
	}	
}