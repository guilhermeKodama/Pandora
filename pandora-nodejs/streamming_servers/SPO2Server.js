//private variables
var http = require('http');
var url = require('url');
var socket = require('socket.io');
var md5 = require('MD5');
var that = this;

//Constructor
function SPO2Server(DEVICE_ID,IN_PORT,OUT_PORT){
	//initialize instance properties
	this.DEVICE_ID = DEVICE_ID;
	this.IN_PORT = IN_PORT;
	this.OUT_PORT = OUT_PORT;
	//Ports
	this.portClient = !isNaN(process.argv[2]) ? process.argv[2] : this.OUT_PORT;
	this.portSensor = !isNaN(process.argv[3]) ? process.argv[3] : this.IN_PORT;

	//http listen
	this.httpServer = http.createServer().listen(this.portClient);
	this.httpSocketIo = socket.listen(this.httpServer);
	this.oldData = null;

	//udp server on portSensor
	this.server = require("dgram").createSocket("udp4");
}

///class methods
SPO2Server.prototype.connect = function(){
	//triggered on incomming message throught the udp server launched after
	this.server.on("message",function(msg,rinfo){
		//Store Hash from object
		var temp = md5(msg);
		// console.log("spo2: "+msg);

		//Avoid similar objects to update the client website
		//Compare with Object hash with last obhect hash
		if(this.oldData != temp){
			//Send message to client website
			this.httpSocketIo.sockets.emit('spo2',String.fromCharCode.apply(null,new Uint16Array(msg)));
			//Log in console
			// console.log("ecg: "+msg);
		}
		//Store actual object hash
		oldData = temp;
	}.bind(this));

	//Start listening on udp server port portSensor
	this.server.on("listening",function(){
		var address = this.server.address();
		console.log("SPO2 - listening "+ address.address + ":" + address.port);
		console.log("SPO2 - broadcasting to "+ address.address + ":" + this.portClient);
	}.bind(this));
	//conecta o servidor UDP
	this.server.bind(this.portSensor);
}

//export the class
module.exports = SPO2Server;