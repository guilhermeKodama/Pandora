method = ECGServer.prototype;

//private variables
var http 			= require('http');
var url 			= require('url');
var socket 			= require('socket.io');
var net 			= require('net');
var md5 			= require('MD5');
var BedDAO			= require('../model/BedDAO.js');
var DeviceDAO		= require('../model/DeviceDAO.js');
var util 			= require('util')
var bedDAO			= new BedDAO();
var deviceDAO		= new DeviceDAO();

//notificação
pushNotifier = require("../model/pushNotifier");
pushNotifier.init();

var ECG = new ECGClass();
var DEVICE_ID = 0;
var time = 0;

//Constructor
function ECGServer (DEV_ID, IN_PORT, OUT_PORT){
	//initialize instance properties
	// this.DEVICE_ID = DEVICE_ID;
	DEVICE_ID = DEV_ID;
	this.IN_PORT = IN_PORT;
	this.OUT_PORT = OUT_PORT;
	
	//Port
	this.portClient = !isNaN(process.argv[2]) ? process.argv[2] : this.OUT_PORT;
	this.portSensor = !isNaN(process.argv[3]) ? process.argv[3] : this.IN_PORT;

	//http listen
	this.httpServer = http.createServer().listen(this.portClient);
	this.httpSocketIo = socket.listen(this.httpServer);
	this.oldData = null;

	//udp server on portSensor
	this.server = require("dgram").createSocket("udp4");

}

//class methods
method.connect = function(){
	var buffer_ecg = []
	var buffer_time = [];
	
	var time_bradycardia = 0;
	var time_tachycardia = 0;
	var time_cardiacArrest = 0;

	var HOST = '127.0.0.1';
	var PORT = 2425;
	this.clientSocket = new net.Socket();

	this.clientSocket.connect(PORT, HOST, function() {
		console.log('CONNECTED TO: ' + HOST + ':' + PORT);
	});


	this.clientSocket.on('data', function(chunk) {
		this.httpSocketIo.sockets.emit('bpm',String.fromCharCode.apply(null,new Uint16Array(chunk)));
		if (time.toFixed(2) % 10 === 0) {
			if(parseInt(chunk) < 40){
				if(parseInt(chunk) == 0){
					this.cardiacArrestAlert();
				}else{
					this.bradycardiaAlert();
				}
			}else if(parseInt(chunk) > 120){
				this.tachycardiaAlert();
			}
		}

    }.bind(this));
	
	//triggered on incomming message throught the udp server launched after
	this.server.on("message",function(msg, rinfo){
		//Store Hash from object
		var temp = md5(msg);
		
		buffer_ecg.push(parseFloat(msg));
		buffer_time.push(time);
		
		time = time + 0.01;

		if (time.toFixed(2) % 2 === 0) {

			this.clientSocket.write(JSON.stringify({"ip":rinfo.address,"port":rinfo.port,"buffer":buffer_ecg}));

			//banho no buffer
			buffer_ecg = [];
		}

		if(this.oldData != temp){
			this.httpSocketIo.sockets.emit('ecg',String.fromCharCode.apply(null,new Uint16Array(msg)));
		}

		oldData = temp;
	}.bind(this));

	//Start listening on udp server port portSensor
	this.server.on("listening",function(){
		var address = this.server.address();
		console.log("ECG - listening "+ address.address + ":" + address.port);
		console.log("ECG - broadcasting to "+ address.address + ":" + this.portClient);
	}.bind(this));
	//conecta o servidor UDP
	this.server.bind(this.portSensor);

}

method.cardiacArrestAlert = function() {
	deviceDAO.getStaffSubscriptions({"device_id": DEVICE_ID}, conn, pg, function(rows,extraInfo){
		var event_id = 1;
		for (var i in rows) {

			pg.connect(conn, function(error, client, done) {
				if (!error) {
					/* inserir log */
					client.query('INSERT INTO "public"."event_log"("event_id", "timestamp_send", "device_id", "bed_id", "staff_cpf", "hospital_cnpj") VALUES($1,CURRENT_TIMESTAMP,$2,$3::int,$4, $5);',[event_id,this.DEVICE_ID,extraInfo['bed_id'],rows[i]["cpf"],extraInfo['hospital_id']], function(error, result) {
						done();
					}.bind(this));
				} else {
					console.log(error);
				}
			}.bind(this));

			pushNotifier.send({token:rows[i]["token"],
				bed_id:extraInfo['bed_id'],
				bed_description:extraInfo['bed_description'],
				message:"Parada cardíaca. O paciente no "+extraInfo['bed_description']+" necessita de assistência imediatamente",
				from: 'sender'});
		}
		
	}.bind(this));
}

method.bradycardiaAlert = function() {
	deviceDAO.getStaffSubscriptions({"device_id": DEVICE_ID}, conn, pg, function(rows,extraInfo){
		var event_id = 2;
		for (var i in rows) {

			pg.connect(conn, function(error, client, done) {
				if (!error) {
					/* inserir log */
					client.query('INSERT INTO "public"."event_log"("event_id", "timestamp_send", "device_id", "bed_id", "staff_cpf", "hospital_cnpj") VALUES($1,CURRENT_TIMESTAMP,$2,$3::int,$4, $5);',[event_id,this.DEVICE_ID,extraInfo['bed_id'],rows[i]["cpf"],extraInfo['hospital_id']], function(error, result) {
						done();
					}.bind(this));
				} else {
					console.log(error);
				}
			}.bind(this));

			pushNotifier.send({token:rows[i]["token"],
				bed_id:extraInfo['bed_id'],
				bed_description:extraInfo['bed_description'],
				message:"Bradicardia. O paciente no "+extraInfo['bed_description']+" necessita de assistência imediatamente",
				from: 'sender'});
		}
		
	}.bind(this));
}

method.tachycardiaAlert = function() {
	deviceDAO.getStaffSubscriptions({"device_id": DEVICE_ID}, conn, pg, function(rows,extraInfo){
		var event_id = 3;
		for (var i in rows) {

			pg.connect(conn, function(error, client, done) {
				if (!error) {
					/* inserir log */
					client.query('INSERT INTO "public"."event_log"("event_id", "timestamp_send", "device_id", "bed_id", "staff_cpf", "hospital_cnpj") VALUES($1,CURRENT_TIMESTAMP,$2,$3::int,$4, $5);',[event_id,this.DEVICE_ID,extraInfo['bed_id'],rows[i]["cpf"],extraInfo['hospital_id']], function(error, result) {
						done();
					}.bind(this));
				} else {
					console.log(error);
				}
			}.bind(this));

			pushNotifier.send({token:rows[i]["token"],
				bed_id:extraInfo['bed_id'],
				bed_description:extraInfo['bed_description'],
				message:"Taquicardia. O paciente no "+extraInfo['bed_description']+" necessita de assistência imediatamente",
				from: 'sender'});
		}
		
	}.bind(this));
}

//export the class
module.exports = ECGServer;

