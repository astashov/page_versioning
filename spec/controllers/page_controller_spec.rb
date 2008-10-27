require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PageController do
  integrate_views
  scenario :users
  before(:each) do
    @page = Page.create(valid_page_params)
    @page.parts.create(:name => "body", :content => "body content")
    @page.parts.create(:name => "extended", :content => "extended content")
    @page.title = "Uga-buga!"
    page_save(@page)
    login_as users(:admin)
  end  
  
  it "should get edit page with second revision of Page" do
    get :edit, :id => @page.id, :revision => 2
    assert_response :success
    response.should render_template("edit")
    response.should have_tag("#page_title[value=Uga-buga!]")
  end
  
  it "should get edit page with last revision if given revision is not existed" do
    get :edit, :id => @page.id, :revision => 16
    assert_response :success
    response.should have_tag("#page_title[value=Uga-buga!]")
  end
  
  it "should get edit page with all necessary revision controls (select boxes, etc.)" do
    get :edit, :id => @page.id, :revision => 2
    response.should have_tag("select#revisions")
    response.should have_tag("select#page_published_revision_number")
    response.should have_tag("input[value=Save and Preview]")
  end
  
  it "should get edit page with published revision by default" do
    get :edit, :id => @page.id
    assert_response :success
    response.should render_template("edit")
    response.should have_tag("#page_title[value=New Page]")
  end
  
  it "should create revision even without changes when preview" do
    previous_length = @page.revisions.length
    post :edit, :id => @page.id, :preview => "Preview a Page", 
      :page => { :published_revision_number => 2 }
    @page.reload
    @page.revisions.length.should == previous_length + 1
  end
  
  it "should save without publishing when preview the page" do
    @page.published_revision_number = 1
    page_save(@page)
    post :edit, :id => @page.id, :preview => "Preview a Page", 
      :page => { :title => "Title", :published_revision_number => 2 }
    @page.reload
    @page.published_revision_number.should == 1
  end
  
  it "should show preview when preview the page" do
    post :edit, :id => @page.id, :preview => "Preview a Page", 
      :page => { :title => "Title", :published_revision_number => 2 }
    assert_redirected_to preview_url(:id => @page.id, :action => 'page')
  end
  
  it "should show errors when required fields is not filled" do
    post :edit, :id => @page.id, :preview => "Preview a Page", 
      :page => { :title => "", :published_revision_number => 2 }
    assert_response :success 
    response.should render_template("edit")
  end
  
end