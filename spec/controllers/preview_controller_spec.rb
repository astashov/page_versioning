require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PreviewController do
  integrate_views
  before do
    @page = Page.create!(valid_page_params)
    @page.update_attributes!(
      :title => "Changed", 
      :parts => [{:name => "body", :content => "Lalala"}], 
      :published_revision_number => @page.published_revision_number + 1 
    )
    @user = User.create!(:name => "Administrator", :login => "admin", :password => "test1", :password_confirmation => "test1")
    login_as @user
  end  
  
  it "should show preview of pages" do
    @page.update_attributes!(:parts => [:name => "body", :content => "Fafafa"])
    get :page, :id => @page.id, :action => "edit"
    response.should be_success
    response.body.should include("Fafafa")
    @page.reload.is_preview.should be_false
    @page.part(:body).content.should == "Lalala"
  end
  
  it "should show preview of layout" do
    @layout = Layout.create!(valid_layout_params)
    @page.update_attributes!(:layout => @layout, :published_revision_number => @page.published_revision_number + 1)
    @layout.update_attributes!(:pages => [ @page ])
    @layout.update_attributes!(:content => 'Changed: <r:content part="body" />')
    get :layout, :id => @layout.id, :page_to_preview => @page.id, :preview => "Save and Preview"
    response.should be_success
    response.body.should include("Changed: Lalala")
    @layout.reload.is_preview.should be_false
    @layout.content.should == "Content of New Layout"
  end
  
  it "should show preview of snippet" do
    @snippet = Snippet.create!(valid_snippet_params)
    @page.update_attributes!(
      :parts => [{:name => "body", :content => 'Fafafa <r:snippet name="new_snippet" />'}], 
      :published_revision_number => @page.published_revision_number + 1)
    @snippet.update_attributes!(:content => 'Lalala')
    get :snippet, :id => @snippet.id, :page_to_preview => @page.id, :preview => "Save and Preview"
    response.should be_success
    response.body.should include("Fafafa Lalala")
    @snippet.reload.is_preview.should be_false
    @snippet.content.should == "Content of New Snippet"
  end
  
end