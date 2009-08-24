require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  
  before(:each) do
    @page = Page.new(valid_page_params)
  end
  
  it "should be valid" do    
    @page.should be_valid
  end
  
  it "should be saved" do
    Page.exists?(valid_page_params).should == false
    page_save(@page) ? (true.should == true) : violated
    Page.exists?(valid_page_params).should == true
  end
  
  it "should create first PageRevision when Page is creating" do
    page_save(@page)
    PageRevision.exists?(valid_page_revision_params).should == true
    revisions = PageRevision.find(:all, :conditions => valid_page_revision_params)
    revisions.length.should == 1
    revisions[0].number.should == 1
  end
  
  it "should create second PageRevision when Page is updating" do
    page_save(@page)
    @page.title = "Change the title"
    page_save(@page)
    @page.reload
    @page.revisions.length.should == 2
  end

  it "should create second PageRevision with number = 2 when Page is updating" do
    page_save(@page)
    @page.title = "Change the title"
    page_save(@page)
    @page.reload
    @page.revisions[1].number.should == 2
  end
  
  it "should create second PageRevision when new PagePart is created" do
    page_save(@page)
    @page.parts.build(:name => "body", :content => "BODY!")
    page_save(@page)
    @page.reload
    @page.revisions.length.should == 2
  end
  
  it "should create PageRevision when PagePart is updated" do
    page_save(@page)
    @page.parts.build(:name => "body", :content => "BODY!")
    page_save(@page)
    @page.parts[0].content = "Change!"
    page_save(@page)
    @page.reload
    @page.revisions.length.should == 3
  end
  
  it "should create PageRevision when one of two PagePart is deleted)" do
    page_save(@page)
    @page.parts.build(:name => "body", :content => "BODY!")
    page_save(@page)
    @page.parts.build(:name => "extended", :content => "Extended!")
    page_save(@page)
    @page.update_attributes!(:parts_attributes => [ 
      { :name => "body", :id => @page.parts.first.id, :_delete => false, :content => "BODY!" },
      { :id => @page.parts.second.id, :_delete => true }
    ])
    page_save(@page)
    @page.reload
    @page.revisions.length.should == 4
  end  
  
  it "should not create second PageRevision when not revisioned fields are changed" do
    page_save(@page)
    @page.status_id = 2
    page_save(@page)
    @page.reload
    @page.revisions.length.should == 1
    @page.status_id.should == 2
  end

  it "should destroy all dependant PageRevisions when Page is deleted" do
    page_save(@page)
    @page.title = "Change the title"
    page_save(@page)
    revision_ids = @page.revisions.map {|r| r.id}
    Page.destroy(@page.id)
    PageRevision.find(:all, :conditions => {:id => revision_ids}).should == []
  end
  
  it "should destroy all dependant PageParts when Page is deleted" do
    page_save(@page)
    @page.title = "Change the title"
    page_save(@page)
    @page.parts.build(:name => "body", :content => "Body!")
    page_save(@page)
    Page.destroy(@page.id)
    PagePart.find(:all, :conditions => {:page_id => @page.id}).should == []
  end
  
  it "should destroy all dependant PagePartRevisions when Page is deleted" do
    page_save(@page)
    @page.title = "Change the title"
    page_save(@page)
    @page.parts.build(:name => "body", :content => "Body!")
    page_save(@page)
    Page.destroy(@page.id)
    PagePartRevision.find(:all, :conditions => {:page_id => @page.id}).should == []
  end
  
  it "last_revision should be nil when Page is not created yet" do
    @page.last_revision.should be_nil
  end
  
  it "number of last_revision should be equal 1 when Page is created" do
    page_save(@page)
    @page.last_revision.number.should == 1
  end
  
  it "number of last_revision should be equal 2 when Page is updated" do
    page_save(@page)
    @page.title = "Change the title"
    page_save(@page)
    @page.last_revision.number.should == 2
  end
  
  it "attributes should show as attributes of published revision" do
    page_save(@page)
    @page.title = "First change"
    page_save(@page)
    @page.title = "Second change"
    page_save(@page)
    @page.published_revision_number = PageRevision.find_by_page_id_and_number(@page.id, 2).number
    page_save(@page)
    @page.reload
    @page.title.should == "First change"
  end
  
  it "should set published_revision_id to newly created revision id when published_revision_id contains '0' and revisioned attributes were changed" do
    page_save(@page)
    @page.title = "Change title"
    @page.published_revision_number = 0
    page_save(@page)
    published_revision = PageRevision.find_by_page_id_and_number(@page.id, @page.last_revision.number)
    @page.published_revision_number.should == published_revision.number
  end
  
  it "should set published_revision_id to last revision id when published_revision_id contains '0' and revisioned attributes weren't changed" do
    page_save(@page)
    @page.published_revision_number = 0
    page_save(@page)
    published_revision = PageRevision.find_by_page_id_and_number(@page.id, @page.last_revision.number)
    @page.published_revision_number.should == published_revision.number
  end
  
  it "should return true if it contains the snippet" do
    snippet = mock_model(Snippet, :name => "snippet_name")
    page_save(@page)
    @page.parts.build(:name => "body", :content => "Somewhere <r:snippet name=\"snippet_name\" /> is the snipper here...")
    @page.contains_snippet?(snippet).should be_true
    @page.parts.first.content = "Somewhere is not..."
    @page.contains_snippet?(snippet).should_not be_true
    @page.layout = mock_model(Layout, :name => "layout", :content => "Snippet.... <r:snippet name=\"snippet_name\" />")
    @page.contains_snippet?(snippet).should be_true
  end
  
  it "should set preview to true or false" do
    page_save(@page)
    @page.is_preview.should be_false
    Page.set_preview(@page.id, true)
    @page.reload.is_preview.should be_true
    Page.set_preview(@page.id, false)
    @page.reload.is_preview.should be_false
  end

end
