using Toybox.Math;

class AngleUtil {
	 	static const PI = 3.141592653589793;
        static const DegToRad = (2.0 * PI / 360.0);
        static const RadToDeg = 1.0 / DegToRad;


        static function ShortAngle(fAngle1, fAngle2)
        {
            var fDelta = fAngle2 - fAngle1;
            while (fDelta > 180.0f) {
            	fDelta -= 360.0f;
            }
            while (fDelta < -180.0f) {
            	fDelta += 360.0f;
            }
            return fDelta;
        }

        static function CalculateAverage(angle1, angle2)
        {
            return ContainAngle0To360((angle1 + Anchor(angle2, angle1)) * 0.5);
        }

        static function Anchor(fValue, fAnchor)
        {
            while (fValue - fAnchor > 180.0f) {
            	fValue -= 360.0f;
            }
            while (fValue - fAnchor < -180.0f) {
            	fValue += 360.0f;
            }
            return fValue;
        }

        static function ContainAngle0To360(fAngle)
        {
            while (fAngle > 360.0f) {
            	fAngle -= 360.0f;
            }
            while (fAngle < 0.0f) {
            	fAngle += 360.0f;
            }
            return fAngle;
        }

        static function ContainAngleMinus180To180(fAngle)
        {
            while (fAngle > 180.0f) {
            	fAngle -= 360.0f;
            }
            while (fAngle < -180.0f) {
            	fAngle += 360.0f;
            }
            return fAngle;
        }
}


class LocationMath {
		//http://www.movable-type.co.uk/scripts/latlong.html?from=49.243824,-121.887340&to=49.227648,-121.89631
		
 		static const R = 6371.0 * 1000.0;    // m
 
 		static function BearingBetweenCoords(lat1, long1, lat2, long2)
 		{
	 		var dLon = (long2 - long1);

		    var y = Math.sin(dLon) * Math.cos(lat2);
		    var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1)
		            * Math.cos(lat2) * Math.cos(dLon);
		
		    var brng = Math.atan2(y, x);
		
		    brng = Math.toDegrees(brng);
		    brng = AngleUtil.ContainAngle0To360(brng + 360.0);
		    brng = 360.0 - brng; // count degrees counter-clockwise - remove to make clockwise
 			return brng;
 		}
 
		static function DistanceBetweenCoords(fFromLat, fFromLong, fToLat, fToLong)
        {
	        //var dLat = (fFromLat - fToLat) * AngleUtil.DegToRad;
            var dLat = (fFromLat - fToLat);
            dLat *= AngleUtil.DegToRad;
            var dLon = (fFromLong - fToLong) * AngleUtil.DegToRad;
            var lat1 = fToLat * AngleUtil.DegToRad;
            var lat2 = fFromLat * AngleUtil.DegToRad;
	        var fDLatOver2 = dLat * 0.5f;
	        var fDLongOver2 = dLon * 0.5f;
	        var a = Math.sin(fDLatOver2) * Math.sin(fDLatOver2) +
		        Math.sin(fDLongOver2) * Math.sin(fDLongOver2) * Math.cos(lat1) * Math.cos(lat2);
	        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	        var d = R * c;
	        return d;
        }
}