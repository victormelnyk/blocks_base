
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = doc, pg_catalog;

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE doc_documents DISABLE TRIGGER ALL;

ALTER TABLE doc_documents ENABLE TRIGGER ALL;

ALTER TABLE doc_languages DISABLE TRIGGER ALL;

ALTER TABLE doc_languages ENABLE TRIGGER ALL;

ALTER TABLE doc_document_edits DISABLE TRIGGER ALL;

ALTER TABLE doc_document_edits ENABLE TRIGGER ALL;

ALTER TABLE doc_document_last_edits DISABLE TRIGGER ALL;

ALTER TABLE doc_document_last_edits ENABLE TRIGGER ALL;
