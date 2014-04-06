<?php
cPage::moduleAdd('blocks/lib/db_view/view/.php');

class cBlocksBase_Documents_DocumentView extends cBlocks_DbView_View
{
  public function build()
  {
    $lContent = '';

    if (count($this->owner->recordset))
    {
      $lRecord = $this->owner->recordset[0];
      $lContent = $lRecord['content'];

      if (isset($lRecord['page_title']))
        $this->page->title .= ($this->page->title ? ' ' : '').
          $lRecord['page_title'];
      if (isset($lRecord['page_meta']))
        $this->page->meta .= '<meta name="description" content="'.
          $lRecord['page_meta'].'">';
    }

    return $this->templateProcess($this->fileFirstExistDataGet('.htm'), array(
      'content' => $lContent
    ));
  }
}
?>