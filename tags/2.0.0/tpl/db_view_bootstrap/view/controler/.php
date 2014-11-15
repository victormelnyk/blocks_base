<?php
function recordsetPostProcess(&$aRecordset, $aControler)
{
  $lKeys = $aControler->filter->keyOptionsAsNameSqlFieldNameArrayGet();
  $lKeyCount = count($lKeys);

  for ($i = 0, $l = count($aRecordset); $i < $l; $i++)
  {
    $lRecord = $aRecordset[$i];
    $lKeyParams = '';
    $lKeyIndex = 0;

    foreach ($lKeys as $lName => $lSql)
    {
      $lKeyParams .= $lName.'='.$lRecord[$lSql].
        ($lKeyIndex < $lKeyCount - 1 ? '&' : '');
      $lKeyIndex++;
    }

    $lRecord['key_params'] = $lKeyParams;

    $aRecordset[$i] = $lRecord;
  }
}
?>