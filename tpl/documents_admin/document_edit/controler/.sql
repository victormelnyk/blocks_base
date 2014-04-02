SELECT
  D.document_id,
  L.language_id,
  L.code language_code,
  D.name document_name,
  DE.content,
  DE.page_title,
  DE.page_meta,
  D.is_published,
  D.is_deleted
FROM doc.doc_documents D
  INNER JOIN doc.doc_languages L
    ON L.language_id = :language_id
  LEFT JOIN doc.doc_document_last_edits DLE
    ON  DLE.document_id = D.document_id
    AND DLE.language_id = L.language_id
  LEFT JOIN doc.doc_document_edits DE
    ON  DE.document_id = DLE.document_id
    AND DE.language_id = DLE.language_id
    AND DE.edit_id     = DLE.last_edit_id
<?p($where);?>
<?p($order);?>
<?p($limit);?>