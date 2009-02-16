class Admin::PreviewController < Admin::ResourceController
  
  def page
    @page = Page.find(params[:id])
    @page.set_to_revision(@page.last_revision.number)
    display_the_page
  end
  
  def layout
    @page = Page.find(params[:page_to_preview])
    Layout.set_preview(params[:id], true)
    display_the_page
  ensure
    Layout.set_preview(params[:id], false)
  end
  
  def snippet
    @page = Page.find(params[:page_to_preview])
    Snippet.set_preview(params[:id], true)
    display_the_page
  ensure
    Snippet.set_preview(params[:id], false)
  end
  
  private
  
    # Display the page with 'return' link
    def display_the_page
      @page.process(request, response)
      # Add backreference to body for returning to edit page
      @response = response
      
      @response.body += '<p><a href="' + url_for(
        :controller => 'admin/' + CGI.escapeHTML(params[:action].pluralize), 
        :id => params[:id].to_i,
        :action => 'edit'
      ) + '">Back</a></p>'
      
      @response = nil

      # If this is true, Radiant will not use render more.
      @performed_render = true
    end
end