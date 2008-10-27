module PageVersioning::SnippetControllerExtensions
  def self.included(base)
    base.class_eval do
      
      alias_method_chain :edit, :preview
      
      # GET admin/page/show_revision/:id?revision=:revision
      def show_revision
        # These are such columns as 'slug', 'breadcrumb', 'description'...
        initialize_meta_rows_and_buttons
        
        # Get page and revision
        @page = Page.find(params[:id])      
        @page.set_to_revision(params[:revision])

        render :action => "show_revision", :layout => false
      end
      
    end
  end

end