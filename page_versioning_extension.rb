require 'application_controller'
# Explicitly load all extensions of Radiant's controllers, models, helpers
Dir.glob(File.expand_path(File.dirname(__FILE__) + "/lib/**/*.rb")).each do |fullpath|
  require fullpath
end

module PageVersioning
  # We should disable versioning for test environment, because we can break some other tests
  # that don't know about published revisions. :) No worries, for PageVersioning specs it
  # will be enable in spec_helper file.
  @enable_versioning ||= ENV["RAILS_ENV"] == "test" ? false : true
  class << self
    attr_accessor :enable_versioning
  end
  Config = YAML.load_file(RAILS_ROOT + "/vendor/extensions/page_versioning/config/config.yml")
end

class PageVersioningExtension < Radiant::Extension
  version "0.2"
  description "Allows you to save and review all changes of the pages, snippets and layouts"
  url "http://github.com/astashov/page_versioning"
  
  define_routes do |map|
    map.preview 'admin/preview/:action/:id', :controller => 'admin/preview'
  end
  
  def activate
    if PageVersioning.enable_versioning
      Admin::ResourceController.send :include, PageVersioning::ResourceControllerExtensions

      Page.send :include, PageVersioning::PageExtensions if Page.connection.tables.include?("page_revisions")
      PagePart.send :include, PageVersioning::PagePartExtensions if PagePart.connection.tables.include?("page_part_revisions")
      Layout.send :include, PageVersioning::CommonRevisionExtensions if Layout.connection.tables.include?("layout_revisions")
      Snippet.send :include, PageVersioning::CommonRevisionExtensions if Snippet.connection.tables.include?("snippet_revisions")
      
      Admin::SnippetsHelper.send :include, PageVersioning::SnippetHelperExtensions
      ActionView::Base.send :include, PageVersioning::CommonHelpers

      admin.page.edit.add :parts_bottom, "publish_revision"
      admin.page.edit.add :main, "select_revision", :after => "edit_header"
      admin.page.edit.add :form_bottom, "preview_button", :after => "edit_buttons"
      admin.page.edit.add :part_controls, "admin/pages/hidded_page_part"

      admin.layout.edit.add :form_bottom, "publish_revision"
      admin.layout.edit.add :main, "select_revision", :after => "edit_header"
      admin.layout.edit.add :form_bottom, "preview_button", :after => "edit_buttons"

      admin.snippet.edit.add :form_bottom, "publish_revision"
      admin.snippet.edit.add :main, "select_revision", :after => "edit_header"
      admin.snippet.edit.add :form_bottom, "preview_button", :after => "edit_buttons"
    end
  end
  
  def deactivate
  end
  
end
