
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

CREATE SCHEMA df;

SET search_path = df, pg_catalog;

CREATE DOMAIN df_boolean AS boolean;

CREATE DOMAIN df_id AS integer;

CREATE DOMAIN df_integer AS integer;

CREATE DOMAIN df_interval AS interval;

CREATE DOMAIN df_money AS numeric(10,2);

CREATE DOMAIN df_smallint AS smallint;

CREATE DOMAIN df_string_large AS character varying(255);

CREATE DOMAIN df_string_short AS character varying(50);

CREATE DOMAIN df_text AS text;

CREATE DOMAIN df_timestamp AS timestamp without time zone;

CREATE DOMAIN df_tinyint AS smallint;

CREATE DOMAIN df_tinyint_id AS smallint
	CONSTRAINT chk_df_tinyint_id CHECK (((VALUE >= 0) OR (VALUE <= 255)));

CREATE FUNCTION fn_df_next_pk_value_get(atable_schema name, atable_name name) RETURNS df_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  lresult df.df_id;
  lfield_name df.df_string_short;
BEGIN
  SELECT KCU.column_name
  INTO lfield_name
  FROM information_schema.table_constraints TC
    INNER JOIN information_schema.key_column_usage KCU
      ON  KCU.table_catalog   = TC.table_catalog
      AND KCU.table_schema    = TC.table_schema
      AND KCU.table_name      = TC.table_name
      AND KCU.constraint_name = TC.constraint_name
  WHERE TC.table_catalog   = current_catalog
    AND TC.table_schema    = atable_schema
    AND TC.table_name      = atable_name
    AND TC.constraint_type = 'PRIMARY KEY';

  EXECUTE 'SELECT COALESCE(MAX(' || lfield_name || ') + 1, 1) FROM ' ||
    atable_schema || '.' || atable_name
  INTO lresult;

  RETURN lresult;
END;
$$;

CREATE FUNCTION fn_df_timestamp_to_str(avalue df_timestamp) RETURNS df_string_short
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN to_char(avalue, 'yyyy-MM-dd HH24:MI:SS');
END;
$$;

CREATE FUNCTION fn_df_utc_timestamp() RETURNS df_timestamp
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN clock_timestamp() AT TIME ZONE 'UTC';
END;
$$;
