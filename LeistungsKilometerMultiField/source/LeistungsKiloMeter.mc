using Toybox.FitContributor as Fit;
using Toybox.ActivityRecording;
using Toybox.Time;
using Toybox.Position;
using Toybox.Math;

module LeistungsKiloMeter2 {

var prevTime;
var values = {};
var totTime = 0;
var totLkm = 0.0f;


var countTrigger = 60;
var counter = 0;

		        	
   function updateLeistungsKilometer(info){
           if(info has :altitude && info has :elapsedDistance && info has :startTime  && info has :timerTime){
		        if(info.altitude != null && info.elapsedDistance != null && info.startTime != null && info.timerTime !=null){
		       	
		        var now = new Time.Moment(info.timerTime);
		        var timeToUse = prevTime;
		        var timeFromPrevPoint;
		        if(timeToUse == null){
		        	timeFromPrevPoint = now;
		        } else {
		        	timeFromPrevPoint = now.subtract(new Time.Moment(timeToUse.toLong()));	
		        }        
			    var steepness = 0.0f;
		        var lkm = 0.0f;
		        var lkmh = 0.0f;
		        if(values.hasKey("lkm")){			       
			        var deltaAlti = info.altitude.toFloat() - values.get("altitude") ;
			        var deltaDistance = info.elapsedDistance.toFloat() - values.get("distance");	
			        deltaDistance = deltaDistance.abs();  
			       	steepness = 0;
			        if(deltaDistance.toFloat()!=0){
			        	steepness = deltaAlti.toFloat() / deltaDistance.toFloat();
			        } 
			        var hoursElapsed = timeFromPrevPoint.value().toFloat() / 3600000;
			        
			       	lkm = getLeistungsKilometer(deltaDistance, steepness, deltaAlti);
			       	if(hoursElapsed>0){
			        	lkmh = lkm/hoursElapsed;
			        }
		        }
	        	
			        	     	updateValues(lkm, timeFromPrevPoint,lkmh,info,steepness,now);		              
		       		 }  
	       		  
				}  
			}
			
			function updateValues(lkm, timeFromPrevPoint,lkmh,info,steepness,now){
				totLkm += lkm;
	        	totTime += timeFromPrevPoint.value().toFloat();
               	updatePointValues(lkm,lkmh,info,timeFromPrevPoint,steepness);
                prevTime = now.value();
			}
			
					
			
		function getLeistungsKilometer(deltaDistance, steepness, deltaAlti){
					var lkm = deltaDistance/1000;
					deltaAlti = deltaAlti.abs();
			        if(-0.2>steepness){
			        	lkm += (deltaAlti/150);
			        } else if (0<=steepness){
			        	lkm += (deltaAlti/100);
			        }
			        return lkm;
			}
			
		function updatePointValues(lkm,lkmh,info,timeFromPrevPoint, steepness){					
	                values.put("lkm",lkm);
	                values.put("lkmh",lkmh);
	                values.put("altitude",info.altitude.toFloat());		       
		        	values.put("timeElapsed",timeFromPrevPoint);
		        	values.put("distance",info.elapsedDistance.toFloat());
		        	values.put("steepness",steepness);	                     
		}		
		
			
		function checkIfUpdateNeeded(info){
			var now = new Time.Moment(Time.now().value());
			var gpsQuality = Position.getInfo().accuracy;
			if(counter % countTrigger == 0){
				if(prevTime!=now.value() && (gpsQuality > 1)){
			 	updateLeistungsKilometer(info);
			 	} else {	
			 		//if gps uality not good enough wait for next iteration
			 		if(counter>0){
			 		counter--;
			 		}
			 	}
			}
			counter ++;
	           if(counter == (100 * countTrigger)){
	              	counter = 0;
	              }
			
		}
			
		function getLeistungsKilometerProStunde(info){		
			checkIfUpdateNeeded(info);			
			var lkmh = 0;
			if(values.hasKey("lkmh")){
				lkmh = values.get("lkmh");
			}
			return lkmh;
		}
		
		function getSteepness(info){		
			checkIfUpdateNeeded(info);			
			var steepness = 0;
			if(values.hasKey("steepness")){
				steepness = values.get("steepness");
			}
			return steepness;
		}
		
		function getAverageLeistungsKilometerProStunde(info){
			checkIfUpdateNeeded(info);	 
			var avLKM = 0;
			if(totTime>0){
				var hours = totTime / 3600000;
				avLKM = totLkm / hours;	
			}		
			return avLKM;
		}
		
		function getTotalLkm(info){
			checkIfUpdateNeeded(info);
			return totLkm;
		}
		
		function clear(){
			prevTime = null;
			values = {};
		}
		
		function setTrigger(countTriggerIn){
			self.countTrigger = countTriggerIn;
		}
		
		function activityPaused(){
			Application.Storage.setValue("totLKM",totLkm);
		}
		
		function activityResumed(){
			var lkm = Application.Storage.get("totLKM");
			if(lkm != null){
			 	totLkm = lkm;
			 	}
		}
		
		
}
