/*markdown
INSERCION DE POZOS
*/
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo1","life_cycle":"In Service","specification":"square","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404270.31 4928508.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo2","life_cycle":"In Service","specification":"square","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404346.69 4928643.55)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo4","life_cycle":"In Service","specification":"square","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404204.97 4928712.77)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo5","life_cycle":"In Service","specification":"square","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404061.86 4928795.84)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo6","life_cycle":"In Service","specification":"square","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403830.22 4928927.29)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo7","life_cycle":"In Service","specification":"cylindric","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403911.74 4929074.14)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo8","life_cycle":"In Service","specification":"cylindric","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403772.35 4928823.38)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo9","life_cycle":"In Service","specification":"cylindric","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403596.88 4929067.92)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo10","life_cycle":"In Service","specification":"cylindric","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403695.08 4928688.35)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo11","life_cycle":"In Service","specification":"cylindric","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403608.66 4928732.30)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"name":"Pozo12","life_cycle":"In Service","specification":"cylindric","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404338.45 4928470.91)","srid":3857}}}');

/*markdown
INSERCION DE POSTES
*/	

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_pole","fields":{"name":"Poste1","usage":"Telco","material_type":"Steel","life_cycle":"In Service","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403976.17 4929178.57)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_pole","fields":{"name":"Poste2","usage":"Telco","material_type":"Steel","life_cycle":"In Service","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404017.00 4929257.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_pole","fields":{"name":"Poste3","usage":"Telco","material_type":"Steel","life_cycle":"In Service","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404118.58 4929237.43)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_pole","fields":{"name":"Poste4","usage":"Telco","material_type":"Steel","life_cycle":"In Service","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403893.58 4929214.64)","srid":3857}}}');

/*markdown
INSERCION DE RUTAS TERRESTRES
*/
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 1","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 2","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 3","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 4","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 5","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 6","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 7","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 8","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 9","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 10","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)","srid":3857}}}');


/*markdown
INSERCION DE RUTAS AEREAS
*/
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_skyway","fields":{"name":"Skyway 1","life_cycle":"In Service","owner":"Owned","measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_skyway","fields":{"name":"Skyway 2","life_cycle":"In Service","owner":"Owned","measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_skyway","fields":{"name":"Skyway 3","life_cycle":"In Service","owner":"Owned","measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404017.00 4929257.68, -404118.58 4929237.43)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_skyway","fields":{"name":"Skyway 4","life_cycle":"In Service","owner":"Owned","measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403976.17 4929178.57, -403893.58 4929214.64)","srid":3857}}}');

/*markdown
INSERCIÓN DE CONDUCTOS
*/
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_duct","fields":{"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)","srid":3857}}}');
	
/*markdown
INSERCIÓN DE EMPALMES
*/
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"name":"Empalme 1","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403830.22 4928927.29)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"name":"Empalme 2","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403830.22 4928927.29)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"name":"Empalme 3","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403830.22 4928927.29)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"name":"Empalme 4","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403976.17 4929178.57)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"name":"Empalme 5","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403976.17 4929178.57)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"name":"Empalme 6","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404017.00 4929257.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"nam	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_splice","fields":{"name":"Empalme 7","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403695.08 4928688.35)","srid":3857}}}');
e":"Empalme 8","life_cycle":"In Service","type":"Breaking","specification":"FIST-GC02-BD16(80)-M","method":"Fusion","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403695.08 4928688.35)","srid":3857}}}');	

/*markdown
INSERCIÓN DE CABLES POR CANALIZACIONES
*/

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_1","name":"FO Cable 1","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_1","name":"FO Cable 2","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_1","name":"FO Cable 3","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_1","name":"FO Cable 4","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');		
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 6","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 7","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)","srid":3857}}}');	

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_3","name":"FO Cable 8","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_3","name":"FO Cable 9","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 10","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 11","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 12","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)","srid":3857}}}');	

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_5","name":"FO Cable 13","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_5","name":"FO Cable 14","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 15","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 16","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 17","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');	

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_7","name":"FO Cable 18","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_7","name":"FO Cable 19","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 20","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 21","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 22","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');	

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_9","name":"FO Cable 23","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_9","name":"FO Cable 24","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 24","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 25","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 26","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)","srid":3857}}}');	

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_11","name":"FO Cable 27","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_11","name":"FO Cable 28","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 29","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 30","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 311","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)","srid":3857}}}');	

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_13","name":"FO Cable 32","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_13","name":"FO Cable 33","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 34","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 35","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 36","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)","srid":3857}}}');	

/*markdown
	CABLES DE FIBRA QUE POR RUTA AEREA
*/

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 37","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 38","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 39","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 40","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)","srid":3857}}}');
	
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 41","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 42","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 43","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)","srid":3857}}}');

/*markdown
	CABLES DE FIBRA QUE PASAN DE LARGO
*/

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 44","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57, -404017.00 4929257.68)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 45","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57, -404017.00 4929257.68, -404118.58 4929237.43)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 46","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57, -403893.58 4929214.64)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 47","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 481","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_1, cw_duct_3, cw_duct_5, null","name":"FO Cable 49","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84, -403830.22 4928927.29)","srid":3857}}}');

/*markdown
	INSERCIÓN DE CABLES POR CANALIZACIONES
*/
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_15","name":"FO Cable 50","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 51","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"cw_duct_16","name":"FO Cable 52","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 53","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)","srid":3857}}}');

    SELECT insert_object('{"scheme_name":"objects","table_name":"cw_building","fields":{"n_floors":30,"n_clients":10,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403832.20 4928977.44)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_building","fields":{"n_floors":9,"n_clients":10,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-403884.22 4929191.55)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_building","fields":{"n_floors":6,"n_clients":4,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404355.78 4928504.85)","srid":3857}}}');

	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_skyway","fields":{"name":"Skyway 1","life_cycle":"In Service","owner":"Owned","measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 10","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403830.22 4928927.29, -403832.20 4928977.44)","srid":3857}}}');
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)","srid":3857}}}');		
    SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)","srid":3857}}}');		
	SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)","srid":3857}}}');		
    SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)","srid":3857}}}');		
    SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)","srid":3857}}}');		
    SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)","srid":3857}}}');		
    SELECT insert_object('{"scheme_name":"objects","table_name":"cw_ground_route","fields":{"name":"Ground Route 10","ground_route_type":"Bore","life_cycle":"In Service","owner":"Owned","width":10.0,"depth":15.0,"measured_length":150.0,"edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404355.78 4928504.85, -404338.45 4928470.91)","srid":3857}}}');
    SELECT insert_object('{"scheme_name":"objects","table_name":"fo_cable","fields":{"id_duct":"null","name":"FO Cable 5","life_cycle":"In Service","measured_length":"100.0","specification":"Distribution Plenum (144)","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"LINESTRING(-404355.78 4928504.85, -404338.45 4928470.91)","srid":3857}}}');		

	
    SELECT connect_objects('objects','fo_cable_23', 'fo_splice_1');
	SELECT connect_objects('objects','fo_cable_20', 'fo_splice_2');
	SELECT connect_objects('objects','fo_cable_21', 'fo_splice_2');
	SELECT connect_objects('objects','fo_cable_22', 'fo_splice_2');
	SELECT connect_objects('objects','fo_cable_24', 'fo_splice_2');
	SELECT connect_objects('objects','fo_cable_28', 'fo_splice_2');
	SELECT connect_objects('objects','fo_cable_33', 'fo_splice_2');

	SELECT connect_objects('objects','fo_cable_51', 'fo_splice_7');
	SELECT connect_objects('objects','fo_cable_54', 'fo_splice_7');
	SELECT connect_objects('objects','fo_cable_52', 'fo_splice_8');
	SELECT connect_objects('objects','fo_cable_53', 'fo_splice_8');
    SELECT connect_objects('objects','fo_cable_38', 'fo_splice_4');
	SELECT connect_objects('objects','fo_cable_39', 'fo_splice_5');
	SELECT connect_objects('objects','fo_cable_42', 'fo_splice_4');
	SELECT connect_objects('objects','fo_cable_43', 'fo_splice_5');
    
    SELECT splice_fiber_connection('objects','fo_cable_20', 1, 144, 'fo_cable_24', 1, 144);
    SELECT splice_fiber_connection('objects','fo_cable_21', 1, 144, 'fo_cable_28', 1, 144);
    SELECT splice_fiber_connection('objects','fo_cable_22', 1, 144, 'fo_cable_33', 1, 144);

	SELECT insert_optical_splitter('objects', 'fo_splice_2', 4, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_optical_splitter('objects', 'fo_splice_2', 16, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_optical_splitter('objects', 'fo_splice_7', 8, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

	SELECT connect_objects('objects','fo_fiber_7221', 'in_port_3');
	SELECT connect_objects('objects','fo_fiber_7640', 'out_port_21');
	SELECT connect_objects('objects','fo_fiber_7645', 'out_port_22');

	SELECT update_object('{"scheme_name":"objects","table_name":"cw_sewer_box","fields":{"id_gis":"cw_sewer_box_1","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404250.9 4928554.1)","srid":3857}}}');
-- INSERT DE ELEMENTOS DEL EDIFICIO
    -- Empalmes
    SELECT insert_fo_splice_on_building('objects', 'cw_building_2', 1, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_fo_splice_on_building('objects', 'cw_building_2', 5, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

    -- Clientes
    SELECT insert_client_on_floor('objects','cw_floor_37', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

    -- Optical Network Terminal
    SELECT insert_ont_on_client('objects', 'cw_client_355', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_ont_on_client('objects', 'cw_client_341', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_ont_on_client('objects', 'cw_client_342', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_ont_on_client('objects', 'cw_client_343', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_ont_on_client('objects', 'cw_client_311', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_ont_on_client('objects', 'cw_client_303', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

    -- Rack
    SELECT insert_rack('objects', 'cw_client_343', 'NGXC-3600  Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_352', 'Alcatel ODF Rack', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_369', 'NGXC-3600  Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_352', 'NGXC-3600  Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_352', 'NGXC-3600  Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_352', 'Wallbox', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_352', '1660 19" Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_352', 'NGXC-3600  Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_388', 'MDU Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_378', 'MDU Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_370', 'MDU Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
    SELECT insert_rack('objects', 'cw_client_397', 'MDU Bay', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

	-- Shelf on Rack
	SELECT insert_shelf_on_rack('objects', 'rack_4', 'LANscape 2U', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_shelf_on_rack('objects', 'rack_4', '7342 AFAN-R', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_shelf_on_rack('objects', 'rack_4', '7342 AFAN-R', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

	-- Card on Shelf
	SELECT insert_card_on_shelf('objects', 'shelf_1', 'VX2000-MD Line Card', 1, 15, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_card_on_shelf('objects', 'shelf_1', 'ADSL2-24', 6, 10, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_card_on_shelf('objects', 'shelf_1', 'COMBO-24', 1, 15, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

	-- Card on Rack	
	SELECT insert_card_on_rack('objects', 'rack_4', 'STM-4 S4.1N', 5, 10, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');
	SELECT insert_card_on_rack('objects', 'rack_4', 'E1LT-A', 1, 15, 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

-- CONEXIONES DE ELEMENTOS DEL EDIFICIO
    -- - Splice -> Client
    SELECT connect_objects('objects','fo_splice_9', 'cw_client_343');
	SELECT connect_objects('objects','fo_splice_9', 'cw_client_341');
	SELECT connect_objects('objects','fo_splice_9', 'cw_client_342');
	SELECT connect_objects('objects','fo_splice_9', 'cw_client_303');
	SELECT connect_objects('objects','fo_splice_9', 'cw_client_311');   

    -- Splice -> Splice
    SELECT connect_objects('objects', 'fo_splice_9', 'fo_splice_10');

	-- Fiber -> ONT
    SELECT connect_objects('objects', 'fo_fiber_8797', 'optical_network_terminal_4');
	SELECT connect_objects('objects', 'fo_fiber_8378', 'optical_network_terminal_6');
	
    -- Splice -> Rack
    SELECT connect_objects('objects','fo_splice_10', 'rack_1');
    SELECT connect_objects('objects','fo_splice_10', 'rack_2');
    SELECT connect_objects('objects','fo_splice_10', 'rack_3');
    SELECT connect_objects('objects','fo_splice_10', 'rack_4');
    SELECT connect_objects('objects','fo_splice_10', 'rack_5');
    SELECT connect_objects('objects','fo_splice_10', 'rack_6');
    SELECT connect_objects('objects','fo_splice_10', 'rack_7');
    SELECT connect_objects('objects','fo_splice_10', 'rack_8');
    SELECT connect_objects('objects','fo_splice_10', 'rack_9');

	-- Fiber -> Building Port
	SELECT connect_objects('objects', 'fo_fiber_10131', 'port_123');
	SELECT connect_objects('objects', 'fo_fiber_10132', 'port_115');
	SELECT connect_objects('objects', 'fo_fiber_10133', 'port_117');
	SELECT connect_objects('objects', 'fo_fiber_10134', 'port_135');
	SELECT connect_objects('objects', 'fo_fiber_10135', 'port_120');
	SELECT connect_objects('objects', 'fo_fiber_10136', 'port_71');
	SELECT connect_objects('objects', 'fo_fiber_10137', 'port_23');
	SELECT connect_objects('objects', 'fo_fiber_10138', 'port_60');

	-- FO Cable -> Rack
	SELECT connect_objects('objects', 'fo_cable_55', 'rack_10');
	SELECT connect_objects('objects', 'fo_cable_58', 'rack_11');
	SELECT connect_objects('objects', 'fo_cable_61', 'rack_12');

-- NEW BRANCH TESTS
	-- CALL create_branch('pruebaProyect', 'b4b7faa2-bbd3-46cc-9fac-84af083bea2e');

	-- SELECT insert_object('{"scheme_name":"alt_2","table_name":"cw_sewer_box","fields":{"name":"Pozotest1","life_cycle":"In Service","specification":"square","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404188.4 4928562.7)","srid":3857}}}');
	-- SELECT insert_object('{"scheme_name":"alt_2","table_name":"cw_sewer_box","fields":{"name":"Pozotest2","life_cycle":"In Service","specification":"square","owner":"Owned","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404266.3 4928319.8)","srid":3857}}}');
	-- SELECT update_object('{"scheme_name":"alt_2","table_name":"cw_sewer_box","fields":{"id_gis":"cw_sewer_box_11","edited_by":"b4b7faa2-bbd3-46cc-9fac-84af083bea2e","geom":{"coords":"POINT(-404335.998 4928488.451)","srid":3857}}}');
