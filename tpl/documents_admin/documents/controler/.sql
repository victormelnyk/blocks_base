SELECT
  D.document_id,
  L.language_id,
  D.name document_name,
  L.code language_code,
  '' state,
  DE.page_title,
  df.fn_df_timestamp_to_str(DE.date_created) date_created,
  D.is_published,
  D.is_deleted
FROM doc.doc_documents D
  INNER JOIN doc.doc_languages L
    ON TRUE
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