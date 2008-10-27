require File.dirname(__FILE__) + '/../spec_helper'

describe Layout do
  
  before(:each) do
    @layout = Layout.new(valid_layout_params)
  end
  
  it "should be valid" do    
    @layout.should be_valid
  end
  
  it "should be saved" do
    Layout.exists?(valid_layout_params).should == false
    @layout.save.should == true
    Layout.exists?(valid_layout_params).should == true
  end
  
  it "should create first LayoutRevision when Layout is creating" do
    @layout.save
    LayoutRevision.exists?(valid_layout_revision_params).should == true
    revisions = LayoutRevision.find(:all, :conditions => valid_layout_revision_params)
    revisions.length.should == 1
    revisions[0].number.should == 1
  end

  it "should create second LayoutRevision when Layout is updating" do
    @layout.save
    @layout.name = "Change the name"
    @layout.save
    @layout.reload
    @layout.revisions.length.should == 2
  end
  
  it "should create second LayoutRevision with number = 2 when Layout is updating" do
    @layout.save
    @layout.name = "Change the title"
    @layout.save
    @layout.reload
    @layout.revisions[1].number.should == 2
  end
  
  it "should not create second LayoutRevision when fields are not changed" do
    @layout.save
    @layout.save
    @layout.reload
    @layout.revisions.length.should == 1
  end
  
  it "should destroy all dependant LayoutRevisions when Layout is deleted" do
    @layout.save
    @layout.name = "Change the title"
    @layout.save
    revision_ids = @layout.revisions.map {|r| r.id}
    Layout.destroy(@layout.id)
    LayoutRevision.find(:all, :conditions => {:id => revision_ids}).should == []
  end
  
  it "attributes should show as attributes of published revision" do
    @layout.save
    @layout.name = "First change"
    @layout.save
    @layout.name = "Second change"
    @layout.save
    @layout.published_revision_number = 2
    @layout.save
    @layout.reload
    @layout.name.should == "First change"
  end
  
  it "should set published_revision_number to newly created revision id when published_revision_number contains '0' and revisioned attributes were changed" do
    @layout.save
    @layout.name = "First change"    
    @layout.published_revision_number = 0
    @layout.save
    published_revision = LayoutRevision.find_by_layout_id_and_number(@layout.id, @layout.number_of_last_revision)
    @layout.published_revision_number.should == published_revision.number
  end
  
  it "should set published_revision_number to last revision id when published_revision_number contains '0' and revisioned attributes weren't changed" do
    @layout.save
    @layout.published_revision_number = 0
    @layout.save
    published_revision = LayoutRevision.find_by_layout_id_and_number(@layout.id, @layout.number_of_last_revision)
    @layout.published_revision_number.should == published_revision.number
  end
  
end