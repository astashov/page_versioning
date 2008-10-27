require File.dirname(__FILE__) + '/../spec_helper'

describe PageRevision do
  
  it "should contain parts" do
    @page = Page.create(valid_page_params)
    @page.parts.create(:name => "body", :content => "body content")
    @page.parts.create(:name => "extended", :content => "extended content")
    @page.title = "Uga-buga!"
    page_save(@page)
    
    page_revision = PageRevision.find_by_page_id_and_number(@page.id, 1)
    page_revision.parts.size.should == 2
    page_revision.parts.map(&:page_id).should == [ @page.id, @page.id ]
  end
  
end
  