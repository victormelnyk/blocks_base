
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

CREATE SCHEMA df;

ALTER SCHEMA df OWNER TO b_admin;

CREATE SCHEMA doc;

ALTER SCHEMA doc OWNER TO b_admin;

CREATE PROCEDURAL LANGUAGE plpgsql;

ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO b_admin;

SET search_path = df, pg_catalog;

CREATE DOMAIN df_boolean AS boolean;

ALTER DOMAIN df.df_boolean OWNER TO b_admin;

CREATE DOMAIN df_id AS integer;

ALTER DOMAIN df.df_id OWNER TO b_admin;

CREATE DOMAIN df_integer AS integer;

ALTER DOMAIN df.df_integer OWNER TO b_admin;

CREATE DOMAIN df_interval AS interval;

ALTER DOMAIN df.df_interval OWNER TO b_admin;

CREATE DOMAIN df_money AS numeric(10,2);

ALTER DOMAIN df.df_money OWNER TO b_admin;

CREATE DOMAIN df_smallint AS smallint;

ALTER DOMAIN df.df_smallint OWNER TO b_admin;

CREATE DOMAIN df_string_large AS character varying(255);

ALTER DOMAIN df.df_string_large OWNER TO b_admin;

CREATE DOMAIN df_string_short AS character varying(50);

ALTER DOMAIN df.df_string_short OWNER TO b_admin;

CREATE DOMAIN df_text AS text;

ALTER DOMAIN df.df_text OWNER TO b_admin;

CREATE DOMAIN df_timestamp AS timestamp without time zone;

ALTER DOMAIN df.df_timestamp OWNER TO b_admin;

CREATE DOMAIN df_tinyint AS smallint
	CONSTRAINT chk_df_tinyint CHECK (((VALUE >= 0) OR (VALUE <= 255)));

ALTER DOMAIN df.df_tinyint OWNER TO b_admin;

CREATE DOMAIN df_tinyint_id AS smallint
	CONSTRAINT chk_df_tinyint_id CHECK (((VALUE >= 0) OR (VALUE <= 255)));

ALTER DOMAIN df.df_tinyint_id OWNER TO b_admin;

SET search_path = doc, pg_catalog;

CREATE DOMAIN doc_language_code AS character varying(2) NOT NULL;

ALTER DOMAIN doc.doc_language_code OWNER TO b_admin;

SET search_path = df, pg_catalog;

CREATE FUNCTION fn_df_next_field_value_get(atable_schema name, atable_name name, afield_name name, acondition df_string_short DEFAULT ''::character varying) RETURNS df_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  lresult df.df_id;
  lsql df.df_string_large;
BEGIN
  lsql = 'SELECT COALESCE(MAX(' || afield_name || ') + 1, 1) FROM ' ||
    atable_schema || '.' || atable_name;

  IF acondition <> '' THEN
    lsql = lsql || ' WHERE ' || acondition;
  END IF;

  EXECUTE lsql
  INTO lresult;

  RETURN lresult;
END;
$$;

ALTER FUNCTION df.fn_df_next_field_value_get(atable_schema name, atable_name name, afield_name name, acondition df_string_short) OWNER TO b_admin;

CREATE FUNCTION fn_df_next_pk_value_get(atable_schema name, atable_name name, acondition df_string_short DEFAULT ''::character varying) RETURNS df_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN df.fn_df_next_field_value_get(atable_schema, atable_name,
    df.fn_df_pk_field_name_get(atable_schema, atable_name), acondition);
END;
$$;

ALTER FUNCTION df.fn_df_next_pk_value_get(atable_schema name, atable_name name, acondition df_string_short) OWNER TO b_admin;

CREATE FUNCTION fn_df_next_random_pk_value_get(atable_schema name, atable_name name, acondition df_string_short DEFAULT ''::character varying, afrom df_id DEFAULT 0, ato df_id DEFAULT 0) RETURNS df_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  lis_exist df.df_boolean;
  lresult df.df_id;
  lsql df.df_string_large;
  lfield_name df.df_string_short;
BEGIN
  lfield_name = df.fn_df_pk_field_name_get(atable_schema, atable_name);

  LOOP
    IF (afrom <> 0) AND (ato <> 0) THEN
      lresult = df.fn_df_random_id_range(afrom, ato);
    ELSE
      lresult = df.fn_df_random_id();
    END IF;

    lsql = 'SELECT EXISTS(SELECT * FROM ' ||
      atable_schema || '.' || atable_name || ' WHERE ';

    IF acondition <> '' THEN
      lsql = lsql || acondition || ' AND ';
    END IF;

    lsql = lsql || lfield_name || ' = ' || lresult || ')';

    EXECUTE lsql
    INTO lis_exist;

    IF NOT lis_exist THEN
      EXIT;
    END IF;
  END LOOP;

  RETURN lresult;
END;
$$;

ALTER FUNCTION df.fn_df_next_random_pk_value_get(atable_schema name, atable_name name, acondition df_string_short, afrom df_id, ato df_id) OWNER TO b_admin;

CREATE FUNCTION fn_df_pk_field_name_get(atable_schema name, atable_name name) RETURNS df_string_short
    LANGUAGE plpgsql
    AS $$
DECLARE
  lresult df.df_string_short;
BEGIN
  SELECT KCU.column_name
  INTO lresult
  FROM information_schema.table_constraints TC
    INNER JOIN information_schema.key_column_usage KCU
      ON  KCU.table_catalog   = TC.table_catalog
      AND KCU.table_schema    = TC.table_schema
      AND KCU.table_name      = TC.table_name
      AND KCU.constraint_name = TC.constraint_name
  WHERE TC.table_catalog   = current_catalog
    AND TC.table_schema    = atable_schema
    AND TC.table_name      = atable_name
    AND TC.constraint_type = 'PRIMARY KEY'
  ORDER BY KCU.ordinal_position DESC
  LIMIT 1;

  RETURN lresult;
END;
$$;

ALTER FUNCTION df.fn_df_pk_field_name_get(atable_schema name, atable_name name) OWNER TO b_admin;

CREATE FUNCTION fn_df_random_i() RETURNS df_integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN trunc(random() * 2^32) - 2^31;
END;
$$;

ALTER FUNCTION df.fn_df_random_i() OWNER TO b_admin;

CREATE FUNCTION fn_df_random_id() RETURNS df_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN 1 + trunc(random() * (2^31 - 1));
END;
$$;

ALTER FUNCTION df.fn_df_random_id() OWNER TO b_admin;

CREATE FUNCTION fn_df_random_id_range(afrom df_id, ato df_id) RETURNS df_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN afrom + trunc(random() * (ato - afrom + 1));
END;
$$;

ALTER FUNCTION df.fn_df_random_id_range(afrom df_id, ato df_id) OWNER TO b_admin;

CREATE FUNCTION fn_df_root_path_calc(aid df_id, aparent_id df_id, atable_schema name, atable_name name, aid_field_name df_string_short, aparent_id_field_name df_string_short) RETURNS df_string_short
    LANGUAGE plpgsql
    AS $$
DECLARE
  lid df.df_id;
  lparent_id df.df_id;
  lresult df.df_string_short;
BEGIN
  lid = aid;
  lparent_id = aparent_id;
  lresult = '.' || lid || '.';

  WHILE (lparent_id IS NOT NULL) LOOP
    EXECUTE 'SELECT ' || aid_field_name || ', ' || aparent_id_field_name || ' '
      'FROM ' || atable_schema || '.' || atable_name || ' '
      'WHERE ' || aid_field_name || ' = ' || lparent_id
    INTO lid, lparent_id;

    lresult =  '.' || lid || lresult;
  END LOOP;

  RETURN lresult;
END;
$$;

ALTER FUNCTION df.fn_df_root_path_calc(aid df_id, aparent_id df_id, atable_schema name, atable_name name, aid_field_name df_string_short, aparent_id_field_name df_string_short) OWNER TO b_admin;

CREATE FUNCTION fn_df_temp_table_exist(atable_name name) RETURNS df_boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN EXISTS(
    SELECT *
    FROM information_schema.tables T
    WHERE T.table_name = atable_name
      AND T.table_type = 'LOCAL TEMPORARY');
END;
$$;

ALTER FUNCTION df.fn_df_temp_table_exist(atable_name name) OWNER TO b_admin;

CREATE FUNCTION fn_df_timestamp_to_local_str(avalue df_timestamp, atimezome df_string_short DEFAULT 'Europe/Kiev'::character varying) RETURNS df_timestamp
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN df.fn_df_timestamp_to_str((avalue AT TIME ZONE atimezome)::df.df_timestamp);
END;
$$;

ALTER FUNCTION df.fn_df_timestamp_to_local_str(avalue df_timestamp, atimezome df_string_short) OWNER TO b_admin;

CREATE FUNCTION fn_df_timestamp_to_str(avalue df_timestamp) RETURNS df_string_short
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN to_char(avalue, 'yyyy-MM-dd HH24:MI:SS');
END;
$$;

ALTER FUNCTION df.fn_df_timestamp_to_str(avalue df_timestamp) OWNER TO b_admin;

CREATE FUNCTION fn_df_utc_timestamp() RETURNS df_timestamp
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN clock_timestamp() AT TIME ZONE 'UTC';
END;
$$;

ALTER FUNCTION df.fn_df_utc_timestamp() OWNER TO b_admin;

SET search_path = doc, pg_catalog;

CREATE FUNCTION fn_doc_clear() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM doc.doc_document_last_edits;
  DELETE FROM doc.doc_document_edits;
  DELETE FROM doc.doc_documents;
  DELETE FROM doc.doc_languages;
END;
$$;

ALTER FUNCTION doc.fn_doc_clear() OWNER TO b_admin;

CREATE FUNCTION fn_doc_language_id_get(adocument_code df.df_string_short, alanguage_code doc_language_code) RETURNS df.df_tinyint_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT L.language_id
    FROM doc.doc_documents D
      INNER JOIN doc.doc_languages L
        ON L.code = alanguage_code
      INNER JOIN doc.doc_document_last_edits DLE
        ON  DLE.document_id = D.document_id
        AND DLE.language_id = L.language_id
    WHERE D.code = adocument_code
    UNION ALL
    SELECT *
    FROM (
      SELECT L.language_id
      FROM doc.doc_documents D
        INNER JOIN doc.doc_languages L
          ON TRUE
        INNER JOIN doc.doc_document_last_edits DLE
          ON  DLE.document_id = D.document_id
          AND DLE.language_id = L.language_id
      WHERE D.code = adocument_code
      ORDER BY L.lno
    ) D
    LIMIT 1);
END;
$$;

ALTER FUNCTION doc.fn_doc_language_id_get(adocument_code df.df_string_short, alanguage_code doc_language_code) OWNER TO b_admin;

CREATE FUNCTION fn_doc_pack() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  lrecord record;
BEGIN
  DELETE FROM doc.doc_document_edits DE
  WHERE NOT EXISTS(
    SELECT *
    FROM doc.doc_document_last_edits DLE
    WHERE DLE.document_id  = DE.document_id
      AND DLE.language_id  = DE.language_id
      AND DLE.last_edit_id = DE.edit_id
  );

  UPDATE doc.doc_document_edits
  SET edit_id = 1
  WHERE edit_id <> 1;

  FOR lrecord IN
    SELECT
      D.document_id,
      ( SELECT COUNT(*)
        FROM doc.doc_documents _D
        WHERE _D.document_id <= D.document_id
      ) count
    FROM doc.doc_documents D
    ORDER BY D.document_id
  LOOP
    UPDATE doc.doc_documents
    SET document_id = lrecord.count
    WHERE document_id = lrecord.document_id;
  END LOOP;
END;
$$;

ALTER FUNCTION doc.fn_doc_pack() OWNER TO b_admin;

CREATE FUNCTION t_doc_document_edits_ai() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE doc.doc_document_last_edits
  SET last_edit_id  = NEW.edit_id
  WHERE document_id = NEW.document_id
    AND language_id = NEW.language_id;

  IF NOT FOUND THEN
    INSERT INTO doc.doc_document_last_edits (
      document_id,
      language_id,
      last_edit_id)
     VALUES (
      NEW.document_id,
      NEW.language_id,
      NEW.edit_id);
  END IF;

  RETURN NEW;
END;
$$;

ALTER FUNCTION doc.t_doc_document_edits_ai() OWNER TO b_admin;

CREATE FUNCTION t_doc_document_edits_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT COALESCE(MAX(DE.edit_id) + 1, 1)
  INTO NEW.edit_id
  FROM doc.doc_document_edits DE
  WHERE DE.document_id = NEW.document_id
    AND DE.language_id = NEW.language_id;

  NEW.date_created = df.fn_df_utc_timestamp();

  RETURN NEW;
END;
$$;

ALTER FUNCTION doc.t_doc_document_edits_bi() OWNER TO b_admin;

CREATE FUNCTION t_doc_documents_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.document_id = df.fn_df_next_pk_value_get(TG_TABLE_SCHEMA, TG_TABLE_NAME);

  IF NEW.is_published IS NULL THEN
    NEW.is_published = FALSE;
  END IF;

  NEW.date_created = df.fn_df_utc_timestamp();
  NEW.is_deleted = FALSE;

  RETURN NEW;
END;
$$;

ALTER FUNCTION doc.t_doc_documents_bi() OWNER TO b_admin;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE doc_document_edits (
    document_id df.df_id NOT NULL,
    language_id df.df_tinyint_id NOT NULL,
    edit_id df.df_id NOT NULL,
    content df.df_text NOT NULL,
    date_created df.df_timestamp NOT NULL,
    page_meta df.df_string_large,
    page_title df.df_string_large
);

ALTER TABLE doc.doc_document_edits OWNER TO b_admin;

CREATE TABLE doc_document_last_edits (
    document_id df.df_id NOT NULL,
    language_id df.df_tinyint_id NOT NULL,
    last_edit_id df.df_id NOT NULL
);

ALTER TABLE doc.doc_document_last_edits OWNER TO b_admin;

CREATE TABLE doc_documents (
    document_id df.df_id NOT NULL,
    code df.df_string_short NOT NULL,
    is_published df.df_boolean NOT NULL,
    date_created df.df_timestamp NOT NULL,
    is_deleted df.df_boolean NOT NULL
);

ALTER TABLE doc.doc_documents OWNER TO b_admin;

CREATE TABLE doc_languages (
    language_id df.df_tinyint_id NOT NULL,
    code doc_language_code NOT NULL,
    title df.df_string_short NOT NULL,
    lno df.df_tinyint NOT NULL
);

ALTER TABLE doc.doc_languages OWNER TO b_admin;

ALTER TABLE ONLY doc_document_edits
    ADD CONSTRAINT pk_doc_document_edits PRIMARY KEY (document_id, language_id, edit_id);

ALTER TABLE ONLY doc_documents
    ADD CONSTRAINT pk_doc_documents PRIMARY KEY (document_id);

ALTER TABLE ONLY doc_languages
    ADD CONSTRAINT pk_doc_languages PRIMARY KEY (language_id);

ALTER TABLE ONLY doc_document_last_edits
    ADD CONSTRAINT pk_document_last_edit PRIMARY KEY (document_id, language_id);

ALTER TABLE ONLY doc_document_last_edits
    ADD CONSTRAINT uq_doc_document_last_edits UNIQUE (document_id, language_id, last_edit_id);

ALTER TABLE ONLY doc_documents
    ADD CONSTRAINT uq_doc_documents UNIQUE (code);

ALTER TABLE ONLY doc_languages
    ADD CONSTRAINT uq_doc_languages UNIQUE (code);

CREATE TRIGGER t_doc_document_edits_ai
    AFTER INSERT ON doc_document_edits
    FOR EACH ROW
    EXECUTE PROCEDURE t_doc_document_edits_ai();

CREATE TRIGGER t_doc_document_edits_bi
    BEFORE INSERT ON doc_document_edits
    FOR EACH ROW
    EXECUTE PROCEDURE t_doc_document_edits_bi();

CREATE TRIGGER t_doc_documents_bi
    BEFORE INSERT ON doc_documents
    FOR EACH ROW
    EXECUTE PROCEDURE t_doc_documents_bi();

ALTER TABLE ONLY doc_document_edits
    ADD CONSTRAINT fk_doc_document_edits__doc_documents FOREIGN KEY (document_id) REFERENCES doc_documents(document_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY doc_document_edits
    ADD CONSTRAINT fk_doc_document_edits__doc_languages FOREIGN KEY (language_id) REFERENCES doc_languages(language_id);

ALTER TABLE ONLY doc_document_last_edits
    ADD CONSTRAINT fk_doc_document_last_edit__doc_document_edits FOREIGN KEY (document_id, language_id, last_edit_id) REFERENCES doc_document_edits(document_id, language_id, edit_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
