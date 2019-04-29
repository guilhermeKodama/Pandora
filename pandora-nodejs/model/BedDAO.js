method = BedDAO.prototype;

function BedDAO() {}

method.getAll = function(cnpj,cpf, conn, pg, callback) {
	pg.connect(conn, function(error, client, done) {
		if (!error) {
			client.query('SELECT id bed_id, description bed_description,case when id IN (select bed_id from device) then TRUE else FALSE END as has_connection,case when id IN (select bed_id from bed_staff where staff_cpf = $1) then TRUE else FALSE END as has_subscription  FROM bed WHERE bed.hospital_id = $2 GROUP BY bed_id ORDER BY bed_id', [cpf,cnpj], function(error, result) {
				if (!error) {
					done();
					callback(result.rows);
				} else {
					done();
					callback({'error': error});
				}
			});
		} else {
			callback({'error': error});
		}
	});
}

module.exports = BedDAO;