using Toybox.System;
using Toybox.Position;
using Toybox.Time;

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
		[null,0.0], 
		[null,0.0], 
		[null,0.0], 
		[null,0.0], 
		[null,0.0], 
		[null,0.0], 
		[null,0.0], 
		[null,0.0], 
		[null,0.0], 
		[null,0.0] 
	];
	
	function hasGPS() {
		return false;
	}

	function hasBearing() {
		return HasBearing;
	}
	
	function onStart(){
		
	}

	function hasLocation() {
		if ( LastData != null ) {
			return true;
		}
		return false;
	}
		
	function addToHistory(info, time){
		for (var iHistory = HISTORY_COUNT-1 ; iHistory > 0 ; iHistory--) {
			HistoricalData[iHistory][0] = HistoricalData[iHistory-1][0];	
			HistoricalData[iHistory][1] = HistoricalData[iHistory-1][1];	
		}
		HistoricalData[0][0] = info;
		HistoricalData[0][1] = time;
	}
		
	function onUpdate(info){
		if (info == null || info.accuracy == null) {
			return;
		}
	
		if (info.accuracy != Position.QUALITY_GOOD) {
			return;
		}	
		
		var time = System.getTimer() * 0.001;
		addToHistory(info, time);
		
		var myLocation = info.position.toDegrees();
		if (LastData == null) {
			FirstTime = time;
			LastTime = FirstTime;
		    //System.println("first Lat,Lon:" + myLocation[0] + ", " + myLocation[1]);
		}
		else {
			var lastLocation = LastData.position.toDegrees();

			//info.speed is a smoothed version from what I've seen
			LastSpeed = 0.0; 
			var _dist = 0.0;
			var _duration = 0.0;
			
			var iData=1;
			do {
				if (HistoricalData[iData][1] == 0.0) {
					break;
				}
				
				lastLocation = HistoricalData[iData][0].position.toDegrees();
				_dist = LocationMath.DistanceBetweenCoords(
								lastLocation[0], lastLocation[1],
								myLocation[0], myLocation[1]
							); 
				_duration = time - HistoricalData[iData][1];
				iData++;
			} while ((_dist<10.0) && (iData<HISTORY_COUNT));
			
			var lastOtherSpeed = 1.94384 * info.speed;
			var itrs = (iData-1);
			System.println("Itrs:" + itrs + ", Dur:" + _duration + ", Dst:" + _dist + ", Spd:" + lastOtherSpeed);
						
			if ((_dist > 0.1) && (_duration > 0.0))
			{
				LastBearing = LocationMath.BearingBetweenCoords(
					lastLocation[0], lastLocation[1],
					myLocation[0], myLocation[1]); 
				
				LastSpeed = _dist * 1.94384 / _duration;

				HasBearing = true;
			}
		}
		LastTime = time;
		LastData = info;
	}

	function onStop(){
		
	}	
}