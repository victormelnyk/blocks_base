
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

CREATE SCHEMA doc;

SET search_path = doc, pg_catalog;

CREATE FUNCTION fn_document_new(alang df.df_id, atitle df.df_string_large, acontent df.df_text, apublished df.df_boolean) RETURNS df.df_boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  document_id df.df_id;
    content_id df.df_id;
    document_edit_id df.df_id;
    date df.df_timestamp;

BEGIN
document_id = 1;
INSERT INTO doc.doc_documents(id, last_edit_id, lang_id, title, published)
VALUES(document_id, 0, alang, atitle, apublished);

content_id = 1;
INSERT INTO doc.doc_contents(id, content, lang_id)
VALUES(content_id, acontent, alang);

document_edit_id = 1;
date = df.fn_df_utc_timestamp();
INSERT INTO doc.doc_edit(id, lang_id, content_id, date, document_id)
VALUES(doc_document_edit_id, alang, doc_document_content_id, date, doc_document_id);

END;
$$;

CREATE FUNCTION t_doc_documents_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT COALESCE(MAX(id) + 1, 1)
  INTO NEW.id
  FROM doc.doc_documents;

  NEW.published = TRUE;

  RETURN NEW;
END;
$$;

CREATE FUNCTION t_document_edits_ai() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE doc.doc_document_last_edit
  SET last_edit_id = NEW.id
  WHERE document_id = NEW.document_id
    AND lang_id     = NEW.lang_id;
END;
$$;

CREATE FUNCTION t_document_edits_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT COALESCE(MAX(DE.id) + 1, 1)
  INTO NEW.edit_id
  FROM doc.doc_document_edits DE
  WHERE DE.document_id = NEW.document_id
    AND DE.lang_id     = NEW.lang_id;

  NEW.date_created = df.fn_df_utc_timestamp();

  RETURN NEW;
END;
$$;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE doc_document_edits (
    document_id df.df_id NOT NULL,
    lang_id df.df_id NOT NULL,
    edit_id df.df_id NOT NULL,
    content df.df_text NOT NULL,
    date_created df.df_timestamp NOT NULL
);

CREATE TABLE doc_document_last_edit (
    document_id df.df_id NOT NULL,
    last_edit_id df.df_id NOT NULL,
    lang_id df.df_id NOT NULL,
    title df.df_string_large NOT NULL
);

CREATE TABLE doc_documents (
    id df.df_id NOT NULL,
    name df.df_string_short NOT NULL,
    published df.df_boolean NOT NULL
);
ALTER TABLE ONLY doc_documents ALTER COLUMN name SET STATISTICS 0;
ALTER TABLE ONLY doc_documents ALTER COLUMN published SET STATISTICS 0;

CREATE TABLE doc_lang (
    id df.df_id NOT NULL,
    code character varying(3) NOT NULL
);

ALTER TABLE ONLY doc_document_edits
    ADD CONSTRAINT pk_doc_document_edits PRIMARY KEY (document_id, lang_id, edit_id);

ALTER TABLE ONLY doc_documents
    ADD CONSTRAINT pk_doc_documents PRIMARY KEY (id);

ALTER TABLE ONLY doc_lang
    ADD CONSTRAINT pk_doc_lang PRIMARY KEY (id);

ALTER TABLE ONLY doc_document_last_edit
    ADD CONSTRAINT pk_document_last_edit PRIMARY KEY (document_id, lang_id);

ALTER TABLE ONLY doc_document_last_edit
    ADD CONSTRAINT uq_doc_document_last_edit UNIQUE (document_id, lang_id, last_edit_id);

ALTER TABLE ONLY doc_documents
    ADD CONSTRAINT uq_doc_documents UNIQUE (name);

ALTER TABLE ONLY doc_lang
    ADD CONSTRAINT uq_doc_lang UNIQUE (code);

CREATE TRIGGER t_doc_documents_bi
    BEFORE INSERT ON doc_documents
    FOR EACH ROW
    EXECUTE PROCEDURE t_doc_documents_bi();

CREATE TRIGGER t_document_edits_ai
    AFTER INSERT ON doc_document_edits
    FOR EACH ROW
    EXECUTE PROCEDURE t_document_edits_ai();

CREATE TRIGGER t_document_edits_bi
    BEFORE INSERT ON doc_document_edits
    FOR EACH ROW
    EXECUTE PROCEDURE t_document_edits_bi();

ALTER TABLE ONLY doc_document_edits
    ADD CONSTRAINT fk_doc_document_edits__doc_document_last_edit FOREIGN KEY (document_id, lang_id) REFERENCES doc_document_last_edit(document_id, lang_id);

ALTER TABLE ONLY doc_document_edits
    ADD CONSTRAINT fk_doc_document_edits__doc_lang FOREIGN KEY (lang_id) REFERENCES doc_lang(id);

ALTER TABLE ONLY doc_document_last_edit
    ADD CONSTRAINT fk_doc_document_last_edit__doc_document_edits FOREIGN KEY (document_id, lang_id, last_edit_id) REFERENCES doc_document_edits(document_id, lang_id, edit_id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY doc_document_last_edit
    ADD CONSTRAINT fk_doc_document_last_edit__doc_documents FOREIGN KEY (document_id) REFERENCES doc_documents(id);
