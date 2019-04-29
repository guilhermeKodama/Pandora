method = DeviceServers.prototype;

/* INCLUDES */
var net = require('net');

var deviceID;

var timer = 0.0;

var serverECG;
var bufferECG = [];

var bufferBPM = [];
var lastValueBPM;

var serverSPO2;
var bufferSPO2 = [];
var lastValueSPO2;

var serverAirFlow;
var bufferAirFlow = [];
var lastValueAirFlow;

var serverEMG;
var bufferEMG = [];
var lastValueEMG;

var serverTemperature;
var bufferTemperature = [];
var lastValueTemperature;

var serverBloodPressure;
var bufferSystole = [];
var bufferDiastole = [];
var lastValueSystole;
var lastValueDiastole;

var serverPatientPosition;
var bufferPatientPosition = [];
var lastValuePatientPosition;


function DeviceServers (deviceID,ecg,spo2,airflow,emg,temperature,bloodpressure,patientposition){

	this.deviceID = deviceID

	serverECG = ecg;
	serverSPO2 = spo2;
	serverAirFlow = airflow;
	serverEMG = emg;
	serverTemperature = temperature;
	serverBloodPressure = bloodpressure;
	serverPatientPosition = patientposition;

	//estabelece conexão com o classificador
	var HOST = '127.0.0.1';
	var PORT = 2428;
	console.log('TENTANDO ME CONECTAR');
	this.classifierSocket = new net.Socket();

	this.classifierSocket.connect(PORT, HOST, function() {
		console.log('CLASSIFIER CONNECTED TO: ' + HOST + ':' + PORT);
	});

	this.classifierSocket.on('error', function(err){
	    console.log("Error: "+err.message);
	});


	/* ECG */
	serverECG.server.on("message",function(msg, rinfo){

		/* 
			PRECISAMOS URGENTEMENTE COMEÇAR A CALCULAR REALMENTE QUAL É O SAMPLING RATE DE ALGUMA
			FORMA MAIS INTELIGENTE.
		*/
		sampling_rate = 0.004;

		// console.log('ECG_DEVICE_SERVER '+parseFloat(msg));
		bufferECG.push(parseFloat(msg));
		bufferBPM.push(lastValueBPM);
		bufferSPO2.push(lastValueSPO2);
		bufferAirFlow.push(lastValueAirFlow);
		bufferEMG.push(lastValueEMG);
		bufferTemperature.push(lastValueTemperature);
		bufferSystole.push(lastValueSystole);
		bufferDiastole.push(lastValueDiastole);
		bufferPatientPosition.push(lastValuePatientPosition);


		timer = timer + sampling_rate;

		if(timer >= 3){

			//envia informação para o classificador
			this.classifierSocket.write(JSON.stringify(
			{ 
				ECG:bufferECG,
				S:{
					BPM:bufferBPM,
					SPO2:bufferSPO2,
					AIRFLOW:bufferAirFlow,
					EMG:bufferEMG,
					SYSTOLE:bufferSystole,
					DIASTOLE:bufferDiastole,
					TEMPERATURE:bufferTemperature,
					PACIENT_POSITION:bufferPatientPosition
				},
				device_id:this.deviceID
			}
			));

			//limpa os buffers
			bufferECG = [];
			bufferBPM = [];
			bufferSPO2 = [];
			bufferAirFlow = [];
			bufferEMG = [];
			bufferTemperature = [];
			bufferSystole = [];
			bufferDiastole = [];
			bufferPatientPosition = [];
			//reset o timer
			timer = 0.0;
		}

	}.bind(this));

	/*BPM*/
	serverECG.clientSocket.on('data', function(chunk) {
		bpm = String.fromCharCode.apply(null,new Uint16Array(chunk));
		lastValueBPM = parseInt(bpm);
	});

	/* SPO2 */
	serverSPO2.server.on("message",function(msg, rinfo){
		// console.log('SPO2_DEVICE_SERVER '+parseFloat(msg));
		lastValueSPO2 = parseFloat(msg);
	});

	/* AirFlow */
	serverAirFlow.server.on("message",function(msg, rinfo){
		// console.log('AIRFLOW_DEVICE_SERVER '+parseFloat(msg));
		lastValueAirFlow = parseFloat(msg);
	});

	/* EMG */
	serverEMG.server.on("message",function(msg, rinfo){
		// console.log('EMG_DEVICE_SERVER '+parseFloat(msg));
		lastValueEMG = parseFloat(msg);
	});

	/* Temperature */
	serverTemperature.server.on("message",function(msg, rinfo){
		// console.log('TEMPERATURE_DEVICE_SERVER '+parseFloat(msg));
		lastValueTemperature = parseFloat(msg);
	});

	/* BloodPressure */
	serverBloodPressure.server.on("message",function(msg, rinfo){
		msg = String.fromCharCode.apply(null,new Uint16Array(msg));
		if(msg != null){
			ms = msg.split(",");
			systole = ms[0];
			diastole = ms[1];
		}
		
		// console.log('BP_DEVICE_SERVER '+systole+' '+diastole);
		lastValueSystole = parseInt(systole);
		lastValueDiastole = parseInt(diastole);
	});

	/* PatientPosition */
	serverPatientPosition.server.on("message",function(msg, rinfo){
		// console.log('PATIENTPOSITION_DEVICE_SERVER '+parseFloat(msg));
		lastValuePatientPosition = parseFloat(msg);
	});

}

//export the class
module.exports = DeviceServers;

