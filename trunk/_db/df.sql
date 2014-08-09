
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

CREATE DOMAIN df_tinyint AS smallint
	CONSTRAINT chk_df_tinyint CHECK (((VALUE >= 0) OR (VALUE <= 255)));

CREATE DOMAIN df_tinyint_id AS smallint
	CONSTRAINT chk_df_tinyint_id CHECK (((VALUE >= 0) OR (VALUE <= 255)));

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

CREATE FUNCTION fn_df_next_pk_value_get(atable_schema name, atable_name name, acondition df_string_short DEFAULT ''::character varying) RETURNS df_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN df.fn_df_next_field_value_get(atable_schema, atable_name,
    df.fn_df_pk_field_name_get(atable_schema, atable_name), acondition);
END;
$$;

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

CREATE FUNCTION fn_df_random_i() RETURNS df_integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN trunc(random() * 2^32) - 2^31;
END;
$$;

CREATE FUNCTION fn_df_random_id() RETURNS df_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN 1 + trunc(random() * (2^31 - 1));
END;
$$;

CREATE FUNCTION fn_df_random_id_range(afrom df_id, ato df_id) RETURNS df_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN afrom + trunc(random() * (ato - afrom + 1));
END;
$$;

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

CREATE FUNCTION fn_df_timestamp_to_local_str(avalue df_timestamp, atimezome df_string_short DEFAULT 'Europe/Kiev'::character varying) RETURNS df_timestamp
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN df.fn_df_timestamp_to_str((avalue AT TIME ZONE atimezome)::df.df_timestamp);
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
