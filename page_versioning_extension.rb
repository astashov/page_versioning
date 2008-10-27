FIELDS = YAML.load_file(RAILS_ROOT + "/vendor/extensions/page_versioning/config/fields.yml")
require 'application'

module PageVersioning
  # We should disable versioning for test environment, because we can break some other tests
  # that don't know about published revisions. :) No worries, for PageVersioning specs it
  # will be enable in spec_helper file.
  @enable_versioning = ENV["RAILS_ENV"] == "test" ? false : true
  class << self
    attr_accessor :enable_versioning
  end
end

class PageVersioningExtension < Radiant::Extension
  version "0.1"
  description "Allows you to save and review all changes of the pages, snippets and layouts"
  url "http://yourwebsite.com/page_versioning"
  
  define_routes do |map|
    map.preview 'admin/preview/:action/:id', :controller => 'admin/preview'
  end
  
  def activate
    Admin::AbstractModelController.send :include, PageVersioning::AbstractModelControllerExtensions
    
    Page.send :include, PageVersioning::PageExtensions
    PagePart.send :include, PageVersioning::PagePartExtensions
    Admin::PageController.send :include, PageVersioning::PageControllerExtensions
    
    Layout.send :include, PageVersioning::LayoutExtensions
    
    Snippet.send :include, PageVersioning::SnippetExtensions
    Admin::SnippetHelper.send :include, PageVersioning::SnippetHelperExtensions
    
    ActionView::Base.send :include, PageVersioning::CommonHelpers

    admin.page.edit.add :parts_bottom, "publish_revision"
    admin.page.edit.add :main, "select_revision", :after => "edit_header"
    admin.page.edit.add :form_bottom, "preview_button", :after => "edit_buttons"
    
    admin.layout.edit.add :form_bottom, "publish_revision"
    admin.layout.edit.add :main, "select_revision", :after => "edit_header"
    admin.layout.edit.add :form_bottom, "preview_button", :after => "edit_buttons"
    
    admin.snippet.edit.add :form_bottom, "publish_revision"
    admin.snippet.edit.add :main, "select_revision", :after => "edit_header"
    admin.snippet.edit.add :form_bottom, "preview_button", :after => "edit_buttons"
  end
  
  def deactivate
  end
  
end