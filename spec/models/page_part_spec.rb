require File.dirname(__FILE__) + '/../spec_helper'

describe PagePart do
  
  before(:each) do
    @page = Page.new(valid_page_params)
    @page.parts << PagePart.new(valid_page_part_params)
    page_save(@page)
    @page_part = @page.part("New page part")
  end
  
  it "should be valid" do    
    @page_part.should be_valid
  end
  
  it "should be saved" do
    PagePart.exists?(valid_page_part_params).should == true
  end
  
  it "should create PagePartRevision when PagePart is saved" do
    PagePartRevision.exists?(valid_page_part_revision_params).should == true
    @page_part.revisions.length.should == 1
  end
  
  it "should not create PagePartRevision when PageParts is not changed" do
    page_save(@page)
    @page_part.revisions.length.should == 1
  end
  
  it "should create PagePartRevision when PagePart is updated" do
    @page.parts[0].content = "Change content!"
    page_save(@page)
    @page_part.revisions.length.should == 2
  end
  
  it "should create PagePartRevision even if only filter_id of PagePart is updated" do
    @page.parts[0].filter_id = "Markdown"
    page_save(@page)
    @page.reload
    @page.parts[0].last_revision.filter_id.should == "Markdown"
  end
  
  it "should create PagePartRevision when Page is updated" do
    @page.slug = "another-slug"
    page_save(@page)
    @page_part.revisions.length.should == 2
  end
  
  it "attributes should show as attributes of published revision" do
    @page.slug = "another-slug"
    page_save(@page)
    @page.parts[0].content = "First change of content!"
    page_save(@page)
    @page.parts[0].content = "Second change of content!"
    page_save(@page)
    @page.published_revision_number = PageRevision.find_by_page_id_and_number(@page.id, 3).number
    page_save(@page)
    @page.reload
    @page.parts[0].content.should == "First change of content!"
  end
  
end