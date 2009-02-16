require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::LayoutsController do
  integrate_views
  
  before do
    @layout = Layout.create!(valid_layout_params)
    @user = User.create!(:name => "Administrator", :login => "admin", :password => "test1", :password_confirmation => "test1")
    login_as @user
  end
  
  it "should get edit page with second revision" do
    @layout.name = "Some another title"
    @layout.save!
    get :edit, :id => @layout.id, :revision => 2
    response.should be_success
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
    response.should be_success
    response.should have_tag("#layout_name[value=Some another title]")
  end
  
  it "should not create revision without changes and don't change pulished revision number when preview" do
    @layout.update_attribute(:published_revision_number, 1)
    lambda do
      lambda do
        put :update, :id => @layout.id, :preview => "Save and Preview", :layout => { :published_revision_number => 2 }
      end.should_not change(@layout.reload.revisions, :length)
    end.should_not change(@layout.reload, :published_revision_number)
  end
  
  it "should save without publishing when preview the layout" do
    @layout.update_attribute(:published_revision_number, 1)
    lambda do
      put :update, :id => @layout.id, :preview => "Save and Preview", 
        :layout => { :name => "Title", :published_revision_number => 2 }
    end.should_not change(@layout.reload, :published_revision_number)
  end
  
  it "should show preview when preview the layout" do
    put :update, :id => @layout.id, :preview => "Preview a Page", 
      :layout => { :name => "Title", :published_revision_number => 2 }
    response.should redirect_to(preview_url(:id => @layout.id, :action => 'layout'))
  end
  
  it "should show errors when required fields is not filled" do
    put :update, :id => @layout.id, :preview => "Preview a Page", 
      :layout => { :name => "", :published_revision_number => 2 }
    response.should be_success
    response.should render_template("edit")
  end
  
end