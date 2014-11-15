<?php
cPage::moduleAdd('blocks/lib/edit_form/db_form/.php');

class cBlocksBase_Images_ImageEdit extends cBlocks_EditForm_DbForm
{
  private $originalFlpTemplate = '';
  private $fileEdits = array();

  protected function delete()
  {
    notSupportedRaise();
  }

  public function fileOptionGet()
  {
    for ($i = 0, $l = $this->form->options->count(); $i < $l; $i++)
    {
      $lOption = $this->form->options->getByI($i);
      if ($lOption->inputType == INPUT_TYPE_FILE)
        return $lOption;
    }

    throw new Exception('FilePprion not set');
  }

  private function fileSave()
  {
    $lFileOption = $this->fileOptionGet();
    $lKeyOptions = $this->form->keyOptionsNamesValuesGet();
    $lFileFlp = tagsReplaceArray($this->originalFlpTemplate, $lKeyOptions);

    eAssert(isset($_FILES[$lFileOption->name]), 'No info about loaded Image');//!!file
    $lImage = $_FILES[$lFileOption->name];
    eAssert($lImage['error'] == 0, 'Error loading Image code: "'.$lImage['error'].'"');
    forceDir($lFileFlp, true);
    move_uploaded_file($lImage['tmp_name'], $lFileFlp);

    for ($i = 0, $l = count($this->fileEdits); $i < $l; $i++)
    {
      $lFileEdit = $this->fileEdits[$i];
      $lFileEditFlp = tagsReplaceArray($lFileEdit['flp_template'], $lKeyOptions);
      cGdImageHelper::resize($lFileFlp, $lFileEditFlp,
        $lFileEdit['width'], $lFileEdit['height']);
    }

    //$lFileOption->isValueValid = true;
  }

  protected function save()
  {
    $lDb = $this->settings->db;
    $lSqlParams = array();
    $lSql = $this->form->sqlBuildAndParamGetForSaveMode($lSqlParams);
    $lIsExist = $this->form->sqlKeysExist();
    $lKeyOptions = $this->form->keyOptionsGet();

    $lDb->beginTran();
    try
    {
      if ($lIsExist)
        $lDb->execute($lSql, $lSqlParams);
      else
      {
        $lLastKeyOption = $lKeyOptions[count($lKeyOptions) - 1];
        $lLastKeyOptionValue = 0;
        $lSql .= CRLF.'RETURNING '.$lLastKeyOption->name;
        $lDb->executeValue($lSql, $lLastKeyOption->name, $lLastKeyOptionValue,
          $lSqlParams, VAR_TYPE_INTEGER);
        $lLastKeyOption->valueSetDirect($lLastKeyOptionValue);
      }

      $this->fileSave();

      $lDb->commitTran();
    }
    catch (Exception $e)
    {
      $lDb->rollbackTran();
      throw $e;
    }
  }

  protected function settingsRead(cXmlNode $aXmlNode)
  {
    parent::settingsRead($aXmlNode);

    $lFilesNode = $aXmlNode->nodes->nextGetByN('Files');

    $this->originalFlpTemplate =
      $lFilesNode->nodes->nextGetByN('OriginalFlpTemplate')->getS();

    while ($lFilesNode->nodes->nextGetCheck($lEditNode))
    {
      $this->fileEdits[] = array(
        'flp_template' => $lEditNode->getS(),
        'width'        => $lEditNode->attrs->nextGetByN('Width')->getI(),
        'height'       => $lEditNode->attrs->nextGetByN('Height')->getI(),
      );
    }
  }
}
?>