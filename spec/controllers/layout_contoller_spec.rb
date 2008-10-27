require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::LayoutController do
  integrate_views
  scenario :users
  before(:each) do
    @layout = Layout.create(valid_layout_params)
    login_as users(:admin)
  end
  
  it "should get edit page with second revision" do
    @layout.name = "Some another title"
    @layout.save!
    get :edit, :id => @layout.id, :revision => 2
    assert_response :success
    response.should render_template("edit")
    response.should have_tag("#layout_name[value=Some another title]")
  end
  
  it "should get edit page with all necessary revision controls (select boxes, etc.)" do
    get :edit, :id => @layout.id
    response.should have_tag("select#revisions")
    response.should have_tag("select#layout_published_revision_number")
    response.should have_tag("input[value=Save and Preview]")
  end
  
  it "should get edit page with last revision if given revision is not existed" do
    @layout.name = "Some another title"
    @layout.save!
    get :edit, :id => @layout.id, :revision => 16
    assert_response :success
    response.should have_tag("#layout_name[value=Some another title]")
  end
  
  it "should create revision even without changes when preview" do
    previous_length = @layout.revisions.length
    post :edit, :id => @layout.id, :preview => "Save and Preview", 
      :layout => { :published_revision_number => 2 }
    @layout.reload
    @layout.revisions.length.should == previous_length + 1
  end
  
  it "should save without publishing when preview the layout" do
    @layout.published_revision_number = 1
    @layout.save
    post :edit, :id => @layout.id, :preview => "Save and Preview", 
      :layout => { :name => "Title", :published_revision_number => 2 }
    @layout.reload
    @layout.published_revision_number.should == 1
  end
  
  it "should show preview when preview the layout" do
    post :edit, :id => @layout.id, :preview => "Preview a Page", 
      :layout => { :name => "Title", :published_revision_number => 2 }
    assert_redirected_to preview_url(:id => @layout.id, :action => 'layout')
  end
  
  it "should show errors when required fields is not filled" do
    post :edit, :id => @layout.id, :preview => "Preview a Page", 
      :layout => { :name => "", :published_revision_number => 2 }
    assert_response :success 
    response.should render_template("edit")
  end
  
end