
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = bl, pg_catalog;

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE bl_types DISABLE TRIGGER ALL;

INSERT INTO bl_types (f_boolean, f_id, f_integer, f_interval, f_money, f_smallint, f_string_large, f_string_short, f_text, f_tinestamp, f_tinyint, f_tinyint_id) VALUES (true, 1, 1, '02:00:00', 7.56, 2, 'String Large', 'String Short', 'Text', '2014-11-15 20:07:21', 3, 3);
INSERT INTO bl_types (f_boolean, f_id, f_integer, f_interval, f_money, f_smallint, f_string_large, f_string_short, f_text, f_tinestamp, f_tinyint, f_tinyint_id) VALUES (false, 10, 10, '2 days', 10.20, 20, 'String Large 2', 'String Short 2', 'Text 2', '2014-11-15 20:08:53', 30, 30);

ALTER TABLE bl_types ENABLE TRIGGER ALL;

SET search_path = doc, pg_catalog;

ALTER TABLE doc_documents DISABLE TRIGGER ALL;

ALTER TABLE doc_documents ENABLE TRIGGER ALL;

ALTER TABLE doc_languages DISABLE TRIGGER ALL;

ALTER TABLE doc_languages ENABLE TRIGGER ALL;

ALTER TABLE doc_document_edits DISABLE TRIGGER ALL;

ALTER TABLE doc_document_edits ENABLE TRIGGER ALL;

ALTER TABLE doc_document_last_edits DISABLE TRIGGER ALL;

ALTER TABLE doc_document_last_edits ENABLE TRIGGER ALL;
