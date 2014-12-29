<?
Page::addModule('blocks/lib/db_view/view/.php');

class BlocksBase_Documents_DocumentView extends Blocks_DbView_View
{
  public function build()
  {
    $lContent = '';

    if (count($this->owner->recordset))
    {
      $lRecord = $this->owner->recordset[0];
      $lContent = $this->processStringTags($lRecord['content'], array());

      if (isset($lRecord['page_title']))
        $this->page->title = $lRecord['page_title'];
      if (isset($lRecord['page_meta']))
        $this->page->meta .= '<meta name="description" content="'.
          $lRecord['page_meta'].'">';
    }

    return $this->templateProcess($this->getFirstExistFileData('.htm'), array(
      'content' => $lContent
    ));
  }
}
?>