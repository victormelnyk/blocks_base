<?php
cPage::moduleAdd('blocks/lib/edit_form/db_form/.php');

class cBlocksBase_Documents_DocumentEdit extends cBlocks_EditForm_DbForm
{
  protected function delete()
  {
    notSupportedRaise();
  }

  protected function save()
  {
    $lDb = $this->settings->db;
    $lSqlParams = array();
    $lNewSqlParams = array();

    $this->form->sqlBuildAndParamGetForSaveMode($lSqlParams);
    $lIsDocumentExist = $this->form->sqlKeysExist();

    $lDb->beginTran();
    try
    {
      $lNewSqlParams['name']         = $lSqlParams['document_name'];
      $lNewSqlParams['is_published'] = $lSqlParams['is_published'];
      $lNewSqlParams['is_deleted']   = $lSqlParams['is_deleted'];

      if ($lIsDocumentExist)
      {
        $lDocumentID = $lSqlParams['document_id'];
        $lSql = $lDb->sqlUpdateBuild('doc.doc_documents',
          $lNewSqlParams, array('document_id' => $lDocumentID));
        $lDb->execute($lSql, $lNewSqlParams);
      }
      else
      {
        $lSql = $lDb->sqlInsertBuild('doc.doc_documents', $lNewSqlParams).CRLF.
          'RETURNING document_id';
        $lDb->executeValue($lSql, 'document_id', $lDocumentID, $lNewSqlParams,
          VAR_TYPE_INTEGER);
      }

      $lNewSqlParams = array();

      $lNewSqlParams['document_id'] = $lDocumentID;
      $lNewSqlParams['language_id'] = $lSqlParams['language_id'];
      $lNewSqlParams['content']     = $lSqlParams['content'];
      $lNewSqlParams['page_title']  = $lSqlParams['page_title'];
      $lNewSqlParams['page_meta']   = $lSqlParams['page_meta'];

      $lSql = $lDb->sqlInsertBuild('doc.doc_document_edits', $lNewSqlParams);
      $lDb->execute($lSql, $lNewSqlParams);

      $lDb->commitTran();
    }
    catch (Exception $e)
    {
      $lDb->rollbackTran();
      throw $e;
    }
  }
}
?>