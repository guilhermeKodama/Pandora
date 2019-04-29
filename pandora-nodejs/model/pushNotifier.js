//openssl rsa -in cert.pem -out key.pem

var pg = require('pg');
//postgres
var conn = "pg://guilherme@localhost:5432/pandora";

var apn  = require("apn")

var apnError = function(err){
    console.log("APN Error:", err);
}

var options = {
    "cert": "cert.pem",
    "key":  "key.pem",
    "passphrase": "Gk59AEVm8wR5",
    "gateway": "gateway.sandbox.push.apple.com",
    "port": 2195,
    "enhanced": true,
    "cacheLength": 100
  };
options.errorCallback = apnError;

var feedBackOptions = {
    "batchFeedback": true,
    "interval": 300
};

var apnConnection, feedback;

module.exports = {
    init : function(){
        apnConnection = new apn.Connection(options);

        feedback = new apn.Feedback(feedBackOptions);
        feedback.on("feedback", function(devices) {
            devices.forEach(function(item) {
                //TODO Do something with item.device and item.time;
                console.log("ITEM : "+item);
            });
        });
    },

    sendAll : function (device_id,params){
        pg.connect(conn, function(err, client, done) {
            if(err) {
                return console.error('error fetching client from pool', err);
            }
            client.query('SELECT medical_staff.token token FROM "medical_staff"',[],function(errSelect, resultSelect) {
                //checa se ocorreu algum erro
                if(err) {
                    console.error('error running query', err);
                }
                var rows = resultSelect.rows;
                for (var i = 0; i < rows.length; i++) {
                    console.log('TOKEN: ', rows[i].token);
                }
            });
        });
    },

    send : function (params){
        var myDevice, note;

        console.log(params);
        console.log(params.token);
        
        myDevice = new apn.Device(params.token);
        note = new apn.Notification();

        note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
        // note.badge = 0;
        note.sound = "ping.aiff";
        note.alert = params.message;
        note.payload = {'messageFrom': params.from};

        if ( typeof params.bed_id !== 'undefined' && params.bed_id){
            console.log('to aqui');
            note.payload['bed_id'] = params.bed_id;
            note.payload['bed_description'] = params.bed_description;
        }

        if(apnConnection) {
            apnConnection.pushNotification(note, myDevice);
        }
    }
}

/*usage
pushNotifier = require("./pushNotifier");
pushNotifier.init();
//use valid device token to get it working 
pushNotifier.process({token:'', message:'Test message', from: 'sender'});
*/