
CREATE EXTENSION postgis;

CREATE EXTENSION postgis_raster;

CREATE EXTENSION fuzzystrmatch;

CREATE EXTENSION postgis_tiger_geocoder;

CREATE EXTENSION postgis_topology;

CREATE EXTENSION address_standardizer_data_us;

CREATE EXTENSION pgrouting;

CREATE SCHEMA objects;

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

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

drop table public.branches;

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

       EXECUTE format('CREATE TABLE %I.%I (LIKE %I.%I INCLUDING ALL)', _dest_schema, _version_table, _base_schema, _table_name);
   IF _table_name != _exclude_table THEN

       -- Copy data from the original table to the new table, excluding 'saved_changes'
       EXECUTE format('INSERT INTO %I.%I SELECT * FROM %I.%I', _dest_schema, _version_table, _base_schema, _table_name);
   END IF;

   -- Create trigger for the new versioned table only if the update trigger function exists
   IF _update_function_exists AND _insert_function_exists THEN
       EXECUTE format('CREATE TRIGGER %I_update_trigger AFTER UPDATE ON %I.%I FOR EACH ROW EXECUTE PROCEDURE %I_update()', _table_name, _dest_schema, _version_table, _table_name);
   END IF;

   -- Create trigger for the new versioned table (always)
   IF _insert_function_exists THEN
       EXECUTE format('CREATE TRIGGER %I_insert_trigger AFTER INSERT ON %I.%I FOR EACH ROW EXECUTE PROCEDURE %I_insert()', _table_name, _dest_schema, _version_table, _table_name);
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
    geom geometry(POINT,3857),
    layout_geom geometry(POLYGON,3857),
    json_binary JSONB,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE OR REPLACE FUNCTION generate_sewer_box_json() RETURNS JSONB AS
$$
DECLARE
    json_data JSONB;
BEGIN
    -- Generar el JSON con los campos especificados
    json_data := jsonb_build_object(
        'especificaciones', ARRAY['Conduit Terminus', 'Controlled Environment Vault', 'Handhole', 'Manhole', 'Pedestal', 'Vault'],
        'profundidad', 10.5,
        'longitud', 20.3,
        'num_lados', 4,
        'id_plantilla', 'template_id_123',
        'ancho', 5.7,
        'asset', ARRAY['Acquired', 'Unknown', 'Use Project Default', 'Owned', 'Third party'],
        'estado_construccion', ARRAY['Abandonned', 'Deleted', 'Unknown', 'In Service', 'In Construction', 'Installed In Place', 'Planned', 'Proposed', 'Reserved']
    );
    RETURN json_data;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cw_sewer_box_insert() RETURNS TRIGGER AS
$$
DECLARE
    new_geom GEOMETRY;
    new_geom_cbox GEOMETRY;
    new_diagonal GEOMETRY;
    width FLOAT;
    width_cbox FLOAT;
    dest_schema TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    json_data JSONB;
    edited_by_value UUID;
    query_merge_value TEXT;
    query_rollback TEXT := 'Call delete procedure'
    insert_connectivity_box_query TEXT;
    insert_query TEXT;
BEGIN
    width := 3.75;
    width_cbox := 2;

    -- Creación de la geometría para la cara exterior
    EXECUTE format('SELECT ST_Buffer($1, %s, ''quad_segs=8'')', width)
    INTO new_geom
    USING NEW.geom;

    -- Verificación de la geometría
    IF new_geom IS NULL THEN
        RAISE EXCEPTION 'new_geom es NULL. Verifica la geometría de entrada y los parámetros de ST_Buffer.';
    END IF;

    -- Creación de la geometría para cw_connectivity_box
    EXECUTE format('SELECT ST_Buffer($1, %s, ''endcap=square'')', width_cbox)
    INTO new_geom_cbox
    USING NEW.geom;

    -- Verificación de la geometría
    IF new_geom_cbox IS NULL THEN
        RAISE EXCEPTION 'new_geom_cbox es NULL. Verifica la geometría de entrada y los parámetros de ST_Buffer.';
    END IF;

    -- Creación de la diagonal
    new_diagonal := ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2] = 4),
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2] = 2)
    );

    -- Verificación de la diagonal
    IF new_diagonal IS NULL THEN
        RAISE EXCEPTION 'new_diagonal es NULL. Verifica los puntos seleccionados de new_geom_cbox.';
    END IF;

    -- Llamada a la función que genera el JSON
    json_data := generate_sewer_box_json();

    -- Obtención de edited_by_value
    EXECUTE format('SELECT edited_by FROM %I.cw_sewer_box WHERE id_auto = $1', dest_schema)
    INTO edited_by_value
    USING NEW.id_auto;

    -- Verificación de edited_by_value
    IF edited_by_value IS NULL THEN
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el registro actual de cw_sewer_box.';
    END IF;

    -- Construcción de query_merge_value para insert_object
    query_merge_value := format('SELECT insert_object(%L, %L, %L, %L)',
                                top_schema, 'cw_sewer_box', NEW.geom, edited_by_value);

    -- Actualización del pozo en el esquema de destino
    EXECUTE format('UPDATE %I.cw_sewer_box SET id_gis = $1, layout_geom = $2, json_binary = $3 WHERE id_auto = $4', dest_schema)
    USING CONCAT('cw_sewer_box_', NEW.id_auto::TEXT), new_geom, json_data, NEW.id_auto;

    -- Inserción en saved_changes para cw_sewer_box
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge, query_rollback) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, %L, %L)',
                   dest_schema, query_merge_value, query_rollback)
    USING NEW.id, CONCAT('cw_sewer_box_', NEW.id_auto::TEXT), edited_by_value;

    -- Construcción de query_merge_value para cw_connectivity_box
    insert_connectivity_box_query := format(
        'INSERT INTO %I.cw_connectivity_box(id_gis, geom, layout_geom, diagonal_geom, edited_by) VALUES (%L, %L, %L, %L, %L)',
        dest_schema,
        CONCAT('cw_connectivity_box_', NEW.id_auto::TEXT),
        NEW.geom::text,
        new_geom_cbox::text,
        new_diagonal::text,
        edited_by_value::text
    );

    EXECUTE insert_connectivity_box_query;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


--Trigger original
CREATE TRIGGER sewer_box_triggger
	AFTER INSERT ON objects.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE cw_sewer_box_insert();


CREATE OR REPLACE FUNCTION cw_sewer_box_update() RETURNS trigger AS
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
    schema_name TEXT := TG_TABLE_SCHEMA; -- Nombre del esquema que deseas buscar
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

    -- Inserción en cw_connectivity_box

    -- Construcción de query_merge_value para insert_object
        query_update_merge := format('SELECT update_object(%L, %L, %L, %L, %L)',
                                schema_name, 'cw_sewer_box',oldgis,  NEW.geom, edited_by_value);

        
        query_update_rollback := format('SELECT update_object(%L, %L, %L, %L, %L)',
                                schema_name, 'cw_sewer_box',oldgis,  OLD.geom, edited_by_value);

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
                    EXECUTE format('SELECT %I, id_gis FROM %I.%I WHERE ctid = %L', 
                                current_field.column_name, 
                                schema_name, 
                                current_table.table_name, 
                                row.ctid)
                    INTO current_new_geom, current_id_gis;

                    IF current_new_geom IS NULL THEN CONTINUE; END IF;

                    IF (current_table.table_name = 'cw_ground_route' OR 
                            current_table.table_name = 'cw_skyway' OR 
                            current_table.table_name = 'cw_duct' OR
                            (current_table.table_name = 'fo_cable' AND current_field.column_name = 'geom')
                        )
                    THEN
                        IF ST_GeometryType(current_new_geom) = 'ST_LineString' THEN                            
                            EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
                                ' = ' || quote_literal(ST_AsText(update_linestrings(current_new_geom, OLD.geom, NEW.geom))) ||
                                ' WHERE id_gis = ($1);' USING current_id_gis;
                        END IF;
                    ELSIF NOT current_table.table_name = 'fo_cable' THEN
                        -- Agrega una parte de la consulta para actualizar todas las geometrías de la tabla
                        EXECUTE 'UPDATE ' || schema_name || '.' || current_table.table_name || ' SET ' || current_field.column_name || 
                            ' = ST_Translate(' || current_field.column_name || ', ' || translation_x || ', ' || translation_y || ')' ||
                            ' WHERE id_gis = ($1);' USING current_id_gis;
                    END IF;                        
                END LOOP;
            END LOOP;
        END LOOP;
        
        FOR current_aux_record IN SELECT * FROM cable_connectivity
        LOOP
            PERFORM connect_cable(current_aux_record.id_gis_cable, current_aux_record.id_gis_splice);
        END LOOP;

        PERFORM update_stored_conections(schema_name);

        DROP TABLE IF EXISTS cable_connectivity;
        DROP TABLE IF EXISTS fiber_connectivity;
        DROP TABLE IF EXISTS fiber_port_connectivity;

    -- Inserción en saved_changes para cw_sewer_box
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge, query_rollback) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, %L, %L)',
                   schema_name, query_update_merge, query_update_rollback)
    USING OLD.id, oldgis, edited_by_value;
    END IF;       
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cw_sewer_box_update_triggger
	AFTER UPDATE ON objects.cw_sewer_box
	FOR EACH ROW EXECUTE PROCEDURE cw_sewer_box_update();

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

--POSTES
CREATE TABLE objects.cw_pole(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	geom geometry(POINT,3857),
    geom3D geometry(POLYGON,3857),
	layout_geom geometry(POLYGON,3857),
	support geometry(LINESTRING, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE OR REPLACE FUNCTION cw_pole_insert() RETURNS trigger AS
$$
DECLARE 
    new_geom GEOMETRY;
    new_geom_3D GEOMETRY;
    new_geom_cbox GEOMETRY;
    new_diagonal GEOMETRY;
    perpendicular_diagonal_line GEOMETRY;
    width FLOAT;
    width_cbox FLOAT;
    width_pole_3D FLOAT;
    dest_schema TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    query_merge_value TEXT;
    query_rollback TEXT;
    insert_connectivity_box_query TEXT;
    insert_query TEXT;
BEGIN
    width = 3.75;
    width_cbox = 2;
    width_pole_3D = 0.125;

    -- Se crea la topología de la cara exterior que cortará los ductos
    new_geom = ST_Buffer(NEW.geom, width, 'quad_segs=8');
    
    -- Se crea la topología de la cara interior que cortará los cables
    new_geom_cbox = ST_Buffer(NEW.geom, width_cbox, 'endcap=square');

    -- Se genera la topología 3D como ayuda al visor 3D    
    new_geom_3D = ST_Buffer(NEW.geom, width_pole_3D, 'quad_segs=8');

    -- Genera la diagonal en la que se irán introduciendo los empalmes
    new_diagonal = ST_MakeLine(
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2]=4),
        (SELECT geom FROM ST_DumpPoints(new_geom_cbox) WHERE path[2]=2)
    );
    
    perpendicular_diagonal_line := ST_Rotate(new_diagonal, -PI()/2, ST_Centroid(new_diagonal));

    -- Obtén el valor de edited_by
    EXECUTE format('SELECT edited_by FROM %I.cw_pole WHERE id_auto = $1', dest_schema)
    INTO edited_by_value
    USING NEW.id_auto;

        -- Construcción de query_merge_value para insert_object
    query_merge_value := format('SELECT insert_object(%L, %L, %L, %L)',
                                top_schema, 'cw_pole', NEW.geom, edited_by_value);

    -- Actualiza el pozo
    EXECUTE format('
        UPDATE %I.cw_pole
        SET id_gis = $1, 
            geom3D = $2,
            layout_geom = $3,
            support = ST_MakeLine(
                ST_MakeLine(
                    ST_LineExtend($4, 0.875, 0.875), 
                    ST_Centroid($4)),
                ST_LineExtend($5, 0.875, 0.875)
            )
        WHERE id = $6', dest_schema)
    USING CONCAT('cw_pole_', NEW.id_auto::text), new_geom_3D, new_geom, new_diagonal, perpendicular_diagonal_line, NEW.id;

        -- Inserción en saved_changes para cw_sewer_box
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, %L)',
                   dest_schema, query_merge_value)
    USING NEW.id, CONCAT('cw_pole_', NEW.id_auto::TEXT), edited_by_value;


    -- Inserta en la tabla cw_connectivity_box con los datos anteriores y edited_by
    insert_connectivity_box_query := format(
        'INSERT INTO %I.cw_connectivity_box(id_gis, geom, layout_geom, diagonal_geom, edited_by) VALUES (%L, %L, %L, %L, %L)',
        dest_schema,
        CONCAT('cw_connectivity_box_', NEW.id_auto::TEXT),
        NEW.geom::text,
        new_geom_cbox::text,
        new_diagonal::text,
        edited_by_value::text
    );

    EXECUTE insert_connectivity_box_query;

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
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el registro actual de cw_sewer_box.';
    END IF;

    -- Construcción de query_merge_value para insert_object
        query_update_merge := format('SELECT update_object(%L, %L, %L, %L, %L)',
                                schema_name, 'cw_pole_', oldgis, NEW.geom, edited_by_value);

        query_rollback := format('SELECT update_object(%L, %L, %L, %L, %L)',
                                schema_name, 'cw_pole_', oldgis, OLD.geom, edited_by_value);

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
                AND NOT table_name = 'fo_fiber'
                AND NOT table_name = 'cw_ground_route'
                AND NOT table_name = 'cw_duct'
                AND NOT table_name = 'fo_fiber_vertices_pgr'
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

        -- Se regeneran los cables
        FOR cur_aux IN SELECT * FROM cable_connectivity
        LOOP
            PERFORM connect_cable(cur_aux.id_gis_cable, cur_aux.id_gis_splice);
        END LOOP;

        -- Se regeneran las conexiones
        PERFORM update_stored_conections(schema_name);

        -- Se borran las tablas temporales
        DROP TABLE IF EXISTS cable_connectivity;
        DROP TABLE IF EXISTS fiber_connectivity;
        DROP TABLE IF EXISTS fiber_port_connectivity;

    -- Inserción en saved_changes para cw_sewer_box
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge, query_rollback) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, %L, %L)',
                   schema_name, query_update_merge, query_rollback)
    USING OLD.id, oldgis, edited_by_value;
    END IF;       
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER cw_pole_update_trigger
	AFTER UPDATE ON objects.cw_pole
	FOR EACH ROW EXECUTE PROCEDURE cw_pole_update();


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
    json_binary JSONB,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE OR REPLACE FUNCTION generate_connectivity_box_json() RETURNS JSONB AS
$$
DECLARE
    json_data JSONB;
BEGIN
    -- Generar el JSON con los campos especificados
    json_data := jsonb_build_object(
        'asset', ARRAY['Acquired', 'Unknown', 'Use Project Default', 'Owned', 'Third party'],
        'estado_construccion', ARRAY['Abandonned', 'Deleted', 'Unknown', 'In Service', 'In Construction', 'Installed In Place', 'Planned', 'Proposed', 'Reserved']
    );

    RETURN json_data;
END;
$$
LANGUAGE plpgsql;




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
CREATE TRIGGER connectivity_box_triggger
	AFTER INSERT ON objects.cw_connectivity_box
	FOR EACH ROW EXECUTE PROCEDURE cw_connectivity_box_insert();

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

-- GROUND ROUTE
CREATE TABLE objects.cw_ground_route(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL, 
	id_gis VARCHAR,
	width FLOAT,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(POLYGON,3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE OR REPLACE FUNCTION generate_ground_route_json() RETURNS JSONB AS
$$
DECLARE
    json_data JSONB;
BEGIN
    -- Generar el JSON con los campos especificados
    json_data := jsonb_build_object(
        'asset', ARRAY['Acquired', 'Unknown', 'Use Project Default', 'Owned', 'Third party'],
        'estado_construccion', ARRAY['Abandonned', 'Deleted', 'Unknown', 'In Service', 'In Construction', 'Installed In Place', 'Planned', 'Proposed', 'Reserved']
    );
    RETURN json_data;
END;
$$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION cw_ground_route_insert() RETURNS trigger AS
$$
DECLARE 
    real_geom GEOMETRY;
    aux_gr_geom GEOMETRY;
    aux_geom GEOMETRY;
    current_node RECORD;
    id_gis_sewer VARCHAR;
    id_cb VARCHAR;
    sewer_box_uuid UUID;
    connectivity_box_uuid UUID;
    radians_to_rotate FLOAT;
    width FLOAT;
    dest_schema TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    update_sewer_box_query TEXT;
    update_connectivity_box_query TEXT;
    query_merge_value TEXT;
    query_rollback TEXT := 'call delete procedure';
BEGIN
    width := 0.875;
    real_geom := ST_LineMerge(NEW.geom);
    aux_gr_geom := ST_Buffer(NEW.geom, width, 'endcap=flat join=round');

    aux_geom := ST_MakeLine(
        ST_SetSRID(ST_MakePoint(ST_X(ST_PointN(real_geom, 1)), ST_Y(ST_PointN(real_geom, 2))), 3857), 
        ST_SetSRID(ST_PointN(real_geom, 2), 3857)
    );

    radians_to_rotate := ST_Angle(aux_geom, real_geom);

    RAISE NOTICE 'radians_to_rotate: %', radians_to_rotate;

    edited_by_value := NEW.edited_by;

    IF edited_by_value IS NULL THEN
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el nuevo registro de cw_ground_route.';
    END IF;

    query_merge_value := format('SELECT insert_object(%L, %L, %L, %L)',
                                top_schema, 'cw_ground_route', NEW.geom, edited_by_value);
    EXECUTE format('
        SELECT id_gis, id 
        FROM (
            SELECT geom::geometry AS a, id_gis, id
            FROM %I.cw_sewer_box
        ) AS subquery  
        WHERE ST_Intersects(
            a,
            ST_EndPoint($1)
        )
        LIMIT 1
    ', dest_schema) INTO id_gis_sewer, sewer_box_uuid
    USING NEW.geom;

    RAISE NOTICE 'id_gis_sewer: %, sewer_box_uuid: %', id_gis_sewer, sewer_box_uuid;

    EXECUTE format('
        SELECT id_gis, id
        FROM (
            SELECT geom::geometry AS a, id_gis, id 
            FROM %I.cw_connectivity_box
        ) AS subquery_cb
        WHERE ST_Intersects(
            a,
            ST_EndPoint($1)
        )
        LIMIT 1
    ', dest_schema) INTO id_cb, connectivity_box_uuid
    USING NEW.geom;

    RAISE NOTICE 'id_cb: %, connectivity_box_uuid: %', id_cb, connectivity_box_uuid;

    IF id_gis_sewer IS NOT NULL THEN
        update_sewer_box_query := format('UPDATE %I.cw_sewer_box 
            SET layout_geom = ST_Rotate(layout_geom, -%s, ST_centroid(geom::geometry))  
            WHERE id_gis=%L', dest_schema, radians_to_rotate, id_gis_sewer);

        RAISE NOTICE 'update_sewer_box_query: %', update_sewer_box_query;
        EXECUTE update_sewer_box_query;

        update_connectivity_box_query := format('UPDATE %I.cw_connectivity_box 
            SET layout_geom = ST_Rotate(layout_geom, -%s, ST_centroid(geom::geometry)),
                diagonal_geom = ST_Rotate(diagonal_geom, -%s, ST_centroid(geom::geometry))
            WHERE id_gis=%L', dest_schema, radians_to_rotate, radians_to_rotate, id_cb);

        RAISE NOTICE 'update_connectivity_box_query: %', update_connectivity_box_query;
        EXECUTE update_connectivity_box_query;
    END IF;

    FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_sewer_box WHERE ST_overlaps($1, layout_geom)', dest_schema) USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
    END LOOP;

    EXECUTE format('UPDATE %I.cw_ground_route
        SET id_gis=CONCAT(''cw_ground_route_'', $1::text),
            layout_geom = $2
        WHERE id_auto = $1', dest_schema)
    USING NEW.id_auto, aux_gr_geom;

    -- Inserta un nuevo registro en la tabla saved_changes para cw_ground_route
    EXECUTE format('INSERT INTO %I.saved_changes
        (id, change_time, record_time, user_id, query_merge, id_gis)
        VALUES (%L, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, %L::uuid, %L, %L)', 
        dest_schema, NEW.id, edited_by_value::text, query_merge_value, CONCAT('cw_ground_route_', NEW.id_auto::TEXT)::text);

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;



--TRIGGER TABLA ORIGINAL
CREATE TRIGGER ground_route_insert_triggger
	AFTER INSERT ON objects.cw_ground_route
	FOR EACH ROW EXECUTE PROCEDURE cw_ground_route_insert();

    
CREATE OR REPLACE FUNCTION cw_ground_route_update() RETURNS trigger AS
$$
DECLARE 
    real_geom GEOMETRY;
    aux_gr_geom GEOMETRY;
    aux_geom GEOMETRY;
    cb_rotated_geom GEOMETRY;
    current_node RECORD;
    id_gis_sewer VARCHAR;
    id_cb VARCHAR;
    radians_to_rotate FLOAT;
    width FLOAT := 0.875; -- Declarar e inicializar la variable width aquí
    schema_name TEXT := TG_TABLE_SCHEMA;
    edited_by_value UUID; -- Declarar variable para edited_by
    action_text TEXT := 'Update in cw_ground_route'; -- Declarar variable para action_text
BEGIN
    IF NOT ST_Equals(OLD.geom, NEW.geom) THEN
        aux_gr_geom = ST_Buffer(NEW.geom, width, 'endcap=flat join=round');

        FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_sewer_box WHERE ST_Overlaps($1, layout_geom)', schema_name) USING aux_gr_geom LOOP
            aux_gr_geom = (SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
        END LOOP;

        EXECUTE format('UPDATE %I.cw_ground_route SET id_gis = CONCAT(''cw_ground_route_'', $1::text), layout_geom = $2 WHERE id = $3', schema_name)
        USING NEW.id_auto, aux_gr_geom, NEW.id;
    END IF;

    -- Obtener el valor de edited_by_value (ajusta según de dónde venga este valor)
    EXECUTE format('SELECT edited_by FROM %I.cw_ground_route WHERE id = $1', schema_name)
    INTO edited_by_value
    USING OLD.id;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;



CREATE TRIGGER ground_route_update_triggger
	AFTER UPDATE ON objects.cw_ground_route
	FOR EACH ROW EXECUTE PROCEDURE cw_ground_route_update();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--SKYWAY
CREATE TABLE objects.cw_skyway(
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(POLYGON,3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);



CREATE OR REPLACE FUNCTION cw_skyway_insert() RETURNS trigger AS
$$
DECLARE
    real_geom GEOMETRY;
    aux_gr_geom GEOMETRY;
    aux_geom GEOMETRY;
    cb_rotated_geom GEOMETRY;
    rotated_diagonal_geom GEOMETRY;
    perpendicular_diagonal_line GEOMETRY;
    current_node RECORD;
    id_gis_pole VARCHAR;
    id_gis_sewer VARCHAR;
    id_cb VARCHAR;
    radians_to_rotate FLOAT;
    width FLOAT;    
    dest_schema TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    edited_by_value UUID; -- Variable para guardar el valor de edited_by
    update_pole_query TEXT;
    update_sewer_box_query TEXT;
    update_connectivity_box_query TEXT;
    query_merge_value TEXT;
    query_rollback TEXT;
BEGIN
    width := 0.625;

    real_geom := ST_LineMerge(NEW.geom);
    
    aux_gr_geom := ST_Buffer(NEW.geom, width, 'side=right');

    -- Se genera una linea auxiliar para compararla con real_geom y sacar el angulo de giro que hay que darle al pozo,
    -- para que la ruta de entrada quede perpendicular al área del pozo
    aux_geom := ST_MakeLine(
        ST_SetSRID(ST_MakePoint(ST_X(ST_PointN(real_geom, 1)), ST_Y(ST_PointN(real_geom, 2))), 3857), 
        ST_SetSRID(ST_PointN(real_geom, 2), 3857));
        
    -- Se obtienen los radianes de giro
    radians_to_rotate := ST_Angle(aux_geom, real_geom);

    -- Se obtiene el id de los elementos que tienen que rotar
    EXECUTE format('
        SELECT id_gis 
        FROM (
            SELECT geom::geometry AS a, * 
            FROM %I.cw_sewer_box
        ) AS subquery  
        WHERE ST_Intersects(
            a,
            ST_EndPoint($1)
        )
        LIMIT 1
    ', dest_schema) INTO id_gis_sewer
    USING NEW.geom;
    
    -- RAISE NOTICE para id_gis_sewer
    RAISE NOTICE 'id_gis_sewer: %', id_gis_sewer;
    
    EXECUTE format('
        SELECT id_gis 
        FROM (
            SELECT geom::geometry AS a, * 
            FROM %I.cw_pole
        ) AS subquery  
        WHERE ST_Intersects(
            a,
            ST_EndPoint($1)
        )
        LIMIT 1
    ', dest_schema) INTO id_gis_pole
    USING NEW.geom;

    

    -- RAISE NOTICE para id_gis_pole
    RAISE NOTICE 'id_gis_pole: %', id_gis_pole;

    EXECUTE format('
        SELECT id_gis 
        FROM (
            SELECT geom::geometry AS a, * 
            FROM %I.cw_connectivity_box
        ) AS subquery  
        WHERE ST_Intersects(
            a,
            ST_EndPoint($1)
        )
        LIMIT 1
    ', dest_schema) INTO id_cb
    USING NEW.geom;
    
    -- RAISE NOTICE para id_cb
    RAISE NOTICE 'id_cb: %', id_cb;
    
    -- En el caso en el que la ruta sea de entrada al pozo, se actualizan las topologías
    IF id_gis_pole IS NOT NULL THEN
        EXECUTE format('
            SELECT ST_Rotate(layout_geom, %L, ST_Centroid(geom))
            FROM %I.cw_connectivity_box
            WHERE id_gis = %L
        ', radians_to_rotate::TEXT, dest_schema, id_cb) INTO cb_rotated_geom;

        EXECUTE format('
            SELECT ST_Rotate(diagonal_geom, %L, ST_Centroid(geom))
            FROM %I.cw_connectivity_box
            WHERE id_gis = %L
        ', radians_to_rotate::TEXT, dest_schema, id_cb) INTO rotated_diagonal_geom;

        perpendicular_diagonal_line := ST_Rotate(rotated_diagonal_geom, -PI()/2, ST_Centroid(rotated_diagonal_geom));

        update_pole_query := format('UPDATE %I.cw_pole 
            SET layout_geom = ST_Rotate(layout_geom, %L, ST_Centroid(geom)),
                support = ST_MakeLine(
                    ST_MakeLine(
                        ST_LineExtend(%L, 0.875, 0.875), 
                        ST_Centroid(%L)),
                    ST_LineExtend(%L, 0.875, 0.875)
                )
            WHERE id_gis = %L', dest_schema, radians_to_rotate::TEXT, rotated_diagonal_geom::TEXT, rotated_diagonal_geom::TEXT, perpendicular_diagonal_line::TEXT, id_gis_pole);

        EXECUTE update_pole_query;
        
        update_connectivity_box_query := format('UPDATE %I.cw_connectivity_box SET layout_geom = %L, diagonal_geom = %L WHERE id_gis = %L', dest_schema, cb_rotated_geom::TEXT, rotated_diagonal_geom::TEXT, id_cb);

        EXECUTE update_connectivity_box_query;

    ELSIF id_gis_sewer IS NOT NULL THEN
        update_sewer_box_query := format('UPDATE %I.cw_sewer_box 
            SET layout_geom = ST_Rotate(geom, %L, ST_Centroid(geom))
            WHERE id_gis = %L', dest_schema, radians_to_rotate::TEXT, id_gis_sewer);
        
        EXECUTE update_sewer_box_query;
        
        update_connectivity_box_query := format('UPDATE %I.cw_connectivity_box 
            SET layout_geom = ST_Rotate(geom, %L, ST_Centroid(geom)),
                diagonal_geom = ST_Rotate(diagonal_geom, %L, ST_Centroid(geom))
            WHERE id_gis = %L', dest_schema, radians_to_rotate::TEXT, radians_to_rotate::TEXT, id_cb);
        
        EXECUTE update_connectivity_box_query;
    END IF;
    
    FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_sewer_box WHERE ST_Overlaps($1, layout_geom)', dest_schema)
    USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
    END LOOP;

    FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_pole WHERE ST_Overlaps($1, layout_geom)', dest_schema)
    USING aux_gr_geom
    LOOP
        aux_gr_geom := ST_Difference(aux_gr_geom, current_node.layout_geom);
    END LOOP;
    
    EXECUTE format('UPDATE %I.cw_skyway
        SET id_gis = %L,
            layout_geom = %L
        WHERE id = %L', dest_schema, CONCAT('cw_skyway_', NEW.id_auto::TEXT), aux_gr_geom::TEXT, NEW.id::TEXT);

    -- Obtiene el valor de edited_by del nuevo registro de cw_skyway
    edited_by_value := NEW.edited_by;

    -- Verifica si edited_by_value fue obtenido correctamente
    IF edited_by_value IS NULL THEN
        RAISE EXCEPTION 'edited_by_value es NULL. Verifica el valor de edited_by en el nuevo registro de cw_skyway.';
    END IF;
    
        -- Construcción de query_merge_value para insert_object
    query_merge_value := format('SELECT insert_object(%L, %L, %L, %L)',
                                top_schema, 'cw_skyway', NEW.geom, edited_by_value);
    -- Inserta en la tabla saved_changes para cw_skyway
    EXECUTE format('
        INSERT INTO %I.saved_changes (id, id_gis, change_time, record_time, user_id, query_merge)
        VALUES (%L, %L, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, %L::uuid, %L)
    ', dest_schema, NEW.id, CONCAT('cw_skyway_', NEW.id_auto::TEXT), edited_by_value::TEXT, query_merge_value);

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER skyway_insert_triggger
	AFTER INSERT ON objects.cw_skyway
	FOR EACH ROW EXECUTE PROCEDURE cw_skyway_insert();


CREATE OR REPLACE FUNCTION skyway_update_trigger() RETURNS trigger AS
$$
DECLARE 
    aux_gr_geom GEOMETRY;
    current_node RECORD;
    width FLOAT;    
    dynamic_query TEXT;
    schema_name TEXT := TG_TABLE_SCHEMA;
	edited_by_value UUID;
BEGIN
    width = 0.875;

    IF NOT ST_Equals(OLD.geom, NEW.geom)
    THEN
        aux_gr_geom = ST_Buffer(NEW.geom, width, 'side=right');

        -- Query para gis.cw_sewer_box
        dynamic_query = 'SELECT * FROM ' || quote_ident(TG_TABLE_SCHEMA) || '.cw_sewer_box WHERE ST_overlaps($1, layout_geom)';
        FOR current_node IN EXECUTE dynamic_query USING aux_gr_geom
        LOOP
            aux_gr_geom = (SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
        END LOOP;

        -- Query para gis.cw_pole
        dynamic_query = 'SELECT * FROM ' || quote_ident(TG_TABLE_SCHEMA) || '.cw_pole WHERE ST_overlaps($1, layout_geom)';
        FOR current_node IN EXECUTE dynamic_query USING aux_gr_geom
        LOOP
            aux_gr_geom = (SELECT ST_Difference(aux_gr_geom, current_node.layout_geom));
        END LOOP;

        EXECUTE format('SELECT edited_by FROM %I.cw_skyway WHERE id = $1', schema_name)
        INTO edited_by_value
        USING OLD.id;

        -- Update en gis.cw_skyway
        dynamic_query = 'UPDATE ' || quote_ident(TG_TABLE_SCHEMA) || '.cw_skyway ' ||
                        'SET id_gis = CONCAT(''cw_skyway_'', $1::text), layout_geom = $2 ' ||
                        'WHERE id = $3';
        EXECUTE dynamic_query USING NEW.id_auto, aux_gr_geom, NEW.id;
    END IF;

    IF OLD.id_auto IS NOT NULL AND edited_by_value IS NOT NULL AND action_text IS NOT NULL THEN
        -- Guardar nuevo record_time en saved_changes usando CURRENT_TIMESTAMP
        EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, $4)', schema_name)
        USING OLD.id, CONCAT('cw_skyway_', OLD.id_auto::TEXT), edited_by_value, action_text;
    END IF;
        
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;



CREATE TRIGGER skyway_update_trigger
	AFTER UPDATE ON objects.cw_skyway
	FOR EACH ROW EXECUTE PROCEDURE skyway_update_trigger();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--SPLICE
CREATE TABLE objects.fo_splice(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
	id_gis VARCHAR,
	geom geometry(POINT,3857),
	layout_geom geometry(POLYGON,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


CREATE OR REPLACE FUNCTION generate_fo_splice_json() RETURNS JSONB AS
$$
DECLARE
    json_data JSONB;
BEGIN
    -- Generar el JSON con los campos especificados
    json_data := jsonb_build_object(
        'asset', ARRAY['Acquired', 'Unknown', 'Use Project Default', 'Owned', 'Third party'],
        'estado_construccion', ARRAY['Abandonned', 'Deleted', 'Unknown', 'In Service', 'In Construction', 'Installed In Place', 'Planned', 'Proposed', 'Reserved']
    );
    RETURN json_data;
END;
$$
LANGUAGE plpgsql;

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
    radians_to_rotate FLOAT;
    cb_rec RECORD;
    pole_count INT;
    splice_count INT;
    dest_schema TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    update_query TEXT;
    query_merge_value TEXT;
    query_rollback TEXT;
    -- Variable para almacenar la query de actualización
BEGIN    
    RAISE NOTICE 'Inicio de la función fo_splice_insert';
    RAISE NOTICE 'Esquema actual: %', dest_schema;

    RAISE NOTICE 'Geom de NEW: %', NEW.geom;

    edited_by_value := NEW.edited_by;

    query_merge_value := format('SELECT insert_object(%L, %L, %L, %L)',
                                top_schema, 'fo_splice', NEW.geom, edited_by_value);

    EXECUTE format('
        SELECT id_gis
        FROM %I.cw_connectivity_box
        WHERE ST_Intersects(geom, $1)
    ', dest_schema) INTO id_cb
    USING NEW.geom;

    RAISE NOTICE 'ID de la caja de conectividad después de la intersección: %', id_cb;
    RAISE NOTICE 'Esquema actual: %', dest_schema;

    IF id_cb IS NULL THEN
        RAISE NOTICE 'No se encontró caja de conectividad para la geometría dada.';
        RETURN NEW;
    END IF;

    EXECUTE format('
        SELECT * 
        FROM %I.cw_connectivity_box 
        WHERE ST_Intersects(geom, $1)
    ', dest_schema) INTO cb_rec
    USING NEW.geom;

    RAISE NOTICE 'Caja de conectividad encontrada: %', cb_rec;
    RAISE NOTICE 'Esquema actual: %', dest_schema;

    -- Se obtiene la diagonal de la caja de conectividad
    EXECUTE format('
        SELECT diagonal_geom 
        FROM %I.cw_connectivity_box 
        WHERE id_gis = $1
    ', dest_schema) INTO splice_line
    USING id_cb;

    RAISE NOTICE 'Línea de empalme: %', splice_line;

    IF splice_line IS NULL THEN
        RAISE NOTICE 'Línea de empalme es NULL, terminando ejecución';
        RETURN NEW;
    END IF;

    RAISE NOTICE 'Esquema actual: %', dest_schema;

    -- Se divide la línea en 10 puntos (Máximo de empalmes que habrá en cada pozo)
    splice_points := ST_LineInterpolatePoints(ST_Linemerge(splice_line), 0.1);

    RAISE NOTICE 'Puntos de empalme: %', splice_points;

    -- Se obtienen puntos para generar líneas y así poder obtener los radianes de giro que tiene que girar el empalme
    EXECUTE format('
        SELECT ST_StartPoint(ST_ExteriorRing(layout_geom)) 
        FROM %I.cw_connectivity_box 
        WHERE id_gis = $1
    ', dest_schema) INTO cb_boundary_point_1
    USING id_cb;

    RAISE NOTICE 'Punto de límite 1: %', cb_boundary_point_1;
    
    EXECUTE format('
        SELECT ST_PointN(ST_ExteriorRing(layout_geom), 2)
        FROM %I.cw_connectivity_box 
        WHERE id_gis = $1
    ', dest_schema) INTO cb_boundary_point_2
    USING id_cb;

    RAISE NOTICE 'Punto de límite 2: %', cb_boundary_point_2;

    IF cb_boundary_point_1 IS NULL OR cb_boundary_point_2 IS NULL THEN
        RAISE NOTICE 'Puntos límite son NULL, terminando ejecución';
        RETURN NEW;
    END IF;

    RAISE NOTICE 'Esquema actual: %', dest_schema;

    line_for_radians_1 := ST_MakeLine(cb_boundary_point_1, cb_boundary_point_2);
    RAISE NOTICE 'Línea para radianes 1: %', line_for_radians_1;

    IF line_for_radians_1 IS NULL THEN
        RAISE NOTICE 'Línea para radianes 1 es NULL, terminando ejecución';
        RETURN NEW;
    END IF;

    line_for_radians_2 := ST_MakeLine(
        ST_SetSRID(ST_MakePoint(ST_X(cb_boundary_point_1), ST_Y(cb_boundary_point_2)), 3857),
        cb_boundary_point_2
    );

    RAISE NOTICE 'Línea para radianes 2: %', line_for_radians_2;

    IF line_for_radians_2 IS NULL THEN
        RAISE NOTICE 'Línea para radianes 2 es NULL, terminando ejecución';
        RETURN NEW;
    END IF;

    RAISE NOTICE 'Esquema actual: %', dest_schema;

    -- Se calcula el ángulo de giro
    radians_to_rotate := ST_Angle(line_for_radians_2, line_for_radians_1);

    IF radians_to_rotate IS NULL THEN
        RAISE NOTICE 'radians_to_rotate es NULL, algo salió mal en el cálculo';
        RETURN NEW;
    END IF;

    RAISE NOTICE 'Radianes a rotar: %', radians_to_rotate;

    -- Evaluación de la intersección con cw_pole
    EXECUTE format('SELECT count(*) FROM %I.cw_pole WHERE ST_Intersects(geom, $1)', dest_schema) INTO pole_count
    USING cb_rec.layout_geom;

    RAISE NOTICE 'Conteo de postes: %', pole_count;

    IF ST_NumGeometries(splice_points) IS NULL THEN
        RAISE NOTICE 'No se pueden iterar puntos de empalme, terminando ejecución';
        RETURN NEW;
    END IF;

    RAISE NOTICE 'Esquema actual: %', dest_schema;

    IF pole_count > 0 THEN
        -- Se revisan los puntos en los que se puede añadir el empalme y se introducen
        FOR i IN 1..(ST_NumGeometries(splice_points) / 2)
        LOOP
            RAISE NOTICE 'Iteración (primera condición): %, Geometría: %', i, (ST_NumGeometries(splice_points) / 2) - i;

            EXECUTE format('SELECT count(*) FROM %I.fo_splice WHERE ST_Intersects(ST_GeometryN($1, $2), layout_geom)', dest_schema) INTO pole_count
            USING splice_points, (ST_NumGeometries(splice_points) / 2) - i;

            RAISE NOTICE 'Pole count después de la primera comprobación: %', pole_count;

            IF pole_count = 0 THEN
                RAISE NOTICE 'Actualizando fo_splice en la primera condición';
                RAISE NOTICE 'splice_points: %', splice_points;
                RAISE NOTICE 'i: %', i;
                RAISE NOTICE 'Geometría utilizada: %', ST_GeometryN(splice_points, (ST_NumGeometries(splice_points) / 2) - i);
                RAISE NOTICE 'radians_to_rotate: %', radians_to_rotate;
                RAISE NOTICE 'NEW.id_auto: %', NEW.id_auto;
                RAISE NOTICE 'NEW.id: %', NEW.id;

                -- Construir la query de actualización y almacenarla en la variable
                update_query := format('
                    UPDATE %I.fo_splice
                    SET layout_geom = ST_Rotate(ST_Buffer(ST_GeometryN(%L, %L), 0.175, ''endcap=square''), -%s, ST_Centroid(ST_GeometryN(%L, %L))),
                        id_gis = CONCAT(''fo_splice_'', %L::text)
                    WHERE id = %L
                ', dest_schema, splice_points, (ST_NumGeometries(splice_points) / 2) - i, radians_to_rotate, splice_points, (ST_NumGeometries(splice_points) / 2) - i, NEW.id_auto, NEW.id);

                EXECUTE update_query;

                EXIT;
            END IF;

            RAISE NOTICE 'Iteración (segunda condición): %, Geometría: %', i, (ST_NumGeometries(splice_points) / 2) + i;

            EXECUTE format('SELECT count(*) FROM %I.fo_splice WHERE ST_Intersects(ST_GeometryN($1, $2), layout_geom)', dest_schema) INTO splice_count
            USING splice_points, (ST_NumGeometries(splice_points) / 2) + i;

            RAISE NOTICE 'Pole count después de la segunda comprobación: %', splice_count;

            IF splice_count = 0 THEN
                RAISE NOTICE 'Actualizando fo_splice en la segunda condición';
                RAISE NOTICE 'splice_points: %', splice_points;
                RAISE NOTICE 'i: %', i;
                RAISE NOTICE 'Geometría utilizada: %', ST_GeometryN(splice_points, (ST_NumGeometries(splice_points) / 2) + i);
                RAISE NOTICE 'radians_to_rotate: %', radians_to_rotate;
                RAISE NOTICE 'NEW.id_auto: %', NEW.id_auto;
                RAISE NOTICE 'NEW.id: %', NEW.id;

                -- Construir la query de actualización y almacenarla en la variable
                update_query := format('UPDATE %I.fo_splice
                    SET layout_geom = ST_Rotate(ST_Buffer(ST_GeometryN(%L, %L), 0.175, ''endcap=square''), -%s, ST_Centroid(ST_GeometryN(%L, %L))),
                        id_gis = CONCAT(''fo_splice_'', %L::text)
                    WHERE id = %L', dest_schema, splice_points, (ST_NumGeometries(splice_points) / 2) + i, radians_to_rotate, splice_points, (ST_NumGeometries(splice_points) / 2) + i, NEW.id_auto, NEW.id);

                EXECUTE update_query;

                EXIT;
            END IF;
        END LOOP;    
    ELSE
        -- Se revisan los puntos en los que se puede añadir el empalme y se introducen
        FOR i IN 1..ST_NumGeometries(splice_points) - 1
        LOOP
            RAISE NOTICE 'Iteración (else): %, Geometría: %', i, i;

            EXECUTE format('SELECT count(*) FROM %I.fo_splice WHERE ST_Intersects(ST_GeometryN($1, $2), layout_geom)', dest_schema) INTO pole_count
            USING splice_points, i;

            RAISE NOTICE 'Pole count después de la comprobación: %', pole_count;

            IF pole_count = 0 THEN
                RAISE NOTICE 'Actualizando fo_splice en la condición else';
                RAISE NOTICE 'splice_points: %', splice_points;
                RAISE NOTICE 'i: %', i;
                RAISE NOTICE 'Geometría utilizada: %', ST_GeometryN(splice_points, i);
                RAISE NOTICE 'radians_to_rotate: %', radians_to_rotate;
                RAISE NOTICE 'NEW.id_auto: %', NEW.id_auto;
                RAISE NOTICE 'NEW.id: %', NEW.id;

                -- Construir la query de actualización y almacenarla en la variable
                update_query := format('UPDATE %I.fo_splice
                    SET layout_geom = ST_Rotate(ST_Buffer(ST_GeometryN(%L, %L), 0.175, ''endcap=square''), -%s, ST_Centroid(ST_GeometryN(%L, %L))),
                        id_gis = CONCAT(''fo_splice_'', %L::text)
                    WHERE id = %L', dest_schema, splice_points, i, radians_to_rotate, splice_points, i, NEW.id_auto, NEW.id);

                EXECUTE update_query;

                EXIT;
            END IF;
        END LOOP;        
    END IF;

    RAISE NOTICE 'Esquema actual antes de la última comprobación: %', dest_schema;

    EXECUTE format('SELECT count(*) FROM %I.cw_pole WHERE ST_Intersects(geom, (SELECT geom FROM %I.cw_connectivity_box WHERE id_gis = $1))', dest_schema, dest_schema) INTO pole_count
    USING id_cb;

    RAISE NOTICE 'Conteo de postes después de la última comprobación: %', pole_count;

    IF pole_count > 0 THEN
        RAISE NOTICE 'Ejecutando update_pole_3d_geometry';
        PERFORM update_pole_3d_geometry(id_cb, 'objects','objects');
    END IF;

    -- Inserta en la tabla saved_changes
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3::uuid, $4)', dest_schema)
    USING NEW.id, CONCAT('fo_splice_', NEW.id_auto::TEXT), edited_by_value, query_merge_value;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;



CREATE TRIGGER fo_splice_triggger
	AFTER INSERT ON objects.fo_splice
	FOR EACH ROW EXECUTE PROCEDURE fo_splice_insert(); 

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
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);


	
CREATE OR REPLACE FUNCTION duct_insert_recursive(id_duct INTEGER, geom_ini GEOMETRY, width1 FLOAT, width2 FLOAT, schema_name TEXT) RETURNS GEOMETRY AS
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
    IF count_result = 0 THEN
        RETURN new_geom1;
    ELSE
        new_geom1 := public.duct_insert_recursive(id_duct, geom_ini, width1 + 0.0000035, width1, schema_name);
    END IF;

    RETURN new_geom1;
END;
$$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION cw_duct_insert() RETURNS trigger AS
$$
DECLARE
    new_geom GEOMETRY;
    current_node RECORD;
    width FLOAT := 0.0000035;
    schema_name TEXT;
    top_schema TEXT := 'objects';
    edited_by_value UUID;
    update_query TEXT;
    query_merge_value TEXT;
BEGIN
    -- Obtiene dinámicamente el nombre del esquema del entorno de ejecución
    schema_name := TG_TABLE_SCHEMA;
    
    edited_by_value := NEW.edited_by;

    -- Asegúrate de definir dest_schema si es necesario. Usamos schema_name aquí como ejemplo.
    query_merge_value := format('SELECT insert_object(%L, %L, %L, %L)',
                                top_schema, 'cw_duct', ST_AsText(NEW.geom), edited_by_value);

    -- Llamada recursiva para salvar la geometría que no se toque con otro ducto
    new_geom := public.duct_insert_recursive(NEW.id_auto, NEW.geom, width, 0, schema_name);

    -- Se acortan los ductos para que corten el sewer_box
    FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_sewer_box WHERE ST_overlaps($1, layout_geom)', schema_name) USING new_geom
    LOOP
        new_geom := ST_Difference(new_geom, current_node.layout_geom);
    END LOOP;

    -- Se actualiza la geometría
    update_query := format('UPDATE %I.cw_duct SET layout_geom = %L, id_gis = %L WHERE id = %L', schema_name, ST_AsText(new_geom), CONCAT('cw_duct_', NEW.id_auto::text), NEW.id);
    EXECUTE update_query;

    -- Inserta en la tabla saved_changes
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge) VALUES (%L, %L, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, %L::uuid, %L)', schema_name, NEW.id, CONCAT('cw_duct_', NEW.id_auto::TEXT), edited_by_value, query_merge_value);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



-- Creación del trigger para la tabla original
CREATE TRIGGER duct_insert_triggger
	AFTER INSERT ON objects.cw_duct
	FOR EACH ROW EXECUTE PROCEDURE cw_duct_insert();


--UPDATES DUCTOS
CREATE OR REPLACE FUNCTION cw_duct_update() RETURNS TRIGGER AS
$$
DECLARE 
    new_geom GEOMETRY;
    current_node RECORD;
    width FLOAT := 0.09;
    schema_name TEXT := TG_TABLE_SCHEMA; -- Obtener el esquema del contexto del trigger
BEGIN
    IF NOT ST_Equals(OLD.geom, NEW.geom) THEN
        new_geom := public.duct_insert_recursive(NEW.id_auto, NEW.geom, width, 0, schema_name);        

        -- Se acortan los ductos para que corten el sewer_box
        FOR current_node IN EXECUTE format('SELECT * FROM %I.cw_sewer_box WHERE ST_Overlaps($1, layout_geom)', schema_name) USING new_geom LOOP
            new_geom := (SELECT ST_Difference(new_geom, current_node.layout_geom));
        END LOOP;

        -- Se actualiza la geometría
        EXECUTE format('UPDATE %I.cw_duct SET layout_geom = $1, id_gis = CONCAT(''cw_duct_'', $2::text) WHERE id = $3', schema_name)
        USING new_geom, NEW.id_auto, NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER duct_update_triggger
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
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(LINESTRING,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE OR REPLACE FUNCTION create_fo_fiber(
    edited_by UUID, 
    cable_id INT,
    cable_geom GEOMETRY, 
    n_fibers INTEGER, 
    schema_name TEXT
) RETURNS void
AS
$$
DECLARE
    width FLOAT;
    new_geom GEOMETRY;
    new_geom_aux GEOMETRY;
    insert_query TEXT;
BEGIN
    -- Crea una cantidad de fibras asociadas a un cable
    width := 0.0000375;
    new_geom := cable_geom;

    FOR i IN 1..n_fibers LOOP
        new_geom_aux := ST_OffsetCurve(new_geom, -width * i, 'quad_segs=4 join=mitre mitre_limit=2.2');

        IF ST_Distance(ST_StartPoint(cable_geom), ST_StartPoint(new_geom_aux)) > 0.006 THEN
            new_geom_aux := ST_Reverse(new_geom_aux);
        END IF;

        -- Construye la consulta INSERT para fo_fiber
        insert_query := format(
            'INSERT INTO %I.fo_fiber(id_cable, geom, layout_geom, edited_by) VALUES (%L, %L::geometry, %L::geometry, %L)', 
            schema_name,
            CONCAT('fo_cable_', cable_id::text),
            ST_AsText(cable_geom),
            ST_AsText(ST_Linemerge(new_geom_aux)),
            edited_by
        );

        -- RAISE NOTICE para mostrar la consulta INSERT
        RAISE NOTICE 'insert_query: %', insert_query;

        -- Ejecuta la consulta INSERT para fo_fiber
        EXECUTE insert_query;
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
    FOR current_fiber IN EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1', schema_name) USING id_gis_cable
    LOOP
        new_geom_aux := ST_LineMerge(ST_OffsetCurve(cable_geom, -width, 'quad_segs=4 join=mitre mitre_limit=2.2'));

        IF ST_Distance(ST_StartPoint(cable_geom), ST_StartPoint(new_geom_aux)) > 0.006 THEN
            new_geom_aux := ST_Reverse(new_geom_aux);
        END IF;

        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = $1, source = null, target = null WHERE id_gis = $2', schema_name)
        USING new_geom_aux, current_fiber.id_gis;

        width := width + 0.0000375;
    END LOOP;
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


CREATE TRIGGER fo_fiber_insert_triggger
	AFTER INSERT ON objects.fo_fiber
	FOR EACH ROW EXECUTE PROCEDURE fo_fiber_insert();



CREATE OR REPLACE FUNCTION update_fiber_topology(schema_name TEXT) RETURNS void
AS
$$
DECLARE
    topology_table TEXT;
    fiber_table TEXT;
BEGIN
    -- Obtener el esquema dinámicamente desde la tabla fo_fiber
    SELECT table_schema INTO schema_name
    FROM information_schema.tables
    WHERE table_name = 'fo_fiber';

    IF schema_name IS NOT NULL THEN
        topology_table := schema_name || '.fo_fiber_vertices_pgr';
        fiber_table := schema_name || '.fo_fiber';

        -- Verificar si la tabla de vértices existe en el esquema dinámico
        IF (SELECT count(*) FROM information_schema.tables WHERE table_schema = schema_name AND table_name = 'fo_fiber_vertices_pgr') > 0 THEN
            -- Crear la topología para la tabla de fibras
            EXECUTE format('PERFORM pgr_CreateTopology(%L, %L, %L, %L)', fiber_table, 0.000025, 'layout_geom', 'id');

            -- Eliminar vértices no conectados
            EXECUTE format('
                DELETE FROM %I
                WHERE id NOT IN (
                    SELECT source FROM %I
                    UNION
                    SELECT target FROM %I
                )',
                topology_table, fiber_table, fiber_table);
        END IF;
    END IF;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--PUERTOS
CREATE TABLE objects.puerto (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    geom GEOMETRY(POINT, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

CREATE TABLE objects.in_port (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    geom GEOMETRY(POINT, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID,
    locked_by UUID REFERENCES security.users(id)
);


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


/*markdown
CRACIÓN DE SPLITTER
*/

CREATE TABLE objects.optical_splitter (
    id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
    id_gis VARCHAR,
    geom GEOMETRY(LINESTRING, 3857),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);

-- Metodo para insertar optical_splitters

CREATE OR REPLACE FUNCTION optical_splitter_insert_func(id_gis_splice VARCHAR, n_puertos_salida INTEGER, dest_schema TEXT) RETURNS void
AS
$$
DECLARE
    fo_splice RECORD;
    aux_offset_line GEOMETRY;
    aux_offset_line_ori GEOMETRY;
    splitter_geom GEOMETRY;
    n_fibers_crossed INTEGER;
    width FLOAT;
    edited_by UUID;
BEGIN
    width := 0.0000375;

    -- Dynamically select from the schema
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', dest_schema)
    INTO fo_splice
    USING id_gis_splice;

    -- Get the edited_by value from fo_splice
    edited_by := fo_splice.edited_by;

    -- Get the number of fibers crossed within the splice
    EXECUTE format('SELECT count(*) FROM %I.fo_fiber WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.005', dest_schema)
    INTO n_fibers_crossed
    USING fo_splice.layout_geom;

    aux_offset_line_ori := ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice.layout_geom) WHERE path[2] = 2),
                                       (SELECT geom FROM ST_DumpPoints(fo_splice.layout_geom) WHERE path[2] = 3));

    -- Depending on the fibers that have already entered the splice, use a different offset line
    FOR i IN 0..1000 LOOP
        aux_offset_line := ST_OffsetCurve(aux_offset_line_ori, -width * (1000 + i), 'quad_segs=4 join=round');
        EXECUTE format('SELECT count(*) FROM %I.in_port WHERE ST_Distance($1, geom) < 0.000025', dest_schema)
        INTO n_fibers_crossed
        USING aux_offset_line;
        IF n_fibers_crossed < 1 THEN
            EXECUTE format('SELECT count(*) FROM %I.out_port WHERE ST_Distance($1, geom) < 0.000025', dest_schema)
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
    EXECUTE format('INSERT INTO %I.optical_splitter(geom, edited_by) VALUES ($1, $2)', dest_schema)
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
BEGIN
    id_gis_splitter := CONCAT('optical_splitter_', NEW.id_auto::text);

    -- Actualiza el id_gis en optical_splitter
    EXECUTE format('UPDATE %I.optical_splitter SET id_gis = $1 WHERE id = $2', dest_schema)
    USING id_gis_splitter, NEW.id;

    -- Selecciona el edited_by de optical_splitter
    EXECUTE format('SELECT edited_by FROM %I.optical_splitter WHERE id = $1', dest_schema)
    INTO edited_by
    USING NEW.id;

    -- Verifica si el valor de edited_by se obtuvo correctamente
    IF edited_by IS NULL THEN
        RAISE EXCEPTION 'edited_by es NULL. Verifica la tabla optical_splitter.';
    END IF;

    -- Se crea el puerto de entrada
    EXECUTE format('INSERT INTO %I.in_port(geom, edited_by) VALUES((SELECT geom FROM ST_DumpPoints($1) WHERE path[1] = 1), $2)', dest_schema)
    USING NEW.geom, edited_by;

    -- Se crean los puertos de salida y cables auxiliares para conectar fibras
    FOR i IN 2..(SELECT count(*) FROM ST_DumpPoints(NEW.geom))
    LOOP
        EXECUTE format('INSERT INTO %I.out_port(geom, edited_by) VALUES((SELECT geom FROM ST_DumpPoints($1) WHERE path[1] = $2), $3)', dest_schema)
        USING NEW.geom, i, edited_by;

        -- Descomentar si es necesario llamar a `create_fo_splitter_fiber`
        -- EXECUTE format('SELECT create_fo_splitter_fiber($1, ST_MakeLine(ST_StartPoint($2), (SELECT geom FROM ST_DumpPoints($2) WHERE path[1] = $3)))', dest_schema)
        -- USING id_gis_splitter, NEW.geom, i;
    END LOOP;

    -- Insertamos en la tabla saved_changes los cambios de in_port
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, $4)', dest_schema)
    USING NEW.id, CONCAT('in_port_', NEW.id_auto::TEXT), edited_by, action_text;

    -- Insertamos en la tabla saved_changes los cambios de out_port
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, $4)', dest_schema)
    USING NEW.id, CONCAT('out_port_', NEW.id_auto::TEXT), edited_by, action_text;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER optical_splitter_insert_trigggger
    AFTER INSERT ON objects.optical_splitter
    FOR EACH ROW EXECUTE PROCEDURE optical_splitter_insert();

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


--CABLES
CREATE TABLE objects.fo_cable(
	id uuid DEFAULT gen_random_uuid(),
    id_auto SERIAL,
	id_gis VARCHAR,
	id_duct VARCHAR,
	source INTEGER,
	target INTEGER,
	geom geometry(LINESTRING,3857),
	layout_geom geometry(LINESTRING,3857),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edited_by UUID REFERENCES security.users(id),
    locked_by UUID REFERENCES security.users(id)
);
CREATE OR REPLACE FUNCTION fo_cable_insert() RETURNS trigger AS
$$
DECLARE 
    dest_schema TEXT := TG_TABLE_SCHEMA;
    top_schema TEXT := 'objects';
    new_geom GEOMETRY;
    update_query TEXT;
    edited_by_value UUID;
    query_merge_value TEXT;
    query_rollback TEXT;
BEGIN
    -- Llamada recursiva para obtener una ubicación que no corte ningún cable
    IF (SELECT count(*) FROM ST_DumpPoints(NEW.geom)) > 2 THEN
        new_geom := public.fo_cable_pass_by_insert(dest_schema, NEW.geom, NEW.id_duct);
    ELSE
        new_geom := public.fo_cable_insert_recursive(NEW.geom, NEW.id_duct);
    END IF;

    -- Construye la sentencia UPDATE con el esquema dinámico
    update_query := format('
        UPDATE %I.fo_cable
        SET layout_geom = %L,
            id_gis = %L
        WHERE id = %L
    ', dest_schema, ST_AsText(new_geom), CONCAT('fo_cable_', NEW.id_auto::text), NEW.id);

    -- RAISE NOTICE para mostrar la consulta UPDATE
    RAISE NOTICE 'update_query: %', update_query;

    -- Ejecuta la sentencia UPDATE
    EXECUTE update_query;

    -- Obtén el valor de edited_by
    edited_by_value := NEW.edited_by;

    RAISE NOTICE 'edited_by_value: %', edited_by_value;

    query_merge_value := format('SELECT insert_object(%L, %L, %L, %L)',
                                top_schema, 'fo_cable', ST_AsText(NEW.geom), edited_by_value);					

    -- Llama a la función que inserta las fibras con los parámetros individuales
    PERFORM create_fo_fiber(
        edited_by_value, 
        NEW.id_auto, 
        new_geom, 
        144, 
        dest_schema
    );

    -- Inserta en la tabla saved_changes
    EXECUTE format('INSERT INTO %I.saved_changes(id, id_gis, change_time, record_time, user_id, query_merge) VALUES (%L, %L, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, %L::uuid, %L)', 
                   dest_schema, NEW.id, CONCAT('fo_cable_', NEW.id_auto::TEXT), edited_by_value, query_merge_value);
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION fo_cable_pass_by_insert(
    schema_name TEXT,
    current_geom GEOMETRY,
    id_duct VARCHAR
) RETURNS GEOMETRY AS
$$
DECLARE 
    width FLOAT;
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
    width := 0.0125;

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
                previous_cable_section_layout := fo_cable_insert_recursive(previous_cable_section, ducts_array[i - 1]);
            ELSE
                previous_cable_section_layout := fo_cable_insert_recursive(previous_cable_section, null);
            END IF;
        END IF;

        IF ducts_array[i] IS NOT NULL THEN
            actual_cable_section_layout := fo_cable_insert_recursive(actual_cable_section, ducts_array[i]);
        ELSE
            actual_cable_section_layout := fo_cable_insert_recursive(actual_cable_section, null);
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




CREATE OR REPLACE FUNCTION fo_cable_update() RETURNS trigger AS
$$
DECLARE 
    new_geom GEOMETRY;
    current_fiber RECORD;
    cont INTEGER;
    width FLOAT;
    schema_name TEXT := TG_TABLE_SCHEMA;
BEGIN
    -- Obtener el esquema de la tabla donde se ejecutó el disparador    
    IF NOT ST_Equals(OLD.geom, NEW.geom) THEN
        width := 0.0000375;

        IF (SELECT count(*) FROM ST_DumpPoints(NEW.geom)) > 2 THEN
            -- Se elimina el EXECUTE de fo_cable_pass_by_insert
            -- new_geom := public.fo_cable_insert_recursive(NEW.geom, NEW.id_duct);     
            new_geom := public.fo_cable_pass_by_insert(schema_name, NEW.geom, NEW.id_duct);
        ELSE
            new_geom := public.fo_cable_insert_recursive(NEW.geom, NEW.id_duct);           
        END IF;

        EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_LineMerge($1) WHERE id = $2', schema_name) USING new_geom, NEW.id;

        cont := 1;

        FOR current_fiber IN EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_cable = $1 ORDER BY id_gis', schema_name) USING OLD.id_gis
        LOOP
            EXECUTE format('UPDATE %I.fo_fiber SET geom = $1, layout_geom = ST_OffsetCurve($2, -$3 * $4, ''quad_segs=4 join=mitre mitre_limit=2.2''), source = null, target = null WHERE id = $5', schema_name) 
            USING NEW.geom, new_geom, width, cont, current_fiber.id;
            cont := cont + 1;
        END LOOP;
    END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER fo_cable_update_triggger
	AFTER UPDATE ON objects.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_update();


CREATE OR REPLACE FUNCTION public.fo_cable_insert_recursive(
    IN current_geom geometry,
    IN id_duct character varying
)
RETURNS geometry
LANGUAGE plpgsql
AS $$
DECLARE 
    new_geom GEOMETRY;
    new_geom_aux GEOMETRY;
    current_cbox_node RECORD;
BEGIN
    -- En el caso en el que el cable vaya por fuera de ducto
    IF id_duct IS NULL THEN
        new_geom := ST_OffsetCurve(current_geom, -0.000002, 'quad_segs=4 join=round');
        new_geom_aux := new_geom;

        -- Se busca si coinciden las geometrías una vez se hayan acortado
        FOR current_cbox_node IN 
            SELECT * FROM objects.cw_connectivity_box AS cb 
            WHERE ST_Intersects(new_geom_aux, cb.layout_geom)
        LOOP
            new_geom_aux := ST_Difference(new_geom_aux, current_cbox_node.layout_geom);
        END LOOP;

        -- En el caso en el que ya haya un cable por esa ruta se llama al método recursivo
        IF (SELECT COUNT(*) FROM objects.fo_cable WHERE ST_Intersects(new_geom_aux, layout_geom)) > 0 THEN 
            new_geom := public.fo_cable_insert_recursive(new_geom, id_duct);
        END IF;

    ELSE
        -- En el caso en el que el cable vaya por dentro de ducto
        new_geom := ST_OffsetCurve(current_geom, 0.0000003, 'quad_segs=4 join=round');
        new_geom_aux := new_geom;

        -- Se busca si coinciden las geometrías una vez se hayan acortado
        FOR current_cbox_node IN 
            SELECT * FROM objects.cw_connectivity_box AS cb 
            WHERE ST_Intersects(new_geom_aux, cb.layout_geom)
        LOOP
            new_geom_aux := ST_Difference(new_geom_aux, current_cbox_node.layout_geom);
        END LOOP;

        -- En el caso en el que ya haya un cable por esa ruta se llama al método recursivo
        IF ST_Intersects((SELECT layout_geom FROM objects.cw_duct WHERE id_gis = id_duct), new_geom) AND 
           (SELECT COUNT(*) FROM objects.fo_cable WHERE ST_Intersects(new_geom_aux, layout_geom)) > 0 THEN
            new_geom := public.fo_cable_insert_recursive(new_geom, id_duct);
        END IF;
    END IF;  

    -- Se acorta la geometría para que no vaya por dentro de la connectivity_box y se devuelve
    FOR current_cbox_node IN 
        SELECT * FROM objects.cw_connectivity_box AS cb 
        WHERE ST_Intersects(new_geom, cb.layout_geom)
    LOOP
        new_geom := ST_Difference(new_geom, current_cbox_node.layout_geom);
    END LOOP;

    RETURN new_geom;
END;
$$;


CREATE TRIGGER fo_cable_insert_triggger
	AFTER INSERT ON objects.fo_cable
	FOR EACH ROW EXECUTE PROCEDURE fo_cable_insert();		


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION connect_cable(id_gis_cable VARCHAR, id_gis_splice VARCHAR, schema_name VARCHAR) RETURNS void
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
    current_distance := 0;
    width := 0.0125;
    
    -- Se obtienen los registros necesarios (cable, empalme y conectivity_box)
    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_rec USING id_gis_cable;
    EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO splice_rec USING id_gis_splice;
    EXECUTE format('SELECT * FROM %I.cw_connectivity_box WHERE ST_Contains(layout_geom, $1)', schema_name, schema_name) INTO cb_rec USING splice_rec.layout_geom;
	
	RAISE NOTICE 'Número de geometrías en cable_rec: %', cable_rec;
	
	RAISE NOTICE 'Número de geometrías en splice_rec: %', splice_rec;

	RAISE NOTICE 'Número de geometrías en connectivity_box: %', cb_rec;


    -- Se genera la linea que conecta el cable cortado en la caja de conexiones con el empalme.
    intersection_point := ST_ClosestPoint(cable_rec.layout_geom, cb_rec.layout_geom);
	
	RAISE NOTICE 'Número de geometrías en intersect: %', intersection_point;

    -- Se obtiene la cara del connectivity_box por el que entra ese cable
    face_1 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 1), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 2));
    face_2 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 2), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 3));
    face_3 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 3), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 4));
    face_4 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 4), (SELECT geom FROM ST_DumpPoints(cb_rec.layout_geom) WHERE path[2] = 5));
	
	RAISE NOTICE 'Número de geometrías en splice_face_1: %', face_1;

    RAISE NOTICE 'Número de geometrías en splice_face_2: %', face_2;

    RAISE NOTICE 'Número de geometrías en splice_face_3: %', face_3;

    RAISE NOTICE 'Número de geometrías en splcie_face_4: %', face_4;
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
	
	
	RAISE NOTICE 'Número de geometrías en closest_face: %', clossest_face;


    splice_face_1 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 1), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 2));
    splice_face_2 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 2), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 3));
    splice_face_3 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 3), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 4));
    splice_face_4 := ST_MakeLine((SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 4), (SELECT geom FROM ST_DumpPoints(splice_rec.layout_geom) WHERE path[2] = 5));
	
	RAISE NOTICE 'Número de geometrías en splice_face_1: %', splice_face_1;

    RAISE NOTICE 'Número de geometrías en splice_face_2: %', splice_face_2;

    RAISE NOTICE 'Número de geometrías en splice_face_3: %', splice_face_3;

    RAISE NOTICE 'Número de geometrías en splcie_face_4: %', splice_face_4;

    RAISE NOTICE 'Número de geometrías en closest_splice: %', clossest_splice_face;

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

    RAISE NOTICE 'Número de geometrías en closest_splice: %', clossest_splice_face;

    -- Por distancias a la cara por la que entra el cable se saca la cara del sheath_splice mas cercana a la cara del connectivity_box
    face_points := (SELECT ST_LineInterpolatePoints(clossest_splice_face, 0.07, true));

    RAISE NOTICE 'Número de geometrías en face_points: %', face_points;

    -- Se obtienen la cantidad de cables que han pasado dentro de la connectivity_box para saber que ruta deberá coger el nuevo cable
    EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Length(ST_Intersection(layout_geom, $1)) > 0.0005 AND ST_Intersects(layout_geom, $2)', schema_name) INTO n_cables_crossing USING cb_rec.layout_geom, clossest_face;

    IF n_cables_crossing < 20 THEN
        -- Se genera el camino que seguirá el cable
        clossest_face := ST_OffsetCurve(clossest_face, -width * (n_cables_crossing + 1), 'quad_segs=4 join=mitre mitre_limit=2.2');

        RAISE NOTICE 'Número de geometrías en face_points: %', ST_NumGeometries(face_points);

        -- Dependiendo de si es un cable de entrada o salida se genera la línea de conexión en una dirección u otra
        FOR i IN REVERSE 12..ST_NumGeometries(face_points)-12 LOOP
            EXECUTE format('SELECT count(*) FROM %I.fo_cable WHERE ST_Distance(ST_GeometryN($1, $2), layout_geom) < 0.0005', schema_name) INTO dist USING face_points, i;
			IF dist = 0
            THEN
                IF ST_Distance(ST_EndPoint(cable_rec.layout_geom), cb_rec.layout_geom) < 0.0005 THEN
                    aux_line_guitar_splice := ST_ShortestLine(clossest_face, ST_GeometryN(face_points, i));
                    aux_line_cable_guitar := ST_ShortestLine(cable_rec.layout_geom, clossest_face);
                    EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_LineMerge(ST_MakeLine(ST_MakeLine(ST_MakeLine($1, $2), ST_ShortestLine($2, $3)), $3)) WHERE id_gis = $4', schema_name) USING cable_rec.layout_geom, aux_line_cable_guitar, aux_line_guitar_splice, id_gis_cable;
                    EXIT;
                ELSE	
                    aux_line_guitar_splice := ST_ShortestLine(ST_GeometryN(face_points, i), clossest_face);
                    aux_line_cable_guitar := ST_ShortestLine(clossest_face, cable_rec.layout_geom);
                    EXECUTE format('UPDATE %I.fo_cable SET layout_geom = ST_LineMerge(ST_MakeLine($1, ST_MakeLine(ST_ShortestLine($1, $2), ST_MakeLine($2, $3)))) WHERE id_gis = $4', schema_name) USING aux_line_guitar_splice, aux_line_cable_guitar, cable_rec.layout_geom, id_gis_cable;
                    EXIT;
                END IF;
            END IF;
        END LOOP;
    END IF;

    EXECUTE format('SELECT * FROM %I.fo_cable WHERE id_gis = $1', schema_name) INTO cable_rec USING id_gis_cable;
    -- Llamada a la función update_fo_fiber_to_splice para actualizar las fibras del cable al empalme
EXECUTE format('SELECT public.update_fo_fiber_to_splice($1, $2, $3)', schema_name, cable_rec.id_gis, cable_rec.layout_geom) USING  schema_name, cable_rec.id_gis, cable_rec.layout_geom;
END;
$$
LANGUAGE plpgsql;


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--FUNCIÓN PARA CONECTAR FIBRAS
CREATE OR REPLACE FUNCTION connect_fiber(
    id_gis_fiber1 VARCHAR, 
    id_gis_fiber2 VARCHAR, 
    schema_name VARCHAR
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
    width FLOAT;
    dist_start1 FLOAT;
    dist_end2 FLOAT;
    dist_start2 FLOAT;
    dist_end1 FLOAT;
BEGIN
    -- Obtiene la distancia mínima entre las fibras y el empalme
    width = 0.0000375;
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

    -- Si las caras se intersectan, ajustar las fibras
    IF ST_Intersects(closest_output_face, closest_input_face) THEN
        -- Punto de intersección de las caras
        faces_intersection_point := ST_Intersection(closest_output_face, closest_input_face);
        
        RAISE NOTICE 'Faces intersection point: %', faces_intersection_point;
        RAISE NOTICE 'Faces input_fiber_point: %', input_fiber_point;
        RAISE NOTICE 'Closest input face: %', closest_input_face;

        -- Línea desde la fibra de entrada hasta la cara
        input_fiber_to_face := ST_ShortestLine(input_fiber_point, closest_input_face);
        -- Línea desde la intersección de la fibra y la cara hasta el punto de intersección de las caras
        input_face_to_intersection_point := ST_ShortestLine(input_fiber_to_face, faces_intersection_point);
        -- Actualizar geometría de la fibra de entrada
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom=ST_LineMerge(ST_MakeLine(ST_MakeLine(layout_geom, $1), $2)) WHERE id_gis=$3', schema_name) USING input_fiber_to_face, input_face_to_intersection_point, input_fiber.id_gis;
        
        -- Línea desde la fibra de salida hasta la cara
        output_fiber_to_face := ST_ShortestLine(closest_output_face, output_fiber_point);
        -- Línea desde el punto de intersección de las caras hasta la fibra de salida
        output_face_to_intersection_point := ST_ShortestLine(faces_intersection_point, output_fiber_to_face);
        -- Actualizar geometría de la fibra de salida
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom=ST_LineMerge(ST_MakeLine(ST_MakeLine($1, layout_geom), $2)) WHERE id_gis=$3', schema_name) USING output_face_to_intersection_point, output_fiber_to_face, output_fiber.id_gis;
    ELSE
        -- Obtener la segunda cara más cercana al punto de salida
        SELECT face
        INTO second_closest_output_face
        FROM (
            SELECT unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
                   ST_Distance(unnest(ARRAY[face_1, face_2, face_3, face_4]), output_fiber_point) AS distance
        ) AS distances
        WHERE face <> closest_output_face
        ORDER BY distance
        LIMIT 1;

        -- Punto de intersección entre la cara más cercana y la segunda cara más cercana
        output_faces_intersection_point := ST_Intersection(closest_output_face, second_closest_output_face);
        -- Línea entre los dos puntos de intersección
        output_faces_line := ST_ShortestLine(faces_intersection_point, output_faces_intersection_point);
        -- Línea desde el punto de intersección de las caras hasta la cara más cercana
        output_faces_line_to_face := ST_ShortestLine(output_faces_intersection_point, second_closest_output_face);

        -- Actualizar geometría de la fibra de entrada
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom=ST_LineMerge(ST_MakeLine(ST_MakeLine(layout_geom, $1), $2)) WHERE id_gis=$3', schema_name) USING input_fiber_to_face, output_faces_line, input_fiber.id_gis;
        -- Actualizar geometría de la fibra de salida
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom=ST_LineMerge(ST_MakeLine(ST_MakeLine($1, layout_geom), $2)) WHERE id_gis=$3', schema_name) USING output_faces_line, output_faces_line_to_face, output_fiber.id_gis;
    END IF;
END;
$$ LANGUAGE plpgsql;



---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--FUNCIÓN PARA CONECTAR FIBRAS Y PUERTOS
CREATE OR REPLACE FUNCTION connect_fiber_port(schema_name TEXT, id_gis_fiber VARCHAR, id_gis_port VARCHAR) RETURNS void
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
    n_guitar_lines INTEGER;
    width FLOAT;
    port_count INTEGER;
BEGIN
    width := 0.0000375;
    n_guitar_lines := 1000;

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

    -- Manejar las asignaciones nulas
    IF input_fiber_point IS NULL THEN
        RAISE EXCEPTION 'El punto de entrada de la fibra es NULL';
    END IF;

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
        EXECUTE format('UPDATE %I.fo_fiber SET layout_geom=$1, source=NULL, target=NULL WHERE id_gis=$2', schema_name) USING new_output_geom, output_fiber.id_gis;
    END IF;
END;
$$
LANGUAGE plpgsql;



---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION store_cb_connections(schema_name TEXT, cb_record RECORD) RETURNS void AS
$$
DECLARE
    current_cable_record RECORD;
    current_splice_record RECORD;
    current_fiber_node RECORD;
    current_input_fiber RECORD;
    current_output_fiber RECORD;
    sql TEXT;
    count_var INTEGER;
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
        EXECUTE format('SELECT * FROM %I.fo_cable WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) 
        USING cb_record.layout_geom
    LOOP
        -- Obtener empalmes dentro de cada cable
        FOR current_splice_record IN 
            EXECUTE format('SELECT * FROM %I.fo_splice WHERE ST_Distance(layout_geom, $1) < 0.00003', schema_name) 
            USING current_cable_record.layout_geom
        LOOP
            -- Obtener nodos de fibra dentro de los empalmes
            FOR current_fiber_node IN 
                EXECUTE format('SELECT * FROM %I.fo_fiber_vertices_pgr WHERE ST_Contains($1, the_geom) AND NOT ST_DWithin(the_geom, ST_Boundary($1), 1e-9)', schema_name) 
                USING current_splice_record.layout_geom
            LOOP
                EXECUTE format('SELECT * FROM %I.fo_fiber WHERE target = $1', schema_name) 
                INTO current_input_fiber 
                USING current_fiber_node.id;

                EXECUTE format('SELECT * FROM %I.fo_fiber WHERE source = $1', schema_name) 
                INTO current_output_fiber 
                USING current_fiber_node.id;
                
                -- Conexiones fibra-puerto
                EXECUTE format('SELECT count(*) FROM %I.in_port WHERE ST_Distance(geom, $1) < 0.000003', schema_name)
                INTO count_var
                USING current_fiber_node.the_geom;

                IF count_var > 0 THEN
                    EXECUTE format('SELECT count(*) FROM fiber_port_connectivity WHERE id_gis_fiber_1 = $1')
                    INTO count_var
                    USING current_input_fiber.id_gis;

                    IF count_var > 0 THEN
                        CONTINUE;
                    END IF;

                    EXECUTE format('INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port, id_splice) VALUES ($1, (SELECT id_gis FROM %I.in_port WHERE ST_Distance(geom, $2) < 0.000003), $3)', schema_name)
                    USING current_input_fiber.id_gis, current_fiber_node.the_geom, current_splice_record.id_gis;
                ELSE
                    EXECUTE format('SELECT count(*) FROM %I.out_port WHERE ST_Distance(geom, $1) < 0.000003', schema_name)
                    INTO count_var
                    USING current_fiber_node.the_geom;

                    IF count_var > 0 THEN
                        EXECUTE format('SELECT count(*) FROM fiber_port_connectivity WHERE id_gis_fiber_1 = $1')
                        INTO count_var
                        USING current_output_fiber.id_gis;

                        IF count_var > 0 THEN
                            CONTINUE;
                        END IF;

                        EXECUTE format('INSERT INTO fiber_port_connectivity(id_gis_fiber_1, id_gis_port, id_splice) VALUES ($1, (SELECT id_gis FROM %I.out_port WHERE ST_Distance(geom, $2) < 0.000003), $3)', schema_name)
                        USING current_output_fiber.id_gis, current_fiber_node.the_geom, current_splice_record.id_gis;
                    ELSE
                        -- Conexiones fibra-fibra
                        EXECUTE format('SELECT count(*) FROM fiber_connectivity WHERE id_gis_fiber_1 = $1 OR id_gis_fiber_2 = $2')
                        INTO count_var
                        USING current_output_fiber.id_gis, current_input_fiber.id_gis;

                        IF count_var > 0 THEN
                            CONTINUE;
                        END IF;

                        INSERT INTO fiber_connectivity(id_gis_fiber_1, id_gis_fiber_2, id_splice) VALUES (
                            current_output_fiber.id_gis,
                            current_input_fiber.id_gis,
                            current_splice_record.id_gis
                        );
                    END IF;
                END IF;
            END LOOP;
            
            -- Conexiones de cable con empalme
            IF ST_Distance(current_splice_record.layout_geom, current_cable_record.layout_geom) < 0.00003 THEN
                INSERT INTO cable_connectivity(id_gis_cable, id_gis_splice) VALUES (current_cable_record.id_gis, current_splice_record.id_gis);
            END IF;

            EXECUTE format('UPDATE %I.fo_fiber SET layout_geom = ST_Difference(layout_geom, $1), source=null, target=null WHERE ST_Intersects(layout_geom, $1)', schema_name)
            USING current_splice_record.layout_geom;
        END LOOP;
    END LOOP;
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


CREATE OR REPLACE FUNCTION update_stored_conections(schema_name TEXT) RETURNS void AS
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
    n_guitar_lines = 1000;

    FOR current_fiber_connectivity_record IN SELECT * FROM fiber_connectivity ORDER BY id_gis_fiber_2, id_splice
    LOOP
        EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO input_fiber_record USING current_fiber_connectivity_record.id_gis_fiber_2;
        EXECUTE format('SELECT * FROM %I.fo_fiber WHERE id_gis = $1', schema_name) INTO output_fiber_record USING current_fiber_connectivity_record.id_gis_fiber_1;
        
        input_fiber_point = ST_EndPoint(input_fiber_record.layout_geom);
        output_fiber_point = ST_StartPoint(output_fiber_record.layout_geom);
        EXECUTE format('SELECT * FROM %I.fo_splice WHERE id_gis = $1', schema_name) INTO fo_splice_rec USING current_fiber_connectivity_record.id_splice;

        IF current_splice IS NULL OR current_splice <> fo_splice_rec.id_gis THEN
            current_splice = fo_splice_rec.id_gis;
            cont = 1;

            face_1 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 1), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 2));
            face_2 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 2), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 3));
            face_3 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 3), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 4));
            face_4 = ST_MakeLine((SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 4), (SELECT geom FROM ST_DumpPoints(fo_splice_rec.layout_geom) WHERE path[2] = 5));
        END IF;

        IF current_cable IS NULL OR current_cable <> input_fiber_record.id_cable THEN
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

    IF ST_Equals(clossest_input_face_aux, clossest_output_face_aux) THEN
        -- Continuación de la fibra hasta la cara.
        input_fiber_to_face = ST_ShortestLine(input_fiber_point ,clossest_input_face_aux);

        new_input_geom = ST_LineMerge(
            ST_MakeLine(input_fiber_record.layout_geom, ST_EndPoint(input_fiber_to_face))
        );

        -- Continuación de la cara de salida hasta la fibra de salida.
        output_fiber_to_face = ST_ShortestLine(clossest_output_face_aux ,output_fiber_point);

        fiber_to_fiber_line = ST_ShortestLine(ST_EndPoint(input_fiber_to_face), output_fiber_to_face);            

        new_output_geom = ST_LineMerge(
            ST_MakeLine(
                fiber_to_fiber_line,
                ST_MakeLine(output_fiber_to_face, output_fiber_record.layout_geom)
            )
        );

    ELSIF ST_Intersects(clossest_input_face_aux, clossest_output_face_aux) THEN    
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
                ST_Distance(clossest_output_face_aux, unnest(ARRAY[face_1, face_2, face_3, face_4])) AS distance
            WHERE 
                NOT ST_Equals(clossest_output_face_aux, unnest(ARRAY[face_1, face_2, face_3, face_4])) AND 
                NOT ST_Intersects(clossest_output_face_aux, unnest(ARRAY[face_1, face_2, face_3, face_4]))
        )
        SELECT INTO second_closest_output_face
            face
        FROM distances
        ORDER BY distance ASC
        LIMIT 1;

        -- Se hace lo mismo para el otro punto de entrada.
        WITH distances AS (
            SELECT
                unnest(ARRAY[face_1, face_2, face_3, face_4]) AS face,
                ST_Distance(clossest_input_face_aux, unnest(ARRAY[face_1, face_2, face_3, face_4])) AS distance
            WHERE 
                NOT ST_Equals(clossest_input_face_aux, unnest(ARRAY[face_1, face_2, face_3, face_4])) AND 
                NOT ST_Intersects(clossest_input_face_aux, unnest(ARRAY[face_1, face_2, face_3, face_4]))
        )
        SELECT INTO second_closest_input_face
            face
        FROM distances
        ORDER BY distance ASC
        LIMIT 1;

        -- Se consigue el punto de corte entre estas caras.
        output_faces_intersection_point = ST_Intersection(clossest_output_face_aux, second_closest_output_face);
        -- Se consigue el punto de corte de las otras caras.
        input_faces_intersection_point = ST_Intersection(clossest_input_face_aux, second_closest_input_face);

        output_faces_line = ST_MakeLine(
            output_faces_intersection_point,
            input_faces_intersection_point
        );

        -- Se crea la geometría de las nuevas entradas y salidas.
        new_input_geom = ST_LineMerge(
            ST_MakeLine(
                ST_MakeLine(
                    ST_ShortestLine(input_fiber_point, clossest_input_face_aux),
                    ST_ShortestLine(clossest_input_face_aux, input_faces_intersection_point)
                ),
                ST_ShortestLine(input_faces_intersection_point, output_faces_intersection_point)
            )
        );

        output_faces_line_to_face = ST_ShortestLine(output_faces_line, clossest_output_face_aux);

        new_output_geom = ST_LineMerge(
            ST_MakeLine(
                ST_MakeLine(output_faces_line, output_faces_line_to_face),
                ST_ShortestLine(clossest_output_face_aux, output_fiber_point)
            )
        );
    END IF;

    cont := cont + 1;
END LOOP;
END
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


--CONSULTAS TOP

    select * from objects.cw_sewer_box

    select * from objects.cw_connectivity_box

    select * from objects.cw_ground_route

    select * from objects.cw_duct

    select * from objects.fo_splice

    select * from objects.fo_cable

    select * from objects.fo_fiber

    select * from objects.cw_skyway

    select * from objects.cw_pole

    select * from objects.in_port

    select * from objects.optical_splitter

    select * from objects.out_port

    select * from objects.puerto
	
	select * from objects.saved_changes

--CONSULTAS ALTERNATIVA

    select * from alt_6.cw_sewer_box

    select * from alt_6.cw_connectivity_box

    select * from alt_6.cw_ground_route

    select * from alt_6.cw_duct

    select * from alt_6.fo_splice

    select * from alt_6.fo_cable

    select * from alt_6.fo_fiber

    select * from alt_6.cw_skyway

    select * from alt_6.cw_pole

    select * from alt_6.in_port

    select * from alt_6.optical_splitter

    select * from alt_6.out_port

    select * from alt_6.puerto
	
	select * from alt_6.saved_changes


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE update_object(
    IN schema_name TEXT,
    IN object_type TEXT, 
    IN id_gis VARCHAR,
    IN geom GEOMETRY,
    IN id_usuario UUID
)
LANGUAGE plpgsql
AS $$
DECLARE
    user_exists BOOLEAN;
    query_text TEXT;  -- Variable para almacenar la consulta de actualización
BEGIN
    -- Verificar si el usuario existe
    SELECT EXISTS(SELECT 1 FROM security.users WHERE id = id_usuario) INTO user_exists;

    -- Si el usuario no existe, lanzar un error
    IF NOT user_exists THEN
        RAISE EXCEPTION 'El usuario con id % no existe en security.users', id_usuario;
    END IF;

    -- Verificar el tipo de objeto y realizar la actualización correspondiente
    CASE object_type
        WHEN 'cw_ground_route' THEN
            query_text := format('
                UPDATE %I.%I
                SET geom = %L, edited_by = %L
                WHERE id_gis = %L', schema_name, object_type, geom, id_usuario, id_gis);
            EXECUTE query_text;

        WHEN 'fo_cable' THEN
            query_text := format('
                UPDATE %I.%I
                SET geom = %L, edited_by = %L, id_duct = %L
                WHERE id_gis = %L', schema_name, object_type, geom, id_usuario, id_duct, id_gis);
            EXECUTE query_text;

        ELSE
            query_text := format('
                UPDATE %I.%I
                SET geom = %L, edited_by = %L
                WHERE id_gis = %L', schema_name, object_type, geom, id_usuario, id_gis);
            EXECUTE query_text;
    END CASE;

    -- Imprimir el valor de query_text
    RAISE NOTICE 'Query ejecutada: %', query_text;

    -- Fin del procedimiento
END;
$$;

------------------------------------------------------------------------------------


CALL update_object('objects', 'cw_sewer_box', 'cw_sewer_box_3', 'SRID=3857;POINT(-404304.97 4928712.77)', '5be381ea-aefc-41ea-aa5e-f28fb9193750');

CALL update_object('objects', 'cw_pole', 'cw_pole_1', 'SRID=3857;POINT(-404063.28 4929153.11)', '5be381ea-aefc-41ea-aa5e-f28fb9193750');

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


--PROCEDIMIENTO PARA INSERTS DINAMICOS, TIPO LINEA
CREATE OR REPLACE FUNCTION insert_object(
    IN schema_name TEXT,
    IN object_type TEXT,
    IN geom GEOMETRY,
    IN id_usuario UUID,
    IN id_duct TEXT DEFAULT NULL
) RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    user_exists BOOLEAN;
    query_text TEXT;
BEGIN
    -- Verificar si el usuario existe
    SELECT EXISTS(SELECT 1 FROM security.users WHERE id = id_usuario) INTO user_exists;

    -- Si el usuario no existe, lanzar un error
    IF NOT user_exists THEN
        RAISE EXCEPTION 'El usuario con id % no existe en security.users', id_usuario;
    END IF;

    -- Verificar el tipo de objeto y realizar la inserción correspondiente
    CASE object_type
        WHEN 'cw_ground_route' THEN
            query_text := format('
                INSERT INTO %I.%I(geom, edited_by)
                VALUES (%L, %L)', schema_name, object_type, geom, id_usuario);
            EXECUTE query_text;

        WHEN 'fo_cable' THEN
            query_text := format('
                INSERT INTO %I.%I(geom, edited_by, id_duct)
                VALUES (%L, %L, %L)', schema_name, object_type, geom, id_usuario, id_duct);
            EXECUTE query_text;

        ELSE
            query_text := format('
                INSERT INTO %I.%I(geom, edited_by)
                VALUES (%L, %L)', schema_name, object_type, geom, id_usuario);
            EXECUTE query_text;
    END CASE;

    -- Imprimir el valor de query_text
    RAISE NOTICE 'Query ejecutada: %', query_text;

    -- Devolver la consulta ejecutada
    RETURN query_text;
END;
$$;


--PROBANDO PROCEDIMIENTO NUEVO SEWER_BOX
SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-404270.31 4928508.68)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box',
    'SRID=3857;POINT(-404346.69 4928643.55)',
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-404204.97 4928712.77)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-404061.86 4928795.84)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-403830.22 4928927.29)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-403911.74 4929074.14)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-403772.35 4928823.38)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-403596.88 4929067.92)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-403596.88 4929067.92)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-403695.08 4928688.35)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);

SELECT insert_object(
    'objects', 
    'cw_sewer_box', 
    'SRID=3857;POINT(-403608.66 4928732.30)', 
    'a997da45-79ec-465d-8bbe-e38468c24c21'
);
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--NUEVO PROCEDIMIENTO, INSERTS POSTE
SELECT insert_object(
    'objects', 
    'cw_pole', 
    'SRID=3857;POINT(-403976.17 4929178.57)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_pole', 
    'SRID=3857;POINT(-404017.00 4929257.68)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_pole', 
    'SRID=3857;POINT(-404118.58 4929237.43)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_pole', 
    'SRID=3857;POINT(-403893.58 4929214.64)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


--PROCEDIMIENTOS NUEVOS GROUND_ROUTE
SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);


SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);
SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);
SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_ground_route', 
    'SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--PROCEDIMIENTOS NUEVOS SKYWAY
SELECT insert_object(
    'objects', 
    'cw_skyway', 
    'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_skyway', 
    'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_skyway', 
    'SRID=3857;LINESTRING(-404017.00 4929257.68, -404118.58 4929237.43)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_skyway', 
    'SRID=3857;LINESTRING(-403976.17 4929178.57, -403893.58 4929214.64)', 
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);


SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);


SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);


SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'cw_duct',
    'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--NUEVOS PROCEDIMIENTOS. INSERTS SPLICE
SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-403830.22 4928927.29)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-403830.22 4928927.29)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);


SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-403830.22 4928927.29)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);


SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-403976.17 4929178.57)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-403976.17 4929178.57)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-404017.00 4929257.68)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-403695.08 4928688.35)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

SELECT insert_object(
    'objects', 
    'fo_splice',
    'SRID=3857;POINT(-403695.08 4928688.35)',
    'fe2ddf89-87ae-4b29-8123-63782d2c8635'
);

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--NUEVOS PROCEDIMIENTOS, INSERTS CABLES
SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_1'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_2'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_2'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);


SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);


SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_3'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_3'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404346.69 4928643.55, -404204.97 4928712.77)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_5'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_5'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404204.97 4928712.77, -404061.86 4928795.84)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);


SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_7'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_7'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_7'
);


SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404061.86 4928795.84, -403830.22 4928927.29)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_9'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_9'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403911.74 4929074.14)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_11'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_11'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403772.35 4928823.38)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_13'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_13'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403830.22 4928927.29, -403596.88 4929067.92)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects',
    'fo_cable',
    'SRID=3857;LINESTRING(-403911.74 4929074.14, -403976.17 4929178.57)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403976.17 4929178.57, -404017.00 4929257.68)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-404270.31 4928508.68, -404346.69 4928643.55, -404204.97 4928712.77, -404061.86 4928795.84, -403830.22 4928927.29)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_1, cw_duct_3, cw_duct_5, null'
);

SELECT insert_object(
    'objects',
    'fo_cable', 
    'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_15'
);


SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403772.35 4928823.38, -403695.08 4928688.35)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);

SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc',
    'cw_duct_16'
);


SELECT insert_object(
    'objects', 
    'fo_cable', 
    'SRID=3857;LINESTRING(-403695.08 4928688.35, -403608.66 4928732.30)', 
    '5d248fef-8bc1-40fb-ab56-9caa1c65cefc'
);
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

call create_branch('pruebaProyect', 'fe2ddf89-87ae-4b29-8123-63782d2c8635')

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

CALL update_object('objects', 'cw_sewer_box', 'cw_sewer_box_3', 'SRID=3857;POINT(-404304.97 4928712.77)', '3d12b18e-a844-477a-bd59-7ecfc984682d');

CALL update_object('objects', 'cw_pole', 'cw_pole_2', 'SRID=3857;POINT(-403985.86 4929052.72)', '3d12b18e-a844-477a-bd59-7ecfc984682d');

-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------


--PROCEDIMIENTOS DE DELETE
CALL delete_point_object('objects', 'cw_sewer_box', 'cw_sewer_box_2');

CALL delete_point_object('objects', 'cw_connectivity_box', 'cw_connectivity_box_2');


------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

SELECT optical_splitter_insert_func('fo_splice_2', 4, 'objects');
SELECT optical_splitter_insert_func('fo_splice_2', 16, 'objects');
SELECT optical_splitter_insert_func('fo_splice_7', 8, 'objects');


------------------------------------------------------------s------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

/*markdown
CONEXIÓN DE CABLES
*/

SELECT connect_cable('fo_cable_20', 'fo_splice_2','objects');
SELECT connect_cable('fo_cable_21', 'fo_splice_2', 'objects');
SELECT connect_cable('fo_cable_24', 'fo_splice_2','objects');
SELECT connect_cable('fo_cable_28', 'fo_splice_2', 'objects');
SELECT connect_cable('fo_cable_33', 'fo_splice_2', 'objects');

SELECT connect_cable('fo_cable_51', 'fo_splice_7', 'objects');
SELECT connect_cable('fo_cable_54', 'fo_splice_7', 'objects');
SELECT connect_cable('fo_cable_52', 'fo_splice_8', 'objects');

------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- /*markdown
-- CONEXIÓN DE CABLES EN POSTES
-- */

SELECT connect_cable('fo_cable_42', 'fo_splice_4', 'objects');
SELECT connect_cable('fo_cable_43', 'fo_splice_5', 'objects');


------------------------------------------------------------------------------------------------------------------------------
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

SELECT connect_fibers();

/*markdown
CONEXIÓN DE HILOS
*/

SELECT connect_fiber('fo_fiber_7210', 'fo_fiber_7635', 'objects');
SELECT connect_fiber('fo_fiber_7215', 'fo_fiber_7636', 'objects');
SELECT connect_fiber('fo_fiber_7216', 'fo_fiber_7637', 'objects');

------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- /*markdown
-- CONEXIÓN DE HILOS EN POSTES
-- */

SELECT connect_fiber('fo_fiber_5330', 'fo_fiber_5910','objects');
SELECT connect_fiber('fo_fiber_5335', 'fo_fiber_5915', 'objects');
SELECT connect_fiber('fo_fiber_5475', 'fo_fiber_6050', 'objects');
SELECT connect_fiber('fo_fiber_5480', 'fo_fiber_6055', 'objects');


------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------



-- /*markdown
-- CONECION CON SPLITTERS
-- */

SELECT connect_fiber_port('objects', 'fo_fiber_7221', 'in_port_3');
SELECT connect_fiber_port('objects', 'fo_fiber_7640', 'out_port_21');
SELECT connect_fiber_port('objects','fo_fiber_7645', 'out_port_22');

------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

--TOPOLOGIA DE HILOS 
SELECT pgr_CreateTopology('objects.fo_fiber', 0.000000001, 'layout_geom', 'id_auto');

--FUNCION QUE ACTUALIZA LA TOPOLOGIA
SELECT update_fiber_topology('objects');

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