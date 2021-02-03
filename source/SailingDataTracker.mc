using Toybox.System;
using Toybox.Position;
using Toybox.Time;

class DataHistory
{
	hidden var historicalData;
	hidden var sampleCount;
	hidden var timeToTrack;
	
	var Bearing = 0.0;
	var Speed = 0.0;
	var HasData = false;
	
	function initialize(sampleCountIn, timeToTrackIn)
	{
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
		}
	}
}

class SailingDataTracker {
	
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