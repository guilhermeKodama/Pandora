//É necessário instanciar os módulos abaixo nessa ordem!
app		 		= require('express')();
http			= require('http');
server 			= http.createServer(app);
io 				= require('socket.io').listen(server);
fs 				= require('fs');
pg				= require('pg');
bodyParser 		= require('body-parser');
multer 			= require('multer');
killable 		= require('killable');
upload 			= multer({ dest: 'uploads/' });
freeport 		= require('freeport');
ECGClass 		= require('./model/ECG.js');
APClass 		= require('./model/AP.js');
MedicalStaffDAO	= require('./model/MedicalStaffDAO.js');
BedDAO			= require('./model/BedDAO.js');
ECG 			= new ECGClass();
AP 				= new APClass();
medicalStaffDAO	= new MedicalStaffDAO();
bedDAO			= new BedDAO();
// conn 			= 'pg://kevinoliveira@localhost:5432/pandora';
conn			= 'pg://guilherme@localhost:5432/pandora';
// conn 			= 'pg://root:multi@media2@localhost:5432/pandora';

var DeviceDAO	= require('./model/DeviceDAO.js');

//modulos dos sensores
var ECGServer = require('./streamming_servers/ECGServer.js');
var SPO2Server = require('./streamming_servers/SPO2Server.js');
var AirFlowServer = require('./streamming_servers/AirFlowServer.js');
var EMGServer = require('./streamming_servers/EMGServer.js');
var TemperatureServer = require('./streamming_servers/TemperatureServer.js');
var BloodPressureServer = require('./streamming_servers/BloodPressureServer.js');
var PatientPositionServer = require('./streamming_servers/PatientPositionServer.js');
var DeviceServers = require('./streamming_servers/DeviceServers.js');

//array que guarda os dispositivos que estão conectados ao servidor
var devices = []

//notificação
pushNotifier = require("./model/pushNotifier");
pushNotifier.init();

// Data struct
// Elapsed time	    ECG	 Resp C	 Resp A	 Resp N	   SpO2
//    (seconds)	   (mV)	   (mV)	   (mV)	   (mV)	   (mV)
//        0.000	 -0.060	 -0.102	 -0.345	  0.235	 98.000
  
// Read file
var dataArray = fs.readFileSync('data.txt').toString().split(/[\s,]+/);
var emgData = fs.readFileSync('emg.txt').toString().split(/[\s,]+/);

server.listen(2426,'192.168.0.5',function(){
	console.log("+++++PANDORA REAL-TIME SERVER+++++");
});

app.use(bodyParser.json());

app.get('/', function (req, res) {
	res.sendFile(__dirname + '/index.html');
});

//recebe informacoes de login de um medico (cpf, token)
app.post('/medical_staff/signin', upload.array(), function(request, response) {
	var json = request.body;
	
	medicalStaffDAO.save(json, conn, pg, function(message) {
		response.send([{'error': message}]);	
	})

});

//subscribe de push notification de um leito para um medico (cpf, bed_id)
app.post('/medical_staff/subscribe', upload.array(), function(request, response) { 
	var json = request.body;
	
	medicalStaffDAO.subscribe(json, conn, pg, function(error) {
		response.send([{'error': error}]);
	});
	
});

//unsubscribe de push notification de um leito para um medico (cpf, bed_id)
app.post('/medical_staff/unsubscribe', upload.array(), function(request, response) { 
	var json = request.body;
	
	medicalStaffDAO.unsubscribe(json, conn, pg, function(error) {
		response.send([{'error': error}]);
	});
	
});

//retornar todos os leitos de um medico (cpf)
app.get('/medical_staff/subscriptions/:cpf', function(request, response) {
	var cpf = request.params.cpf;

	medicalStaffDAO.subscriptions(cpf, conn, pg, function(result) {
		response.send(result);
	});
	
});

//retornar todos os leitos cadastrados (cpf)
app.get('/beds/:cnpj/:cpf', function(request, response) {
	var cnpj = request.params.cnpj;
	var cpf = request.params.cpf;
	
	bedDAO.getAll(cnpj,cpf,conn, pg, function(result) {
		response.send(result);
	});
});

//retornar todos os leitos cadastrados (cpf)
app.get('/beds/:cnpj', function(request, response) {
	var cnpj = request.params.cnpj;
	var cpf = '0102';
	
	bedDAO.getAll(cnpj,cpf,conn, pg, function(result) {
		response.send(result);
	});
});

// ENVIA PUSH NOTIFICATION
app.post('/push',upload.array(), function(request,response){
	//use valid device token to get it working 
	pushNotifier.send({token:'14159c7d5fc267d3f0b10497a74a2135a04d6720a76e01d3e92b4d68abf00356',
	 message:'teste',
	 from: 'sender'});
	response.send([{"result":"everything ok"}]);
});

//para coração
app.post('/stopheart',upload.array(),function(request,response){
	this.DEVICE_ID = 1;
	deviceDAO	= new DeviceDAO();
	event_id = 1;
	//envia notificação a todos os medicos que estão inscritos no leito relacionado ao id desse device
	//id do evento que você acabou de detectar , verifica no dump
	deviceDAO.getStaffSubscriptions({"device_id":this.DEVICE_ID}, conn, pg, function(rows,extraInfo){
		for (var i in rows) {

			pg.connect(conn, function(error, client, done) {
				if (!error) {
					/* inserir log */
					client.query('INSERT INTO "public"."event_log"("event_id", "timestamp_send", "device_id", "bed_id", "staff_cpf", "hospital_cnpj") VALUES($1,CURRENT_TIMESTAMP,$2,$3::int,$4, $5);',[event_id,this.DEVICE_ID,extraInfo['bed_id'],rows[i]["cpf"],extraInfo['hospital_id']], function(error, result) {
						done();
					}.bind(this));
				}else{
					console.log(error);
				}
			}.bind(this));

			pushNotifier.send({token:rows[i]["token"],
				bed_id:extraInfo['bed_id'],
				bed_description:extraInfo['bed_description'],
				message:"Bradicardia.O paciente no "+extraInfo['bed_description']+" necessita de assistência imediatamente",
				from: 'sender'});
		}

	}.bind(this));

	response.send([{"result":"everything ok"}]);
});

//coração muito lento
app.post('/bradycardia',upload.array(),function(request,response){
	var json = request.body;
	console.log(json);

	pushNotifier.send({token:json.token,
	 message:json.message,
	 from: 'sender'});
	
	response.send([{"result":"everything ok"}]);
});

//coração muito rápido
app.post('/tachycardia',upload.array(),function(request,response){
	var json = request.body;
	console.log(json);

	pushNotifier.send({token:json.token,
	 message:json.message,
	 from: 'sender'});
	
	response.send([{"result":"everything ok"}]);
});

//adicionar um novo pizinho para fazer streamming
app.post('/device/connection/create', upload.array(), function(request, response) { 
	var json = request.body;
	console.log(json);

	var ports = [];
	var fakeServers = [];
	//gera as novas portas de entrada e saida para cada sensor
	function bindPort(err, port) {
		if (err) throw err;
		
		var s = http.createServer(app);
		killable(s);
		s.listen(port,function(){
			fakeServers.push(s);
			ports.push(port);
			console.log(ports);
			if(ports.length < 14){
				freeport(bindPort);
			}else{
				//libera as portas dos servidores temporarios
				freePorts(fakeServers[0],0);
			}
		});
	}

	freeport(bindPort);
	//estabelece conexão
	function freePorts(fakeServer,position){
		var tempPort = fakeServer.address().port;
		console.log(tempPort);
		fakeServer.kill(function () {
			if(tempPort == ports[ports.length-1]){
				//cria as conexoes do streamming
				createServers(json.device_id,ports,function(){
					//salva as informações de conexão no banco de dados
					saveConnections();
				});
			}else{
				position++;
				freePorts(fakeServers[position],position);
			}
		});
	}
	//insere informações na tabela connection
	function saveConnections(){
		console.log("PERSISTINDO CONNECTIONS");
		pg.connect(conn, function(error, client, done) {
			//ECG
			client.query('INSERT INTO "public"."connection"("sensor_id", "input_port", "output_port", "device_id") VALUES($1,$2,$3,$4)',[1,ports[0],ports[1],json.device_id], function (error, result) {});
			//SPO2
			client.query('INSERT INTO "public"."connection"("sensor_id", "input_port", "output_port", "device_id") VALUES($1,$2,$3,$4)',[2,ports[2],ports[3],json.device_id], function (error, result) {});
			//AIRFLOW
			client.query('INSERT INTO "public"."connection"("sensor_id", "input_port", "output_port", "device_id") VALUES($1,$2,$3,$4)',[3,ports[4],ports[5],json.device_id], function (error, result) {});
			//EMG
			client.query('INSERT INTO "public"."connection"("sensor_id", "input_port", "output_port", "device_id") VALUES($1,$2,$3,$4)',[4,ports[6],ports[7],json.device_id], function (error, result) {});
			//TEMPERATURE
			client.query('INSERT INTO "public"."connection"("sensor_id", "input_port", "output_port", "device_id") VALUES($1,$2,$3,$4)',[5,ports[8],ports[9],json.device_id], function (error, result) {});
			//BLOODPRESSURE
			client.query('INSERT INTO "public"."connection"("sensor_id", "input_port", "output_port", "device_id") VALUES($1,$2,$3,$4)',[6,ports[10],ports[11],json.device_id], function (error, result) {});
			//PATIENT POSITION
			client.query('INSERT INTO "public"."connection"("sensor_id", "input_port", "output_port", "device_id") VALUES($1,$2,$3,$4)',[7,ports[12],ports[13],json.device_id], function (error, result) {
				done();
				//envia de volta quais portas o pizinho deve fazer o envio
				response.send([{"ECG_IN":ports[0],"ECG_OUT":ports[1],"SPO2_IN":ports[2],"SPO2_OUT":ports[3],"AIRFLOW_IN":ports[4],"AIRFLOW_OUT":ports[5],"EMG_IN":ports[6],"EMG_OUT":ports[7],"TEMPERATURE_IN":ports[8],"TEMPERATURE_OUT":ports[9],"BLOODPRESSURE_IN":ports[10],"BLOODPRESSURE_OUT":ports[11],"PATIENTPOSITION_IN":ports[12],"PATIENTPOSITION_OUT":ports[13]}]);
			});
		});
	}
});

app.post('/device/connection/stablish', upload.array(), function(request, response) { 
	var json = request.body;
	console.log(json);
	//recupera do BD as portas de output do pizinho X
	pg.connect(conn, function(error, client, done) {
			//ECG
			client.query('SELECT sensor_id,output_port FROM connection WHERE device_id = $1',[json.device_id], function (error, result) {
				//envia informações
				response.send(result.rows);
				done();
			});
	});
});

//SERVIDORES DE STREAMMING
//var p = [41181,8443,41182,8444,41183,8445,41184,8446,41185,8447,41186,8448,41187,8449];
//createServers(p,function(){});

function createServers(deviceID,pts,callback){
	serverECG = new ECGServer(deviceID,pts[0],pts[1]);
	serverECG.connect();

	serverSPO2 = new SPO2Server(deviceID,pts[2],pts[3]);
	serverSPO2.connect();

	serverAirFlow = new AirFlowServer(deviceID,pts[4],pts[5]);
	serverAirFlow.connect();

	serverEMG = new EMGServer(deviceID,pts[6],pts[7]);
	serverEMG.connect();

	serverTemperature = new TemperatureServer(deviceID,pts[8],pts[9]);
	serverTemperature.connect();

	serverBloodPressure = new BloodPressureServer(deviceID,pts[10],pts[11]);
	serverBloodPressure.connect();

	serverPatientPosition = new PatientPositionServer(deviceID,pts[12],pts[13]);
	serverPatientPosition.connect();

	callback();

	deviceServer = new DeviceServers(deviceID,serverECG,serverSPO2,serverAirFlow,serverEMG,serverTemperature,serverBloodPressure,serverPatientPosition);

	devices.push(deviceServer)
}

/* TIMELINE */
app.get('/timeline/:device_id', upload.array(), function(request, response) { 
	var device_id = request.params.device_id;
	//recupera do BD as portas de output do pizinho X
	pg.connect(conn, function(error, client, done) {
			//ECG
			client.query('SELECT * FROM timeline WHERE device_id = $1',[device_id], function (error, result) {
				//checa se ocorreu algum erro
		      if(error) {done();console.error('error running query', err);}
				//envia informações
				response.send(result.rows);
				done();
			});
	});
});

