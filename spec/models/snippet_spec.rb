require File.dirname(__FILE__) + '/../spec_helper'

describe Snippet do
  
  before(:each) do
    @snippet = Snippet.new(valid_snippet_params)
  end
  
  it "should be valid" do    
    @snippet.should be_valid
  end
  
  it "should be saved" do
    Snippet.exists?(valid_snippet_params).should == false
    @snippet.save.should == true
    Snippet.exists?(valid_snippet_params).should == true
  end
  
  it "should create first SnippetRevision when Snippet is creating" do
    @snippet.save
    SnippetRevision.exists?(valid_snippet_revision_params).should == true
    revisions = SnippetRevision.find(:all, :conditions => valid_snippet_revision_params)
    revisions.length.should == 1
    revisions[0].number.should == 1
  end

  it "should create second SnippetRevision when Snippet is updating" do
    @snippet.save
    @snippet.name = "change_the_name"
    @snippet.save
    @snippet.reload
    @snippet.revisions.length.should == 2
  end
  
  it "should create second SnippetRevision with number = 2 when Snippet is updating" do
    @snippet.save
    @snippet.name = "change_the_name"
    @snippet.save
    @snippet.reload
    @snippet.revisions[1].number.should == 2
  end
  
  it "should not create second SnippetRevision when fields are not changed" do
    @snippet.save
    @snippet.save
    @snippet.reload
    @snippet.revisions.length.should == 1
  end
  
  it "should destroy all dependant SnippetRevision when Snippet is deleted" do
    @snippet.save
    @snippet.name = "change_the_name"
    @snippet.save
    revision_ids = @snippet.revisions.map {|r| r.id}
    Snippet.destroy(@snippet.id)
    SnippetRevision.find(:all, :conditions => {:id => revision_ids}).should == []
  end
  
  it "attributes should show as attributes of published revision" do
    @snippet.save
    @snippet.name = "first_change"
    @snippet.save
    @snippet.name = "second_change"
    @snippet.save
    @snippet.published_revision_number = SnippetRevision.find_by_snippet_id_and_number(@snippet.id, 2).number
    @snippet.save
    @snippet.reload
    @snippet.name.should == "first_change"
  end
  
  it "should set published_revision_number to newly created revision id when published_revision_number contains '0' and revisioned attributes were changed" do
    @snippet.save
    @snippet.name = "first_change"    
    @snippet.published_revision_number = 0
    @snippet.save
    published_revision = SnippetRevision.find_by_snippet_id_and_number(@snippet.id, @snippet.number_of_last_revision)
    @snippet.published_revision_number.should == published_revision.number
  end
  
  it "should set published_revision_number to last revision id when published_revision_number contains '0' and revisioned attributes weren't changed" do
    @snippet.save
    @snippet.published_revision_number = 0
    @snippet.save
    published_revision = SnippetRevision.find_by_snippet_id_and_number(@snippet.id, @snippet.number_of_last_revision)
    @snippet.published_revision_number.should == published_revision.number
  end
  
end