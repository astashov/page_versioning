require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PreviewController do
  scenario :users
  before(:each) do
    @page = Page.create(valid_page_params)
    @page.title = "Changed"
    @page.save
    login_as users(:admin)
  end  
  
  it "should show preview of pages" do
    get :page, :id => @page.id, :preview => "Save and Preview"
    assert_response :success 
    assigns[:page].title.should == "Changed"
  end
  
  it "should show preview of layout" do
    @layout = Layout.create(valid_layout_params)
    @layout.name = "Changed"
    @layout.is_preview = true
    @layout.save
    get :layout, :id => @layout.id, :page_to_preview => @page.id, :preview => "Save and Preview"
    assert_response :success 
    assigns[:layout].name.should == "Changed"
  end
  
  it "should show preview of snippet" do
    @snippet = Snippet.create(valid_snippet_params)
    @snippet.name = "changed"
    @snippet.is_preview = true
    @snippet.save
    get :snippet, :id => @snippet.id, :page_to_preview => @page.id, :preview => "Save and Preview"
    assert_response :success 
    assigns[:snippet].name.should == "changed"
  end
  
end