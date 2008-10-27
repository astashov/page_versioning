class Admin::PreviewController < Admin::AbstractModelController
  
  def page
    @page = Page.find(params[:id])
    @page.set_to_revision(@page.number_of_last_revision)
    display_the_page
  end
  
  def layout
    @page = Page.find(params[:page_to_preview])
    @layout = Layout.find(params[:id])
    display_the_page
    @layout.is_preview = false
    @layout.save
  end
  
  def snippet
    @page = Page.find(params[:page_to_preview])
    @snippet = Snippet.find(params[:id])    
    display_the_page
    @snippet.is_preview = false
    @snippet.save
  end
  
  private
  
    # Display the page with 'return' link
    def display_the_page
      @page.process(request, response)
      # Add backreference to body for returning to edit page
      @response = response
      
      @response.body += '<p><a href="' + url_for(
        :controller => 'admin/' + params[:action], 
        :id => instance_variable_get("@#{params[:action]}"),
        :action => 'edit'
      ) + '">Back</a></p>'
      
      @response = nil

      # If this is true, Radiant will not use render more.
      @performed_render = true
    end
end