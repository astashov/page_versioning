require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::SnippetController do
  integrate_views
  scenario :users
  before(:each) do
    @snippet = Snippet.create(valid_snippet_params)
    login_as users(:admin)
  end
  
  it "should get edit page with second revision" do
    @snippet.name = "some_another_title"
    @snippet.save!
    get :edit, :id => @snippet.id, :revision => 2
    assert_response :success
    response.should render_template("edit")
    response.should have_tag("#snippet_name[value=some_another_title]")
  end
  
  it "should get edit page with all necessary revision controls (select boxes, etc.)" do
    get :edit, :id => @snippet.id
    response.should have_tag("select#revisions")
    response.should have_tag("select#snippet_published_revision_number")
    response.should have_tag("input[value=Save and Preview]")
  end

  it "should get edit page with last revision if given revision is not existed" do
    @snippet.name = "some_another_title"
    @snippet.save!
    get :edit, :id => @snippet.id, :revision => 16
    assert_response :success
    response.should have_tag("#snippet_name[value=some_another_title]")
  end  
  
  it "should create revision even without changes when preview" do
    previous_length = @snippet.revisions.length
    post :edit, :id => @snippet.id, :preview => "Save and Preview", 
      :snippet => { :published_revision_number => 2 }
    @snippet.reload
    @snippet.revisions.length.should == previous_length + 1
  end
  
  it "should save without publishing when preview the layout" do
    @snippet.published_revision_number = 1
    @snippet.save
    post :edit, :id => @snippet.id, :preview => "Save and Preview", 
      :snippet => { :name => "Title", :published_revision_number => 2 }
    @snippet.reload
    @snippet.published_revision_number.should == 1
  end
  
  it "should show preview when preview the layout" do
    post :edit, :id => @snippet.id, :preview => "Preview a Page", 
      :snippet => { :name => "Title", :published_revision_number => 2 }
    assert_redirected_to preview_url(:id => @snippet.id, :action => 'snippet')
  end
  
  it "should show errors when required fields is not filled" do
    post :edit, :id => @snippet.id, :preview => "Preview a Page", 
      :snippet => { :name => "", :published_revision_number => 2 }
    assert_response :success 
    response.should render_template("edit")
  end
  
end