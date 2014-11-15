SELECT
  DE.content,
  DE.page_title,
  DE.page_meta
FROM doc.doc_documents D
  INNER JOIN doc.doc_document_last_edits DLE
    ON  DLE.document_id = D.document_id
    AND DLE.language_id = doc.fn_doc_language_id_get(:code, :language_code)
  INNER JOIN doc.doc_document_edits DE
    ON  DE.document_id = DLE.document_id
    AND DE.language_id = DLE.language_id
    AND DE.edit_id     = DLE.last_edit_id
<?p($where)?>