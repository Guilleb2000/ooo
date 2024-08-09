
CREATE EXTENSION postgis;

CREATE EXTENSION postgis_raster;

CREATE EXTENSION fuzzystrmatch;

CREATE EXTENSION postgis_tiger_geocoder;

CREATE EXTENSION postgis_topology;

CREATE EXTENSION address_standardizer_data_us;

CREATE EXTENSION pgrouting;

CREATE SCHEMA objects;

CREATE SCHEMA template;

CREATE SCHEMA alt_1;

CREATE SCHEMA alt_2;

CREATE SCHEMA alt_3;

CREATE SCHEMA alt_4;

CREATE SCHEMA alt_5;

CREATE SCHEMA alt_6;

CREATE SCHEMA alt_7;

CREATE SCHEMA alt_8;

CREATE SCHEMA alt_9;

CREATE SCHEMA alt_10;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION create_qlr_file(
    dbname TEXT,
    host TEXT,
    port TEXT,
    password TEXT,
    key TEXT,
    wkbType TEXT,
    layerName TEXT,
    scheme TEXT,
    geomField TEXT,
    srid TEXT
)
RETURNS TEXT AS $$
DECLARE
    qlrContent TEXT;
BEGIN
    qlrContent := '<!DOCTYPE qgis-layer-definition>
                   <qlr>
                     <layer-tree-group name="" groupLayer="" expanded="1" checked="Qt::Checked">
                       <layer-tree-layer source="dbname=''' || dbname || ''' host=' || host || ' port=' || port || ' password=''' || password || ''' key=''' || key || ''' srid=' || srid || ' type=' || wkbType || ' checkPrimaryKeyUnicity=''1'' table=&quot;' || scheme || '&quot;.&quot;' || layerName || '&quot; (' || geomField || ')" name="' || layerName || '" expanded="1" patch_size="-1,-1" id="' || layerName || '" checked="Qt::Checked" providerKey="postgres">
                       </layer-tree-layer>
                     </layer-tree-group>
                     <maplayers>
                       <maplayer type="vector" hasScaleBasedVisibilityFlag="0" minScale="100000000" wkbType="' || wkbType || '" maxScale="0" geometry="Line">
                         <id>' || layerName || '</id>
                         <datasource>dbname=''' || dbname || ''' host=' || host || ' port=' || port || ' password=''' || password || ''' key=''' || key || ''' srid=' || srid || ' type=' || wkbType || ' checkPrimaryKeyUnicity=''1'' table="' || scheme || '"."' || layerName || '" (' || geomField || ')</datasource>
                         <layername>' ||scheme||'.'|| layerName ||'.'|| geomField ||'</layername>
                         <srs>
                           <spatialrefsys nativeFormat="Wkt">
                             <wkt>GEOGCRS["WGS 84",ENSEMBLE["World Geodetic System 1984 ensemble",MEMBER["World Geodetic System 1984 (Transit)"],MEMBER["World Geodetic System 1984 (G730)"],MEMBER["World Geodetic System 1984 (G873)"],MEMBER["World Geodetic System 1984 (G1150)"],MEMBER["World Geodetic System 1984 (G1674)"],MEMBER["World Geodetic System 1984 (G1762)"],MEMBER["World Geodetic System 1984 (G2139)"],ELLIPSOID["WGS 84",6378137,298.257223563,LENGTHUNIT["metre",1]],ENSEMBLEACCURACY[2.0]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]],CS[ellipsoidal,2],AXIS["geodetic latitude (Lat)",north,ORDER[1],ANGLEUNIT["degree",0.0174532925199433]],AXIS["geodetic longitude (Lon)",east,ORDER[2],ANGLEUNIT["degree",0.0174532925199433]],USAGE[SCOPE["Horizontal component of 3D system."],AREA["World."],BBOX[-90,-180,90,180]],ID["EPSG",4326]]</wkt>
                             <proj4>+proj=longlat +datum=WGS84 +no_defs</proj4>
                             <srsid>' || srid || '</srsid>
                             <srid>' || srid || '</srid>
                             <authid>EPSG:' || srid || '</authid>
                             <description>WGS 84</description>
                             <projectionacronym>longlat</projectionacronym>
                             <ellipsoidacronym>EPSG:7030</ellipsoidacronym>
                             <geographicflag>true</geographicflag>
                           </spatialrefsys>
                         </srs>
                       </maplayer>
                     </maplayers>
                   </qlr>';

    RETURN qlrContent;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION generate_all_qlr_files(
    dbname TEXT,
    host TEXT,
    port TEXT,
    password TEXT,
    key TEXT
)
RETURNS TABLE(scheme TEXT, layername TEXT, geomfield TEXT, qlr_content TEXT) AS $$
DECLARE
    rec RECORD;
    qlr TEXT;
BEGIN
    FOR rec IN
        SELECT f_table_schema AS scheme,
               f_table_name AS layername,
               f_geometry_column AS geomfield,
               type AS wkbtype,
               srid
        FROM geometry_columns
    LOOP
        qlr := create_qlr_file(
            dbname,
            host,
            port,
            password,
            key,
            rec.wkbtype,
            rec.layername,
            rec.scheme,
            rec.geomfield,
            rec.srid::TEXT
        );

        -- Asignar valores a las columnas de salida
        scheme := rec.scheme;
        layername := rec.layername;
        geomfield := rec.geomfield;
        qlr_content := qlr;

        -- Devolver el registro
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION generate_all_qlr_files_scheme(
    dbname TEXT,
    host TEXT,
    port TEXT,
    password TEXT,
    key TEXT,
    specific_scheme TEXT -- nuevo parámetro para el esquema específico
)
RETURNS TABLE(scheme TEXT, layername TEXT, geomfield TEXT, qlr_content TEXT) AS $$
DECLARE
    rec RECORD;
    qlr TEXT;
BEGIN
    FOR rec IN
        SELECT f_table_schema AS scheme,
               f_table_name AS layername,
               f_geometry_column AS geomfield,
               type AS wkbtype,
               srid
        FROM geometry_columns
        WHERE f_table_schema = specific_scheme -- filtro por esquema específico
    LOOP
        qlr := create_qlr_file(
            dbname,
            host,
            port,
            password,
            key,
            rec.wkbtype,
            rec.layername,
            rec.scheme,
            rec.geomfield,
            rec.srid::TEXT
        );

        -- Asignar valores a las columnas de salida
        scheme := rec.scheme;
        layername := rec.layername;
        geomfield := rec.geomfield;
        qlr_content := qlr;

        -- Devolver el registro
        RETURN NEXT;
    END LOOP;
END;

$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION generate_all_qlr_files_scheme_db(
    dbname TEXT,
    specific_scheme TEXT,
    host TEXT,
    port TEXT,
    password TEXT,
    key TEXT
)
RETURNS TABLE(scheme TEXT, layername TEXT, geomfield TEXT, qlr_content TEXT) AS $$
DECLARE
    rec RECORD;
    qlr TEXT;
BEGIN
    FOR rec IN
        SELECT f_table_schema AS scheme,
               f_table_name AS layername,
               f_geometry_column AS geomfield,
               type AS wkbtype,
               srid
        FROM geometry_columns
        WHERE f_table_schema = specific_scheme -- filtro por esquema específico
    LOOP
        qlr := create_qlr_file(
            dbname,
            host,
            port,
            password,
            key,
            rec.wkbtype,
            rec.layername,
            rec.scheme,
            rec.geomfield,
            rec.srid::TEXT
        );

        -- Asignar valores a las columnas de salida
        scheme := rec.scheme;
        layername := rec.layername;
        geomfield := rec.geomfield;
        qlr_content := qlr;

        -- Devolver el registro
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
DROP TABLE IF EXISTS jeraquia.capa;
DROP TABLE IF EXISTS jeraquia.grupos;


--- ESTRUCTURA DE PROYECTO 
CREATE SCHEMA IF NOT EXISTS jeraquia;

CREATE TABLE jeraquia.grupos (
    nombre_directorio TEXT PRIMARY KEY
);

CREATE TABLE jeraquia.capa (
    layername TEXT PRIMARY KEY,
    nombre_directorio TEXT REFERENCES jeraquia.grupos(nombre_directorio)
);

--- Creación de grupos
INSERT INTO jeraquia.grupos (nombre_directorio) VALUES ('optic_fiber');
INSERT INTO jeraquia.grupos (nombre_directorio) VALUES ('obra_civil_exterior');
INSERT INTO jeraquia.grupos (nombre_directorio) VALUES ('obra_civil_interior');
--- Adición de las capas a los grupos

--- optic_fiber
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('fo_splice.layout_geom','optic_fiber');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('fo_cable.layout_geom','optic_fiber');

--- obra_civil_exterior
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_building.geom','obra_civil_exterior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_sewer_box.geom','obra_civil_exterior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_pole.geom','obra_civil_exterior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_skyway.geom','obra_civil_exterior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_ground_route.geom','obra_civil_exterior');

--- obra_civil_interior
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_building.layout_geom','obra_civil_interior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_sewer_box.layout_geom','obra_civil_interior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_skyway.layout_geom','obra_civil_interior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_connectivity_box.layout_geom','obra_civil_interior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_duct.layout_geom','obra_civil_interior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_ground_route.layout_geom','obra_civil_interior');
INSERT INTO jeraquia.capa (layername, nombre_directorio) VALUES ('cw_pole.layout_geom','obra_civil_interior');

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--ESQUEMA SECURITY Y TABLAS DE USUARIO
CREATE SCHEMA IF NOT EXISTS security;

DROP TABLE IF EXISTS security.authorities CASCADE;
CREATE TABLE security.authorities (
    id SERIAL PRIMARY KEY,
    authority_name TEXT NOT NULL
);

DROP TABLE IF EXISTS security.users CASCADE;
CREATE TABLE security.users (
    id UUID DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    username TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role INT REFERENCES security.authorities(id)
);

-- DROP TABLE IF EXISTS security.roles CASCADE;
-- CREATE TABLE security.roles (
--     id SERIAL PRIMARY KEY,
--     role_name TEXT NOT NULL
-- );

-- DROP TABLE IF EXISTS security.user_roles CASCADE;
-- CREATE TABLE security.user_roles (
--     user_id UUID REFERENCES security.users(id),
--     role_id INT REFERENCES security.roles(id),
--     PRIMARY KEY (user_id, role_id)
-- );

-- DROP TABLE IF EXISTS security.user_authorities CASCADE;
-- CREATE TABLE security.user_authorities (
--     user_id UUID REFERENCES security.users(id),
--     authority_id INT REFERENCES security.authorities(id),
--     PRIMARY KEY (user_id, authority_id)
-- );

INSERT INTO security.authorities(
	authority_name)
	VALUES ('ROLE_ADMIN');

INSERT INTO security.authorities(
	authority_name)
	VALUES ('ROLE_DEV');
	
INSERT INTO security.authorities(
	authority_name)
	VALUES ('ROLE_PM');

INSERT INTO security.authorities(
	authority_name)
	VALUES ('ROLE_GUEST');

INSERT INTO security.users (first_name, last_name, username, email, password, role)
  VALUES ('john', 'doe', 'jd', 'john@domain.test', '$argon2id$v=19$m=16384,t=2,p=1$/RJzMqXHoIQ/C2R2PqPMZg$9h9EG3comRGMypX3HFubS2LeDZtkK44XIkjKl1KrPfg', 1);

-- INSERT INTO security.user_authorities(
-- 	user_id, authority_id)
-- 	VALUES (
--     (SELECT id FROM security.users WHERE email = 'john@domain.test'), 
--     1
--   );
--
-- INSERT INTO security.user_authorities(
-- 	user_id, authority_id)
-- 	VALUES (
--     (SELECT id FROM security.users WHERE email = 'john@domain.test'), 
--     3
--   );
-- 	
-- INSERT INTO security.user_authorities(
-- 	user_id, authority_id)
-- 	VALUES (
--     (SELECT id FROM security.users WHERE email = 'john@domain.test'), 
--     4
--   );

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

drop table if exists public.branches;

CREATE TABLE IF NOT EXISTS public.schema_status (
    id SERIAL PRIMARY KEY,
    schema_name TEXT UNIQUE NOT NULL,
    in_use BOOLEAN DEFAULT FALSE
);

INSERT INTO public.schema_status (schema_name) VALUES
    ('alt_2'),
    ('alt_3'),
    ('alt_4'),
    ('alt_5'),
    ('alt_6'),
    ('alt_7'),
    ('alt_8'),
    ('alt_9'),
    ('alt_10');


CREATE TABLE IF NOT EXISTS public.branches (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE, -- Restricción UNIQUE en la columna name
    created_by UUID REFERENCES security.users(id) NOT NULL,
    schema_id INT REFERENCES public.schema_status(id)
);

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE merge_branch(
    _branch_name text
) LANGUAGE plpgsql
AS $$
DECLARE
    _source_schema text;
    _dest_schema CONSTANT text := 'objects';
    _schema_id INT;
    _branch_id BIGINT;
    _table_record record;
    _table record;
    _query_record record;
    _query text;
BEGIN
    -- Selecciona el esquema en uso y el ID de la rama
    SELECT s.schema_name, b.id INTO _source_schema, _branch_id
    FROM public.schema_status s
    JOIN public.branches b ON s.id = b.schema_id
    WHERE s.in_use = TRUE
    AND b.name = _branch_name
    LIMIT 1;

    -- Si no se encuentra el esquema, lanza una excepción.
    IF _source_schema IS NULL THEN
        RAISE EXCEPTION 'No branch schema found for branch %', _branch_name;
    END IF;

    -- Ejecutar todas las consultas almacenadas en query_merge de saved_changes
    FOR _query_record IN
        EXECUTE format('SELECT id, query_merge FROM %I.saved_changes', _source_schema)
    LOOP
        EXECUTE _query_record.query_merge;
    END LOOP;

    -- Transferir datos desde source.saved_changes a dest.saved_changes
    EXECUTE format('INSERT INTO %I.saved_changes (id, id_gis, change_time, record_time, user_id, query_merge, query_rollback)
                    SELECT id, id_gis, change_time, record_time, user_id, query_merge, query_rollback
                    FROM %I.saved_changes', _dest_schema, _source_schema);

    -- Iterar sobre todas las tablas en el esquema de origen y truncarlas
    FOR _table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = _source_schema
    LOOP
        EXECUTE format('TRUNCATE TABLE %I.%I CASCADE', _source_schema, _table_record.table_name);
    END LOOP;

    -- Eliminar las tablas en el esquema de origen
    FOR _table IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = _source_schema
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS %I.%I CASCADE', _source_schema, _table);
    END LOOP;
    
    -- Marcar el esquema como libre en schema_status
    UPDATE public.schema_status
    SET in_use = FALSE
    WHERE schema_name = _source_schema;
 
    -- Eliminar la rama actual de la tabla branches
    DELETE FROM public.branches
    WHERE id = _branch_id;
END;
$$;


---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


-- Function to add a new version name in 'branches' table and returns the new ID.
CREATE OR REPLACE FUNCTION add_version(
  _version_name text,
  _user_id UUID
) RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
  _branch_table CONSTANT text := 'branches';
  _sql text := format('INSERT INTO %I (name, created_by) VALUES ($1, $2) RETURNING id', _branch_table);
  _new_id bigint;
BEGIN
  -- Executes insert statement and gets the new ID
  EXECUTE _sql INTO _new_id USING _version_name, _user_id;
  
  -- Updates the branch name to include the new ID for uniqueness.
  UPDATE branches SET name = format('%s', _version_name) WHERE id = _new_id;
  
  RETURN _new_id;
END;
$$;

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

--CREATE VERSION CON CREACION DE TRIGGERS (NO SE SI FUNCIONA BIEN)
CREATE OR REPLACE PROCEDURE create_version(
    _base_schema text,
    _dest_schema text,
    _table_name text
) LANGUAGE plpgsql
AS $$
DECLARE
  _version_table text := _table_name;
  _update_function_exists boolean;
  _insert_function_exists boolean;
  _delete_function_exists boolean;
  _exclude_table text := 'saved_changes';
BEGIN
   -- Check if the update trigger function exists
   SELECT EXISTS (
       SELECT 1 FROM pg_proc WHERE proname = format('%I_update', _table_name)
   ) INTO _update_function_exists;

   -- Check if the insert function exists
   SELECT EXISTS (
       SELECT 1 FROM pg_proc WHERE proname = format('%I_insert', _table_name)
   ) INTO _insert_function_exists;

   -- Check if the delete function exists
   SELECT EXISTS (
       SELECT 1 FROM pg_proc WHERE proname = format('%I_delete', _table_name)
   ) INTO _delete_function_exists;

   -- Create the versioned table in the destination schema
   EXECUTE format('CREATE TABLE %I.%I (LIKE %I.%I INCLUDING ALL)', _dest_schema, _version_table, _base_schema, _table_name);

   IF _table_name != _exclude_table THEN
       -- Copy data from the original table to the new table, excluding 'saved_changes'
       EXECUTE format('INSERT INTO %I.%I SELECT * FROM %I.%I', _dest_schema, _version_table, _base_schema, _table_name);
   END IF;

   -- Create trigger for the new versioned table if the update trigger function exists
   IF _update_function_exists THEN
       EXECUTE format('CREATE TRIGGER %I_update_trigger AFTER UPDATE ON %I.%I FOR EACH ROW EXECUTE PROCEDURE %I_update()', _table_name, _dest_schema, _version_table, _table_name);
   END IF;

   -- Create trigger for the new versioned table if the insert trigger function exists
   IF _insert_function_exists THEN
       EXECUTE format('CREATE TRIGGER %I_insert_trigger AFTER INSERT ON %I.%I FOR EACH ROW EXECUTE PROCEDURE %I_insert()', _table_name, _dest_schema, _version_table, _table_name);
   END IF;

   -- Create trigger for the new versioned table if the delete trigger function exists
   IF _delete_function_exists THEN
       EXECUTE format('CREATE TRIGGER %I_delete_trigger AFTER DELETE ON %I.%I FOR EACH ROW EXECUTE PROCEDURE %I_delete()', _table_name, _dest_schema, _version_table, _table_name);
   END IF;

   -- Add triggers for other operations as needed
END;
$$;

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

-- Procedure to create a new branch including versioning of existing tables(top tables)
CREATE OR REPLACE PROCEDURE create_branch(_branch_name text, _user_id UUID)
LANGUAGE plpgsql
AS $$
DECLARE
    _table_record record;   
    _id BIGINT; -- Variable para almacenar el ID de la nueva versión
    _dest_schema text;
    _schema_id INT;
    _source_schema CONSTANT text := 'objects';
BEGIN
    -- Llama a 'add_version' para insertar el nombre de la rama y obtener el ID.
    _id := add_version(_branch_name, _user_id);

    -- Selecciona un esquema disponible y marca como en uso
    SELECT id, schema_name INTO _schema_id, _dest_schema
    FROM public.schema_status
    WHERE in_use = FALSE
    LIMIT 1;

    -- Si no se encuentra un esquema disponible, lanza una excepción.
    IF _dest_schema IS NULL THEN
        RAISE EXCEPTION 'No available schema found for branching';
    END IF;

    -- Marca el esquema seleccionado como en uso
    UPDATE public.schema_status
    SET in_use = TRUE
    WHERE id = _schema_id;

    -- Itera sobre todas las tablas en el esquema base, excepto 'branches'.
    FOR _table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = _source_schema -- top(main)
    LOOP
        IF _table_record.table_name <> 'branches' THEN
            -- Crea una copia versionada de cada tabla para la nueva rama.
            CALL create_version(_source_schema, _dest_schema, _table_record.table_name);
        END IF;
    END LOOP;

    -- Actualiza la tabla branches con el ID del esquema utilizado.
    UPDATE public.branches
    SET schema_id = _schema_id
    WHERE id = _id;
END;
$$;

----------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--TABLA PARA CAMBIOS
CREATE TABLE objects.saved_changes (
    id uuid,
    id_gis VARCHAR,
	change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id UUID REFERENCES security.users(id),
    query_merge TEXT,
    query_rollback TEXT
    );

----------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--TABLA RAMAS USUARIO
DROP TABLE IF EXISTS public.user_branches CASCADE;
CREATE TABLE public.user_branches (
  user_id UUID REFERENCES security.users(id),
  branch_id INT REFERENCES public.branches(id),
  PRIMARY KEY (user_id, branch_id)
);

----------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--SEWER BOX
CREATE TABLE objects.cw_sewer_box (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    name VARCHAR,
	life_cycle template.life_cycle_enum,
	specification template.cw_sewer_box_spec_enum,
	owner template.owner_enum,
    rotated BOOLEAN,
    geom geometry(POINT,3857),
    layout_geom geometry(POLYGON,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id),
    CONSTRAINT specification 
	    FOREIGN KEY(specification) 
            REFERENCES template.cw_sewer_box_spec(spec_name) 
);


CREATE OR REPLACE FUNCTION cw_sewer_box_insert() RETURNS trigger AS
$$
DECLARE  
    new_geom GEOMETRY;
    new_geom_cbox GEOMETRY;
    new_diagonal GEOMETRY;
    new_moved_geom GEOMETRY;
    width FLOAT := 3.75;
    width_cbox FLOAT := 2;
    schema_name TEXT := TG_TABLE_SCHEMA;
    edited_by_value UUID;
    count_end_ground_route INTEGER;
    count_start_ground_route INTEGER;
    count_end_skyway INTEGER;
    count_start_skyway INTEGER;
    specification_exists BOOLEAN;
BEGIN
    new_moved_geom := NEW.geom;

    -- Obtención de edited_by_value
    EXECUTE format('SELECT edited_by FROM %I.cw_sewer_box WHERE id_auto = $1', schema_name)
    INTO edited_by_value
    USING NEW.id_auto;
    
    -- Verificar si el campo specification existe en la tabla
    SELECT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = schema_name 
                   AND table_name = 'cw_sewer_box' 
                   AND column_name = 'specification')
    INTO specification_exists;

    IF NOT specification_exists THEN
        RAISE EXCEPTION 'El campo specification no existe en la tabla %I.cw_sewer_box', schema_name;
    END IF;

    -- Guardar los resultados de los conteos en variables usando EXECUTE
    EXECUTE format('SELECT COUNT(*) FROM %I.cw_ground_route WHERE ST_Distance($1, ST_EndPoint(geom)) < 4', schema_name) INTO count_end_ground_route USING NEW.geom;
    EXECUTE format('SELECT COUNT(*) FROM %I.cw_ground_route WHERE ST_Distance($1, ST_StartPoint(geom)) < 4', schema_name) INTO count_start_ground_route USING NEW.geom;
    EXECUTE format('SELECT COUNT(*) FROM %I.cw_skyway WHERE ST_Distance($1, ST_EndPoint(geom)) < 4', schema_name) INTO count_end_skyway USING NEW.geom;
    EXECUTE format('SELECT COUNT(*) FROM %I.cw_skyway WHERE ST_Distance($1, ST_StartPoint(geom)) < 4', schema_name) INTO count_start_skyway USING NEW.geom;

    -- Verificar y actualizar new_moved_geom en función de los resultados de los conteos
    IF count_end_ground_route > 0 THEN
        EXECUTE format('SELECT ST_EndPoint(geom) FROM %I.cw_ground_route WHERE ST_Distance($1, ST_EndPoint(geom)) < 4 LIMIT 1', schema_name) INTO new_moved_geom USING NEW.geom;
    ELSIF count_start_ground_route > 0 THEN
        EXECUTE format('SELECT ST_StartPoint(geom) FROM %I.cw_ground_route WHERE ST_Distance($1, ST_StartPoint(geom)) < 4 LIMIT 1', schema_name) INTO new_moved_geom USING NEW.geom;
    ELSIF count_end_skyway > 0 THEN
        EXECUTE format('SELECT ST_EndPoint(geom) FROM %I.cw_skyway WHERE ST_Distance($1, ST_EndPoint(geom)) < 4 LIMIT 1', schema_name) INTO new_moved_geom USING NEW.geom;
    ELSIF count_start_skyway > 0 THEN
        EXECUTE format('SELECT ST_StartPoint(geom) FROM %I.cw_skyway WHERE ST_Distance($1, ST_StartPoint(geom)) < 4 LIMIT 1', schema_name) INTO new_moved_geom USING NEW.geom;
    END IF;

    -- Crear la topología de la cara exterior que cortará los ductos
    IF (SELECT shape FROM template.cw_sewer_box_spec WHERE spec_name = NEW.specification) = 'square' THEN
        new_geom := ST_Buffer(new_moved_geom, width, 'endcap=square');
    ELSE
        new_geom := ST_Buffer(new_moved_geom, width, 'quad_segs=8');
    END IF;

    -- Crear la topología de la cara interior que cortará los cables
    new_geom_cbox := ST_Buffer(new_moved_geom, width_cbox, 'endcap=square');

    -- Generar la diagonal en la que se irán introduciendo los empalmes
    new_diagonal := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2] = 4),
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2] = 2)
    );

    -- Actualizar el pozo
    EXECUTE format('UPDATE %I.cw_sewer_box SET id_gis = CONCAT(''cw_sewer_box_'', $1::text), geom = $2, layout_geom = $3, rotated = false WHERE id = $4', schema_name) USING NEW.id_auto, new_moved_geom, new_geom, NEW.id;


    -- Insertar en la tabla connectivity box
    EXECUTE format('INSERT INTO %I.cw_connectivity_box (geom, layout_geom, diagonal_geom, edited_by) VALUES ($1, $2, $3, $4)', schema_name) USING new_moved_geom, new_geom_cbox, new_diagonal, edited_by_value;

    -- Actualizar la geometría layout de las canalizaciones
    EXECUTE format('UPDATE %I.cw_ground_route SET layout_geom = ST_Difference(layout_geom, $1) WHERE ST_Intersects(layout_geom, $1)', schema_name) USING new_geom;
    EXECUTE format('UPDATE %I.cw_skyway SET layout_geom = ST_Difference(layout_geom, $1) WHERE ST_Intersects(layout_geom, $1)', schema_name) USING new_geom;
    EXECUTE format('UPDATE %I.cw_duct SET layout_geom = ST_Difference(layout_geom, $1) WHERE ST_Intersects(layout_geom, $1)', schema_name) USING new_geom;
    EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_Difference(layout_geom, $1) WHERE ST_Intersects(layout_geom, $1)', schema_name) USING new_geom_cbox;
    EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1) WHERE ST_Intersects(layout_geom, $1)', schema_name) USING new_geom_cbox;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


--Trigger original
CREATE TRIGGER cw_sewer_box_insert_trigger
	AFTER INSERT ON objects.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE cw_sewer_box_insert();

CREATE OR REPLACE FUNCTION cw_sewer_box_update() RETURNS trigger AS
$$
DECLARE
    new_geom GEOMETRY;
    width FLOAT;
    width_cbox FLOAT;
    translation_x FLOAT;
    translation_y FLOAT;
    current_table RECORD;
    current_field RECORD;
    cb_record RECORD;
    query TEXT;
    schema_name TEXT := TG_TABLE_SCHEMA; -- Nombre del esquema que deseas buscar
    old_geom GEOMETRY;
    current_new_geom GEOMETRY;
    current_id_gis VARCHAR;
    row RECORD;
    current_aux_record RECORD;
    action_text TEXT := 'Update cw_sewer_box and cw_connectivity_box'; -- Texto de acción para guardar en saved_changes
    edited_by_value UUID; -- Variable para guardar el valor de edited_by
    existing_change RECORD;
    query_update_merge TEXT;
    query_update_rollback TEXT;
    oldgis TEXT; -- Variable para verificar si existe un registro en saved_changes
BEGIN
    IF NOT ST_Equals(OLD.geom, NEW.geom) THEN
        translation_x = ST_X(NEW.geom) - ST_X(OLD.geom);
        translation_y = ST_Y(NEW.geom) - ST_Y(OLD.geom);
        old_geom := OLD.layout_geom;
        
        EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE ST_Intersects(geom, $1)', schema_name)
            INTO cb_record
        USING OLD.geom;
        
        -- Guarda las conexiones de la connectivity_box en tablas temporales
        PERFORM store_cb_connections(schema_name, cb_record);
        
        EXECUTE format('UPDATE %I.fo_cable SET layout_geom = null WHERE ST_Intersects(geom, $1)', schema_name)
        USING OLD.geom;

        oldgis = CONCAT('cw_sewer_box_', OLD.id_auto::TEXT);
        edited_by_value = NEW.edited_by;

    IF edited_by_value IS NULL THEN
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el registro actual de cw_sewer_box.';
    END IF;

        FOR current_table IN 
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = schema_name
        LOOP
            FOR current_field IN
                SELECT column_name
                FROM information_schema.columns
                WHERE table_name = current_table.table_name
                AND data_type = 'USER-DEFINED'
                AND udt_name = 'geometry'
                AND NOT table_name = 'fo_fiber'
                AND NOT table_name = 'fo_fiber_vertices_pgr'
            LOOP
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
                        IF ST_GeometryType(current_new_geom) = 'ST_LineString' THEN                            
                            EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
									' = ' || quote_literal(ST_AsText(update_linestrings(current_new_geom, OLD.geom, NEW.geom))) ||
									' WHERE id_gis = ($1);' USING current_id_gis;
                        END IF;
                    ELSIF NOT current_table.table_name = 'fo_cable' AND NOT current_field.column_name = 'layout_3d_geom' THEN
                        -- Agrega una parte de la consulta para actualizar todas las geometrías de la tabla
                        EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
								' = ST_Translate(' || current_field.column_name || ', ' || translation_x || ', ' || translation_y || ')' ||
								' WHERE id_gis = ($1);' USING current_id_gis;
                    END IF;                        
                END LOOP;
            END LOOP;
        END LOOP;

        PERFORM update_stored_conections(schema_name);

        DROP TABLE IF EXISTS cable_connectivity;
        DROP TABLE IF EXISTS fiber_connectivity;
        DROP TABLE IF EXISTS fiber_port_connectivity;

    END IF;       
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_sewer_box_update_trigger
	AFTER UPDATE ON objects.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE cw_sewer_box_update();

CREATE OR REPLACE FUNCTION cw_sewer_box_delete() RETURNS trigger AS
$$
	DECLARE 
        schema_name TEXT := TG_TABLE_SCHEMA;
	BEGIN
		EXECUTE ('DELETE FROM %I.cw_connectivity_box WHERE ST_Intersects(geom, $1)', schema_name) USING OLD.layout_geom;
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_sewer_box_delete_trigger
	AFTER DELETE ON objects.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE cw_sewer_box_delete();
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

--POSTES
CREATE TABLE objects.cw_pole(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    name VARCHAR,
	usage template.cw_pole_usage_enum,
    material_type template.material_type,
	life_cycle template.life_cycle_enum,
    owner template.owner_enum,
    rotated BOOLEAN,
	geom geometry(POINT,3857),
    geom3D geometry(POLYGON,3857),
	layout_geom geometry(POLYGON,3857),
	support geometry(LINESTRING, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_cw_pole_id_gis ON objects.cw_pole (id_gis);
CREATE INDEX idx_geom_pole ON objects.cw_pole USING GIST(geom);
CREATE INDEX idx_layout_geom_pole ON objects.cw_pole USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION cw_pole_insert() RETURNS trigger AS
$$
DECLARE 
    new_geom GEOMETRY;
    new_geom_3D GEOMETRY;
    new_geom_cbox GEOMETRY;
    new_diagonal GEOMETRY;
    perpendicular_diagonal_line GEOMETRY;
    new_moved_geom GEOMETRY;
    width FLOAT := 3.75;
    width_pole_3D FLOAT := 0.125;
    width_cbox FLOAT := 2;
    schema_name TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    query_merge_value TEXT;
    query_rollback TEXT;
    count_end_point INT;
    count_start_point INT;
BEGIN
    new_moved_geom := NEW.geom;

    -- Obtén el valor de edited_by
    EXECUTE format('SELECT edited_by FROM %I.cw_pole WHERE id_auto = $1', schema_name)
    INTO edited_by_value
    USING NEW.id_auto;

    -- Realiza las consultas con NEW.geom como parámetro
    EXECUTE format('SELECT count(*) FROM %I.cw_skyway WHERE ST_Distance($1, ST_EndPoint(geom)) < 4', schema_name)
    INTO count_end_point
    USING NEW.geom;

    IF count_end_point > 0 THEN
        new_moved_geom := (SELECT ST_EndPoint(geom) FROM format('%I.cw_skyway', schema_name) WHERE ST_Distance(NEW.geom, ST_EndPoint(geom)) < 4 LIMIT 1);
    END IF;

    EXECUTE format('SELECT count(*) FROM %I.cw_skyway WHERE ST_Distance($1, ST_StartPoint(geom)) < 4', schema_name)
    INTO count_start_point
    USING NEW.geom;

    IF count_start_point > 0 THEN
        new_moved_geom := (SELECT ST_StartPoint(geom) FROM format('%I.cw_skyway', schema_name) WHERE ST_Distance(NEW.geom, ST_StartPoint(geom)) < 4 LIMIT 1);
    END IF;

    new_geom := ST_Buffer(new_moved_geom, width, 'quad_segs=8');
    new_geom_cbox := ST_Buffer(new_moved_geom, width_cbox, 'endcap=square');
    new_geom_3D := ST_Buffer(new_moved_geom, width_pole_3D, 'quad_segs=8');

    new_diagonal := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2] = 4),
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2] = 2)
    );
    
    perpendicular_diagonal_line := ST_Rotate(new_diagonal, -PI()/2, ST_Centroid(new_diagonal));

    EXECUTE format('UPDATE %I.cw_pole SET id_gis = CONCAT(''cw_pole_'', $1::text), geom = $2, geom3D = $3, layout_geom = $4, rotated = false, support = 
        ST_MakeLine(ST_MakeLine(ST_LineExtend($5, 0.875, 0.875), ST_Centroid($5)), ST_LineExtend($6, 0.875, 0.875)) WHERE id = $7', schema_name)
    USING NEW.id_auto, new_moved_geom, new_geom_3D, new_geom, new_diagonal, perpendicular_diagonal_line, NEW.id;

    EXECUTE format('INSERT INTO %I.cw_connectivity_box(geom, layout_geom, diagonal_geom, edited_by) VALUES($1, $2, $3, $4)', schema_name)
    USING new_moved_geom, new_geom_cbox, new_diagonal, edited_by_value;

    EXECUTE format('UPDATE %I.cw_skyway SET layout_geom = ST_Difference(layout_geom, $1) WHERE ST_Intersects(layout_geom, $1)', schema_name)
    USING new_geom;

    EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_Difference(layout_geom, $1) WHERE ST_Intersects(layout_geom, $1)', schema_name)
    USING new_geom_cbox;

    EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE ST_Intersects(layout_geom, $1)', schema_name)
    USING new_geom_cbox;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_pole_insert_trigger
	AFTER INSERT ON objects.cw_pole
	FOR EACH ROW EXECUTE PROCEDURE cw_pole_insert();

-- Metodo para actualizar la posiciónd 3d del psote en función del numero de empalmes que haya dentro
CREATE OR REPLACE FUNCTION update_pole_3d_geometry(id_gis_cb VARCHAR, cb_schema TEXT, pole_schema TEXT) RETURNS void AS
$$
DECLARE 
    pole_rec RECORD;
    cb_rec RECORD;
    perpendicular_diagonal_line GEOMETRY;
BEGIN
    -- Se carga el record de la conectivity box en una variable
    EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE id_gis = $1', cb_schema) INTO cb_rec
    USING id_gis_cb;

    -- Se carga el record de poste en una variable
    EXECUTE format('SELECT * FROM %I.cw_pole WHERE ST_Intersects($1, geom)', pole_schema) INTO pole_rec
    USING cb_rec.geom;

    perpendicular_diagonal_line := ST_Rotate(cb_rec.diagonal_geom, -PI()/2, ST_Centroid(cb_rec.diagonal_geom));

    EXECUTE format('
        UPDATE %I.cw_pole
        SET support = ST_MakeLine(
            ST_MakeLine(
                ST_LineExtend($1, 0.875, 0.875), 
                ST_Centroid($1)
            ),
            ST_LineExtend($2, 0.875, 0.875)
        )
        WHERE id = $3
    ', pole_schema)
    USING cb_rec.diagonal_geom, perpendicular_diagonal_line, pole_rec.id;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cw_pole_update() RETURNS trigger AS
$$
DECLARE 
    translation_x FLOAT;
    translation_y FLOAT;
    current_table RECORD;
    current_field RECORD;
    cb_record RECORD;
    schema_name TEXT := TG_TABLE_SCHEMA; -- Nombre del esquema que deseas buscar
    old_geom GEOMETRY;
    current_new_geom GEOMETRY;
    current_id_gis VARCHAR;
    cur_aux RECORD; -- Cursor para iterar sobre los resultados de la consulta dinámica
    edited_by_value UUID;
	existing_change RECORD;
    query_update_merge TEXT;
    query_rollback TEXT;
    oldgis TEXT; -- Variable para verificar si existe un registro en saved_changes
BEGIN
    IF NOT ST_Equals(OLD.geom, NEW.geom) THEN
        translation_x = ST_X(NEW.geom) - ST_X(OLD.geom);
        translation_y = ST_Y(NEW.geom) - ST_Y(OLD.geom);
        old_geom := OLD.layout_geom;

        EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE ST_Intersects(geom, $1)', schema_name)
        INTO cb_record
        USING OLD.geom;

        -- Guarda las conexiones de la connectivity_box en tablas temporales
        PERFORM store_cb_connections(schema_name, cb_record);

        EXECUTE format('UPDATE %I.fo_cable SET layout_geom = null WHERE ST_Intersects(geom, $1)', schema_name)
        USING OLD.geom;

        oldgis = CONCAT('cw_pole_', OLD.id_auto::TEXT);
        edited_by_value = NEW.edited_by;

    IF edited_by_value IS NULL THEN
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el registro actual de cw_pole.';
    END IF;

        -- Se recorren todas las tablas del esquema gis
        FOR current_table IN
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = schema_name
        LOOP
            -- Se recorren todos los campos geométricos de las tablas, excluyendo los que no tienen sentido
            FOR current_field IN
                SELECT column_name
                FROM information_schema.columns
                WHERE table_name = current_table.table_name
                AND data_type = 'USER-DEFINED'
                AND udt_name = 'geometry'
                AND table_name NOT IN ('fo_fiber', 'cw_ground_route', 'cw_duct', 'fo_fiber_vertices_pgr')
            LOOP
                -- Se ejecuta la consulta dinámica para obtener los id_gis
                FOR cur_aux IN 
                    EXECUTE format('SELECT id_gis FROM %I.%I WHERE %I IS NOT NULL AND ST_Intersects(%I, %L)', 
                               schema_name, 
                               current_table.table_name, 
                               current_field.column_name,
                               current_field.column_name,
                               old_geom)
                LOOP
                    -- Ejecuta una consulta dinámica para obtener la geometría actual
                    EXECUTE format('SELECT %I FROM %I.%I WHERE id_gis = $1', 
                                current_field.column_name,
                                schema_name, 
                                current_table.table_name)
                    INTO current_new_geom
                    USING cur_aux.id_gis;

                    IF current_new_geom IS NULL THEN CONTINUE; END IF;

                    IF (current_table.table_name = 'cw_skyway' OR
                            (current_table.table_name = 'fo_cable' AND current_field.column_name = 'geom')
                        )
                    THEN
                        -- En el caso de que sea una línea y se cumpla la condición anterior se actualiza la geometría
                        IF ST_GeometryType(current_new_geom) = 'ST_LineString' THEN
                            EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
                                ' = ' || quote_literal(ST_AsText(update_linestrings(current_new_geom, OLD.geom, NEW.geom))) ||
                                ' WHERE id_gis = $1' USING cur_aux.id_gis;
                        END IF;
                    ELSIF NOT current_table.table_name = 'fo_cable' THEN
                        -- En este caso únicamente se hace una translación de las geometrías
                        EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
                            ' = ST_Translate(' || current_field.column_name || ', ' || translation_x || ', ' || translation_y || ')' ||
                            ' WHERE id_gis = $1' USING cur_aux.id_gis;
                    END IF;                                
                END LOOP;
            END LOOP;
        END LOOP;

        -- Se regeneran las conexiones
        PERFORM update_stored_conections(schema_name);

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
	AFTER UPDATE ON objects.cw_pole
	FOR EACH ROW EXECUTE PROCEDURE cw_pole_update();

CREATE OR REPLACE FUNCTION cw_pole_delete() RETURNS trigger AS
$$
DECLARE 
BEGIN
    EXECUTE ('DELETE FROM %I.cw_connectivity_box WHERE ST_Intersects(geom, $1)', schema_name) USING OLD.layout_geom;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_pole_delete_trigger
    AFTER DELETE ON objects.cw_pole
    FOR EACH ROW EXECUTE PROCEDURE cw_pole_delete();

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- CONNECTIVITY BOX
CREATE TABLE objects.cw_connectivity_box(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
	id_gis VARCHAR, 
	geom geometry(POINT,3857),
	layout_geom geometry(POLYGON,3857),
	diagonal_geom geometry(LINESTRING,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE OR REPLACE FUNCTION cw_connectivity_box_insert() RETURNS TRIGGER AS
$$
DECLARE
    dest_schema TEXT := TG_TABLE_SCHEMA;
    action_text TEXT := 'Insert into cw_connectivity_box';
    edited_by_value UUID; -- Variable para guardar el valor de edited_by
BEGIN
    -- Obtiene el valor de edited_by del nuevo registro de cw_connectivity_box
    edited_by_value := NEW.edited_by;

    -- Verifica si edited_by_value fue obtenido correctamente
    IF edited_by_value IS NULL THEN
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el nuevo registro de cw_connectivity_box.';
    END IF;

    -- Actualiza la tabla cw_connectivity_box
    EXECUTE format('UPDATE %I.cw_connectivity_box SET id_gis = $1 WHERE id_auto = $2', dest_schema)
    USING CONCAT('cw_connectivity_box_', NEW.id_auto::TEXT), NEW.id_auto;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

--Trigger original
CREATE TRIGGER cw_connectivity_box_insert_trigger
	AFTER INSERT ON objects.cw_connectivity_box
	FOR EACH ROW EXECUTE PROCEDURE cw_connectivity_box_insert();

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

-- GROUND ROUTE
CREATE TABLE objects.cw_ground_route(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL, 
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
    layout_3d_geom geometry(LINESTRING,3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE UNIQUE INDEX idx_cw_ground_route_id_gis ON objects.cw_ground_route (id_gis);
CREATE INDEX idx_geom_ground_route ON objects.cw_ground_route USING GIST(geom);
CREATE INDEX idx_layout_geom_ground_route ON objects.cw_ground_route USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION cw_ground_route_insert() RETURNS trigger AS
$$
DECLARE
    real_geom GEOMETRY;
    aux_gr_geom GEOMETRY;
    aux_gr3d_geom GEOMETRY;
    aux_geom GEOMETRY;
    current_node RECORD;
    id_gis_sewer VARCHAR;
    id_cb VARCHAR;
    building_record RECORD;
    building_on_start_point BOOLEAN;
    radians_to_rotate DOUBLE PRECISION;
    new_first_geom GEOMETRY;
    new_last_geom GEOMETRY;
    building_face_1 GEOMETRY;
    building_face_2 GEOMETRY;
    building_face_3 GEOMETRY;
    building_face_4 GEOMETRY;
    is_rotated BOOLEAN;
    aux_client_record RECORD;
    building_face GEOMETRY;
    schema_name TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    width FLOAT := 0.875;
    edited_by_value UUID;
    query_merge_value TEXT;
    query_rollback TEXT := 'call delete procedure';
BEGIN
    --En el caso en el que los extremos de la geometrías toquen un pozo, poste o edificio, este punto que toca se adecuará para colocarse justo en ese punto.
    EXECUTE format('SELECT geom FROM %I.cw_sewer_box WHERE ST_Distance($1, geom) < 3', schema_name)
        INTO new_first_geom
    USING ST_StartPoint(NEW.geom);

    IF new_first_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_pole WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_first_geom
        USING ST_StartPoint(NEW.geom);
    END IF; 

    IF new_first_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_building WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_first_geom
        USING ST_StartPoint(NEW.geom);
    END IF; 

    EXECUTE format('SELECT geom FROM %I.cw_sewer_box WHERE ST_Distance($1, geom) < 3', schema_name)
        INTO new_last_geom
    USING ST_EndPoint(NEW.geom);

    IF new_last_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_pole WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_last_geom
        USING ST_EndPoint(NEW.geom);
    END IF; 

    IF new_last_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_building WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_last_geom
        USING ST_EndPoint(NEW.geom);
    END IF; 

    -- Si alguno o ambos punto no son NULL se actualiza la geometría
    IF new_first_geom IS NOT NULL
    THEN
        NEW.geom := ST_SetPoint(NEW.geom, 0, new_first_geom);
    END IF;

    IF new_last_geom IS NOT NULL
    THEN
        NEW.geom := ST_SetPoint(NEW.geom, ST_NumPoints(NEW.geom) - 1, new_last_geom);
    END IF;

    real_geom= ST_LineMerge(NEW.geom);
    
    aux_gr_geom := ST_Buffer(NEW.geom, width, 'endcap=flat join=round');

    -- Se genera una línea auxiliar para compararla con real geom y sacar el ángulo de giro que hay que darle al pozo, 
    -- para que la ruta de entrada quede perpendicular al área del pozo
    aux_geom := (ST_MakeLine(
        ST_SetSRID(ST_MakePoint(ST_X(ST_PointN(real_geom, 1)), ST_Y(ST_PointN(real_geom, 2))), 3857), 
        ST_SetSRID(ST_PointN(real_geom, 2), 3857)));
        
    -- Se obtienen los radianes de giro
    radians_to_rotate := ST_Angle(aux_geom, real_geom);

    -- Se obtiene el id del usuario
    edited_by_value := NEW.edited_by;

    -- Se obtiene el id de los elementos que tienen que rotar
    EXECUTE format('
        SELECT id_gis FROM %I.cw_sewer_box 
        WHERE ST_Intersects(geom, ST_EndPoint($1))',
        schema_name) INTO id_gis_sewer
        USING NEW.geom;

    EXECUTE format('
        SELECT id_gis FROM %I.cw_connectivity_box 
        WHERE ST_Intersects(geom, ST_EndPoint($1))',
        schema_name) INTO id_cb
        USING NEW.geom;

    EXECUTE format('
        SELECT * FROM %I.cw_building 
        WHERE ST_Intersects(geom, $1)',
        schema_name) INTO building_record
        USING NEW.geom;        

    -- En el caso en que la ruta sea de entrada al pozo, se actualizan las topologías
    IF id_gis_sewer IS NOT NULL
    THEN
        EXECUTE format('SELECT rotated FROM %I.cw_sewer_box WHERE id_gis = $1', schema_name) INTO is_rotated USING id_gis_sewer;
        RAISE NOTICE 'rotated %', is_rotated;
        RAISE NOTICE 'radians_to_rotate gr %', radians_to_rotate;
        IF NOT is_rotated
        THEN
            EXECUTE format('
                UPDATE %I.cw_sewer_box 
                SET layout_geom = ST_Rotate(layout_geom, -%s, ST_centroid(geom)), rotated = true
                WHERE id_gis = %L',
                schema_name, radians_to_rotate, id_gis_sewer);
            
            EXECUTE format('
                UPDATE %I.cw_connectivity_box 
                SET layout_geom = ST_Rotate(layout_geom, -%s, ST_centroid(geom)),
                    diagonal_geom = ST_Rotate(diagonal_geom, -%s, ST_centroid(geom))  
                WHERE id_gis = %L',
                schema_name, radians_to_rotate, radians_to_rotate, id_cb);
        END IF;
    END IF;
    RAISE NOTICE 'building_record %', building_record;

    -- En el caso en que se conecte a un edificio
    IF building_record.id_gis IS NOT NULL 
    THEN
         RAISE NOTICE 'Deentro';
        PERFORM building_rotation_update_line(building_record, NEW.geom, schema_name);
    END IF;
    RAISE NOTICE 'Fuera';
    -- Proceso para actualizar gis.cw_ground_route
    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_building 
        WHERE ST_Intersects($1, %I.cw_building.layout_geom)',
        schema_name, schema_name)
    USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
        aux_gr3d_geom := ST_Difference(real_geom, current_node.layout_geom);
    END LOOP;
    
    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_sewer_box 
        WHERE ST_Intersects($1, %I.cw_sewer_box.layout_geom)',
        schema_name, schema_name)
    USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
        aux_gr3d_geom := ST_Difference(real_geom, current_node.layout_geom);
    END LOOP;

    aux_gr3d_geom := real_geom;
    
    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_sewer_box 
        WHERE ST_Intersects($1, %I.cw_sewer_box.layout_geom)',
        schema_name, schema_name)
    USING real_geom
    LOOP
        aux_gr3d_geom := ST_Difference(aux_gr3d_geom, current_node.layout_geom);
    END LOOP;

    -- Se actualiza gis.cw_ground_route
    EXECUTE format('
        UPDATE %I.cw_ground_route
        SET id_gis = CONCAT(''cw_ground_route_'', %L::text),
            calculated_length = ST_Length($1),
            layout_geom = $2,
            layout_3d_geom = $3
        WHERE id = %L',
        schema_name, NEW.id_auto, NEW.id)
    USING NEW.geom, aux_gr_geom, aux_gr3d_geom;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


--TRIGGER TABLA ORIGINAL
CREATE TRIGGER cw_ground_route_insert_trigger
	AFTER INSERT ON objects.cw_ground_route
	FOR EACH ROW EXECUTE PROCEDURE cw_ground_route_insert();

    
CREATE OR REPLACE FUNCTION cw_ground_route_update() RETURNS trigger AS
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
    width FLOAT := 0.875; -- Declarar e inicializar la variable width aquí
    building_record RECORD;
    schema_name TEXT := TG_TABLE_SCHEMA;
    edited_by_value UUID; -- Declarar variable para edited_by
    action_text TEXT := 'Update in cw_ground_route'; -- Declarar variable para action_text
BEGIN
    IF NOT ST_Equals(OLD.geom, NEW.geom) THEN
        EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(geom, $1)', schema_name)
            INTO building_record
        USING NEW.geom;

        -- Caso en el que al actualizarse un ground route esta estuviese coenctada a un edificio, actualizaría la rotación de este edificio
        IF building_record.id_gis IS NOT NULL
        THEN
            PERFORM building_rotation_update_line(building_record, NEW.geom, schema_name);
        END IF;

        aux_gr_geom = ST_Buffer(NEW.geom, width, 'endcap=flat join=round');

        FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_sewer_box WHERE ST_Overlaps($1, layout_geom)', schema_name) USING aux_gr_geom 
        LOOP
            aux_gr_geom = ST_Difference(aux_gr_geom, current_node.layout_geom);
        END LOOP;

        FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Overlaps($1, layout_geom)', schema_name) USING aux_gr_geom 
        LOOP
            aux_gr_geom = ST_Difference(aux_gr_geom, current_node.layout_geom);
        END LOOP;

        aux_gr3d_geom = NEW.geom;
    
        FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_sewer_box WHERE ST_Intersects($1, layout_geom)', schema_name) USING NEW.geom 
        LOOP
            aux_gr3d_geom=ST_Difference(aux_gr3d_geom, current_node.layout_geom);
        END LOOP;
        RAISE NOTICE 'aux_gr_geom %', ST_AsText(aux_gr_geom);
        EXECUTE format('UPDATE %I.cw_ground_route SET id_gis = CONCAT(''cw_ground_route_'', $1::text), layout_geom = $2, layout_3d_geom = $3 WHERE id = $4', schema_name)
        USING NEW.id_auto, aux_gr_geom, aux_gr3d_geom, NEW.id;
    END IF;

    -- Obtener el valor de edited_by_value (ajusta según de dónde venga este valor)
    EXECUTE format('SELECT edited_by FROM %I.cw_ground_route WHERE id = $1', schema_name)
    INTO edited_by_value
    USING OLD.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_ground_route_update_trigger
	AFTER UPDATE ON objects.cw_ground_route
	FOR EACH ROW EXECUTE PROCEDURE cw_ground_route_update();

CREATE OR REPLACE FUNCTION building_rotation_update_line(building_record RECORD, new_line_geom GEOMETRY, schema_name TEXT) RETURNS void AS
$$
DECLARE
    radians_to_rotate FLOAT;
    aux_geom GEOMETRY;
    building_on_start_point BOOLEAN;
    not_rotated_layout_geom GEOMETRY;
    building_face_1 GEOMETRY;
    building_face_2 GEOMETRY;
    building_face_3 GEOMETRY;
    building_face_4 GEOMETRY;
    aux_client_record RECORD;
    building_face GEOMETRY;
BEGIN 
    IF ST_Intersects(building_record.layout_geom, ST_EndPoint(new_line_geom))
    THEN
        building_on_start_point := false;
    ELSE
        building_on_start_point := true;
    END IF;
RAISE NOTICE 'building_on_start_point %', building_on_start_point;
    -- Se establece la rotación en funcion de si es una ruta de entrada o salida
    IF NOT building_on_start_point
    THEN
        aux_geom := ST_MakeLine(
                ST_SetSRID(
                    ST_MakePoint(
                        ST_X(ST_PointN(new_line_geom, (SELECT count(*) FROM ST_DumpPoints(new_line_geom))::INTEGER - 1) ), 
                        ST_Y(ST_PointN(new_line_geom, (SELECT count(*) FROM ST_DumpPoints(new_line_geom))::INTEGER))),
                    3857), 
                ST_SetSRID(
                    ST_PointN(new_line_geom, (SELECT count(*) FROM ST_DumpPoints(new_line_geom))::INTEGER), 3857)
            );
    ELSE
        aux_geom := ST_MakeLine(
                ST_SetSRID(
                    ST_MakePoint(
                        ST_X(ST_PointN(new_line_geom, (SELECT count(*) FROM ST_DumpPoints(new_line_geom))::INTEGER)),
                        ST_Y(ST_PointN(new_line_geom, (SELECT count(*) FROM ST_DumpPoints(new_line_geom))::INTEGER-1))),
                    3857), 
                ST_SetSRID(
                    ST_PointN(new_line_geom, (SELECT count(*) FROM ST_DumpPoints(new_line_geom))::INTEGER-1), 3857)
            );
    END IF;
    RAISE NOTICE 'aux_geomt %', ST_AsText(aux_geom);
    -- Se calcula el angulo de giro
    radians_to_rotate := -ST_Angle(aux_geom, new_line_geom);
RAISE NOTICE 'radians_to_rotate %', radians_to_rotate;
    not_rotated_layout_geom := ST_Rotate(
            (building_record.layout_geom),
            (-1 * (building_record.rotate_rads)),
            (building_record.geom)
        );
    RAISE NOTICE 'not_rotated_layout_geom %', ST_AsText(not_rotated_layout_geom);
    building_face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=2));
    building_face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=3));
    building_face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=4));
    building_face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(not_rotated_layout_geom) WHERE path[2]=5));

    EXECUTE format('SELECT * FROM %I.cw_floor WHERE ST_Intersects(layout_geom, $1) LIMIT 1', schema_name)
        INTO aux_client_record
    USING building_record.layout_geom;

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
        WHEN ST_Intersects(new_line_geom,
            ST_Rotate(
                building_face,
                radians_to_rotate - radians(90), 
                building_record.geom
            )
        )
        THEN
            radians_to_rotate := radians_to_rotate - radians(90);
        WHEN ST_Intersects(new_line_geom,
            ST_Rotate(
                building_face,
                radians_to_rotate - radians(180), 
                building_record.geom
            )
        )
        THEN
            radians_to_rotate := radians_to_rotate - radians(180);
        WHEN ST_Intersects(new_line_geom,
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
    EXECUTE format('UPDATE %I.cw_client SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2),
        layout_geom = ST_Rotate(ST_Rotate(layout_geom ,$1, $2), $4, $2)
        WHERE ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.cw_floor SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2),
        layout_geom = ST_Rotate(ST_Rotate(layout_geom ,$1, $2), $4, $2)
        WHERE ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.rack SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2),
        layout_geom = ST_Rotate(ST_Rotate(layout_geom ,$1, $2), $4, $2)
        WHERE ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.fo_splice SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2),
        layout_geom = ST_Rotate(ST_Rotate(layout_geom ,$1, $2), $4, $2)
        WHERE ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('ALTER TABLE %I.fo_cable DISABLE TRIGGER fo_cable_update_trigger', schema_name);
    EXECUTE format('UPDATE %I.fo_cable SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2),
        layout_geom = ST_Rotate(ST_Rotate(layout_geom ,$1, $2), $4, $2)
        WHERE ST_Intersects(ST_StartPoint(geom), $3) AND ST_Intersects(ST_EndPoint(geom), $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;
    EXECUTE format('ALTER TABLE %I.fo_cable ENABLE TRIGGER fo_cable_update_trigger', schema_name);

    EXECUTE format('UPDATE %I.fo_fiber SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2),
        layout_geom = ST_Rotate(ST_Rotate(layout_geom ,$1, $2), $4, $2),
        source = null,
        target = null
        WHERE ST_Intersects(ST_StartPoint(geom), $3) AND ST_Intersects(ST_EndPoint(geom), $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    -- Se actualiza la topología de fibras
    PERFORM update_fiber_topology(schema_name);

    EXECUTE format('UPDATE %I.port SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2)
        WHERE  ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.in_port SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2)
        WHERE  ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.out_port SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2)
        WHERE  ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.pig_tail SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2)
        WHERE  ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.optical_network_terminal SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2)
        WHERE  ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.optical_splitter SET 
        geom = ST_Rotate(ST_Rotate(geom, $1, $2), $4, $2)
        WHERE  ST_Intersects(geom, $3)', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.layout_geom, radians_to_rotate;

    EXECUTE format('UPDATE %I.cw_building SET 
        layout_geom = ST_Rotate(ST_Rotate(layout_geom, $1, geom), $5, geom),
        rotate_rads = $5
        WHERE  id_gis =  $4', schema_name)
    USING (-1 * (building_record.rotate_rads)), building_record.geom, building_record.rotate_rads, building_record.id_gis, radians_to_rotate;
END
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--SKYWAY
CREATE TABLE objects.cw_skyway(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
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
    layout_3d_geom geometry(LINESTRING,3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE UNIQUE INDEX idx_cw_skyway_id_gis ON objects.cw_skyway (id_gis);
CREATE INDEX idx_geom_skyway ON objects.cw_skyway USING GIST(geom);
CREATE INDEX idx_layout_geom_skyway ON objects.cw_skyway USING GIST(layout_geom);



CREATE OR REPLACE FUNCTION cw_skyway_insert() RETURNS trigger AS
$$
DECLARE 
    real_geom GEOMETRY;
    aux_gr_geom GEOMETRY;
    aux_geom GEOMETRY;
    cb_rotated_geom GEOMETRY;
    rotated_diagonal_geom GEOMETRY;
    perpendicular_diagonal_line GEOMETRY;
    new_first_geom GEOMETRY;
    new_last_geom GEOMETRY;
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
    width FLOAT := 0.625;
    schema_name TEXT := TG_TABLE_SCHEMA;
    update_pole_query TEXT;
    update_connectivity_box_query TEXT;
    update_sewer_box_query TEXT;
    query_merge_value TEXT;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    query_rollback TEXT;
    is_rotated_pole BOOLEAN;
    is_rotated_sewer BOOLEAN;
    BEGIN
    --En el caso en el que los extremos de la geometrías toquen un pozo, poste o edificio, este punto que toca se adecuará para colocarse justo en ese punto.
    EXECUTE format('SELECT geom FROM %I.cw_sewer_box WHERE ST_Distance($1, geom) < 3', schema_name)
        INTO new_first_geom
    USING ST_StartPoint(NEW.geom);

    IF new_first_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_pole WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_first_geom
        USING ST_StartPoint(NEW.geom);
    END IF; 

    IF new_first_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_building WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_first_geom
        USING ST_StartPoint(NEW.geom);
    END IF; 

    EXECUTE format('SELECT geom FROM %I.cw_sewer_box WHERE ST_Distance($1, geom) < 3', schema_name)
        INTO new_last_geom
    USING ST_EndPoint(NEW.geom);

    IF new_last_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_pole WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_last_geom
        USING ST_EndPoint(NEW.geom);
    END IF; 

    IF new_last_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_building WHERE ST_Distance($1, geom) < 3', schema_name)
            INTO new_last_geom
        USING ST_EndPoint(NEW.geom);
    END IF; 

     -- Si alguno o ambos punto no son NULL se actualiza la geometría
    IF new_first_geom IS NOT NULL
    THEN
        NEW.geom := ST_SetPoint(NEW.geom, 0, new_first_geom);
    END IF;

    IF new_last_geom IS NOT NULL
    THEN
        NEW.geom := ST_SetPoint(NEW.geom, ST_NumPoints(NEW.geom) - 1, new_last_geom);
    END IF;

    real_geom = ST_LineMerge(NEW.geom);
    
    aux_gr_geom = ST_Buffer(NEW.geom, width, 'side=right');

    -- Generar una línea auxiliar para compararla con real_geom y sacar el ángulo de giro necesario
    -- para que la ruta de entrada quede perpendicular al área del pozo.
    aux_geom = (ST_MakeLine(
        ST_SetSRID(ST_MakePoint(ST_X(ST_PointN(real_geom, 1)), ST_Y(ST_PointN(real_geom, 2))), 3857), 
        ST_SetSRID(ST_PointN(real_geom, 2), 3857))
    );

    radians_to_rotate = ST_Angle(aux_geom, real_geom);

    -- Obtener los IDs de los elementos que tienen que rotar
    EXECUTE format('
        SELECT id_gis FROM %I.cw_sewer_box 
        WHERE ST_Intersects($1, ST_EndPoint($2.geom))
        LIMIT 1', schema_name)
    INTO id_gis_sewer
    USING NEW.geom, NEW;

    EXECUTE format('
        SELECT id_gis FROM %I.cw_pole 
        WHERE ST_Intersects($1, ST_EndPoint($2.geom))
        LIMIT 1', schema_name)
    INTO id_gis_pole
    USING NEW.geom, NEW;

    EXECUTE format('
        SELECT id_gis FROM %I.cw_connectivity_box 
        WHERE ST_Intersects($1, ST_EndPoint($2.geom))
        LIMIT 1', schema_name)
    INTO id_cb
    USING NEW.geom, NEW;

    -- Obtener el registro del edificio que intersecta con NEW.geom
    EXECUTE format('
        SELECT * FROM %I.cw_building 
        WHERE ST_Intersects($1, geom)
        LIMIT 1', schema_name)
    INTO building_record
    USING NEW.geom;
    EXECUTE format('SELECT rotated FROM %I.cw_sewer_box WHERE id_gis = $1', schema_name) INTO is_rotated_sewer USING id_gis_sewer;
    EXECUTE format('SELECT rotated FROM %I.cw_pole WHERE id_gis = $1', schema_name) INTO is_rotated_pole USING id_gis_pole;
    -- En el caso en el que la ruta sea de entrada al pozo, se actualizan las topologías
    IF id_gis_pole IS NOT NULL AND NOT is_rotated_pole THEN
        EXECUTE format('
            SELECT ST_Rotate(layout_geom, %L, ST_Centroid(geom))
            FROM %I.cw_connectivity_box
            WHERE id_gis = %L
        ', -radians_to_rotate, schema_name, id_cb) INTO cb_rotated_geom;

        EXECUTE format('
            SELECT ST_Rotate(diagonal_geom, %L, ST_Centroid(geom))
            FROM %I.cw_connectivity_box
            WHERE id_gis = %L
        ', -radians_to_rotate, schema_name, id_cb) INTO rotated_diagonal_geom;

        perpendicular_diagonal_line := ST_Rotate(rotated_diagonal_geom, -PI()/2, ST_Centroid(rotated_diagonal_geom));

        update_pole_query := format('UPDATE %I.cw_pole 
            SET layout_geom = ST_Rotate(layout_geom, %L, ST_Centroid(geom)),
                support = ST_MakeLine(
                    ST_MakeLine(
                        ST_LineExtend(%L, 0.875, 0.875), 
                        ST_Centroid(%L)),
                    ST_LineExtend(%L, 0.875, 0.875)
                ),
                rotated = true
            WHERE id_gis = %L', schema_name, -radians_to_rotate, rotated_diagonal_geom::TEXT, rotated_diagonal_geom::TEXT, perpendicular_diagonal_line::TEXT, id_gis_pole);

        EXECUTE update_pole_query;

        update_connectivity_box_query := format('UPDATE %I.cw_connectivity_box SET layout_geom = %L, diagonal_geom = %L WHERE id_gis = %L', schema_name, cb_rotated_geom::TEXT, rotated_diagonal_geom::TEXT, id_cb);

        EXECUTE update_connectivity_box_query;

    ELSIF id_gis_sewer IS NOT NULL AND NOT is_rotated_sewer THEN
        update_sewer_box_query := format('UPDATE %I.cw_sewer_box 
            SET layout_geom = ST_Rotate(layout_geom, %L, ST_Centroid(geom)), rotated = true
            WHERE id_gis = %L', schema_name, -radians_to_rotate, id_gis_sewer);
        
        EXECUTE update_sewer_box_query;
        
        update_connectivity_box_query := format('UPDATE %I.cw_connectivity_box 
            SET layout_geom = ST_Rotate(layout_geom, %L, ST_Centroid(geom)),
                diagonal_geom = ST_Rotate(diagonal_geom, %L, ST_Centroid(geom))
            WHERE id_gis = %L', schema_name, -radians_to_rotate, -radians_to_rotate, id_cb);
        
        EXECUTE update_connectivity_box_query;
    END IF;
RAISE NOTICE 'building_record %' ,building_record;
    -- Lógica para manejar la conexión con un edificio
    IF building_record.id_gis IS NOT NULL THEN
        PERFORM building_rotation_update_line(building_record, NEW.geom, schema_name);
    END IF;

    -- Lógica para el procesamiento de intersecciones con otros nodos
    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_building 
        WHERE ST_Intersects($1, layout_geom)', schema_name)
    USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
    END LOOP;

    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_sewer_box 
        WHERE ST_Intersects($1, layout_geom)', schema_name)
    USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
    END LOOP;

    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_pole 
        WHERE ST_Intersects($1, layout_geom)', schema_name)
    USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
    END LOOP;

    aux_gr3d_geom := ST_OffsetCurve(real_geom, -width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');

    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_sewer_box 
        WHERE ST_Intersects($1, layout_geom)', schema_name)
    USING real_geom
    LOOP
        aux_gr3d_geom := ST_Difference(aux_gr3d_geom, current_node.layout_geom);
    END LOOP;

    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_pole 
        WHERE ST_Intersects($1, layout_geom)', schema_name)
    USING real_geom
    LOOP
        aux_gr3d_geom := ST_Difference(aux_gr3d_geom, current_node.layout_geom);
    END LOOP;

    FOR current_node IN EXECUTE format('
        SELECT * FROM %I.cw_building 
        WHERE ST_Intersects($1, layout_geom)', schema_name)
    USING aux_gr3d_geom
    LOOP
        aux_gr3d_geom := ST_Difference(aux_gr3d_geom, current_node.layout_geom);
    END LOOP;

    edited_by_value := NEW.edited_by;

    -- Verifica si edited_by_value fue obtenido correctamente
    IF edited_by_value IS NULL THEN
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el nuevo registro de cw_skyway.';
    END IF;

    -- Actualizar gis.cw_skyway con los resultados calculados
    EXECUTE format('
        UPDATE %I.cw_skyway
        SET id_gis = $1,
            calculated_length = ST_Length($2),
            layout_geom = $3,
            layout_3d_geom = $4
        WHERE id = $5', schema_name)
    USING CONCAT('cw_skyway_', NEW.id_auto::text), NEW.geom, aux_gr_geom, aux_gr3d_geom, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER cw_skyway_insert_trigger
	AFTER INSERT ON objects.cw_skyway
	FOR EACH ROW EXECUTE PROCEDURE cw_skyway_insert();


CREATE OR REPLACE FUNCTION cw_skyway_update() RETURNS trigger AS
$$
DECLARE 
    aux_gr_geom GEOMETRY;
    aux_gr3d_geom GEOMETRY;
    current_node RECORD;
    building_record RECORD;
    width FLOAT;    
    dynamic_query TEXT;
    schema_name TEXT := TG_TABLE_SCHEMA;
	edited_by_value UUID;
BEGIN
    width = 0.875;

    IF NOT ST_Equals(OLD.geom, NEW.geom)
    THEN
        -- Obtener el registro del edificio que intersecta con NEW.geom
        EXECUTE format('
            SELECT * FROM %I.cw_building 
            WHERE ST_Intersects($1, geom)
            LIMIT 1', schema_name)
        INTO building_record
        USING NEW.geom;

        IF building_record IS NOT NULL
        THEN
            PERFORM building_rotation_update_line(building_record, NEW.geom, schema_name);
        END IF;

        aux_gr_geom = ST_Buffer(NEW.geom, width, 'side=right');

        -- Lógica para el procesamiento de intersecciones con otros nodos
        FOR current_node IN EXECUTE format('
            SELECT * FROM %I.cw_building 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING aux_gr_geom
        LOOP
            aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
        END LOOP;

        FOR current_node IN EXECUTE format('
            SELECT * FROM %I.cw_sewer_box 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING aux_gr_geom
        LOOP
            aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
        END LOOP;

        FOR current_node IN EXECUTE format('
            SELECT * FROM %I.cw_pole 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING aux_gr_geom
        LOOP
            aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
        END LOOP;

        aux_gr3d_geom := ST_OffsetCurve(real_geom, -width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');

        FOR current_node IN EXECUTE format('
            SELECT * FROM %I.cw_sewer_box 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING real_geom
        LOOP
            aux_gr3d_geom := ST_Difference(aux_gr3d_geom, current_node.layout_geom);
        END LOOP;

        FOR current_node IN EXECUTE format('
            SELECT * FROM %I.cw_pole 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING real_geom
        LOOP
            aux_gr3d_geom := ST_Difference(aux_gr3d_geom, current_node.layout_geom);
        END LOOP;

        FOR current_node IN EXECUTE format('
            SELECT * FROM %I.cw_building 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING aux_gr3d_geom
        LOOP
            aux_gr3d_geom := ST_Difference(aux_gr3d_geom, current_node.layout_geom);
        END LOOP;

        EXECUTE format('SELECT edited_by FROM %I.cw_skyway WHERE id = $1', schema_name)
        INTO edited_by_value
        USING OLD.id;

       EXECUTE format('
            UPDATE %I.cw_skyway
            SET id_gis = $1,
                calculated_length = ST_Length($2),
                layout_geom = $3,
                layout_3d_geom = $4
            WHERE id = $5', schema_name)
        USING CONCAT('cw_skyway_', NEW.id_auto::text), NEW.geom, aux_gr_geom, aux_gr3d_geom, NEW.id;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_skyway_update_trigger
	AFTER UPDATE ON objects.cw_skyway
	FOR EACH ROW EXECUTE PROCEDURE cw_skyway_update();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--SPLICE
CREATE TABLE objects.fo_splice(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
	id_gis VARCHAR,
    name VARCHAR,
	life_cycle template.life_cycle_enum,
	type template.fo_splice_enum,
	specification template.fo_splice_spec_enum,
	method template.fo_splice_method_enum,
	owner template.owner_enum,
	geom geometry(POINT,3857),
	layout_geom geometry(POLYGON,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id),
    CONSTRAINT specification 
		FOREIGN KEY(specification) 
			REFERENCES template.fo_splice_spec(model) 
);


CREATE UNIQUE INDEX idx_fo_splice_id_gis ON objects.fo_splice (id_gis);
CREATE INDEX idx_geom_fo_splice ON objects.fo_splice USING GIST(geom);
CREATE INDEX idx_layout_geom_fo_splice ON objects.fo_splice USING GIST(layout_geom);

CREATE OR REPLACE FUNCTION fo_splice_insert() RETURNS trigger AS
$$
DECLARE 
    id_cb VARCHAR;
    cb_record RECORD;
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
    splice_count INT;
    pole_count INT;
    cb_count INT;
    building_count INT;
    schema_name TEXT := TG_TABLE_SCHEMA;
    query_merge_value TEXT;
    query_rollback TEXT;
    edited_by_value UUID;
    top_schema TEXT := 'objects';
BEGIN    
    RAISE NOTICE 'Inicio de fo_splice_insert, TG_TABLE_SCHEMA: %', schema_name;

    edited_by_value := NEW.edited_by;

    EXECUTE format('SELECT count(*) FROM %I.cw_connectivity_box WHERE ST_Intersects(layout_geom, $1)', schema_name)
    INTO cb_count
    USING NEW.geom;
    RAISE NOTICE 'cb_count: %', cb_count;

    IF cb_count > 0 THEN
        EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE ST_Intersects(layout_geom, $1)', schema_name)
            INTO cb_rec
        USING NEW.geom;

        splice_line := cb_rec.diagonal_geom;

        splice_points := ST_LineInterpolatePoints(ST_Linemerge(splice_line), 0.1, true);
        RAISE NOTICE 'splice_points: %', ST_AsText(splice_points);

        cb_boundary_point_1 := ST_PointN(ST_ExteriorRing(cb_rec.layout_geom), 1);
        cb_boundary_point_2 := ST_PointN(ST_ExteriorRing(cb_rec.layout_geom), 2);

        line_for_radians_1 := ST_MakeLine(cb_boundary_point_1, cb_boundary_point_2);
        RAISE NOTICE 'line_for_radians_1: %', ST_AsText(line_for_radians_1);

        line_for_radians_2 := ST_MakeLine(
            ST_SetSRID(ST_MakePoint(ST_X(cb_boundary_point_1), ST_Y(cb_boundary_point_2)), 3857),
            cb_boundary_point_2
        );
        RAISE NOTICE 'line_for_radians_2: %', ST_AsText(line_for_radians_2);

        radians_to_rotate := ST_Angle(line_for_radians_2, line_for_radians_1);

        IF radians_to_rotate IS NULL THEN radians_to_rotate := 0; END IF;

        RAISE NOTICE 'radians_to_rotate: %', radians_to_rotate;

        EXECUTE format('SELECT count(*) FROM %I.cw_pole WHERE ST_Intersects(geom, $1)', schema_name)
        INTO pole_count
        USING cb_rec.layout_geom;
        RAISE NOTICE 'pole_count: %', pole_count;

        IF pole_count > 0 THEN
            FOR i IN 1..(ST_NumGeometries(splice_points) / 2)
            LOOP
                RAISE NOTICE 'Checking splice point index: %', (ST_NumGeometries(splice_points) / 2) - i;

                EXECUTE format('SELECT count(*) FROM %I.fo_splice WHERE ST_Intersects(ST_GeometryN($1, %L), layout_geom)', schema_name, (ST_NumGeometries(splice_points) / 2) - i)
                INTO splice_count
                USING splice_points;
                RAISE NOTICE 'splice_count: %', splice_count;

                IF splice_count = 0 THEN
                    EXECUTE format('
                        UPDATE %I.fo_splice
                        SET layout_geom = ST_Rotate(ST_Buffer(ST_GeometryN(%L, %L), 0.175, ''endcap=square''), %s, ST_Centroid(ST_GeometryN(%L, %L))),
                            id_gis = CONCAT(''fo_splice_'', %L::text)
                        WHERE id = %L
                    ', schema_name, splice_points, (ST_NumGeometries(splice_points) / 2) - i, -radians_to_rotate, splice_points, (ST_NumGeometries(splice_points) / 2) - i, NEW.id_auto, NEW.id);
                    RAISE NOTICE 'Splice point updated at index: %', (ST_NumGeometries(splice_points) / 2) - i;
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            FOR i IN 1..ST_NumGeometries(splice_points)-1
            LOOP
                RAISE NOTICE 'Checking splice point index: %', i;

                EXECUTE format('SELECT count(*) FROM %I.fo_splice WHERE ST_Intersects(ST_GeometryN($1, %L), layout_geom)', schema_name, i)
                INTO splice_count
                USING splice_points;
                RAISE NOTICE 'splice_count: %', splice_count;

                IF splice_count = 0 THEN
                    EXECUTE format('
                        UPDATE %I.fo_splice
                        SET layout_geom = ST_Rotate(ST_Buffer(ST_GeometryN(%L, %L), 0.175, ''endcap=square''), -%s, ST_Centroid(ST_GeometryN(%L, %L))),
                            id_gis = CONCAT(''fo_splice_'', %L::text)
                        WHERE id = %L
                    ', schema_name, splice_points, i, radians_to_rotate, splice_points, i, NEW.id_auto, NEW.id);
                    RAISE NOTICE 'Splice point updated at index: %', i;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        EXECUTE format('SELECT count(*) FROM %I.cw_pole WHERE ST_Intersects(geom, (SELECT geom FROM %I.cw_connectivity_box WHERE id_gis = $1))', schema_name, schema_name)
        INTO pole_count
        USING id_cb;
        RAISE NOTICE 'pole_count: %', pole_count;

        IF pole_count > 0 THEN
            EXECUTE format('PERFORM update_pole_3d_geometry($1)', schema_name) USING id_cb;
            RAISE NOTICE 'update_pole_3d_geometry performed for id_cb: %', id_cb;
        END IF;
    ELSE
        EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Contains(layout_geom, $1)', schema_name) INTO building_record USING NEW.geom;        

         EXECUTE format('UPDATE %I.fo_splice SET 
                layout_geom = ST_Rotate(ST_Buffer(%L, 0.175, ''endcap=square''), %s, %L), id_gis = CONCAT(''fo_splice_'', %L::text)
            WHERE id = %L', schema_name, NEW.geom, building_record.rotate_rads, NEW.geom, NEW.id_auto, NEW.id);
    END IF;

    RAISE NOTICE 'Fin de fo_splice_insert';

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_splice_insert_trigger
	AFTER INSERT ON objects.fo_splice
	FOR EACH ROW EXECUTE PROCEDURE fo_splice_insert();

CREATE OR REPLACE FUNCTION fo_splice_delete() RETURNS trigger AS
$$
	DECLARE 	
		connectivity_box_record RECORD;
	BEGIN
		EXECUTE format('SELECT * FROM %$.cw_connectivity_box WHERE ST_Intersects(layout_geom, $1)', schema_name)
            INTO connectivity_box_record
        USING OLD.layout_geom;

		EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_Difference(layout_geom, $1) 
		WHERE ST_Distance(layout_geom, $2) < 0.003', schema_name)
        USING connectivity_box_record.layout_geom, OLD.layout_geom;

		EXECUTE format('UPDATE %I.fo_fiber SET 
            layout_geom = ST_Difference(layout_geom, $1),
            source = null,
            target = null
		WHERE ST_Distance(layout_geom, $2) < 0.003', schema_name)
        USING connectivity_box_record.layout_geom, OLD.layout_geom;

		-- Se actualiza la topología de fibras
		PERFORM update_fiber_topology(schema_name);

		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_splice_delete_trigger
	AFTER DELETE ON objects.fo_splice
	FOR EACH ROW EXECUTE PROCEDURE fo_splice_delete();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--DUCTOS
CREATE TABLE objects.cw_duct(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
	id_gis VARCHAR,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(POLYGON,3857),
    layout_3d_geom geometry(LINESTRING,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_cw_duct_id_gis ON objects.cw_duct (id_gis);
CREATE INDEX idx_geom_cw_duct ON objects.cw_duct USING GIST(geom);
CREATE INDEX idx_layout_geom_cw_duct ON objects.cw_duct USING GIST(layout_geom);
	
CREATE OR REPLACE FUNCTION public.duct_insert_recursive(id_duct INTEGER, geom_ini GEOMETRY, width1 FLOAT, width2 FLOAT, schema_name TEXT) RETURNS GEOMETRY AS
$$
DECLARE 		
    new_geom1 GEOMETRY;
    new_geom2 GEOMETRY;
    count_result INTEGER;
BEGIN	
    new_geom1 = ST_Buffer(geom_ini, width1, 'side=left join=mitre');
    new_geom2 = ST_Buffer(geom_ini, width2, 'side=left join=mitre');
    new_geom1 = ST_Difference(new_geom1, new_geom2);

    -- Hacer la consulta con el esquema dinámico
    EXECUTE format('SELECT count(*) FROM %I.cw_duct WHERE ST_Intersects(layout_geom, ST_Centroid($1))', schema_name) INTO count_result USING new_geom1;
    RAISE NOTICE 'num_ducts %', count_result;
    IF count_result = 0 THEN
        RETURN new_geom1;
    ELSE
        new_geom1 := public.duct_insert_recursive(id_duct, geom_ini, width1 + 0.09, width1, schema_name);
    END IF;

    RETURN new_geom1;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cw_duct_insert() RETURNS trigger AS
$$
DECLARE 
    new_geom GEOMETRY;
    aux_duct_3d_geom GEOMETRY;
    current_node RECORD;
    width FLOAT := 0.09;
    schema_name TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    query_merge_value TEXT;
BEGIN

    edited_by_value := NEW.edited_by;

    -- Llamada recursiva para salvar la geometría que no se toque con otro ducto
    new_geom := public.duct_insert_recursive(NEW.id_auto, NEW.geom, width, 0, schema_name);    

    -- Se acortan los ductos para que corten el sewer_box
    FOR current_node IN
        EXECUTE format('
            SELECT * FROM %I.cw_sewer_box 
            WHERE ST_overlaps($1, layout_geom)', schema_name)
        USING new_geom
    LOOP
        new_geom := ST_Difference(new_geom, current_node.layout_geom);
    END LOOP;

    FOR current_node IN
        EXECUTE format('
            SELECT * FROM %I.cw_building 
            WHERE ST_overlaps($1, layout_geom)', schema_name)
        USING new_geom
    LOOP
        new_geom := ST_Difference(new_geom, current_node.layout_geom);
    END LOOP;

    aux_duct_3d_geom := ST_OffsetCurve(NEW.geom, width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');

    FOR i IN 1..100 LOOP
        IF ST_Intersects(ST_Centroid(aux_duct_3d_geom), new_geom) THEN
            EXIT;
        ELSE
            aux_duct_3d_geom := ST_OffsetCurve(aux_duct_3d_geom, width, 'quad_segs=4 join=mitre mitre_limit=2.2');
        END IF;
    END LOOP;

    FOR current_node IN
        EXECUTE format('
            SELECT * FROM %I.cw_sewer_box 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING NEW.geom
    LOOP
        aux_duct_3d_geom := ST_Difference(aux_duct_3d_geom, current_node.layout_geom);
    END LOOP;

    FOR current_node IN
        EXECUTE format('
            SELECT * FROM %I.cw_building 
            WHERE ST_Intersects($1, layout_geom)', schema_name)
        USING NEW.geom
    LOOP
        aux_duct_3d_geom := ST_Difference(aux_duct_3d_geom, current_node.layout_geom);
    END LOOP;


    -- Se actualiza la geometría
    EXECUTE format('
        UPDATE %I.cw_duct
        SET layout_geom = $1,
            layout_3d_geom = $2,
            id_gis = CONCAT(''cw_duct_'', $3::text)
        WHERE id = $4', schema_name)
    USING new_geom, aux_duct_3d_geom, NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Creación del trigger para la tabla original
CREATE TRIGGER cw_duct_insert_trigger
	AFTER INSERT ON objects.cw_duct
	FOR EACH ROW EXECUTE PROCEDURE cw_duct_insert();


--UPDATES DUCTOS
CREATE OR REPLACE FUNCTION cw_duct_update() RETURNS trigger AS
$$
DECLARE 
    new_geom GEOMETRY;
    aux_duct_3d_geom GEOMETRY;
    current_node RECORD;
    width FLOAT := 0.09;
    schema_name TEXT := TG_TABLE_SCHEMA;  -- Obtener el esquema actual donde se activa el trigger
BEGIN
    IF NOT ST_Equals(OLD.geom, NEW.geom) THEN
        -- Llamada recursiva para salvar la geometría que no se toque con otro ducto
        new_geom := public.duct_insert_recursive(NEW.id_auto, NEW.geom, width, 0, schema_name);

        -- Se acortan los ductos para que corten el sewer_box
        FOR current_node IN
            EXECUTE format('
                SELECT * FROM %I.cw_sewer_box 
                WHERE ST_overlaps($1, layout_geom)', schema_name)
            USING new_geom
        LOOP
            new_geom := ST_Difference(new_geom, current_node.layout_geom);
        END LOOP;

        FOR current_node IN
            EXECUTE format('
                SELECT * FROM %I.cw_building 
                WHERE ST_overlaps($1, layout_geom)', schema_name)
            USING new_geom
        LOOP
            new_geom := ST_Difference(new_geom, current_node.layout_geom);
        END LOOP;

        aux_duct_3d_geom := ST_OffsetCurve(NEW.geom, width/2, 'quad_segs=4 join=mitre mitre_limit=2.2');

        FOR i IN 1..100 LOOP
            IF ST_Intersects(ST_Centroid(aux_duct_3d_geom), new_geom) THEN
                EXIT;
            ELSE
                aux_duct_3d_geom := ST_OffsetCurve(aux_duct_3d_geom, width, 'quad_segs=4 join=mitre mitre_limit=2.2');
            END IF;
        END LOOP;

        FOR current_node IN
            EXECUTE format('
                SELECT * FROM %I.cw_sewer_box 
                WHERE ST_Intersects($1, layout_geom)', schema_name)
            USING NEW.geom
        LOOP
            aux_duct_3d_geom := ST_Difference(aux_duct_3d_geom, current_node.layout_geom);
        END LOOP;

        FOR current_node IN
            EXECUTE format('
                SELECT * FROM %I.cw_building 
                WHERE ST_Intersects($1, layout_geom)', schema_name)
            USING NEW.geom
        LOOP
            aux_duct_3d_geom := ST_Difference(aux_duct_3d_geom, current_node.layout_geom);
        END LOOP;

        -- Se actualiza la geometría
        EXECUTE format('
            UPDATE %I.cw_duct
            SET layout_geom = $1,
                layout_3d_geom = $2,
                id_gis = CONCAT(''cw_duct_'', $3::text)
            WHERE id = $4', schema_name)
        USING new_geom, aux_duct_3d_geom, NEW.id_auto, NEW.id;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER cw_duct_update_trigger
	AFTER UPDATE ON objects.cw_duct
	FOR EACH ROW EXECUTE PROCEDURE cw_duct_update();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--FIBRA
CREATE TABLE objects.fo_fiber(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
	id_gis VARCHAR,
	id_cable VARCHAR,
    fiber_number INTEGER,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(LINESTRING,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_fo_fiber_id_gis ON objects.fo_fiber (id_gis);
CREATE INDEX idx_geom_fo_fiber ON objects.fo_fiber USING GIST(geom);
CREATE INDEX idx_layout_geom_fo_fiber ON objects.fo_fiber USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION create_fo_fiber(cable RECORD, cable_geom GEOMETRY, n_fibers INTEGER, schema_name TEXT) RETURNS void
AS
$$
DECLARE
    width FLOAT := 0.0000375;
    new_geom GEOMETRY;
    new_geom_aux GEOMETRY;
BEGIN
    new_geom := cable_geom;

    FOR i IN 1..n_fibers LOOP
        new_geom_aux := ST_OffsetCurve(new_geom, -width * i, 'quad_segs=4 join=mitre mitre_limit=2.2');

        -- Revisa la distancia desde el inicio del cable original al inicio del nuevo segmento
        IF ST_Distance(ST_StartPoint(cable_geom), ST_StartPoint(new_geom_aux)) > 0.006 THEN
            new_geom_aux := ST_Reverse(new_geom_aux);
        END IF;

        -- Inserta el nuevo segmento de fibra óptica en la tabla correspondiente
        EXECUTE format('
            INSERT INTO %I.fo_fiber(id_cable, geom, layout_geom, fiber_number)
            VALUES($1, $2, ST_LineMerge($3), $4)', schema_name)
        USING CONCAT('fo_cable_', cable.id_auto::TEXT), cable.geom, new_geom_aux, i;
    END LOOP;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_fo_splitter_fiber(id_gis_splitter VARCHAR, splitter_fiber_geom GEOMETRY) RETURNS void
AS
$$
DECLARE
    dest_schema TEXT := TG_TABLE_SCHEMA;
BEGIN    
    EXECUTE format('INSERT INTO %I.fo_fiber(id_cable, geom, layout_geom) VALUES ($1, $2, $3)', dest_schema)
    USING CONCAT(id_gis_splitter), splitter_fiber_geom, splitter_fiber_geom;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_fo_fiber_to_splice(schema_name TEXT, id_gis_cable VARCHAR, cable_geom GEOMETRY) RETURNS void
AS
$$
DECLARE
    width FLOAT;
    new_geom GEOMETRY;
    new_geom_aux GEOMETRY;
    current_fiber RECORD;
BEGIN
    width := 0.0000375;
    
    -- Actualiza todas las fibras para hacer match con la geometría del cable padre
    FOR current_fiber IN EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 ORDER BY id_gis', schema_name) USING id_gis_cable
    LOOP
        new_geom_aux := ST_LineMerge(ST_OffsetCurve(cable_geom, -width, 'quad_segs=4 join=mitre mitre_limit=2.2'));

        IF ST_Distance(ST_StartPoint(cable_geom), ST_StartPoint(new_geom_aux)) > 0.006 THEN
            new_geom_aux := ST_Reverse(new_geom_aux);
        END IF;

        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis = $2', schema_name)
        USING new_geom_aux, current_fiber.id_gis;

        width := width + 0.0000375;
    END LOOP;

    -- Se actualiza la topología de fibras
    PERFORM update_fiber_topology(schema_name);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fo_fiber_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT;
    edited_by_value UUID;
BEGIN
    schema_name := TG_TABLE_SCHEMA;

    edited_by_value := NEW.edited_by;

    EXECUTE format('UPDATE %I.fo_fiber SET id_gis = CONCAT(''fo_fiber_'', $1::text) WHERE id_auto = $2', schema_name)
    USING NEW.id_auto, NEW.id_auto;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER fo_fiber_insert_trigger
	AFTER INSERT ON objects.fo_fiber
	FOR EACH ROW EXECUTE PROCEDURE fo_fiber_insert();


CREATE OR REPLACE FUNCTION update_fiber_topology(schema_name TEXT) RETURNS void
AS
$$
DECLARE
    topology_table TEXT;
    fiber_count INTEGER;
BEGIN
    -- Step 1: Construct the full table name with the provided schema
    topology_table := schema_name || '.fo_fiber';

    EXECUTE format('SELECT count(*) FROM %I.fo_fiber', schema_name) INTO fiber_count;
    RAISE NOTICE 'topology fiber coount %', fiber_count;
    IF fiber_count > 0
    THEN
        -- Step 2: Create or update the topology using pgr_CreateTopology function
        PERFORM pgr_CreateTopology(topology_table, 0.000025, 'layout_geom', 'id_auto');
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_fo_fiber_vertices_pgr_geom ON %I.fo_fiber_vertices_pgr USING GIST(the_geom)', schema_name);

        -- Step 3: Delete vertices from fo_fiber_vertices_pgr that are not endpoints in fo_fiber
        EXECUTE '
            DELETE FROM ' || schema_name || '.fo_fiber_vertices_pgr 
            WHERE id NOT IN (
                SELECT DISTINCT source AS id FROM ' || topology_table || '
                UNION
                SELECT DISTINCT target AS id FROM ' || topology_table || '
            )
        ';
        RAISE NOTICE 'Fiber topology update completed successfully for schema %.', schema_name;
    END IF;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.in_port (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    port_number INTEGER,
    geom GEOMETRY(POINT, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID,
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_in_port_id_gis ON objects.in_port (id_gis);
CREATE INDEX idx_geom_in_port ON objects.in_port USING GIST(geom);

CREATE OR REPLACE FUNCTION in_port_insert() RETURNS trigger
AS
$$
DECLARE
    dest_schema TEXT := TG_TABLE_SCHEMA;
BEGIN
    EXECUTE format('UPDATE %I.in_port SET id_gis = $1 WHERE id = $2', dest_schema)
    USING CONCAT('in_port_', NEW.id_auto::text), NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER in_port_insert_trigger
	AFTER INSERT ON objects.in_port
	FOR EACH ROW EXECUTE PROCEDURE in_port_insert();	

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--OUT PORT
CREATE TABLE objects.out_port (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    port_number INTEGER,
    geom GEOMETRY(POINT, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE OR REPLACE FUNCTION out_port_insert() RETURNS trigger
AS
$$
DECLARE
    dest_schema TEXT := TG_TABLE_SCHEMA;
BEGIN
    EXECUTE format('UPDATE %I.out_port SET id_gis = $1 WHERE id = $2', dest_schema)
    USING CONCAT('out_port_', NEW.id_auto::text), NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER out_port_insert_trigger
	AFTER INSERT ON objects.out_port
	FOR EACH ROW EXECUTE PROCEDURE out_port_insert();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

-- SPLITTER

CREATE TABLE objects.optical_splitter (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    life_cycle template.life_cycle_enum,
	specification template.optical_splitter_spec_enum,
	method template.optical_splitter_method_enum,
	owner template.owner_enum,
    geom GEOMETRY(LINESTRING, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE OR REPLACE FUNCTION insert_optical_splitter(schema_name TEXT, id_gis_splice VARCHAR, n_puertos_salida INTEGER, edited_by UUID) RETURNS void
AS
$$
DECLARE
    fo_splice RECORD;
    aux_offset_line GEOMETRY;
    aux_offset_line_ori GEOMETRY;
    splitter_geom GEOMETRY;
    n_fibers_crossed INTEGER;
    width FLOAT := 0.0000375;
BEGIN
    -- Dynamically select from the schema
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name)
    INTO fo_splice
    USING id_gis_splice;

    -- Get the edited_by value from fo_splice
    -- Get the number of fibers crossed within the splice
    EXECUTE format('SELECT count(*) FROM %I.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.005', schema_name)
    INTO n_fibers_crossed
    USING fo_splice.layout_geom;

    aux_offset_line_ori := ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice.layout_geom) WHERE path[2] = 2),
                                       (SELECT geom FROM ST_DumpPoints(fo_splice.layout_geom) WHERE path[2] = 3));

    -- Depending on the fibers that have already entered the splice, use a different offset line
    FOR i IN 0..1000 LOOP
        aux_offset_line := ST_OffsetCurve(aux_offset_line_ori, -width * (1000 + i), 'quad_segs=4 join=round');
        EXECUTE format('SELECT count(*) FROM %I.in_port WHERE ST_Distance($1, geom) < 0.000025', schema_name)
        INTO n_fibers_crossed
        USING aux_offset_line;
        IF n_fibers_crossed < 1 THEN
            EXECUTE format('SELECT count(*) FROM %I.out_port WHERE ST_Distance($1, geom) < 0.000025', schema_name)
            INTO n_fibers_crossed
            USING aux_offset_line;
            IF n_fibers_crossed < 1 THEN
                EXIT;
            END IF;
        END IF;
    END LOOP;

    splitter_geom := ST_Centroid(aux_offset_line);

    FOR i IN 0..n_puertos_salida-1 LOOP
        -- Update the line representing the splitter
        splitter_geom := ST_MakeLine(splitter_geom, ST_Centroid(ST_OffsetCurve(aux_offset_line, width, 'quad_segs=4 join=round')));
        width := width + 0.0000375;
    END LOOP;

    -- Insert into the dynamically selected schema with edited_by
    EXECUTE format('INSERT INTO %I.optical_splitter(geom, edited_by) VALUES ($1, $2)', schema_name)
    USING splitter_geom, edited_by;

END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION optical_splitter_insert() RETURNS TRIGGER
AS
$$
DECLARE
    id_gis_splitter VARCHAR;
    dest_schema TEXT := TG_TABLE_SCHEMA;
    edited_by UUID;
    action_text TEXT := 'Insert into optical_splitter';
    query_merge_value TEXT;
    query_rollback TEXT;
    top_schema TEXT := 'objects';
BEGIN

    -- Selecciona el edited_by de optical_splitter
    EXECUTE format('SELECT edited_by FROM %I.optical_splitter WHERE id = $1', dest_schema)
    INTO edited_by
    USING NEW.id;

        -- Verifica si el valor de edited_by se obtuvo correctamente
    IF edited_by IS NULL THEN
        RAISE EXCEPTION 'edited_by es NULL. Verifica la tabla optical_splitter.';
    END IF;

    id_gis_splitter := CONCAT('optical_splitter_', NEW.id_auto::text);

    -- Actualiza el id_gis en optical_splitter
    EXECUTE format('UPDATE %I.optical_splitter SET id_gis = $1 WHERE id = $2', dest_schema)
    USING id_gis_splitter, NEW.id;


    -- Se crea el puerto de entrada
    EXECUTE format('INSERT INTO %I.in_port(geom, port_number, edited_by) VALUES((SELECT geom FROM ST_DumpPoints($1) WHERE path[1] = 1), 1, $2)', dest_schema)
    USING NEW.geom, edited_by;

    -- Se crean los puertos de salida y cables auxiliares para conectar fibras
    FOR i IN 2..(SELECT count(*) FROM ST_DumpPoints(NEW.geom))
    LOOP
        EXECUTE format('INSERT INTO %I.out_port(geom, port_number, edited_by) VALUES((SELECT geom FROM ST_DumpPoints($1) WHERE path[1] = $2), $3, $4)', dest_schema)
        USING NEW.geom, i, (i - 1), edited_by;
    END LOOP;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER optical_splitter_insert_trigger
    AFTER INSERT ON objects.optical_splitter
    FOR EACH ROW EXECUTE PROCEDURE optical_splitter_insert();


CREATE OR REPLACE FUNCTION optical_splitter_delete() RETURNS trigger
AS
$$
DECLARE
    fo_splice_record RECORD;
    schema_name TEXT := TG_TABLE_SCHEMA; -- Obtener el esquema de la tabla donde se ejecuta el trigger
BEGIN
    -- Step 1: Utilizar el esquema proporcionado dinámicamente en todas las consultas
    EXECUTE '
        SELECT * INTO fo_splice_record FROM ' || schema_name || '.fo_splice WHERE ST_Intersects(layout_geom, $1)
    ' INTO fo_splice_record USING OLD.geom;

    -- Step 2: Actualizar la tabla fo_fiber utilizando el esquema proporcionado
    EXECUTE '
        UPDATE ' || schema_name || '.fo_fiber SET
            layout_geom = ST_Difference(layout_geom, $1),
            target = null,
            source = null
        WHERE ST_Distance(layout_geom, $2) < 0.0003
    ' USING fo_splice_record.layout_geom, OLD.geom;

    -- Step 3: Eliminar de las tablas out_port e in_port usando el esquema proporcionado
    EXECUTE '
        DELETE FROM ' || schema_name || '.out_port WHERE ST_Intersects(geom, $1);
        DELETE FROM ' || schema_name || '.in_port WHERE ST_Intersects(geom, $1);
    ' USING OLD.geom;

    -- Se actualiza la topología de fibras
    PERFORM update_fiber_topology(schema_name);

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER optical_splitter_delete_trigger
	AFTER DELETE ON objects.optical_splitter
	FOR EACH ROW EXECUTE PROCEDURE optical_splitter_delete();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--CABLES
CREATE TABLE objects.fo_cable(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
	id_gis VARCHAR,
	id_duct VARCHAR,
    name VARCHAR,
	life_cycle template.life_cycle_enum,
	calculated_length FLOAT,
	measured_length FLOAT,
	specification template.fo_cable_spec_enum,
    is_acometida BOOLEAN DEFAULT false,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(LINESTRING,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE UNIQUE INDEX idx_fo_cable_id_gis ON objects.fo_cable (id_gis);
CREATE INDEX idx_geom_fo_cable ON objects.fo_cable USING GIST(geom);
CREATE INDEX idx_layout_geom_fo_cable ON objects.fo_cable USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION fo_cable_insert() RETURNS trigger AS
$$
DECLARE 
    new_geom GEOMETRY; 
    real_geom GEOMETRY;   
    new_first_geom GEOMETRY;
    new_last_geom GEOMETRY;
    current_client RECORD;
    current_rack RECORD;
    splice_connection BOOLEAN := false;
    fiber_count_var INTEGER;
    schema_name TEXT := TG_TABLE_SCHEMA;  -- Esquema base, puedes cambiarlo según sea necesario
    start_point_count INT;
    end_point_count INT;
    edited_by_value UUID;
    query_merge_value TEXT;
    query_rollback TEXT;
    top_schema TEXT := 'objects';
BEGIN
    
    EXECUTE format('SELECT geom FROM %I.cw_sewer_box WHERE ST_Distance($1, geom) < 3', schema_name) 
        INTO new_first_geom 
    USING ST_StartPoint(NEW.geom);

    IF new_first_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_pole WHERE ST_Distance($1, geom) < 3', schema_name) 
            INTO new_first_geom 
        USING ST_StartPoint(NEW.geom);
    END IF; 

    IF new_first_geom IS NULL AND NOT NEW.is_acometida
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_building WHERE ST_Distance($1, geom) < 3', schema_name) 
            INTO new_first_geom 
        USING ST_StartPoint(NEW.geom);
    END IF; 

    EXECUTE format('SELECT geom FROM %I.cw_sewer_box WHERE ST_Distance($1, geom) < 3', schema_name) 
        INTO new_last_geom 
    USING ST_EndPoint(NEW.geom);

    IF new_last_geom IS NULL 
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_pole WHERE ST_Distance($1, geom) < 3', schema_name) 
            INTO new_last_geom 
        USING ST_EndPoint(NEW.geom);
    END IF; 

    IF new_last_geom IS NULL AND NOT NEW.is_acometida
    THEN
        EXECUTE format('SELECT geom FROM %I.cw_building WHERE ST_Distance($1, geom) < 3', schema_name) 
            INTO new_last_geom 
        USING ST_EndPoint(NEW.geom);
    END IF; 
    
    -- Si alguno o ambos punto no son NULL se actualiza la geometría
    IF new_first_geom IS NOT NULL
    THEN
        NEW.geom := ST_SetPoint(NEW.geom, 0, new_first_geom);
    END IF;

    IF new_last_geom IS NOT NULL
    THEN
        NEW.geom := ST_SetPoint(NEW.geom, ST_NumPoints(NEW.geom) - 1, new_last_geom);
    END IF;

    real_geom= ST_LineMerge(NEW.geom);

    -- Contar las intersecciones en el punto inicial
    EXECUTE format('
        SELECT count(*)
        FROM %I.fo_splice 
        WHERE ST_Intersects(ST_StartPoint($1), layout_geom)', schema_name)
    INTO start_point_count
    USING real_geom;

    -- Contar las intersecciones en el punto final si no hay conexión de empalme en el inicio
    IF start_point_count = 0 THEN
        EXECUTE format('
            SELECT count(*)
            FROM %I.fo_splice 
            WHERE ST_Intersects(ST_EndPoint($1), layout_geom)', schema_name)
        INTO end_point_count
        USING real_geom;
    END IF;

    -- Establecer splice_connection basado en los resultados de las consultas
    IF start_point_count > 0 OR end_point_count > 0 THEN
        splice_connection := true;
    END IF;
    
    -- Llamada recursiva para obtener una ubicación que no corte ningún cable
    IF (SELECT count(*) FROM ST_DumpPoints(real_geom)) > 2 AND NOT NEW.is_acometida AND NOT splice_connection
    THEN
        new_geom := fo_cable_pass_by_insert(real_geom, NEW.id_duct, schema_name);
    ELSIF NOT NEW.is_acometida AND NOT splice_connection
    THEN
        new_geom := fo_cable_insert_recursive(real_geom, NEW.id_duct, schema_name);
    END IF;

    IF splice_connection THEN new_geom := NEW.layout_geom; END IF;
    
    IF NEW.is_acometida
    THEN
        new_geom := NEW.layout_geom;
        -- Procesar los clientes dentro del nuevo layout_geom
        FOR current_client IN EXECUTE format('
            SELECT * FROM %I.cw_client WHERE ST_Intersects(layout_geom, $1)', schema_name)
        USING new_geom
        LOOP
            new_geom := ST_Difference(new_geom, current_client.layout_geom);
        END LOOP;
        
        -- Procesar los racks dentro del nuevo layout_geom
        FOR current_rack IN EXECUTE format('
            SELECT * FROM %I.rack WHERE ST_Intersects(layout_geom, $1)', schema_name)
        USING new_geom
        LOOP
            new_geom := ST_Difference(new_geom, current_rack.layout_geom);
        END LOOP;
        
        -- Actualizar fo_cable con el nuevo layout_geom
        EXECUTE format('
            UPDATE %I.fo_cable
            SET layout_geom = $1,
                id_gis = CONCAT(''fo_cable_'', $2::text)
            WHERE id = $3', schema_name)
        USING new_geom, NEW.id_auto, NEW.id;
        
        EXECUTE format('SELECT fiber_count FROM template.fo_cable_spec WHERE name = $1') INTO fiber_count_var USING NEW.specification;

        IF fiber_count_var IS NULL THEN fiber_count_var := 144; END IF;
        -- Llamar a la función que crea las fibras
        PERFORM create_fo_fiber(NEW, new_geom, fiber_count_var, schema_name);

        RETURN NEW;
    END IF;

    -- Obtén el valor de edited_by
    edited_by_value := NEW.edited_by;

    RAISE NOTICE 'edited_by_value: %', edited_by_value;
                                
    -- Actualizar fo_cable con el nuevo layout_geom
    EXECUTE format('
        UPDATE %I.fo_cable
        SET geom = $1,
            layout_geom = $2,
            id_gis = CONCAT(''fo_cable_'', $3::text)
        WHERE id = $4', schema_name)
    USING real_geom, new_geom, NEW.id_auto, NEW.id;

    EXECUTE format('SELECT fiber_count FROM template.fo_cable_spec WHERE name = $1') INTO fiber_count_var USING NEW.specification;

    IF fiber_count_var IS NULL THEN fiber_count_var := 144; END IF;

    -- Llamar a la función que crea las fibras
    PERFORM create_fo_fiber(NEW, new_geom, fiber_count_var, schema_name);

    -- Se actualiza la topología de fibras
    PERFORM update_fiber_topology(schema_name);

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION fo_cable_pass_by_insert(
    current_geom GEOMETRY,
    id_duct VARCHAR,
    schema_name TEXT
) RETURNS GEOMETRY AS
$$
DECLARE 
    width FLOAT := 0.0125;
    ducts_array TEXT[];
    pole_count INT;
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
    IF id_duct IS NOT NULL THEN
        SELECT ARRAY(SELECT TRIM(x) FROM unnest(string_to_array(id_duct, ',')) AS t(x)) INTO ducts_array;
    END IF;

    -- Obtención de los diferentes tramos del cable. Empieza en 2 para poder coger tramo anterior y siguiente.
    FOR i IN 2..(SELECT count(*) FROM ST_DumpPoints(current_geom))-1 LOOP
        -- Se sacan las secciones anterior y posterior del punto i de la cadena
        previous_cable_section := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i - 1),
            (SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i)
        );
        actual_cable_section := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i),
            (SELECT geom FROM ST_DumpPoints(current_geom) WHERE path[1] = i + 1)
        );
        
        IF previous_cable_section_layout IS NULL THEN
            IF ducts_array[i - 1] IS NOT NULL THEN
                previous_cable_section_layout := fo_cable_insert_recursive(previous_cable_section, ducts_array[i - 1], schema_name);
            ELSE
                previous_cable_section_layout := fo_cable_insert_recursive(previous_cable_section, null, schema_name);
            END IF;
        END IF;

        IF ducts_array[i] IS NOT NULL THEN
            actual_cable_section_layout := fo_cable_insert_recursive(actual_cable_section, ducts_array[i], schema_name);
        ELSE
            actual_cable_section_layout := fo_cable_insert_recursive(actual_cable_section, null, schema_name);
        END IF;            

        -- Se obtiene el connectivity_box en el punto i de la cadena
        EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE ST_Intersects(layout_geom, ST_EndPoint($1))', schema_name) INTO current_connectivity_box USING previous_cable_section;

        EXECUTE format('SELECT count(*) FROM %I.cw_pole WHERE ST_Intersects(geom, $1)', schema_name) INTO pole_count USING current_connectivity_box.layout_geom;
        
        IF pole_count > 0 THEN
            EXECUTE format('SELECT * FROM %I.cw_pole WHERE ST_Intersects(geom, $1)', schema_name) INTO current_parent_element USING current_connectivity_box.layout_geom;
        END IF;

        -- Se divide el área en caras
        face_1 := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 1),
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 2)
        );
        face_2 := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 2),
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 3)
        );
        face_3 := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 3),
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 4)
        );
        face_4 := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 4),
            (SELECT geom FROM ST_DumpPoints(current_connectivity_box.layout_geom) WHERE path[2] = 5)
        );

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

        -- Se obtiene el número de cables que pasan de largo
        EXECUTE format('
            SELECT count(*)
            FROM %I.fo_cable
            WHERE ST_Intersects($1, geom) 
                AND NOT ST_Intersects($1, ST_EndPoint(geom)) 
                AND NOT ST_Intersects($1, ST_StartPoint(geom))
                AND layout_geom IS NOT NULL
        ', schema_name)
        INTO n_crossing_cables
        USING current_connectivity_box.layout_geom;
        
        n_crossing_cables := n_crossing_cables + 1;

        previous_cable_section_layout := ST_LineMerge(previous_cable_section_layout);
        -- Se calculan las caras con un offset en función del número de cables que pasan de largo

        previous_cable_face := ST_LineExtend(ST_OffsetCurve(previous_cable_face, width * n_crossing_cables, 'quad_segs=4 join=mitre mitre_limit=2.2'), 0.25, 0.25);
        actual_cable_face := ST_LineExtend(ST_OffsetCurve(actual_cable_face, width * n_crossing_cables, 'quad_segs=4 join=mitre mitre_limit=2.2'), 0.25, 0.25);

        previous_cable_section_layout := ST_LineSubstring(
            previous_cable_section_layout,
            0,
            ST_LineLocatePoint(previous_cable_section_layout, ST_ClosestPoint(previous_cable_section_layout, previous_cable_face))
        );
        
        -- En el caso en el que las caras no intersecten se genera una cara auxiliar, la más cercana al punto de entrada
        IF ST_Equals(previous_cable_face, actual_cable_face) THEN
            previous_cable_section_layout := ST_MakeLine(
                ST_MakeLine(
                    ST_MakeLine(
                        previous_cable_section_layout,
                        ST_Intersection(actual_cable_section_layout, actual_cable_face)
                    ),
                    ST_EndPoint(actual_cable_section_layout)
                )
            );
        ELSIF NOT ST_Intersects(previous_cable_face, actual_cable_face) THEN
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

            -- Se saca el offset de la cara auxiliar
            aux_cable_face := ST_LineExtend(ST_OffsetCurve(aux_cable_face, width * n_crossing_cables, 'quad_segs=4 join=mitre mitre_limit=2.2'), 0.25, 0.25);
            
            -- Se generan los puntos de intersección de las caras
            intersection_previous_face_with_aux_face := ST_Intersection(previous_cable_face, aux_cable_face);
            intersection_actual_face_with_aux_face := ST_Intersection(actual_cable_face, aux_cable_face);
    
            previous_cable_section_layout := ST_MakeLine(
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
            -- Se saca el punto de intersección de las caras que tocan los cables
            intersection_previous_face_with_actual_face := ST_Intersection(previous_cable_face, actual_cable_face);
    
            -- Se actualiza la geometría
            previous_cable_section_layout := ST_MakeLine(
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


CREATE OR REPLACE FUNCTION public.fo_cable_insert_recursive(current_geom GEOMETRY, id_duct_func VARCHAR, schema_name TEXT) RETURNS GEOMETRY AS
$$
DECLARE 
    new_geom GEOMETRY;
    new_geom_aux GEOMETRY;
    gr_geom GEOMETRY;
    n_jumps_for_duct INTEGER;
    current_cbox_node RECORD;
    current_building RECORD;
    start_point_count INT;
    end_point_count INT;
    i INT := 1;
BEGIN     
    -- En el caso en el que el cable vaya por fuera de ducto
    IF id_duct_func IS NULL OR id_duct_func = 'null'
    THEN
        RAISE NOTICE 'ductos';
        new_geom = (SELECT ST_OffsetCurve(current_geom, -0.05, 'quad_segs=4 join=mitre mitre_limit=2.2'));
        RAISE NOTICE 'new_geom %', ST_AsText(new_geom);
        -- Comprobación por si se ha invertido la geometría
        IF ST_Distance(ST_StartPoint(current_geom), ST_StartPoint(new_geom)) > 0.06
        THEN
            new_geom := ST_Reverse(new_geom);
        END IF;
        RAISE NOTICE 'new_geom %', ST_AsText(new_geom);
        new_geom_aux = new_geom;

        -- Verificar si hay cables cerca del new_geom_aux
        EXECUTE format('
            SELECT count(*)
            FROM %I.fo_cable 
            WHERE ST_distance(layout_geom, ST_Centroid($1)) < 0.005', schema_name)
        INTO start_point_count
        USING new_geom_aux;

        IF start_point_count > 0
        THEN
            new_geom_aux := fo_cable_insert_recursive(new_geom_aux, id_duct_func, schema_name);
        END IF;         
    ELSE
        n_jumps_for_duct := -1;
RAISE NOTICE 'no ductos';
        -- Realizar hasta 1000 iteraciones para intentar offsetar
        WHILE i <= 1000 LOOP
            new_geom := (SELECT ST_OffsetCurve(current_geom, 0.0075 * (i), 'quad_segs=4 join=mitre mitre_limit=2.2'));
            
            -- Verificar si existe el ducto dentro de new_geom
            EXECUTE format('
                SELECT 1 
                FROM %I.cw_duct 
                WHERE id_gis = $2 
                AND ST_Intersects($1, layout_geom)
                LIMIT 1', schema_name)
            INTO n_jumps_for_duct
            USING new_geom, id_duct_func;

            -- Si se encuentra el ducto, salir del bucle
            IF n_jumps_for_duct = 1 THEN
                EXIT;
            END IF;

            i := i + 1;
        END LOOP;

        -- Obtener la geometría según la cantidad de rectas
        new_geom := (SELECT ST_OffsetCurve(current_geom, 0.0075 * (n_jumps_for_duct), 'quad_segs=4 join=mitre mitre_limit=2.2'));

        -- Comprobación si existe una intersección entre ST_StartPoint de current_geom y new_geom_aux
        IF ST_Distance(ST_StartPoint(current_geom), ST_StartPoint(new_geom)) > 0.03
        THEN
            new_geom := ST_Reverse(new_geom);
        END IF;

        new_geom_aux := new_geom;

        -- Verificar si existe un count(*) de la distancia ST_Centroid de gis.fo_cable y new_geom_aux
        EXECUTE format('
            SELECT count(*)
            FROM %I.fo_cable 
            WHERE ST_distance(layout_geom, ST_Centroid($1)) < 0.005', schema_name)
        INTO end_point_count
        USING new_geom_aux;

        IF end_point_count > 0
        THEN
            new_geom_aux := fo_cable_insert_recursive(new_geom_aux, id_duct_func, schema_name);
        END IF;
    END IF;
 RAISE NOTICE 'new_geom_aux cb %', ST_AsText(new_geom_aux);
    -- Reducir la geometría para que no pase por el current_cbox_node y devolver
    FOR current_cbox_node IN EXECUTE format('
        SELECT * 
        FROM %I.cw_connectivity_box as cb 
        WHERE ST_Intersects($1, cb.layout_geom) 
            AND (ST_Intersects(ST_StartPoint($1), cb.layout_geom) OR ST_Intersects(ST_EndPoint($1), cb.layout_geom))', schema_name)
    USING new_geom_aux
    LOOP
        new_geom_aux := ST_LineMerge(ST_Difference(new_geom_aux, current_cbox_node.layout_geom));
    END LOOP;
 RAISE NOTICE 'new_geom_aux building %', ST_AsText(new_geom_aux);
    -- Eliminar la construcción de los bloques aux
    FOR current_building IN EXECUTE format('
        SELECT * 
        FROM %I.cw_building 
        WHERE ST_Intersects(layout_geom, $1)', schema_name)
    USING new_geom_aux
    LOOP
        new_geom_aux := ST_LineMerge(ST_Difference(new_geom_aux, current_building.layout_geom));
    END LOOP;
 RAISE NOTICE 'new_geom_aux %', ST_AsText(new_geom_aux);
    RETURN new_geom_aux;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER fo_cable_insert_trigger
	AFTER INSERT ON objects.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_insert();


CREATE OR REPLACE FUNCTION fo_cable_update() RETURNS trigger AS
$$
DECLARE 
    new_geom GEOMETRY;
    current_fiber RECORD;
    current_connected_fiber RECORD;
    cont INTEGER;
    fiber_count_var INTEGER;
    width FLOAT := 0.0000375;
    current_cb_box RECORD;
    current_splice RECORD;
    current_aux_record RECORD;
    schema_name TEXT:= TG_TABLE_SCHEMA;
    BEGIN
    RAISE notice 'update ST_AsText(OLD.geom) %', ST_AsText(OLD.geom);
    RAISE notice 'update ST_AsText(NEW.geom) %', ST_AsText(NEW.geom);
    RAISE notice 'update ST_AsText(OLD.layout_geom) %', ST_AsText(OLD.layout_geom);
    RAISE notice 'update ST_AsText(NEW.layout_geom) %', ST_AsText(NEW.layout_geom);

    IF NOT ST_Equals(OLD.geom, NEW.geom) AND (NOT (ST_Equals(OLD.layout_geom, NEW.layout_geom)) OR NEW.layout_geom IS NULL)
    THEN
        -- Determinar si se necesita insertar pasando por el cable o recursivamente
        IF (SELECT count(*) FROM ST_DumpPoints(NEW.geom)) > 2
        THEN
            EXECUTE format('
                SELECT fo_cable_pass_by_insert($1, $2, $3)
            ') INTO new_geom USING NEW.geom, NEW.id_duct, schema_name;
        ELSE
            EXECUTE format('
                SELECT fo_cable_insert_recursive($1, $2, $3)
            ') INTO new_geom USING NEW.geom, NEW.id_duct, schema_name;
        END IF;

        -- Actualizar la geometría del cable
        EXECUTE format('
            UPDATE %I.fo_cable
            SET layout_geom = ST_LineMerge($1)
            WHERE id = $2
        ',schema_name) USING new_geom, NEW.id;

        cont := 1;

        -- Actualizar las fibras asociadas al cable
        FOR current_fiber IN EXECUTE format('
            SELECT * FROM %I.fo_fiber
            WHERE id_cable = $1
            ORDER BY id_gis
        ',schema_name) USING OLD.id_gis
        LOOP
            EXECUTE format('
                UPDATE %I.fo_fiber
                SET geom = $1,
                    layout_geom = ST_OffsetCurve($2, -$3 * $5, ''quad_segs=4 join=mitre mitre_limit=2.2''),
                    source = NULL,
                    target = NULL
                WHERE id = $4
            ',schema_name) USING NEW.geom, new_geom, width, current_fiber.id, cont;
            
            cont := cont + 1;
        END LOOP;
    END IF;

-- En el caso en el que se actualice la especificación
    IF OLD.specification <> NEW.specification AND OLD.specification IS NOT NULL
    THEN
        EXECUTE format('DELETE FROM %I.fo_fiber WHERE id_cable = $1', schema_name) USING OLD.id_gis;        
        EXECUTE format('SELECT fiber_count FROM template.fo_cable_spec WHERE name = $1') INTO fiber_count_var USING NEW.specification;

        IF fiber_count_var IS NULL THEN fiber_count_var := 144; END IF;
        -- Llamar a la función que crea las fibras
        PERFORM create_fo_fiber(NEW, new_geom, fiber_count_var, schema_name);

        IF NEW.layout_geom IS NULL 
        THEN
            PERFORM create_fo_fiber(NEW, OLD.layout_geom, fiber_count_var);	
        ELSE
            PERFORM create_fo_fiber(NEW, NEW.layout_geom, fiber_count_var);	
        END IF;
    END IF;			

    -- Se actualiza la topología de fibras
    PERFORM update_fiber_topology(schema_name);	
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_cable_update_trigger
	AFTER UPDATE ON objects.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_update();


CREATE OR REPLACE FUNCTION fo_cable_delete() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT:= TG_TABLE_SCHEMA;
BEGIN
    -- Eliminar las fibras asociadas al cable que se está eliminando
    EXECUTE format('
        DELETE FROM %I.fo_fiber
        WHERE id_cable = $1
    ', schema_name) USING OLD.id_gis;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER fo_cable_delete_trigger
	AFTER DELETE ON objects.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_delete();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.cw_building(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    n_floors INTEGER,
    n_clients INTEGER,
	rotate_rads DOUBLE PRECISION,
	geom geometry(POINT, 3857),
	layout_geom geometry(POLYGON, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)  
);

-- Se crean los indices resppecto al id_gis y a los campos geométricos.
CREATE UNIQUE INDEX idx_cw_building_id_gis ON objects.cw_building (id_gis);
CREATE INDEX idx_cw_building_geom ON objects.cw_building USING GIST(geom);
CREATE INDEX idx_cw_building_layout_geom ON objects.cw_building USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION cw_building_insert() RETURNS trigger AS
$$
DECLARE 
    width FLOAT:= 7.8;
    height FLOAT;
    new_layout_geom GEOMETRY;
    schema_name TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    query_merge_value TEXT;
    query_rollback TEXT;
BEGIN
    height := 0.75 * (NEW.n_floors + 1);

        -- Obtén el valor de edited_by
    edited_by_value := NEW.edited_by;

    RAISE NOTICE 'edited_by_value: %', edited_by_value;

    new_layout_geom := ST_MakeEnvelope(
        ST_X(NEW.geom) - width,   -- Coordenada x de la esquina inferior izquierda
        ST_Y(NEW.geom) - height,  -- Coordenada y de la esquina inferior izquierda
        ST_X(NEW.geom) + width,   -- Coordenada x de la esquina superior derecha
        ST_Y(NEW.geom) + height,  -- Coordenada y de la esquina superior derecha
        ST_SRID(NEW.geom)         -- SRID
    );

    -- Ejecutar función para crear pisos y clientes
    PERFORM create_floors_and_clients(new_layout_geom, NEW.n_floors, NEW.n_clients, height, schema_name);

    -- Actualizar la tabla de edificios en el esquema actual
    EXECUTE format('
        UPDATE %I.cw_building 
        SET layout_geom = $1,
            rotate_rads = 0,
            id_gis = CONCAT(''cw_building_'', $2::text)
        WHERE id = $3',
        schema_name)
    USING new_layout_geom, NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER cw_building_insert_trigger
	AFTER INSERT ON objects.cw_building
	FOR EACH ROW EXECUTE PROCEDURE cw_building_insert();

-- Trigger de update
CREATE OR REPLACE FUNCTION cw_building_update() RETURNS trigger AS
	$$
	DECLARE 
		translation_x FLOAT;
		translation_y FLOAT;
		old_geom GEOMETRY;
		current_new_geom GEOMETRY;
		current_table RECORD;
		current_field RECORD;
		query TEXT;
		schema_name TEXT := TG_TABLE_SCHEMA; -- Nombre del esquema que deseas buscar
		current_id_gis VARCHAR;
		row RECORD;
    BEGIN
		IF NOT ST_Equals(NEW.geom, OLD.geom)
		THEN
			translation_x = ST_X(NEW.geom) - ST_X(OLD.geom);
			translation_y = ST_Y(NEW.geom) - ST_Y(OLD.geom);
			old_geom := OLD.layout_geom;

			PERFORM store_building_connections(schema_name, OLD);
          
			-- Se hace un translate del edificio  
            EXECUTE format('UPDATE %I.cw_building SET layout_geom = ST_Tramslate(layout_geom, $1, $2 WHERE id_gis = $3)', schema_name) 
            USING translation_x, translation_y, OLD.id_gis;

			-- Se hace un translate de todos los componenetes del edificio
            EXECUTE format('UPDATE %I.cw_floor SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2) 
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.cw_client SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2) 
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.rack SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2) 
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.fo_splice SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2) 
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('ALTER TABLE %I.fo_cable DISABLE TRIGGER fo_cable_update_tigger', schema_name);
			EXECUTE format('UPDATE %I.fo_cable SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2) 
                WHERE ST_Intersects(ST_StartPoint(geom), $4) AND ST_Intersects(ST_EndPoint(geom), $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;
			EXECUTE format('ALTER TABLE %I.fo_cable ENABLE TRIGGER fo_cable_update_tigger', schema_name);

			EXECUTE format('UPDATE %I.fo_fiber SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2),
                    source = NULL, target = NULL
                WHERE ST_Intersects(ST_StartPoint(geom), $4) AND ST_Intersects(ST_EndPoint(geom), $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.card SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2) 
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;
			
            EXECUTE format('UPDATE %I.shelf SET 
                    geom = ST_Tramslate(geom, $1, $2),
                    layout_geom = ST_Tramslate(layout_geom, $1, $2) 
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.port SET 
                    geom = ST_Tramslate(geom, $1, $2)
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.optical_splitter SET 
                    geom = ST_Tramslate(geom, $1, $2)
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.in_port SET 
                    geom = ST_Tramslate(geom, $1, $2)
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.out_port SET 
                    geom = ST_Tramslate(geom, $1, $2)
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.pig_tail SET 
                    geom = ST_Tramslate(geom, $1, $2)
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			EXECUTE format('UPDATE %I.optical_network_terminal SET 
                    geom = ST_Tramslate(geom, $1, $2)
                WHERE ST_Intersects(geom, $4))', schema_name) 
            USING translation_x, translation_y, OLD.id_gis, OLD.layout_geom;

			--  Se actualiza las rutas qeu conectan con el edificio para que se haga la rotación necesaria
            EXECUTE format('UPDATE %I.cw_skyway SET 
                    geom = update_linestrings(geom, $1, $2)
                WHERE ST_Intersects(geom, $3))', schema_name) 
            USING OLD.geom, NEW.geom, OLD.layout_geom;

			EXECUTE format('UPDATE %I.cw_ground_route SET 
                    geom = update_linestrings(geom, $1, $2)
                WHERE ST_Intersects(geom, $3))', schema_name) 
            USING OLD.geom, NEW.geom, OLD.layout_geom;

			--  Se actualizan los cables que no están completamente conetenidos en el edificio
            EXECUTE format('UPDATE %I.fo_cable SET 
                    ggeom = update_linestrings(geom, $1, $2),
                    layout_geom = null
                WHERE ST_DWithin(geom, ST_Boundary($3), 1e-9) AND  NOT ST_Intersects(ST_StartPoint(geom), $3) AND ST_Intersects(ST_EndPoint(geom), $3))', schema_name) 
            USING OLD.geom, NEW.geom, OLD.layout_geom;

			-- Se regneran las conexiones
			PERFORM update_stored_conections(schema_name);
		END IF;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER cw_building_update_trigger
	AFTER UPDATE ON objects.cw_building
	FOR EACH ROW EXECUTE PROCEDURE cw_building_update();

CREATE OR REPLACE FUNCTION create_floors_and_clients(
    cw_building_geom GEOMETRY,
    n_floors INTEGER,
    n_clients INTEGER,
    height FLOAT,
    schema_name TEXT
) RETURNS VOID AS 
$$
DECLARE
    central_line GEOMETRY;
    central_floor_points GEOMETRY;
    central_line_clients GEOMETRY;
    central_clients_line_points GEOMETRY;
    clients_distance FLOAT;
    floor_width FLOAT := 6;
    floor_height FLOAT := 0.6;
    new_floor_layout_geom GEOMETRY;
    aux_line_1 GEOMETRY;
    aux_line_2 GEOMETRY;
    cont_clients INTEGER;
    pos INTEGER;
    pos_floor INTEGER;
    client_count INTEGER;
BEGIN
    aux_line_1 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(cw_building_geom) WHERE path[2] = 4),
        (SELECT geom FROM ST_DumpPoints(cw_building_geom) WHERE path[2] = 5)
    );
    aux_line_2 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(cw_building_geom) WHERE path[2] = 2),
        (SELECT geom FROM ST_DumpPoints(cw_building_geom) WHERE path[2] = 3)
    );

    central_line := ST_MakeLine(
        ST_Centroid(aux_line_1), 
        ST_Centroid(aux_line_2)
    );

    central_line := ST_OffsetCurve(central_line, -0.9, 'quad_segs=4 join=mitre mitre_limit=2.2');

    central_floor_points := ST_LineInterpolatePoints(central_line, (1.0 / (n_floors + 1)), true);

    FOR i IN 1..(ST_NumGeometries(central_floor_points)-1)
    LOOP
        pos_floor := ST_NumGeometries(central_floor_points) - i;
        new_floor_layout_geom := ST_MakeEnvelope(
            ST_X(ST_GeometryN(central_floor_points, pos_floor)) - floor_width,
            ST_Y(ST_GeometryN(central_floor_points, pos_floor)) - floor_height,
            ST_X(ST_GeometryN(central_floor_points, pos_floor)) + floor_width,
            ST_Y(ST_GeometryN(central_floor_points, pos_floor)) + floor_height,
            ST_SRID(ST_GeometryN(central_floor_points, pos_floor))
        );

        aux_line_1 := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(new_floor_layout_geom) WHERE path[2] = 3),
            (SELECT geom FROM ST_DumpPoints(new_floor_layout_geom) WHERE path[2] = 4)
        );
        aux_line_2 := ST_MakeLine(
            (SELECT geom FROM ST_DumpPoints(new_floor_layout_geom) WHERE path[2] = 1),
            (SELECT geom FROM ST_DumpPoints(new_floor_layout_geom) WHERE path[2] = 2)
        );

        central_line_clients := ST_MakeLine(
            ST_Centroid(aux_line_1), 
            ST_Centroid(aux_line_2)
        );

        central_clients_line_points := ST_LineInterpolatePoints(central_line_clients, (1.0 / (20 + 1)), true);

        IF ST_NumGeometries(central_clients_line_points) > 1 THEN
            clients_distance := ST_Distance(ST_GeometryN(central_clients_line_points,1), ST_GeometryN(central_clients_line_points,2));
        ELSE
            clients_distance := floor_width - 0.06;
        END IF;

        -- Insertar piso
        EXECUTE format('INSERT INTO %I.cw_floor (geom, layout_geom) VALUES ($1, $2)', schema_name)
        USING ST_GeometryN(central_floor_points, pos_floor), new_floor_layout_geom;

        -- Contar clientes que intersectan con el layout_geom del piso actual
        EXECUTE format('SELECT count(*) FROM %I.cw_client WHERE ST_Intersects(layout_geom, $1)', schema_name)
        INTO client_count
        USING ST_GeometryN(central_clients_line_points, pos);

        cont_clients := 1;

        -- Insertar clientes si no hay suficientes intersectando
        FOR e IN 1..(n_clients - client_count)
        LOOP
            pos := ST_NumGeometries(central_clients_line_points) - e;
            IF client_count = 0 THEN
                EXECUTE format('INSERT INTO %I.cw_client (geom, layout_geom) VALUES ($1, $2)', schema_name)
                USING ST_GeometryN(central_clients_line_points, pos), 
                      ST_MakeEnvelope(
                          ST_X(ST_GeometryN(central_clients_line_points, pos)) - clients_distance/2 + 0.03,
                          ST_Y(ST_GeometryN(central_clients_line_points, pos)) - floor_height + 0.36,
                          ST_X(ST_GeometryN(central_clients_line_points, pos)) + clients_distance/2 - 0.03,
                          ST_Y(ST_GeometryN(central_clients_line_points, pos)) + floor_height,
                          ST_SRID(ST_GeometryN(central_clients_line_points, pos))
                      );
                cont_clients := cont_clients + 1;
            END IF;
        END LOOP;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.cw_floor(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	geom geometry(POINT, 3857) ,
    layout_geom geometry(POLYGON, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_cw_floor_id_gis ON objects.cw_floor (id_gis);
CREATE INDEX idx_cw_floor_geom ON objects.cw_floor USING GIST(geom);
CREATE INDEX idx_cw_floor_layout_geom ON objects.cw_floor USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION cw_floor_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT := TG_TABLE_SCHEMA;  -- Esquema por defecto
BEGIN

    EXECUTE format('
        UPDATE %I.cw_floor 
        SET id_gis = CONCAT(''cw_floor_'', $1::text)
        WHERE id = $2', schema_name)
    USING NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_floor_insert_trigger
	AFTER INSERT ON objects.cw_floor
	FOR EACH ROW EXECUTE PROCEDURE cw_floor_insert();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.cw_client(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	geom geometry(POINT, 3857),
	layout_geom GEOMETRY(POLYGON, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE UNIQUE INDEX idx_cw_client_id_gis ON objects.cw_client (id_gis);
CREATE INDEX idx_cw_client_geom ON objects.cw_client USING GIST(geom);
CREATE INDEX idx_cw_client_layout_geom ON objects.cw_client USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION cw_client_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT := TG_TABLE_SCHEMA;  -- Esquema por defecto
BEGIN

    EXECUTE format('
        UPDATE %I.cw_client 
        SET id_gis = CONCAT(''cw_client_'', $1::text)
        WHERE id = $2', schema_name)
    USING NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_client_insert_trigger
	AFTER INSERT ON objects.cw_client
	FOR EACH ROW EXECUTE PROCEDURE cw_client_insert();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE objects.cw_room(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	geom geometry(POINT, 3857),
	layout_geom GEOMETRY(POLYGON, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_cw_room_id_gis ON objects.cw_room (id_gis);
CREATE INDEX idx_cw_room_geom ON objects.cw_room USING GIST(geom);
CREATE INDEX idx_cw_room_layout_geom ON objects.cw_room USING GIST(layout_geom);

CREATE OR REPLACE FUNCTION cw_room_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT:= TG_TABLE_SCHEMA;
BEGIN

    EXECUTE format('
        UPDATE %I.cw_room 
        SET id_gis = CONCAT(''cw_room_'', $1::text)
        WHERE id = $2', schema_name)
    USING NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER cw_room_insert_trigger
	AFTER INSERT ON objects.cw_room
	FOR EACH ROW EXECUTE PROCEDURE cw_room_insert();


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.optical_network_terminal(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	geom geometry(POINT, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_optical_network_terminal_id_gis ON objects.optical_network_terminal (id_gis);
CREATE INDEX idx_optical_network_terminal_geom ON objects.optical_network_terminal USING GIST(geom);



-- Trigger de inserción
CREATE OR REPLACE FUNCTION optical_network_terminal_insert() RETURNS trigger AS
$$
DECLARE 
    client_record RECORD;
    aux_client_line GEOMETRY;
    ont_line_points GEOMETRY;
    current_ont RECORD;
    cont INTEGER;
    schema_name TEXT := TG_TABLE_SCHEMA;
    client_count INTEGER;
BEGIN

    EXECUTE format('SELECT count(*) FROM %I.cw_client WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO client_count
    USING NEW.geom;

    IF client_count > 0 THEN
        EXECUTE format('SELECT * FROM %I.cw_client WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO client_record
        USING NEW.geom;

        cont := 15;

        aux_client_line := ST_OffsetCurve(
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2] = 4),
                    (SELECT geom FROM ST_DumpPoints(client_record.layout_geom) WHERE path[2] = 5)
                ),
                -0.04,
                'quad_segs=4 join=mitre mitre_limit=2.2'
            );

        ont_line_points := (SELECT ST_LineInterpolatePoints(aux_client_line, (1::FLOAT / (15+1)::FLOAT), true));

        FOR current_ont IN EXECUTE format('SELECT * FROM %I.optical_network_terminal WHERE ST_Intersects($1, geom)', schema_name)
        USING client_record.layout_geom
        LOOP
            IF cont = 5 THEN RETURN NULL; END IF;

            EXECUTE format('UPDATE %I.optical_network_terminal SET geom = ST_GeometryN($1, $2), id_gis = CONCAT(''optical_network_terminal_'', $3::text) WHERE id = $4', schema_name)
            USING ont_line_points, cont, current_ont.id_auto, current_ont.id;

            cont := cont - 1;
        END LOOP;

        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER optical_network_terminal_insert_trigger
	AFTER INSERT ON objects.optical_network_terminal
	FOR EACH ROW EXECUTE PROCEDURE optical_network_terminal_insert();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE objects.rack(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	specification VARCHAR,
	geom GEOMETRY(POINT, 3857),
    layout_geom GEOMETRY(POLYGON, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id),
	CONSTRAINT specification 
      FOREIGN KEY(specification) 
        REFERENCES template.rack_specs(model)
);

CREATE UNIQUE INDEX idx_rack_id_gis ON objects.rack (id_gis);
CREATE INDEX idx_rack_geom ON objects.rack USING GIST(geom);
CREATE INDEX idx_rack_layout_geom ON objects.rack USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION rack_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT := TG_TABLE_SCHEMA;
BEGIN
    EXECUTE format('UPDATE %I.rack SET id_gis = CONCAT(''rack_'', $1::text) WHERE id = $2', schema_name)
    USING NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER rack_insert_trigger
	AFTER INSERT ON objects.rack
	FOR EACH ROW EXECUTE PROCEDURE rack_insert();


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.shelf(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    specification VARCHAR,
	geom GEOMETRY(POINT, 3857),
    layout_geom GEOMETRY(POLYGON, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id),
	CONSTRAINT specification 
      FOREIGN KEY(specification) 
        REFERENCES template.shelf_specs(model)
);


CREATE UNIQUE INDEX idx_shelf_id_gis ON objects.shelf (id_gis);
CREATE INDEX idx_shelf_geom ON objects.shelf USING GIST(geom);
CREATE INDEX idx_shelf_layout_geom ON objects.shelf USING GIST(layout_geom);


CREATE OR REPLACE FUNCTION shelf_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT := TG_TABLE_SCHEMA;
BEGIN
    EXECUTE format('UPDATE %I.shelf SET id_gis = CONCAT(''shelf_'', $1::text) WHERE id = $2', schema_name)
    USING NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER shelf_insert_trigger
	AFTER INSERT ON objects.shelf
	FOR EACH ROW EXECUTE PROCEDURE shelf_insert();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE objects.card (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	specification VARCHAR,
	geom  GEOMETRY(POINT, 3857),
	layout_geom GEOMETRY(POLYGON, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id),
	CONSTRAINT specification 
      FOREIGN KEY(specification) 
        REFERENCES template.card_specs(model)
);

CREATE UNIQUE INDEX idx_card_id_gis ON objects.card (id_gis);
CREATE INDEX idx_geom_card ON objects.card USING GIST(geom);


CREATE OR REPLACE FUNCTION card_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT := TG_TABLE_SCHEMA;
BEGIN
    EXECUTE format('UPDATE %I.card SET id_gis = CONCAT(''card_'', $1::text) WHERE id = $2', schema_name)
    USING NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER card_insert_trigger
	AFTER INSERT ON objects.card
	FOR EACH ROW EXECUTE PROCEDURE card_insert();


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.port (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    geom GEOMETRY(POINT, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_port_id_gis ON objects.port (id_gis);
CREATE INDEX idx_geom_port ON objects.port USING GIST(geom);


CREATE OR REPLACE FUNCTION port_insert() RETURNS trigger AS
$$
DECLARE 
    schema_name TEXT := TG_TABLE_SCHEMA;
BEGIN
    EXECUTE format('UPDATE %I.port SET id_gis = CONCAT(''port_'', $1::text) WHERE id = $2', schema_name)
    USING NEW.id_auto, NEW.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER pot_insert_trigger
	AFTER INSERT ON objects.port
	FOR EACH ROW EXECUTE PROCEDURE port_insert();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE objects.pig_tail(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	geom GEOMETRY(LINESTRING, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE UNIQUE INDEX idx_pig_tail_id_gis ON objects.pig_tail (id_gis);
CREATE INDEX idx_pig_tail_geom ON objects.pig_tail USING GIST(geom);

-- Trigger de inserción
CREATE OR REPLACE FUNCTION pig_tail_insert() RETURNS trigger AS
	$$
	DECLARE 
        schema_name TEXT := TG_TABLE_SCHEMA;
    BEGIN
        EXECUTE format('UPDATE %I.pig_tail SET id_gis = CONCAT(''pig_tail_'', $1::text) WHERE id = $2', schema_name)
        USING NEW.id_auto, NEW.id;

        RETURN NEW;
    END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER pig_tail_insert_trigger
	AFTER INSERT ON objects.pig_tail
	FOR EACH ROW EXECUTE PROCEDURE pig_tail_insert();

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION connect_objects(
    schema_name TEXT, 
    id_gis_object_1 VARCHAR, 
    id_gis_object_2 VARCHAR
) RETURNS void
AS
$$
DECLARE
    object_1 VARCHAR;
    object_2 VARCHAR;
    char_array TEXT[];
BEGIN
    -- Parsing the first object ID
    char_array := STRING_TO_ARRAY(id_gis_object_1, '_');
    object_1 := char_array[1];
    FOR i IN 2..array_length(char_array, 1)-1 LOOP
        object_1 := CONCAT(CONCAT(object_1, '_'), char_array[i]);
    END LOOP;

    -- Parsing the second object ID
    char_array := STRING_TO_ARRAY(id_gis_object_2, '_');
    object_2 := char_array[1];
    FOR i IN 2..array_length(char_array, 1)-1 LOOP
        object_2 := CONCAT(CONCAT(object_2, '_'), char_array[i]);
    END LOOP;

    -- Debugging output
    RAISE NOTICE 'Object 1: %', object_1;
    RAISE NOTICE 'Object 2: %', object_2;

    -- Handling different cases
    CASE
        WHEN object_1 = 'fo_cable' AND object_2 = 'fo_splice'
        THEN
            PERFORM connect_cable(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'fo_splice' AND object_2 = 'fo_cable'
        THEN
            PERFORM connect_cable(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_fiber' AND object_2 = 'fo_fiber'
        THEN
            PERFORM connect_fiber(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'fo_fiber' AND (object_2 = 'in_port' OR object_2 = 'out_port')
        THEN
            PERFORM connect_fiber_splitter_port(id_gis_object_1, id_gis_object_2, schema_name);				
        WHEN (object_1 = 'in_port' OR object_1 = 'out_port') AND object_2 = 'fo_fiber'
        THEN
            PERFORM connect_fiber_splitter_port(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_splice' AND object_2 = 'cw_client'
        THEN
            PERFORM connect_splice_client(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'cw_client' AND object_2 = 'fo_splice'
        THEN
            PERFORM connect_splice_client(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_splice' AND object_2 = 'fo_splice'
        THEN
            PERFORM connect_splice_splice(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_fiber' AND object_2 = 'optical_network_terminal'
        THEN
            PERFORM connect_fiber_ont(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'optical_network_terminal' AND object_2 = 'fo_fiber'
        THEN
            PERFORM connect_fiber_ont(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_splice' AND object_2 = 'rack'
        THEN
            PERFORM connect_splice_rack(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'rack' AND object_2 = 'fo_splice'
        THEN
            PERFORM connect_splice_rack(id_gis_object_2, id_gis_object_1, schema_name);	
        WHEN object_1 = 'fo_fiber' AND object_2 = 'port'
        THEN
            PERFORM connect_fiber_building_port(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'port' AND object_2 = 'fo_fiber'
        THEN
            PERFORM connect_fiber_building_port(id_gis_object_2, id_gis_object_1, schema_name);	
        WHEN object_1 = 'fo_cable' AND object_2 = 'rack'
        THEN
            PERFORM connect_cable_rack(id_gis_object_1, id_gis_object_2, schema_name);	
        WHEN object_1 = 'rack' AND object_2 = 'fo_cable'
        THEN
            PERFORM connect_cable_rack(id_gis_object_2, id_gis_object_1, schema_name);		
        WHEN object_1 = 'out_port' AND object_2 = 'in_port'
        THEN
            PERFORM connect_optical_splitter_ports(id_gis_object_1, id_gis_object_2, schema_name);	
        WHEN object_1 = 'in_port' AND object_2 = 'out_port'
        THEN
            PERFORM connect_optical_splitter_ports(id_gis_object_2, id_gis_object_1, schema_name);	
        ELSE
    END CASE;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION disconnect_objects(
    schema_name TEXT, 
    id_gis_object_1 VARCHAR, 
    id_gis_object_2 VARCHAR
) RETURNS void
AS
$$
DECLARE
    object_1 VARCHAR;
    object_2 VARCHAR;
    char_array TEXT[];
BEGIN
    -- Parsing the first object ID
    char_array := STRING_TO_ARRAY(id_gis_object_1, '_');
    object_1 := char_array[1];
    FOR i IN 2..array_length(char_array, 1)-1 LOOP
        object_1 := CONCAT(CONCAT(object_1, '_'), char_array[i]);
    END LOOP;

    -- Parsing the second object ID
    char_array := STRING_TO_ARRAY(id_gis_object_2, '_');
    object_2 := char_array[1];
    FOR i IN 2..array_length(char_array, 1)-1 LOOP
        object_2 := CONCAT(CONCAT(object_2, '_'), char_array[i]);
    END LOOP;

    -- Debugging output
    RAISE NOTICE 'Object 1: %', object_1;
    RAISE NOTICE 'Object 2: %', object_2;

    -- Handling different cases
    CASE
        WHEN object_1 = 'fo_cable' AND object_2 = 'fo_splice'
        THEN
            PERFORM disconnect_cable_splice(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'fo_splice' AND object_2 = 'fo_cable'
        THEN
            PERFORM disconnect_cable_splice(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_fiber' AND object_2 = 'fo_fiber'
        THEN
            PERFORM disconnect_fibers(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'fo_fiber' AND (object_2 = 'in_port' OR object_2 = 'out_port')
        THEN
            PERFORM disconnect_fiber_port(id_gis_object_1, id_gis_object_2, schema_name);	
        WHEN (object_1 = 'in_port' OR object_1 = 'out_port') AND object_2 = 'fo_fiber'
        THEN
            PERFORM disconnect_fiber_port(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_splice' AND object_2 = 'fo_splice'
        THEN
            PERFORM disconnect_splice_splice(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_fiber' AND object_2 = 'optical_network_terminal'
        THEN
            PERFORM disconnect_fiber_ont(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'optical_network_terminal' AND object_2 = 'fo_fiber'
        THEN
            PERFORM disconnect_fiber_ont(id_gis_object_2, id_gis_object_1, schema_name);
        WHEN object_1 = 'fo_splice' AND object_2 = 'rack'
        THEN
            PERFORM disconnect_splice_rack(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'rack' AND object_2 = 'fo_splice'
        THEN
            PERFORM disconnect_splice_rack(id_gis_object_2, id_gis_object_1, schema_name);	
        WHEN object_1 = 'fo_fiber' AND object_2 = 'port'
        THEN
            PERFORM disconnect_fiber_building_port(id_gis_object_1, id_gis_object_2, schema_name);
        WHEN object_1 = 'port' AND object_2 = 'fo_fiber'
        THEN
            PERFORM disconnect_fiber_building_port(id_gis_object_2, id_gis_object_1, schema_name);	
        WHEN object_1 = 'fo_cable' AND object_2 = 'rack'
        THEN
            PERFORM disconnect_cable_rack(id_gis_object_1, id_gis_object_2, schema_name);	
        WHEN object_1 = 'rack' AND object_2 = 'fo_cable'
        THEN
            PERFORM disconnect_cable_rack(id_gis_object_2, id_gis_object_1, schema_name);		
        WHEN object_1 = 'out_port' AND object_2 = 'in_port'
        THEN
            PERFORM disconnect_optical_splitter_ports(id_gis_object_1, id_gis_object_2, schema_name);	
        WHEN object_1 = 'in_port' AND object_2 = 'out_port'
        THEN
            PERFORM disconnect_optical_splitter_ports(id_gis_object_2, id_gis_object_1, schema_name);	
        ELSE
    END CASE;
END;
$$
LANGUAGE plpgsql;


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION connect_cable(
    id_gis_cable VARCHAR, 
    id_gis_splice VARCHAR, 
    schema_name TEXT
) RETURNS void
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
    face_1 GEOMETRY;
    face_2 GEOMETRY;
    face_3 GEOMETRY;
    face_4 GEOMETRY;
    splice_face_1 GEOMETRY;
    splice_face_2 GEOMETRY;
    splice_face_3 GEOMETRY;
    splice_face_4 GEOMETRY;
    closest_face GEOMETRY;
    closest_splice_face GEOMETRY;
BEGIN
    current_distance := 0;
    width := 0.0125;

    -- Se obtienen los registros necesarios (cable, empalme y conectivity_box)
    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_rec USING id_gis_cable;
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO splice_rec USING id_gis_splice;
    EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE ST_Contains(layout_geom, $1)', schema_name) INTO cb_rec USING splice_rec.layout_geom;

    IF cb_rec IS NULL
    THEN
        EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Contains(layout_geom, $1)', schema_name) INTO cb_rec USING splice_rec.layout_geom;
    END IF;

    -- Verificar resultados de las consultas
    RAISE NOTICE 'Cable Record: %', cable_rec;
    RAISE NOTICE 'Splice Record: %', splice_rec;
    RAISE NOTICE 'Connectivity Box Record: %', cb_rec;

    -- Se genera la linea que conecta el cable cortado en la caja de conexiones con el empalme.
    intersection_point := ST_ClosestPoint(cable_rec.layout_geom, cb_rec.layout_geom);

    -- Obtener la cara más cercana del connectivity_box
    face_1 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 1),
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 2)
    );
    face_2 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 2),
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 3)
    );
    face_3 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 3),
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 4)
    );
    face_4 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 4),
        (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 5)
    );

    RAISE NOTICE 'Face 1: %', face_1;
    RAISE NOTICE 'Face 2: %', face_2;
    RAISE NOTICE 'Face 3: %', face_3;
    RAISE NOTICE 'Face 4: %', face_4;

    SELECT INTO closest_face
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

    RAISE NOTICE 'Closest Face: %', closest_face;

    splice_face_1 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 1),
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 2)
    );
    splice_face_2 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 2),
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 3)
    );
    splice_face_3 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 3),
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 4)
    );
    splice_face_4 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 4),
        (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 5)
    );

    RAISE NOTICE 'Splice Face 1: %', splice_face_1;
    RAISE NOTICE 'Splice Face 2: %', splice_face_2;
    RAISE NOTICE 'Splice Face 3: %', splice_face_3;
    RAISE NOTICE 'Splice Face 4: %', splice_face_4;

    SELECT INTO closest_splice_face
    CASE
        WHEN ST_Distance(ST_Centroid(splice_face_1), closest_face) <= LEAST(
            ST_Distance(ST_Centroid(splice_face_2), closest_face),
            ST_Distance(ST_Centroid(splice_face_3), closest_face),
            ST_Distance(ST_Centroid(splice_face_4), closest_face)
        ) THEN splice_face_1
        WHEN ST_Distance(ST_Centroid(splice_face_2), closest_face) <= LEAST(
            ST_Distance(ST_Centroid(splice_face_1), closest_face),
            ST_Distance(ST_Centroid(splice_face_3), closest_face),
            ST_Distance(ST_Centroid(splice_face_4), closest_face)
        ) THEN splice_face_2
        WHEN ST_Distance(ST_Centroid(splice_face_3), closest_face) <= LEAST(
            ST_Distance(ST_Centroid(splice_face_1), closest_face),
            ST_Distance(ST_Centroid(splice_face_2), closest_face),
            ST_Distance(ST_Centroid(splice_face_4), closest_face)
        ) THEN splice_face_3
        ELSE splice_face_4
    END;

    RAISE NOTICE 'Closest Splice Face: %', closest_splice_face;

    -- Por distancias a la cara por la que entra el cable se saca la cara del sheath_splice más cercana a la cara del connectivity_box
    face_points := ST_LineInterpolatePoints(closest_splice_face, 0.07, true);

    RAISE NOTICE 'Face Points: %', face_points;

    -- Se obtienen la cantidad de cables que han pasado dentro de la connectivity_box para saber que ruta deberá coger el nuevo cable
    EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.0005 AND ST_Intersects(layout_geom, $2)', schema_name) INTO n_cables_crossing USING cb_rec.layout_geom, closest_face;

    RAISE NOTICE 'Number of cables crossing: %', n_cables_crossing;

    IF n_cables_crossing < 20 THEN
        -- Se genera el camino que seguirá el cable
        closest_face := ST_OffsetCurve(closest_face, -width * (n_cables_crossing + 1), 'quad_segs=4 join=mitre mitre_limit=2.2');

        RAISE NOTICE 'Adjusted Closest Face: %', closest_face;

        -- Dependiendo de si es un cable de entrada o salida se genera la línea de conexión en una dirección u otra
        FOR i IN REVERSE 12..ST_NumGeometries(face_points)-12 LOOP
            EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Distance(ST_GeometryN($1, $2), layout_geom) < 0.0005', schema_name) INTO dist USING face_points, i;
            IF dist = 0 THEN
                IF ST_Distance(ST_EndPoint(cable_rec.layout_geom), cb_rec.layout_geom) < 0.0005 THEN
                    aux_line_guitar_splice := ST_ShortestLine(closest_face, ST_GeometryN(face_points, i));
                    aux_line_cable_guitar := ST_ShortestLine(cable_rec.layout_geom, closest_face);
                    EXECUTE format(
                        'UPDATE %I.fo_cable SET layout_geom = ST_LineMerge(ST_MakeLine(ST_MakeLine(ST_MakeLine($1, $2), ST_ShortestLine($2, $3)), $3)) WHERE id_gis = $4',
                        schema_name
                    ) USING cable_rec.layout_geom, aux_line_cable_guitar, aux_line_guitar_splice, id_gis_cable;
                    EXIT;
                ELSE    
                    aux_line_guitar_splice := ST_ShortestLine(ST_GeometryN(face_points, i), closest_face);
                    aux_line_cable_guitar := ST_ShortestLine(closest_face, cable_rec.layout_geom);
                    EXECUTE format(
                        'UPDATE %I.fo_cable SET layout_geom = ST_LineMerge(ST_MakeLine($1, ST_MakeLine(ST_ShortestLine($1, $2), ST_MakeLine($2, $3)))) WHERE id_gis = $4',
                        schema_name
                    ) USING aux_line_guitar_splice, aux_line_cable_guitar, cable_rec.layout_geom, id_gis_cable;
                    EXIT;
                END IF;
            END IF;
        END LOOP;
    END IF;

    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_rec USING id_gis_cable;

    PERFORM update_fo_fiber_to_splice(schema_name, cable_rec.id_gis, cable_rec.layout_geom);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION disconnect_cable_splice(id_gis_cable VARCHAR, id_gis_splice VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
		splice_record RECORD;
		cable_record RECORD;
		cb_record RECORD;
	BEGIN 
        EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_record USING id_gis_cable;
        EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO splice_record USING id_gis_splice;
        EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE ST_Intersects(layout_geom, $1)', schema_name) 
            INTO cb_record 
        USING splice_record.layout_geom;

        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_cable = $2', schema_name) USING cb_record.layout_geom, id_gis_cable;
        EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_gis = $2', schema_name) USING cb_record.layout_geom, id_gis_cable;

        -- Se actualiza la topología de fibras
        PERFORM update_fiber_topology(schema_name);
	END;
	$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


--FUNCIÓN PARA CONECTAR FIBRAS
CREATE OR REPLACE FUNCTION connect_fiber(
    id_gis_fiber1 VARCHAR, 
    id_gis_fiber2 VARCHAR, 
    schema_name TEXT
) 
RETURNS void AS
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
    closest_input_face GEOMETRY;
    closest_output_face GEOMETRY;
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
    width FLOAT := 0.0000375;
    dist_start1 FLOAT;
    dist_end2 FLOAT;
    dist_start2 FLOAT;
    dist_end1 FLOAT;
BEGIN
    RAISE NOTICE 'Obteniendo los registros...';
    EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_rec1 USING id_gis_fiber1;
    RAISE NOTICE 'fiber_rec1: %', fiber_rec1;
    EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_rec2 USING id_gis_fiber2;
    RAISE NOTICE 'fiber_rec2: %', fiber_rec2;
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE ST_Distance(layout_geom, $1) < 0.0005', schema_name) INTO fo_splice_rec USING fiber_rec1.layout_geom;
    RAISE NOTICE 'fo_splice_rec: %', fo_splice_rec;

    -- Calcular las distancias para la depuración
    dist_start1 := ST_Distance(ST_StartPoint(fiber_rec1.layout_geom), fo_splice_rec.layout_geom);
    dist_end2 := ST_Distance(ST_EndPoint(fiber_rec2.layout_geom), fo_splice_rec.layout_geom);
    dist_start2 := ST_Distance(ST_StartPoint(fiber_rec2.layout_geom), fo_splice_rec.layout_geom);
    dist_end1 := ST_Distance(ST_EndPoint(fiber_rec1.layout_geom), fo_splice_rec.layout_geom);

    RAISE NOTICE 'dist_start1: %, dist_end2: %, dist_start2: %, dist_end1: %', dist_start1, dist_end2, dist_start2, dist_end1;

    -- Se determina el punto de entrada y salida de la fibra
    IF dist_start1 < 0.05 AND dist_end2 < 0.05 THEN
        input_fiber_point = ST_EndPoint(fiber_rec2.layout_geom);
        RAISE NOTICE 'input if: %', input_fiber_point;
        output_fiber_point = ST_StartPoint(fiber_rec1.layout_geom);
        input_fiber = fiber_rec2;
        output_fiber = fiber_rec1;
    ELSIF dist_start2 < 0.05 AND dist_end1 < 0.05 THEN
        input_fiber_point = ST_EndPoint(fiber_rec1.layout_geom);
        RAISE NOTICE 'input else: %', input_fiber_point;
        output_fiber_point = ST_StartPoint(fiber_rec2.layout_geom);
        input_fiber = fiber_rec1;
        output_fiber = fiber_rec2;
    ELSE
        -- Manejo del caso donde no se cumple ninguna condición
        RAISE NOTICE 'No se encontró una condición válida para determinar los puntos de entrada y salida';
        RETURN;
    END IF;

    -- Verificación de que los puntos de entrada y salida no sean NULL
    IF input_fiber_point IS NULL OR output_fiber_point IS NULL THEN
        RAISE NOTICE 'Puntos de entrada o salida no definidos';
        RETURN;
    END IF;

    -- Se cuenta la cantidad de fibras que pasan dentro del empalme
    EXECUTE format('SELECT count(*) FROM %I.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.00005', schema_name) INTO n_fibers_crossed USING fo_splice_rec.layout_geom;
    
    -- Se genera una autovía auxiliar dependiendo de las fibras que ya han entrado en el empalme
    aux_offset_box = ST_Buffer(fo_splice_rec.layout_geom, width * ((n_fibers_crossed/2)+1), 'side=right join=mitre');
    RAISE NOTICE 'Autovía generada: %', aux_offset_box;
    
    -- Se inicializan las 4 caras de esta ruta auxiliar del offset
    face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=1), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=2));
    face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=2), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=3));
    face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=3), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=4));
    face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=4), (SELECT geom FROM ST_DumpPoints(aux_offset_box) WHERE path[2]=5));

    -- Encontrar la cara más cercana al punto de entrada
    SELECT face
    INTO closest_input_face
    FROM (
        SELECT unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
               ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), input_fiber_point) AS distance
    ) AS distances
    ORDER BY distance
    LIMIT 1;
    RAISE NOTICE 'input closest face: %', closest_input_face;
    
    -- Encontrar la cara más cercana al punto de salida
    SELECT face
    INTO closest_output_face
    FROM (
        SELECT unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
               ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), output_fiber_point) AS distance
    ) AS distances
    ORDER BY distance
    LIMIT 1;
    
    --  SI las coras son la misma
    IF ST_Equals(closest_output_face, closest_input_face)
    THEN
        -- Continuación de la fibra hasta la cara.
        input_fiber_to_face = ST_ShortestLine(input_fiber_point ,closest_input_face);

        new_input_geom = ST_LineMerge(
                ST_MakeLine(input_fiber.layout_geom, ST_EndPoint(input_fiber_to_face))
            );

        EXECUTE format('UPDATE %.fo_fiber SET layout_geom = $1, source = NULL, target = NULL
            WHERE id_gis = $2', schema_name) 
        USING new_input_geom, input_fiber.id_gis;

       -- Continuación de la cara de salida hasta la fibra de salida.
        output_fiber_to_face := ST_ShortestLine(closest_input_face ,output_fiber_point);

        fiber_to_fiber_line = ST_ShortestLine(ST_EndPoint(input_fiber_to_face), output_fiber_to_face);			

        new_output_geom = ST_LineMerge(
                ST_MakeLine(
                    fiber_to_fiber_line,
                    ST_MakeLine(output_fiber_to_face, output_fiber.layout_geom)
                )
            );
            
        EXECUTE format('UPDATE %.fo_fiber SET layout_geom = $1, source = NULL, target = NULL
            WHERE id_gis = $2', schema_name) 
        USING new_output_geom, output_fiber.id_gis;
    -- Si las caras se intersectan, ajustar las fibras
    ELSIF ST_Intersects(closest_output_face, closest_input_face) THEN
        -- Punto de corte de las caras.
        faces_intersection_point = ST_Intersection(closest_output_face, closest_input_face);
        -- Continuación de la fibra hasta la cara.
        input_fiber_to_face = ST_ShortestLine(input_fiber_point ,closest_input_face);
        -- Desde donde se cortan la fibra y la cara de entrada hasta el punto de corte de las caras.
        input_face_to_intersection_point = ST_ShortestLine(input_fiber_to_face ,faces_intersection_point);
        -- Se actualizza la geometría de la fibra
        new_input_geom = ST_LineMerge(
                ST_MakeLine(
                    ST_MakeLine(input_fiber.layout_geom, input_fiber_to_face),
                    input_face_to_intersection_point
                )
            );
				
        -- Actualizar geometría de la fibra de entrada
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis=$2', schema_name) 
        USING new_input_geom, input_fiber.id_gis;
        -- Continuación de la cara de salida hasta la fibra de salida.
        output_fiber_to_face = ST_ShortestLine(closest_output_face ,output_fiber_point);
        -- Continuación desde el punto de corte de las caras hasta el punto de corte de la fibra con la cara de salida.
        output_face_to_intersection_point = ST_ShortestLine(faces_intersection_point, output_fiber_to_face);
        new_output_geom = ST_LineMerge(
                ST_MakeLine(
                    output_face_to_intersection_point,
                    ST_MakeLine(output_fiber_to_face, output_fiber.layout_geom)
                )
            );

        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis=$2', schema_name) 
        USING new_output_geom, output_fiber.id_gis;
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
			faces_intersection_point = ST_Intersection(second_closest_output_face, closest_input_face);
			-- Continuación de la fibra hasta la cara.
			input_fiber_to_face = ST_ShortestLine(input_fiber_point ,closest_input_face);
			-- Desde donde se cortan la fibra y la cara de entrada hasta el punto de corte de las caras.
			input_face_to_intersection_point = ST_ShortestLine(input_fiber_to_face ,faces_intersection_point);
			-- Se actualizza la geometría de la fibra
			new_input_geom = ST_LineMerge(
					ST_MakeLine(
						ST_MakeLine(input_fiber.layout_geom, input_fiber_to_face),
						input_face_to_intersection_point
					)
				);
        -- Actualizar geometría de la fibra de entrada
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis=$2', schema_name) USING new_input_geom, input_fiber.id_gis;

        -- FIBRA DE SALIDA
        -- Punto de corte de cara mas corta con segunda cara mas corta
        output_faces_intersection_point = ST_Intersection(second_closest_output_face, closest_output_face);
        -- Se crea la linea entre el punto de interseccion real y en el que interseccionan las caras outer
        output_faces_line = ST_MakeLine(faces_intersection_point, output_faces_intersection_point);
        -- Continuación de la cara de salida hasta la fibra de salida.
        output_fiber_to_face = ST_ShortestLine(closest_output_face ,output_fiber_point);
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

        -- Actualizar geometría de la fibra de salida
       EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis=$2', schema_name) USING new_output_geom, output_fiber.id_gis;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION disconnect_fibers(id_gis_fiber1 VARCHAR, id_gis_fiber2 VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
		splice_record RECORD;
		fiber_record_1 RECORD;
		fiber_record_2 RECORD;
	BEGIN 
        EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_record_1 USING id_gis_fiber1;
        EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_record_2 USING id_gis_fiber2;
        EXECUTE format('SELECT * FROM %I.fo_splice WHERE ST_Intersects(layout_geom, $1) AND ST_Intersects(layout_geom, $2)', schema_name) 
            INTO splice_record 
        USING fiber_record_1.layout_geom, fiber_record_2.layout_geom;

        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_gis = $2') USING splice_record, id_gis_fiber_1;
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_gis = $2') USING splice_record, id_gis_fiber_2;

        -- Se actualiza la topología de fibras
        PERFORM update_fiber_topology(schema_name);
	END;
	$$
LANGUAGE plpgsql;


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION connect_optical_splitter_ports(id_gis_out_port VARCHAR, id_gis_in_port VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
		out_port_record RECORD;
		in_port_record RECORD;
		gutiar_port_conextion_line GEOMETRY;
		new_pig_tail_geom GEOMETRY;
	BEGIN
        EXECUTE format('SELECT * FROM %I.in_port WHERE id_gis = $1', schema_name) INTO out_port_record USING id_gis_out_port;
        EXECUTE format('SELECT * FROM %I.out_port WHERE id_gis = $1', schema_name) INTO in_port_record USING id_gis_in_port;

		gutiar_port_conextion_line := ST_OffsetCurve(ST_ShortestLine(out_port_record.geom, in_port_record.geom), 0.00003, 'quad_segs=4 join=round');

		new_pig_tail_geom := ST_MakeLine(out_port_record.geom, ST_StartPoint(gutiar_port_conextion_line));
		new_pig_tail_geom := ST_MakeLine(new_pig_tail_geom, ST_EndPoint(gutiar_port_conextion_line));
		new_pig_tail_geom := ST_MakeLine(new_pig_tail_geom, in_port_record.geom);

        EXECUTE format('INSERT INTO %i.pig_tail(geom) VALUES($1)', schema_name) USING new_pig_tail_geom;		
	END;
	$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION disconnect_optical_splitter_ports(id_gis_out_port VARCHAR, id_gis_in_port VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
        in_port_geom GEOMETRY;
        out_port_geom GEOMETRY;
	BEGIN
        EXECUTE format('SELECT geom FROM %I.in_port WHERE id_gis = $1', schema_name) INTO in_port_geom USING id_gis_in_port;
        EXECUTE format('SELECT geom FROM %I.out_port WHERE id_gis = $1', schema_name) INTO out_port_geom USING id_gis_out_port;

        EXECUTE format('DELETE FROM %I.pig_tail WHERE ST_Intersects(geom, $1) AND ST_Intersects(geom, $2)', schema_name) USING in_port_geom, out_port_geom;
	END;
	$$
LANGUAGE plpgsql;


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--FUNCIÓN PARA CONECTAR FIBRAS Y PUERTOS
CREATE OR REPLACE FUNCTION connect_fiber_splitter_port(id_gis_fiber VARCHAR, id_gis_port VARCHAR, schema_name TEXT) RETURNS void
AS
$$
DECLARE
    fiber_rec RECORD;
    fo_splice_rec RECORD;
    port_rec RECORD;
    input_fiber RECORD;
    output_fiber RECORD;
    input_fiber_point GEOMETRY;
    output_fiber_point GEOMETRY;
    clossest_input_face GEOMETRY;
    clossest_output_face GEOMETRY;
    input_fiber_to_face GEOMETRY;
    output_fiber_to_face GEOMETRY;
    new_input_geom GEOMETRY;
    new_output_geom GEOMETRY;
    faces_intersection_point GEOMETRY;
    second_closest_input_face GEOMETRY;
    second_closest_output_face GEOMETRY;
    inputput_faces_intersection_point GEOMETRY;
    output_faces_intersection_point GEOMETRY;
    face_1 GEOMETRY;
    face_2 GEOMETRY;
    face_3 GEOMETRY;
    face_4 GEOMETRY;
    n_guitar_lines INTEGER := 1000;
    width FLOAT := 0.0000375;
    port_count INTEGER;
BEGIN
    -- Recuperar el registro de fibra
    EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis=$1', schema_name) INTO fiber_rec USING id_gis_fiber;
    IF fiber_rec IS NULL THEN
        RAISE EXCEPTION 'No se encontró fibra con id_gis %', id_gis_fiber;
    END IF;

    -- Verificar y recuperar el puerto correspondiente
    EXECUTE format('SELECT count(*) FROM %I.in_port WHERE id_gis=$1', schema_name) INTO port_count USING id_gis_port;
    IF port_count > 0 THEN
        EXECUTE format('SELECT * FROM %I.in_port WHERE id_gis=$1', schema_name) INTO port_rec USING id_gis_port;
    ELSE
        EXECUTE format('SELECT * FROM %I.out_port WHERE id_gis=$1', schema_name) INTO port_rec USING id_gis_port;
    END IF;

    IF port_rec IS NULL THEN
        RAISE EXCEPTION 'No se encontró puerto con id_gis %', id_gis_port;
    END IF;

    -- Recuperar el registro de splice correspondiente
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO fo_splice_rec USING port_rec.geom;
    IF fo_splice_rec IS NULL THEN
        RAISE EXCEPTION 'No se encontró splice correspondiente al puerto con id_gis %', id_gis_port;
    END IF;

    RAISE NOTICE 'Fiber_rec %', fiber_rec;
    RAISE NOTICE 'Port_count %', port_count;
    RAISE NOTICE 'port_rec %', port_rec;
    RAISE NOTICE 'Distancia %', ST_Distance(ST_StartPoint(fiber_rec.layout_geom), fo_splice_rec.layout_geom);

    -- Determinar si la fibra es de entrada o salida
    IF ST_Distance(ST_StartPoint(fiber_rec.layout_geom), fo_splice_rec.layout_geom) < 0.005 THEN
        RAISE NOTICE 'output';
        output_fiber := fiber_rec;
        output_fiber_point := ST_StartPoint(fiber_rec.layout_geom);
    ELSE
        RAISE NOTICE 'input';
        input_fiber := fiber_rec;
        input_fiber_point := ST_EndPoint(fiber_rec.layout_geom);
    END IF;

    RAISE NOTICE 'input_fiber_point: %', input_fiber_point;
    RAISE NOTICE 'fiber_rec.layout_geom: %', fiber_rec.layout_geom;

    -- Asignar y trabajar con las caras
    face_1 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=1), 
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2));
    face_2 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=2), 
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3));
    face_3 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=3), 
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4));
    face_4 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=4), 
        (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2]=5));

    -- Encontrar el carril por el que irá la conexión
    FOR i IN 0..1000 LOOP           
        IF (ST_Distance(port_rec.geom, ST_OffsetCurve(face_2, -width * (n_guitar_lines + i), 'quad_segs=4 join=round')) < 0.000025) THEN
            n_guitar_lines := n_guitar_lines + i;
            EXIT;
        END IF;
    END LOOP;

    -- Determinar la cara más cercana al punto de entrada o salida
    IF input_fiber_point IS NOT NULL THEN
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

    -- Ajustar cara 2
    face_2 := ST_OffsetCurve(face_2, -width * n_guitar_lines, 'quad_segs=4 join=round');

    -- Manejar input_fiber
    IF clossest_input_face IS NOT NULL THEN      
        clossest_input_face := ST_OffsetCurve(clossest_input_face, -width * n_guitar_lines, 'quad_segs=4 join=round');
        IF clossest_input_face = face_2 THEN
            RAISE NOTICE 'CASO 1';
            input_fiber_to_face := ST_ShortestLine(input_fiber_point ,clossest_input_face);
            new_input_geom := ST_LineMerge(
                ST_MakeLine(
                    ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
                    port_rec.geom
                )
            );
        ELSIF ST_Intersects(clossest_input_face, face_2) THEN           
            RAISE NOTICE 'CASO 2';     
            faces_intersection_point := ST_Intersection(clossest_input_face, face_2);
            input_fiber_to_face := ST_ShortestLine(input_fiber_point ,clossest_input_face);
            new_input_geom := ST_LineMerge(
                ST_MakeLine(
                    ST_MakeLine(
                        ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
                        faces_intersection_point
                    ),
                    port_rec.geom
                )
            );
        ELSE           
            RAISE NOTICE 'CASO 3';
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

            second_closest_input_face := ST_OffsetCurve(second_closest_input_face, -width * n_guitar_lines, 'quad_segs=4 join=round');
            input_fiber_to_face := ST_ShortestLine(input_fiber_point ,clossest_input_face);
            inputput_faces_intersection_point := ST_Intersection(second_closest_input_face, clossest_input_face);
            faces_intersection_point := ST_Intersection(second_closest_input_face, face_2);
            new_input_geom := ST_LineMerge(
                ST_MakeLine(
                    ST_MakeLine(
                        ST_MakeLine(
                            ST_MakeLine(fiber_rec.layout_geom, input_fiber_to_face),
                            inputput_faces_intersection_point
                        ),
                        faces_intersection_point
                    ),
                    port_rec.geom
                )
            );
        END IF;
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom=$1, source=NULL, target=NULL WHERE id_gis=$2', schema_name) USING new_input_geom, input_fiber.id_gis;
    ELSIF clossest_output_face IS NOT NULL THEN
        clossest_output_face := ST_OffsetCurve(clossest_output_face, -width * n_guitar_lines, 'quad_segs=4 join=round');
        IF clossest_output_face = face_2 THEN
            output_fiber_to_face := ST_ShortestLine(clossest_output_face, output_fiber_point);
            new_input_geom := ST_LineMerge(
                ST_MakeLine(
                    port_rec.geom,
                    ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                            
                )
            );
        ELSIF ST_Intersects(clossest_output_face, face_2) THEN
            faces_intersection_point := ST_Intersection(clossest_output_face, face_2);
            output_fiber_to_face := ST_ShortestLine(clossest_output_face, output_fiber_point);
            new_output_geom := ST_LineMerge(
                ST_MakeLine(
                    port_rec.geom,
                    ST_MakeLine(
                        faces_intersection_point,
                        ST_MakeLine(output_fiber_to_face, fiber_rec.layout_geom)                               
                    )                            
                )
            );
        ELSE
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
            second_closest_output_face := ST_OffsetCurve(second_closest_output_face, -width * n_guitar_lines, 'quad_segs=4 join=round');
            output_fiber_to_face := ST_ShortestLine(clossest_output_face, output_fiber_point);
            output_faces_intersection_point := ST_Intersection(second_closest_output_face, clossest_output_face);
            faces_intersection_point := ST_Intersection(second_closest_output_face, face_2);
            new_output_geom := ST_LineMerge(
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
        PERFORM update_fiber_topology(schema_name);
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom=$1, source=NULL, target=NULL WHERE id_gis=$2', schema_name) USING new_output_geom, output_fiber.id_gis;
    END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION disconnect_fiber_port(id_gis_fiber VARCHAR, id_gis_port VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
		splice_record RECORD;
		fiber_record RECORD;
		port_record RECORD;
	BEGIN 
        EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_record USING id_gis_fiber;
        EXECUTE format('SELECT * FROM %I.in_port WHERE id_gis = $1', schema_name) INTO port_record USING id_gis_port;

        IF port_record IS NULL THEN  
            EXECUTE format('SELECT * FROM %I.out_port WHERE id_gis = $1', schema_name) INTO port_record USING id_gis_port;
        END IF;

        EXECUTE format('SELECT * FROM %I.fo_splice WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO splice_record USING port_record.geom;

        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_gis = $2', schema_name) USING splice_record.layout_geom, id_gis_fiber;
    
        -- Se actualiza la topología de fibras
        PERFORM update_fiber_topology(schema_name);
	END;
	$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION connect_fiber_ont(id_gis_fiber VARCHAR, id_gis_ont VARCHAR, schema_name TEXT) RETURNS VOID AS 
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
    -- Obtener registros de fibra, ONT y cliente
    EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_record USING id_gis_fiber;
    EXECUTE format('SELECT * FROM %I.optical_network_terminal WHERE id_gis = $1', schema_name) INTO ont_record USING id_gis_ont;
    EXECUTE format('SELECT * FROM %I.cw_client WHERE ST_Intersects($1, layout_geom)', schema_name) INTO client_record USING ont_record.geom;
    RAISE NOTICE 'fiber_record %', fiber_record;
    RAISE NOTICE 'ont_record %', ont_record;
    RAISE NOTICE 'client_record %', client_record;

    -- Obtener caras del cliente
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

    -- Encontrar la cara más cercana del cliente a la fibra
    min_distance := NULL;
    FOR e IN 1..array_length(client_faces_array, 1) LOOP
        IF min_distance IS NULL OR ST_Distance(client_faces_array[e], fiber_record.layout_geom) < min_distance THEN
            min_distance := ST_Distance(client_faces_array[e], fiber_record.layout_geom);
            closest_client_face := client_faces_array[e];
        END IF;
    END LOOP;
 RAISE NOTICE 'closest_client_face %', closest_client_face;
    -- Calcular el número de cables y la cara de cliente ajustada
    EXECUTE format('SELECT count(DISTINCT id_cable) FROM %I.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.00003', schema_name) 
        INTO n_cables 
    USING client_record.layout_geom;
    n_cables := n_cables + 1;
    guitar_client_face := ST_OffsetCurve(closest_client_face, -0.0075 * n_cables, 'quad_segs=4 join=mitre mitre_limit=2.2');
RAISE NOTICE 'new_layout_geom %', new_layout_geom;
    -- Crear la nueva geometría de diseño de fibra
    new_layout_geom := ST_MakeLine(
            fiber_record.layout_geom,
            ST_ShortestLine(fiber_record.layout_geom, guitar_client_face)
        );
RAISE NOTICE 'new_layout_geom %', new_layout_geom;
    new_layout_geom := ST_MakeLine(
            new_layout_geom,
            ST_Intersection(guitar_client_face, ST_ShortestLine(guitar_client_face, ont_record.geom))
        );
RAISE NOTICE 'new_layout_geom %', new_layout_geom;
    new_layout_geom := ST_MakeLine(
            new_layout_geom,
            ST_ShortestLine(guitar_client_face, ont_record.geom)
        );
RAISE NOTICE 'new_layout_geom %', new_layout_geom;
    -- Actualizar el registro de fibra con la nueva geometría
    EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis = $2', schema_name) USING new_layout_geom, id_gis_fiber;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION disconnect_fiber_ont(id_gis_fiber VARCHAR, id_gis_ont VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
		ont_record RECORD;
		fiber_record RECORD;
		location_record RECORD;
	BEGIN 
        EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_record USING id_gis_fiber;
        EXECUTE format('SELECT * FROM %I.optical_network_terminal WHERE id_gis = $1', schema_name) INTO ont_record USING id_gis_ont;
        EXECUTE format('SELECT * FROM %I.cw_client WHERE ST_Intersects($1, layout_geom)', schema_name) INTO location_record USING ont_record.geom;

        -- Actualizar el registro de fibra con la nueva geometría
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_gis = $2', schema_name) USING location_record.layout_geom, id_gis_fiber;
        -- Se actualiza la topología de fibras
        PERFORM update_fiber_topology(schema_name);
	END;
	$$
LANGUAGE plpgsql;


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION connect_fiber_building_port(
    id_gis_fiber VARCHAR,
    id_gis_port VARCHAR,
    schema_name TEXT
) RETURNS VOID AS 
$$
DECLARE
    fiber_record RECORD;
    port_record RECORD;
    card_record RECORD;
    rack_record RECORD;
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
    fiber_intersects_count INTEGER;
BEGIN
    -- Obtener registros usando el esquema dinámico
    EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_record USING id_gis_fiber;
    EXECUTE format('SELECT * FROM %I.port WHERE id_gis = $1', schema_name) INTO port_record USING id_gis_port;
    EXECUTE format('SELECT * FROM %I.rack WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO rack_record USING port_record.geom;
    EXECUTE format('SELECT * FROM %I.card WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO card_record USING port_record.geom;

    RAISE NOTICE 'fiber_record %', fiber_record;
    RAISE NOTICE 'port_record %', port_record;
    RAISE NOTICE 'rack_record %', rack_record;
    RAISE NOTICE 'card_record %', card_record;

    -- Contar los puertos contenidos en la tarjeta
    EXECUTE format('SELECT count(*) FROM %I.port WHERE ST_Contains($1, geom)', schema_name) INTO n_ports_on_card USING card_record.layout_geom;
    RAISE NOTICE 'n_ports_on_card %', n_ports_on_card;
    -- Obtener caras de rack y tarjeta usando el esquema dinámico
    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_faces_array USING rack_record.id_gis;

    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.card WHERE id_gis = $1', schema_name) INTO card_faces_array USING card_record.id_gis;

    -- Determinar líneas para conectar la fibra
    min_distance := NULL;
    
    FOR i IN 1..array_length(rack_faces_array, 1)
    LOOP
        IF min_distance IS NULL OR (ST_Distance(rack_faces_array[i], fiber_record.layout_geom) > 0.000003 AND ST_Distance(rack_faces_array[i], fiber_record.layout_geom) < min_distance)
        THEN
            min_distance := ST_Distance(rack_faces_array[i], fiber_record.layout_geom);
            rack_up_guitar_line := rack_faces_array[i];
            IF i = 1 
            THEN
                 rack_guitar_line := rack_faces_array[i + 3];
            ELSE
                rack_guitar_line := rack_faces_array[i - 1];
            END IF;            
        END IF;
    END LOOP;
    
    RAISE NOTICE 'rack_guitar_line %', rack_guitar_line;
    min_distance := NULL;

    FOR i IN 1..array_length(card_faces_array, 1)
    LOOP
        IF min_distance IS NULL OR ST_Distance(ST_Centroid(card_faces_array[i]), rack_up_guitar_line) < min_distance
        THEN
            min_distance := ST_Distance(ST_Centroid(card_faces_array[i]), rack_up_guitar_line);
            card_line := card_faces_array[i];
        END IF;
    END LOOP;
    RAISE NOTICE 'card_line %', card_line;
    min_distance := NULL;

    FOR i IN 1..array_length(card_faces_array, 1)
    LOOP
        IF min_distance IS NULL OR ST_Distance(ST_Centroid(card_faces_array[i]), ST_Centroid(rack_guitar_line)) < min_distance
        THEN
            min_distance := ST_Distance(ST_Centroid(card_faces_array[i]), ST_Centroid(rack_guitar_line));
            card_bottom_line := card_faces_array[i];
        END IF;
    END LOOP;
 RAISE NOTICE 'card_bottom_line %', card_bottom_line;
    -- Contar fibras cruzando el rack usando esquema dinámico
    EXECUTE format('SELECT count(*) FROM %I.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.0003', schema_name) INTO n_fibers_crossing_rack USING rack_record.layout_geom;

    -- Generar caras con offset para que la fibra recorra la autopista
    rack_guitar_line := ST_OffsetCurve(rack_guitar_line, -0.0001 * (n_fibers_crossing_rack + 1), 'quad_segs=4 join=mitre mitre_limit=2.2');
    rack_up_guitar_line := ST_OffsetCurve(rack_up_guitar_line, -0.0001 * (n_fibers_crossing_rack + 1), 'quad_segs=4 join=mitre mitre_limit=2.2');
 RAISE NOTICE 'rack_guitar_line %', rack_guitar_line;
  RAISE NOTICE 'rack_up_guitar_line %', rack_up_guitar_line;
    FOR i IN 1..n_ports_on_card
    LOOP
        card_guitar_line := ST_OffsetCurve(card_line, -0.0000375 * i, 'quad_segs=4 join=mitre mitre_limit=2.2');
        card_bottom_guitar_line := ST_OffsetCurve(card_bottom_line, -0.0000375 * i, 'quad_segs=4 join=mitre mitre_limit=2.2');
        card_guitar_line_points := ST_LineInterpolatePoints(card_guitar_line, (1 / n_ports_on_card::FLOAT), true);
        RAISE NOTICE 'card_guitar_line %', card_guitar_line;
        RAISE NOTICE 'card_bottom_guitar_line %', card_bottom_guitar_line;
        RAISE NOTICE 'card_guitar_line_points %', card_guitar_line_points;
        -- Contar la intersección con fibras usando esquema dinámico
        EXECUTE format('SELECT count(*) FROM %I.fo_fiber WHERE ST_Intersects(layout_geom, ST_GeometryN($1, $2))', schema_name) INTO fiber_intersects_count USING card_guitar_line_points, i;
        RAISE NOTICE 'fiber_intersects_count %', fiber_intersects_count;

        IF fiber_intersects_count = 0
        THEN
             RAISE NOTICE 'ST_Distance(ST_EndPoint(fiber_record.layout_geom), rack_record.layout_geom) %', ST_Distance(ST_EndPoint(fiber_record.layout_geom), rack_record.layout_geom);
            IF ST_Distance(ST_EndPoint(fiber_record.layout_geom), rack_record.layout_geom) < 0.000003
            THEN
                -- Generar la autopista
                new_fiber_layout_geom := ST_MakeLine(
                    fiber_record.layout_geom,
                    ST_ShortestLine(ST_EndPoint(fiber_record.layout_geom), rack_guitar_line)
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                new_fiber_layout_geom := ST_MakeLine(
                    new_fiber_layout_geom,
                    ST_ShortestLine(ST_EndPoint(new_fiber_layout_geom), rack_up_guitar_line)
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                new_fiber_layout_geom := ST_MakeLine(
                    new_fiber_layout_geom,
                    ST_Intersection(ST_ShortestLine(rack_up_guitar_line, ST_GeometryN(card_guitar_line_points, i)), rack_up_guitar_line)
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                new_fiber_layout_geom := ST_MakeLine(
                    new_fiber_layout_geom,
                    ST_ShortestLine(rack_up_guitar_line, ST_GeometryN(card_guitar_line_points, i))
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                new_fiber_layout_geom := ST_MakeLine(
                    new_fiber_layout_geom,
                    ST_ShortestLine(ST_EndPoint(new_fiber_layout_geom), card_bottom_guitar_line)
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                aux_line := ST_OffsetCurve(
                    ST_ShortestLine(card_bottom_guitar_line, port_record.geom),
                    0.0002 + (0.0000375 * i),
                    'quad_segs=4 join=mitre mitre_limit=2.2'
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                new_fiber_layout_geom := ST_MakeLine(
                    new_fiber_layout_geom,
                    ST_Intersection(
                        card_bottom_guitar_line,
                        aux_line
                    )
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                new_fiber_layout_geom := ST_MakeLine(
                    new_fiber_layout_geom,
                    aux_line
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                new_fiber_layout_geom := ST_MakeLine(
                    new_fiber_layout_geom,
                    port_record.geom
                );
 RAISE NOTICE 'new_fiber_layout_geom %', new_fiber_layout_geom;
                -- Actualizar el registro de la fibra
                EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis = $2', schema_name)
                USING new_fiber_layout_geom, fiber_record.id_gis;

                RETURN;
            END IF;
        ELSE
            -- TODO: lógica para hilos de salida de puertos
        END IF;

        -- Se actualiza la topología de fibras
        PERFORM update_fiber_topology(schema_name);

    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION disconnect_fiber_building_port(id_gis_fiber VARCHAR, id_gis_port VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
		port_record RECORD;
		fiber_record RECORD;
		rack_record RECORD;
	BEGIN 
        EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO fiber_record USING id_gis_fiber;
        EXECUTE format('SELECT * FROM %I.port WHERE id_gis = $1', schema_name) INTO port_record USING id_gis_port;
        EXECUTE format('SELECT * FROM %I.rack WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO rack_record USING port_record.geom;

        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_gis = $2', schema_name) 
        USING rack_record.layout_geom, id_gis_fiber;
        
        -- Se actualiza la topología de fibras
        PERFORM update_fiber_topology(schema_name);
	END;
	$$
LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION connect_cable_rack(id_gis_cable VARCHAR, id_gis_rack VARCHAR, schema_name TEXT) RETURNS VOID AS 
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
    count_cable INTEGER;
    count_splice INTEGER;
    count_rack INTEGER;
    count_location INTEGER;
    count_floor INTEGER;
    count_cable_2 INTEGER;
    count_cable_3 INTEGER;
    count_cable_4 INTEGER;
    count_cable_5 INTEGER;
BEGIN
    -- Obtener el registro del cable
    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_record USING id_gis_cable;
    RAISE NOTICE 'cable_record %', cable_record;
    
    -- Obtener el registro del rack
    EXECUTE format('SELECT * FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_record USING id_gis_rack;
     RAISE NOTICE 'rack_record %', rack_record;
    -- Obtener el registro del edificio
    EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO building_record USING rack_record.layout_geom;
     RAISE NOTICE 'building_record %', building_record;
    -- Obtener el registro de la ubicación
    EXECUTE format('SELECT * FROM %I.cw_client WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO location_record USING rack_record.layout_geom;
     RAISE NOTICE 'location_record %', location_record;
    -- Obtener el registro del piso
    EXECUTE format('SELECT * FROM %I.cw_floor WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO floor_record USING rack_record.layout_geom;
 RAISE NOTICE 'floor_record %', floor_record;
    IF location_record IS NULL THEN
        -- Obtener el registro de la sala si no hay ubicación
        EXECUTE format('SELECT * FROM %I.cw_room WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO location_record USING rack_record.layout_geom;
    END IF;
 RAISE NOTICE 'location_record %', location_record;
    -- Obtener las caras del edificio
    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.cw_building WHERE id_gis = $1', schema_name) INTO building_faces_array USING building_record.id_gis;
    
    -- Obtener las caras del piso
    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.cw_floor WHERE id_gis = $1', schema_name) INTO floor_faces_array USING floor_record.id_gis;

    -- Obtener las caras de la ubicación
    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.cw_client WHERE id_gis = $1', schema_name) INTO location_faces_array USING location_record.id_gis;

    -- Obtener las caras del rack
    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_faces_array USING rack_record.id_gis;

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
    -- Determinar la posición del cable


    -- Determinar la posición del piso
    EXECUTE format('SELECT COUNT(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.0003
        AND	ST_Length(ST_Intersection(layout_geom, $1)) > 0.0005', schema_name) 
        INTO pos 
    USING  building_record.layout_geom;

    building_bottom_guitar_line := ST_OffsetCurve(building_bottom_line, -0.5 + (-0.0125 * pos), 'quad_segs=4 join=mitre mitre_limit=2.2');
    building_up_guitar_line := ST_OffsetCurve(building_up_line, -1 + (-0.0125 * pos), 'quad_segs=4 join=mitre mitre_limit=2.2');

    EXECUTE format('SELECT COUNT(*) FROM %I.fo_cable WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO count_floor USING floor_record.layout_geom;
    EXECUTE format('SELECT COUNT(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) INTO count_location USING location_record.layout_geom;
    floor_up_guitar_line := ST_OffsetCurve(
            floor_up_line,
            -0.0075 * (count_floor + 1),
            'quad_segs=4 join=mitre mitre_limit=2.2'
        );

    floor_bottom_guitar_line := ST_OffsetCurve(
            floor_bottom_line,
            -0.0075 * (count_floor + 1),
            'quad_segs=4 join=mitre mitre_limit=2.2'
        );		

    location_up_guitar_line := ST_OffsetCurve(
            location_up_line,
            -0.0075 * (count_location + 1),
            'quad_segs=4 join=mitre mitre_limit=2.2'
        );

    location_bottom_guitar_line := ST_OffsetCurve(
            location_bottom_line,
            -0.0075 * (count_location + 1),
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
    
    FOR i IN 1..ST_NumGeometries(floor_up_line_points) LOOP
        pos := ST_NumGeometries(floor_up_line_points) - i;

        EXECUTE format('SELECT COUNT(*) FROM %I.fo_cable WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO count_cable USING ST_GeometryN(floor_up_line_points, pos);
        IF count_cable = 0 THEN
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

    FOR i IN 1..ST_NumGeometries(location_face_points) LOOP
        pos := ST_NumGeometries(location_face_points) - i;
        EXECUTE format('SELECT COUNT(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) INTO count_cable USING ST_GeometryN(location_face_points, pos);
        IF count_cable = 0 THEN
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

    -- Primero, obtener el conteo de cables en la proximidad del rack
    EXECUTE format('SELECT COUNT(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.0001', schema_name) INTO count_cable USING rack_record.layout_geom;

    -- Luego, usar el conteo obtenido para definir la línea de la guitarra del rack
    rack_in_guitar_line := ST_LineExtend(
        ST_OffsetCurve(
            rack_in_line, 
            0.0075 * (count_cable + 1), 
            'quad_segs=4 join=mitre mitre_limit=2.2'
        ), 
        0.50, 
        0.50
    );

    new_cable_layout_geom := ST_MakeLine(
            new_cable_layout_geom,
            ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_Intersection(rack_in_guitar_line, location_up_guitar_line))
        );	

    new_cable_layout_geom := ST_MakeLine(
            new_cable_layout_geom,
            ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_Intersection(rack_in_guitar_line, ST_LineExtend(ST_ShortestLine(rack_in_guitar_line, ST_GeometryN(ST_LineInterpolatePoints(rack_in_line, 0.05, true), 18)), 0.005, 0.005)))
        );	

    new_cable_layout_geom := ST_MakeLine(
            new_cable_layout_geom,
            ST_ShortestLine(ST_EndPoint(new_cable_layout_geom), ST_GeometryN(ST_LineInterpolatePoints(rack_in_line, 0.05, true), 18))
        );


    IF ST_Distance(ST_EndPoint(cable_record.layout_geom), building_record.layout_geom) > ST_Distance(ST_StartPoint(cable_record.layout_geom), building_record.layout_geom)
    THEN
        new_cable_layout_geom := ST_Reverse(new_cable_layout_geom);
    END IF; 

    RAISE NOTICE 'new_cable_layout_geom %', new_cable_layout_geom;
    -- Actualizar el cable
    EXECUTE format('UPDATE %I.fo_cable SET layout_geom = $1 WHERE id_gis = $2', schema_name) USING new_cable_layout_geom, cable_record.id_gis;

    -- Volver a seleccionar el cable
    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_record USING cable_record.id_gis;

    -- Llamar a la función de actualización
    PERFORM update_fo_fiber_to_splice(schema_name, cable_record.id_gis, cable_record.layout_geom);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION disconnect_cable_rack(id_gis_cable VARCHAR, id_gis_rack VARCHAR, schema_name TEXT) RETURNS void
AS
	$$
	DECLARE
		rack_record RECORD;
		cable_record RECORD;
		building_record RECORD;
	BEGIN 

        EXECUTE format('SELECT * FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_record USING id_gis_rack;
        EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_record USING id_gis_cable;
        EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO building_record USING rack_record.layout_geom;

        EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_gis = $2', schema_name) 
        USING building_record.layout_geom, id_gis_cable;
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL WHERE id_cable = $2', schema_name) 
        USING building_record.layout_geom, id_gis_cable;
        
        -- Se actualiza la topología de fibras
        PERFORM update_fiber_topology(schema_name);
	END;
	$$
LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION connect_splice_client(id_gis_splice VARCHAR, id_gis_client VARCHAR, schema_name TEXT) RETURNS RECORD AS 
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
    min_distance FLOAT;
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
    -- Obtener registros actuales
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO current_splice_record USING id_gis_splice;
    EXECUTE format('SELECT * FROM %I.cw_client WHERE id_gis = $1', schema_name) INTO current_client_record USING id_gis_client;
    EXECUTE format('SELECT * FROM %I.cw_floor WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO current_floor_record USING current_client_record.layout_geom;
    EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO current_building_record USING current_client_record.layout_geom;

    RAISE NOTICE 'current_splice_record %',current_splice_record;
    RAISE NOTICE 'current_client_record %',current_client_record;
    RAISE NOTICE 'current_floor_record %',current_floor_record;
    RAISE NOTICE 'current_building_record %',current_building_record;

    -- Caras del empalme
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

    -- Caras del floor
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

    -- Caras del cliente
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

    -- Obtener las caras más cercanas
    FOR i IN 1..array_length(splice_array, 1) LOOP
        FOR e IN 1..array_length(floor_array, 1) LOOP
            IF min_distance IS NULL OR ST_Distance(splice_array[i], ST_Centroid(floor_array[e])) < min_distance THEN
                min_distance := ST_Distance(splice_array[i], ST_Centroid(floor_array[e]));
                closest_splice_face := splice_array[i];
                closest_floor_face := floor_array[e];
            END IF;
        END LOOP;
    END LOOP;

    FOR e IN 1..array_length(floor_array, 1) LOOP
        IF NOT (ST_Distance(current_client_record.layout_geom, floor_array[e]) < 0.00003) AND (ST_Distance(floor_array[e], closest_floor_face) < 0.00003) THEN
            bottom_floor_face := floor_array[e];
        END IF;
    END LOOP;

    min_distance := NULL;
    FOR e IN 1..array_length(client_array, 1) LOOP
        IF min_distance IS NULL OR ST_Distance(ST_Centroid(client_array[e]), bottom_floor_face) < min_distance THEN
            min_distance := ST_Distance(ST_Centroid(client_array[e]), bottom_floor_face);
            closest_client_face := client_array[e];
        END IF;
    END LOOP;

    -- Obtener puntos libres en las caras
    splice_face_points := ST_LineInterpolatePoints(closest_splice_face, 0.045, true);
    floor_face_points := ST_LineInterpolatePoints(closest_floor_face, 0.045, true);
    client_face_points := ST_LineInterpolatePoints(closest_client_face, 0.045, true);

    FOR i IN 2..(ST_NumGeometries(splice_face_points)-1) LOOP
        EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) INTO min_distance USING ST_GeometryN(splice_face_points, i);
        IF min_distance = 0 THEN
            splice_free_point := ST_GeometryN(splice_face_points, i);
            EXIT;
        END IF;
    END LOOP;

    FOR i IN 2..(ST_NumGeometries(floor_face_points)-1) LOOP
        EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) INTO min_distance USING ST_GeometryN(floor_face_points, i);
        IF min_distance = 0 THEN
            floor_free_point := ST_GeometryN(floor_face_points, i);
            EXIT;
        END IF;
    END LOOP;

    FOR i IN 2..(ST_NumGeometries(client_face_points)-1) LOOP
        EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) INTO min_distance USING ST_GeometryN(client_face_points, ST_NumGeometries(client_face_points) - i);
        IF min_distance = 0 THEN
            client_free_point := ST_GeometryN(client_face_points, ST_NumGeometries(client_face_points) - i);
            EXIT;
        END IF;
    END LOOP;

    -- Obtener número de cables
    EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO n_cables_building USING current_building_record.layout_geom;
    EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO n_cables_floor USING current_floor_record.layout_geom;

    -- Crear líneas para el guitar line
    splice_guitar_line := ST_LineExtend(ST_OffsetCurve(closest_splice_face, 0.0075 * (n_cables_building + 1), 'quad_segs=4 join=mitre mitre_limit=2.2'), 10, 10);
    closest_floor_guitar_line := ST_LineExtend(ST_OffsetCurve(closest_floor_face, -0.0075 * (n_cables_floor + 1), 'quad_segs=4 join=mitre mitre_limit=2.2'), 10, 10);
    bottom_floor_guitar_line := ST_LineExtend(ST_OffsetCurve(bottom_floor_face, -0.0075 * (n_cables_floor + 1), 'quad_segs=4 join=mitre mitre_limit=2.2'), 10, 10);

    -- Crear la geometría del cable
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

    -- Insertar nuevo cable y devolver el registro
    EXECUTE format('INSERT INTO %I.fo_cable(geom, layout_geom, is_acometida) VALUES ($1, $2, $3) RETURNING *', schema_name) 
    INTO new_cable_record 
    USING ST_MakeLine(current_splice_record.geom, ST_Centroid(current_client_record.geom)), cable_layout_geom, true;

    RETURN new_cable_record;
END;
$$
LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION connect_splice_splice(id_gis_splice_1 VARCHAR, id_gis_splice_2 VARCHAR, schema_name TEXT) RETURNS VOID AS 
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
    -- Obtener registros de los empalmes
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO splice_record_1 USING id_gis_splice_1;
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO splice_record_2 USING id_gis_splice_2;
    RAISE NOTICE 'splice_record_1 %', splice_record_1;
    RAISE NOTICE 'splice_record_2 %', splice_record_2;
    -- Obtener caras del empalme 1
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

    -- Encontrar la cara más cercana del empalme 1 al empalme 2
    min_distance := NULL;
    FOR e IN 1..array_length(splice_faces_array, 1) LOOP
        IF min_distance IS NULL OR ST_Distance(ST_Centroid(splice_faces_array[e]), splice_record_2.layout_geom) < min_distance THEN
            min_distance := ST_Distance(ST_Centroid(splice_faces_array[e]), splice_record_2.layout_geom);
            closest_splice_face := splice_faces_array[e];
        END IF;
    END LOOP;
     RAISE NOTICE 'closest_splice_face %', closest_splice_face;
    -- Puntos de la cara del empalme más cercana
    splice_face_points := ST_LineInterpolatePoints(closest_splice_face, 0.045, true);
RAISE NOTICE 'splice_face_points %', splice_face_points;
    -- Encontrar un punto libre en la cara del empalme más cercana
    splice_free_point := NULL;
    FOR i IN 2..(ST_NumGeometries(splice_face_points)-1) LOOP
        EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) INTO min_distance USING ST_GeometryN(splice_face_points, i);
        IF min_distance = 0 THEN
            splice_free_point := ST_GeometryN(splice_face_points, i);
            EXIT;
        END IF;
    END LOOP;

    -- Insertar el cable entre los empalmes
    EXECUTE format('INSERT INTO %I.fo_cable(geom, layout_geom, is_acometida) VALUES ($1, $2, $3)', schema_name) 
    USING ST_MakeLine(splice_record_1.geom, splice_record_2.geom), ST_ShortestLine(splice_free_point, splice_record_2.layout_geom), false;

END;
$$
LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION connect_splice_rack(id_gis_splice VARCHAR, id_gis_rack VARCHAR, schema_name TEXT) RETURNS VOID AS 
$$
DECLARE
    splice_record RECORD;
    location_record RECORD;
    rack_record RECORD;
    cable_record RECORD;
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
    r RECORD;  -- Temporary record for cursor fetching
BEGIN
    -- Obtener registros de rack, empalme y ubicación
    EXECUTE format('SELECT * FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_record USING id_gis_rack;
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO splice_record USING id_gis_splice;
    EXECUTE format('SELECT * FROM %I.cw_client WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO location_record USING rack_record.layout_geom;
RAISE NOTICE 'rack_record %', rack_record;
RAISE NOTICE 'splice_record %', splice_record;
RAISE NOTICE 'location_record %', location_record;
    cable_record := connect_splice_client(splice_record.id_gis, location_record.id_gis, schema_name);
RAISE NOTICE 'cable_record %', cable_record;
    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = CONCAT(''fo_cable_'', $1::TEXT)', schema_name) INTO cable_record USING cable_record.id_auto;
RAISE NOTICE 'cable_record %', cable_record;
    -- Cara de entrada
    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
            ] FROM %I.cw_client WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO location_faces_array USING rack_record.layout_geom;

    -- Cara de subida de cables
    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
            ] FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_faces_array USING id_gis_rack;

    -- Cara de entrada
    min_distance := NULL;
    closest_location_face := NULL;
    
    FOR e IN 1..array_length(location_faces_array,1) LOOP
        IF min_distance IS NULL OR ST_Distance(location_faces_array[e], cable_record.layout_geom) < min_distance THEN
            min_distance := ST_Distance(location_faces_array[e], cable_record.layout_geom);
            closest_location_face := location_faces_array[e];
        END IF;
    END LOOP;    

    -- Cara de subida de cables
    min_distance := NULL;
    rise_location_face := NULL;
    
    FOR e IN 1..array_length(location_faces_array,1) LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I.rack WHERE ST_Distance(layout_geom, $1) < 0.06', schema_name) INTO cont USING location_faces_array[e];

        IF cont > 0 THEN
            CONTINUE;
        END IF;

        IF ST_Intersects(closest_location_face, location_faces_array[e]) AND NOT ST_Equals(closest_location_face, location_faces_array[e]) THEN
            rise_location_face := location_faces_array[e];
        END IF;
    END LOOP;

    min_distance := NULL;

    -- Cara de entrada de las racks
    min_distance := NULL;
    in_rack_face := NULL;
    
    FOR e IN 1..array_length(rack_faces_array,1) LOOP
        IF min_distance IS NULL OR ST_Distance(ST_Centroid(rack_faces_array[e]), closest_location_face) < min_distance THEN
            min_distance := ST_Distance(ST_Centroid(rack_faces_array[e]), closest_location_face);
            in_rack_face := rack_faces_array[e];
        END IF;
    END LOOP;

    -- Calcular el número de cables y actualizar la geometría del cable
    EXECUTE format('SELECT count(DISTINCT id_cable) FROM %I.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.00003', schema_name) INTO n_cables USING location_record.layout_geom;
    n_cables := n_cables + 1;

    n_cables_rack := 1;

    EXECUTE format('SELECT * FROM %I.rack 
        WHERE ST_Distance(layout_geom, ST_LineExtend($1, 0.50, 0.50)) < 0.001 
            AND ST_Intersects(layout_geom, $2)', schema_name) INTO current_rack_record USING in_rack_face, location_record.layout_geom;

    FOR current_rack_record IN
        EXECUTE format('SELECT * FROM %I.rack 
            WHERE ST_Distance(layout_geom, ST_LineExtend($1, 0.50, 0.50)) < 0.001 
                AND ST_Intersects(layout_geom, $2)', schema_name) USING in_rack_face, location_record.layout_geom
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.001', schema_name) INTO cont USING current_rack_record.layout_geom;

        IF cont > 0 THEN
            n_cables_rack := n_cables_rack + 1;
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
        
    EXECUTE format('UPDATE %I.fo_cable 
        SET layout_geom = ST_LineMerge($1)
        WHERE id_gis = $2', schema_name) USING new_cable_layout_geom, cable_record.id_gis;
    
    cont := 1;

    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_record USING cable_record.id_gis;

    PERFORM update_fo_fiber_to_splice(schema_name, cable_record.id_gis, new_cable_layout_geom);    
END;
$$
LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- Metodo para la conexión de de fibras en un empalme
CREATE OR REPLACE FUNCTION splice_fiber_connection(
    schema_name TEXT,
	id_gis_cable_1 VARCHAR,
	start_fiber_number_1 INTEGER,
	end_fiber_number_1 INTEGER,
	id_gis_cable_2 VARCHAR,
	start_fiber_number_2 INTEGER,
	end_fiber_number_2 INTEGER
)RETURNS VOID AS 
$$
DECLARE
	id_gis_fiber_1 VARCHAR;
	id_gis_fiber_2 VARCHAR;
	cont INTEGER;
BEGIN
	IF (end_fiber_number_1 - start_fiber_number_1) = (end_fiber_number_2 - start_fiber_number_2)
	THEN
		IF (end_fiber_number_1 - start_fiber_number_1) = 0
		THEN
            EXECUTE format('SELECT id_gis FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_1 USING id_gis_cable_1, start_fiber_number_1;
            EXECUTE format('SELECT id_gis FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_2 USING id_gis_cable_2, start_fiber_number_2;
            RAISE NOTICE 'id_gis_fiber_1 %', id_gis_fiber_1;
            RAISE NOTICE 'id_gis_fiber_2 %', id_gis_fiber_2;
			PERFORM connect_objects(schema_name, id_gis_fiber_1, id_gis_fiber_2);
		ELSE
			cont  := 0;
			FOR i IN start_fiber_number_1..end_fiber_number_1
			LOOP
                EXECUTE format('SELECT id_gis FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_1 USING id_gis_cable_1, i;
                EXECUTE format('SELECT id_gis FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_2 USING id_gis_cable_2, (start_fiber_number_2 + cont);
                RAISE NOTICE 'id_gis_fiber_1 %', id_gis_fiber_1;
                RAISE NOTICE 'id_gis_fiber_2 %', id_gis_fiber_2;
				PERFORM connect_objects(schema_name, id_gis_fiber_1, id_gis_fiber_2);
				cont := cont + 1;
			END LOOP;
		END IF;
	END IF;

    -- Se actualiza la topología de fibras
    PERFORM update_fiber_topology(schema_name);
END;
$$
LANGUAGE plpgsql;

-- Metodo para la desconexión de fibras en un empalme
CREATE OR REPLACE FUNCTION splice_fiber_disconnection(
    schema_name TEXT,
	id_gis_cable_1 VARCHAR,
	start_fiber_number_1 INTEGER,
	end_fiber_number_1 INTEGER,
	id_gis_cable_2 VARCHAR,
	start_fiber_number_2 INTEGER,
	end_fiber_number_2 INTEGER
)RETURNS VOID AS 
$$
DECLARE
	id_gis_fiber_1 VARCHAR;
	id_gis_fiber_2 VARCHAR;
	cont INTEGER;
BEGIN
	IF (end_fiber_number_1 - start_fiber_number_1) = (end_fiber_number_2 - start_fiber_number_2)
	THEN
		IF (end_fiber_number_1 - start_fiber_number_1) = 0
		THEN
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_1 USING id_gis_cable_1, start_fiber_number_1;
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_2 USING id_gis_cable_2, start_fiber_number_2;
			PERFORM disconnect_objects(schema_name, id_gis_fiber_1, id_gis_fiber_2);
		ELSE
			cont  := 0;
			FOR i IN start_fiber_number_1..end_fiber_number_1
			LOOP
				EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_1 USING id_gis_cable_1, i;
                EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber_2 USING id_gis_cable_2, (start_fiber_number_2 + cont);
				PERFORM disconnect_objects(schema_name, id_gis_fiber_1, id_gis_fiber_2);
				cont := cont + 1;
			END LOOP;
		END IF;
	END IF;
END;
$$
LANGUAGE plpgsql;

-- Metodo para la conexión de fibras con splitters en un empalme
CREATE OR REPLACE FUNCTION splice_port_connection(
    schema_name TEXT,
	id_gis_cable VARCHAR,
	fiber_number_var INTEGER,
	id_gis_splitter VARCHAR,
	port_number_var INTEGER,
	source BOOLEAN
)RETURNS VOID AS 
$$
DECLARE
	id_gis_fiber VARCHAR;
	id_gis_port VARCHAR;
    splitter_rec RECORD;
	cont INTEGER;
BEGIN
    EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber USING id_gis_cable, fiber_number_var;
    EXECUTE format('SELECT * FROM %I.optical_splitter WHERE id_gis = $1', schema_name) INTO splitter_rec USING id_gis_splitter;
	IF source
	THEN
        EXECUTE format('SELECT * FROM %I.out_port WHERE ST_DWithin(geom, $1) AND fiber_number = $2', schema_name) INTO id_gis_port USING splitter_rec, port_number_var;
		PERFORM connect_objects(schema_name, id_gis_fiber, id_gis_port);
	ELSE
        EXECUTE format('SELECT * FROM %I.in_port WHERE ST_DWithin(geom, $1) AND fiber_number = $2', schema_name) INTO id_gis_port USING splitter_rec, port_number_var;
		PERFORM connect_objects(schema_name, id_gis_fiber, id_gis_port);
	END IF;
END;
$$
LANGUAGE plpgsql;

-- Metodo para la desconexión de fibras con splitters en un empalme
CREATE OR REPLACE FUNCTION splice_port_disconnection(
    schema_name TEXT,
	id_gis_cable VARCHAR,
	fiber_number_var INTEGER,
	id_gis_splitter VARCHAR,
	port_number_var INTEGER,
	source BOOLEAN
)RETURNS VOID AS 
$$
DECLARE
	id_gis_fiber VARCHAR;
	id_gis_port VARCHAR;
    splitter_rec RECORD;
	cont INTEGER;
BEGIN
    EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 AND fiber_number = $2', schema_name) INTO id_gis_fiber USING id_gis_cable, fiber_number_var;
    EXECUTE format('SELECT * FROM %I.optical_splitter WHERE id_gis = $1', schema_name) INTO splitter_rec USING id_gis_splitter;
	IF source
	THEN
		EXECUTE format('SELECT * FROM %I.out_port WHERE ST_DWithin(geom, $1) AND fiber_number = $2', schema_name) INTO id_gis_port USING splitter_rec, port_number_var;
		PERFORM disconnect_objects(schema_name, id_gis_fiber, id_gis_port);
	ELSE
		EXECUTE format('SELECT * FROM %I.in_port WHERE ST_DWithin(geom, $1) AND fiber_number = $2', schema_name) INTO id_gis_port USING splitter_rec, port_number_var;
		PERFORM disconnect_objects(schema_name, id_gis_fiber, id_gis_port);
	END IF;
END;
$$
LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION store_cb_connections(schema_name TEXT, cb_record RECORD) RETURNS void AS
$$
DECLARE
    current_cable_record RECORD;
    current_splice_record RECORD;
    current_fiber_node RECORD;
    current_input_fiber RECORD;
    current_output_fiber RECORD;
    current_building_record RECORD;
BEGIN
    -- Crear tablas temporales si no existen
    CREATE TEMP TABLE IF NOT EXISTS cable_connectivity (
        id_gis_cable VARCHAR,
        id_gis_splice VARCHAR
    ) ON COMMIT DROP;

    CREATE TEMP TABLE IF NOT EXISTS fiber_connectivity (
        id_gis_fiber_1 VARCHAR,
        id_gis_fiber_2 VARCHAR
    ) ON COMMIT DROP;

    CREATE TEMP TABLE IF NOT EXISTS fiber_port_connectivity (
        id_gis_fiber_1 VARCHAR,
        id_gis_port VARCHAR
    ) ON COMMIT DROP;

    -- Obtener cables conectados a la caja de conectividad
    FOR current_cable_record IN EXECUTE format('SELECT * FROM %I.fo_cable WHERE ST_DWithin(layout_geom, $1, 0.00003)', schema_name) USING cb_record.layout_geom
    LOOP
        -- Obtener edificios y empalmes cercanos al cable
        PERFORM process_buildings(schema_name, current_cable_record);
        PERFORM process_splices(schema_name, current_cable_record);
		PERFORM process_racks(schema_name, current_cable_record);
		PERFORM process_clients(schema_name, current_cable_record);
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION store_building_connections(schema_name TEXT, building_record RECORD) RETURNS void AS
$$
DECLARE
	current_cable_record RECORD;
BEGIN
	-- Crear tablas temporales si no existen
	CREATE TEMP TABLE IF NOT EXISTS cable_connectivity (
		id_gis_cable VARCHAR,
		id_gis_splice VARCHAR
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS fiber_connectivity (
		id_gis_fiber_1 VARCHAR,
		id_gis_fiber_2 VARCHAR
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS fiber_port_connectivity (
		id_gis_fiber_1 VARCHAR,
		id_gis_port VARCHAR
	) ON COMMIT DROP;

	FOR current_cable_record IN 
        EXECUTE format('SELECT * FROM %I.fo_cable WHERE ST_DWithin(geom, $1, 0.00003)
            AND NOT (ST_Intersects(ST_EndPoint(geom), $1) AND ST_Intersects(ST_StartPoint(geom), $1))', schema_name) 
        USING building_record.layout_geom
    LOOP
        -- Obtener edificios y empalmes cercanos al cable
        PERFORM process_buildings(schema_name, current_cable_record);
        PERFORM process_splices(schema_name, current_cable_record);
		PERFORM process_racks(schema_name, current_cable_record);
		PERFORM process_clients(schema_name, current_cable_record);
    END LOOP;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_buildings(schema_name TEXT, current_cable_record RECORD) RETURNS void AS
$$
DECLARE
    current_building_record RECORD;
    current_fiber_node RECORD;
    current_input_fiber RECORD;
    current_output_fiber RECORD;
BEGIN
    
    FOR current_building_record IN EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_DWithin(layout_geom, $1, 0.00003)', schema_name) USING current_cable_record.layout_geom
    LOOP
        FOR current_fiber_node IN EXECUTE format('SELECT * FROM %I.fo_fiber_vertices_pgr WHERE ST_Contains($1, the_geom) 
            AND NOT ST_DWithin(the_geom, ST_Boundary($1), 1e-9)', schema_name) USING current_building_record.layout_geom
        LOOP
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE target = $1 LIMIT 1', schema_name) INTO current_input_fiber USING current_fiber_node.id;
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE source = $1 LIMIT 1', schema_name) INTO current_output_fiber USING current_fiber_node.id;

            IF FOUND THEN
                PERFORM process_connections(
                    current_fiber_node.the_geom,
                    current_input_fiber.id_gis,
                    current_output_fiber.id_gis,
                    current_input_fiber.id_cable
                );
            END IF;
        END LOOP;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_splices(schema_name TEXT, current_cable_record RECORD) RETURNS void AS
$$
DECLARE
    current_splice_record RECORD;
    current_fiber_node RECORD;
    current_input_fiber RECORD;
    current_output_fiber RECORD;
BEGIN
    FOR current_splice_record IN EXECUTE format('SELECT * FROM %I.fo_splice WHERE ST_DWithin(layout_geom, $1, 0.00003)', schema_name) USING current_cable_record.layout_geom
    LOOP
        FOR current_fiber_node IN EXECUTE format('SELECT * FROM %I.fo_fiber_vertices_pgr WHERE ST_Contains($1, the_geom) 
            AND NOT ST_DWithin(the_geom, ST_Boundary($1), 1e-9)', schema_name) USING current_splice_record.layout_geom
        LOOP
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE target = $1 LIMIT 1', schema_name) INTO current_input_fiber USING current_fiber_node.id;
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE source = $1 LIMIT 1', schema_name) INTO current_output_fiber USING current_fiber_node.id;

            IF FOUND THEN
                PERFORM process_connections(
                    current_fiber_node.the_geom,
                    current_input_fiber.id_gis,
                    current_output_fiber.id_gis,
                    current_input_fiber.id_cable
                );
            END IF;
        END LOOP;

        -- Conexiones de cable con empalme
        IF ST_DWithin(current_splice_record.layout_geom, current_cable_record.layout_geom, 0.0003) THEN
            INSERT INTO cable_connectivity(id_gis_cable, id_gis_splice)
                VALUES (current_cable_record.id_gis, current_splice_record.id_gis);
        END IF;

        -- Actualizar fibras intersectadas
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL 
            WHERE ST_Intersects(layout_geom, $1)', schema_name) USING current_splice_record.layout_geom;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_clients(schema_name TEXT, current_cable_record RECORD) RETURNS void AS
$$
DECLARE
    current_client_record RECORD;
    current_fiber_node RECORD;
    current_input_fiber RECORD;
    current_output_fiber RECORD;
BEGIN
    FOR current_client_record IN EXECUTE format('SELECT * FROM %I.cw_client WHERE ST_DWithin(layout_geom, $1, 0.00003)', schema_name) USING current_cable_record.layout_geom
    LOOP
        FOR current_fiber_node IN EXECUTE format('SELECT * FROM %I.fo_fiber_vertices_pgr WHERE ST_Contains($1, the_geom) 
            AND NOT ST_DWithin(the_geom, ST_Boundary($1), 1e-9)', schema_name) USING current_client_record.layout_geom
        LOOP
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE target = $1 LIMIT 1', schema_name) INTO current_input_fiber USING current_fiber_node.id;
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE source = $1 LIMIT 1', schema_name) INTO current_output_fiber USING current_fiber_node.id;

            IF FOUND THEN
                PERFORM process_connections(
                    current_fiber_node.the_geom,
                    current_input_fiber.id_gis,
                    current_output_fiber.id_gis,
                    current_input_fiber.id_cable
                );
            END IF;
        END LOOP;

        -- Conexiones de cable con empalme
        IF ST_DWithin(current_client_record.layout_geom, current_cable_record.layout_geom, 0.0003) THEN
            INSERT INTO cable_connectivity(id_gis_cable, id_gis_splice)
            VALUES (current_cable_record.id_gis, current_client_record.id_gis);
        END IF;

        -- Actualizar fibras intersectadas
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL 
            WHERE ST_Intersects(layout_geom, $1)', schema_name) USING current_client_record.layout_geom;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_racks(schema_name TEXT, current_cable_record RECORD) RETURNS void AS
$$
DECLARE
    current_rack_record RECORD;
    current_fiber_node RECORD;
    current_input_fiber RECORD;
    current_output_fiber RECORD;
BEGIN
    FOR current_rack_record IN EXECUTE format('SELECT * FROM %I.cw_client WHERE ST_DWithin(layout_geom, $1, 0.00003)', schema_name) USING current_cable_record.layout_geom
    LOOP
        FOR current_fiber_node IN EXECUTE format('SELECT * FROM %I.fo_fiber_vertices_pgr WHERE ST_Contains($1, the_geom) 
            AND NOT ST_DWithin(the_geom, ST_Boundary($1), 1e-9)', schema_name) USING current_rack_record.layout_geom
        LOOP
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE target = $1 LIMIT 1', schema_name) INTO current_input_fiber USING current_fiber_node.id;
            EXECUTE format('SELECT * FROM %I.fo_fiber WHERE source = $1 LIMIT 1', schema_name) INTO current_output_fiber USING current_fiber_node.id;

            IF FOUND THEN
                PERFORM process_connections(
                    current_fiber_node.the_geom,
                    current_input_fiber.id_gis,
                    current_output_fiber.id_gis,
                    current_input_fiber.id_cable
                );
            END IF;
        END LOOP;

        -- Conexiones de cable con rack
        IF ST_DWithin(current_rack_record.layout_geom, current_cable_record.layout_geom, 0.0003) THEN
            INSERT INTO cable_connectivity(id_gis_cable, id_gis_splice)
            VALUES (current_cable_record.id_gis, current_rack_record.id_gis);
        END IF;

        -- Actualizar fibras intersectadas
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source = NULL, target = NULL 
            WHERE ST_Intersects(layout_geom, $1)', schema_name) USING current_rack_record.layout_geom;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_connections(
    fiber_node_geom geometry,
    input_fiber_gis VARCHAR,
    output_fiber_gis VARCHAR,
    input_fiber_cable VARCHAR
) RETURNS void AS
$$
BEGIN
    IF (SELECT COUNT(*) FROM gis.cw_client WHERE ST_DWithin(geom, fiber_node_geom, 0.000003)) > 0 THEN
        IF NOT EXISTS (SELECT 1 FROM cable_connectivity WHERE id_gis_cable = input_fiber_cable) THEN
            INSERT INTO cable_connectivity(id_gis_cable, id_gis_splice) 
            VALUES (
                input_fiber_cable, 
                (SELECT id_gis FROM gis.cw_client WHERE ST_DWithin(geom, fiber_node_geom, 0.000003) LIMIT 1)
            );
        END IF;
    ELSIF (SELECT COUNT(*) FROM gis.rack WHERE ST_DWithin(layout_geom, fiber_node_geom, 0.000003)) > 0 THEN
        IF NOT EXISTS (SELECT 1 FROM cable_connectivity WHERE id_gis_cable = input_fiber_cable) THEN
            INSERT INTO cable_connectivity(id_gis_cable, id_gis_splice) 
            VALUES (
                input_fiber_cable, 
                (SELECT id_gis FROM gis.rack WHERE ST_DWithin(layout_geom, fiber_node_geom, 0.000003) LIMIT 1)
            );
        END IF;
    ELSIF (SELECT COUNT(*) FROM gis.optical_network_terminal WHERE ST_DWithin(geom, fiber_node_geom, 0.000003)) > 0 THEN
        IF NOT EXISTS (SELECT 1 FROM fiber_port_connectivity WHERE id_gis_fiber_1 = input_fiber_gis) THEN
            INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port) 
            VALUES (
                input_fiber_gis, 
                (SELECT id_gis FROM gis.optical_network_terminal WHERE ST_DWithin(geom, fiber_node_geom, 0.000003) LIMIT 1)
            );
        END IF;
    ELSIF (SELECT COUNT(*) FROM gis.port WHERE ST_DWithin(geom, fiber_node_geom, 0.000003)) > 0 THEN
        IF NOT EXISTS (SELECT 1 FROM fiber_port_connectivity WHERE id_gis_fiber_1 = input_fiber_gis) THEN
            INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port) 
            VALUES (
                input_fiber_gis, 
                (SELECT id_gis FROM gis.port WHERE ST_DWithin(geom, fiber_node_geom, 0.000003) LIMIT 1)
            );
        ELSIF NOT EXISTS (SELECT 1 FROM fiber_port_connectivity WHERE id_gis_fiber_1 = output_fiber_gis) THEN
            INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port) 
            VALUES (
                output_fiber_gis, 
                (SELECT id_gis FROM gis.port WHERE ST_DWithin(geom, fiber_node_geom, 0.000003) LIMIT 1)
            );
        END IF;
	ELSIF (SELECT COUNT(*) FROM gis.in_port WHERE ST_DWithin(geom, fiber_node_geom, 0.000003)) > 0 THEN
        IF NOT EXISTS (SELECT 1 FROM fiber_port_connectivity WHERE id_gis_fiber_1 = input_fiber_gis) THEN
            INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port) 
            VALUES (
                input_fiber_gis, 
                (SELECT id_gis FROM gis.in_port WHERE ST_DWithin(geom, fiber_node_geom, 0.000003) LIMIT 1)
            );
		END IF;
	ELSIF (SELECT COUNT(*) FROM gis.out_port WHERE ST_DWithin(geom, fiber_node_geom, 0.000003)) > 0 THEN
        IF NOT EXISTS (SELECT 1 FROM fiber_port_connectivity WHERE id_gis_fiber_1 = output_fiber_gis) THEN
            INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port) 
            VALUES (
                output_fiber_gis, 
                (SELECT id_gis FROM gis.out_port WHERE ST_DWithin(geom, fiber_node_geom, 0.000003) LIMIT 1)
            );
		END IF;
    ELSE
        IF NOT EXISTS (SELECT 1 FROM fiber_connectivity WHERE id_gis_fiber_1 = output_fiber_gis)
           AND NOT EXISTS (SELECT 1 FROM fiber_connectivity WHERE id_gis_fiber_2 = input_fiber_gis) THEN
            INSERT INTO fiber_connectivity(id_gis_fiber_1, id_gis_fiber_2) 
            VALUES (
                output_fiber_gis,
                input_fiber_gis
            );
        END IF;
    END IF;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


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


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

-- Funcion para procesar la informaciónd e conectividad almacenada
CREATE OR REPLACE FUNCTION update_stored_conections(schema_name TEXT) RETURNS void AS
	$$
	DECLARE
		current_aux_record RECORD;
	BEGIN
		-- Se regeneran los cables
        FOR current_aux_record IN SELECT * FROM cable_connectivity
        LOOP
			If current_aux_record.id_gis_cable IS NULL OR current_aux_record.id_gis_splice IS NULL THEN CONTINUE; END IF;
        	PERFORM connect_objects(schema_name, current_aux_record.id_gis_cable, current_aux_record.id_gis_splice);
        END LOOP;

		FOR current_aux_record IN SELECT * FROM fiber_connectivity
        LOOP
			If current_aux_record.id_gis_fiber_1 IS NULL OR current_aux_record.id_gis_fiber_2 IS NULL THEN CONTINUE; END IF;
            PERFORM connect_objects(schema_name, current_aux_record.id_gis_fiber_1, current_aux_record.id_gis_fiber_2);
        END LOOP;

		FOR current_aux_record IN SELECT * FROM fiber_port_connectivity
        LOOP
			If current_aux_record.id_gis_fiber_1 IS NULL OR current_aux_record.id_gis_port IS NULL THEN CONTINUE; END IF;
            PERFORM connect_objects(schema_name, current_aux_record.id_gis_fiber_1, current_aux_record.id_gis_port);
        END LOOP;
	END;
	$$
LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- INSERT DE EMPALMES DEN EDIFICIOS

CREATE OR REPLACE FUNCTION insert_fo_splice_on_building(
    schema_name TEXT, 
    id_gis_building VARCHAR,
    n_floor INTEGER,
    edited_by UUID
) RETURNS VOID AS
$$
DECLARE
    building_record RECORD;
    guitar_splices_line GEOMETRY;
    guitar_splices_line_points GEOMETRY;
    splice_geometry GEOMETRY;
BEGIN
    -- Obtener el registro del edificio usando el esquema proporcionado
    EXECUTE format('
        SELECT * 
        FROM %I.cw_building
        WHERE id_gis = $1', schema_name)
    INTO building_record
    USING id_gis_building;
    
    IF n_floor IS NOT NULL THEN
        IF n_floor <= building_record.n_floors THEN
            guitar_splices_line := ST_OffsetCurve(ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2] = 1),
                (SELECT geom FROM ST_DumpPoints(building_record.layout_geom) WHERE path[2] = 2)
            ), -0.2, 'quad_segs=4 join=mitre mitre_limit=2.2');

            guitar_splices_line_points := ST_LineInterpolatePoints(guitar_splices_line, (1::FLOAT / (building_record.n_floors + 1)::FLOAT), true);

            splice_geometry := ST_GeometryN(guitar_splices_line_points, (building_record.n_floors + 1) - n_floor);

            -- Insertar el empalme en la tabla correspondiente al esquema proporcionado
            EXECUTE format('
                INSERT INTO %I.fo_splice(geom, edited_by)
                VALUES ($1, $2)', schema_name)
            USING splice_geometry, edited_by;
        END IF;
    ELSE
        -- Manejo del caso cuando n_floor es NULL
        -- Aquí puedes agregar cualquier lógica adicional necesaria para manejar el caso cuando n_floor es NULL
    END IF;
END;
$$
LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_client_on_floor(
    schema_name TEXT, 
    id_gis_floor VARCHAR,
    edited_by UUID
) RETURNS VOID AS
$$
DECLARE
    current_floor RECORD;
    current_building RECORD;
    aux_line_1 GEOMETRY;
    aux_line_2 GEOMETRY;
    central_line_clients GEOMETRY;
    central_clients_line_points GEOMETRY;
    clients_distance FLOAT;
    floor_width FLOAT := 6;
    floor_height FLOAT := 0.6;
    pos INTEGER;
    client_count INTEGER;
BEGIN 
    -- Obtener la información del piso usando el esquema proporcionado
    EXECUTE format('
        SELECT * 
        FROM %I.cw_floor 
        WHERE id_gis = $1', schema_name)
    INTO current_floor
    USING id_gis_floor;

    -- Obtener la información del edificio usando el esquema proporcionado
    EXECUTE format('
        SELECT * 
        FROM %I.cw_building 
        WHERE ST_Intersects(layout_geom, $1)', schema_name)
    INTO current_building
    USING current_floor.geom;

    aux_line_1 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(current_floor.layout_geom) WHERE path[2] = 3),
        (SELECT geom FROM ST_DumpPoints(current_floor.layout_geom) WHERE path[2] = 4)
    );
    
    aux_line_2 := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(current_floor.layout_geom) WHERE path[2] = 1),
        (SELECT geom FROM ST_DumpPoints(current_floor.layout_geom) WHERE path[2] = 2)
    );

    central_line_clients := ST_MakeLine(
        ST_Centroid(aux_line_1), 
        ST_Centroid(aux_line_2)
    );

    central_clients_line_points := (SELECT ST_LineInterpolatePoints(central_line_clients, (1::FLOAT / (20+1)::FLOAT), true));
    clients_distance := ST_Distance(ST_GeometryN(central_clients_line_points, 1), ST_GeometryN(central_clients_line_points, 2));    

    FOR e IN 1..(ST_NumGeometries(central_clients_line_points))
    LOOP
        pos := (ST_NumGeometries(central_clients_line_points)) - e;

        -- Guardar el count(*) en una variable utilizando EXECUTE
        EXECUTE format('
            SELECT count(*)
            FROM %I.cw_client
            WHERE ST_Intersects(layout_geom, $1)', schema_name)
        INTO client_count
        USING ST_GeometryN(central_clients_line_points, pos);

        IF client_count = 0 THEN
            EXECUTE format('
                INSERT INTO %I.cw_client(geom, layout_geom, edited_by)
                VALUES (
                    $1,
                    ST_Rotate(
                        ST_MakeEnvelope(
                            ST_X($1) - $2 / 2 + 0.03, 
                            ST_Y($1) - $3 + 0.36,
                            ST_X($1) + $2 / 2 - 0.03,  
                            ST_Y($1) + $3,   
                            ST_SRID($1)
                        ),
                        $4,
                        $1
                    ),
                    $5
                )', schema_name)
            USING ST_GeometryN(central_clients_line_points, pos), clients_distance, floor_height, current_building.rotate_rads, edited_by;
            EXIT;
        END IF;
    END LOOP;

END;
$$
LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_ont_on_client(schema_name TEXT, id_gis_client VARCHAR, edited_by UUID) RETURNS VOID AS 
$$
DECLARE
    ont_count INTEGER;
BEGIN
    -- Contar el número de registros en optical_network_terminal que intersectan con la geometría del cliente
    EXECUTE format('
        SELECT count(*)
        FROM %I.optical_network_terminal
        WHERE ST_Intersects(geom, (SELECT layout_geom FROM %I.cw_client WHERE id_gis = $1))',
        schema_name, schema_name)
    INTO ont_count
    USING id_gis_client;

    -- Insertar un nuevo registro si el conteo es menor que 10
    IF ont_count < 10 THEN
        EXECUTE format('
            INSERT INTO %I.optical_network_terminal(geom, edited_by)
            VALUES ((SELECT geom FROM %I.cw_client WHERE id_gis = $1), %L)',
            schema_name, schema_name, edited_by)
        USING id_gis_client;
    END IF;
END;
$$
LANGUAGE plpgsql;


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--  FUnción para la inserción de rackas enc lientes o habitaciones
CREATE OR REPLACE FUNCTION insert_rack(schema_name TEXT, id_gis_location VARCHAR, rack_spec VARCHAR, edited_by_var UUID) RETURNS VOID AS 
	$$
	DECLARE
		location_record RECORD;
		building_record RECORD;
		aux_rack_line GEOMETRY;
		rack_line_points GEOMETRY;
		pos INTEGER;
        n_racks INTEGER;
		height FLOAT := 0.054;
		width FLOAT := 0.03;
		inserted BOOLEAN := false;
	BEGIN
        EXECUTE format('SELECT * FROM %I.cw_client WHERE id_gis = $1', schema_name) INTO location_record USING id_gis_location;
        EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO building_record USING location_record.geom;

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

                EXECUTE format('SELECT count(*) FROM %I.rack WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO n_racks USING ST_GeometryN(rack_line_points, pos);
				
				IF n_racks < 1
				THEN
                    EXECUTE format('INSERT INTO %I.rack(specification, geom, layout_geom, edited_by) VALUES($1, $2, $3, $4)', schema_name) 
                    USING 
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
                        ),
                        edited_by_var;
                    inserted := true;
                    EXIT;
				END IF;
			END LOOP;
		END LOOP;
	END;
	$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_shelf_on_rack(
    schema_name TEXT,
    id_gis_rack VARCHAR,
    shelf_spec VARCHAR,
    edited_by_var UUID
) RETURNS VOID AS 
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
    shelf_count INTEGER;
    card_count INTEGER;
    shelf_dist_count INTEGER;
    card_dist_count INTEGER;
    shelf_dist_count_result INTEGER;
    card_dist_count_result INTEGER;
BEGIN
    ok := true;
    sum_height := 0;
    shelf_layout_width := 0.024;
    pos_aux := 0;  -- Inicializar pos_aux

    -- Obtener información del rack y del edificio
    EXECUTE format('SELECT * FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_record USING id_gis_rack;
    EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO building_record USING rack_record.layout_geom;
    
    FOR current_shelf IN EXECUTE format('SELECT * FROM %I.shelf WHERE ST_Intersects(layout_geom, $1)', schema_name) USING rack_record.layout_geom LOOP
        sum_height := sum_height + (SELECT height FROM template.shelf_specs WHERE model = current_shelf.specification);
    END LOOP;

    FOR current_card IN EXECUTE format('SELECT * FROM %I.card WHERE ST_Intersects(layout_geom, $1)', schema_name) USING rack_record.layout_geom LOOP
        sum_height := sum_height + current_card.height;
    END LOOP;

    -- Verificar si hay espacio suficiente en el rack para insertar el estante
    IF (SELECT width FROM template.rack_specs WHERE model = rack_record.specification) <= (SELECT width FROM template.shelf_specs WHERE model = shelf_spec)
        OR (SELECT height FROM template.rack_specs WHERE model = rack_record.specification) <= (sum_height + (SELECT height FROM template.shelf_specs WHERE model = shelf_spec))
        OR (SELECT depth FROM template.rack_specs WHERE model = rack_record.specification) <= (SELECT depth FROM template.shelf_specs WHERE model = shelf_spec)
    THEN 
        ok := false;
    END IF;

    IF ok THEN
        -- Obtener las caras del rack
        EXECUTE format('SELECT ARRAY[
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
                ] FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_faces_array USING id_gis_rack;

        -- Encontrar las caras más cortas del rack
        min_length := NULL;
        FOR e IN 1..(array_length(rack_faces_array,1) - 2) LOOP
            IF min_length IS NULL OR ST_Length(rack_faces_array[e]) < min_length THEN
                min_length := ST_Length(rack_faces_array[e]);
                aux_face_rack_1 := rack_faces_array[e];
                aux_face_rack_2 := rack_faces_array[e + 2];
            END IF;
        END LOOP;    

        -- Crear la línea central del rack desplazada
        central_rack_line := ST_MakeLine(ST_Centroid(aux_face_rack_1), ST_Centroid(aux_face_rack_2));
        central_rack_line := ST_OffsetCurve(central_rack_line, 0.004, 'quad_segs=4 join=mitre mitre_limit=2.2');
        central_rack_line_points := ST_LineInterpolatePoints(central_rack_line, (1/(((SELECT height FROM template.rack_specs WHERE model = rack_record.specification) * 100) + 10.0)), true);
RAISE NOTICE 'central_rack_line_points %', central_rack_line_points;
        -- Verificar que central_rack_line_points no sea NULL
        IF central_rack_line_points IS NOT NULL THEN
            -- Insertar el estante en la posición adecuada
            FOR e IN 1..(ST_NumGeometries(central_rack_line_points)) LOOP    
                pos_aux := (ST_NumGeometries(central_rack_line_points)) - e;
                EXECUTE format('SELECT COUNT(*) FROM %I.shelf WHERE ST_Distance(layout_geom, $1) < 0.0003', schema_name) INTO shelf_count USING ST_GeometryN(central_rack_line_points, pos_aux);
                EXECUTE format('SELECT COUNT(*) FROM %I.card WHERE ST_Distance(layout_geom, $1) < 0.0003', schema_name) INTO card_count USING ST_GeometryN(central_rack_line_points, pos_aux);
                IF shelf_count = 0 AND card_count = 0
                THEN     
                    IF pos_aux < (ST_NumGeometries(central_rack_line_points) - 1) THEN
                        pos_aux := pos_aux + 1;
                    END IF;

                    pos := pos_aux - (CEIL((SELECT height FROM template.shelf_specs WHERE model = shelf_spec) * 100)/2)::INTEGER;

                    shelf_layout_height := ST_Distance(ST_GeometryN(central_rack_line_points, pos_aux), ST_GeometryN(central_rack_line_points, pos));
                    EXECUTE format('INSERT INTO %I.shelf(geom, specification, layout_geom, edited_by)
                        VALUES (
                            $1,
                            $2,
                            ST_Rotate(
                                ST_MakeEnvelope(
                                    ST_X($3) - $4,
                                    ST_Y($3) - $5,
                                    ST_X($3) + $4,
                                    ST_Y($3) + $5,
                                    $6
                                ),
                                $7,
                                $8
                            ),
                            $9
                        )', schema_name)
                    USING
                        ST_GeometryN(central_rack_line_points, pos),
                        shelf_spec,
                        ST_GeometryN(central_rack_line_points, pos),
                        shelf_layout_width,
                        shelf_layout_height,
                        ST_SRID(ST_GeometryN(central_rack_line_points, pos)),
                        building_record.rotate_rads,
                        ST_GeometryN(central_rack_line_points, pos),
                        edited_by_var;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    END IF;
END;
$$
LANGUAGE plpgsql;


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_card_on_shelf(
    schema_name TEXT,
    id_gis_shelf VARCHAR,
    card_spec VARCHAR,
    n_rows INTEGER,
    n_cols INTEGER,
    edited_by_var UUID
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
    card_count INTEGER;
BEGIN
    EXECUTE format('SELECT * FROM %I.shelf WHERE id_gis = $1', schema_name) INTO shelf_record USING id_gis_shelf;
    EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO building_record USING shelf_record.layout_geom;

    FOR current_card IN EXECUTE format('SELECT * FROM %I.card WHERE ST_Contains(layout_geom, $1)', schema_name) USING shelf_record.layout_geom LOOP
        sum_height := sum_height + (SELECT height FROM template.card_specs WHERE model = current_card.specification);
    END LOOP;

    IF (SELECT width FROM template.shelf_specs WHERE model = shelf_record.specification) < (SELECT width FROM template.card_specs WHERE model = card_spec)
        OR (SELECT height FROM template.shelf_specs WHERE model = shelf_record.specification) < (sum_height + (SELECT height FROM template.card_specs WHERE model = card_spec))
        OR (SELECT depth FROM template.shelf_specs WHERE model = shelf_record.specification) < (SELECT depth FROM template.card_specs WHERE model = card_spec)
    THEN
        ok := false;
    END IF;

    IF ok THEN
        EXECUTE format('SELECT ARRAY[
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)
                ),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)
                ),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)
                ),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4),
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5)
                )
            ] FROM %I.shelf WHERE id_gis = $1', schema_name) INTO shelf_faces_array USING id_gis_shelf;

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

            EXECUTE format('SELECT count(*) FROM %I.card WHERE ST_Distance(layout_geom, ST_GeometryN($1, $2)) < 0.0003', schema_name) INTO card_count USING central_shelf_line_points, pos_aux;

            IF card_count = 0 THEN
                IF pos_aux < (ST_NumGeometries(central_shelf_line_points)) - 1 THEN
                    pos_aux := pos_aux + 1;
                END IF;

                pos := (pos_aux - (CEIL((SELECT height FROM template.card_specs WHERE model = card_spec) * 100 )/ 2))::INTEGER;
                card_layout_height := ST_Distance(ST_GeometryN(central_shelf_line_points, pos_aux), ST_GeometryN(central_shelf_line_points, pos));

                EXECUTE format('INSERT INTO %I.card(geom, specification, layout_geom, edited_by)
                    VALUES (
                        $1,
                        $2,
                        ST_Rotate(
                            ST_MakeEnvelope(
                                ST_X($3) - 0.022,
                                ST_Y($3) - $4,
                                ST_X($3) + 0.022,
                                ST_Y($3) + $4,
                                $5
                            ),
                            $6,
                            $3
                        ),
                        $7
                    ) RETURNING id_auto', schema_name)
                INTO id_card_inserted
                USING
                    ST_GeometryN(central_shelf_line_points, pos),
                    card_spec,
                    ST_GeometryN(central_shelf_line_points, pos),
                    card_layout_height,
                    ST_SRID(ST_GeometryN(central_shelf_line_points, pos)),
                    building_record.rotate_rads,
                    edited_by_var;

                PERFORM create_card_ports(schema_name, CONCAT('card_', id_card_inserted::TEXT), n_rows, n_cols, edited_by_var);
                EXIT;
            END IF;
        END LOOP;
    END IF;
END;
$$ 
LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION insert_card_on_rack(
    schema_name TEXT,
    id_gis_rack VARCHAR,
    card_spec VARCHAR,
    n_rows INTEGER,
    n_cols INTEGER,
    edited_by_var UUID
) RETURNS VOID AS 
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
    card_layout_height FLOAT;
    pos INTEGER;
    pos_aux INTEGER;
    ok BOOLEAN;
    id_card_inserted INTEGER;
    shelf_count INTEGER;
    shelf_count_aux INTEGER;
    card_count INTEGER;
BEGIN
    ok := true;
    sum_height := 0;
    min_length := NULL;

    EXECUTE format('SELECT * FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_record USING id_gis_rack;
    EXECUTE format('SELECT * FROM %I.cw_building WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO building_record USING rack_record.layout_geom;
RAISE NOTICE 'rack_record %', rack_record;
RAISE NOTICE 'building_record %', building_record;
    FOR current_shelf IN EXECUTE format('SELECT * FROM %I.shelf WHERE ST_Intersects(layout_geom, $1)', schema_name) USING rack_record.layout_geom LOOP
        sum_height := sum_height + (SELECT height FROM template.shelf_specs WHERE model = current_shelf.specification);
    END LOOP;
RAISE NOTICE 'sum_height %', sum_height;
    FOR current_card IN EXECUTE format('SELECT * FROM %I.card WHERE ST_Intersects(layout_geom, $1)', schema_name) USING rack_record.layout_geom LOOP
        EXECUTE format('SELECT count(*) FROM %I.shelf WHERE ST_Intersects(layout_geom, $1)', schema_name) INTO shelf_count_aux USING current_card.layout_geom;
        IF shelf_count_aux = 0
        THEN
            sum_height := sum_height + (SELECT height FROM template.card_specs WHERE model = current_card.specification);
        END IF;
    END LOOP;
RAISE NOTICE 'sum_height %',sum_height ;
    IF (SELECT width FROM template.rack_specs WHERE model = rack_record.specification) < (SELECT width FROM template.card_specs WHERE model = card_spec)
        OR (SELECT height FROM template.rack_specs WHERE model = rack_record.specification) < (sum_height + (SELECT height FROM template.card_specs WHERE model = card_spec))
        OR (SELECT depth FROM template.rack_specs WHERE model = rack_record.specification) < (SELECT depth FROM template.card_specs WHERE model = card_spec)
    THEN 
        ok := false;
    END IF;
RAISE NOTICE 'ok %', ok;
    IF ok THEN
        EXECUTE format('SELECT ARRAY[
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
                ST_MakeLine(
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                    (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
            ] FROM %I.rack WHERE id_gis = $1', schema_name) INTO rack_faces_array USING id_gis_rack;

        FOR e IN 1..(array_length(rack_faces_array, 1) - 2)
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

        EXECUTE format('SELECT ST_LineInterpolatePoints(
                $1,
                (1/(((SELECT height FROM template.rack_specs WHERE model = $2) * 100) + 10.0)),
                true
            )')
        INTO central_rack_line_points
        USING central_rack_line, rack_record.specification;
RAISE NOTICE 'central_rack_line_points %', central_rack_line_points;
        FOR e IN 1..(ST_NumGeometries(central_rack_line_points))
        LOOP    
            pos_aux := (ST_NumGeometries(central_rack_line_points)) - e;

            EXECUTE format('SELECT COUNT(*) FROM %I.shelf WHERE ST_Distance(layout_geom, ST_GeometryN($1, $2)) < 0.003', schema_name) INTO shelf_count USING central_rack_line_points, pos_aux;
            EXECUTE format('SELECT COUNT(*) FROM %I.card WHERE ST_Distance(layout_geom, ST_GeometryN($1, $2)) < 0.003', schema_name) INTO card_count USING central_rack_line_points, pos_aux;

            IF shelf_count = 0 AND card_count = 0 
            THEN 
                IF pos_aux < (ST_NumGeometries(central_rack_line_points)) - 1
                THEN
                    pos_aux := pos_aux + 1;
                END IF;

                pos := pos_aux - (CEIL((SELECT height FROM template.card_specs WHERE model = card_spec) * 100)/2)::INTEGER;
                card_layout_height := ST_Distance(ST_GeometryN(central_rack_line_points, pos_aux), ST_GeometryN(central_rack_line_points, pos));
                EXECUTE format('INSERT INTO %I.card(geom, specification, layout_geom, edited_by)
                    VALUES(
                        $1,
                        $2,
                        ST_Rotate(
                            ST_MakeEnvelope(
                                ST_X($3) - 0.022,  
                                ST_Y($3) - $4,   
                                ST_X($3) + 0.022,  
                                ST_Y($3) + $4,
                                $5
                            ),
                            $6,
                            $7
                        ),
                        $8                      
                    ) RETURNING id_auto', schema_name)
                    INTO id_card_inserted
                USING
                    ST_GeometryN(central_rack_line_points, pos),
                    card_spec,
                    ST_GeometryN(central_rack_line_points, pos),
                    card_layout_height,
                    ST_SRID(ST_GeometryN(central_rack_line_points, pos)),
                    building_record.rotate_rads,
                    ST_GeometryN(central_rack_line_points, pos),
                    edited_by_var;
                PERFORM create_card_ports(schema_name, CONCAT('card_', id_card_inserted::TEXT), n_rows, n_cols, edited_by_var);
                EXIT;
            END IF;
        END LOOP;
    END IF;
END;
$$
LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION create_card_ports(schema_name TEXT, id_gis_card VARCHAR, n_rows INTEGER, n_cols INTEGER, edited_by_var UUID) RETURNS VOID AS 
$$
DECLARE
    card_record RECORD;
    card_faces_array GEOMETRY[];
    aux_short_face_card_1 GEOMETRY;
    aux_short_face_card_2 GEOMETRY;
    aux_long_face_card_1 GEOMETRY;
    aux_long_face_card_2 GEOMETRY;
BEGIN
    EXECUTE format('SELECT * FROM %I.card WHERE id_gis = $1', schema_name) INTO card_record USING id_gis_card;

    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.card WHERE id_gis = $1', schema_name) INTO card_faces_array USING id_gis_card;

    aux_short_face_card_1 := ST_LineInterpolatePoints(card_faces_array[1], (1/(n_rows + 3)::FLOAT), true);
    aux_short_face_card_2 := ST_LineInterpolatePoints(card_faces_array[3], (1/(n_rows + 3)::FLOAT), true);
    aux_long_face_card_1 := ST_LineInterpolatePoints(card_faces_array[2], (1/(n_cols + 3)::FLOAT), true);
    aux_long_face_card_2 := ST_LineInterpolatePoints(card_faces_array[4], (1/(n_cols + 3)::FLOAT), true);

    FOR e IN 2..(n_rows + 1)
    LOOP
        FOR i IN 2..(n_cols + 1)
        LOOP
            EXECUTE format('INSERT INTO %I.port(geom, edited_by)
                VALUES( ST_Intersection(ST_MakeLine($1, $2), ST_MakeLine($3, $4)),
                    $5)', schema_name)
            USING
                ST_GeometryN(aux_short_face_card_1, e),
                ST_GeometryN(aux_short_face_card_2, ST_NumGeometries(aux_short_face_card_1) - e),
                ST_GeometryN(aux_long_face_card_1, i),
                ST_GeometryN(aux_long_face_card_2, ST_NumGeometries(aux_long_face_card_1) - i),
                edited_by_var;
        END LOOP;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------





--CONSULTAS TOP

    select * from objects.cw_sewer_box;

    select * from objects.cw_connectivity_box;

    select * from objects.cw_ground_route;

    select * from objects.cw_duct;

    select * from objects.fo_splice;

    select * from objects.fo_cable;

    select * from objects.fo_fiber;

    select * from objects.cw_skyway;

    select * from objects.cw_pole;

    select * from objects.in_port;

    select * from objects.optical_splitter;

    select * from objects.out_port;

    select * from objects.port;
	
	select * from objects.saved_changes;

--CONSULTAS ALTERNATIVA

    -- select * from alt_6.cw_sewer_box;

    -- select * from alt_6.cw_connectivity_box;

    -- select * from alt_6.cw_ground_route;

    -- select * from alt_6.cw_duct;

    -- select * from alt_6.fo_splice;

    -- select * from alt_6.fo_cable;

    -- select * from alt_6.fo_fiber;

    -- select * from alt_6.cw_skyway;

    -- select * from alt_6.cw_pole;

    -- select * from alt_6.in_port;

    -- select * from alt_6.optical_splitter;

    -- select * from alt_6.out_port;

    -- select * from alt_6.port;
	
	-- select * from alt_6.saved_changes;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


-- CREATE OR REPLACE PROCEDURE update_object(
--     IN schema_name TEXT,
--     IN object_type TEXT, 
--     IN id_gis VARCHAR,
--     IN geom GEOMETRY,
--     IN id_usuario UUID
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     user_exists BOOLEAN;
--     query_text TEXT;  -- Variable para almacenar la consulta de actualización
-- BEGIN
--     -- Verificar si el usuario existe
--     SELECT EXISTS(SELECT 1 FROM security.users WHERE id = id_usuario) INTO user_exists;

--     -- Si el usuario no existe, lanzar un error
--     IF NOT user_exists THEN
--         RAISE EXCEPTION 'El usuario con id % no existe en security.users', id_usuario;
--     END IF;

--     -- Verificar el tipo de objeto y realizar la actualización correspondiente
--     CASE object_type
--         WHEN 'cw_ground_route' THEN
--             query_text := format('
--                 UPDATE %I.%I
--                 SET geom = %L, edited_by = %L
--                 WHERE id_gis = %L', schema_name, object_type, geom, id_usuario, id_gis);
--             EXECUTE query_text;

--         WHEN 'fo_cable' THEN
--             query_text := format('
--                 UPDATE %I.%I
--                 SET geom = %L, edited_by = %L, id_duct = %Lf
--                 WHERE id_gis = %L', schema_name, object_type, geom, id_usuario, id_duct, id_gis);
--             EXECUTE query_text;

--         ELSE
--             query_text := format('
--                 UPDATE %I.%I
--                 SET geom = %L, edited_by = %L
--                 WHERE id_gis = %L', schema_name, object_type, geom, id_usuario, id_gis);
--             EXECUTE query_text;
--     END CASE;

--     -- Imprimir el valor de query_text
--     RAISE NOTICE 'Query ejecutada: %', query_text;

--     -- Fin del procedimiento
-- END;
-- $$;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

-- CALL update_object('objects', 'cw_sewer_box', 'cw_sewer_box_3', 'SRID=3857;POINT(-404304.97 4928712.77)', '5be381ea-aefc-41ea-aa5e-f28fb9193750');

-- CALL update_object('objects', 'cw_pole', 'cw_pole_1', 'SRID=3857;POINT(-404063.28 4929153.11)', '5be381ea-aefc-41ea-aa5e-f28fb9193750');

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_object(json_info jsonb) RETURNS TABLE (
    id UUID,
    id_auto INT,
    change_time TIMESTAMP,
    record_time TIMESTAMP,
    edited_by UUID
) AS
$$
DECLARE
    scheme_name TEXT;
    table_name TEXT;
    field RECORD;
    columnas TEXT := '';
    valores TEXT := '';
    valor TEXT;
    geom_coords TEXT;
    geom_srid INT;
    insert_query TEXT;
    query_merge_value TEXT;
    query_rollback TEXT;
    new_id UUID;
    new_id_auto INT;
    new_edited_by UUID;
BEGIN
    -- Extraer el esquema y nombre de la tabla del JSON
    scheme_name := json_info->>'scheme_name';
    table_name := json_info->>'table_name';
    
    -- Recorrer las claves del objeto 'fields'
    FOR field IN SELECT * FROM jsonb_each(json_info->'fields')
    LOOP
        -- Concatenar nombres de columnas
        columnas := columnas || quote_ident(field.key) || ', ';
        
        -- Determinar el valor apropiado para la columna
        IF field.key = 'geom' THEN
            geom_coords := field.value->>'coords';
            geom_srid := (field.value->>'srid')::INT;
            valor := 'ST_GeomFromText(' || quote_literal(geom_coords) || ', ' || geom_srid || ')';
        ELSE
            valor := quote_literal(field.value->>0);
        END IF;
        
        -- Concatenar valores
        valores := valores || valor || ', ';
    END LOOP;
    
    -- Eliminar la última coma y espacio
    columnas := rtrim(columnas, ', ');
    valores := rtrim(valores, ', ');
    
    -- Construir la consulta de inserción dinámica con RETURNING
    insert_query := FORMAT(
        'INSERT INTO %I.%I (%s) VALUES (%s) RETURNING id, id_auto, CURRENT_TIMESTAMP AS change_time, CURRENT_TIMESTAMP AS record_time, edited_by',
        scheme_name, table_name, columnas, valores
    );

    -- Ejecutar la consulta de inserción dinámica y obtener los valores del RETURNING
    EXECUTE insert_query INTO new_id, new_id_auto, change_time, record_time, new_edited_by;
    
    -- Construir el query_merge como una llamada al mismo procedimiento insert_object
    query_merge_value := FORMAT(
        'SELECT insert_object(''{"scheme_name": "%s", "table_name": "%s", "fields": {"%s"}}'')',
        scheme_name, table_name, replace(columnas || ': ' || valores, ', ', '", "')
    );
    
    -- Construir el query_rollback como una llamada a delete_object
    query_rollback := FORMAT(
        'SELECT delete_object(''{"scheme_name": "%s", "table_name": "%s", "conditions": {"id": "%s", "id_auto": "%s"}}'')',
        scheme_name, table_name, new_id::TEXT, new_id_auto::TEXT
    );

    -- Inserción en saved_changes para cw_sewer_box usando los valores obtenidos del RETURNING
    EXECUTE format(
        'INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge, query_rollback) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, %L, %L)',
        scheme_name, query_merge_value, query_rollback
    ) USING new_id, CONCAT( table_name, '_', new_id_auto::TEXT), new_edited_by;
    
    -- Mostrar la consulta ejecutada
    RAISE NOTICE 'Executed Query: %', insert_query;

    -- Retornar los valores obtenidos
    RETURN QUERY SELECT new_id, new_id_auto, change_time, record_time, new_edited_by;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_object(json_info jsonb) RETURNS VOID AS
$$
DECLARE
    scheme_name TEXT;
    table_name TEXT;
    field RECORD;
    columnas TEXT := '';
    valores TEXT := '';
    valor TEXT;
    geom_coords TEXT;
    geom_srid INT;
    id_gis VARCHAR;
    where_clause VARCHAR;
    query_rollback TEXT;
    query_merge TEXT;
    old_values JSONB;
    new_values JSONB;
BEGIN

    -- Extraer el esquema y nombre de la tabla del JSON
    scheme_name := json_info->>'scheme_name';
    table_name := json_info->>'table_name';
    
    -- Recorrer las claves del objeto 'fields'
    FOR field IN SELECT * FROM jsonb_each(json_info->'fields')
    LOOP
        -- Concatenar nombres de columnas
        IF field.key <> 'id_gis' THEN
            columnas := columnas || quote_ident(field.key) || ', ';
        END IF;
        
        -- Determinar el valor apropiado para la columna
        IF field.key = 'geom' THEN
            geom_coords := field.value->>'coords';
            geom_srid := (field.value->>'srid')::INT;
            valor := 'ST_GeomFromText(' || quote_literal(geom_coords) || ', ' || geom_srid || ')';
        ELSE
            IF field.key = 'id_gis' THEN
                id_gis := quote_literal(field.value->>0);
            ELSE 
                valor := quote_literal(field.value->>0);
            END IF;
        END IF;

        IF valor IS NOT NULL THEN
            -- Concatenar valores generando el set del update
            valores := valores || quote_ident(field.key) || ' = ' || valor || ', ';
        END IF;
    END LOOP;
    
    -- Eliminar la última coma y espacio
    valores := rtrim(valores, ', ');
    where_clause := 'id_gis = ' || id_gis;

    -- Obtener el estado actual del objeto antes de modificarlo
    EXECUTE 'SELECT row_to_json(t) FROM (SELECT * FROM ' || 
            quote_ident(scheme_name) || '.' || quote_ident(table_name) || 
            ' WHERE ' || where_clause || ') t'
    INTO old_values;

    -- Construir y ejecutar la consulta de actualización dinámica
    EXECUTE 'UPDATE ' || quote_ident(scheme_name) || '.' || quote_ident(table_name) || 
            ' SET ' || valores ||
            ' WHERE ' || where_clause;

    -- Obtener el nuevo estado del objeto después de la modificación
    EXECUTE 'SELECT row_to_json(t) FROM (SELECT * FROM ' || 
            quote_ident(scheme_name) || '.' || quote_ident(table_name) || 
            ' WHERE ' || where_clause || ') t'
    INTO new_values;

    -- Construir query_rollback como una llamada a update_object con el estado anterior
    query_rollback := 'SELECT update_object(' || 
                      quote_literal('{"scheme_name": "' || scheme_name || 
                                    '", "table_name": "' || table_name || 
                                    '", "fields": ' || old_values || '}') || ')';

    -- Construir query_merge como una llamada a update_object con el nuevo estado
    query_merge := 'SELECT update_object(' || 
                   quote_literal('{"scheme_name": "' || scheme_name || 
                                 '", "table_name": "' || table_name || 
                                 '", "fields": ' || new_values || '}') || ')';

    -- Guardar los datos en la tabla saved_changes
    EXECUTE format(
        'INSERT INTO %I.saved_changes(id_gis, change_time, record_time, user_id, query_merge, query_rollback) VALUES ($1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $2, %L, %L)',
        scheme_name, query_merge, query_rollback
    ) USING id_gis, (json_info->>'edited_by')::UUID;

END;
$$
LANGUAGE plpgsql;


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------



-- CREATE OR REPLACE FUNCTION insert_object(
--     IN schema_name TEXT,
--     IN object_type TEXT,
--     IN geom GEOMETRY,
--     IN id_usuario UUID,
--     IN id_duct TEXT DEFAULT NULL,
--     IN n_floors INT DEFAULT NULL,
--     IN n_clients INT DEFAULT NULL
-- ) RETURNS TEXT
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     user_exists BOOLEAN;
--     query_text TEXT;
-- BEGIN
--     -- Verificar si el usuario existe
--     SELECT EXISTS(SELECT 1 FROM security.users WHERE id = id_usuario) INTO user_exists;

--     -- Si el usuario no existe, lanzar un error
--     IF NOT user_exists THEN
--         RAISE EXCEPTION 'El usuario con id % no existe en security.users', id_usuario;
--     END IF;

--     -- Verificar el tipo de objeto y realizar la inserción correspondiente
--     CASE object_type
--         WHEN 'cw_ground_route' THEN
--             query_text := format('
--                 INSERT INTO %I.%I(geom, edited_by)
--                 VALUES (%L, %L)', schema_name, object_type, geom, id_usuario);
--             EXECUTE query_text;
--         WHEN 'fo_splice' THEN
--             query_text := format('
--                 INSERT INTO %I.%I(geom, edited_by)
--                 VALUES (%L, %L)', schema_name, object_type, geom, id_usuario);
--             EXECUTE query_text;

--         WHEN 'fo_cable' THEN
--             query_text := format('
--                 INSERT INTO %I.%I(geom, edited_by, id_duct)
--                 VALUES (%L, %L, %L)', schema_name, object_type, geom, id_usuario, id_duct);
--             EXECUTE query_text;

--         WHEN 'cw_building' THEN
--             -- Ajuste para cw_building con n_floors y n_clients, sin id_duct
--             query_text := format('
--                 INSERT INTO %I.%I(geom, edited_by, n_floors, n_clients)
--                 VALUES (%L, %L, %s, %s)', schema_name, object_type, geom, id_usuario, n_floors, n_clients);
--             EXECUTE query_text;
--         ELSE
--             query_text := format('
--                 INSERT INTO %I.%I(geom, edited_by)
--                 VALUES (%L, %L)', schema_name, object_type, geom, id_usuario);
--             EXECUTE query_text;
--     END CASE;

--     -- Imprimir el valor de query_text
--     RAISE NOTICE 'Query ejecutada: %', query_text;

--     -- Devolver la consulta ejecutada
--     RETURN query_text;
-- END;
-- $$;


--PROBANDO PROCEDIMIENTO NUEVO SEWER_BOX
-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-404270.31 4928508.68)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box',
--     'SRID=3857;POINT(-404346.69 4928643.55)',
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-404204.97 4928712.77)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-404061.86 4928795.84)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-403830.22 4928927.29)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-403911.74 4929074.14)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-403772.35 4928823.38)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-403596.88 4929067.92)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-403596.88 4929067.92)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-403695.08 4928688.35)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_sewer_box', 
--     'SRID=3857;POINT(-403608.66 4928732.30)', 
--     'a997da45-79ec-465d-8bbe-e38468c24c21'
-- );

-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------

-- --NUEVO PROCEDIMIENTO, INSERTS POSTE
-- SELECT insert_object(
--     'objects', 
--     'cw_pole',
--     'SRID=3857;POINT(-403976.17 4929178.57)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_pole', 
--     'SRID=3857;POINT(-404017.00 4929257.68)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_pole', 
--     'SRID=3857;POINT(-404118.58 4929237.43)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_pole', 
--     'SRID=3857;POINT(-403893.58 4929214.64)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------

-- --PROCEDIMIENTOS NUEVOS GROUND_ROUTE
-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );


-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );
-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );
-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------

-- --PROCEDIMIENTOS NUEVOS SKYWAY
-- SELECT insert_object(
--     'objects', 
--     'cw_skyway', 
--     'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_skyway', 
--     'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_skyway', 
--     'SRID=3857;LINESTRING(-404017.00 4929257.68, -404118.58 4929237.43)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_skyway', 
--     'SRID=3857;LINESTRING(-403976.17 4929178.57, -403893.58 4929214.64)', 
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );


-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );


-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );


-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_duct',
--     'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------

-- --NUEVOS PROCEDIMIENTOS. INSERTS SPLICE
-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-403830.22 4928927.29)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-403830.22 4928927.29)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );


-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-403830.22 4928927.29)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );


-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-403976.17 4929178.57)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-403976.17 4929178.57)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-404017.00 4929257.68)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-403695.08 4928688.35)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_splice',
--     'SRID=3857;POINT(-403695.08 4928688.35)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635'
-- );

-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------

-- --NUEVOS PROCEDIMIENTOS, INSERTS CABLES
-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_1'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_2'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_2'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );


-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );


-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_3'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_3'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_5'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_5'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );


-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_7'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_7'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_7'
-- );


-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_9'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_9'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_11'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)',
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_11'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)',
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_13'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_13'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects',
--     'fo_cable',
--     'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84, -403830.22 4928927.29)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_1, cw_duct_3, cw_duct_5, null'
-- );

-- SELECT insert_object(
--     'objects',
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_15'
-- );


-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
--     'cw_duct_16'
-- );


-- SELECT insert_object(
--     'objects',
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );
-- ------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------

-- -- Insertar un edificio
-- SELECT insert_object(
--     'objects',
--     'cw_building',
--     'SRID=3857;POINT(-404270.31 4928508.68)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635',
--     NULL,
--     30,
--     10
-- );

-- SELECT insert_object(
--     'objects',
--     'cw_building',
--     'SRID=3857;POINT(-404270.31 4928508.68)',
--     'fe2ddf89-87ae-4b29-8123-63782d2c8635',
--     NULL,
--     9,
--     10
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_skyway', 
--     'SRID=3857;LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'cw_ground_route', 
--     'SRID=3857;LINESTRING(-403830.22 4928927.29, -403832.20 4928977.44)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

-- SELECT insert_object(
--     'objects', 
--     'fo_cable', 
--     'SRID=3857;LINESTRING(-403893.58 4929214.64, -403884.22 4929191.55)', 
--     '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
-- );

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

-- call create_branch('pruebaProyect', 'fe2ddf89-87ae-4b29-8123-63782d2c8635');

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


--PROCEDIMIENTO DE DELETE
CREATE OR REPLACE PROCEDURE delete_point_object(
    IN schema_name TEXT,
    IN object_type TEXT, 
    IN id_gis VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar el tipo de objeto y realizar la eliminación correspondiente
    EXECUTE format('
        DELETE FROM %I.%I
        WHERE id_gis = $1', schema_name, object_type)
    USING id_gis;
END;
$$;

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

-- CALL update_object('objects', 'cw_sewer_box', 'cw_sewer_box_3', 'SRID=3857;POINT(-404304.97 4928712.77)', '3d12b18e-a844-477a-bd59-7ecfc984682d');

-- CALL update_object('objects', 'cw_pole', 'cw_pole_2', 'SRID=3857;POINT(-403985.86 4929052.72)', '3d12b18e-a844-477a-bd59-7ecfc984682d');

-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------


--PROCEDIMIENTOS DE DELETE
-- CALL delete_point_object('objects', 'cw_sewer_box', 'cw_sewer_box_2');

-- CALL delete_point_object('objects', 'cw_connectivity_box', 'cw_connectivity_box_2');


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION create_card_ports(
    schema_name TEXT,
    id_gis_card VARCHAR,
    n_rows INTEGER,
    n_cols INTEGER
) RETURNS VOID AS 
$$
DECLARE
    card_record RECORD;
    card_faces_array GEOMETRY[];
    aux_short_face_card_1 GEOMETRY;
    aux_short_face_card_2 GEOMETRY;
    aux_long_face_card_1 GEOMETRY;
    aux_long_face_card_2 GEOMETRY;
BEGIN
    EXECUTE format('SELECT * FROM %I.card WHERE id_gis = $1', schema_name) INTO card_record USING id_gis_card;

    EXECUTE format('SELECT ARRAY[
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=1), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=2), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=3), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4)),
            ST_MakeLine(
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=4), 
                (SELECT geom FROM ST_DumpPoints(layout_geom) WHERE path[2]=5))
        ] FROM %I.card WHERE id_gis = $1', schema_name) INTO card_faces_array USING id_gis_card;

    aux_short_face_card_1 := ST_LineInterpolatePoints(card_faces_array[1], (1/(n_rows + 3)::FLOAT), true);
    aux_short_face_card_2 := ST_LineInterpolatePoints(card_faces_array[3], (1/(n_rows + 3)::FLOAT), true);
    aux_long_face_card_1 := ST_LineInterpolatePoints(card_faces_array[2], (1/(n_cols + 3)::FLOAT), true);
    aux_long_face_card_2 := ST_LineInterpolatePoints(card_faces_array[4], (1/(n_cols + 3)::FLOAT), true);

    FOR e IN 2..(n_rows + 1)
    LOOP
        FOR i IN 2..(n_cols + 1)
        LOOP
            EXECUTE format('INSERT INTO %I.port(geom)
                SELECT ST_Intersection(
                    ST_MakeLine(
                        ST_GeometryN($1, $2),
                        ST_GeometryN($3, $4)
                    ),
                    ST_MakeLine(
                        ST_GeometryN($5, $6),
                        ST_GeometryN($7, $8)
                    )
                )', schema_name)
            USING
                aux_short_face_card_1, e,
                aux_short_face_card_2, ST_NumGeometries(aux_short_face_card_1) - e,
                aux_long_face_card_1, i,
                aux_long_face_card_2, ST_NumGeometries(aux_long_face_card_1) - i;
        END LOOP;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_fo_fiber_to_splice(
    schema_name TEXT, 
    id_gis_cable VARCHAR, 
    cable_geom GEOMETRY
) RETURNS void
AS
$$
DECLARE
    width FLOAT;
    new_geom_aux GEOMETRY;
    current_fiber RECORD;
BEGIN
    width := 0.0000375;
RAISE NOTICE 'dentro de update_fo_fiber_to_splice';
    -- Actualiza todas las fibras para hacer match con la geometría del cable padre
    FOR current_fiber IN EXECUTE format(
        'SELECT * FROM %I.fo_fiber WHERE id_cable = $1 ORDER BY id_gis',
        schema_name
    ) USING id_gis_cable
    LOOP
        -- Calcula la nueva geometría con un offset negativo
        new_geom_aux := ST_LineMerge(
            ST_OffsetCurve(cable_geom, -width, 'quad_segs=4 join=mitre mitre_limit=2.2')
        );

        -- Reversa la geometría si es necesario
        IF ST_Distance(ST_StartPoint(cable_geom), ST_StartPoint(new_geom_aux)) > 0.006 THEN
            new_geom_aux := ST_Reverse(new_geom_aux);
        END IF;
        RAISE NOTICE 'new_geom_aux %', ST_Astext(new_geom_aux);
        RAISE NOTICE 'current_fiber.id_gis %', current_fiber.id_gis;
        -- Actualiza la geometría de la fibra en la base de datos
        EXECUTE format(
            'UPDATE %I.fo_fiber SET layout_geom = $1, source = NULL, target = NULL WHERE id_gis = $2',
            schema_name
        ) USING new_geom_aux, current_fiber.id_gis;

        -- Incrementa el ancho para la próxima fibra
        width := width + 0.0000375;
    END LOOP;
END;
$$
LANGUAGE plpgsql;


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- --INSERCIÓN DE EMPALMES EN EDIFICIOS
-- SELECT insert_fo_splice_on_building('objects','cw_building_2', 1,'6a90e563-c016-4a30-aab3-91047725d7b5');

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

--INSERCIÓN DE OPTICAL SPLITTERS
-- SELECT optical_splitter_insert_func('objects','fo_splice_2', 4, '0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT optical_splitter_insert_func('objects','fo_splice_2', 16,'0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT optical_splitter_insert_func('objects','fo_splice_7', 8, '0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
 
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--CONECTAR CABLES CON EMPALMES

-- SELECT connect_objects('objects', 'fo_cable_59', 'fo_splice_11');
-- SELECT connect_objects('objects', 'fo_cable_60', 'fo_splice_13');
-- SELECT connect_objects('objects', 'fo_cable_62', 'fo_splice_13');
-- SELECT connect_objects('objects', 'fo_cable_63', 'fo_splice_13');
-- SELECT connect_objects('objects', 'fo_cable_64', 'fo_splice_13');
-- SELECT connect_objects('objects', 'fo_cable_44', 'fo_splice_13');
-- SELECT connect_objects('objects', 'fo_cable_45', 'fo_splice_13');


-- SELECT connect_objects('objects', 'fo_cable_51', 'fo_splice_7');
-- SELECT connect_objects('objects', 'fo_cable_54', 'fo_splice_7');
-- SELECT connect_objects('objects', 'fo_cable_52', 'fo_splice_8');
-- SELECT connect_objects('objects', 'fo_cable_53', 'fo_splice_8');


-- SELECT connect_objects('objects', 'fo_cable_38', 'fo_splice_4');
-- SELECT connect_objects('objects', 'fo_cable_39', 'fo_splice_5');
-- SELECT connect_objects('objects', 'fo_cable_42', 'fo_splice_4');
-- SELECT connect_objects('objects', 'fo_cable_43', 'fo_splice_5');

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--CONECTAR FIBRAS

-- SELECT connect_objects('objects', 'fo_fiber_7210', 'fo_fiber_7635');
-- SELECT connect_objects('objects', 'fo_fiber_7215', 'fo_fiber_7636');
-- SELECT connect_objects('objects', 'fo_fiber_7216', 'fo_fiber_7637');

--CONEXIÓN DE HILOS EN POSTES

-- SELECT connect_objects('objects', 'fo_fiber_5330', 'fo_fiber_5910');
-- SELECT connect_objects('objects', 'fo_fiber_5335', 'fo_fiber_5915');
-- SELECT connect_objects('objects', 'fo_fiber_5475', 'fo_fiber_6050');
-- SELECT connect_objects('objects', 'fo_fiber_5480', 'fo_fiber_6055');

--CONEXIÓN CON SPLITTERS

-- SELECT connect_objects('objects', 'fo_fiber_7221', 'in_port_3');
-- SELECT connect_objects('objects', 'fo_fiber_7640', 'out_port_21');
-- SELECT connect_objects('objects', 'fo_fiber_7645', 'out_port_22');

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--INSERCIÓN DE CLIENTES

-- SELECT insert_ont_on_client('objects','cw_client_355','6a90e563-c016-4a30-aab3-91047725d7b5');
-- SELECT insert_ont_on_client('objects','cw_client_341','6a90e563-c016-4a30-aab3-91047725d7b5');
-- SELECT insert_ont_on_client('objects','cw_client_342','6a90e563-c016-4a30-aab3-91047725d7b5');
-- SELECT insert_ont_on_client('objects','cw_client_343','6a90e563-c016-4a30-aab3-91047725d7b5');
-- SELECT insert_ont_on_client('objects','cw_client_311','6a90e563-c016-4a30-aab3-91047725d7b5');
-- SELECT insert_ont_on_client('objects','cw_client_303','6a90e563-c016-4a30-aab3-91047725d7b5');

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

--CONECTAR EMPALMES CON CLIENTES
-- SELECT connect_objects('objects', 'fo_splice_9', 'cw_client_343');
-- SELECT connect_objects('objects', 'fo_splice_9', 'cw_client_341');
-- SELECT connect_objects('objects', 'fo_splice_9', 'cw_client_342');
-- SELECT connect_objects('objects', 'fo_splice_9', 'cw_client_303');
-- SELECT connect_objects('objects', 'fo_splice_9', 'cw_client_311');

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

--INSERCIÓN DE CLIENTE EN EL SUELO
-- SELECT insert_client_on_floor('objects','cw_floor_37', '6a90e563-c016-4a30-aab3-91047725d7b5');

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- SELECT insert_fo_splice_on_building('objects','cw_building_2', 5,'0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects','fo_splice_9', 'fo_splice_10');
-- SELECT optical_splitter_insert_func('fo_splice_10', 16, 'objects','74af23be-6a0a-4e48-a345-0f9cf4726e5c');

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--INSERT RACKS
-- SELECT insert_rack('objects', 'cw_client_343', 'NGXC-3600  Bay','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_1');

-- SELECT insert_rack('objects', 'cw_client_352', 'Alcatel ODF Rack','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_2');

-- SELECT insert_rack('objects', 'cw_client_369', 'NGXC-3600  Bay','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_3');

-- SELECT insert_rack('objects', 'cw_client_352', 'NGXC-3600  Bay','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_4');

-- SELECT insert_rack('objects', 'cw_client_352', 'Wallbox','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_5');

-- SELECT insert_rack('objects', 'cw_client_352', 'NGXC-3600  Bay','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_6');

-- SELECT insert_rack('objects', 'cw_client_352', 'Wallbox','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_7');

-- SELECT insert_rack('objects', 'cw_client_352', '1660 19" Bay','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_8');

-- SELECT insert_rack('objects', 'cw_client_352', 'NGXC-3600  Bay','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT connect_objects('objects', 'fo_splice_10', 'rack_9');

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

-- SELECT insert_shelf_on_rack('objects', 'rack_4', 'LANscape 2U','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT insert_shelf_on_rack('objects', 'rack_4', '7342 AFAN-R','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');
-- SELECT insert_shelf_on_rack('objects', 'rack_4', '7342 AFAN-R','0b85f0ac-3ec6-4d08-a964-25cbb7aaae05');

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- SELECT insert_card_on_rack('objects', 'rack_4', 'STM-4 S4.1N', 5, 10);
-- SELECT insert_card_on_rack('objects', 'rack_4', 'E1LT-A', 1, 15);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- SELECT insert_card_on_shelf('objects', 'shelf_1', 'VX2000-MD Line Card', 1, 15);
-- SELECT insert_card_on_shelf('objects', 'shelf_1', 'ADSL2-24', 6, 10);
-- SELECT insert_card_on_shelf('objects', 'shelf_1', 'COMBO-24', 1, 15);

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

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
		PERFORM connect_fiber(CONCAT('fo_fiber_', (fibra_inicio + i)::TEXT), CONCAT('fo_fiber_', (fibra_fin + i)::TEXT), 'objects');

		fibra_inicio:=2880;
		fibra_fin:=3888;
		PERFORM connect_fiber(CONCAT('fo_fiber_', (fibra_inicio + i)::TEXT), CONCAT('fo_fiber_', (fibra_fin + i)::TEXT), 'objects');

		fibra_inicio:=3024;
		fibra_fin:=4608;
		PERFORM connect_fiber(CONCAT('fo_fiber_', (fibra_inicio + i)::TEXT), CONCAT('fo_fiber_', (fibra_fin + i)::TEXT), 'objects');
	END LOOP;
END;
$$
LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- SELECT connect_fibers();

------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- /*markdown
-- CONECION CON SPLITTERS
-- */

-- SELECT connect_fiber_port('objects', 'fo_fiber_7221', 'in_port_3');
-- SELECT connect_fiber_port('objects', 'fo_fiber_7640', 'out_port_21');
-- SELECT connect_fiber_port('objects','fo_fiber_7645', 'out_port_22');

------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

--TOPOLOGIA DE HILOS 
-- SELECT pgr_CreateTopology('objects.fo_fiber', 0.000000001, 'layout_geom', 'id_auto');

--FUNCION QUE ACTUALIZA LA TOPOLOGIA
-- SELECT update_fiber_topology('objects');

--------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
	
CREATE OR REPLACE FUNCTION possible_to_delete(id_gis VARCHAR) RETURNS VARCHAR AS 
$$
DECLARE
    char_array TEXT[];
    object_name VARCHAR;
    object_record RECORD;
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

--------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

select * FROM security.users;