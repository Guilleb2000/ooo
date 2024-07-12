/*markdown
INICIALIZACIONES NECESARIAS
*/

CREATE EXTENSION postgis;

CREATE EXTENSION postgis_raster;

CREATE EXTENSION fuzzystrmatch;

CREATE EXTENSION postgis_tiger_geocoder;

CREATE EXTENSION postgis_topology;

CREATE EXTENSION address_standardizer_data_us;

CREATE EXTENSION pgrouting;

CREATE SCHEMA gis;
CREATE SCHEMA template;


-- CREACIÖN DE TOPOLOGIAS --

-- SELECT topology.CreateTopology('structures', 3857, 0);
-- SELECT topology.CreateTopology('layout', 3857, 0);
-- SELECT topology.CreateTopology('cable', 3857, 0);
-- SELECT topology.CreateTopology('fiber', 3857, 0);

/*
	CRACIÓN DE ENUMERADOS
*/
	-- ENUMS COMUNES PARA TODAS LAS TABLAS --
CREATE TYPE template.owner_enum AS ENUM('Acquired', 'Unknown', 'Use Project Default', 'Owned', 'Third party');
CREATE TYPE template.life_cycle_enum AS ENUM('Planned', 'In Construction', 'In Service', 'Abandonned', 'Unknown');
CREATE TYPE template.material_type AS ENUM('Concrete', 'Steel', 'Wood', 'Unknown');

	-- ENUMERADOS ESPECIFICOS DEL SEWER BOX --
CREATE TYPE template.cw_sewer_box_type_enum AS ENUM('Conduit Terminus', 'Controlled Environment Vault', 'Handhole', 'Manhole', 'Pedestal', 'Vault');
CREATE TYPE template.cw_sewer_box_shape_enum AS ENUM('cylindric', 'square');
CREATE TYPE template.cw_sewer_box_drop_code_type_enum AS ENUM('Unknown', 'LD', 'None', 'X', 'Y', 'Z');
CREATE TYPE template.cw_sewer_box_spec_enum AS ENUM('cylindric', 'square');

	-- ENUMERADOS ESPECIFICOS DEL POLE --
CREATE TYPE template.cw_pole_usage_enum AS ENUM('CATV', 'Joint', 'Joint with Transformer', 'Power', 'Power with Transformer', 'Telco', 'Unknown');

	-- ENUMERADOS ESPECIFICOS DEL GROUND ROUTE --
CREATE TYPE template.cw_ground_route_type_enum AS ENUM('Bore', 'Plow', 'Trench', 'Unknown');

	-- ENUMERADOS ESPECIFICOS DEL FO SPLICE --
CREATE TYPE template.fo_splice_enum AS ENUM('Breaking', 'Non Breaking', 'Virtual');
CREATE TYPE template.fo_splice_method_enum AS ENUM('Fusion', 'Mechanical');
CREATE TYPE template.fo_splice_spec_enum AS ENUM('SC 8 Port - 4 Tray', 'Splice 1', 'Splice 2', 'Splice JMA', 'Splice', 'Tyco Splice Closure', 'Base Plate 1', 'Base Plate 2', 'EMMuffe-HK-48', 'EMMuffe-HK-96', 'FIST-GC02-BC16(24)-M', 
	'FIST-GC02-BC16(24)-MC-NV', 'FIST-GC02-BD16(56)-MC-NV', 'FIST-GC02-BD16(80)-M', 'FIST-GC02-BD16(80)-MC-NV', 'FIST-GCO2_F', 'GF-AP HUP 4..8WE', 'GF-AP OneBox1..3WE', 'GF-AP OneBox13-16WE', 'GF-AP OneBox41..64WE', 'GF-AP OneBox4WE', 'Large', 'NVt', 'splice_2');

	-- ENUMERADOS ESPECIFICOS DEL OPTICAL SPLITTER --
CREATE TYPE template.optical_splitter_spec_enum AS ENUM('1:4 Splitter', '1:6 Splitter', '1:12 Splitter', '1:32 Splitter', '1:64 Splitter', 'Tyco 1:4 Splitter', 'Tyco 1:8 Splitter', 'Tyco 1:16 Splitter', 'Tyco 1:32 Splitter', 'Tyco 1:64 Splitter');
CREATE TYPE template.optical_splitter_method_enum AS ENUM('Combiner', 'Splitter');

	-- ENUMERADOS ESPECIFICOS DEL FO CABLE --
CREATE TYPE template.fo_cable_spec_enum AS ENUM('12x12x12', '144F leaf NZ-DSF', '36x48', 'AFL-288', 'Armoured Single Jacket (2)', 'Armoured Single Jacket (10)', 'B-Lite UT SP1134 (1)', 'B-Lite UT SP1134 (2)', 'B-Lite UT SP1134 (4)', 'B-Lite UT SP1089 (12)', 
	'B-Lite UB SP1101 (24)', 'B-Lite MB SP1100 (72)', 'B-Lite MB SP1351 (96)', 'Dielectric Flat Drop (2)', 'Dielectric Flat Drop (6)', 'Dielectric Flat Drop (12)', 'Dielectric Single Jacket (6)', 'Dielectric Single Jacket (20)', 'Dielectric Single Jacket (50)',
	'Dielectric Single Jacket (100)', 'Distribution Plenum (2)', 'Distribution Plenum (6)', 'Distribution Plenum (12)', 'Distribution Plenum (24)', 'Distribution Plenum (60)', 'Distribution Plenum (144)', 'Nexans 4 F', 'Nexans 12 F', 'Nexans 48 F', 'Nexans 96 F',
	'Nexans GRSLDV (96)', 'S-F');

/*
	ESPECIFICACION DE POZO
*/
CREATE TABLE template.cw_sewer_box_spec(
	spec_name template.cw_sewer_box_spec_enum PRIMARY KEY UNIQUE,
	type template.cw_sewer_box_type_enum,
	shape template.cw_sewer_box_shape_enum,
	width FLOAT,
	depth FLOAT	
);

INSERT INTO template.cw_sewer_box_spec(spec_name, type, shape, width, depth)
	VALUES(
		'cylindric',
		'Handhole',
		'cylindric',
		1.0,
		0.5
	);

INSERT INTO template.cw_sewer_box_spec(spec_name, type, shape, width, depth)
	VALUES(
		'square',
		'Handhole',
		'square',
		1.0,
		0.5
	);

/*
	ESPECIFICACION DE FO SPLICE
*/

CREATE TABLE template.fo_splice_spec(
	model template.fo_splice_spec_enum PRIMARY KEY UNIQUE,
	manufacturer VARCHAR	
);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'SC 8 Port - 4 Tray',
		'AT&T'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Splice 1',
		'AT&T'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Splice 2',
		'AT&T'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Splice JMA',
		'AT&T'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Splice',
		'Tyco'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Tyco Splice Closure',
		'Tyco'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Base Plate 1',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Base Plate 2',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'EMMuffe-HK-48',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'EMMuffe-HK-96',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'FIST-GC02-BC16(24)-M',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'FIST-GC02-BC16(24)-MC-NV',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'FIST-GC02-BD16(56)-MC-NV',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'FIST-GC02-BD16(80)-M',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'FIST-GC02-BD16(80)-MC-NV',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'FIST-GCO2_F',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'GF-AP HUP 4..8WE',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'GF-AP OneBox1..3WE',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'GF-AP OneBox13-16WE',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'GF-AP OneBox41..64WE',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'GF-AP OneBox4WE',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'Large',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'NVt',
		'Tyco Electronics'
	);

INSERT INTO template.fo_splice_spec(model, manufacturer)
	VALUES(
		'splice_2',
		'Tyco Electronics'
	);
/*
	ESPECIFICACION DE OPTICAL SPLITTERS
*/

CREATE TABLE template.optical_splitter_spec(
	name template.optical_splitter_spec_enum,
	model VARCHAR,
	manufacturer VARCHAR,
	split_count INTEGER
);

INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'1:4 Splitter',
		'OCM1-SA11420S1',
		'Tyco',
		4
	);

INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'1:6 Splitter',
		'OCM2-SP22630S2',
		'Tyco',
		6
	);

INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'1:12 Splitter',
		'OCM2-SP22630S2-12',
		'Tyco',
		12
	);
	
INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'1:32 Splitter',
		'FIST-FSA-132-1PL',
		'Tyco',
		32
	);
	
INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'1:64 Splitter',
		'FIST-FSA-164-1PL',
		'Tyco',
		64
	);

INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'Tyco 1:4 Splitter',
		'FIST-FSA-104-1PL',
		'Tyco',
		4
	);

INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'Tyco 1:8 Splitter',
		'FIST-FSA-108-1PL',
		'Tyco',
		8
	);

INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'Tyco 1:16 Splitter',
		'FIST-FSA-116-1PL',
		'Tyco',
		16
	);
	
INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'Tyco 1:32 Splitter',
		'FIST-FSA-132-1PL',
		'Tyco',
		32
	);
	
INSERT INTO template.optical_splitter_spec(name, model, manufacturer, split_count)
	VALUES(
		'Tyco 1:64 Splitter',
		'FIST-FSA-164-1PL',
		'Tyco',
		64
	);

/*
	ESPECIFICACIÓN DE FO CABLE
*/

CREATE TABLE template.fo_cable_spec(
	name template.fo_cable_spec_enum,
	model VARCHAR,
	fiber_count INTEGER,
	diameter FLOAT,
	manufacturer VARCHAR
);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'12x12x12',
		'12x12x12',
		1728,
		0,
		'Unknown'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'36x48',
		'36x48',
		1728,
		0,
		'Unknown'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'144F leaf NZ-DSF',
		'144F leaf NZ-DSF',
		144,
		0.010922,
		'Corning'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'AFL-288',
		'AFL-288',
		288,
		0,
		'AFL Telecommunications'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Armoured Single Jacket (2)',
		'Armoured 2',
		2,
		0.012195,
		'AFL Telecommunications'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Armoured Single Jacket (10)',
		'Armoured 10',
		10,
		0.012192,
		'AFL Telecommunications'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'B-Lite UT SP1134 (1)',
		'B-Lite UT SP1134 (1)',
		1,
		0.0013,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'B-Lite UT SP1134 (2)',
		'B-Lite UT SP1134',
		2,
		0.0013,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'B-Lite UT SP1134 (4)',
		'B-Lite UT SP1134',
		4,
		0.0013,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'B-Lite UT SP1089 (12)',
		'B-Lite UT SP1089',
		12,
		0.0016,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'B-Lite UB SP1101 (24)',
		'B-Lite UB SP1101',
		24,
		0.00381,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'B-Lite MB SP1100 (72)',
		'B-Lite MB SP1100',
		72,
		0.005334,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'B-Lite MB SP1351 (96)',
		'B-Lite MB SP1351',
		96,
		0.00635,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Dielectric Flat Drop (2)',
		'Dielec Flat Drop 2',
		2,
		0.00193,
		'Corning'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Dielectric Flat Drop (6)',
		'Dielec Flat Drop 6',
		6,
		0.00193,
		'Corning'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Dielectric Flat Drop (12)',
		'Dielec Flat Drop 12',
		12,
		0.002997,
		'Corning'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Dielectric Single Jacket (6)',
		'Dielectric 6',
		6,
		0.010668,
		'AFL Telecommunications'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Dielectric Single Jacket (20)',
		'Dielectric 20',
		20,
		0.010668,
		'AFL Telecommunications'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Dielectric Single Jacket (50)',
		'Dielectric 50',
		50,
		0.010668,
		'AFL Telecommunications'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Dielectric Single Jacket (100)',
		'Dielectric 100',
		100,
		0.014224,
		'AFL Telecommunications'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Distribution Plenum (2)',
		'Distribution Plenum',
		2,
		0.00208,
		'Sumitomo'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Distribution Plenum (6)',
		'Distribution Plenum',
		6,
		0.006096,
		'Sumitomo'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Distribution Plenum (12)',
		'Distribution Plenum',
		12,
		0.007112,
		'Sumitomo'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Distribution Plenum (24)',
		'Distribution Plenum',
		24,
		0.014224,
		'Sumitomo'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Distribution Plenum (60)',
		'Distribution Plenum',
		60,
		0.018796,
		'Sumitomo'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Distribution Plenum (144)',
		'Distribution Plenum',
		144,
		0.028908,
		'Sumitomo'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Nexans 4 F',
		'Nexans 4 F',
		4,
		0.001,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Nexans 12 F',
		'Nexans 12 F',
		12,
		0.0012,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Nexans 48 F',
		'Nexans 48 F',
		48,
		0.0054,
		'Nexans'
	);


INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Nexans 96 F',
		'Nexans 96 F',
		96,
		0.0064,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'Nexans GRSLDV (96)',
		'GRSLDV',
		96,
		0.00635,
		'Nexans'
	);

INSERT INTO template.fo_cable_spec(name, model, fiber_count, diameter, manufacturer)
	VALUES(
		'S-F',
		'S-F',
		12,
		0,
		'Unknown'
	);
/*
	ESPECIFICACION DE CARDS
*/

CREATE TABLE template.card_specs(
	model VARCHAR PRIMARY KEY UNIQUE,
	height FLOAT,
	Width FLOAT,
	depth FLOAT,
	manufacturer VARCHAR
);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'VX2000-MD Line Card',
		0.2302,
		0.0254,
		0.3,
		'Versa Technology'
	);

INSERT INTO template.card_specs(model,height, width, depth, manufacturer)
	VALUES(
		'VX2000-MD MCU Card',
		0.2302,
		0.0254,
		0.3,
		'Versa Technology'
	);

INSERT INTO template.card_specs(model,height, width, depth, manufacturer)
	VALUES(
		'RAP-0C48 LR',
		0.23622,
		0.01778,
		0.2286,
		'Calix'
	);

INSERT INTO template.card_specs(model,height, width, depth, manufacturer)
	VALUES(
		'ADSL2-24',
		0.23622,
		0.01778,
		0.2286,
		'Calix'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'DS3/EC1-12s',
		0.23622,
		0.01778,
		0.2286,
		'Calix'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'OC3-4 IR',
		0.23622,
		0.01778,
		0.2286,
		'Calix'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'T1-6',
		0.23622,
		0.01778,
		0.2286,
		'Calix'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'COMBO-24',
		0.23622,
		0.03556,
		0.2286,
		'Calix'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'STM-64 L6434',
		0.265,
		0.021,
		0.2286,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'STM-4 S4.1N',
		0.265,
		0.021,
		0.213,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'House Keeping',
		0.265,
		0.021,
		0.213,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'House Keeping 2',
		0.265,
		0.042,
		0.213,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'STM-16 S16.1ND',
		0.265,
		0.021,
		0.213,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'2 Mbit/s-75ohm-A21E1',
		0.265,
		0.021,
		0.213,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'34 Mbit/s-75ohm-A3E3',
		0.265,
		0.021,
		0.213,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ADLT-J',
		0.265,
		0.021,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Alcatel ODF Tray',
		0.037,
		0.55,
		0.290,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'E1LC-A(75 Ohm)',
		0.240,
		0.029,
		0.248,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'SANT-E',
		0.240,
		0.03,
		0.248,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7342 AFAN-R CARD',
		0.08,
		0.48,
		0.3,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'DSNC-A',
		0.028,
		0.580,
		0.295,
		'Alcatel'
	);	


INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'E3NC-C',
		0.200,
		0.03,
		0.248,
		'Alcatel'
	);	

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ESS-7-M1-Crd',
		0.038,
		0.200,
		0.500,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'E1LT-A',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'SC-G-FLSH1/5-12-A-1',
		0.036,
		0.55,
		0.29,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'E3NC-A (BNC)',
		0.064,
		0.33,
		0.129,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'E1NT-A',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'PPSC-F',
		0.2,
		0.03,
		0.248,
		'Alcatel'
	);


INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'SANT-D (Tropical)',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7342 P-OLT AACU-C',
		0.53,
		0.02,
		0.28,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ADLT-E(lp)',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'SANT-E (tropical lh)',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'VPSC',
		0.028,
		0.58,
		0.295,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'E1NC-A (75 Ohm)',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7342 P-OLT EHNT-A',
		0.53,
		0.02,
		0.28,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ESS-7-M20 Crd',
		0.038,
		0.2,
		0.5,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ASPC-C',
		0.2,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'EBLT',
		0.028,
		0.48,
		0.295,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'PWRIO-A',
		0.2,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'E3NT-A',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'AACU',
		0.028,
		0.48,
		0.295,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'AACU-B/2',
		0.24,
		0.02,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7342 P-OLT GLT2-B',
		0.530,
		0.02,
		0.28,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'AACU-B/1',
		0.24,
		0.02,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ADSE-A',
		0.24,
		0.02,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ESS-7 (PSU CRD)',
		0.16,
		0.21,
		0.25,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'SANT-D',
		0.24,
		0.03,
		0.248,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'VPSC 2',
		0.028,
		0.48,
		0.295,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'VPSC 3',
		0.028,
		0.35,
		0.295,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ECNT-A',
		0.028,
		0.48,
		0.295,
		'Alcatel'
	);

INSERT INTO template.card_specs(model, height, width, depth, manufacturer)
	VALUES(
		'GENC-E',
		0.028,
		0.48,
		0.295,
		'Alcatel'
	);

/*
	ESPECIFICACION DE shelfs
*/

CREATE TABLE template.shelf_specs(
	model VARCHAR PRIMARY KEY UNIQUE,
	height FLOAT,
	Width FLOAT,
	depth FLOAT,
	manufacturer VARCHAR
);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'C7 Shelf',
		0.3556,
		0.4826,
		0.304,
		'Calix'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'1660 Main Subrack',
		0.65,
		0.482,
		0.3,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'1660 Drop Subrack',
		0.35,
		0.482,
		0.3,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ASAM Subrack',
		0.488,
		0.56,
		0.264,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Alcatel 1664SM',
		0.16,
		0.3,
		0.2,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'AFAN-A (With Filter)',
		0.05,
		0.53,
		0.264,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7330-ISAM-RDSLAM',
		0.225,
		0.58,
		0.3,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Wallbox sub-frame',
		0.38,
		0.38,
		0.15,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Alcatel 1664SM (L)',
		0.65,
		0.59,
		0.3,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Alcatel ODF Shelf',
		0.3,
		0.55,
		0.3,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7342 P-OLT',
		0.535,
		0.48,
		0.3,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'SD MASTER',
		0.15,
		0.53,
		0.264,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'AFAN-A',
		0.05,
		0.53,
		0.264,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'ODF 26 cassette',
		0.963,
		0.6,
		0.29,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'SD SLAVE',
		0.488,
		0.53,
		0.265,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7342 AFAN-R',
		0.08,
		0.48,
		0.3,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7330 FTTN ARAM-D',
		0.3556,
		0.5842,
		0.3048,
		'Alcatel'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'MDU Shelf',
		0.5,
		0.6,
		0.4,
		'Tyco Electronics'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'MDU Splice Shelf 56',
		0.5,
		0.6,
		0.4,
		'Tyco Electronics'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'MDU Splice Shelf 80',
		0.5,
		0.6,
		0.4,
		'Tyco Electronics'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'MDU Splice Shelf 24',
		0.5,
		0.6,
		0.4,
		'Tyco Electronics'
	);

INSERT INTO template.shelf_specs(model, height, width, depth, manufacturer)
	VALUES(
		'LANscape 2U',
		0.89,
		0.447,
		0.414,
		'Corning'
	);

/*
	ESPECIFICACION DE racks
*/

CREATE TABLE template.rack_specs(
	model VARCHAR PRIMARY KEY UNIQUE,
	height FLOAT,
	Width FLOAT,
	depth FLOAT,
	manufacturer VARCHAR
);

INSERT INTO template.rack_specs(model, height, width, depth, manufacturer)
	VALUES(
		'NGXC-3600  Bay',
		1.3208,
		0.533,
		0.431,
		'Tyco Electronics'
	);

INSERT INTO template.rack_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Alcatel generic bay',
		2.5,
		0.6,
		0.3,
		'Alcatel'
	);

INSERT INTO template.rack_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Alcatel ODF Rack',
		2.2,
		0.6,
		0.3,
		'Alcatel'
	);

INSERT INTO template.rack_specs(model, height, width, depth, manufacturer)
	VALUES(
		'7330 Alcatel bay',
		0.750,
		0.6,
		0.3,
		'Alcatel'
	);

INSERT INTO template.rack_specs(model, height, width, depth, manufacturer)
	VALUES(
		'Wallbox',
		0.4,
		0.401,
		0.15,
		'Alcatel'
	);

INSERT INTO template.rack_specs(model, height, width, depth, manufacturer)
	VALUES(
		'1660 19" Bay',
		2.2,
		0.4826,
		0.3,
		'Alcatel'
	);

INSERT INTO template.rack_specs(model, height, width, depth, manufacturer)
	VALUES(
		'MDU Bay',
		1,
		0.6,
		0.4,
		'Tyco Electronics'
	);

/*markdown
	CREACIÖN DE OBJETO POZOS(SEWER BOX)
*/

CREATE TABLE gis.cw_sewer_box(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	name VARCHAR,
	life_cycle template.life_cycle_enum,
	specification template.cw_sewer_box_spec_enum,
	owner template.owner_enum,
	geom geometry(POINT,3857),
	layout_geom geometry(POLYGON,3857),
	CONSTRAINT specification 
		FOREIGN KEY(specification) 
			REFERENCES template.cw_sewer_box_spec(spec_name) 
);

CREATE UNIQUE INDEX idx_cw_sewer_box_id_gis ON gis.cw_sewer_box (id_gis);
CREATE INDEX idx_geom_sewer_box ON gis.cw_sewer_box USING GIST(geom);
CREATE INDEX idx_layout_geom_sewer_box ON gis.cw_sewer_box USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION sewer_box_insert() RETURNS trigger AS
	$$
	DECLARE  
		new_geom GEOMETRY;
		new_geom_cbox GEOMETRY;
		new_diagonal GEOMETRY;
		touching_ground_route RECORD;
		clossest_point_route GEOMETRY;
		exact_point_on_line GEOMETRY;
		is_point_on_line BOOLEAN;
		divided_geom GEOMETRY;
		new_moved_geom GEOMETRY;
		width FLOAT;
		width_cbox FLOAT;
		row RECORD;
		current_table RECORD;
		current_field RECORD;
		schema_name TEXT := 'gis';
		current_new_geom GEOMETRY;
		current_id_gis VARCHAR;
	BEGIN
		width=3.75;
		width_cbox=2;
		
		new_moved_geom := New.geom;

		IF (SELECT count(*) FROM gis.cw_ground_route WHERE ST_Distance(New.geom, ST_EndPoint(geom)) < 4) > 0
		THEN
			new_moved_geom := (SELECT ST_EndPoint(geom) FROM gis.cw_ground_route WHERE ST_Distance(New.geom, ST_EndPoint(geom)) < 4 LIMIT 1); 
		END IF;
					
		IF (SELECT count(*) FROM gis.cw_ground_route WHERE ST_Distance(New.geom, ST_StartPoint(geom)) < 4) > 0
		THEN
			new_moved_geom := (SELECT ST_StartPoint(geom) FROM gis.cw_ground_route WHERE ST_Distance(New.geom, ST_StartPoint(geom)) < 4 LIMIT 1); 
		END IF;
		
		IF (SELECT count(*) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_EndPoint(geom))< 4) > 0
		THEN
			new_moved_geom := (SELECT ST_EndPoint(geom) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_EndPoint(geom)) < 4 LIMIT 1); 
		END IF;
					
		IF (SELECT count(*) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_StartPoint(geom)) < 4) > 0
		THEN
			new_moved_geom := (SELECT ST_StartPoint(geom) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_StartPoint(geom)) < 4 LIMIT 1); 
		END IF;

		-- Se crea la topología de la cara exterior que cortará los ductos --
		IF (SELECT shape FROM template.cw_sewer_box_spec WHERE spec_name = NEW.specification) = 'square'
		THEN
			new_geom=ST_Buffer(new_moved_geom, width, 'endcap=square');
		ELSE
			new_geom=ST_Buffer(new_moved_geom, width, 'quad_segs=8');
		END IF;
		
		-- Se crea la topología de la cara interior que cortará los cables, no será una topología del pozo, si no de un objeto que
		--	se llama  cw_connectivity_box 
		new_geom_cbox=ST_Buffer(new_moved_geom, width_cbox, 'endcap=square');

		-- Genera la diagonal en la que se iran introduciendo los empalmes
		new_diagonal=ST_MakeLine(
			(SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2]=4),
			(SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2]=2)
		);

		-- Actualiza el pozo
		UPDATE gis.cw_sewer_box 
			SET id_gis=CONCAT('cw_sewer_box_', NEW.id::text), 
				geom = new_moved_geom,
				layout_geom=new_geom
		WHERE id=NEW.id;

		-- Inserta en la tabla conenctibity box con los datos anteriores
		INSERT INTO gis.cw_connectivity_box(geom, layout_geom, diagonal_geom) 
			VALUES(
					new_moved_geom,
					new_geom_cbox,
					new_diagonal);		
		
		-- Se updatea la geometría layout de las canalizaciones
		UPDATE gis.cw_ground_route SET 
			layout_geom = ST_Difference(layout_geom, new_geom)
		WHERE ST_Intersects(layout_geom, new_geom);

		UPDATE gis.cw_skyway SET 
			layout_geom = ST_Difference(layout_geom, new_geom)
		WHERE ST_Intersects(layout_geom, new_geom);

		UPDATE gis.cw_duct SET 
			layout_geom = ST_Difference(layout_geom, new_geom)
		WHERE ST_Intersects(layout_geom, new_geom);

		UPDATE gis.fo_cable SET 
			layout_geom = ST_Difference(layout_geom, new_geom_cbox)
		WHERE ST_Intersects(layout_geom, new_geom);
7
		UPDATE gis.fo_fiber SET 
			layout_geom = ST_Difference(layout_geom, new_geom_cbox)
		WHERE ST_Intersects(layout_geom, new_geom);

		-- Se updatea la geometría layout de los Skyway

		-- -- En el caso en el que al introducir un pozo la distancia con la geomtria del ground rout esta a una cierta distacia
		-- IF (SELECT count(*) FROM gis.cw_ground_route WHERE ST_Distance(geom, NEW.geom) < 5) = 1
		-- THEN
		-- 	-- Se reccorren todas las tablas del schema gis			                  
		-- 	FOR current_table IN 
		-- 		SELECT table_name
		-- 		FROM information_schema.tables
		-- 		WHERE table_schema = schema_name
		-- 	LOOP
		-- 		-- Se reccorren todos los campos geometricos de las tablas, excluyendo als que no tengan sentido
		-- 		FOR current_field IN
		-- 			SELECT column_name
		-- 			FROM information_schema.columns
		-- 			WHERE table_name = current_table.table_name
		-- 			AND data_type = 'USER-DEFINED'
		-- 			AND udt_name = 'geometry'
		-- 			AND (table_name='fo_cable'
		-- 				OR table_name='cw_ground_route'
		-- 				OR table_name='cw_duct')
		-- 		LOOP
		-- 			IF current_field.column_name <> 'geom' THEN CONTINUE; END IF;
		-- 			-- Se extraen los valores de esos campos y se tratan
		-- 			 FOR row IN 
        --         		EXECUTE format('SELECT ctid, id_gis FROM %I.%I WHERE %I IS NOT NULL AND ST_Distance(%I, %L) < 5', 
        --                        schema_name, 
        --                        current_table.table_name, 
        --                        current_field.column_name,
        --                        current_field.column_name,
        --                        NEW.geom)
		-- 			LOOP
		-- 				-- Ejecuta una consulta dinámica para obtener el valor de la columna actual
		-- 				EXECUTE format('SELECT %I, id_gis FROM %I.%I WHERE ctid = %L AND %I IS NOT NULL', 
		-- 							current_field.column_name, 
		-- 							schema_name, 
		-- 							current_table.table_name, 
		-- 							row.ctid,
		-- 							current_field.column_name)
		-- 				INTO current_new_geom, current_id_gis;

		-- 				IF (SELECT count(*) FROM ST_DumpPoints(current_new_geom)) > 2
		-- 				THEN
		-- 					RAISE NOTICE 'TODO';
		-- 				ELSE
		-- 					EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
		-- 						' = ' || quote_literal(ST_AsText(ST_MakeLine(ST_StartPoint(current_new_geom), NEW.geom))) ||
		-- 						' WHERE id_gis = ($1);' USING current_id_gis;
		-- 					EXECUTE 'INSERT INTO ' || schema_name || '.' || current_table.table_name || '(geom) VALUES(' || 
		-- 						quote_literal(ST_AsText(ST_MakeLine(NEW.geom, ST_EndPoint(current_new_geom)))) || ')';
		-- 				END IF;
		-- 			END LOOP;
		-- 		END LOOP;
		-- 	END LOOP;
		-- END IF;
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER sewer_box_triggger
	AFTER INSERT ON gis.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE sewer_box_insert();
	
CREATE OR REPLACE FUNCTION sewer_box_update_trigger() RETURNS trigger AS
$$
	DECLARE 
		new_geom GEOMETRY;
		new_geom_cbox GEOMETRY;
		new_diagonal GEOMETRY;
		width FLOAT;
		width_cbox FLOAT;
		old_sewer_box RECORD;
		translation_x FLOAT;
		translation_y FLOAT;
		current_table RECORD;
		current_field RECORD;
		cb_record RECORD;
		query TEXT;
		schema_name TEXT := 'gis'; -- Nombre del esquema que deseas buscar
		old_geom GEOMETRY;
		current_new_line GEOMETRY;
		current_new_geom GEOMETRY;
		current_id_gis VARCHAR;
		n_current_new_geom_points INTEGER;
		id_gis_line VARCHAR;
		aux_point GEOMETRY;
		column_value GEOMETRY;
		row RECORD;
		current_aux_record RECORD;
	BEGIN
		IF NOT ST_Equals(OLD.geom, NEW.geom)
		THEN
			translation_x = ST_X(NEW.geom) - ST_X(OLD.geom);
			translation_y = ST_Y(NEW.geom) - ST_Y(OLD.geom);
			old_geom := OLD.layout_geom;
			
			SELECT * INTO cb_record FROM gis.cw_connectivity_box WHERE ST_Intersects(geom, OLD.geom);
			
			-- Guarda las conexiones de la coonnectivity_box en tamblas temporales
			PERFORM store_cb_conections(cb_record);
			
			UPDATE gis.fo_cable SET layout_geom = null WHERE ST_Intersects(geom, OLD.geom);

			-- Se reccorren todas las tablas del schema gis			                  
			FOR current_table IN 
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = schema_name
			LOOP
				-- Se reccorren todos los campos geometricos de las tablas, excluyendo als que no tengan sentido
				FOR current_field IN
					SELECT column_name
					FROM information_schema.columns
					WHERE table_name = current_table.table_name
					AND data_type = 'USER-DEFINED'
					AND udt_name = 'geometry'
					AND NOT table_name='fo_fiber'
					AND NOT table_name='fo_fiber_vertices_pgr'
				LOOP
					-- Se extraen los valores de esos campos y se tratan
					 FOR row IN 
                		EXECUTE format('SELECT ctid, id_gis FROM %I.%I WHERE %I IS NOT NULL AND ST_Intersects(%I, %L)', 
								schema_name, 
								current_table.table_name, 
								current_field.column_name,
								current_field.column_name,
								old_geom)
					LOOP
						-- Ejecuta una consulta dinámica para obtener el valor de la columna actual
						EXECUTE format('SELECT %I, id_gis FROM %I.%I WHERE ctid = %L AND %I IS NOT NULL', 
									current_field.column_name, 
									schema_name, 
									current_table.table_name, 
									row.ctid,
									current_field.column_name)
						INTO current_new_geom, current_id_gis;

						IF current_new_geom IS NULL THEN CONTINUE; END IF;

						IF (NOT current_field.column_name = 'layout_3d_geom'
							AND (current_table.table_name = 'cw_ground_route' OR 
								current_table.table_name = 'cw_skyway' OR 
								current_table.table_name = 'cw_duct' OR
								(current_table.table_name = 'fo_cable' AND current_field.column_name = 'geom'))
							)
						THEN
							-- En el caso de que sea una liena y se cumpla la condición anterior se actualiza la geometría
							IF ST_GeometryType(current_new_geom) = 'ST_LineString' 
							THEN							
								EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
									' = ' || quote_literal(ST_AsText(update_linestrings(current_new_geom, OLD.geom, NEW.geom))) ||
									' WHERE id_gis = ($1);' USING current_id_gis;
							END IF;
						ELSIF NOT current_table.table_name = 'fo_cable' AND NOT current_field.column_name = 'layout_3d_geom'
						THEN
							-- En este caso unicamente se hace una translación de las geometrías
							EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
								' = ST_Translate(' || current_field.column_name || ', ' || translation_x || ', ' || translation_y || ')' ||
								' WHERE id_gis = ($1);' USING current_id_gis;
						END IF;								
					END LOOP;
				END LOOP;
			END LOOP;
			
			-- Se regeneran los cables
			IF (SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cable_connectivity'))
			THEN
				FOR current_aux_record IN SELECT * FROM cable_connectivity
				LOOP
					PERFORM connect_cable(current_aux_record.id_gis_cable, current_aux_record.id_gis_splice);
				END LOOP;

				-- Se regeneran las conexiones
				PERFORM update_stored_conections();
			END IF;

			-- Se borran las tablas temporales
			DROP TABLE IF EXISTS cable_connectivity;
			DROP TABLE IF EXISTS fiber_connectivity;
			DROP TABLE IF EXISTS fiber_port_connectivity;
		END IF;       

    	RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER sewer_box_update_triggger
	AFTER UPDATE ON gis.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE sewer_box_update_trigger();

CREATE OR REPLACE FUNCTION sewer_box_delete_trigger() RETURNS trigger AS
$$
	DECLARE 
	BEGIN
		DELETE FROM gis.cw_connectivity_box WHERE ST_Intersects(geom, OLD.layout_geom);
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER sewer_box_delete_trigger
	AFTER DELETE ON gis.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE sewer_box_delete_trigger();


/*markdown
CREACIÖN DE OBJETO POSTE(CW POLE)
*/

CREATE TABLE gis.cw_pole(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	name VARCHAR,
	usage template.cw_pole_usage_enum,
    material_type template.material_type,
	life_cycle template.life_cycle_enum,
	owner template.owner_enum,
	geom geometry(POINT,3857),
    geom3D geometry(POLYGON,3857),
	layout_geom geometry(POLYGON,3857),
	support geometry(LINESTRING, 3857)  
);

CREATE UNIQUE INDEX idx_cw_pole_id_gis ON gis.cw_pole (id_gis);
CREATE INDEX idx_geom_pole ON gis.cw_pole USING GIST(geom);
CREATE INDEX idx_layout_geom_pole ON gis.cw_pole USING GIST(layout_geom);

CREATE OR REPLACE FUNCTION cw_pole_insert() RETURNS trigger AS
	$$
	DECLARE 
		new_geom GEOMETRY;
        new_geom_3D GEOMETRY;
		new_geom_cbox GEOMETRY;
		new_diagonal GEOMETRY;
		perpendicular_diagonal_line GEOMETRY;
		new_moved_geom GEOMETRY;
		width FLOAT;
		width_cbox FLOAT;
		width_pole_3D FLOAT;
	BEGIN
		width = 3.75;
        width_pole_3D = 0.125;
		width_cbox = 2;

		new_moved_geom := New.geom;

		IF (SELECT count(*) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_EndPoint(geom))< 4) > 0
		THEN
			new_moved_geom := (SELECT ST_EndPoint(geom) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_EndPoint(geom)) < 4 LIMIT 1); 
		END IF;
					
		IF (SELECT count(*) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_StartPoint(geom)) < 4) > 0
		THEN
			new_moved_geom := (SELECT ST_StartPoint(geom) FROM gis.cw_skyway WHERE ST_Distance(New.geom, ST_StartPoint(geom)) < 4 LIMIT 1); 
		END IF;

		-- Se crea la topología de la cara exterior que cortará los ductos --
		new_geom = ST_Buffer(new_moved_geom, width, 'quad_segs=8');
		
		-- Se crea la topología de la cara interior que cortará los cables, no será una topología del pozo, si no de un objeto que
		--se llama  cw_connectivity_box 
		new_geom_cbox = ST_Buffer(new_moved_geom, width_cbox, 'endcap=square');

        -- Se genera la topología 3D como ayuda al visor 3D	
        new_geom_3D = ST_Buffer(
			new_moved_geom,
			width_pole_3D, 
			'quad_segs=8');

		-- Genera la diagonal en la que se iran introduciendo los empalmes
		new_diagonal=ST_MakeLine(
			(SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2]=4),
			(SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2]=2)
		);
		
		perpendicular_diagonal_line := ST_Rotate(new_diagonal, -PI()/2, ST_centroid(new_diagonal));
		-- Actualiza el pozo
		UPDATE gis.cw_pole
			SET id_gis=CONCAT('cw_pole_', NEW.id::text), 
				geom = new_moved_geom,
				geom3D = new_geom_3D,
				layout_geom = new_geom,
				support = ST_MakeLine(
					ST_MakeLine(
						ST_LineExtend(new_diagonal, 0.875, 0.875), 
						ST_Centroid(new_diagonal)),
					ST_LineExtend(perpendicular_diagonal_line, 0.875, 0.875)
				)
		WHERE id=NEW.id;

		-- Inserta en la tabla conenctibity box con los datos anteriores
		INSERT INTO gis.cw_connectivity_box(geom, layout_geom, diagonal_geom) 
			VALUES(
					new_moved_geom,
					new_geom_cbox,
					new_diagonal);		
		RETURN NEW;

		UPDATE gis.cw_skyway SET 
			layout_geom = ST_Difference(layout_geom, new_geom)
		WHERE ST_Intersects(layout_geom, new_geom);

		UPDATE gis.fo_cable SET 
			layout_geom = ST_Difference(layout_geom, new_geom_cbox)
		WHERE ST_Intersects(layout_geom, new_geom);

		UPDATE gis.fo_fiber SET 
			layout_geom = ST_Difference(layout_geom, new_geom_cbox)
		WHERE ST_Intersects(layout_geom, new_geom);
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_pole_insert_trigger
	AFTER INSERT ON gis.cw_pole
	FOR EACH ROW EXECUTE PROCEDURE cw_pole_insert();

-- Metodo para actualizar la posiciónd 3d del psote en función del numero de empalmes que haya dentro
CREATE OR REPLACE FUNCTION update_pole_3d_geometry(id_gis_cb VARCHAR) RETURNS void AS
	$$
	DECLARE 
		pole_rec RECORD;
		cb_rec RECORD;
		perpendicular_diagonal_line GEOMETRY;
	BEGIN
		-- Se carga el record de la conectivity box en una varibale
		SELECT * INTO cb_rec FROm gis.cw_connectivity_box WHERE id_gis = id_gis_cb;

		-- Se carga el record de poste en una varibale
		SELECT * INTO pole_rec FROm gis.cw_pole WHERE ST_Intersects(cb_rec.geom, geom);

		perpendicular_diagonal_line := ST_Rotate(cb_rec.diagonal_geom, -PI()/2, ST_centroid(cb_rec.diagonal_geom));

		UPDATE gis.cw_pole
			SET	support = ST_MakeLine(
				ST_MakeLine(
					ST_LineExtend(cb_rec.diagonal_geom, 0.875, 0.875), 
					ST_Centroid(cb_rec.diagonal_geom)),
				ST_LineExtend(perpendicular_diagonal_line, 0.875, 0.875)
			)
		WHERE id=pole_rec.id;
	END;
	$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cw_pole_update_trigger() RETURNS trigger AS
	$$
	DECLARE 
		new_geom GEOMETRY;
		new_geom_cbox GEOMETRY;
		new_diagonal GEOMETRY;
		width FLOAT;
		width_cbox FLOAT;
		old_sewer_box RECORD;
		translation_x FLOAT;
		translation_y FLOAT;
		current_table RECORD;
		current_field RECORD;
		cb_record RECORD;
		query TEXT;
		schema_name TEXT := 'gis'; -- Nombre del esquema que deseas buscar
		old_geom GEOMETRY;
		current_new_line GEOMETRY;
		current_new_geom GEOMETRY;
		current_id_gis VARCHAR;
		n_current_new_geom_points INTEGER;
		id_gis_line VARCHAR;
		aux_point GEOMETRY;
		column_value GEOMETRY;
		row RECORD;
		current_aux_record RECORD;
	BEGIN
		IF NOT ST_Equals(OLD.geom, NEW.geom)
		THEN
			translation_x = ST_X(NEW.geom) - ST_X(OLD.geom);
			translation_y = ST_Y(NEW.geom) - ST_Y(OLD.geom);
			old_geom := OLD.layout_geom;
			
			SELECT * INTO cb_record FROM gis.cw_connectivity_box WHERE ST_Intersects(geom, OLD.geom);
			
			-- Guarda las conexiones de la coonnectivity_box en tamblas temporales
			PERFORM store_cb_conections(cb_record);
			
			UPDATE gis.fo_cable SET layout_geom = null WHERE ST_Intersects(geom, OLD.geom);
			
			-- Se reccorren todas las tablas del schema gis
			FOR current_table IN 
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = schema_name
			LOOP
				-- Se reccorren todos los campos geometricos de las tablas, excluyendo als que no tengan sentido
				FOR current_field IN
					SELECT column_name
					FROM information_schema.columns
					WHERE table_name = current_table.table_name
					AND data_type = 'USER-DEFINED'
					AND udt_name = 'geometry'
					AND table_name NOT IN ('fo_fiber', 'cw_ground_route', 'cw_duct', 'fo_fiber_vertices_pgr')
				LOOP
					-- Se extraen los valores de esos campos y se tratan
					 FOR row IN 
                		EXECUTE format('SELECT ctid, id_gis FROM %I.%I WHERE %I IS NOT NULL AND ST_Intersects(%I, %L)', 
                               schema_name, 
                               current_table.table_name, 
                               current_field.column_name,
                               current_field.column_name,
                               old_geom)
					LOOP
						-- Ejecuta una consulta dinámica para obtener el valor de la columna actual
						EXECUTE format('SELECT %I, id_gis FROM %I.%I WHERE ctid = %L AND %I IS NOT NULL', 
                               current_field.column_name, 
                               schema_name, 
                               current_table.table_name, 
                               row.ctid::text,
                               current_field.column_name)
                		INTO current_new_geom, current_id_gis;
						
						IF current_new_geom IS NULL THEN CONTINUE; END IF;

						IF (NOT current_field.column_name = 'layout_3d_geom'
							AND (current_table.table_name = 'cw_skyway' OR 
								(current_table.table_name = 'fo_cable' AND current_field.column_name = 'geom'))
								
							)
						THEN
							-- En el caso de que sea una liena y se cumpla la condición anterior se actualiza la geometría
							IF ST_GeometryType(current_new_geom) = 'ST_LineString' 
							THEN					
								EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
									' = ' || quote_literal(ST_AsText(update_linestrings(current_new_geom, OLD.geom, NEW.geom))) ||
									' WHERE id_gis = ($1);' USING current_id_gis;
							END IF;
						ELSIF NOT current_table.table_name = 'fo_cable' 
							AND NOT current_field.column_name = 'layout_3d_geom'
						THEN
							-- En este caso unicamente se hace una translación de las geometrías
							EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
								' = ST_Translate(' || current_field.column_name || ', ' || translation_x || ', ' || translation_y || ')' ||
								' WHERE id_gis = ($1);' USING current_id_gis;
						END IF;								
					END LOOP;
				END LOOP;
			END LOOP;

			-- Se regeneran los cables
			FOR current_aux_record IN SELECT * FROM cable_connectivity
			LOOP
				PERFORM connect_cable(current_aux_record.id_gis_cable, current_aux_record.id_gis_splice);
			END LOOP;

			-- Se regeneran las conexiones
			PERFORM update_stored_conections();

			-- Se borran las tablas temporales
			DROP TABLE IF EXISTS cable_connectivity;
			DROP TABLE IF EXISTS fiber_connectivity;
			DROP TABLE IF EXISTS fiber_port_connectivity;
		END IF;       

    	RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;


CREATE TRIGGER cw_pole_update_trigger
	AFTER UPDATE ON gis.cw_pole
	FOR EACH ROW EXECUTE PROCEDURE cw_pole_update_trigger();


CREATE OR REPLACE FUNCTION cw_pole_delete_trigger() RETURNS trigger AS
$$
	DECLARE 
	BEGIN
		DELETE FROM gis.cw_connectivity_box WHERE ST_Intersects(geom, OLD.layout_geom);
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_pole_delete_trigger
	AFTER DELETE ON gis.cw_pole
	FOR EACH ROW EXECUTE PROCEDURE cw_pole_delete_trigger();


/*markdown
CREACIÖN DE OBJETO CAJAS DE CONECTIVIDAD(CONNECTIVITY BOX)
*/

CREATE TABLE gis.cw_connectivity_box(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR, 
	geom geometry(POINT,3857),
	layout_geom geometry(POLYGON,3857),
	diagonal_geom geometry(LINESTRING,3857)
);

CREATE UNIQUE INDEX idx_cw_connecitivity_box_id_gis ON gis.cw_connectivity_box (id_gis);
CREATE INDEX idx_geom_connectivity_box ON gis.cw_connectivity_box USING GIST(geom);
CREATE INDEX idx_layout_geom_connectivity_box ON gis.cw_connectivity_box USING GIST(layout_geom);

-- El trigger simplemente genera el id_gis cuando se inserta
CREATE OR REPLACE FUNCTION connectivity_box_insert() RETURNS trigger AS
$$
	BEGIN
		UPDATE gis.cw_connectivity_box 
			SET id_gis=CONCAT('cw_connectivity_box_', NEW.id::text)
		WHERE id=NEW.id;
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER connectivity_box_triggger
	AFTER INSERT ON gis.cw_connectivity_box
	FOR EACH ROW EXECUTE PROCEDURE connectivity_box_insert();

/*markdown
CREACION DEL OBJETO RUTA CANALIZADA(GROUND ROUTE)
*/

CREATE TABLE gis.cw_ground_route(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	name VARCHAR,
	ground_route_type template.cw_ground_route_type_enum,
    life_cycle template.life_cycle_enum,
	owner template.owner_enum,
	width FLOAT,
	depth FLOAT,
	calculated_length FLOAT,
	measured_length FLOAT,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(POLYGON,3857),
	layout_3d_geom geometry(LINESTRING,3857)
);

CREATE UNIQUE INDEX idx_cw_ground_route_id_gis ON gis.cw_ground_route (id_gis);
CREATE INDEX idx_geom_ground_route ON gis.cw_ground_route USING GIST(geom);
CREATE INDEX idx_layout_geom_ground_route ON gis.cw_ground_route USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION ground_route_insert() RETURNS trigger AS
	$$
	DECLARE 
		real_geom GEOMETRY;
		aux_gr_geom GEOMETRY;
		aux_gr3d_geom GEOMETRY;
		aux_geom GEOMETRY;
		cb_rotated_geom GEOMETRY;
		current_node RECORD;
		id_gis_sewer VARCHAR;
		id_cb VARCHAR;
		building_Record RECORD;
		building_on_start_point BOOLEAN;
		radians_to_rotate DOUBLE PRECISION;
		building_face_1 GEOMETRY;
		building_face_2 GEOMETRY;
		building_face_3 GEOMETRY;
		building_face_4 GEOMETRY;
		aux_client_record RECORD;
		building_face GEOMETRY;
		width FLOAT;
	BEGIN
		width= 0.875;
		real_geom= ST_LineMerge(NEW.geom);
		
		aux_gr_geom = ST_Buffer(NEW.geom, width, 'endcap=flat join=round');

        -- Se genera una linea auxiliar para compararla con real geom y sacar el angulo de giro que hayq ue darle al pozo, 
        -- para que la ruta de entrada qeude perpendiuclar al area del pozo
		aux_geom=(ST_MakeLine(
			ST_SetSRID(ST_MakePoint(ST_X(ST_PointN(real_geom, 1)), ST_Y(ST_PointN(real_geom, 2))), 3857), 
			ST_SetSRID(ST_PointN(real_geom, 2), 3857)));
			
        -- Se obtienen los radianes de giro
		radians_to_rotate=ST_Angle(aux_geom, real_geom);

        -- Se obtiene el id de los elementos que tienen que rotar
		id_gis_sewer=(SELECT id_gis FROM (SELECT geom as a, * FROM gis.cw_sewer_box) WHERE ST_Intersects(a, ST_EndPoint(NEW.geom)));
		id_cb=(SELECT id_gis FROM (SELECT geom as a, * FROM gis.cw_connectivity_box) WHERE ST_Intersects(a, ST_EndPoint(NEW.geom)));
		SELECT * INTO building_record FROM (SELECT geom as a, * FROM gis.cw_building) WHERE ST_Intersects(a, NEW.geom);

        -- En el caso en el que la ruta sea de entrada al pozo, se actualizan las topologías
		IF id_gis_sewer IS NOT NULL
		THEN
			UPDATE gis.cw_sewer_box 
				SET layout_geom = (SELECT ST_Rotate(layout_geom, -radians_to_rotate, ST_centroid(geom)) FROM gis.cw_sewer_box where id_gis=id_gis_sewer)  
			WHERE id_gis=id_gis_sewer;
			
			UPDATE gis.cw_connectivity_box 
				SET layout_geom = (SELECT ST_Rotate(layout_geom, -radians_to_rotate, ST_centroid(geom)) FROM gis.cw_connectivity_box where id_gis=id_cb),
					diagonal_geom = (SELECT ST_Rotate(diagonal_geom, -radians_to_rotate, ST_centroid(geom)) FROM gis.cw_connectivity_box where id_gis=id_cb)  
			WHERE id_gis=id_cb;
		END IF;
		
		-- En el caso en el que se conecte a un edificio
		IF building_record IS NOT NULL
		THEN
			IF ST_Intersects(building_record.layout_geom, ST_EndPoint(NEW.geom))
			THEN
				building_on_start_point := false;
			ELSE
				building_on_start_point := true;
			END IF;

			-- Se establece la rotación en funcion de si es una ruta de entrada o salida
			IF NOT building_on_start_point
			THEN
				aux_geom := ST_MakeLine(
						ST_SetSRID(
							ST_MakePoint(
								ST_X(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER - 1) ), 
								ST_Y(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER))),
							3857), 
						ST_SetSRID(
							ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER), 3857)
					);
			ELSE
				aux_geom := ST_MakeLine(
						ST_SetSRID(
							ST_MakePoint(
								ST_X(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER)),
								ST_Y(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER-1))),
							3857), 
						ST_SetSRID(
							ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER-1), 3857)
					);
			END IF;

			-- Se calcula el angulo de giro
			radians_to_rotate := -ST_Angle(aux_geom, NEW.geom) - radians(90);

			
			building_face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=2));
			building_face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=3));
			building_face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=4));
			building_face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=5));

			SELECT * INTO aux_client_record FROM gis.cw_floor WHERE ST_Intersects(layout_geom, building_record.layout_geom) LIMIT 1;

			CASE
				WHEN ST_Distance(building_face_1, aux_client_record.layout_geom) = 0.7 
				THEN
					building_face := building_face_1;
				WHEN ST_Distance(building_face_2, aux_client_record.layout_geom) = 0.7 
				THEN
					building_face := building_face_2;
				WHEN ST_Distance(building_face_3, aux_client_record.layout_geom) = 0.7 
				THEN 
					building_face := building_face_3;
				ELSE 
					building_face := building_face_4;
			END CASE;

			CASE 
				WHEN ST_Intersects(NEW.geom,
					ST_Rotate(
						building_face,
						radians_to_rotate - radians(90), 
						building_record.geom
					)
				)
				THEN
					radians_to_rotate := radians_to_rotate - radians(90);
				WHEN ST_Intersects(NEW.geom,
					ST_Rotate(
						building_face,
						radians_to_rotate - radians(180), 
						building_record.geom
					)
				)
				THEN
					radians_to_rotate := radians_to_rotate - radians(180);
				WHEN ST_Intersects(NEW.geom,
					ST_Rotate(
						building_face,
						radians_to_rotate - radians(270), 
						building_record.geom
					)
				)
				THEN
					radians_to_rotate := radians_to_rotate - radians(270);
				ELSE
					-- DO NOTHING
			END CASE;

			-- Se actualzia tanto el edificio como los objetos que tiene en el interior
			UPDATE gis.cw_building SET
				layout_geom = ST_Rotate(layout_geom, radians_to_rotate, geom),
				rotate_rads = radians_to_rotate
			WHERE id_gis = building_record.id_gis;

			UPDATE gis.cw_floor SET 
				layout_geom = ST_Rotate(layout_geom, radians_to_rotate, building_record.geom) 
			WHERE ST_Intersects(geom, building_record.layout_geom);

			UPDATE gis.cw_client SET 
				geom = ST_Rotate(geom, radians_to_rotate, building_record.geom),
				layout_geom = ST_Rotate(layout_geom, radians_to_rotate, building_record.geom)
			WHERE ST_Intersects(geom, building_record.layout_geom);
		END IF;
		
		FOR current_node IN SELECT * FROM gis.cw_building WHERE 
			ST_Intersects(aux_gr_geom, gis.cw_building.layout_geom)
		LOOP
			aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
			aux_gr3d_geom=(SeLECt ST_Difference(real_geom, current_node.layout_geom));
		END LOOP;
		
		FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE 
			ST_Intersects(aux_gr_geom, gis.cw_sewer_box.layout_geom)
		LOOP
			aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
			aux_gr3d_geom=(SeLECt ST_Difference(real_geom, current_node.layout_geom));
		END LOOP;

		aux_gr3d_geom=real_geom;
		
		FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE 
			ST_Intersects(real_geom, gis.cw_sewer_box.layout_geom)
		LOOP
			aux_gr3d_geom=(SeLECt ST_Difference(aux_gr3d_geom, current_node.layout_geom));
		END LOOP;

		UPDATE gis.cw_ground_route
			SET id_gis=CONCAT('cw_ground_route_', NEW.id::text),
				calculated_length = ST_Length(NEW.geom),
				layout_geom = aux_gr_geom,
				layout_3d_geom = aux_gr3d_geom
		WHERE id = NEW.id;

		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER ground_route_insert_triggger
	AFTER INSERT ON gis.cw_ground_route
	FOR EACH ROW EXECUTE PROCEDURE ground_route_insert();

CREATE OR REPLACE FUNCTION ground_route_update() RETURNS trigger AS
	$$
	DECLARE 
		real_geom GEOMETRY;
		aux_gr_geom GEOMETRY;
		aux_geom GEOMETRY;
		cb_rotated_geom GEOMETRY;
		aux_gr3d_geom GEOMETRY;
		current_node RECORD;
		id_gis_sewer VARCHAR;
		id_cb VARCHAR;
		radians_to_rotate FLOAT;
		width FLOAT;
	BEGIN
		width= 0.875;

		IF NOT ST_Equals(OLD.geom, NEW.geom)
		THEN
			aux_gr_geom = ST_Buffer(NEW.geom, width, 'endcap=flat join=round');

			FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_overlaps(aux_gr_geom, gis.cw_sewer_box.layout_geom)
			LOOP
				aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
			END LOOP;

			aux_gr3d_geom = NEW.geom;
		
			FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE 
				ST_Intersects(NEW.geom, gis.cw_sewer_box.layout_geom)
			LOOP
				aux_gr3d_geom=(SeLECt ST_Difference(aux_gr3d_geom, current_node.layout_geom));
			END LOOP;

			UPDATE gis.cw_ground_route
			SET id_gis=CONCAT('cw_ground_route_', NEW.id::text),
				calculated_length = ST_Length(NEW.geom),
				layout_geom = aux_gr_geom,
				layout_3d_geom = aux_gr3d_geom
			WHERE id = NEW.id;
		END IF;

		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER ground_route_update_triggger
	AFTER UPDATE ON gis.cw_ground_route
	FOR EACH ROW EXECUTE PROCEDURE ground_route_update();

/*markdown
CREACION DEL OBJETO RUTA AEREA(SKYWAY)
*/

CREATE TABLE gis.cw_skyway(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	name VARCHAR,
	life_cycle template.life_cycle_enum,
	calculated_length FLOAT,
	measured_length FLOAT,
	owner template.owner_enum,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(POLYGON,3857),
	layout_3d_geom geometry(LINESTRING,3857)
);

CREATE UNIQUE INDEX idx_cw_skyway_id_gis ON gis.cw_skyway (id_gis);
CREATE INDEX idx_geom_skyway ON gis.cw_skyway USING GIST(geom);
CREATE INDEX idx_layout_geom_skyway ON gis.cw_skyway USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION skyway_insert() RETURNS trigger AS
	$$
	DECLARE 
		real_geom GEOMETRY;
		aux_gr_geom GEOMETRY;
		aux_geom GEOMETRY;
		cb_rotated_geom GEOMETRY;
		rotated_diagonal_geom GEOMETRY;
		perpendicular_diagonal_line GEOMETRY;
		aux_gr3d_geom GEOMETRY;
		current_node RECORD;
		id_gis_pole VARCHAR;
		id_gis_sewer VARCHAR;
		id_cb VARCHAR;
		building_record RECORD;
		building_on_start_point BOOLEAN;
		radians_to_rotate FLOAT;
		building_face_1 GEOMETRY;
		building_face_2 GEOMETRY;
		building_face_3 GEOMETRY;
		building_face_4 GEOMETRY;
		building_face GEOMETRY;
		aux_client_record RECORD;
		width FLOAT;
	BEGIN
		width= 0.625;

		real_geom= ST_LineMerge(NEW.geom);
		
		aux_gr_geom = ST_Buffer(NEW.geom, width, 'side=right');

        -- Se genera una linea auxiliar para compararla con real geom y sacar el angulo de giro que hayq ue darle al pozo, 
        -- para que la ruta de entrada qeude perpendiuclar al area del pozo
		aux_geom=(ST_MakeLine(
			ST_SetSRID(ST_MakePoint(ST_X(ST_PointN(real_geom, 1)), ST_Y(ST_PointN(real_geom, 2))), 3857), 
			ST_SetSRID(ST_PointN(real_geom, 2), 3857)));
			
        -- Se obtienen los radianes de giro
		radians_to_rotate=ST_Angle(aux_geom, real_geom);

        -- Se obtiene el id de los elementos que tienen que rotar
		id_gis_sewer = (SELECT id_gis FROM (SELECT geom as a, * FROM gis.cw_sewer_box) WHERE ST_Intersects(a, ST_EndPoint(NEW.geom)));
		id_gis_pole = (SELECT id_gis FROM (SELECT geom as a, * FROM gis.cw_pole) WHERE ST_Intersects(a, ST_EndPoint(NEW.geom)));	
		id_cb = (SELECT id_gis FROM (SELECT geom as a, * FROM gis.cw_connectivity_box) WHERE ST_Intersects(a, ST_EndPoint(NEW.geom)));
		SELECT * INTO building_record FROM (SELECT geom as a, * FROM gis.cw_building) WHERE ST_Intersects(a, NEW.geom);

        -- En el caso en el que la ruta sea de entrada al pozo, se actualizan las topologías
		IF id_gis_pole IS NOT NULL
		THEN
			cb_rotated_geom := (SELECT ST_Rotate(layout_geom, -radians_to_rotate, ST_centroid(geom)) FROM gis.cw_connectivity_box where id_gis=id_cb);
			rotated_diagonal_geom = (SELECT ST_Rotate(diagonal_geom, -radians_to_rotate, ST_centroid(geom)) FROM gis.cw_connectivity_box where id_gis=id_cb);
			perpendicular_diagonal_line := ST_Rotate(rotated_diagonal_geom, -PI()/2, ST_centroid(rotated_diagonal_geom));

			UPDATE gis.cw_pole 
				SET layout_geom = (SELECT ST_Rotate(layout_geom, -radians_to_rotate, ST_centroid(geom)) FROM gis.cw_pole where id_gis=id_gis_pole),
				support = ST_MakeLine(
						ST_MakeLine(
							ST_LineExtend(rotated_diagonal_geom, 0.875, 0.875), 
							ST_Centroid(rotated_diagonal_geom)),
						ST_LineExtend(perpendicular_diagonal_line, 0.875,  0.875)
					)
			WHERE id_gis=id_gis_pole;
			
			UPDATE gis.cw_connectivity_box 
				SET layout_geom = cb_rotated_geom,
					diagonal_geom = rotated_diagonal_geom
			WHERE id_gis=id_cb;
		ELSIF id_gis_sewer IS NOT NULL
		THEN
			UPDATE gis.cw_sewer_box 
				SET layout_geom = (SELECT ST_Rotate(layout_geom, radians_to_rotate, ST_centroid(geom)) FROM gis.cw_sewer_box where id_gis=id_gis_sewer)  
			WHERE id_gis=id_gis_sewer;
			
			UPDATE gis.cw_connectivity_box 
				SET layout_geom = (SELECT ST_Rotate(layout_geom, radians_to_rotate, ST_centroid(geom)) FROM gis.cw_connectivity_box where id_gis=id_cb),
					diagonal_geom = (SELECT ST_Rotate(diagonal_geom, radians_to_rotate, ST_centroid(geom)) FROM gis.cw_connectivity_box where id_gis=id_cb)  
			WHERE id_gis=id_cb;
		END IF;
		-- En el caso en el que se conecte a un edificio
		IF building_record IS NOT NULL
		THEN
			IF ST_Intersects(building_record.layout_geom, ST_EndPoint(NEW.geom))
			THEN
				building_on_start_point := false;
			ELSE
				building_on_start_point := true;
			END IF;
			
			-- Se establece la rotación en funcion de si es una ruta de entrada o salida
			IF NOT building_on_start_point
			THEN
				aux_geom := ST_MakeLine(
						ST_SetSRID(
							ST_MakePoint(
								ST_X(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER - 1) ), 
								ST_Y(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER))),
							3857), 
						ST_SetSRID(
							ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER), 3857)
					);
			ELSE
				aux_geom := ST_MakeLine(
						ST_SetSRID(
							ST_MakePoint(
								ST_X(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER)),
								ST_Y(ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER-1))),
							3857), 
						ST_SetSRID(
							ST_PointN(NEW.geom, (SELECT count(*) FROM ST_DumpPoints(NEW.geom))::INTEGER-1), 3857)
					);
			END IF;
			-- Se calcula el angulo de giro
			radians_to_rotate := -ST_Angle(aux_geom, NEW.geom);

			building_face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=2));
			building_face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=3));
			building_face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=4));
			building_face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=5));

			SELECT * INTO aux_client_record FROM gis.cw_floor WHERE ST_Intersects(layout_geom, building_record.layout_geom) LIMIT 1;

			CASE
				WHEN ST_Distance(building_face_1, aux_client_record.layout_geom) = 0.7 
				THEN
					building_face := building_face_1;
				WHEN ST_Distance(building_face_2, aux_client_record.layout_geom) = 0.7 
				THEN
					building_face := building_face_2;
				WHEN ST_Distance(building_face_3, aux_client_record.layout_geom) = 0.7 
				THEN 
					building_face := building_face_3;
				ELSE 
					building_face := building_face_4;
			END CASE;

			CASE 
				WHEN ST_Intersects(NEW.geom,
					ST_Rotate(
						building_face,
						radians_to_rotate - radians(90), 
						building_record.geom
					)
				)
				THEN
					radians_to_rotate := radians_to_rotate - radians(90);
				WHEN ST_Intersects(NEW.geom,
					ST_Rotate(
						building_face,
						radians_to_rotate - radians(180), 
						building_record.geom
					)
				)
				THEN
					radians_to_rotate := radians_to_rotate - radians(180);
				WHEN ST_Intersects(NEW.geom,
					ST_Rotate(
						building_face,
						radians_to_rotate - radians(270), 
						building_record.geom
					)
				)
				THEN
					radians_to_rotate := radians_to_rotate - radians(270);
				ELSE
					-- DO NOTHING
			END CASE;

			-- Se actualzia tanto el edificio como los objetos que tiene en el interior
			UPDATE gis.cw_building SET
				layout_geom = ST_Rotate(layout_geom, radians_to_rotate, geom),
				rotate_rads = radians_to_rotate
			WHERE id_gis = building_record.id_gis;

			UPDATE gis.cw_floor SET 
				geom = ST_Rotate(geom, radians_to_rotate, building_record.geom) ,
				layout_geom = ST_Rotate(layout_geom, radians_to_rotate, building_record.geom) 
			WHERE ST_Intersects(geom, building_record.layout_geom);

			UPDATE gis.cw_client SET 
				geom = ST_Rotate(geom, radians_to_rotate, building_record.geom),
				layout_geom = ST_Rotate(layout_geom, radians_to_rotate, building_record.geom)
			WHERE ST_Intersects(geom, building_record.layout_geom);
		END IF;
		
		FOR current_node IN SELECT * FROM gis.cw_building WHERE 
			ST_Intersects(aux_gr_geom, gis.cw_building.layout_geom)
		LOOP
			aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
		END LOOP;
		
		FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_Intersects(aux_gr_geom, gis.cw_sewer_box.layout_geom)
		LOOP
			aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
		END LOOP;

		FOR current_node IN SELECT * FROM gis.cw_pole WHERE ST_Intersects(aux_gr_geom, gis.cw_pole.layout_geom)
		LOOP
			aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
		END LOOP;

		aux_gr3d_geom= ST_OffsetCurve(real_geom, -width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');
	
		FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_Intersects(real_geom, gis.cw_sewer_box.layout_geom)
		LOOP
			aux_gr3d_geom= ST_Difference(aux_gr3d_geom, current_node.layout_geom);
		END LOOP;

		FOR current_node IN SELECT * FROM gis.cw_pole WHERE ST_Intersects(real_geom, gis.cw_pole.layout_geom)
		LOOP
			aux_gr3d_geom= ST_Difference(aux_gr3d_geom, current_node.layout_geom);
		END LOOP;

		FOR current_node IN SELECT * FROM gis.cw_building WHERE 
			ST_Intersects(aux_gr3d_geom, gis.cw_building.layout_geom)
		LOOP
			aux_gr3d_geom=(SELECT ST_Difference(aux_gr3d_geom, current_node.layout_geom));
		END LOOP;
		
		UPDATE gis.cw_skyway
			SET id_gis=CONCAT('cw_skyway_', NEW.id::text),
				calculated_length = ST_Length(NEW.geom),
				layout_geom = aux_gr_geom,
				layout_3d_geom = aux_gr3d_geom
		WHERE id = NEW.id;
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER skyway_insert_insert_triggger
	AFTER INSERT ON gis.cw_skyway
	FOR EACH ROW EXECUTE PROCEDURE skyway_insert();

CREATE OR REPLACE FUNCTION skyway_update_trigger() RETURNS trigger AS
	$$
	DECLARE 
		aux_gr_geom GEOMETRY;
		aux_gr3d_geom GEOMETRY;
		current_node RECORD;
		width FLOAT;    
	BEGIN
		width= 0.625;

		IF NOT ST_Equals(OLD.geom, NEW.geom)
		THEN		
			aux_gr_geom = ST_Buffer(NEW.geom, width, 'side=right');
			
			FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_Intersects(aux_gr_geom, gis.cw_sewer_box.layout_geom)
			LOOP
				aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
			END LOOP;

			FOR current_node IN SELECT * FROM gis.cw_pole WHERE ST_Intersects(aux_gr_geom, gis.cw_pole.layout_geom)
			LOOP
				aux_gr_geom=(SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
			END LOOP;

			aux_gr3d_geom = ST_OffsetCurve(NEW.geom, -width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');

			FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE 
				ST_Intersects(NEW.geom, gis.cw_sewer_box.layout_geom)
			LOOP
				aux_gr3d_geom=(SeLECt ST_Difference(aux_gr3d_geom, current_node.layout_geom));
			END LOOP;

			FOR current_node IN SELECT * FROM gis.cw_pole WHERE 
				ST_Intersects(NEW.geom, gis.cw_pole.layout_geom)
			LOOP
				aux_gr3d_geom=(SeLECt ST_Difference(aux_gr3d_geom, current_node.layout_geom));
			END LOOP;
			
			UPDATE gis.cw_skyway
				SET id_gis=CONCAT('cw_skyway_', NEW.id::text),
					calculated_length = ST_Length(NEW.geom),
					layout_geom = aux_gr_geom,
					layout_3d_geom = aux_gr3d_geom
			WHERE id = NEW.id;
		END IF;

		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER skyway_update_trigger
	AFTER UPDATE ON gis.cw_skyway
	FOR EACH ROW EXECUTE PROCEDURE skyway_update_trigger();

/*markdown
CREACION DEL OBJETO EMPALME DE FIBRA(FO SPLICE)
*/

CREATE TABLE gis.fo_splice(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	name VARCHAR,
	life_cycle template.life_cycle_enum,
	type template.fo_splice_enum,
	specification template.fo_splice_spec_enum,
	method template.fo_splice_method_enum,
	owner template.owner_enum,
	geom geometry(POINT,3857),
	layout_geom geometry(POLYGON,3857),
	CONSTRAINT specification 
		FOREIGN KEY(specification) 
			REFERENCES template.fo_splice_spec(model) 
);

CREATE UNIQUE INDEX idx_fo_splice_id_gis ON gis.fo_splice (id_gis);
CREATE INDEX idx_geom_fo_splice ON gis.fo_splice USING GIST(geom);
CREATE INDEX idx_layout_geom_fo_splice ON gis.fo_splice USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION fo_splice_insert() RETURNS trigger AS
	$$
	DECLARE 
		id_cb VARCHAR;
		splice_line GEOMETRY;
		splice_points GEOMETRY;		
		cb_boundary_point_1 GEOMETRY;
		cb_boundary_point_2 GEOMETRY;
		line_for_radians_1 GEOMETRY;
		line_for_radians_2 GEOMETRY;
		building_record RECORD;
		guitar_splices_line GEOMETRY;
		aux_line_for_radians GEOMETRY;
		radians_to_rotate FLOAT;
		cb_rec RECORD;
	BEGIN	
		IF (SELECT count(*) FROM gis.cw_connectivity_box WHERE ST_Intersects(layout_geom, NEW.geom)) > 0
		THEN
			id_cb=(SELECT id_gis FROM (SELECT geom as a, * FROM gis.cw_connectivity_box) WHERE ST_Intersects(geom, NEW.geom));
			SELECT * INTO cb_rec FROM gis.cw_connectivity_box WHERE ST_Intersects(geom, NEW.geom);

			-- Se obtiene la diagonal de la caja de conectividad
			splice_line=(SELECT diagonal_geom FROM gis.cw_connectivity_box WHERE id_gis=id_cb);

			-- Se dividide la linea en 10 puntos(Maximo de empalmes que habrá en cada pozo)
			splice_points=(SELECT ST_LineInterpolatePoints(ST_Linemerge(splice_line), 0.1, true));
				
			-- Se obtienen puntos, para generar lineas y así poder obtener los radianes de giro que tiene que girar el empalme,
			-- Se obtienen una linea a partir del punto inicial y el siguiente ed la linea qu rodea el area
			cb_boundary_point_1=(SELECT ST_StartPoint(ST_ExteriorRing(layout_geom)) FROM gis.cw_connectivity_box WHERE id_gis=id_cb);	
			cb_boundary_point_2=(SELECT ST_PointN(ST_ExteriorRing(layout_geom),2) FROM gis.cw_connectivity_box WHERE id_gis=id_cb);
			line_for_radians_1=ST_MakeLine(cb_boundary_point_1, cb_boundary_point_2);
			-- Se genera una linea paralela al eje x para porde obtener el angulo de giro
			line_for_radians_2=(ST_MakeLine(
				ST_SetSRID(ST_MakePoint(ST_X(cb_boundary_point_1), ST_Y(cb_boundary_point_2)),3857),
				cb_boundary_point_2));

			-- Se calcula el angulo de giro
			radians_to_rotate=ST_Angle(line_for_radians_2, line_for_radians_1);
			
			IF (SELECT count(*) FROM gis.cw_pole WHERE ST_Intersects(geom, cb_rec.layout_geom)) > 0
			THEN
				-- Se revisan los puntos en los que se peude añadir el empalme y se introducen
				FOR i IN 1..(ST_NumGeometries(splice_points)/2)
				LOOP
					IF (SELECT count(*) FROM gis.fo_splice WHERE ST_Intersects(ST_GeometryN(splice_points, (ST_NumGeometries(splice_points)/2) - i), gis.fo_splice.layout_geom))=0
					THEN
						UPDATE gis.fo_splice
							SET layout_geom=ST_Rotate(ST_Buffer(ST_GeometryN(splice_points, (ST_NumGeometries(splice_points)/2) - i), 0.175, 'endcap=square'), -radians_to_rotate, ST_centroid(ST_GeometryN(splice_points, (ST_NumGeometries(splice_points)/2) - i))),
								id_gis=CONCAT('fo_splice_', NEW.id::text)
						WHERE id=NEW.id;
						EXIT;
					ELSIF (SELECT count(*) FROM gis.fo_splice WHERE ST_Intersects(ST_GeometryN(splice_points, (ST_NumGeometries(splice_points)/2) + i), gis.fo_splice.layout_geom))=0
					THEN
						UPDATE gis.fo_splice
							SET layout_geom=ST_Rotate(ST_Buffer(ST_GeometryN(splice_points, (ST_NumGeometries(splice_points)/2) + i), 0.175, 'endcap=square'), -radians_to_rotate, ST_centroid(ST_GeometryN(splice_points, (ST_NumGeometries(splice_points)/2) + i))),
								id_gis=CONCAT('fo_splice_', NEW.id::text)
						WHERE id=NEW.id;
						EXIT;
					END IF;
				END LOOP;	
			ELSE
				-- Se revisan los puntos en los que se peude añadir el empalme y se introducen
				FOR i IN 1..ST_NumGeometries(splice_points)-1
				LOOP
					IF (SELECT count(*) FROM gis.fo_splice WHERE ST_Intersects(ST_GeometryN(splice_points, i), gis.fo_splice.layout_geom))=0
					THEN
						UPDATE gis.fo_splice
							SET layout_geom=ST_Rotate(ST_Buffer(ST_GeometryN(splice_points, i), 0.175, 'endcap=square'), -radians_to_rotate, ST_centroid(ST_GeometryN(splice_points, i))),
								id_gis=CONCAT('fo_splice_', NEW.id::text)
						WHERE id=NEW.id;
						EXIT;
					END IF;
				END LOOP;		
			END IF;
			IF (SELECT count(*) FROM gis.cw_pole WHERE ST_Intersects(geom, (SELECT geom FROM gis.cw_connectivity_box WHERE id_gis=id_cb))) > 0
			THEN
				PERFORM update_pole_3d_geometry(id_cb);
			END IF;
		ELSE
			SELECT * INTO building_record FROM gis.cw_building WHERE ST_Contains(layout_geom, NEW.geom);

			UPDATE gis.fo_splice SET
				layout_geom = ST_Rotate(ST_Buffer(NEW.geom, 0.175, 'endcap=square'), building_record.rotate_rads, NEW.geom),
				id_gis = CONCAT('fo_splice_', NEW.id::text)
			WHERE id=NEW.id;
		END IF;
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_splice_insert_triggger
	AFTER INSERT ON gis.fo_splice
		FOR EACH ROW EXECUTE PROCEDURE fo_splice_insert();

CREATE OR REPLACE FUNCTION fo_splice_delete_triggger() RETURNS trigger AS
$$
	DECLARE 	
		connectivity_box_record RECORD;
	BEGIN
		SELECT * INTO connectivity_box_record FROM gis.cw_connectivity_box WHERE ST_Intersects(layout_geom, OLD.layout_geom);

		UPDATE gis.fo_cable 
			SET layout_geom=ST_Difference(layout_geom, connectivity_box_record.layout_geom) 
		WHERE ST_Distance(layout_geom, OLD.layout_geom) < 0.003;

		UPDATE gis.fo_fiber 
			SET layout_geom=ST_Difference(layout_geom, connectivity_box_record.layout_geom),
			target = null,
			source = null 
		WHERE ST_Distance(layout_geom, OLD.layout_geom) < 0.003;

		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_splice_delete_triggger
	AFTER DELETE ON gis.fo_splice
	FOR EACH ROW EXECUTE PROCEDURE fo_splice_delete_triggger();
		
/*markdown
CREACIÓN DE CONDUCTOS(DUCT)
*/

CREATE TABLE gis.cw_duct(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,	
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(POLYGON,3857),
	layout_3d_geom geometry(LINESTRING,3857)
);

CREATE UNIQUE INDEX idx_cw_duct_id_gis ON gis.cw_duct (id_gis);
CREATE INDEX idx_geom_cw_duct ON gis.cw_duct USING GIST(geom);
CREATE INDEX idx_layout_geom_cw_duct ON gis.cw_duct USING GIST(layout_geom);

CREATE OR REPLACE FUNCTION duct_insert() RETURNS trigger AS
	$$
	DECLARE 
		new_geom GEOMETRY;
		aux_duct_3d_geom GEOMETRY;
		current_node record;
		width FLOAT;
	BEGIN
		width=0.09;
		-- Llamada recursiva para savar la geometria que no se toque con otro ducto
		new_geom:=public.duct_insert_recursive(NEW.id, NEW.geom, width, 0);		

		-- Se acortan los ductos para que corten el sewer_box
		FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_overlaps(new_geom, gis.cw_sewer_box.layout_geom)
		LOOP
			new_geom=(SELECT ST_Difference(new_geom, current_node.layout_geom));
		END LOOP;

		aux_duct_3d_geom = ST_OffsetCurve(NEW.geom, width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');

		FOR i IN 1..100
		LOOP
			IF ST_Intersects(aux_duct_3d_geom, new_geom)
			THEN
				EXIT;
			ELSE
				aux_duct_3d_geom = ST_OffsetCurve(aux_duct_3d_geom, width, 'quad_segs=4 join=mitre mitre_limit=2.2');
			END IF;
		END LOOP;

		FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_Intersects(NEW.geom, gis.cw_sewer_box.layout_geom)
		LOOP
			aux_duct_3d_geom=(SELECT ST_Difference(aux_duct_3d_geom, current_node.layout_geom));
		END LOOP;

		-- Se actualiza la geometría
		UPDATE gis.cw_duct
			SET layout_geom=new_geom, 
				layout_3d_geom = aux_duct_3d_geom,
				id_gis=CONCAT('cw_duct_', NEW.id::text)
		WHERE id = NEW.id;
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION duct_insert_recursive(id_duct INTEGER, geom_ini GEOMETRY, width1 FLOAT, width2 FLOAT) RETURNS GEOMETRY AS
	$$
	DECLARE 		
		new_geom1 GEOMETRY;
		new_geom2 GEOMETRY;
	BEGIN	
		new_geom1 = ST_Buffer(geom_ini, width1, 'side=left join=mitre');
		new_geom2 = ST_Buffer(geom_ini, width2, 'side=left join=mitre');
		new_geom1 = ST_Difference(new_geom1, new_geom2);

		--  lo hice con el Intersects del Centroide porque los ductos tienen que ir todos de forma continua
		--  Si se toca con algún centroide vuevle a hacer la llamada recusiva
		IF (SELECT count(*) FROM gis.cw_duct WHERE ST_Intersects(gis.cw_duct.layout_geom, ST_Centroid(new_geom1)))=0
		THEN
			RETURN new_geom1;
		ELSE
			new_geom1 := public.duct_insert_recursive(id_duct, geom_ini, width1 + 0.09, width1);
		END IF;

		RETURN new_geom1;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER duct_insert_triggger
	AFTER INSERT ON gis.cw_duct
	FOR EACH ROW EXECUTE PROCEDURE duct_insert();	

CREATE OR REPLACE FUNCTION duct_update() RETURNS trigger AS
	$$
	DECLARE 
		new_geom GEOMETRY;
		aux_duct_3d_geom GEOMETRY;
		current_node record;
		width FLOAT;
	BEGIN
		width=0.09;
		IF NOT ST_Equals(OLD.geom, NEW.geom)
		THEN
			new_geom:=public.duct_insert_recursive(NEW.id, NEW.geom, width, 0);
			-- Se acortan los ductos para que corten el sewer_box
			FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_overlaps(new_geom, gis.cw_sewer_box.layout_geom)
			LOOP
				new_geom=(SELECT ST_Difference(new_geom, current_node.layout_geom));
			END LOOP;

			aux_duct_3d_geom = ST_OffsetCurve(NEW.geom, width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');

			FOR i IN 1..100
			LOOP
				IF ST_Intersects(aux_duct_3d_geom, new_geom)
				THEN
					EXIT;
				ELSE
					aux_duct_3d_geom = ST_OffsetCurve(aux_duct_3d_geom, width, 'quad_segs=4 join=mitre mitre_limit=2.2');
				END IF;
			END LOOP;

			FOR current_node IN SELECT * FROM gis.cw_sewer_box WHERE ST_Intersects(NEW.geom, gis.cw_sewer_box.layout_geom)
			LOOP
				aux_duct_3d_geom=(SELECT ST_Difference(aux_duct_3d_geom, current_node.layout_geom));
			END LOOP;

			-- Se actualiza la geometría
			UPDATE gis.cw_duct
				SET layout_geom=new_geom, 
					layout_3d_geom = aux_duct_3d_geom,
					id_gis=CONCAT('cw_duct_', NEW.id::text)
			WHERE id = NEW.id;
		END IF;
		
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER duct_update_triggger
	AFTER UPDATE ON gis.cw_duct
	FOR EACH ROW EXECUTE PROCEDURE duct_update();

/*markdown
CREACION DE HILOS DE FIBRA(FO CABLE)
*/

CREATE TABLE gis.fo_fiber(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	id_cable VARCHAR,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(LINESTRING,3857) 
);

CREATE UNIQUE INDEX idx_fo_fiber_id_gis ON gis.fo_fiber (id_gis);
CREATE INDEX idx_geom_fo_fiber ON gis.fo_fiber USING GIST(geom);
CREATE INDEX idx_layout_geom_fo_fiber ON gis.fo_fiber USING GIST(layout_geom);

CREATE OR REPLACE FUNCTION create_fo_fiber(cable RECORD, cable_geom GEOMETRY, n_fibers INTEGER) RETURNS void
AS
	$$
	DECLARE
		width FLOAT;
		new_geom GEOMETRY;
		new_geom_aux GEOMETRY;
	BEGIN
	--  Crea una cantidad de fibras asociadas a un cable
		width=0.0000375;
		new_geom=cable_geom;
	
		FOR i IN 1..n_fibers
		LOOP			
			new_geom_aux := ST_OffsetCurve(new_geom, -width * i, 'quad_segs=4 join=mitre mitre_limit=2.2');

			IF ST_Distance(ST_StartPoint(cable_geom), ST_StartPoint(new_geom_aux)) > 0.006
			THEN
				new_geom_aux := ST_Reverse(new_geom_aux);
			END IF;

			INSERT INTO gis.fo_fiber(id_cable, geom, layout_geom)
				VALUES(
					CONCAT('fo_cable_', cable.id::text),
						cable.geom::geometry,
						ST_Linemerge(new_geom_aux));
		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

-- Crea fibras auxiliares para conectar los ports de los splitters
CREATE OR REPLACE FUNCTION create_fo_splitter_fiber(id_gis_splitter VARCHAR, splitter_fiber_geom GEOMETRY) RETURNS void
AS
	$$
	DECLARE
	BEGIN	
		INSERT INTO gis.fo_fiber(id_cable, geom, layout_geom)
			VALUES(
				CONCAT(id_gis_splitter),
					splitter_fiber_geom,
					splitter_fiber_geom);
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_fo_fiber_to_splice(id_gis_cable VARCHAR, cable_geom GEOMETRY) RETURNS void
AS
	$$
	DECLARE
		width FLOAT;
		new_geom GEOMETRY;
		new_geom_aux GEOMETRY;
		current_fiber RECORD;
	BEGIN
		width=0.0000375;
		--  Actualiza todas las fibras para hacer match con la geometría del cable padre
		FOR current_fiber IN SELECT * FROM gis.fo_fiber WHERE id_cable=id_gis_cable ORDER BY id_gis
		LOOP			
			new_geom_aux=ST_LineMerge(ST_OffsetCurve(cable_geom, -width, 'quad_segs=4 join=mitre mitre_limit=2.2'));

			IF ST_Distance(ST_StartPoint(cable_geom), ST_StartPoint(new_geom_aux)) > 0.006
			THEN
				new_geom_aux := ST_Reverse(new_geom_aux);
			END IF;

			UPDATE gis.fo_fiber
				SET layout_geom=new_geom_aux,
					source = null,
					target = null
			WHERE id_gis = current_fiber.id_gis;
			width = width + 0.0000375;
		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fo_fiber_insert() RETURNS trigger AS
	$$
	DECLARE 
	
	BEGIN
		UPDATE gis.fo_fiber
			SET id_gis=CONCAT('fo_fiber_', NEW.id::text)
		WHERE id = NEW.id;	

		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_fiber_insert_triggger
	AFTER INSERT ON gis.fo_fiber
	FOR EACH ROW EXECUTE PROCEDURE fo_fiber_insert();


-- Actualización de la topología borrando nodos no utilizados y recreando la topología en los nodos existentes
CREATE OR REPLACE FUNCTION update_fiber_topology() RETURNS void
AS
	$$
	DECLARE
	BEGIN
		PERFORM pgr_CreateTopology('gis.fo_fiber', 0.000025, 'layout_geom', 'id');
		DELETE FROM gis.fo_fiber_vertices_pgr 
			WHERE id NOT IN (SELECT source FROM gis.fo_fiber UNION SELECT target FROM gis.fo_fiber);
	END;
	$$
LANGUAGE plpgsql;


/*markdown
CRACIÓN DE PUERTOS DE SPLITTER
*/

CREATE TABLE gis.in_port (
    id SERIAL PRIMARY KEY,
    id_gis VARCHAR,
    geom GEOMETRY(POINT, 3857)
);

CREATE UNIQUE INDEX idx_in_port_id_gis ON gis.in_port (id_gis);
CREATE INDEX idx_geom_in_port ON gis.in_port USING GIST(geom);

CREATE OR REPLACE FUNCTION in_port_insert_trigger_func() RETURNS trigger
AS
	$$
	DECLARE
    BEGIN
         UPDATE gis.in_port
			SET id_gis=CONCAT('in_port_', NEW.id::text)
		WHERE id = NEW.id;	

		RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER in_port_insert_triggger
	AFTER INSERT ON gis.in_port
	FOR EACH ROW EXECUTE PROCEDURE in_port_insert_trigger_func();	

CREATE TABLE gis.out_port (
    id SERIAL PRIMARY KEY,
    id_gis VARCHAR,
    geom GEOMETRY(POINT, 3857)
);

CREATE UNIQUE INDEX idx_out_port_id_gis ON gis.out_port (id_gis);
CREATE INDEX idx_geom_out_port ON gis.out_port USING GIST(geom);

CREATE OR REPLACE FUNCTION out_port_insert_trigger_func() RETURNS trigger
AS
	$$
	DECLARE
    BEGIN
        UPDATE gis.out_port
			SET id_gis=CONCAT('out_port_', NEW.id::text)
		WHERE id = NEW.id;	

		RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER out_port_insert_triggger
	AFTER INSERT ON gis.out_port
	FOR EACH ROW EXECUTE PROCEDURE out_port_insert_trigger_func();	

/*markdown
CRACIÓN DE SPLITTER
*/

CREATE TABLE gis.optical_splitter (
    id SERIAL PRIMARY KEY,
    id_gis VARCHAR,
	life_cycle template.life_cycle_enum,
	specification template.optical_splitter_spec_enum,
	method template.optical_splitter_method_enum,
	owner template.owner_enum,
    geom GEOMETRY(LINESTRING, 3857)
);

CREATE UNIQUE INDEX idx_optical_splitter_id_gis ON gis.optical_splitter (id_gis);
CREATE INDEX idx_geom_optical_splitter ON gis.optical_splitter USING GIST(geom);

-- Metodo para insertar optical_splitters
CREATE OR REPLACE FUNCTION insert_optical_splitter(id_gis_splice VARCHAR, n_ports_salida INTEGER) RETURNS void
AS
	$$
	DECLARE
        fo_splice RECORD;
        splice_face GEOMETRY;
        aux_offset_line GEOMETRY;
		aux_offset_line_ori GEOMETRY;
        splitter_geom GEOMETRY;
		n_fibers_crossed INTEGER;
        width FLOAT;
    BEGIN
		width=0.0000375;
		SELECT * INTO fo_splice FROM gis.fo_splice WHERE id_gis=id_gis_splice;

        -- Se obtienen la cantidad de fibras que han pasado dentro del empalme
		n_fibers_crossed = (SELECT count(*) FROM gis.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, fo_splice.layout_geom)) > 0.005);
		
		aux_offset_line_ori = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice.layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(fo_splice.layout_geom) WHERE path[2]=3));
		-- Dependiendo de las fibras que ya hayan entrado en el empalme utilizo una autovia diferente, se tienen e cuenta los ports
        FOR i IN 0..1000
        LOOP		
            aux_offset_line = ST_OffsetCurve(aux_offset_line_ori, -width * (1000 + i), 'quad_segs=4 join=round');
            IF ((SELECT count(*) FROM gis.in_port WHERE ST_Distance(aux_offset_line, geom) < 0.000025) < 1 AND 
                (SELECT count(*) FROM gis.out_port WHERE ST_Distance(aux_offset_line, geom) < 0.000025) < 1)
            THEN
                EXIT;
            END IF;
        END LOOP;		

		splitter_geom = ST_Centroid(aux_offset_line);

        FOR i IN 0..n_ports_salida-1
        LOOP
            -- Se va acatualizando la linea que representará el splitter
            splitter_geom = ST_MakeLine(splitter_geom, ST_Centroid(ST_OffsetCurve(aux_offset_line, width, 'quad_segs=4 join=round')));  

			width = width + 0.0000375;
        END LOOP;

        INSERT INTO gis.optical_splitter(geom) VALUES(splitter_geom);   
    END;
	$$
LANGUAGE plpgsql;	

CREATE OR REPLACE FUNCTION optical_splitter_insert_trigger_func() RETURNS trigger
AS
	$$
	DECLARE
        id_gis_splitter VARCHAR;
        splitter_points GEOMETRY;
    BEGIN
        id_gis_splitter = CONCAT('optical_splitter_', NEW.id::text);

		UPDATE gis.optical_splitter
			SET id_gis=id_gis_splitter
		WHERE id = NEW.id;

		-- SE crea el port de entrada
        INSERT INTO gis.in_port(geom) VALUES((SELECT geom FROM ST_DumpPoints(NEW.geom) WHERE path[1]=1));
		
        -- Se crean los purrtos de salida y cables auxiliares apra conectar fibras
        FOR i IN 2..(SELECT count(*) FROM ST_DumpPoints(NEW.geom))
        LOOP
            INSERT INTO gis.out_port(geom) VALUES((SELECT geom FROM ST_DumpPoints(NEW.geom) WHERE path[1]=i));
			-- PERFORM create_fo_splitter_fiber(id_gis_splitter, ST_MakeLine(ST_StartPoint(NEW.geom), (SELECT geom FROM ST_DumpPoints(NEW.geom) WHERE path[1]=i)));
        END LOOP;

		RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER optical_splitter_insert_triggger
	AFTER INSERT ON gis.optical_splitter
	FOR EACH ROW EXECUTE PROCEDURE optical_splitter_insert_trigger_func();	

CREATE OR REPLACE FUNCTION optical_splitter_delete_trigger() RETURNS trigger
AS
	$$
	DECLARE
		fo_splice_record RECORD;
    BEGIN
		SELECT * INTO fo_splice_record FROM gis.fo_splice WHERE ST_Intersects(layout_geom, OLD.geom);

		UPDATE gis.fo_fiber SET
			layout_geom = ST_Difference(layout_geom, fo_splice_record.layout_geom),
			target = null,
			source = null
		WHERE 
			ST_Distance(layout_geom, OLD.geom) < 0.0003;

		DELETE FROM gis.out_port WHERE ST_Intersects(geom, OLD.geom);
		DELETE FROM gis.in_port WHERE ST_Intersects(geom, OLD.geom);

		RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER optical_splitter_delete_triggger
	AFTER DELETE ON gis.optical_splitter
	FOR EACH ROW EXECUTE PROCEDURE optical_splitter_delete_trigger();	

/*markdown
CREACION DE CABLES DE FIBRA(FO CABLE)
*/

CREATE TABLE gis.fo_cable(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	id_duct VARCHAR,
	name VARCHAR,
	life_cycle template.life_cycle_enum,
	calculated_length FLOAT,
	measured_length FLOAT,
	specification template.fo_cable_spec_enum,
	source INTEGER,
	target INTEGER,
	is_acometida BOOLEAN DEFAULT false,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(LINESTRING,3857) 
);

CREATE UNIQUE INDEX idx_fo_cable_id_gis ON gis.fo_cable (id_gis);
CREATE INDEX idx_geom_fo_cable ON gis.fo_cable USING GIST(geom);
CREATE INDEX idx_layout_geom_fo_cable ON gis.fo_cable USING GIST(layout_geom);

CREATE OR REPLACE FUNCTION fo_cable_insert() RETURNS trigger AS
	$$
	DECLARE 
		new_geom GEOMETRY;	
		current_client RECORD;
		current_rack RECORD;
		splice_connection BOOLEAN;
	BEGIN
		splice_connection := false;
		IF (SELECT count(*) FROM gis.fo_splice WHERE ST_Intersects(ST_StartPoint(NEW.geom), layout_geom)) > 0
		THEN
			IF (SELECT count(*) FROM gis.fo_splice WHERE ST_Intersects(ST_EndPoint(NEW.geom), layout_geom)) > 0
			THEN
				splice_connection := true;
			END IF; 
		END IF; 
		--  Llamada recurisva para obtener una ubicaciónq ue no corte ningún cable
		IF (SELECT count(*) FROM ST_DumpPoints(NEW.geom)) > 2 AND NOT NEW.is_acometida AND NOT splice_connection
		THEN
			new_geom:=fo_cable_pass_by_insert(NEW.geom, NEW.id_duct);		
		ELSIF NOT NEW.is_acometida AND NOT splice_connection
		THEN
			new_geom:=fo_cable_insert_recursive(NEW.geom, NEW.id_duct);		
		END IF;

		IF splice_connection THEN new_geom := NEW.layout_geom; END IF;
		
		IF NEW.is_acometida
		THEN
			new_geom := NEW.layout_geom;
			FOR current_client IN SELECT * FROM gis.cw_client WHERE ST_Intersects(layout_geom, new_geom)
			LOOP
				new_geom := ST_Difference(new_geom, current_client.layout_geom);
			END LOOP;

			FOR current_rack IN SELECT * FROM gis.rack WHERE ST_Intersects(layout_geom, new_geom)
			LOOP
				new_geom := ST_Difference(new_geom, current_rack.layout_geom);
			END LOOP;

			UPDATE gis.fo_cable
				SET layout_geom=new_geom,
					id_gis=CONCAT('fo_cable_', NEW.id::text)
				WHERE id = NEW.id;

			PERFORM create_fo_fiber(NEW, new_geom, 144);	

			RETURN NEW;
		END IF;

		UPDATE gis.fo_cable
			SET layout_geom=new_geom,
				id_gis=CONCAT('fo_cable_', NEW.id::text)
		WHERE id = NEW.id;

		-- LLama a la función que inserta las fibras
		PERFORM create_fo_fiber(NEW, new_geom, 144);	
		-- PERFORM pgr_CreateTopology('gis.fo_fiber', 0.0001, 'layout_geom', 'id');
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

-- Función para generar de forma correcta los cables que pasan de largo.
CREATE OR REPLACE FUNCTION fo_cable_pass_by_insert(current_geom GEOMETRY, id_duct VARCHAR) RETURNS GEOMETRY AS
	$$
	DECLARE 
		width FLOAT;
		ducts_array TEXT[];
		previous_cable_section GEOMETRY;
		actual_cable_section GEOMETRY;
		previous_cable_section_layout GEOMETRY;
		actual_cable_section_layout GEOMETRY;
		current_connectivity_box RECORD;
		face_1 GEOMETRY;
		face_2 GEOMETRY;
		face_3 GEOMETRY;
		face_4 GEOMETRY;
		n_crossing_cables INTEGER;
		previous_cable_face GEOMETRY;
		actual_cable_face GEOMETRY;
		aux_cable_face GEOMETRY;
		intersection_previous_face_with_aux_face GEOMETRY;
		intersection_actual_face_with_aux_face GEOMETRY;
		intersection_previous_face_with_actual_face GEOMETRY;
		start_point GEOMETRY;
		current_parent_element RECORD;
	BEGIN
		width = 0.0125;

		IF id_duct IS NOT NULL
		THEN
			SELECT ARRAY(SELECT TRIM(x) FROM unnest(string_to_array(id_duct, ',')) AS t(x)) INTO ducts_array;
		END IF;

		-- Obtención de los diferentes tramos del cable. Empieza en 2 para poder coger tramo anterior y siguiente.
		FOR i IN 2..(SELECT count(*) FROM ST_DumpPoints(current_geom))-1
		LOOP
			-- Se sacan las secciones anterior y posterior del punto i de la cadena
			previous_cable_section = ST_MakeLine((SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i - 1), (SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i));
			actual_cable_section = ST_MakeLine((SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i), (SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i + 1));
			
			IF previous_cable_section_layout IS NULL
			THEN
				IF ducts_array[i - 1] IS NOT NULL
				THEN
					previous_cable_section_layout := fo_cable_insert_recursive(previous_cable_section, ducts_array[i - 1]);
				ELSE
					previous_cable_section_layout := fo_cable_insert_recursive(previous_cable_section, null);
				END IF;
			END IF;

			IF ducts_array[i] IS NOT NULL
			THEN
				actual_cable_section_layout := fo_cable_insert_recursive(actual_cable_section, ducts_array[i]);
			ELSE
				actual_cable_section_layout := fo_cable_insert_recursive(actual_cable_section, null);
			END IF;			

			-- Se obitiene el connectivity_box en el punto i de la cadena
			SELECT * INTO current_connectivity_box FROM gis.cw_connectivity_box WHERE ST_Intersects(layout_geom, ST_EndPoint(previous_cable_section));

			IF (SELECT count(*) FROM gis.cw_pole WHERE ST_Intersects(geom, current_connectivity_box.layout_geom)) > 0
			THEN
				SELECT * INTO current_parent_element FROM gis.cw_pole WHERE ST_Intersects(geom, current_connectivity_box.layout_geom);
			END IF;

			-- Se divide el area en caras
			face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=2));
			face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=3));
			face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=4));
			face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2]=5));

			-- Se obtiene la cara de entrada del cable
			SELECT INTO previous_cable_face
			CASE
				WHEN ST_Intersects(face_1, previous_cable_section) THEN face_1
				WHEN ST_Intersects(face_2, previous_cable_section) THEN face_2
				WHEN ST_Intersects(face_3, previous_cable_section) THEN face_3
				ELSE face_4
			END;
			
			-- Se obtiene la cara de salida del cable
			SELECT INTO actual_cable_face
			CASE
				WHEN ST_Intersects(face_1, actual_cable_section) THEN face_1
				WHEN ST_Intersects(face_2, actual_cable_section) THEN face_2
				WHEN ST_Intersects(face_3, actual_cable_section) THEN face_3
				ELSE face_4
			END;

			-- Se obtiene el numero de cables que pasan de largo

			n_crossing_cables = (SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(current_connectivity_box.layout_geom, geom) 
				AND NOT ST_Intersects(current_connectivity_box.layout_geom, ST_EndPoint(geom)) 
				AND	NOT ST_Intersects(current_connectivity_box.layout_geom, ST_StartPoint(geom))
				AND layout_geom IS NOT NULL) + 1;
			
			previous_cable_section_layout := ST_LineMerge(previous_cable_section_layout);
			-- Se calculan las caras con un offset en funcion del numerod e cables que pasan de largo

			previous_cable_face = ST_LineExtend(ST_OffsetCurve(previous_cable_face, width * n_crossing_cables, 'quad_segs=4 join=mitre mitre_limit=2.2'), 0.25, 0.25);
			actual_cable_face = ST_LineExtend(ST_OffsetCurve(actual_cable_face, width * n_crossing_cables, 'quad_segs=4 join=mitre mitre_limit=2.2'), 0.25, 0.25);

			previous_cable_section_layout :=  ST_LineSubstring(
					previous_cable_section_layout,
					0,
					ST_LineLocatePoint(previous_cable_section_layout, ST_ClosestPoint(previous_cable_section_layout, previous_cable_face))
				);
			
			-- En el caso en el que la caras no intersecten se genera una cara auxiliar, la mas ceracana al punto de entrada
			IF ST_Equals(previous_cable_face, actual_cable_face)
			THEN
				previous_cable_section_layout = ST_MakeLine(
					ST_MakeLine(
						ST_MakeLine(
							previous_cable_section_layout,
							ST_Intersection(actual_cable_section_layout, actual_cable_face)
						),
						ST_EndPoint(actual_cable_section_layout)
					)
				);
			ELSIF NOT ST_Intersects(previous_cable_face, actual_cable_face)
			THEN
				WITH distances AS (
				SELECT
					unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
					ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), ST_EndPoint(previous_cable_section_layout)) AS distance
                )
                SELECT 
                    face
                INTO 
                    aux_cable_face
                FROM (
                    SELECT 
                        face,
                        ROW_NUMBER() OVER (ORDER BY distance) AS rn
                    FROM 
                        distances
                ) ranked_distances
                WHERE rn = 2;

				-- Se asaca el offset de la cara auxiliar
				aux_cable_face = ST_LineExtend(ST_OffsetCurve(aux_cable_face, width * n_crossing_cables, 'quad_segs=4 join=mitre mitre_limit=2.2'), 0.25, 0.25);
				
				-- Se generan los puntos de insterscciónde las caras
				intersection_previous_face_with_aux_face = ST_Intersection(previous_cable_face, aux_cable_face);
				intersection_actual_face_with_aux_face = ST_Intersection(actual_cable_face, aux_cable_face);
		
				previous_cable_section_layout = ST_MakeLine(
					ST_MakeLine(
						ST_MakeLine(
							ST_MakeLine(
								previous_cable_section_layout,
								intersection_previous_face_with_aux_face
							),
							intersection_actual_face_with_aux_face
						),
						ST_Intersection(actual_cable_section_layout, actual_cable_face)	
					),
					ST_EndPoint(actual_cable_section_layout)
				);
			ELSE
				-- Se saca el punto de intersección de las caras quet ocan los cables
				intersection_previous_face_with_actual_face = ST_Intersection(previous_cable_face, actual_cable_face);
		
				--  Se actualiza la geometría
				previous_cable_section_layout = ST_MakeLine(
					ST_MakeLine(
						ST_MakeLine(
							ST_MakeLine(
								previous_cable_section_layout,
								intersection_previous_face_with_actual_face
							),
							ST_Intersection(actual_cable_section_layout, actual_cable_face)
						),
						ST_EndPoint(actual_cable_section_layout)
					)
				);
			END IF;			
		END LOOP;		 

		RETURN previous_cable_section_layout;
	END;
	$$
LANGUAGE plpgsql;

-- Genera la geometría layout por dentro o fuera de ductos
CREATE OR REPLACE FUNCTION fo_cable_insert_recursive(current_geom GEOMETRY, id_duct_func VARCHAR) RETURNS GEOMETRY AS
	$$
	DECLARE 
		new_geom GEOMETRY;
		new_geom_aux GEOMETRY;
		gr_geom GEOMETRY;
		n_cables INTEGER;
		n_jumps_for_duct INTEGER;
		current_cbox_node record;
		current_building RECORD;
	BEGIN		
		n_cables = 0;
		-- En  el caso en el que el cable vaya por fuera de ducto
		IF id_duct_func IS NULL OR id_duct_func='null'
		THEN
			new_geom = (SELECT ST_OffsetCurve(current_geom, -0.05, 'quad_segs=4 join=mitre mitre_limit=2.2'));

			-- Comprobación por si se ha invertido la geometría
			IF ST_Distance(ST_StartPoint(current_geom), ST_StartPoint(new_geom)) > 0.06
			THEN
				new_geom := ST_Reverse(new_geom);
			END IF;
			new_geom_aux=new_geom;
			
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_distance(gis.fo_cable.layout_geom, ST_Centroid(new_geom_aux)) < 0.04) > 0
			THEN
				new_geom_aux := fo_cable_insert_recursive(new_geom_aux, id_duct_func);
			END IF;			
		ELSE
			n_jumps_for_duct=1;
			
			IF NOT EXISTS (
					SELECT 1 
					FROM gis.cw_duct 
					WHERE id_gis = id_duct_func 
					AND ST_Intersects(new_geom, layout_geom)
				)
			THEN
				FOR i IN 1..1000
				LOOP
					new_geom=(SELECT ST_OffsetCurve(current_geom, 0.0075 * (i), 'quad_segs=4 join=mitre mitre_limit=2.2'));
					IF EXISTS (
						SELECT 1 
						FROM gis.cw_duct 
						WHERE id_gis = id_duct_func 
						AND ST_Intersects(new_geom, layout_geom)
					)
					THEN
						n_jumps_for_duct=i;
						EXIT;
					END IF;
				END LOOP;
			END IF;

			new_geom=(SELECT ST_OffsetCurve(current_geom, 0.0075 * (n_jumps_for_duct), 'quad_segs=4 join=mitre mitre_limit=2.2'));

			IF ST_Distance(ST_StartPoint(current_geom), ST_StartPoint(new_geom)) > 0.03
			THEN
				new_geom := ST_Reverse(new_geom);
			END IF;

			new_geom_aux=new_geom;

			IF  (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(gis.fo_cable.layout_geom, ST_Centroid(new_geom_aux)) < 0.005) > 0
			THEN
				new_geom_aux := fo_cable_insert_recursive(new_geom_aux, id_duct_func);
			END IF;
		END IF;	
		-- Se acrota la geometría para que no vaya por dentro de la connectivity_box y se devuelve
		FOR current_cbox_node IN SELECT * FROM gis.cw_connectivity_box as cb WHERE ST_Intersects(new_geom_aux, cb.layout_geom) 
			AND (ST_Intersects(ST_StartPoint(new_geom_aux), cb.layout_geom) OR ST_Intersects(ST_EndPoint(new_geom_aux), cb.layout_geom))
		LOOP
			new_geom_aux=(SELECT ST_Difference(new_geom_aux, current_cbox_node.layout_geom));
		END LOOP;

		FOR current_building IN SELECT * FROM gis.cw_building WHERE ST_Intersects(layout_geom, new_geom_aux)
		LOOP
			new_geom_aux := ST_Difference(new_geom_aux, current_building.layout_geom);
		END LOOP;

		RETURN new_geom_aux;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_cable_insert_triggger
	AFTER INSERT ON gis.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_insert();		

CREATE OR REPLACE FUNCTION fo_cable_update() RETURNS trigger AS
	$$
	DECLARE 
		new_geom GEOMETRY;
		current_fiber RECORD;
		current_connected_fiber RECORD;
		cont INTEGER;
		width FLOAT;
		current_cb_box RECORD;
		current_splice RECORD;
		current_aux_record RECORD;
	BEGIN
		IF NOT ST_Equals(OLD.geom, NEW.geom)
		THEN
			width=0.0000375;

			IF (SELECT count(*) FROM ST_DumpPoints(NEW.geom)) > 2
			THEN
				new_geom:=fo_cable_pass_by_insert(NEW.geom, NEW.id_duct);		
			ELSE
				new_geom:=fo_cable_insert_recursive(NEW.geom, NEW.id_duct);		
			END IF;

			UPDATE gis.fo_cable
				SET layout_geom = ST_LineMerge(new_geom)
			WHERE id = NEW.id;	

			cont := 1;

			FOR current_fiber IN SELECT * FROM gis.fo_fiber WHERE id_cable = OLD.id_gis ORDER BY id_gis
			LOOP
				UPDATE gis.fo_fiber				
					SET geom = NEW.geom,
						layout_geom = ST_OffsetCurve(new_geom, -width * cont, 'quad_segs=4 join=mitre mitre_limit=2.2'),
						source = null,
						target = null
				WHERE id = current_fiber.id;	
				cont = cont + 1;
			END LOOP;						
		END IF;
		
		RETURN NEW;
	END;
	$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_cable_update_triggger
	AFTER UPDATE ON gis.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_update();	

CREATE OR REPLACE FUNCTION fo_cable_delete_triggger() RETURNS trigger AS
$$
	DECLARE 	
	BEGIN
		DELETE FROM gis.fo_fiber WHERE id_cable = OLD.id_gis;

		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_cable_delete_triggger
	AFTER DELETE ON gis.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_delete_triggger();

/*markdown
    CREACIÓN DE LA TABLA BUILDINGS
*/

CREATE TABLE gis.cw_building(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
    n_floors INTEGER,
    n_clients INTEGER,
	rotate_rads  DOUBLE PRECISION,
	geom geometry(POINT, 3857),
	layout_geom geometry(POLYGON, 3857)  
);

-- Se crean los indices resppecto al id_gis y a los campos geométricos.
CREATE UNIQUE INDEX idx_cw_building_id_gis ON gis.cw_building (id_gis);
CREATE INDEX idx_cw_building_geom ON gis.cw_building USING GIST(geom);
CREATE INDEX idx_cw_building_layout_geom ON gis.cw_building USING GIST(layout_geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION building_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
        width FLOAT;
        height FLOAT;
        new_layout_geom GEOMETRY;
    BEGIN
        width = 7.8;
        height = 0.75 * (NEW.n_floors + 1);

        new_layout_geom := ST_MakeEnvelope(
            ST_X(NEW.geom) - width,  -- Coordenada x de la esquina inferior izquierda
            ST_Y(NEW.geom) - height,   -- Coordenada y de la esquina inferior izquierda
            ST_X(NEW.geom) + width,  -- Coordenada x de la esquina superior derecha
            ST_Y(NEW.geom) + height,   -- Coordenada y de la esquina superior derecha
            ST_SRID(NEW.geom));            -- SRID
            
        PERFORM create_floors_and_clients(new_layout_geom, NEW.n_floors, NEW.n_clients, height);            

        UPDATE gis.cw_building SET 
            layout_geom = new_layout_geom,
			rotate_rads = 0,
            id_gis = CONCAT('cw_building_', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER building_triggger
	AFTER INSERT ON gis.cw_building
	FOR EACH ROW EXECUTE PROCEDURE building_insert_trigger();

CREATE OR REPLACE FUNCTION create_floors_and_clients(cw_building_geom GEOMETRY, n_floors INTEGER, n_clients INTEGER, height FLOAT) RETURNS VOID AS 
	$$
	DECLARE
		central_line GEOMETRY;
		central_floor_points GEOMETRY;
		central_line_clients GEOMETRY;
		central_clients_line_points GEOMETRY;
		clients_distance FLOAT;
		floor_width FLOAT;
		floor_height FLOAT;
		new_floor_layout_geom GEOMETRY;
		aux_line_1 GEOMETRY;
		aux_line_2 GEOMETRY;
		cont_clients INTEGER;
		pos INTEGER;
		pos_floor INTEGER;
	BEGIN
		floor_width := 6;
		floor_height := 0.6;

		aux_line_1 := ST_MakeLine(
				(SELECT geom FROM ST_DUmpPoints(cw_building_geom) WHERE path[2] = 4),
				(SELECT geom FROM ST_DUmpPoints(cw_building_geom) WHERE path[2] = 5)
			);
		aux_line_2 := ST_MakeLine(
				(SELECT geom FROM ST_DUmpPoints(cw_building_geom) WHERE path[2] = 2),
				(SELECT geom FROM ST_DUmpPoints(cw_building_geom) WHERE path[2] = 3)
			);

		central_line := ST_MakeLine(
			ST_Centroid(aux_line_1), 
			ST_Centroid(aux_line_2)
		);
		
		central_line := ST_OffsetCurve(central_line, -0.9, 'quad_segs=4 join=mitre mitre_limit=2.2');

		central_floor_points := (SELECT ST_LineInterpolatePoints(central_line, (1::FLOAT / (n_floors + 1)::FLOAT), true));

		FOR i IN 1..(ST_NumGeometries(central_floor_points)-1)
		LOOP
			pos_floor := ST_NumGeometries(central_floor_points) - i;
			new_floor_layout_geom := ST_MakeEnvelope(
				ST_X(ST_GeometryN(central_floor_points, pos_floor)) - floor_width,  -- Coordenada x de la esquina inferior izquierda
				ST_Y(ST_GeometryN(central_floor_points, pos_floor)) - floor_height,   -- Coordenada y de la esquina inferior izquierda
				ST_X(ST_GeometryN(central_floor_points, pos_floor)) + floor_width,  -- Coordenada x de la esquina superior derecha
				ST_Y(ST_GeometryN(central_floor_points, pos_floor)) + floor_height,   -- Coordenada y de la esquina superior derecha
				ST_SRID(ST_GeometryN(central_floor_points, pos_floor))
			);

			aux_line_1 := ST_MakeLine(
					(SELECT geom FROM ST_DUmpPoints(new_floor_layout_geom) WHERE path[2] = 3),
					(SELECT geom FROM ST_DUmpPoints(new_floor_layout_geom) WHERE path[2] = 4)
				);
			aux_line_2 := ST_MakeLine(
					(SELECT geom FROM ST_DUmpPoints(new_floor_layout_geom) WHERE path[2] = 1),
					(SELECT geom FROM ST_DUmpPoints(new_floor_layout_geom) WHERE path[2] = 2)
				);

			central_line_clients := ST_MakeLine(
				ST_Centroid(aux_line_1), 
				ST_Centroid(aux_line_2)
			);

			central_clients_line_points := (SELECT ST_LineInterpolatePoints(central_line_clients, (1::FLOAT / (20+1)::FLOAT), true));

			IF ST_NumGeometries(central_clients_line_points) > 1
			THEN
				clients_distance := ST_Distance(ST_GeometryN(central_clients_line_points,1),ST_GeometryN(central_clients_line_points,2));
			ELSE
				clients_distance := floor_width - 0.06;
			END IF;

			INSERT INTO gis.cw_floor(geom, layout_geom)
				values(
					ST_GeometryN(central_floor_points, pos_floor),
					new_floor_layout_geom
				);
			cont_clients := 1;

			FOR e IN 1..(ST_NumGeometries(central_clients_line_points))
			LOOP
				IF cont_clients > n_clients THEN EXIT; END IF;
				pos := (ST_NumGeometries(central_clients_line_points)) - e;
				IF (SELECT count(*) FROM gis.cw_client WHERE ST_Intersects(layout_geom, ST_GeometryN(central_clients_line_points, pos))) = 0
				THEN
					INSERT INTO gis.cw_client(geom, layout_geom)
						values(
							ST_GeometryN(central_clients_line_points, pos),
							ST_MakeEnvelope(
									ST_X(ST_GeometryN(central_clients_line_points, pos)) - clients_distance/2 + 0.03,  -- Coordenada x de la esquina inferior izquierda
									ST_Y(ST_GeometryN(central_clients_line_points, pos)) - floor_height + 0.36 ,   -- Coordenada y de la esquina inferior izquierda
									ST_X(ST_GeometryN(central_clients_line_points, pos)) + clients_distance/2 - 0.03,  -- Coordenada x de la esquina superior derecha
									ST_Y(ST_GeometryN(central_clients_line_points, pos)) + floor_height,   -- Coordenada y de la esquina superior derecha
									ST_SRID(ST_GeometryN(central_clients_line_points, pos)
								)
							)
						);
					cont_clients := cont_clients + 1;
				END IF;
			END LOOP;
		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

/*markdown
    CREACIÓN DE LA TABLA FLOOR
*/

CREATE TABLE gis.cw_floor(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	geom geometry(POINT, 3857) ,
    layout_geom geometry(POLYGON, 3857)  
);

CREATE UNIQUE INDEX idx_cw_floor_id_gis ON gis.cw_floor (id_gis);
CREATE INDEX idx_cw_floor_geom ON gis.cw_floor USING GIST(geom);
CREATE INDEX idx_cw_floor_layout_geom ON gis.cw_floor USING GIST(layout_geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION floor_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
    BEGIN
        UPDATE gis.cw_floor SET 
            id_gis = CONCAT('cw_floor_', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER floor_insert_trigger
	AFTER INSERT ON gis.cw_floor
	FOR EACH ROW EXECUTE PROCEDURE floor_insert_trigger();

/*markdown
    CREACIÓN DE LA TABLA CLIENT
*/

CREATE TABLE gis.cw_client(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	geom geometry(POINT, 3857),
	layout_geom GEOMETRY(POLYGON, 3857)
);

CREATE UNIQUE INDEX idx_cw_client_id_gis ON gis.cw_client (id_gis);
CREATE INDEX idx_cw_client_geom ON gis.cw_client USING GIST(geom);
CREATE INDEX idx_cw_client_layout_geom ON gis.cw_client USING GIST(layout_geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION client_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
    BEGIN
        UPDATE gis.cw_client SET 
            id_gis = CONCAT('cw_client_', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER client_insert_trigger
	AFTER INSERT ON gis.cw_client
	FOR EACH ROW EXECUTE PROCEDURE client_insert_trigger();

/*markdown
    CREACIÓN DE LA TABLA ROOM
*/

CREATE TABLE gis.cw_room(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	geom geometry(POINT, 3857),
	layout_geom GEOMETRY(POLYGON, 3857)
);

CREATE UNIQUE INDEX idx_cw_room_id_gis ON gis.cw_room (id_gis);
CREATE INDEX idx_cw_room_geom ON gis.cw_room USING GIST(geom);
CREATE INDEX idx_cw_room_layout_geom ON gis.cw_room USING GIST(layout_geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION room_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
    BEGIN
        UPDATE gis.cw_room SET 
            id_gis = CONCAT('cw_room', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER room_insert_trigger
	AFTER INSERT ON gis.cw_room
	FOR EACH ROW EXECUTE PROCEDURE room_insert_trigger();

/*markdown
    CREACIÓN DE LA TABLA optical_network_terminal
*/

CREATE TABLE gis.optical_network_terminal(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	geom geometry(POINT, 3857)
);

CREATE UNIQUE INDEX idx_optical_network_terminal_id_gis ON gis.optical_network_terminal (id_gis);
CREATE INDEX idx_optical_network_terminal_geom ON gis.optical_network_terminal USING GIST(geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION optical_network_terminal_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
		client_record RECORD;
		aux_client_line GEOMETRY;
		ont_line_points GEOMETRY;
		current_ont RECORD;
		cont INTEGER;
    BEGIN
		IF (SELECT count(*) FROM gis.cw_client WHERE ST_Intersects(layout_geom, NEW.geom)) > 0
		THEN		
			SELECT * INTO client_record FROM gis.cw_client WHERE ST_Intersects(layout_geom, NEW.geom);
			cont := 15;

			aux_client_line := ST_OffsetCurve(
					ST_MakeLine(
						(SELECT geom FROM ST_DUmpPoints(client_record.layout_geom) WHERE path[2] = 4),
						(SELECT geom FROM ST_DUmpPoints(client_record.layout_geom) WHERE path[2] = 5)
					),
					-0.04,
					'quad_segs=4 join=mitre mitre_limit=2.2'
				);

			ont_line_points := (SELECT ST_LineInterpolatePoints(aux_client_line, (1::FLOAT / (15+1)::FLOAT), true));

			FOR current_ont IN SELECT * FROM gis.optical_network_terminal WHERE ST_Intersects(client_record.layout_geom, geom)
			LOOP
				IF cont = 5 THEN RETURN NULL; END IF;
				UPDATE gis.optical_network_terminal SET 
					geom = ST_GeometryN(ont_line_points, cont),
					id_gis = CONCAT('optical_network_terminal_', current_ont.id::text)
				WHERE id = current_ont.id;
				cont = cont - 1;
			END LOOP;
			
			RETURN NEW;
		ELSE
			RETURN NULL;
		END IF;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER optical_network_terminal_insert_trigger
	AFTER INSERT ON gis.optical_network_terminal
	FOR EACH ROW EXECUTE PROCEDURE optical_network_terminal_insert_trigger();

/*markdown
	CREACIÓN DEL OBJETO RACK
*/

CREATE TABLE gis.rack(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	specification VARCHAR,
	geom GEOMETRY(POINT, 3857),
    layout_geom GEOMETRY(POLYGON, 3857),
	CONSTRAINT specification 
      FOREIGN KEY(specification) 
        REFERENCES template.rack_specs(model)
);

CREATE UNIQUE INDEX idx_rack_id_gis ON gis.rack (id_gis);
CREATE INDEX idx_rack_geom ON gis.rack USING GIST(geom);
CREATE INDEX idx_rack_layout_geom ON gis.rack USING GIST(layout_geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION rack_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
    BEGIN
        UPDATE gis.rack SET 
            id_gis = CONCAT('rack_', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER rack_insert_trigger
	AFTER INSERT ON gis.rack
	FOR EACH ROW EXECUTE PROCEDURE rack_insert_trigger();

CREATE TABLE gis.shelf(
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
    specification VARCHAR,
	geom GEOMETRY(POINT, 3857),
    layout_geom GEOMETRY(POLYGON, 3857),
	CONSTRAINT specification 
      FOREIGN KEY(specification) 
        REFERENCES template.shelf_specs(model)
);

CREATE UNIQUE INDEX idx_shelf_id_gis ON gis.shelf (id_gis);
CREATE INDEX idx_shelf_geom ON gis.shelf USING GIST(geom);
CREATE INDEX idx_shelf_layout_geom ON gis.shelf USING GIST(layout_geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION shelf_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
    BEGIN
        UPDATE gis.shelf SET 
            id_gis = CONCAT('shelf_', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER shelf_insert_trigger
	AFTER INSERT ON gis.shelf
	FOR EACH ROW EXECUTE PROCEDURE shelf_insert_trigger();

/* Markdown
	CREACIÓN DE TARJETAS DE RACK
*/

CREATE TABLE gis.card (
	id SERIAL PRIMARY KEY,
	id_gis VARCHAR,
	specification VARCHAR,
	geom  GEOMETRY(POINT, 3857),
	layout_geom GEOMETRY(POLYGON, 3857),
	CONSTRAINT specification 
      FOREIGN KEY(specification) 
        REFERENCES template.card_specs(model)
);

CREATE UNIQUE INDEX idx_card_id_gis ON gis.card (id_gis);
CREATE INDEX idx_geom_card ON gis.card USING GIST(geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION card_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
    BEGIN
        UPDATE gis.card SET 
            id_gis = CONCAT('card_', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER card_insert_trigger
	AFTER INSERT ON gis.card
	FOR EACH ROW EXECUTE PROCEDURE card_insert_trigger();

/* Markdown
	CREACIÓN DE PUERTOS DE RACK
*/

CREATE TABLE gis.port (
    id SERIAL PRIMARY KEY,
    id_gis VARCHAR,
    geom GEOMETRY(POINT, 3857)
);

CREATE UNIQUE INDEX idx_port_id_gis ON gis.port (id_gis);
CREATE INDEX idx_geom_port ON gis.port USING GIST(geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION pot_insert_trigger() RETURNS trigger AS
	$$
	DECLARE 
    BEGIN
        UPDATE gis.port SET 
            id_gis = CONCAT('port_', NEW.id::text)
        WHERE id = NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER pot_insert_trigger
	AFTER INSERT ON gis.port
	FOR EACH ROW EXECUTE PROCEDURE pot_insert_trigger();

/*markdown
	CONEXIÓN DE TODOS LOS OBJETOS
*/

CREATE OR REPLACE FUNCTION connect_objects(id_gis_object_1 VARCHAR, id_gis_object_2 VARCHAR) RETURNS void
AS
	$$
	DECLARE
		object_1 VARCHAR;
		object_2 VARCHAR;
		char_array TEXT[];
	BEGIN
		char_array := STRING_TO_ARRAY(id_gis_object_1, '_');
    	object_1 := char_array[1];

		FOR i IN 2..array_length(char_array, 1)-1
		LOOP
			object_1 := CONCAT(CONCAT(object_1, '_'), char_array[i]);
		END LOOP;

		char_array := STRING_TO_ARRAY(id_gis_object_2, '_');
    	object_2 := char_array[1];

		FOR i IN 2..array_length(char_array, 1)-1
		LOOP
			object_2 := CONCAT(CONCAT(object_2, '_'), char_array[i]);
		END LOOP;

		CASE
			WHEN object_1 = 'fo_cable' AND object_2 = 'fo_splice'
			THEN
				PERFORM connect_cable(id_gis_object_1, id_gis_object_2);
			WHEN object_1 = 'fo_splice' AND object_2 = 'fo_cable'
			THEN
				PERFORM connect_cable(id_gis_object_2, id_gis_object_1);
			WHEN object_1 = 'fo_fiber' AND object_2 = 'fo_fiber'
			THEN
				PERFORM connect_fiber(id_gis_object_1, id_gis_object_2);
			WHEN object_1 = 'fo_fiber' AND (object_2 = 'in_port' OR object_2 = 'out_port')
			THEN
				PERFORM connect_fiber_splitter_port(id_gis_object_1, id_gis_object_2);				
			WHEN (object_1 = 'in_port' OR object_1 = 'out_port') AND object_2 = 'fo_fiber'
			THEN
				PERFORM connect_fiber_splitter_port(id_gis_object_2, id_gis_object_1);
			WHEN object_1 = 'fo_splice' AND object_2 = 'cw_client'
			THEN
				PERFORM connect_splice_client(id_gis_object_1, id_gis_object_2);
			WHEN object_1 = 'cw_client' AND object_2 = 'fo_splice'
			THEN
				PERFORM connect_splice_client(id_gis_object_2, id_gis_object_1);
			WHEN object_1 = 'fo_splice' AND object_2 = 'fo_splice'
			THEN
				PERFORM connect_splice_splice(id_gis_object_2, id_gis_object_1);
			WHEN object_1 = 'fo_fiber' AND object_2 = 'optical_network_terminal'
			THEN
				PERFORM connect_fiber_ont(id_gis_object_1, id_gis_object_2);
			WHEN object_1 = 'optical_network_terminal' AND object_2 = 'fo_fiber'
			THEN
				PERFORM connect_fiber_ont(id_gis_object_2, id_gis_object_1);
			WHEN object_1 = 'fo_splice' AND object_2 = 'rack'
			THEN
				PERFORM connect_splice_rack(id_gis_object_1, id_gis_object_2);
			WHEN object_1 = 'rack' AND object_2 = 'fo_splice'
			THEN
				PERFORM connect_splice_rack(id_gis_object_2, id_gis_object_1);	
			WHEN object_1 = 'fo_fiber' AND object_2 = 'port'
			THEN
				PERFORM connect_fiber_building_port(id_gis_object_1, id_gis_object_2);
			WHEN object_1 = 'port' AND object_2 = 'fo_fiber'
			THEN
				PERFORM connect_fiber_building_port(id_gis_object_2, id_gis_object_1);	
			WHEN object_1 = 'fo_cable' AND object_2 = 'rack'
			THEN
				PERFORM connect_cable_rack(id_gis_object_1, id_gis_object_2);	
			WHEN object_1 = 'rack' AND object_2 = 'fo_cable'
			THEN
				PERFORM connect_cable_rack(id_gis_object_2, id_gis_object_1);					
			ELSE
		END CASE;
	END;
	$$
LANGUAGE plpgsql;

/*markdown
CONEXIÓN DE CABLES
*/
CREATE OR REPLACE FUNCTION connect_cable(id_gis_cable VARCHAR, id_gis_splice VARCHAR) RETURNS void
AS
	$$
	DECLARE
		cable_rec RECORD;
		splice_rec RECORD;
		cb_rec RECORD;
		current_face_line GEOMETRY;
		face_points GEOMETRY;
		intersection_point GEOMETRY;
		aux_line GEOMETRY;
		aux_guitar_line GEOMETRY;
		aux_line_guitar_splice GEOMETRY;
		aux_line_cable_guitar GEOMETRY;
		n_cables_crossing INTEGER;
		width FLOAT;
		current_distance FLOAT;
		dist FLOAT;
		guitar_center INTEGER;
		face_1 GEOMETRY;
		face_2 GEOMETRY;
		face_3 GEOMETRY;
		face_4 GEOMETRY;
		splice_face_1 GEOMETRY;
		splice_face_2 GEOMETRY;
		splice_face_3 GEOMETRY;
		splice_face_4 GEOMETRY;
		clossest_face GEOMETRY;
		clossest_splice_face GEOMETRY;
	BEGIN
		current_distance=0;
		width = 0.0125;
				
        -- Se obtienen los registros necesarios(cable, empalme y conectivity_box)
		SELECT * INTO cable_rec FROM gis.fo_cable WHERE id_gis=id_gis_cable;
		SELECT * INTO splice_rec FROM gis.fo_splice WHERE id_gis=id_gis_splice;	
		SELECT * INTO cb_rec FROM gis.cw_connectivity_box WHERE ST_Contains(gis.cw_connectivity_box.layout_geom, splice_rec.layout_geom);
		IF cb_rec IS NULL
		THEN
			SELECT * INTO cb_rec FROM gis.cw_building WHERE ST_Contains(layout_geom, splice_rec.layout_geom);
		END IF;
		
        -- Se genera la linea que conecta el cable cortado en la caja de coneciones con el empalme.
		intersection_point=ST_ClosestPoint(cable_rec.layout_geom, cb_rec.layout_geom);
		-- connection_line=ST_MakeLine(intersection_point, ST_Centroid(splice_rec.layout_geom));
		
		-- Se obtiene la cara del connectivity_box por el que entra ese cable
		face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=2));
		face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=3));
		face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=4));
		face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2]=5));

		SELECT INTO clossest_face
        CASE
            WHEN ST_Distance(face_1, intersection_point) <= LEAST(
                ST_Distance(face_2, intersection_point),
                ST_Distance(face_3, intersection_point),
                ST_Distance(face_4, intersection_point)
            ) THEN face_1
            WHEN ST_Distance(face_2, intersection_point) <= LEAST(
                ST_Distance(face_1, intersection_point),
                ST_Distance(face_3, intersection_point),
                ST_Distance(face_4, intersection_point)
            ) THEN face_2
            WHEN ST_Distance(face_3, intersection_point) <= LEAST(
                ST_Distance(face_1, intersection_point),
                ST_Distance(face_2, intersection_point),
                ST_Distance(face_4, intersection_point)
            ) THEN face_3
            ELSE face_4
        END;

		splice_face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=2));
		splice_face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=3));
		splice_face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=4));
		splice_face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2]=5));

		SELECT INTO clossest_splice_face
        CASE
            WHEN ST_Distance(ST_Centroid(splice_face_1), clossest_face) <= LEAST(
                ST_Distance(ST_Centroid(splice_face_2), clossest_face),
                ST_Distance(ST_Centroid(splice_face_3), clossest_face),
                ST_Distance(ST_Centroid(splice_face_4), clossest_face)
            ) THEN splice_face_1
            WHEN ST_Distance(ST_Centroid(splice_face_2), clossest_face) <= LEAST(
                ST_Distance(ST_Centroid(splice_face_1), clossest_face),
                ST_Distance(ST_Centroid(splice_face_3), clossest_face),
                ST_Distance(ST_Centroid(splice_face_4), clossest_face)
            ) THEN splice_face_2
            WHEN ST_Distance(ST_Centroid(splice_face_3), clossest_face) <= LEAST(
                ST_Distance(ST_Centroid(splice_face_1), clossest_face),
                ST_Distance(ST_Centroid(splice_face_2), clossest_face),
                ST_Distance(ST_Centroid(splice_face_4), clossest_face)
            ) THEN splice_face_3
            ELSE splice_face_4
        END;

		-- Por distancías a la cara por al que entra el cable se saca la cara del sheath_splice mas cercana a la cara del connectivity_box
		face_points = (SELECT ST_LineInterpolatePoints(clossest_splice_face, 0.07, true));

		-- Se obtienen la cantidad de cables que han apsado dentro de la connectivity_box para saber que ruta deberá coger el nuevo cable
		n_cables_crossing = (SELECT count(*) FROM gis.fo_cable WHERE ST_Length(ST_Intersection(layout_geom, cb_rec.layout_geom)) > 0.0005 AND ST_Intersects(layout_geom, clossest_face));
		
		IF n_cables_crossing < 20
		THEN
			-- Se genera el camino que seguirá el cable
			clossest_face = ST_OffsetCurve(clossest_face, -width * (n_cables_crossing + 1), 'quad_segs=4 join=mitre mitre_limit=2.2');

			-- Dependiendo de si es un calbde de entrada o salida se genera la liena de conecxión en una dirección u otra
			FOR i IN REVERSE 12..ST_NumGeometries(face_points)-12
			LOOP 
				IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(ST_GeometryN(face_points,i), layout_geom) < 0.0005)=0
				THEN
					IF ST_Distance(ST_EndPoint(cable_rec.layout_geom), cb_rec.layout_geom) < 0.0005
					THEN
						aux_line_guitar_splice = ST_ShortestLine(clossest_face, ST_GeometryN(face_points, i));
						aux_line_cable_guitar = ST_ShortestLine((cable_rec.layout_geom), clossest_face);
						UPDATE gis.fo_cable
							SET layout_geom=ST_LineMerge(
								ST_MakeLine(
									ST_MakeLine( 
										ST_MakeLine((cable_rec.layout_geom), aux_line_cable_guitar),
										ST_ShortestLine(aux_line_cable_guitar, aux_line_guitar_splice)
									),
								aux_line_guitar_splice
								)
							)
						WHERE id_gis=id_gis_cable;
						EXIT;
					ELSE	
						aux_line_guitar_splice = ST_ShortestLine(ST_GeometryN(face_points, i), clossest_face);
						aux_line_cable_guitar = ST_ShortestLine(clossest_face, (cable_rec.layout_geom));
						UPDATE gis.fo_cable
							SET layout_geom=ST_LineMerge(
								ST_MakeLine(
									aux_line_guitar_splice,
									ST_MakeLine( 
										ST_ShortestLine(aux_line_guitar_splice, aux_line_cable_guitar),
										ST_MakeLine(aux_line_cable_guitar, (cable_rec.layout_geom))
										
									)								
								)
							)
						WHERE id_gis=id_gis_cable;
						EXIT;
					END IF;
				END IF;
			END LOOP;
		END IF;

		SELECT * INTO cable_rec FROM gis.fo_cable WHERE id_gis=id_gis_cable;

		PERFORM update_fo_fiber_to_splice(cable_rec.id_gis, cable_rec.layout_geom);
	END;
	$$
LANGUAGE plpgsql;	

/*markdown
CONEXIÓN DE HILOS
*/
CREATE OR REPLACE FUNCTION connect_fiber(id_gis_fiber1 VARCHAR, id_gis_fiber2 VARCHAR) RETURNS void
AS
	$$
	DECLARE
		fiber_rec1 RECORD;
		fiber_rec2 RECORD;
		input_fiber_point GEOMETRY;
		output_fiber_point GEOMETRY;
		input_fiber RECORD;
		output_fiber RECORD;
		fo_splice_rec RECORD;
		n_fibers_crossed INTEGER;
		aux_offset_box GEOMETRY;
		face_1 GEOMETRY; 
		face_2 GEOMETRY;
		face_3 GEOMETRY;
		face_4 GEOMETRY;
		clossest_input_face GEOMETRY;
		clossest_output_face GEOMETRY;
		faces_intersection_point GEOMETRY;
		input_fiber_to_face GEOMETRY;
		input_face_to_intersection_point GEOMETRY;
		output_fiber_to_face GEOMETRY;
		output_face_to_intersection_point GEOMETRY;
		second_closest_output_face GEOMETRY;
		output_faces_intersection_point GEOMETRY;
		output_faces_line GEOMETRY;
		output_faces_line_to_face GEOMETRY;
		new_input_geom GEOMETRY;
		new_output_geom GEOMETRY;
		fiber_to_fiber_line GEOMETRY;
		width FLOAT;
	BEGIN
		-- Obtengo los records que voy a utilizar
		width = 0.0000375;
		SELECT * INTO fiber_rec1 FROM gis.fo_fiber WHERE id_gis=id_gis_fiber1;
		SELECT * INTO fiber_rec2 FROM gis.fo_fiber WHERE id_gis=id_gis_fiber2;
		SELECT * INTO fo_splice_rec FROM gis.fo_splice WHERE ST_Distance(layout_geom, fiber_rec1.layout_geom) < 0.0005;

		IF ST_Distance(ST_StartPoint(fiber_rec1.layout_geom), fo_splice_rec.layout_geom) < 0.05 AND ST_Distance(ST_EndPoint(fiber_rec2.layout_geom), fo_splice_rec.layout_geom) < 0.05
		THEN
			input_fiber_point = ST_EndPoint(fiber_rec2.layout_geom);
			output_fiber_point = ST_StartPoint(fiber_rec1.layout_geom);
			input_fiber = fiber_rec2;
			output_fiber = fiber_rec1;
		ELSIF ST_Distance(ST_StartPoint(fiber_rec2.layout_geom), fo_splice_rec.layout_geom) < 0.05 AND ST_Distance(ST_EndPoint(fiber_rec1.layout_geom), fo_splice_rec.layout_geom) < 0.05
		THEN
			input_fiber_point = ST_EndPoint(fiber_rec1.layout_geom);
			output_fiber_point = ST_StartPoint(fiber_rec2.layout_geom);
			input_fiber = fiber_rec1;
			output_fiber = fiber_rec2;
		END IF;

		-- Se obtienen la cantidad de fibras que han pasado dentro del empalme
		n_fibers_crossed = (SELECT count(*) FROM gis.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, fo_splice_rec.layout_geom)) > 0.00005);
		
		-- Dependiendo de las fibras que ya hayan entrado en el empalme utilizo una autovia diferente
		aux_offset_box = ST_Buffer(fo_splice_rec.layout_geom, width * ((n_fibers_crossed/2)+1), 'side=right join=mitre');
		
		-- Se inicializan las 4 caras de esta ruta auxiliar del offset
		face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=2));
		face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=3));
		face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=4));
		face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=5));

		-- Se obtiene la cara mas cercana al punto de entrada
		SELECT INTO clossest_input_face
        CASE
            WHEN ST_Distance(face_1, input_fiber_point) <= LEAST(
                ST_Distance(face_2, input_fiber_point),
                ST_Distance(face_3, input_fiber_point),
                ST_Distance(face_4, input_fiber_point)
            ) THEN face_1
            WHEN ST_Distance(face_2, input_fiber_point) <= LEAST(
                ST_Distance(face_1, input_fiber_point),
                ST_Distance(face_3, input_fiber_point),
                ST_Distance(face_4, input_fiber_point)
            ) THEN face_2
            WHEN ST_Distance(face_3, input_fiber_point) <= LEAST(
                ST_Distance(face_1, input_fiber_point),
                ST_Distance(face_2, input_fiber_point),
                ST_Distance(face_4, input_fiber_point)
            ) THEN face_3
            ELSE face_4
        END;

		-- Se obtiene la cara mas cercana al punto de salida
		SELECT INTO clossest_output_face
        CASE
            WHEN ST_Distance(face_1, output_fiber_point) <= LEAST(
                ST_Distance(face_2, output_fiber_point),
                ST_Distance(face_3, output_fiber_point),
                ST_Distance(face_4, output_fiber_point)
            ) THEN face_1
            WHEN ST_Distance(face_2, output_fiber_point) <= LEAST(
                ST_Distance(face_1, output_fiber_point),
                ST_Distance(face_3, output_fiber_point),
                ST_Distance(face_4, output_fiber_point)
            ) THEN face_2
            WHEN ST_Distance(face_3, output_fiber_point) <= LEAST(
                ST_Distance(face_1, output_fiber_point),
                ST_Distance(face_2, output_fiber_point),
                ST_Distance(face_4, output_fiber_point)
            ) THEN face_3
            ELSE face_4
        END;
		-- Si las caras se extiende la fibra de entrada hasta el putno de corte y se extiende la fibra de salira desde el punto de corte.
		
		-- Si las caras se extiende la fibra de entrada hasta el putno de corte y se extiende la fibra de salira desde el punto de corte.
		IF ST_Equals(clossest_output_face, clossest_input_face)
		THEN
			-- Continuación de la fibra hasta la cara.
			input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face);

			new_input_geom = ST_LineMerge(
					ST_MakeLine(input_fiber.layout_geom, ST_EndPoint(input_fiber_to_face))
				);

			UPDATE gis.fo_fiber
				SET layout_geom=new_input_geom,
				source=null, 
				target=null
			WHERE id_gis = input_fiber.id_gis;
			-- Continuación de la cara de salida hasta la fibra de salida.
			output_fiber_to_face := ST_ShortestLine(clossest_input_face ,output_fiber_point);

			fiber_to_fiber_line = ST_ShortestLine(ST_EndPoint(input_fiber_to_face), output_fiber_to_face);			

			new_output_geom = ST_LineMerge(
					ST_MakeLine(
						fiber_to_fiber_line,
						ST_MakeLine(output_fiber_to_face, output_fiber.layout_geom)
					)
				);
				
			UPDATE gis.fo_fiber
				SET layout_geom=new_output_geom,
				source=null, 
				target=null
			WHERE id_gis = output_fiber.id_gis;
		ELSIF ST_Intersects(clossest_output_face, clossest_input_face)
		THEN	
			-- Punto de corte de las caras.
			faces_intersection_point = ST_Intersection(clossest_output_face, clossest_input_face);
			-- Continuación de la fibra hasta la cara.
			input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face);
			-- Desde donde se cortan la fibra y la cara de entrada hasta el punto de corte de las caras.
			input_face_to_intersection_point = ST_ShortestLine(input_fiber_to_face ,faces_intersection_point);
			-- Se actualizza la geometría de la fibra

			new_input_geom = ST_LineMerge(
					ST_MakeLine(
						ST_MakeLine(input_fiber.layout_geom, input_fiber_to_face),
						input_face_to_intersection_point
					)
				);
				
			UPDATE gis.fo_fiber
				SET layout_geom=new_input_geom,
				source=null, 
				target=null
			WHERE id_gis = input_fiber.id_gis;

			-- Continuación de la cara de salida hasta la fibra de salida.
			output_fiber_to_face = ST_ShortestLine(clossest_output_face ,output_fiber_point);
			-- Continuación desde el punto de corte de las caras hasta el punto de corte de la fibra con la cara de salida.
			output_face_to_intersection_point = ST_ShortestLine(faces_intersection_point, output_fiber_to_face);

			new_output_geom = ST_LineMerge(
					ST_MakeLine(
						output_face_to_intersection_point,
						ST_MakeLine(output_fiber_to_face, output_fiber.layout_geom)
					)
				);
				
			UPDATE gis.fo_fiber
				SET layout_geom=new_output_geom,
				source=null, 
				target=null
			WHERE id_gis = output_fiber.id_gis;
		ELSE
			--  En el caso en el que no se corten, se cogerá la cara que no corte mas cercana al putno de salida y se recorrerá
			WITH distances AS (
				SELECT
					unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
					ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), output_fiber_point) AS distance
			)
			SELECT 
				face
			INTO 
				second_closest_output_face
			FROM (
				SELECT 
					face,
					ROW_NUMBER() OVER (ORDER BY distance) AS rn
				FROM 
					distances
			) ranked_distances
			WHERE rn = 2;

			-- FIBRA DE ENTRADA
			-- Punto de corte de las caras.
			faces_intersection_point = ST_Intersection(second_closest_output_face, clossest_input_face);
			-- Continuación de la fibra hasta la cara.
			input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face);
			-- Desde donde se cortan la fibra y la cara de entrada hasta el punto de corte de las caras.
			input_face_to_intersection_point = ST_ShortestLine(input_fiber_to_face ,faces_intersection_point);
			-- Se actualizza la geometría de la fibra

			new_input_geom = ST_LineMerge(
					ST_MakeLine(
						ST_MakeLine(input_fiber.layout_geom, input_fiber_to_face),
						input_face_to_intersection_point
					)
				);

			UPDATE gis.fo_fiber
				SET layout_geom=new_input_geom,
				source=null, 
				target=null
			WHERE id_gis = input_fiber.id_gis;

			-- FIBRA DE SALIDA
			-- Punto de corte de cara mas corta con segunda cara mas corta
			output_faces_intersection_point = ST_Intersection(second_closest_output_face, clossest_output_face);
			-- Se crea la linea entre el punto de interseccion real y en el que interseccionan las caras outer
			output_faces_line = ST_MakeLine(faces_intersection_point, output_faces_intersection_point);
			-- Continuación de la cara de salida hasta la fibra de salida.
			output_fiber_to_face = ST_ShortestLine(clossest_output_face ,output_fiber_point);
			-- Se crea la linea entre la linea de output faces line y la linea del fiber to face
			output_faces_line_to_face =  ST_ShortestLine(output_faces_line ,output_fiber_to_face);
			-- Continuación desde el punto de corte de las caras hasta el punto de corte de la fibra con la cara de salida.
			output_face_to_intersection_point = ST_ShortestLine(output_faces_line, output_fiber_to_face);

			new_output_geom=ST_LineMerge(
					ST_MakeLine(
						ST_MakeLine(
							ST_MakeLine(output_faces_line,output_faces_line_to_face),
							output_fiber_to_face
						),
						output_fiber.layout_geom
					)
				);

			UPDATE gis.fo_fiber
				SET layout_geom=new_output_geom,
				source=null, 
				target=null
			WHERE id_gis = output_fiber.id_gis;
		END IF;
	END;
	$$
LANGUAGE plpgsql;

/*markdown
CONEXIÓN Hilo-port
*/

CREATE OR REPLACE FUNCTION connect_fiber_splitter_port(id_gis_fiber VARCHAR, id_gis_port VARCHAR) RETURNS void
AS
	$$
	DECLARE
        fiber_rec RECORD;
        fo_splice_rec RECORD;
        port_rec RECORD;
        input_fiber RECORD;
        output_fiber RECORD;
        face_1 GEOMETRY;
        face_2 GEOMETRY;
        face_3 GEOMETRY;
        face_4 GEOMETRY;
        clossest_input_face GEOMETRY;
        clossest_output_face GEOMETRY;
        input_fiber_to_face GEOMETRY;
		output_fiber_point GEOMETRY;
		input_fiber_point GEOMETRY;
		new_input_geom GEOMETRY;
        faces_intersection_point GEOMETRY;
        second_closest_input_face GEOMETRY;
        second_closest_output_face GEOMETRY;
		input_faces_intersection_point GEOMETRY;
		output_fiber_to_face GEOMETRY;
		new_output_geom GEOMETRY;
		output_faces_intersection_point GEOMETRY;
        n_guitar_lines INTEGER;
        width FLOAT;
    BEGIN
        width = 0.0000375;
        n_guitar_lines=1000;

        -- Records que voy a utilziar
        SELECT * INTO fiber_rec FROM gis.fo_fiber WHERE id_gis=id_gis_fiber;

        IF (SELECT count(*) FROM gis.in_port WHERE id_gis = id_gis_port) > 0
        THEN
            SELECT * INTO port_rec FROM gis.in_port WHERE id_gis=id_gis_port;
        ELSE
            SELECT * INTO port_rec FROM gis.out_port WHERE id_gis=id_gis_port;
        END IF;
		
		SELECT * INTO fo_splice_rec FROM gis.fo_splice WHERE ST_Intersects(layout_geom, port_rec.geom);

        -- Se obtiene si la fibra es de entrada o salida
        IF ST_Distance(ST_StartPoint(fiber_rec.layout_geom), fo_splice_rec.layout_geom) < 0.005 
		THEN
			output_fiber = fiber_rec;
            output_fiber_point = ST_StartPoint(fiber_rec.layout_geom);
		ELSE
			input_fiber = fiber_rec;
            input_fiber_point = ST_EndPoint(fiber_rec.layout_geom);
		END IF;

        -- Se inicializan las 4 caras de esta ruta auxiliar del offset
		face_1 = ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=1), 
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2));
		face_2 = ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2), 
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3));
		face_3 = ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3), 
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4));
		face_4 = ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4), 
            (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=5));

        -- Se obtiene el carril por el que irá la conexión
        FOR i IN 0..1000
        LOOP           
			-- INSERT INTO gis.test(geom) VALUES(ST_OffsetCurve(face_4, -width * (n_guitar_lines + i), 'quad_segs=4 join=mitre mitre_limit=2.2'));
            IF (ST_Distance(port_rec.geom, ST_OffsetCurve(face_2, -width * (n_guitar_lines + i), 'quad_segs=4 join=round')) < 0.000025)
            THEN
                n_guitar_lines = n_guitar_lines + i;
                EXIT;
            END IF;
        END LOOP;

        IF input_fiber_point IS NOT NULL
        THEN
            -- Se obtiene la cara mas cercana al punto de entrada
            SELECT INTO clossest_input_face
            CASE
                WHEN ST_Distance(face_1, input_fiber_point) <= LEAST(
                    ST_Distance(face_2, input_fiber_point),
                    ST_Distance(face_3, input_fiber_point),
                    ST_Distance(face_4, input_fiber_point)
                ) THEN face_1
                WHEN ST_Distance(face_2, input_fiber_point) <= LEAST(
                    ST_Distance(face_1, input_fiber_point),
                    ST_Distance(face_3, input_fiber_point),
                    ST_Distance(face_4, input_fiber_point)
                ) THEN face_2
                WHEN ST_Distance(face_3, input_fiber_point) <= LEAST(
                    ST_Distance(face_1, input_fiber_point),
                    ST_Distance(face_2, input_fiber_point),
                    ST_Distance(face_4, input_fiber_point)
                ) THEN face_3
                ELSE face_4
            END;
        ELSE
                -- Se obtiene la cara mas cercana al punto de salida
            SELECT INTO clossest_output_face
            CASE
                WHEN ST_Distance(face_1, output_fiber_point) <= LEAST(
                    ST_Distance(face_2, output_fiber_point),
                    ST_Distance(face_3, output_fiber_point),
                    ST_Distance(face_4, output_fiber_point)
                ) THEN face_1
                WHEN ST_Distance(face_2, output_fiber_point) <= LEAST(
                    ST_Distance(face_1, output_fiber_point),
                    ST_Distance(face_3, output_fiber_point),
                    ST_Distance(face_4, output_fiber_point)
                ) THEN face_2
                WHEN ST_Distance(face_3, output_fiber_point) <= LEAST(
                    ST_Distance(face_1, output_fiber_point),
                    ST_Distance(face_2, output_fiber_point),
                    ST_Distance(face_4, output_fiber_point)
                ) THEN face_3
                ELSE face_4
            END;
        END IF;

        face_2 =  ST_OffsetCurve(face_2, -width * n_guitar_lines, 'quad_segs=4 join=round');

        IF clossest_input_face IS NOT NULL      
        THEN      
            clossest_input_face =  ST_OffsetCurve(clossest_input_face, -width * n_guitar_lines, 'quad_segs=4 join=round');
            IF clossest_input_face = face_2
            THEN
                -- Se obtiene el camino mas corto de la fibra a la cara
                input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face);

                -- Se updatea la geometria para que se conecte con el port.
                new_input_geom=ST_LineMerge(
                        ST_MakeLine(
                            ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
                            port_rec.geom
                        )
                    );
            ELSIF (ST_Intersects(clossest_input_face, face_2))
            THEN           
                -- Caso en el que se cortan las caras
                -- Se obtiene el punto de corte
                faces_intersection_point = ST_Intersection(clossest_input_face, face_2);

                -- Se obtiene el camino mas corto de la fibra a la cara
                input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face);

                -- Se crea la nueva geometría
                new_input_geom=ST_LineMerge(
                        ST_MakeLine(
                            ST_MakeLine(
                                ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
                                faces_intersection_point
                            ),
                            port_rec.geom
                        )
                    );
            ELSE
                -- Caso en el que no se cortan las caras
                WITH distances AS (
				SELECT
					unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
					ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), input_fiber_point) AS distance
                )
                SELECT 
                    face
                INTO 
                    second_closest_input_face
                FROM (
                    SELECT 
                        face,
                        ROW_NUMBER() OVER (ORDER BY distance) AS rn
                    FROM 
                        distances
                ) ranked_distances
                WHERE rn = 2;

				second_closest_input_face =  ST_OffsetCurve(second_closest_input_face, -width * n_guitar_lines, 'quad_segs=4 join=round');
				
				-- Se obtiene el camino mas corto de la fibra a la cara
				input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face);

				--  Punto de corte de la cara mas cercana con la segunda mas cercana
				input_faces_intersection_point = ST_Intersection(second_closest_input_face, clossest_input_face);

				-- Punto de corte de la segunda cara mas cercana con la cara del port
				faces_intersection_point = ST_Intersection(second_closest_input_face, face_2);

				-- Se crea la nueva geometría uniendo los puntos anteriores
				new_input_geom=ST_LineMerge(
						ST_MakeLine(
							ST_MakeLine(
								ST_MakeLine(
									ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
									input_faces_intersection_point
								),
								faces_intersection_point
							),
							port_rec.geom
						)
					);
            END IF;

            -- Se actualiza la fibra con la nueva geometría
            UPDATE gis.fo_fiber
                SET layout_geom=new_input_geom,
                source=null, 
                target=null
            WHERE id_gis = input_fiber.id_gis;
        ELSIF clossest_output_face IS NOT NULL
        THEN
            clossest_output_face =  ST_OffsetCurve(clossest_output_face, -width * n_guitar_lines, 'quad_segs=4 join=round');
            IF clossest_output_face = face_2
            THEN
                -- Se obtiene el camino mas corto de la fibra a la cara
                output_fiber_to_face = ST_ShortestLine(clossest_output_face, output_fiber_point);

                -- Se updatea la geometria para que se conecte con el port.
                new_output_geom=ST_LineMerge(
                        ST_MakeLine(
                            port_rec.geom,
                            ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                            
                        )
                    );
            ELSIF (ST_Intersects(clossest_output_face, face_2))
            THEN 
                -- Caso en el que se cortan las caras
                -- Se obtiene el punto de corte
                faces_intersection_point = ST_Intersection(clossest_output_face, face_2);

                -- Se obtiene el camino mas corto de la fibra a la cara
                output_fiber_to_face = ST_ShortestLine(clossest_output_face, output_fiber_point);

                -- Se crea la nueva geometría
                new_output_geom=ST_LineMerge(
                    ST_MakeLine(
                        port_rec.geom,
                        ST_MakeLine(
                            faces_intersection_point,
                            ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                               
                        )                            
                    )
                );
            ELSE
                -- Caso en el que no se cortan las caras
                WITH distances AS (
				SELECT
					unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
					ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), output_fiber_point) AS distance
                )
                SELECT 
                    face
                INTO 
                    second_closest_output_face
                FROM (
                    SELECT 
                        face,
                        ROW_NUMBER() OVER (ORDER BY distance) AS rn
                    FROM 
                        distances
                ) ranked_distances
                WHERE rn = 2;

                second_closest_output_face =  ST_OffsetCurve(second_closest_output_face, -width * n_guitar_lines, 'quad_segs=4 join=round');

                -- Se obtiene el camino mas corto de la fibra a la cara
                output_fiber_to_face = ST_ShortestLine(clossest_output_face, output_fiber_point);

                --  Punto de corte de la cara mas cercana con la segunda mas cercana
                output_faces_intersection_point = ST_Intersection(second_closest_output_face, clossest_output_face);

                -- Punto de corte de la segunda cara mas cercana con la cara del port
                faces_intersection_point = ST_Intersection(second_closest_output_face, face_2);

                -- Se crea la nueva geometría uniendo los puntos anteriores
                new_output_geom=ST_LineMerge(
                        ST_MakeLine(
                            port_rec.geom,
                            ST_MakeLine(
                                faces_intersection_point,
                                ST_MakeLine(
                                    output_faces_intersection_point,
                                    ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                                
                                )                            
                            )                       
                        )
                    );
            END IF;

            -- Se actualiza la fibra con la nueva geometría
            UPDATE gis.fo_fiber
                SET layout_geom=new_output_geom,
                source=null, 
                target=null
            WHERE id_gis = output_fiber.id_gis;
        END IF;
		-- PERFORM update_fiber_topology();
    END;
    $$
LANGUAGE plpgsql;	

-- Funcion para almacenar los detalles de conectividad de una conectivity_box
CREATE OR REPLACE FUNCTION store_cb_conections(cb_record RECORD) RETURNS void AS
	$$
	DECLARE
		current_cable_record RECORD;
		current_splice_record RECORD;
		current_fiber_record RECORD;
		current_connected_fiber_record RECORD;
		current_fiber_node RECORD;
		current_input_fiber RECORD;
		current_output_fiber RECORD;
	BEGIN
		-- Crear tablas temporales si no existen
		CREATE TEMP TABLE IF NOT EXISTS cable_connectivity (
			id SERIAL PRIMARY KEY,
			id_gis_cable VARCHAR,
			id_gis_splice VARCHAR
		);

		CREATE TEMP TABLE IF NOT EXISTS fiber_connectivity (
			id SERIAL PRIMARY KEY,
			id_gis_fiber_1 VARCHAR,
			id_gis_fiber_2 VARCHAR,
			id_splice VARCHAR
		);

		CREATE TEMP TABLE IF NOT EXISTS fiber_port_connectivity (
			id SERIAL PRIMARY KEY,
			id_gis_fiber_1 VARCHAR,
			id_gis_port VARCHAR,
			id_splice VARCHAR
		);      

		-- Obtener cables conectados a la caja de conectividad
		FOR current_cable_record IN 
			SELECT * FROM gis.fo_cable WHERE ST_Distance(layout_geom, cb_record.layout_geom) < 0.00003
		LOOP
			-- Obtener empalmes dentro de cada cable
			FOR current_splice_record IN 
				SELECT * FROM gis.fo_splice WHERE ST_Distance(layout_geom, current_cable_record.layout_geom) < 0.00003
			LOOP
				-- Obtener nodos de fibra dentro de los empalmes
				FOR current_fiber_node IN 
					SELECT * FROM gis.fo_fiber_vertices_pgr WHERE ST_Contains(current_splice_record.layout_geom, the_geom) AND NOT ST_DWithin(the_geom, ST_Boundary(current_splice_record.layout_geom), 1e-9)
				LOOP
					SELECT * INTO current_input_fiber FROM gis.fo_fiber WHERE target = current_fiber_node.id;
					SELECT * INTO current_output_fiber FROM gis.fo_fiber WHERE  source = current_fiber_node.id;
					-- Conexiones fibra-port
					IF (SELECT count(*) FROM gis.in_port WHERE ST_Distance(geom, current_fiber_node.the_geom) < 0.000003) > 0 
					THEN
						IF (SELECT count(*) FROM fiber_port_connectivity WHERE id_gis_fiber_1 = current_input_fiber.id_gis) > 0 
						THEN
							CONTINUE;
						END IF;

						INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port, id_splice) VALUES (
							current_input_fiber.id_gis, 
							(SELECT id_gis FROM gis.in_port WHERE ST_Distance(geom, current_fiber_node.the_geom) < 0.000003),
							current_splice_record.id_gis
						);
					ELSIF (SELECT count(*) FROM gis.out_port WHERE ST_Distance(geom, current_fiber_node.the_geom) < 0.000003) > 0 
					THEN
						IF (SELECT count(*) FROM fiber_port_connectivity WHERE id_gis_fiber_1 = current_output_fiber.id_gis) > 0 
						THEN
							CONTINUE;
						END IF;

						INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port, id_splice) VALUES (
							current_output_fiber.id_gis, 
							(SELECT id_gis FROM gis.out_port WHERE ST_Distance(geom, current_fiber_node.the_geom) < 0.000003),
							current_splice_record.id_gis
						);
					ELSE
						-- Conexiones fibra-fibra
						IF (SELECT count(*) FROM fiber_connectivity WHERE id_gis_fiber_1 = current_output_fiber.id_gis) > 0 
							OR (SELECT count(*) FROM fiber_connectivity WHERE id_gis_fiber_2 = current_input_fiber.id_gis) > 0
						THEN
							CONTINUE;
						END IF;

						INSERT INTO fiber_connectivity(id_gis_fiber_1, id_gis_fiber_2, id_splice) VALUES (
							current_output_fiber.id_gis,
							current_input_fiber.id_gis,
							current_splice_record.id_gis
						);
					END IF;
				END LOOP;
				
				-- Conexiones de cable con empalme
				IF ST_Distance(current_splice_record.layout_geom, current_cable_record.layout_geom) < 0.00003 THEN
					INSERT INTO cable_connectivity(id_gis_cable, id_gis_splice) VALUES (current_cable_record.id_gis, current_splice_record.id_gis);
				END IF;

				UPDATE gis.fo_fiber SET 
					layout_geom = ST_Difference(layout_geom, current_splice_record.layout_geom),
					source=null, 
					target=null
					WHERE ST_Intersects(layout_geom,current_splice_record.layout_geom);
			END LOOP;
		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_linestrings(
		current_geom GEOMETRY, 
		old_geometry GEOMETRY, 
		new_geometry GEOMETRY
	) RETURNS GEOMETRY
	AS
	$$
	DECLARE
		final_geometry GEOMETRY;
		num_points INTEGER;
	BEGIN
		num_points := (SELECT count(*) FROM ST_DumpPoints(current_geom));
		
		CASE
			-- Caso en el que la geometría toca en el punto inicial.
			WHEN ST_Distance(ST_StartPoint(current_geom), old_geometry) < 0.00003 
			THEN
				IF num_points > 2 
				THEN
					final_geometry := ST_SetPoint(current_geom, 0, new_geometry);
				ELSE
					final_geometry := ST_MakeLine(new_geometry, ST_EndPoint(current_geom));
				END IF;
			-- Caso en el que la geometría toca en el punto final.
			WHEN ST_Distance(ST_EndPoint(current_geom), old_geometry) < 0.00003 
			THEN
				IF num_points > 2 
				THEN
					final_geometry := ST_SetPoint(current_geom, num_points - 1, new_geometry);
				ELSE
					final_geometry := ST_MakeLine(ST_StartPoint(current_geom), new_geometry);
				END IF;
			-- Caso en el que la geometría tiene varios puntos y el punto inicial o final no es el ultimo.
			ELSE
				-- Para manejar el caso en el que no toca en el punto inicial ni final, pero es una línea con varios puntos.
				FOR i IN 1..(num_points - 1) 
				LOOP
					IF ST_Distance(ST_PointN(current_geom, i), old_geometry) < 0.00003 
					THEN
						final_geometry := ST_SetPoint(current_geom, i - 1, new_geometry);
						EXIT;
					END IF;
				END LOOP;           
		END CASE;
		
		RETURN final_geometry;
	END;
	$$
LANGUAGE plpgsql;

-- Funcion para procesar la informaciónd e conectividad almacenada
CREATE OR REPLACE FUNCTION update_stored_conections() RETURNS void AS
	$$
	DECLARE
		input_fiber_record RECORD;
		output_fiber_record RECORD;
		fo_splice_rec RECORD;
		fiber_rec RECORD;
		port_rec RECORD;
		input_fiber_point GEOMETRY;
		output_fiber_point GEOMETRY;
		face_1 GEOMETRY;
		face_2 GEOMETRY;
		face_3 GEOMETRY;
		face_4 GEOMETRY;
		clossest_input_face GEOMETRY;
		clossest_output_face GEOMETRY;
		clossest_input_face_aux GEOMETRY;
		clossest_output_face_aux GEOMETRY;
		face_2_aux GEOMETRY;
		input_fiber_to_face GEOMETRY;
		new_input_geom GEOMETRY;
		output_fiber_to_face GEOMETRY;
		fiber_to_fiber_line GEOMETRY;
		new_output_geom GEOMETRY;
		faces_intersection_point GEOMETRY;
		input_face_to_intersection_point GEOMETRY;
		output_face_to_intersection_point GEOMETRY;
		second_closest_output_face GEOMETRY;
		second_closest_input_face GEOMETRY;
		output_faces_intersection_point GEOMETRY;
		output_faces_line GEOMETRY;
		output_faces_line_to_face GEOMETRY;
		input_faces_intersection_point GEOMETRY;
		current_cable VARCHAR;
		current_splice VARCHAR;
		width FLOAT;
		cont INTEGER;
		n_guitar_lines INTEGER;
		current_fiber_connectivity_record RECORD;
		current_fiber_port_connectivity_record RECORD;
	BEGIN
		width = 0.0000375;
		cont = 1;
		n_guitar_lines=1000;

		FOR current_fiber_connectivity_record IN SELECT * FROM fiber_connectivity ORDER BY id_gis_fiber_2, id_splice
		LOOP
			SELECT * INTO input_fiber_record FROM gis.fo_fiber WHERE id_gis = current_fiber_connectivity_record.id_gis_fiber_2;
			SELECT * INTO output_fiber_record FROM gis.fo_fiber WHERE id_gis = current_fiber_connectivity_record.id_gis_fiber_1;			
			input_fiber_point = ST_EndPoint(input_fiber_record.layout_geom);
			output_fiber_point = ST_StartPoint(output_fiber_record.layout_geom);
			SELECT * INTO fo_splice_rec FROM gis.fo_splice WHERE id_gis = current_fiber_connectivity_record.id_splice;

			IF current_splice IS NULL OR current_splice <> fo_splice_rec.id_gis
			THEN
				current_splice = fo_splice_rec.id_gis;
				cont = 1;
				face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2));
				face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3));
				face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4));
				face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=5));
			END IF;

			IF current_cable IS NULL OR current_cable <> input_fiber_record.id_cable
			THEN
				current_cable = input_fiber_record.id_cable;

				-- Se obtiene la cara mas cercana al punto de entrada
				SELECT INTO clossest_input_face
				CASE
					WHEN ST_Distance(face_1, input_fiber_point) <= LEAST(
						ST_Distance(face_2, input_fiber_point),
						ST_Distance(face_3, input_fiber_point),
						ST_Distance(face_4, input_fiber_point)
					) THEN face_1
					WHEN ST_Distance(face_2, input_fiber_point) <= LEAST(
						ST_Distance(face_1, input_fiber_point),
						ST_Distance(face_3, input_fiber_point),
						ST_Distance(face_4, input_fiber_point)
					) THEN face_2
					WHEN ST_Distance(face_3, input_fiber_point) <= LEAST(
						ST_Distance(face_1, input_fiber_point),
						ST_Distance(face_2, input_fiber_point),
						ST_Distance(face_4, input_fiber_point)
					) THEN face_3
					ELSE face_4
				END;

				-- Se obtiene la cara mas cercana al punto de salida
				SELECT INTO clossest_output_face
				CASE
					WHEN ST_Distance(face_1, output_fiber_point) <= LEAST(
						ST_Distance(face_2, output_fiber_point),
						ST_Distance(face_3, output_fiber_point),
						ST_Distance(face_4, output_fiber_point)
					) THEN face_1
					WHEN ST_Distance(face_2, output_fiber_point) <= LEAST(
						ST_Distance(face_1, output_fiber_point),
						ST_Distance(face_3, output_fiber_point),
						ST_Distance(face_4, output_fiber_point)
					) THEN face_2
					WHEN ST_Distance(face_3, output_fiber_point) <= LEAST(
						ST_Distance(face_1, output_fiber_point),
						ST_Distance(face_2, output_fiber_point),
						ST_Distance(face_4, output_fiber_point)
					) THEN face_3
					ELSE face_4
				END;
			END IF;
		
		clossest_input_face_aux = ST_OffsetCurve(clossest_input_face, -width * cont, 'quad_segs=4 join=round');
		clossest_output_face_aux = ST_OffsetCurve(clossest_output_face, -width * cont, 'quad_segs=4 join=round');

		IF ST_Equals(clossest_input_face_aux, clossest_output_face_aux)
		THEN
			-- Continuación de la fibra hasta la cara.
			input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face_aux);

			new_input_geom = ST_LineMerge(
					ST_MakeLine(input_fiber_record.layout_geom, ST_EndPoint(input_fiber_to_face))
				);

			-- Continuación de la cara de salida hasta la fibra de salida.
			output_fiber_to_face := ST_ShortestLine(clossest_output_face_aux ,output_fiber_point);

			fiber_to_fiber_line = ST_ShortestLine(ST_EndPoint(input_fiber_to_face), output_fiber_to_face);			

			new_output_geom = ST_LineMerge(
					ST_MakeLine(
						fiber_to_fiber_line,
						ST_MakeLine(output_fiber_to_face, output_fiber_record.layout_geom)
					)
				);

			ELSIF ST_Intersects(clossest_input_face_aux, clossest_output_face_aux)
			THEN	
				-- Punto de corte de las caras.
				faces_intersection_point = ST_Intersection(clossest_input_face_aux, clossest_output_face_aux);
				-- Continuación de la fibra hasta la cara.
				input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face_aux);
				-- Desde donde se cortan la fibra y la cara de entrada hasta el punto de corte de las caras.
				input_face_to_intersection_point = ST_ShortestLine(input_fiber_to_face ,faces_intersection_point);
				-- Se actualizza la geometría de la fibra

				new_input_geom = ST_LineMerge(
						ST_MakeLine(
							ST_MakeLine(input_fiber_record.layout_geom, input_fiber_to_face),
							input_face_to_intersection_point
						)
					);

				-- Continuación de la cara de salida hasta la fibra de salida.
				output_fiber_to_face = ST_ShortestLine(clossest_output_face_aux ,output_fiber_point);
				-- Continuación desde el punto de corte de las caras hasta el punto de corte de la fibra con la cara de salida.
				output_face_to_intersection_point = ST_ShortestLine(faces_intersection_point, output_fiber_to_face);

				new_output_geom = ST_LineMerge(
						ST_MakeLine(
							output_face_to_intersection_point,
							ST_MakeLine(output_fiber_to_face, output_fiber_record.layout_geom)
						)
					);
			ELSE
				--  En el caso en el que no se corten, se cogerá la cara que no corte mas cercana al putno de salida y se recorrerá
				WITH distances AS (
					SELECT
						unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
						ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), output_fiber_point) AS distance
				)
				SELECT 
					face
				INTO 
					second_closest_output_face
				FROM (
					SELECT 
						face,
						ROW_NUMBER() OVER (ORDER BY distance) AS rn
					FROM 
						distances
				) ranked_distances
				WHERE rn = 2;

				second_closest_output_face =  ST_OffsetCurve(second_closest_output_face, -width * cont, 'quad_segs=4 join=round');

				-- FIBRA DE ENTRADA
				-- Punto de corte de las caras.
				faces_intersection_point = ST_Intersection(second_closest_output_face, clossest_input_face_aux);
				-- Continuación de la fibra hasta la cara.
				input_fiber_to_face = ST_ShortestLine(input_fiber_point, clossest_input_face_aux);
				-- Desde donde se cortan la fibra y la cara de entrada hasta el punto de corte de las caras.
				input_face_to_intersection_point = ST_ShortestLine(input_fiber_to_face, faces_intersection_point);
				-- Se actualizza la geometría de la fibra

				new_input_geom = ST_LineMerge(
						ST_MakeLine(
							ST_MakeLine(input_fiber_record.layout_geom, input_fiber_to_face),
							input_face_to_intersection_point
						)
					);

				-- FIBRA DE SALIDA
				-- Punto de corte de cara mas corta con segunda cara mas corta
				output_faces_intersection_point = ST_ClosestPoint(second_closest_output_face, clossest_output_face_aux);
				-- Se crea la linea entre el punto de interseccion real y en el que interseccionan las caras outer
				output_faces_line = ST_MakeLine(faces_intersection_point, output_faces_intersection_point);
				-- Continuación de la cara de salida hasta la fibra de salida.
				output_fiber_to_face = ST_ShortestLine(clossest_output_face_aux ,output_fiber_point);
				-- Se crea la linea entre la linea de output faces line y la linea del fiber to face
				output_faces_line_to_face =  ST_ShortestLine(output_faces_line ,output_fiber_to_face);
				-- Continuación desde el punto de corte de las caras hasta el punto de corte de la fibra con la cara de salida.
				output_face_to_intersection_point = ST_ShortestLine(output_faces_line, output_fiber_to_face);

				new_output_geom=ST_LineMerge(
						ST_MakeLine(
							ST_MakeLine(
								ST_MakeLine(output_faces_line,output_faces_line_to_face),
								output_fiber_to_face
							),
							output_fiber_record.layout_geom
						)
					);
			END IF;
			
			UPDATE gis.fo_fiber
				SET layout_geom=new_input_geom,
				source=null, 
				target=null
			WHERE id_gis = input_fiber_record.id_gis;
			
			UPDATE gis.fo_fiber
				SET layout_geom=new_output_geom,
				source=null, 
				target=null
			WHERE id_gis = output_fiber_record.id_gis;
			cont = cont + 1;
		END LOOP;		

		current_splice = null;
		cont = 1;

		-- Se actualizan las conexiones de fibra-port
		FOR current_fiber_port_connectivity_record IN SELECT * FROM fiber_port_connectivity ORDER BY id_gis_fiber_1, id_splice
		LOOP
			clossest_input_face = NULL;
			clossest_output_face = NULL;
			output_fiber_point = NULL;
			input_fiber_point = NULL;

			SELECT * INTO fiber_rec FROM gis.fo_fiber WHERE id_gis = current_fiber_port_connectivity_record.id_gis_fiber_1;
			SELECT * INTO fo_splice_rec FROM gis.fo_splice WHERE id_gis = current_fiber_port_connectivity_record.id_splice;

			IF ST_Distance(ST_StartPoint(fiber_rec.layout_geom), fo_splice_rec.layout_geom) < 0.005 
			THEN
				output_fiber_point = ST_StartPoint(fiber_rec.layout_geom);
			ELSE
				input_fiber_point = ST_EndPoint(fiber_rec.layout_geom);
			END IF;

			IF (SELECT count(*) FROM gis.in_port WHERE id_gis = current_fiber_port_connectivity_record.id_gis_port) > 0
			THEN
				SELECT * INTO port_rec FROM gis.in_port WHERE id_gis = current_fiber_port_connectivity_record.id_gis_port;
			ELSE
				SELECT * INTO port_rec FROM gis.out_port WHERE id_gis = current_fiber_port_connectivity_record.id_gis_port;
			END IF;

			IF current_splice IS NULL OR current_splice <> fo_splice_rec.id_gis
			THEN
				current_splice = fo_splice_rec.id_gis;
				cont = 1;

				face_1 = ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2));
				face_2 = ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3));
				face_3 = ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4));
				face_4 = ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=5));
			END IF;

			IF input_fiber_point IS NOT NULL
			THEN
				-- Se obtiene la cara mas cercana al punto de entrada
				SELECT INTO clossest_input_face
				CASE
					WHEN ST_Distance(face_1, input_fiber_point) <= LEAST(
						ST_Distance(face_2, input_fiber_point),
						ST_Distance(face_3, input_fiber_point),
						ST_Distance(face_4, input_fiber_point)
					) THEN face_1
					WHEN ST_Distance(face_2, input_fiber_point) <= LEAST(
						ST_Distance(face_1, input_fiber_point),
						ST_Distance(face_3, input_fiber_point),
						ST_Distance(face_4, input_fiber_point)
					) THEN face_2
					WHEN ST_Distance(face_3, input_fiber_point) <= LEAST(
						ST_Distance(face_1, input_fiber_point),
						ST_Distance(face_2, input_fiber_point),
						ST_Distance(face_4, input_fiber_point)
					) THEN face_3
					ELSE face_4
				END;
			ELSE
					-- Se obtiene la cara mas cercana al punto de salida
				SELECT INTO clossest_output_face
				CASE
					WHEN ST_Distance(face_1, output_fiber_point) <= LEAST(
						ST_Distance(face_2, output_fiber_point),
						ST_Distance(face_3, output_fiber_point),
						ST_Distance(face_4, output_fiber_point)
					) THEN face_1
					WHEN ST_Distance(face_2, output_fiber_point) <= LEAST(
						ST_Distance(face_1, output_fiber_point),
						ST_Distance(face_3, output_fiber_point),
						ST_Distance(face_4, output_fiber_point)
					) THEN face_2
					WHEN ST_Distance(face_3, output_fiber_point) <= LEAST(
						ST_Distance(face_1, output_fiber_point),
						ST_Distance(face_2, output_fiber_point),
						ST_Distance(face_4, output_fiber_point)
					) THEN face_3
					ELSE face_4
				END;
			END IF;

			face_2_aux = ST_OffsetCurve(face_2, -width * (n_guitar_lines + cont), 'quad_segs=4 join=round');

			IF clossest_input_face IS NOT NULL      
			THEN      
				clossest_input_face_aux = ST_OffsetCurve(clossest_input_face, -width * (n_guitar_lines + cont), 'quad_segs=4 join=round');

				IF clossest_input_face_aux = face_2_aux
				THEN
					-- Se obtiene el camino mas corto de la fibra a la cara
					input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face_aux);

					-- Se updatea la geometria para que se conecte con el port.
					new_input_geom=ST_LineMerge(
						ST_MakeLine(
							ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
							port_rec.geom
						)
					);
				ELSIF (ST_Intersects(clossest_input_face_aux, face_2_aux))
				THEN           
					-- Caso en el que se cortan las caras
					-- Se obtiene el punto de corte
					faces_intersection_point = ST_Intersection(clossest_input_face_aux, face_2_aux);

					-- Se obtiene el camino mas corto de la fibra a la cara
					input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face_aux);

					-- Se crea la nueva geometría
					new_input_geom=ST_LineMerge(
						ST_MakeLine(
							ST_MakeLine(
								ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
								faces_intersection_point
							),
							port_rec.geom
						)
					);
			ELSE
					-- Caso en el que no se cortan las caras
					WITH distances AS (
					SELECT
						unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
						ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), input_fiber_point) AS distance
					)
					SELECT 
						face
					INTO 
						second_closest_input_face
					FROM (
						SELECT 
							face,
							ROW_NUMBER() OVER (ORDER BY distance) AS rn
						FROM 
							distances
					) ranked_distances
					WHERE rn = 2;

					second_closest_input_face =  ST_OffsetCurve(second_closest_input_face, -width * (n_guitar_lines + cont), 'quad_segs=4 join=round');
					
					-- Se obtiene el camino mas corto de la fibra a la cara
					input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face_aux);

					--  Punto de corte de la cara mas cercana con la segunda mas cercana
					input_faces_intersection_point = ST_Intersection(second_closest_input_face, clossest_input_face_aux);

					-- Punto de corte de la segunda cara mas cercana con la cara del port
					faces_intersection_point = ST_Intersection(second_closest_input_face, face_2_aux);

					-- Se crea la nueva geometría uniendo los puntos anteriores
					new_input_geom=ST_LineMerge(
							ST_MakeLine(
								ST_MakeLine(
									ST_MakeLine(
										ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
										input_faces_intersection_point
									),
									faces_intersection_point
								),
								port_rec.geom
							)
						);
				END IF;

				-- Se actualiza la fibra con la nueva geometría
				UPDATE gis.fo_fiber
					SET layout_geom=new_input_geom,
					source=null, 
					target=null
				WHERE id_gis = fiber_rec.id_gis;
			ELSIF clossest_output_face IS NOT NULL
			THEN
				clossest_output_face_aux = ST_OffsetCurve(clossest_output_face, -width * (n_guitar_lines + cont), 'quad_segs=4 join=round');

				IF clossest_output_face_aux = face_2_aux
				THEN
					-- Se obtiene el camino mas corto de la fibra a la cara
					output_fiber_to_face = ST_ShortestLine(clossest_output_face_aux, output_fiber_point);

					-- Se updatea la geometria para que se conecte con el port.
					new_output_geom=ST_LineMerge(
							ST_MakeLine(
								port_rec.geom,
								ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                            
							)
						);
				ELSIF (ST_Intersects(clossest_output_face_aux, face_2_aux))
				THEN 
					-- Caso en el que se cortan las caras
					-- Se obtiene el punto de corte
					faces_intersection_point = ST_Intersection(clossest_output_face_aux, face_2_aux);

					-- Se obtiene el camino mas corto de la fibra a la cara
					output_fiber_to_face = ST_ShortestLine(clossest_output_face_aux, output_fiber_point);

					-- Se crea la nueva geometría
					new_output_geom=ST_LineMerge(
						ST_MakeLine(
							port_rec.geom,
							ST_MakeLine(
								faces_intersection_point,
								ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                               
							)                            
						)
					);
				ELSE
					-- Caso en el que no se cortan las caras
					WITH distances AS (
					SELECT
						unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
						ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), output_fiber_point) AS distance
					)
					SELECT 
						face
					INTO 
						second_closest_output_face
					FROM (
						SELECT 
							face,
							ROW_NUMBER() OVER (ORDER BY distance) AS rn
						FROM 
							distances
					) ranked_distances
					WHERE rn = 2; 

					second_closest_output_face =  ST_OffsetCurve(second_closest_output_face, -width * (n_guitar_lines + cont), 'quad_segs=4 join=round');

					-- Se obtiene el camino mas corto de la fibra a la cara
					output_fiber_to_face = ST_ShortestLine(clossest_output_face_aux, output_fiber_point);

					--  Punto de corte de la cara mas cercana con la segunda mas cercana
					output_faces_intersection_point = ST_Intersection(second_closest_output_face, clossest_output_face_aux);

					-- Punto de corte de la segunda cara mas cercana con la cara del port
					faces_intersection_point = ST_Intersection(second_closest_output_face, face_2_aux);

					-- Se crea la nueva geometría uniendo los puntos anteriores
					new_output_geom=ST_LineMerge(
							ST_MakeLine(
								port_rec.geom,
								ST_MakeLine(
									faces_intersection_point,
									ST_MakeLine(
										output_faces_intersection_point,
										ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                                
									)                            
								)                       
							)
						);
				END IF;

				-- Se actualiza la fibra con la nueva geometría
				UPDATE gis.fo_fiber
					SET layout_geom=new_output_geom,
					source=null, 
					target=null
				WHERE id_gis = fiber_rec.id_gis;
			END IF;
			cont = cont + 1;
		END LOOP;		
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION possible_to_delete(id_gis VARCHAR) RETURNS VARCHAR AS 
$$
DECLARE
    char_array TEXT[];
    object_name VARCHAR;
    object_record RECORD;
	current_fiber RECORD;
    result_array TEXT[] := '{}';  -- Inicializar result_array como un array vacío
    result VARCHAR;
BEGIN
    -- Obtengo el nombre del objeto
    char_array := STRING_TO_ARRAY(id_gis, '_');
    object_name := char_array[1];

    FOR i IN 2..array_length(char_array, 1)-1
    LOOP
        object_name := CONCAT(CONCAT(object_name, '_'), char_array[i]);
    END LOOP;

    FOR object_record IN EXECUTE 'SELECT * FROM gis.' || quote_ident(object_name) || ' WHERE id_gis = ' || quote_literal(id_gis)
    LOOP
        CASE

            WHEN object_name = 'optical_splitter'
            THEN
                IF (SELECT count(*) FROM gis.fo_fiber WHERE ST_distance(layout_geom, object_record.geom) < 0.003) > 1
                THEN
                    result_array := array_append(result_array, 'hilos de Fibra Óptica conectados');
                END IF; 

			WHEN object_name = 'fo_splice'
			THEN
				IF (SELECT count(*) FROM gis.optical_splitter WHERE ST_Intersects(geom, object_record.layout_geom)) > 1
                THEN
                    result_array := array_append(result_array, 'Splitters Ópticos'); 
                END IF; 

				IF (SELECT count(*) FROM gis.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, object_record.layout_geom)) > 0.03) > 1
                THEN
                    result_array := array_append(result_array, 'hilos de Fibra Óptica conectados');
                END IF; 

				IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, object_record.layout_geom) < 0.003) > 1
                THEN
                    result_array := array_append(result_array, 'cables de Fibra Óptica conectados');
                END IF; 

			WHEN object_name = 'cw_sewer_box'
				OR object_name = 'cw_pole'
			THEN
				IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, object_record.layout_geom) < 0.003) > 1
                THEN
                    result_array := array_append(result_array, 'cables de Fibra Óptica conectados');
                END IF; 

			WHEN object_name = 'cw_duct'
            THEN
				IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, object_record.layout_geom)) > 1
                THEN
                    result_array := array_append(result_array, 'cables de Fibra Óptica por dentro');
                END IF; 

			WHEN object_name = 'cw_ground_route'
            THEN
				IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, object_record.layout_geom)) > 1
                THEN
                    result_array := array_append(result_array, 'cables de Fibra Óptica por dentro');
                END IF; 

				IF (SELECT count(*) FROM gis.cw_duct WHERE ST_Intersects(layout_geom, object_record.layout_geom)) > 1
                THEN
                    result_array := array_append(result_array, 'Ductos por dentro');
                END IF; 

			WHEN object_name = 'cw_skyway'
            THEN
				IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, object_record.layout_geom)) > 1
                THEN
                    result_array := array_append(result_array, 'cables de Fibra Óptica por dentro');
                END IF; 
			WHEN object_name = 'fo_cable'
            THEN				
				FOR current_fiber IN SELECT * FROM gis.fo_fiber WHERE id_cable = object_record.id_gis
				LOOP
					IF (SELECT count(*) FROM gis.fo_splice WHERE ST_Length(ST_Intersection(current_fiber.layout_geom, layout_geom)) > 0.003) > 0
					THEN
						result_array := array_append(result_array, 'hilos de Fibra Óptica conectados');
						EXIT;
					END IF;
				END LOOP;
			ELSE
				-- DO NOTHING
        END CASE;
    END LOOP;

    result := '{';
    IF array_length(result_array, 1) > 0
    THEN
        result := CONCAT(result, '"ableToDelete":"false","msgError":"No se puede borrar porque hay: ');
        FOR i IN 1..array_length(result_array, 1)
        LOOP
            result := CONCAT(result, result_array[i]);
            IF i < array_length(result_array, 1) THEN
                result := CONCAT(result, ', ');
            END IF;
        END LOOP;
        result := CONCAT(result, '"');
    ELSE
        result := CONCAT(result, '"ableToDelete":"true","msgError":"OK"');
    END IF;
    result := CONCAT(result, '}');

    RETURN result;
END;
$$ 
LANGUAGE plpgsql;


-- GEMERA IUN EMPALME EN EL PISO INDICADO EN EL EDIFICIO INDICADO
CREATE OR REPLACE FUNCTION insert_fo_splice_on_building(id_gis_building VARCHAR, n_floor INTEGER) RETURNS VOID AS 
	$$
	DECLARE
		building_record RECORD;
		guitar_splices_line GEOMETRY;
		guitar_splices_line_points GEOMETRY;
		aux_line_for_radians GEOMETRY;
	BEGIN
		SELECT * INTO building_record FROM gis.cw_building WHERE id_gis = id_gis_building;

		IF n_floor IS NOT NULL
		THEN
			IF n_floor <= building_record.n_floors
			THEN
				guitar_splices_line := ST_OffsetCurve(ST_MakeLine(
						(SELECT geom FROM ST_DUmpPoints(building_record.layout_geom) WHERE path[2] = 1),
						(SELECT geom FROM ST_DUmpPoints(building_record.layout_geom) WHERE path[2] = 2)
					),
					-0.2, 
					'quad_segs=4 join=mitre mitre_limit=2.2'
					);

				guitar_splices_line_points := ST_LineInterpolatePoints(guitar_splices_line, (1::FLOAT / (building_record.n_floors + 1)::FLOAT), true);

				INSERT INTO gis.fo_splice(geom) VALUES (ST_GeometryN(guitar_splices_line_points, (building_record.n_floors + 1) - n_floor));
			END IF;
		ELSE

		END IF;
	END;
	$$
LANGUAGE plpgsql;

-- GEMERA IUN EMPALME EN EL PISO INDICADO EN EL EDIFICIO INDICADO
CREATE OR REPLACE FUNCTION insert_client_on_floor(id_gis_floor VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		current_floor RECORD;
		current_building RECORD;
		aux_line_1 GEOMETRY;
		aux_line_2 GEOMETRY;
		central_line_clients GEOMETRY;
		central_clients_line_points GEOMETRY;
		clients_distance FLOAT;
		floor_width FLOAT;
		floor_height FLOAT;
		radians_to_rotate FLOAT;
		floor_boundary_point_1 GEOMETRY;
		floor_boundary_point_2 GEOMETRY;
		line_for_radians_1 GEOMETRY;
		line_for_radians_2 GEOMETRY;
		pos INTEGER;
	BEGIN 
		floor_width := 6;
		floor_height := 0.6;
		SELECT * INTO current_floor FROM gis.cw_floor WHERE id_gis = id_gis_floor;
		SELECT * INTO current_building FROM gis.cw_building WHERE ST_Intersects(layout_geom, current_floor.geom);

		aux_line_1 := ST_MakeLine(
				(SELECT geom FROM ST_DUmpPoints(current_floor.layout_geom) WHERE path[2] = 3),
				(SELECT geom FROM ST_DUmpPoints(current_floor.layout_geom) WHERE path[2] = 4)
			);
		aux_line_2 := ST_MakeLine(
				(SELECT geom FROM ST_DUmpPoints(current_floor.layout_geom) WHERE path[2] = 1),
				(SELECT geom FROM ST_DUmpPoints(current_floor.layout_geom) WHERE path[2] = 2)
			);

		central_line_clients := ST_MakeLine(
			ST_Centroid(aux_line_1), 
			ST_Centroid(aux_line_2)
		);
		central_clients_line_points := (SELECT ST_LineInterpolatePoints(central_line_clients, (1::FLOAT / (20+1)::FLOAT), true));
		clients_distance := ST_Distance(ST_GeometryN(central_clients_line_points,1),ST_GeometryN(central_clients_line_points,2));	

		FOR e IN 1..(ST_NumGeometries(central_clients_line_points))
		LOOP
			pos := (ST_NumGeometries(central_clients_line_points)) - e;
			IF (SELECT count(*) FROM gis.cw_client WHERE ST_Intersects(layout_geom, ST_GeometryN(central_clients_line_points, pos))) = 0
			THEN
				INSERT INTO gis.cw_client(geom, layout_geom)
					values(
						ST_GeometryN(central_clients_line_points, pos),
						ST_Rotate(
							ST_MakeEnvelope(
								ST_X(ST_GeometryN(central_clients_line_points, pos)) - clients_distance/2 + 0.03,  -- Coordenada x de la esquina inferior izquierda
								ST_Y(ST_GeometryN(central_clients_line_points, pos)) - floor_height + 0.36 ,   -- Coordenada y de la esquina inferior izquierda
								ST_X(ST_GeometryN(central_clients_line_points, pos)) + clients_distance/2 - 0.03,  -- Coordenada x de la esquina superior derecha
								ST_Y(ST_GeometryN(central_clients_line_points, pos)) + floor_height,   -- Coordenada y de la esquina superior derecha
								ST_SRID(ST_GeometryN(central_clients_line_points, pos))
							),
							current_building.rotate_rads,
							ST_GeometryN(central_clients_line_points, pos)
						)
					);
				EXIT;
			END IF;
		END LOOP;

	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_ont_on_client(id_gis_client VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
	BEGIN
		IF (SELECT count(*) FROM gis.optical_network_terminal WHERE ST_Intersects(geom, (SELECT layout_geom FROm gis.cw_client WHERE id_gis = id_gis_client))) < 10 
		THEN
			INSERT INTO gis.optical_network_terminal(geom)
				VALUES ((SELECT geom FROM gis.cw_client WHERE id_gis = id_gis_client));
		END IF;
	END;
	$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION connect_splice_client(id_gis_splice VARCHAR, id_gis_client VARCHAR) RETURNS RECORD AS 
	$$
	DECLARE
		current_splice_record RECORD;
		current_client_record RECORD;
		current_floor_record RECORD;
		current_building_record RECORD;
		new_cable_record RECORD;
		splice_face_1 GEOMETRY;
		splice_face_2 GEOMETRY;
		splice_face_3 GEOMETRY;
		splice_face_4 GEOMETRY;
		client_face_1 GEOMETRY;
		client_face_2 GEOMETRY;
		client_face_3 GEOMETRY;
		client_face_4 GEOMETRY;
		min_distance float;
    	closest_splice_face GEOMETRY;
		closest_floor_face GEOMETRY;
		closest_floor_guitar_line GEOMETRY;
		bottom_floor_guitar_line GEOMETRY;
		splice_face_points GEOMETRY;
		floor_face_points GEOMETRY;
		splice_free_point GEOMETRY;
		floor_free_point GEOMETRY;
		splice_guitar_line GEOMETRY;
		cable_layout_geom GEOMETRY;
		n_cables_building INTEGER;
		n_cables_floor INTEGER;
		floor_array GEOMETRY[];
		splice_array GEOMETRY[];
		client_array GEOMETRY[];
		closest_client_face GEOMETRY;
		client_face_points GEOMETRY;
		client_free_point GEOMETRY;
		bottom_floor_face GEOMETRY;
	BEGIN
		SELECT * INTO current_splice_record FROM gis.fo_splice WHERE id_gis = id_gis_splice;
		SELECT * INTO current_client_record FROM gis.cw_client WHERE id_gis = id_gis_client;
		SELECT * INTO current_floor_record FROM gis.cw_floor WHERE ST_Intersects(layout_geom, current_client_record.layout_geom);
		SELECT * INTO current_building_record FROM gis.cw_building WHERE ST_Intersects(layout_geom, current_client_record.layout_geom);

		-- CARAS DEL EMPALME
		splice_array := ARRAY[
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=1), 
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=2)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=2), 
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=3)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=3), 
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=4)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=4), 
				(SELECT geom FROM ST_DumpPoints(current_splice_record.layout_geom) WHERE path[2]=5))
			];
		-- CARAS DEL FLOOR
		floor_array := ARRAY[
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=1), 
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=2)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=2), 
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=3)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=3), 
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=4)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=4), 
				(SELECT geom FROM ST_DumpPoints(current_floor_record.layout_geom) WHERE path[2]=5))
			];

		client_array := ARRAY[
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=1), 
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=2)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=2), 
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=3)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=3), 
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=4)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=4), 
				(SELECT geom FROM ST_DumpPoints(current_client_record.layout_geom) WHERE path[2]=5))
			];
		

		-- Obtengo las caras mas cercanas
		FOR i IN 1..array_length(splice_array,1) 
		LOOP
			FOR e IN 1..array_length(floor_array,1)
			LOOP
				IF min_distance IS NULL OR ST_Distance(splice_array[i], ST_Centroid(floor_array[e])) < min_distance 
				THEN
					min_distance := ST_Distance(splice_array[i], ST_Centroid(floor_array[e]));
					closest_splice_face := splice_array[i];
					closest_floor_face := floor_array[e];
				END IF;
			END LOOP;
		END LOOP;

		FOR e IN 1..array_length(floor_array,1)
		LOOP
			IF NOT (ST_Distance(current_client_record.layout_geom, floor_array[e]) < 0.00003) AND (ST_Distance(floor_array[e], closest_floor_face) < 0.00003)
			THEN
				bottom_floor_face := floor_array[e];
			END IF;
		END LOOP;

		min_distance := NULL;
		FOR e IN 1..array_length(client_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(client_array[e]), bottom_floor_face) < min_distance 
			THEN
				min_distance := ST_Distance(ST_Centroid(client_array[e]), bottom_floor_face);
				closest_client_face := client_array[e];
			END IF;
		END LOOP;

		splice_face_points := ST_LineInterpolatePoints(closest_splice_face, 0.045, true);
		floor_face_points := ST_LineInterpolatePoints(closest_floor_face, 0.045, true);
		client_face_points := ST_LineInterpolatePoints(closest_client_face, 0.045, true);

		FOR i IN 2..(ST_NumGeometries(splice_face_points)-1)
		LOOP
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, ST_GeometryN(splice_face_points, i)) < 0.00003) = 0
			THEN
				splice_free_point := ST_GeometryN(splice_face_points, i);
			END IF;
		END LOOP;

		FOR i IN 2..(ST_NumGeometries(floor_face_points)-1)
		LOOP
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, ST_GeometryN(floor_face_points, i)) < 0.00003) = 0
			THEN
				floor_free_point := ST_GeometryN(floor_face_points, i);
			END IF;
		END LOOP;

		FOR i IN 2..(ST_NumGeometries(client_face_points)-1)
		LOOP
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, ST_GeometryN(client_face_points, i)) < 0.00003) = 0
			THEN
				client_free_point := ST_GeometryN(client_face_points, i);
			END IF;
		END LOOP;

		n_cables_building := (SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, current_building_record.layout_geom));
		n_cables_floor := (SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, current_floor_record.layout_geom));

		splice_guitar_line := ST_LineExtend(ST_OffsetCurve(closest_splice_face, 0.0075 * (n_cables_building + 1), 'quad_segs=4 join=mitre mitre_limit=2.2'), 10, 10);

		closest_floor_guitar_line := ST_LineExtend(ST_OffsetCurve(closest_floor_face, -0.0075 * (n_cables_floor + 1), 'quad_segs=4 join=mitre mitre_limit=2.2'), 10, 10);

		bottom_floor_guitar_line := ST_LineExtend(ST_OffsetCurve(bottom_floor_face, -0.0075 * (n_cables_floor + 1), 'quad_segs=4 join=mitre mitre_limit=2.2'), 10, 10);

		cable_layout_geom := ST_MakeLine(
				ST_ShortestLine(splice_free_point, splice_guitar_line),
				ST_ShortestLine(splice_guitar_line, floor_free_point)
			);
		
		cable_layout_geom := ST_MakeLine(
				cable_layout_geom,
				ST_ShortestLine(cable_layout_geom, closest_floor_guitar_line)
			);

		cable_layout_geom := ST_MakeLine(
				cable_layout_geom,
				ST_Intersection(closest_floor_guitar_line, bottom_floor_guitar_line)
			);

		cable_layout_geom := ST_MakeLine(
				cable_layout_geom,
				ST_Intersection(ST_ShortestLine(bottom_floor_guitar_line, client_free_point), bottom_floor_guitar_line)
			);
		
		cable_layout_geom := ST_MakeLine(
				cable_layout_geom,
				ST_ShortestLine(bottom_floor_guitar_line, client_free_point)
			);

		INSERT INTO gis.fo_cable(geom, layout_geom, is_acometida) 
			VALUES(
				ST_MakeLine(current_splice_record.geom, ST_Centroid(current_client_record.geom)),
				cable_layout_geom,
				true
			)
			RETURNING * INTO new_cable_record;

		RETURN new_cable_record;
	END;
	$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION connect_splice_splice(id_gis_splice_1 VARCHAR, id_gis_splice_2 VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		splice_record_1 RECORD;
		splice_record_2 RECORD;
		splice_faces_array GEOMETRY[];
		closest_splice_face GEOMETRY;
		splice_face_points GEOMETRY;
		splice_free_point GEOMETRY;
		min_distance FLOAT;
	BEGIN
		SELECT * INTO splice_record_1 FROM gis.fo_splice WHERE id_gis = id_gis_splice_1;
		SELECT * INTO splice_record_2 FROM gis.fo_splice WHERE id_gis = id_gis_splice_2;

		-- CARAS DEL EMPALME
		splice_faces_array := ARRAY[
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=1), 
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=2)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=2), 
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=3)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=3), 
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=4)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=4), 
				(SELECT geom FROM ST_DumpPoints(splice_record_1.layout_geom) WHERE path[2]=5))
			];

		FOR e IN 1..array_length(splice_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(splice_faces_array[e]), splice_record_2.layout_geom) < min_distance 
			THEN
				min_distance := ST_Distance(ST_Centroid(splice_faces_array[e]), splice_record_2.layout_geom);
				closest_splice_face := splice_faces_array[e];
			END IF;
		END LOOP;

		splice_face_points := ST_LineInterpolatePoints(closest_splice_face, 0.045, true);

		FOR i IN 2..(ST_NumGeometries(splice_face_points)-1)
		LOOP
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, ST_GeometryN(splice_face_points, i)) < 0.00003) = 0
			THEN
				splice_free_point := ST_GeometryN(splice_face_points, i);
			END IF;
		END LOOP;

		INSERT INTO gis.fo_cable(geom, layout_geom, is_acometida) 
			VALUES(
				ST_MakeLine(splice_record_1.geom, splice_record_2.geom),
				ST_ShortestLine(splice_free_point, splice_record_2.layout_geom),
				false
			);		
	END;
	$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION connect_fiber_ont(id_gis_fiber VARCHAR, id_gis_ont VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		fiber_record RECORD;
		ont_record RECORD;
		client_record RECORD;
		client_faces_array GEOMETRY[];
		closest_client_face GEOMETRY;
		guitar_client_face GEOMETRY;
		new_layout_geom GEOMETRY;
		min_distance FLOAT;
		n_cables INTEGER;
	BEGIN
		SELECT * INTO fiber_record FROM gis.fo_fiber WHERE id_gis = id_gis_fiber;
		SELECT * INTO ont_record FROM gis.optical_network_terminal WHERE id_gis = id_gis_ont;
		SELECT * INTO client_record FROM gis.cw_client WHERE ST_Intersects(ont_record.geom, layout_geom);
	
		-- CARAS DEL CLIENTE
		client_faces_array := ARRAY[
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=1), 
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=2)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=2), 
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=3)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=3), 
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=4)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=4), 
				(SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2]=5))
			];

		FOR e IN 1..array_length(client_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(client_faces_array[e], fiber_record.layout_geom) < min_distance 
			THEN
				min_distance := ST_Distance(client_faces_array[e], fiber_record.layout_geom);
				closest_client_face := client_faces_array[e];
			END IF;
		END LOOP;

		n_cables := (SELECT count(DISTINCT id_cable) FROM gis.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, client_record.layout_geom)) > 0.00003) + 1;
		guitar_client_face := ST_OffsetCurve(closest_client_face, -0.0075 * n_cables, 'quad_segs=4 join=mitre mitre_limit=2.2');

		new_layout_geom := ST_MakeLine(
				fiber_record.layout_geom,
				ST_ShortestLine(fiber_record.layout_geom, guitar_client_face)
			);

		new_layout_geom := ST_MakeLine(
				new_layout_geom,
				ST_Intersection(guitar_client_face, ST_ShortestLine(guitar_client_face, ont_record.geom))
			);

		new_layout_geom := ST_MakeLine(
				new_layout_geom,
				ST_ShortestLine(guitar_client_face, ont_record.geom)
			);

		UPDATE gis.fo_fiber 
			SET	
				layout_geom = new_layout_geom,
				source = NULL,
				target = NULL
			WHERE id_gis = id_gis_fiber;

	END;
	$$
LANGUAGE plpgsql;

--  FUnción para la inserción de rackas enc lientes o habitaciones
CREATE OR REPLACE FUNCTION insert_rack(id_gis_location VARCHAR, rack_spec VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		location_record RECORD;
		building_record RECORD;
		aux_rack_line GEOMETRY;
		rack_line_points GEOMETRY;
		pos INTEGER;
		height FLOAT;
		width FLOAT;
		inserted BOOLEAN;
	BEGIN
		height := 0.054;
		width := 0.03;
		inserted := false;

		SELECT * INTO location_record FROM gis.cw_client WHERE id_gis = id_gis_location;
		SELECT * INTO building_record FROM gis.cw_building WHERE ST_Intersects(layout_geom, location_record.geom);

		FOR i IN 2..5
		LOOP
			aux_rack_line := ST_OffsetCurve(
				ST_MakeLine(
					(SELECT geom FROM ST_DUmpPoints(location_record.layout_geom) WHERE path[2] = 4),
					(SELECT geom FROM ST_DUmpPoints(location_record.layout_geom) WHERE path[2] = 5)
				),
				-0.15 * i,
				'quad_segs=4 join=mitre mitre_limit=2.2'
			);
			rack_line_points := (SELECT ST_LineInterpolatePoints(aux_rack_line, (1::FLOAT / (6+1)::FLOAT), true));
			
			FOR e IN 0..ST_NumGeometries(rack_line_points)
			LOOP
				IF inserted THEN EXIT; END IF;
				pos := 6 - e;
				IF pos < 3 THEN EXIT; END IF;
				
				IF (SELECT count(*) FROM gis.rack WHERE ST_Intersects(layout_geom, ST_GeometryN(rack_line_points, pos))) < 1
				THEN
					INSERT INTO gis.rack(specification, geom, layout_geom)
						VALUES(
							rack_spec,
							ST_GeometryN(rack_line_points, pos),
							ST_Rotate(
								ST_MakeEnvelope(
									ST_X(ST_GeometryN(rack_line_points, pos)) - width,  -- Coordenada x de la esquina inferior izquierda
									ST_Y(ST_GeometryN(rack_line_points, pos)) - height,   -- Coordenada y de la esquina inferior izquierda
									ST_X(ST_GeometryN(rack_line_points, pos)) + width,  -- Coordenada x de la esquina superior derecha
									ST_Y(ST_GeometryN(rack_line_points, pos)) + height,   -- Coordenada y de la esquina superior derecha
									ST_SRID(ST_GeometryN(rack_line_points, pos))
								),
								building_record.rotate_rads,
								ST_GeometryN(rack_line_points, pos)
							)
						);
						inserted := true;
						EXIT;
				END IF;
			END LOOP;
		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

CREATE TABLE test(
	point GEOMETRY(POINT, 3857),
	linestring GEOMETRY(LINESTRING, 3857),
	polygon GEOMETRY(POLYGON, 3857)
);

-- Metodo de conexión de empalmes a racks
CREATE OR REPLACE FUNCTION connect_splice_rack(id_gis_splice VARCHAR, id_gis_rack VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		splice_record RECORD;
		location_record RECORD;
		rack_record RECORD;
		cable_record RECORD;
		current_fiber RECORD;
		current_rack RECORD;
		current_rack_record RECORD;
		location_faces_array GEOMETRY[];
		rack_faces_array GEOMETRY[];
		closest_location_face GEOMETRY;
		rise_location_face GEOMETRY;
		in_rack_face GEOMETRY;
		guitar_location_face GEOMETRY;
		guitar_rise_location_face GEOMETRY;
		guitar_in_rack_face GEOMETRY;
		min_distance FLOAT;
		cont INTEGER;
		n_cables INTEGER;
		n_cables_rack INTEGER;
		new_cable_layout_geom GEOMETRY;
	BEGIN
		SELECT * INTO rack_record FROM gis.rack WHERE id_gis = id_gis_rack;
		SELECT * INTO splice_record FROM gis.fo_splice WHERE id_gis = id_gis_splice;
		SELECT * INTO location_record FROM gis.cw_client WHERE ST_Intersects(layout_geom, rack_record.layout_geom);

		cable_record := connect_splice_client(splice_record.id_gis, location_record.id_gis);

		SELECT * INTO cable_record FROM gis.fo_cable WHERE id_gis = CONCAT('fo_cable_', cable_record.id::TEXT);

		-- Ahora que ya tenemos el cable acabando en el cliente se generan las guitarras del cable dentro del cliente/location
		-- CARAS DEL CLIENTE/HABITACIÓN
		location_faces_array := ARRAY[
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=1), 
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=2)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=2), 
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=3)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=3), 
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=4)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=4), 
				(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=5))
			];

		rack_faces_array := ARRAY[
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=1), 
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2), 
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3), 
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4)),
			ST_MakeLine(
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4), 
				(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=5))
			];

		-- Cara de entrada
		FOR e IN 1..array_length(location_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(location_faces_array[e], cable_record.layout_geom) < min_distance 
			THEN
				min_distance := ST_Distance(location_faces_array[e], cable_record.layout_geom);
				closest_location_face := location_faces_array[e];
			END IF;
		END LOOP;	

		-- Cara de subida de cables
		FOR e IN 1..array_length(location_faces_array,1)
		LOOP
			IF (SELECT count(*) FROM gis.rack WHERE ST_Distance(layout_geom, location_faces_array[e]) < 0.06) > 0
			THEN 
				CONTINUE;
			END IF;

			IF ST_Intersects(closest_location_face, location_faces_array[e]) 
				AND NOT ST_Equals(closest_location_face, location_faces_array[e])
			THEN
				rise_location_face = location_faces_array[e];
			END IF;
		END LOOP;
		
		min_distance := NULL;

		-- Cara de entrada de las racks
		FOR e IN 1..array_length(rack_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(rack_faces_array[e]), closest_location_face) < min_distance 
			THEN
				min_distance := ST_Distance(ST_Centroid(rack_faces_array[e]), closest_location_face);
				in_rack_face := rack_faces_array[e];
			END IF;
		END LOOP;

		n_cables := (SELECT count(DISTINCT id_cable) FROM gis.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, location_record.layout_geom)) > 0.00003) + 1;

		n_cables_rack := 1;

		FOR current_rack_record IN SELECT * FROM gis.rack 
			WHERE ST_Distance(layout_geom, ST_LineExtend(in_rack_face, 0.50, 0.50)) < 0.001 
				AND ST_Intersects(layout_geom, location_record.layout_geom)
		LOOP
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, current_rack_record.layout_geom) < 0.001) > 0
			THEN
				n_cables_rack = n_cables_rack + 1;
			END IF;
		END LOOP;

		guitar_location_face := ST_OffsetCurve(closest_location_face, -0.0075 * n_cables, 'quad_segs=4 join=mitre mitre_limit=2.2');
		guitar_rise_location_face := ST_OffsetCurve(rise_location_face, -0.0075 * n_cables, 'quad_segs=4 join=mitre mitre_limit=2.2');
		guitar_in_rack_face := ST_LineExtend(ST_OffsetCurve(in_rack_face, 0.0075 * n_cables_rack, 'quad_segs=4 join=mitre mitre_limit=2.2'), 0.50, 0.50);

		new_cable_layout_geom := ST_MakeLine(
				cable_record.layout_geom,
				ST_ShortestLine(cable_record.layout_geom, guitar_location_face)
			);

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), guitar_rise_location_face)
			);

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), guitar_in_rack_face)
			);

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_Intersection(ST_ShortestLine(guitar_in_rack_face, ST_GeometryN(ST_LineInterpolatePoints(in_rack_face, 0.05, true), 19)), guitar_in_rack_face)
			);
		
		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(guitar_in_rack_face, ST_GeometryN(ST_LineInterpolatePoints(in_rack_face, 0.05, true), 19))
			);
			
		UPDATE gis.fo_cable 
			SET	
				layout_geom = ST_LineMerge(new_cable_layout_geom)
			WHERE id_gis = cable_record.id_gis;
		cont := 1;

		SELECT * INTO cable_record FROM gis.fo_cable WHERE id_gis = cable_record.id_gis;

		PERFORM update_fo_fiber_to_splice(cable_record.id_gis, cable_record.layout_geom);	
	END;
	$$
LANGUAGE plpgsql;

-- Metodo para insertar shelfs en racks
CREATE OR REPLACE FUNCTION insert_shelf_on_rack(id_gis_rack VARCHAR, shelf_spec VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		rack_record RECORD;
		building_record RECORD;		
		current_shelf RECORD;
		current_card RECORD;
		rack_faces_array GEOMETRY[];
		aux_face_rack_1 GEOMETRY;
		aux_face_rack_2 GEOMETRY;
		central_rack_line GEOMETRY;
		central_rack_line_points GEOMETRY;
		temp_width FLOAT;
		sum_height FLOAT;
		temp_height FLOAT;
		temp_depth FLOAT;
		min_length FLOAT;
		shelf_layout_width FLOAT;
		shelf_layout_height FLOAT;
		ok BOOLEAN; 
		pos INTEGER;
		pos_aux INTEGER;
	BEGIN
		ok := true;
		sum_height := 0;
		shelf_layout_width = 0.024;

		SELECT * INTO rack_record FROM gis.rack WHERE id_gis = id_gis_rack;
		SELECT * INTO building_record FROM gis.cw_building WHERE ST_Intersects(layout_geom, rack_record.layout_geom);

		FOR current_shelf IN SELECT * FROM gis.shelf WHERE ST_Intersects(rack_record.layout_geom, layout_geom)
		LOOP
			sum_height = sum_height + (SELECT height FROM template.shelf_specs WHERE model = current_shelf.specification);
		END LOOP;

		FOR current_card IN SELECT * FROM gis.card WHERE ST_Intersects(rack_record.layout_geom, layout_geom)
		LOOP
			sum_height = sum_height + current_card.height;
		END LOOP;

		IF (SELECT width FROM template.rack_specs WHERE model = rack_record.specification) <= (SELECT width FROM template.shelf_specs WHERE model = shelf_spec)
			OR (SELECT height FROM template.rack_specs WHERE model = rack_record.specification) <= (sum_height + (SELECT height FROM template.shelf_specs WHERE model = shelf_spec))
			OR (SELECT depth FROM template.rack_specs WHERE model = rack_record.specification) <= (SELECT depth FROM template.shelf_specs WHERE model = shelf_spec)
		THEN 
			ok := false;
		END IF;

		IF ok
		THEN
			rack_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=5))
				];

			--  REcorro las caras de la tarjeta para sacar la 2 mas cortas
			FOR e IN 1..(array_length(rack_faces_array,1) - 2)
			LOOP
				IF min_length IS NULL OR ST_Length(rack_faces_array[e]) < min_length 
				THEN
					min_length := ST_Length(rack_faces_array[e]);
					aux_face_rack_1 := rack_faces_array[e];
					aux_face_rack_2 := rack_faces_array[e + 2];
				END IF;
			END LOOP;	

			central_rack_line := ST_MakeLine(
					ST_Centroid(aux_face_rack_1),
					ST_Centroid(aux_face_rack_2)
				);

			central_rack_line := ST_OffsetCurve(central_rack_line, 0.004, 'quad_segs=4 join=mitre mitre_limit=2.2');

			central_rack_line_points := ST_LineInterpolatePoints(
					central_rack_line,
					(1/(((SELECT height FROM template.rack_specs WHERE model = rack_record.specification) * 100) + 10.0)),  
					true
				);
			
			FOR e IN 1..(ST_NumGeometries(central_rack_line_points))
			LOOP	
				pos_aux := (ST_NumGeometries(central_rack_line_points)) - e;
				IF (SELECT count(*) FROM gis.shelf WHERE ST_Distance(layout_geom, ST_GeometryN(central_rack_line_points, pos_aux)) < 0.0003) = 0
					AND (SELECT count(*) FROM gis.card WHERE ST_Distance(layout_geom, ST_GeometryN(central_rack_line_points, pos_aux)) < 0.0003) = 0
				THEN 	
					IF pos_aux < (ST_NumGeometries(central_rack_line_points) - 1)
					THEN
						pos_aux := pos_aux + 1;
					END IF;

					pos := pos_aux - (CEIL((SELECT height FROM template.shelf_specs WHERE model = shelf_spec) * 100)/2)::INTEGER;

					shelf_layout_height := ST_Distance(ST_GeometryN(central_rack_line_points, pos_aux), ST_GeometryN(central_rack_line_points, pos));
					INSERT INTO gis.shelf(geom, specification, layout_geom)
						VALUES(
							ST_GeometryN(central_rack_line_points, pos),
							shelf_spec,
							ST_Rotate(
								ST_MakeEnvelope(
									ST_X(ST_GeometryN(central_rack_line_points, pos)) - shelf_layout_width,  -- Coordenada x de la esquina inferior izquierda
									ST_Y(ST_GeometryN(central_rack_line_points, pos)) - shelf_layout_height,   -- Coordenada y de la esquina inferior izquierda
									ST_X(ST_GeometryN(central_rack_line_points, pos)) + shelf_layout_width,  -- Coordenada x de la esquina superior derecha
									ST_Y(ST_GeometryN(central_rack_line_points, pos)) + shelf_layout_height,   -- Coordenada y de la esquina superior derecha
									ST_SRID(ST_GeometryN(central_rack_line_points, pos))
								),
								building_record.rotate_rads,
								ST_GeometryN(central_rack_line_points, pos)
							)						
						);
						EXIT;
				END IF;
			END LOOP;
		END IF;
		
	END;
	$$
LANGUAGE plpgsql;

-- Metodo para insertar shelfs en racks
CREATE OR REPLACE FUNCTION insert_card_on_shelf(
    id_gis_shelf VARCHAR,
	card_spec VARCHAR,
    n_rows INTEGER,
    n_cols INTEGER
) RETURNS VOID AS 
	$$
	DECLARE
		shelf_record RECORD;
		building_record RECORD;
		current_card RECORD;
		shelf_faces_array GEOMETRY[];
		central_shelf_line GEOMETRY;
		central_shelf_line_points GEOMETRY;
		sum_height FLOAT := 0;
		card_layout_height FLOAT;
		pos INTEGER;
		pos_aux INTEGER;
		ok BOOLEAN := true;
		id_card_inserted INTEGER;
	BEGIN
		SELECT * INTO shelf_record FROM gis.shelf WHERE id_gis = id_gis_shelf;
		SELECT * INTO building_record FROM gis.cw_building WHERE ST_Intersects(shelf_record.layout_geom, layout_geom);

		FOR current_card IN SELECT * FROM gis.card WHERE ST_Contains(shelf_record.layout_geom, layout_geom)
		LOOP
			sum_height := sum_height + (SELECT height FROM template.card_specs WHERE model = current_card.specification);
		END LOOP;

		IF (SELECT width FROM template.shelf_specs WHERE model = shelf_record.specification) < (SELECT width FROM template.card_specs WHERE model = card_spec) 
			OR (SELECT height FROM template.shelf_specs WHERE model = shelf_record.specification) < (sum_height + (SELECT height FROM template.card_specs WHERE model = card_spec)) 
			OR (SELECT depth FROM template.shelf_specs WHERE model = shelf_record.specification) < (SELECT depth FROM template.card_specs WHERE model = card_spec) 
		THEN
			ok := false;
		END IF;

		IF ok THEN
			shelf_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=1),
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=2)
				),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=2),
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=3)
				),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=3),
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=4)
				),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=4),
					(SELECT geom FROM ST_DumpPoints(shelf_record.layout_geom) WHERE path[2]=5)
				)
			];

			central_shelf_line := ST_MakeLine(
				ST_Centroid(shelf_faces_array[2]),
				ST_Centroid(shelf_faces_array[4])
			);

			central_shelf_line_points := ST_LineInterpolatePoints(central_shelf_line, 
				(1 / (((SELECT height FROM template.shelf_specs WHERE model = shelf_record.specification) * 100) + 10.0)), 
				true);

			FOR e IN 0..ST_NumGeometries(central_shelf_line_points)
			LOOP
				pos_aux := (ST_NumGeometries(central_shelf_line_points)) - e;
				IF (SELECT count(*) FROM gis.card WHERE ST_Distance(layout_geom, ST_GeometryN(central_shelf_line_points, pos_aux)) < 0.0003) = 0 
				THEN
					IF pos_aux < (ST_NumGeometries(central_shelf_line_points)) - 1 
					THEN
						pos_aux := pos_aux + 1;
					END IF;

					pos := (pos_aux - (CEIL((SELECT height FROM template.card_specs WHERE model = card_spec) * 100 )/ 2))::INTEGER;
					card_layout_height := ST_Distance(ST_GeometryN(central_shelf_line_points, pos_aux), ST_GeometryN(central_shelf_line_points, pos));

					INSERT INTO gis.card(geom, specification, layout_geom)
					VALUES (
						ST_GeometryN(central_shelf_line_points, pos),
						card_spec,
						ST_Rotate(
							ST_MakeEnvelope(
								ST_X(ST_GeometryN(central_shelf_line_points, pos)) - 0.022,
								ST_Y(ST_GeometryN(central_shelf_line_points, pos)) - card_layout_height,
								ST_X(ST_GeometryN(central_shelf_line_points, pos)) + 0.022,
								ST_Y(ST_GeometryN(central_shelf_line_points, pos)) + card_layout_height,
								ST_SRID(ST_GeometryN(central_shelf_line_points, pos))
							),
							building_record.rotate_rads,
							ST_GeometryN(central_shelf_line_points, pos)
						)
					) RETURNING id INTO id_card_inserted;

					PERFORM create_card_ports(CONCAT('card_', id_card_inserted::TEXT), n_rows, n_cols);
					EXIT;
				END IF;
			END LOOP;
		END IF;
	END;
	$$ 
LANGUAGE plpgsql;

-- Metodo de conexión de empalmes a racks
CREATE OR REPLACE FUNCTION insert_card_on_rack(id_gis_rack VARCHAR, card_spec VARCHAR, n_rows INTEGER, n_cols INTEGER) RETURNS VOID AS 
	$$
	DECLARE
		rack_record RECORD;
		building_record RECORD;
		current_shelf RECORD;
		current_card RECORD;
		rack_faces_array GEOMETRY[];
		aux_face_rack_1 GEOMETRY;
		aux_face_rack_2 GEOMETRY;
		central_rack_line GEOMETRY;
		central_rack_line_points GEOMETRY;
		sum_height FLOAT;
		min_length FLOAT;
		temp_width FLOAT;
		temp_height  FLOAT;
		temp_depth FLOAT;
		card_layout_height FLOAT;
		pos INTEGER;
		pos_aux INTEGER;
		ok BOOLEAN;
		id_card_inserted INTEGER;
	BEGIN
		ok := true;
		sum_height:=0;

		SELECT * INTO rack_record FROM gis.rack WHERE id_gis = id_gis_rack;
		SELECT * INTO building_record FROM gis.cw_building WHERE ST_Intersects(rack_record.layout_geom, layout_geom);

		FOR current_shelf IN SELECT * FROM gis.shelf WHERE ST_Intersects(rack_record.layout_geom, layout_geom)
		LOOP
			sum_height = sum_height + (SELECT height FROM template.shelf_specs WHERE model = current_shelf.specification);
		END LOOP;

		FOR current_card IN SELECT * FROM gis.card WHERE ST_Intersects(rack_record.layout_geom, layout_geom)
		LOOP
			sum_height = sum_height + (SELECT height FROM template.card_specs WHERE model = current_card.specification);
		END LOOP;

		IF (SELECT width FROM template.rack_specs WHERE model = rack_record.specification) < (SELECT width FROM template.card_specs WHERE model = card_spec)
			OR (SELECT height FROM template.rack_specs WHERE model = rack_record.specification) < (sum_height + (SELECT height FROM template.card_specs WHERE model = card_spec))
			OR (SELECT depth FROM template.rack_specs WHERE model = rack_record.specification) < (SELECT depth FROM template.card_specs WHERE model = card_spec)
		THEN 
			ok := false;
		END IF;

		IF ok
		THEN
			rack_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=5))
				];

			--  REcorro las caras de la tarjeta para sacar la 2 mas cortas
			FOR e IN 1..(array_length(rack_faces_array,1) - 2)
			LOOP
				IF min_length IS NULL OR ST_Length(rack_faces_array[e]) < min_length 
				THEN
					min_length := ST_Length(rack_faces_array[e]);
					aux_face_rack_1 := rack_faces_array[e];
					aux_face_rack_2 := rack_faces_array[e + 2];
				END IF;
			END LOOP;	

			central_rack_line := ST_MakeLine(
					ST_Centroid(aux_face_rack_1),
					ST_Centroid(aux_face_rack_2)
				);

			central_rack_line := ST_OffsetCurve(central_rack_line, 0.004, 'quad_segs=4 join=mitre mitre_limit=2.2');

			central_rack_line_points := ST_LineInterpolatePoints(
					central_rack_line,
					(1/(((SELECT height FROM template.rack_specs WHERE model = rack_record.specification) * 100) + 10.0)),  
					true
				);

			FOR e IN 1..(ST_NumGeometries(central_rack_line_points))
			LOOP	
				pos_aux := (ST_NumGeometries(central_rack_line_points)) - e;
				IF (SELECT count(*) FROM gis.shelf WHERE ST_Distance(layout_geom, ST_GeometryN(central_rack_line_points, pos_aux)) < 0.003) = 0
					AND (SELECT count(*) FROM gis.card WHERE ST_Distance(layout_geom, ST_GeometryN(central_rack_line_points, pos_aux)) < 0.003) = 0
				THEN 
					IF pos_aux < (ST_NumGeometries(central_rack_line_points)) - 1
					THEN
						pos_aux := pos_aux + 1;
					END IF;

					pos := pos_aux - (CEIL((SELECT height FROM template.card_specs WHERE model = card_spec) * 100)/2)::INTEGER;
					card_layout_height := ST_Distance(ST_GeometryN(central_rack_line_points, pos_aux), ST_GeometryN(central_rack_line_points, pos));
					INSERT INTO gis.card(geom, specification, layout_geom)
						VALUES(
							ST_GeometryN(central_rack_line_points, pos),
							card_spec,
							ST_Rotate(
								ST_MakeEnvelope(
									ST_X(ST_GeometryN(central_rack_line_points, pos)) - 0.022,  -- Coordenada x de la esquina inferior izquierda
									ST_Y(ST_GeometryN(central_rack_line_points, pos)) - card_layout_height,   -- Coordenada y de la esquina inferior izquierda
									ST_X(ST_GeometryN(central_rack_line_points, pos)) + 0.022,  -- Coordenada x de la esquina superior derecha
									ST_Y(ST_GeometryN(central_rack_line_points, pos)) + card_layout_height,   -- Coordenada y de la esquina superior derecha
									ST_SRID(ST_GeometryN(central_rack_line_points, pos))
								),
								building_record.rotate_rads,
								ST_GeometryN(central_rack_line_points, pos)
							)						
						)RETURNING id INTO id_card_inserted;

						PERFORM create_card_ports(CONCAT('card_', id_card_inserted::TEXT), n_rows, n_cols);
						EXIT;
				END IF;
			END LOOP;

		END IF;
	END;
	$$
LANGUAGE plpgsql;

-- Metodo de creación de empalmes en función del numero filas y columnas
CREATE OR REPLACE FUNCTION create_card_ports(id_gis_card VARCHAR, n_rows INTEGER, n_cols INTEGER) RETURNS VOID AS 
	$$
	DECLARE
		card_record RECORD;
		card_faces_array GEOMETRY[];
		aux_short_face_card_1 GEOMETRY;
		aux_short_face_card_2 GEOMETRY;
		aux_long_face_card_1 GEOMETRY;
		aux_long_face_card_2 GEOMETRY;
	BEGIN
		SELECT * INTO card_record FROM gis.card WHERE id_gis = id_gis_card;

		card_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=5))
				];

		aux_short_face_card_1 := ST_LineInterpolatePoints(card_faces_array[1], (1/(n_rows + 3)::FLOAT), true);
		aux_short_face_card_2 := ST_LineInterpolatePoints(card_faces_array[3], (1/(n_rows + 3)::FLOAT), true);
		aux_long_face_card_1 := ST_LineInterpolatePoints(card_faces_array[2], (1/(n_cols + 3)::FLOAT), true);
		aux_long_face_card_2 := ST_LineInterpolatePoints(card_faces_array[4], (1/(n_cols + 3)::FLOAT), true);

		FOR e IN 2..(n_rows + 1)
		LOOP
			FOR i IN 2..(n_cols + 1)
			LOOP
				INSERT INTO gis.port(geom)
					VALUES(
						ST_Intersection(
							ST_MakeLine(
								ST_GeometryN(aux_short_face_card_1, e),
								ST_GeometryN(aux_short_face_card_2, ST_NumGeometries(aux_short_face_card_1) - e)
							),
							ST_MakeLine(
								ST_GeometryN(aux_long_face_card_1, i),
								ST_GeometryN(aux_long_face_card_2, ST_NumGeometries(aux_long_face_card_1) - i)
							)
						)
					);
			END LOOP;
		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION connect_fiber_building_port(id_gis_fiber VARCHAR, id_gis_port VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		fiber_record RECORD;
		port_record RECORD;
		card_record RECORD;
		rack_record RECORD;
		shelf_record RECORD;
		rack_faces_array GEOMETRY[];
		card_faces_array GEOMETRY[];
		rack_guitar_line GEOMETRY;
		rack_up_guitar_line GEOMETRY;
		card_line GEOMETRY;
		card_guitar_line GEOMETRY;
		new_fiber_layout_geom GEOMETRY;
		card_guitar_line_points GEOMETRY;
		card_bottom_line GEOMETRY;
		card_bottom_guitar_line GEOMETRY;
		aux_line GEOMETRY;
		min_distance FLOAT;
		n_ports_on_card INTEGER;
		n_fibers_crossing_rack INTEGER;
	BEGIN
		SELECT * INTO fiber_record FROM gis.fo_fiber WHERE id_gis = id_gis_fiber;
		SELECT * INTO port_record FROM gis.port WHERE id_gis = id_gis_port;
		SELECT * INTO rack_record FROM gis.rack WHERE ST_Intersects(layout_geom, port_record.geom);
		SELECT * INTO card_record FROM gis.card WHERE ST_Intersects(layout_geom, port_record.geom);		
		n_ports_on_card := (SELECT count(*) FROM gis.port WHERE ST_Contains(card_record.layout_geom, geom));
		
		-- Saco las caras de todos los elementos necesarios para genrar las autovías de conetividad
		rack_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=5))
			];

		card_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(card_record.layout_geom) WHERE path[2]=5))
			];

		-- Se obtienen las caras por als que vana  air las autopistas
		FOR i IN 1..array_length(rack_faces_array,1)
		LOOP			
			IF min_distance IS NULL OR (ST_Distance(rack_faces_array[i], fiber_record.layout_geom) > 0.000003 AND ST_Distance(rack_faces_array[i], fiber_record.layout_geom) < min_distance)
			THEN
				min_distance := ST_Distance(rack_faces_array[i], fiber_record.layout_geom);
				rack_up_guitar_line := rack_faces_array[i];
			ELSIF ST_Distance(rack_faces_array[i], fiber_record.layout_geom) < 0.000003
			THEN
				rack_guitar_line := rack_faces_array[i];
			END IF;
		END LOOP;


		min_distance := NULL;

		FOR i IN 1..array_length(card_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(card_faces_array[i]), rack_up_guitar_line) < min_distance
			THEN
				min_distance := ST_Distance(ST_Centroid(card_faces_array[i]), rack_up_guitar_line);
				card_line := card_faces_array[i];
			END IF;
		END LOOP;

		min_distance := NULL;

		FOR i IN 1..array_length(card_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(card_faces_array[i]), ST_Centroid(rack_guitar_line)) < min_distance
			THEN
				min_distance := ST_Distance(ST_Centroid(card_faces_array[i]), ST_Centroid(rack_guitar_line));
				card_bottom_line := card_faces_array[i];
			END IF;
		END LOOP;

		-- Se generan las caras con offset apra que la fibra recorra la autopista
		n_fibers_crossing_rack := (SELECT count(*) FROM gis.fo_fiber WHERE ST_Length(ST_Intersection(rack_record.layout_geom, layout_geom)) > 0.0003);
		rack_guitar_line := ST_OffsetCurve(rack_guitar_line, -0.0001 * (n_fibers_crossing_rack + 1),'quad_segs=4 join=mitre mitre_limit=2.2');
		rack_up_guitar_line := ST_OffsetCurve(rack_up_guitar_line, -0.0001 * (n_fibers_crossing_rack + 1),'quad_segs=4 join=mitre mitre_limit=2.2');

		FOR i IN 1..n_ports_on_card
		LOOP
			card_guitar_line := ST_OffsetCurve(card_line, -0.0000375 * i,'quad_segs=4 join=mitre mitre_limit=2.2');
			card_bottom_guitar_line := ST_OffsetCurve(card_bottom_line, -0.0000375 * i,'quad_segs=4 join=mitre mitre_limit=2.2');
			card_guitar_line_points := ST_LineInterpolatePoints(card_guitar_line, (1/n_ports_on_card::FLOAT), true);

			IF (SELECT count(*) FROM gis.fo_fiber WHERE ST_Intersects(layout_geom, ST_GeometryN(card_guitar_line_points, i))) = 0
			THEN
				IF (ST_Distance(ST_EndPoint(fiber_record.layout_geom), rack_record.layout_geom) < 0.000003)
				THEN
					-- Se gemera ña utopista
					new_fiber_layout_geom := ST_MakeLine(
							fiber_record.layout_geom,
							ST_ShortestLine(ST_EndPoint(fiber_record.layout_geom), rack_guitar_line)
						);
						
					new_fiber_layout_geom := ST_MakeLine(
							new_fiber_layout_geom,
							ST_ShortestLine(ST_EndPoint(new_fiber_layout_geom), rack_up_guitar_line)
						);
		
					new_fiber_layout_geom := ST_MakeLine(
							new_fiber_layout_geom,
							ST_Intersection(ST_ShortestLine(rack_up_guitar_line, ST_GeometryN(card_guitar_line_points, i)), rack_up_guitar_line)
						);
		
					new_fiber_layout_geom := ST_MakeLine(
							new_fiber_layout_geom,
							ST_ShortestLine(rack_up_guitar_line, ST_GeometryN(card_guitar_line_points, i))
						);

					new_fiber_layout_geom := ST_MakeLine(
							new_fiber_layout_geom,
							ST_ShortestLine(ST_EndPoint(new_fiber_layout_geom), card_bottom_guitar_line)
						);

					aux_line := ST_OffsetCurve(
							ST_ShortestLine(card_bottom_guitar_line, port_record.geom), 
							0.0002 + (0.0000375 * i), 
							'quad_segs=4 join=mitre mitre_limit=2.2'
						);

					new_fiber_layout_geom := ST_MakeLine(
							new_fiber_layout_geom,
							ST_Intersection(
								card_bottom_guitar_line,
								aux_line)
						);

					new_fiber_layout_geom := ST_MakeLine(
							new_fiber_layout_geom,
							aux_line
						);

					new_fiber_layout_geom := ST_MakeLine(
							new_fiber_layout_geom,
							port_record.geom
						);

					UPDATE gis.fo_fiber
						SET
							layout_geom = new_fiber_layout_geom,
							source = null,
							target = null
						WHERE id_gis = fiber_record.id_gis;
					EXIT;
				END IF;
			ELSE
				-- TODO hilos de salida de puertos
			END IF;

		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION connect_cable_rack(id_gis_cable VARCHAR, id_gis_rack VARCHAR) RETURNS VOID AS 
	$$
	DECLARE
		cable_record RECORD;
		rack_record RECORD;
		location_record RECORD;
		building_record RECORD;
		floor_record RECORD;
		current_cable RECORD;
		new_cable_layout_geom GEOMETRY;
		building_faces_array GEOMETRY[];
		floor_faces_array GEOMETRY[];
		location_faces_array GEOMETRY[];
		rack_faces_array GEOMETRY[];
		building_bottom_line GEOMETRY;
		building_bottom_guitar_line GEOMETRY;
		building_up_line GEOMETRY;
		building_up_guitar_line GEOMETRY;
		floor_bottom_line GEOMETRY;
		floor_bottom_guitar_line GEOMETRY;
		floor_up_line GEOMETRY;
		floor_up_guitar_line GEOMETRY;
		floor_up_line_points GEOMETRY;
		location_bottom_line GEOMETRY;
		location_up_line GEOMETRY;
		aux_line GEOMETRY;
		location_face_points GEOMETRY;
		location_up_guitar_line GEOMETRY;
		location_bottom_guitar_line GEOMETRY;
		rack_in_line GEOMETRY;
		rack_in_guitar_line GEOMETRY;
		min_distance FLOAT;
		pos INTEGER;
		pos_floor INTEGER;
		encontrado BOOLEAN;
	BEGIN 
		SELECT * INTO cable_record FROM gis.fo_cable WHERE id_gis = id_gis_cable;
		SELECT * INTO rack_record FROM gis.rack WHERE id_gis = id_gis_rack;
		SELECT * INTO building_record FROM gis.cw_building WHERE ST_Intersects(layout_geom, rack_record.layout_geom);
		SELECT * INTO location_record FROM gis.cw_client WHERE ST_Intersects(layout_geom, rack_record.layout_geom);
		SELECT * INTO floor_record FROM gis.cw_floor WHERE ST_Intersects(layout_geom, rack_record.layout_geom);

		IF location_record IS NULL
		THEN
			SELECT * INTO location_record FROM gis.cw_room WHERE ST_Intersects(layout_geom, rack_record.layout_geom);
		END IF;

		-- Saco las caras de todos los elementos necesarios para genrar las autovías de conetividad
		building_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2]=5))
			];

		floor_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(floor_record.layout_geom) WHERE path[2]=5))
			];

		location_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(location_record.layout_geom) WHERE path[2]=5))
			];

		rack_faces_array := ARRAY[
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=1), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=2), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=3), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4)),
				ST_MakeLine(
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=4), 
					(SELECT geom FROM ST_DumpPoints(rack_record.layout_geom) WHERE path[2]=5))
			];
		
		FOR i IN 1..array_length(building_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(building_faces_array[i], cable_record.layout_geom) < min_distance
			THEN
				min_distance := ST_Distance(building_faces_array[i], cable_record.layout_geom);
				building_bottom_line := building_faces_array[i];
				IF i <> array_length(building_faces_array,1) 
				THEN
					building_up_line := building_faces_array[i + 1];
				ELSE
					building_up_line := building_faces_array[i -3];
				END IF;
			END IF;
		END LOOP;

		min_distance := NULL;

		FOR i IN 1..array_length(floor_faces_array,1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(floor_faces_array[i]), building_up_line) < min_distance
			THEN
				min_distance := ST_Distance(ST_Centroid(floor_faces_array[i]), building_up_line);
				floor_up_line := floor_faces_array[i];
				IF i <> 1
				THEN
					floor_bottom_line := floor_faces_array[i - 1];
				ELSE
					floor_bottom_line := floor_faces_array[i + 3];
				END IF;
			END IF;
		END LOOP;
		
		-- SE calculan las caras mas cercanas del cliete en funcion del floor up line
		min_distance := NULL;

		FOR i IN 1..array_length(location_faces_array, 1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(location_faces_array[i]), floor_up_line) < min_distance
			THEN		
				min_distance := ST_Distance(ST_Centroid(location_faces_array[i]), floor_up_line);
				location_up_line := location_faces_array[i];
				IF i <> 1
				THEN
					location_bottom_line := location_faces_array[i - 1];
				ELSE
					location_bottom_line := location_faces_array[i + 3];
				END IF;
			END IF;
		END LOOP;

		--  Calculod e la cara de entrada del rack alq ue se queire conectar
		min_distance := NULL;
		FOR i IN 1..array_length(rack_faces_array, 1)
		LOOP
			IF min_distance IS NULL OR ST_Distance(ST_Centroid(rack_faces_array[i]), location_bottom_line) < min_distance
			THEN		
				min_distance := ST_Distance(ST_Centroid(rack_faces_array[i]), location_bottom_line);
				rack_in_line := rack_faces_array[i];
			END IF;
		END LOOP;

		pos = 1;

		pos := (SELECT count(*) FROM gis.fo_cable as ca WHERE ST_Distance(ca.layout_geom, building_record.layout_geom) < 0.0003
			AND (SELECT count(*) FROM gis.fo_splice as sp WHERE ST_Distance(ca.layout_geom ,sp.layout_geom) < 0.0003
				AND ST_Intersects(sp.layout_geom, building_record.layout_geom)) = 0) + 1;

		building_bottom_guitar_line := ST_OffsetCurve(building_bottom_line, -0.5 + (-0.0125 * pos), 'quad_segs=4 join=mitre mitre_limit=2.2');
		building_up_guitar_line := ST_OffsetCurve(building_up_line, -1 + (-0.0125 * pos), 'quad_segs=4 join=mitre mitre_limit=2.2');

		floor_up_guitar_line := ST_OffsetCurve(
				floor_up_line,
				-0.0075 * ((SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, floor_record.layout_geom)) + 1),
				'quad_segs=4 join=mitre mitre_limit=2.2'
			);

		floor_bottom_guitar_line := ST_OffsetCurve(
				floor_bottom_line,
				-0.0075 * ((SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, floor_record.layout_geom)) + 1),
				'quad_segs=4 join=mitre mitre_limit=2.2'
			);		

		location_up_guitar_line := ST_OffsetCurve(
				location_up_line,
				-0.0075 * ((SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, location_record.layout_geom) < 0.00003) + 1),
				'quad_segs=4 join=mitre mitre_limit=2.2'
			);

		location_bottom_guitar_line := ST_OffsetCurve(
				location_bottom_line,
				-0.0075 * ((SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, location_record.layout_geom) < 0.00003) + 1),
				'quad_segs=4 join=mitre mitre_limit=2.2'
			);		

		IF ST_Distance(ST_EndPoint(cable_record.layout_geom), building_record.layout_geom) > ST_Distance(ST_StartPoint(cable_record.layout_geom), building_record.layout_geom)
		THEN
			new_cable_layout_geom := ST_Reverse(cable_record.layout_geom);
		ELSE
			new_cable_layout_geom := cable_record.layout_geom;
		END IF;

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), building_bottom_guitar_line)
			);
				
		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), building_up_guitar_line)
			);

		floor_up_line_points := ST_LineInterpolatePoints(floor_up_line, 0.045, true);
		
		FOR i IN 1..ST_NumGeometries(floor_up_line_points)
		LOOP
			pos := ST_NumGeometries(floor_up_line_points) - i;
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Intersects(layout_geom, ST_GeometryN(floor_up_line_points, pos))) = 0
			THEN
				new_cable_layout_geom := ST_MakeLine(
						new_cable_layout_geom,
						ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_Intersection(building_up_guitar_line, ST_ShortestLine(building_up_line, ST_GeometryN(floor_up_line_points, pos))))
					);

				new_cable_layout_geom := ST_MakeLine(
						new_cable_layout_geom,
						ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_GeometryN(floor_up_line_points, pos))
					);						
				EXIT;
			END IF;
		END LOOP;

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), floor_up_guitar_line)
			);	

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), floor_bottom_guitar_line)
			);	

		location_face_points := ST_LineInterpolatePoints(location_bottom_line, 0.045, true);

		FOR i IN 1..ST_NumGeometries(location_face_points)
		LOOP
			pos := ST_NumGeometries(location_face_points) - i;
			IF (SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, ST_GeometryN(location_face_points, pos)) < 0.00003) = 0
			THEN
				new_cable_layout_geom := ST_MakeLine(
						new_cable_layout_geom,
						ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_Intersection(floor_bottom_guitar_line, ST_ShortestLine(floor_bottom_line, ST_GeometryN(location_face_points, pos))))
					);	

				new_cable_layout_geom := ST_MakeLine(
						new_cable_layout_geom,
						ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_GeometryN(location_face_points, pos))
					);	
				EXIT;
			END IF;
		END LOOP;

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), location_bottom_guitar_line)
			);	

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), location_up_guitar_line)
			);	

		rack_in_guitar_line := ST_LineExtend(
			ST_OffsetCurve(
				rack_in_line, 
				0.0075 * ((SELECT count(*) FROM gis.fo_cable WHERE ST_Distance(layout_geom, rack_record.layout_geom) < 0.0001) + 1), 
				'quad_segs=4 join=mitre mitre_limit=2.2'), 
			0.50, 
			0.50);

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_Intersection(rack_in_guitar_line, location_up_guitar_line))
			);	

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_Intersection(rack_in_guitar_line, ST_LineExtend(ST_ShortestLine(rack_in_guitar_line, ST_GeometryN(ST_LineInterpolatePoints(rack_in_line, 0.05, true), 19)), 0.005, 0.005)))
			);	

		new_cable_layout_geom := ST_MakeLine(
				new_cable_layout_geom,
				ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_GeometryN(ST_LineInterpolatePoints(rack_in_line, 0.05, true), 19))
			);


		IF ST_Distance(ST_EndPoint(cable_record.layout_geom), building_record.layout_geom) > ST_Distance(ST_StartPoint(cable_record.layout_geom), building_record.layout_geom)
		THEN
			new_cable_layout_geom := ST_Reverse(new_cable_layout_geom);
		END IF; 

		UPDATE gis.fo_cable 
			SET
				layout_geom = new_cable_layout_geom
			WHERE id_gis = cable_record.id_gis;

		SELECT * INTO cable_record FROM gis.fo_cable WHERE id_gis = cable_record.id_gis;

		PERFORM update_fo_fiber_to_splice(cable_record.id_gis, cable_record.layout_geom);
	END;
	$$
LANGUAGE plpgsql;


/*markdown
INSERCION DE POZOS
*/

	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-404270.31 4928508.68)', 'square');							  
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-404346.69 4928643.55)', 'square');							  
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-404204.97 4928712.77)', 'square');							  
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-404061.86 4928795.84)', 'square');
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-403830.22 4928927.29)', 'square');	
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-403911.74 4929074.14)', 'square');
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-403772.35 4928823.38)', 'cylindric');
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-403596.88 4929067.92)', 'cylindric');
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-403695.08 4928688.35)', 'cylindric');							  
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-403608.66 4928732.30)', 'cylindric');
	INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-404338.45 4928470.91)', 'cylindric');

/*markdown
INSERCION DE POSTES
*/	
	
	INSERT INTO gis.cw_pole(geom) VALUES('SRID=3857;POINT(-403976.17 4929178.57)');	
	INSERT INTO gis.cw_pole(geom) VALUES('SRID=3857;POINT(-404017.00 4929257.68)');
	INSERT INTO gis.cw_pole(geom) VALUES('SRID=3857;POINT(-404118.58 4929237.43)');
	INSERT INTO gis.cw_pole(geom) VALUES('SRID=3857;POINT(-403893.58 4929214.64)');

/*markdown
INSERCION DE RUTAS TERRESTRES
*/

	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');	
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');	
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');	
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');	
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');	
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)');
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)');
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)');


/*markdown
INSERCION DE RUTAS AEREAS
*/

	INSERT INTO gis.cw_skyway(geom) VALUES('SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)');
	INSERT INTO gis.cw_skyway(geom) VALUES('SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)');
	INSERT INTO gis.cw_skyway(geom) VALUES('SRID=3857;LINESTRING(-404017.00 4929257.68, -404118.58 4929237.43)');
	INSERT INTO gis.cw_skyway(geom) VALUES('SRID=3857;LINESTRING(-403976.17 4929178.57, -403893.58 4929214.64)');

/*markdown
INSERCIÓN DE CONDUCTOS
*/

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');	

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)');

	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)');
	INSERT INTO gis.cw_duct(geom) VALUES('SRID=3857;LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)');
	
/*markdown
INSERCIÓN DE EMPALMES
*/

	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-403830.22 4928927.29)');	
	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-403830.22 4928927.29)');	
	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-403830.22 4928927.29)');
	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-403976.17 4929178.57)');	
	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-403976.17 4929178.57)');
	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-404017.00 4929257.68)');
	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-403695.08 4928688.35)');	
	INSERT INTO gis.fo_splice(geom) VALUES('SRID=3857;POINT(-403695.08 4928688.35)');	

/*markdown
INSERCIÓN DE CABLES POR CANALIZACIONES
*/

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_1','SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_1','SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_2','SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_2','SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_3','SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_3','SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_5','SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_5','SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_7','SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_7','SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_9','SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_9','SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_11','SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_11','SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_13','SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_13','SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)');

/*markdown
	CABLES DE FIBRA QUE POR RUTA AEREA
*/
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)');

/*markdown
	CABLES DE FIBRA QUE PASAN DE LARGO
*/
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57, -404017.00 4929257.68)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57, -404017.00 4929257.68, -404118.58 4929237.43)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57, -403893.58 4929214.64)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84, -403830.22 4928927.29)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_1, cw_duct_3, cw_duct_5, null','SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84, -403830.22 4928927.29)');

/*markdown
	INSERCIÓN DE CABLES POR CANALIZACIONES
*/
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_15','SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES('cw_duct_16','SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)');

/*markdown
	INSERT DE SPLITTERS
*/

	SELECT insert_optical_splitter('fo_splice_2', 4);
	SELECT insert_optical_splitter('fo_splice_2', 16);
	SELECT insert_optical_splitter('fo_splice_7', 8);

/*markdown
	CONEXIÓN DE CABLES
*/

	SELECT connect_objects('fo_cable_23', 'fo_splice_1');
	SELECT connect_objects('fo_cable_20', 'fo_splice_2');
	SELECT connect_objects('fo_cable_21', 'fo_splice_2');
	SELECT connect_objects('fo_cable_22', 'fo_splice_2');
	SELECT connect_objects('fo_cable_24', 'fo_splice_2');
	SELECT connect_objects('fo_cable_28', 'fo_splice_2');
	SELECT connect_objects('fo_cable_33', 'fo_splice_2');

	SELECT connect_objects('fo_cable_51', 'fo_splice_7');
	SELECT connect_objects('fo_cable_54', 'fo_splice_7');
	SELECT connect_objects('fo_cable_52', 'fo_splice_8');
	SELECT connect_objects('fo_cable_53', 'fo_splice_8');

/*markdown
	CONEXIÓN DE CABLES EN POSTES
*/

	SELECT connect_objects('fo_cable_38', 'fo_splice_4');
	SELECT connect_objects('fo_cable_39', 'fo_splice_5');
	SELECT connect_objects('fo_cable_42', 'fo_splice_4');
	SELECT connect_objects('fo_cable_43', 'fo_splice_5');

/*markdown
	CONEXIÓN DE HILOS
*/

	CREATE OR REPLACE FUNCTION connect_fibers() RETURNS void
		AS
		$$
		DECLARE
			fibra_inicio INTEGER;
			fibra_fin INTEGER;
		BEGIN
			FOR i IN 1..144
			LOOP
				fibra_inicio:=2736;
				fibra_fin:=3312;
				PERFORM connect_objects(CONCAT('fo_fiber_', (fibra_inicio + i)::TEXT), CONCAT('fo_fiber_', (fibra_fin + i)::TEXT));

				fibra_inicio:=2880;
				fibra_fin:=3888;
				PERFORM connect_objects(CONCAT('fo_fiber_', (fibra_inicio + i)::TEXT), CONCAT('fo_fiber_', (fibra_fin + i)::TEXT));

				fibra_inicio:=3024;
				fibra_fin:=4608;
				PERFORM connect_objects(CONCAT('fo_fiber_', (fibra_inicio + i)::TEXT), CONCAT('fo_fiber_', (fibra_fin + i)::TEXT));
			END LOOP;
		END;
		$$
	LANGUAGE plpgsql;

	SELECT connect_fibers();

	SELECT connect_objects('fo_fiber_7210', 'fo_fiber_7635');
	SELECT connect_objects('fo_fiber_7215', 'fo_fiber_7636');
	SELECT connect_objects('fo_fiber_7216', 'fo_fiber_7637');

/*markdown
	CONEXIÓN DE HILOS EN POSTES
*/

	SELECT connect_objects('fo_fiber_5330', 'fo_fiber_5910');
	SELECT connect_objects('fo_fiber_5335', 'fo_fiber_5915');
	SELECT connect_objects('fo_fiber_5475', 'fo_fiber_6050');
	SELECT connect_objects('fo_fiber_5480', 'fo_fiber_6055');

/*markdown
	CONEXIóN CON SPLITTERS
*/

	SELECT connect_objects('fo_fiber_7221', 'in_port_3');
	SELECT connect_objects('fo_fiber_7640', 'out_port_21');
	SELECT connect_objects('fo_fiber_7645', 'out_port_22');

/*markdown
	INSERCIÓN DE BUIDLINGS
*/

	INSERT INTO gis.cw_building(geom, n_floors, n_clients) 
		values(
			'SRID=3857;POINT(-403832.20 4928977.44)',
			30,
			10
		);

	INSERT INTO gis.cw_building(geom, n_floors, n_clients) 
		values(
			'SRID=3857;POINT(-403884.22 4929191.55)',
			9,
			10
		);


	INSERT INTO gis.cw_skyway(geom) VALUES('SRID=3857;LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)');
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-403830.22 4928927.29, -403832.20 4928977.44)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)');

	SELECT insert_fo_splice_on_building('cw_building_2', 1);
	SELECT insert_optical_splitter('fo_splice_9', 8);

	SELECT connect_cable('fo_cable_55', 'fo_splice_9');
	SELECT connect_fiber_splitter_port('fo_fiber_7780', 'in_port_4');
	SELECT insert_client_on_floor('cw_floor_37');

	SELECT insert_ont_on_client('cw_client_355');
	SELECT insert_ont_on_client('cw_client_341');
	SELECT insert_ont_on_client('cw_client_342');
	SELECT insert_ont_on_client('cw_client_343');
	SELECT insert_ont_on_client('cw_client_311');
	SELECT insert_ont_on_client('cw_client_303');

	SELECT connect_objects('fo_splice_9', 'cw_client_343');
	SELECT connect_objects('fo_splice_9', 'cw_client_341');
	SELECT connect_objects('fo_splice_9', 'cw_client_342');
	SELECT connect_objects('fo_splice_9', 'cw_client_303');
	SELECT connect_objects('fo_splice_9', 'cw_client_311');

	-- SELECT connect_objects('fo_fiber_7921', 'out_port_32');
	-- SELECT connect_objects('fo_fiber_7925', 'out_port_35');

	SELECT insert_fo_splice_on_building('cw_building_2', 5);
	SELECT connect_objects('fo_splice_9', 'fo_splice_10');
	SELECT insert_optical_splitter('fo_splice_10', 16);

	-- SELECT connect_objects('fo_fiber_7934', 'in_port_5');
	-- SELECT connect_objects('fo_fiber_7930', 'out_port_36');

	-- SELECT connect_objects('fo_fiber_7922', 'optical_network_terminal_2');
	-- SELECT connect_objects('fo_fiber_7923', 'optical_network_terminal_3');
	-- SELECT connect_objects('fo_fiber_7921', 'optical_network_terminal_4');
	-- SELECT connect_objects('fo_fiber_7925', 'optical_network_terminal_5');
	-- SELECT connect_objects('fo_fiber_7924', 'optical_network_terminal_6');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)');
	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-404338.45 4928470.91, -404270.31 4928508.68)');

	SELECT insert_rack('cw_client_343', 'NGXC-3600  Bay');
	SELECT connect_objects('fo_splice_10', 'rack_1');

	SELECT insert_rack('cw_client_352', 'Alcatel ODF Rack');
	SELECT connect_objects('fo_splice_10', 'rack_2');

	SELECT insert_rack('cw_client_369', 'NGXC-3600  Bay');
	SELECT connect_objects('fo_splice_10', 'rack_3');

	SELECT insert_rack('cw_client_352', 'NGXC-3600  Bay');
	SELECT connect_objects('fo_splice_10', 'rack_4');
	SELECT insert_rack('cw_client_352', 'Wallbox');
	SELECT connect_objects('fo_splice_10', 'rack_5');
	SELECT insert_rack('cw_client_352', 'NGXC-3600  Bay');
	SELECT connect_objects('fo_splice_10', 'rack_6');
	SELECT insert_rack('cw_client_352', 'Wallbox');
	SELECT connect_objects('fo_splice_10', 'rack_7');
	SELECT insert_rack('cw_client_352', '1660 19" Bay');
	SELECT connect_objects('fo_splice_10', 'rack_8');
	SELECT insert_rack('cw_client_352', 'NGXC-3600  Bay');
	SELECT connect_objects('fo_splice_10', 'rack_9');

	SELECT insert_shelf_on_rack('rack_4', 'LANscape 2U');
	SELECT insert_shelf_on_rack('rack_4', '7342 AFAN-R');
	SELECT insert_shelf_on_rack('rack_4', '7342 AFAN-R');

	SELECT insert_card_on_rack('rack_4', 'STM-4 S4.1N', 5, 10);
	SELECT insert_card_on_rack('rack_4', 'E1LT-A', 1, 15);
	
	SELECT insert_card_on_shelf('shelf_1', 'VX2000-MD Line Card', 1, 15);
	SELECT insert_card_on_shelf('shelf_1', 'ADSL2-24', 6, 10);
	SELECT insert_card_on_shelf('shelf_1', 'COMBO-24', 1, 15);

	SELECT connect_objects('fo_fiber_9559', 'port_123');
	SELECT connect_objects('fo_fiber_9550', 'port_115');
	SELECT connect_objects('fo_fiber_9551', 'port_117');
	SELECT connect_objects('fo_fiber_9552', 'port_135');
	SELECT connect_objects('fo_fiber_9553', 'port_120');
	SELECT connect_objects('fo_fiber_9555', 'port_71');
	SELECT connect_objects('fo_fiber_9556', 'port_23');
	SELECT connect_objects('fo_fiber_9557', 'port_60');

	SELECT connect_objects('fo_fiber_8378', 'optical_network_terminal_6');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)');

	SELECT insert_rack('cw_client_388', 'MDU Bay');
	SELECT connect_objects('fo_cable_73', 'rack_10');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)');

	SELECT insert_rack('cw_client_378', 'MDU Bay');
	SELECT connect_objects('fo_cable_74', 'rack_11');

	INSERT INTO gis.fo_cable(id_duct, geom) VALUES(null,'SRID=3857;LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)');

	SELECT insert_rack('cw_client_370', 'MDU Bay');
	SELECT connect_objects('fo_cable_75', 'rack_12');

	SELECT update_fiber_topology();

/*
	PRUEBAS DE INSERT CERCA PERO NO JUSTO ENCIMA
*/
	INSERT INTO gis.cw_ground_route(geom) VALUES('SRID=3857;LINESTRING(-404065.0 4928520.0, -403584.6 4928482.5)');
	-- INSERT INTO gis.cw_sewer_box(geom, specification) VALUES('SRID=3857;POINT(-403583.64 4928480.38)', 'square');