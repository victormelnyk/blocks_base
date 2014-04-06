
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

CREATE SCHEMA doc;

SET search_path = doc, pg_catalog;

CREATE DOMAIN doc_language_code AS character varying(2) NOT NULL;

CREATE FUNCTION fn_doc_clear() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM doc.doc_document_last_edits;
  DELETE FROM doc.doc_document_edits;
  DELETE FROM doc.doc_documents;
  --DELETE FROM doc.doc_languages;
END;
$$;

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

CREATE FUNCTION t_doc_documents_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT COALESCE(MAX(document_id) + 1, 1)
  INTO NEW.document_id
  FROM doc.doc_documents;

  IF NEW.is_published IS NULL THEN
    NEW.is_published = FALSE;
  END IF;

  NEW.date_created = df.fn_df_utc_timestamp();
  NEW.is_deleted = FALSE;

  RETURN NEW;
END;
$$;

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

CREATE TABLE doc_document_last_edits (
    document_id df.df_id NOT NULL,
    language_id df.df_tinyint_id NOT NULL,
    last_edit_id df.df_id NOT NULL
);

CREATE TABLE doc_documents (
    document_id df.df_id NOT NULL,
    code df.df_string_short NOT NULL,
    is_published df.df_boolean NOT NULL,
    date_created df.df_timestamp NOT NULL,
    is_deleted df.df_boolean NOT NULL
);

CREATE TABLE doc_languages (
    language_id df.df_tinyint_id NOT NULL,
    code doc_language_code NOT NULL,
    title df.df_string_short NOT NULL,
    lno df.df_tinyint NOT NULL
);

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
    ADD CONSTRAINT fk_doc_document_edits__doc_documents FOREIGN KEY (document_id) REFERENCES doc_documents(document_id);

ALTER TABLE ONLY doc_document_edits
    ADD CONSTRAINT fk_doc_document_edits__doc_languages FOREIGN KEY (language_id) REFERENCES doc_languages(language_id);

ALTER TABLE ONLY doc_document_last_edits
    ADD CONSTRAINT fk_doc_document_last_edit__doc_document_edits FOREIGN KEY (document_id, language_id, last_edit_id) REFERENCES doc_document_edits(document_id, language_id, edit_id) DEFERRABLE INITIALLY DEFERRED;
