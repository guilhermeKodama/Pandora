method = DeviceDAO.prototype;

function DeviceDAO() {}

method.getStaffSubscriptions = function(json, conn, pg, callback) {
	var extraInfo = [];
	pg.connect(conn, function(error, client, done) {
		if (!error) {
			client.query('SELECT d.bed_id as bed_id,b.description as bed_description,b.hospital_id as hospital_id FROM device d JOIN bed b ON d.bed_id = b.id WHERE d.id = $1',[json.device_id],function(error, resultBed) {
				if (!error) {

					extraInfo['bed_id'] = resultBed.rows[0]["bed_id"];
					extraInfo['bed_description'] = resultBed.rows[0]["bed_description"];
					extraInfo['hospital_id'] = resultBed.rows[0]["hospital_id"];

					client.query('SELECT m.cpf,m.name,m.token FROM bed_staff b JOIN medical_staff m ON b.staff_cpf = m.cpf WHERE b.bed_id = $1',[resultBed.rows[0]["bed_id"]], function(error, resultTokens) {
						if (!error) {
							done();
							callback(resultTokens.rows,extraInfo);
							
						} else {
							done();
							callback({'error': error},null);
						}
					});
				} else {
					done();
					callback({'error': error},null);
				}
			});
		} else {
			callback({'error': error},null);
		}
	});
}

module.exports = DeviceDAO;