method = AP.prototype;

function AP() {
	this.count = 1;
	this.difference = 6;
	this.emgCount = 1;
}

method.updateFormula = function() {
	this.ecg = 2 + (this.count - 1) * this.difference;
	this.time = 1 + (this.count - 1) * this.difference;
	this.spo2 = 6 + (this.count - 1) * this.difference;
	this.respA = 4 + (this.count - 1) * this.difference;
	this.emg = 1 + (this.emgCount - 1) * 2;
}

module.exports = AP;