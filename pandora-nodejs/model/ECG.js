method = ECG.prototype;

function ECG() { 
	this.bpm = 0;
}


method.appendECG = function(ecg, time) {
    newECG = [];
	
    for (var i = 0; i < ecg.length; i++) {
        newECG.push({ecg: ecg[i], time: time[i]});
    }
	
	return newECG;
}

method.calculatedAverage = function(ecg) {
    total = ecg[0];
    offset = parseInt(ecg.length * 0.95);

	for (var i = ecg.length - 1; i > offset; i--) {
		total = total + ecg[i];
	}

	return total / (ecg.length - offset);
}

method.compareECG = function(a, b) {
	if (a.ecg < b.ecg)
		return -1;
	else if (a.ecg > b.ecg)
		return 1;
	else 
		return 0;
}

method.compareTime = function(a, b) {
	if (a.time < b.time)
		return -1;
	else if (a.time > b.time)
		return 1;
	else 
		return 0;
}

method.calculatedBPM = function(array) {
    first_time = null;
    
	for (var i = 0; i < array.length; i++) {
		time = array[i].time;
		
		if (first_time == null) {
			first_time = time;
		} else {
			second_time = time;
			
			delta_time = second_time - first_time;
			
			if (delta_time > 0.12) {
				bpm = 60000 / (delta_time * 1000);
			
				first_time = second_time;
			
				return bpm;				
			}
		}
	}
}

method.desiredECG = function(ecg, array) {
    new_array = [];

	average = this.calculatedAverage(array);
	console.log('AVERAGE : '+average);
	
	for (var i = 0; i < ecg.length; i++) {
		if (ecg[i].ecg > average) {
			new_array.push(ecg[i]);					
		}
	}
	
	return new_array;
}

method.updateBPM = function (data, time, callback) {
	
	ecg = this.appendECG(data, time);
	
	ecg.sort(this.compareECG);
		
	data.sort();

	new_array = this.desiredECG(ecg, data);

	new_array.sort(this.compareTime);

	bpm = this.calculatedBPM(ecg);

	callback(bpm);

}

module.exports = ECG;