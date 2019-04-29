method = MedicalStaffDAO.prototype;

function MedicalStaffDAO(){}

method.save = function (json, conn, pg, callback) {
	pg.connect(conn, function(error, client, done) {
		if (error) {
			callback(error);
		} else {
			client.query('SELECT (cpf, token) FROM medical_staff WHERE cpf = ($1)', [json.cpf], function(error, result) {
				if (!error) {				
					if (result.rows.length > 0) {
						client.query('UPDATE medical_staff SET token = ($1) WHERE cpf = ($2)', [json.token, json.cpf], function(error, result) {
							done();
							callback(error);
						});
					} else {
						done();
						callback("cpf nao encontrado");
					}
				} else {
					done();		
					callback(error);	
				}
			});
		}
	});
}

method.subscribe = function (json, conn, pg, callback) {
	pg.connect(conn, function(error, client, done) {
		if (error) {
			callback(error);
		} else {
			client.query('SELECT (bed_id, staff_cpf) FROM bed_staff WHERE bed_id = ($1) AND staff_cpf = ($2)', [json.bed_id, json.cpf], function(error, result) {
				if (!error) {
					if (result.rows.length > 0) {
						done();						
						callback('ja existe uma relacao entre essa bed_id e esse cpf');
					} else {
						client.query('INSERT INTO bed_staff (bed_id, staff_cpf) VALUES ($1, $2)', [json.bed_id, json.cpf], function (error, result) {
							done();
							callback(error);
						});
					}
				} else {
					done();
					callback(error);
				}
			}); 
		}
	});
}

method.unsubscribe = function (json, conn, pg, callback) {
	pg.connect(conn, function(error, client, done) {
		if (error) {
			callback(error);
		} else {
			client.query('SELECT (bed_id, staff_cpf) FROM bed_staff WHERE bed_id = ($1) AND staff_cpf = ($2)', [json.bed_id, json.cpf], function(error, result) {
				if (!error) {
					if (result.rows.length == 0) {
						done();
						callback('nao existe uma relacao entre essa bed_id e esse cpf');
					} else {
						client.query('DELETE FROM bed_staff WHERE bed_id = ($1) AND staff_cpf = ($2)', [json.bed_id, json.cpf], function (error, result) {
							done();
							callback(error);
						});
					}
				} else {
					done();
					callback(error);
				}
			}); 
		}
	});
}

method.subscriptions = function(cpf, conn, pg, callback) {
	pg.connect(conn, function(error, client, done) {
		if (error) {
			callback({'error': error});
		} else {
			client.query('SELECT bed.id bed_id, bed.description bed_description, case when bed_staff.staff_cpf = $1 then TRUE else FALSE END as has_subscription FROM bed LEFT JOIN bed_staff ON bed.id = bed_staff.bed_id;', [cpf], function(error, result) {
				if (!error) {
					done();
					callback(result.rows);
				} else {
					done();
					callback({'error': error});
				}
			});
		}
	});
}

module.exports = MedicalStaffDAO;