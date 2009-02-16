require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PagesController do
  integrate_views
  before do
    @page = Page.create!(valid_page_params)
    @page.parts.create!(:name => "body", :content => "body content")
    @page.parts.create!(:name => "extended", :content => "extended content")
    @page.title = "Uga-buga!"
    page_save(@page)
    @user = User.create!(:name => "Administrator", :login => "admin", :password => "test1", :password_confirmation => "test1")
    login_as @user
  end  
  
  it "should get edit page with second revision of Page" do
    get :edit, :id => @page.id, :revision => 2
    response.should be_success 
    response.should render_template("edit")
    response.should have_tag("#page_title[value=Uga-buga!]")
  end
  
  it "should get edit page with last revision if given revision is not existed" do
    get :edit, :id => @page.id, :revision => 16
    response.should be_success 
    response.should have_tag("#revisions option[selected=selected]", "2")
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
  
  it "should not create revision without changes when preview" do
    lambda do
      lambda do 
        post :edit, :id => @page.id, :preview => "Preview a Page", 
          :page => { :published_revision_number => 2 }
      end.should_not change(@page.reload.revisions, :length)
    end.should_not change(@page.reload, :published_revision_number)
  end
  
  it "should save without publishing when preview the page" do
    page_save(@page)
    lambda do
      post :edit, :id => @page.id, :preview => "Preview a Page", 
        :page => { :title => "Title", :published_revision_number => 2 }
    end.should_not change(@page.reload, :published_revision_number)
  end
  
  it "should show preview when preview the page" do
    put :update, :id => @page.id, :preview => "Preview a Page", 
      :page => { :title => "Title", :published_revision_number => 2 }
    response.should redirect_to(preview_url(:id => @page.id, :action => 'page'))
  end
  
  it "should show errors when required fields is not filled" do
    put :update, :id => @page.id, :preview => "Preview a Page", 
      :page => { :title => "", :published_revision_number => 2 }
    response.should be_success 
    response.should render_template("edit")
  end
  
end