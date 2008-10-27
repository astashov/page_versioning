module PageVersioning::SnippetHelperExtensions
  
  # Look for snippet in PagePart contents and Layout contents of mentioned Page.
  # Return Pages what contains this snippet
  def insert_options_for_snippet_preview
    all_pages = Page.find(:all)    
    pages_with_snippet = all_pages.select { |page| page.contains_snippet?(@snippet) }
    pages_with_snippet.map {|page| [ page.title, page.id ]}
  end
  
  
  def insert_snippet_preview_submit_tag
    options = insert_options_for_snippet_preview
    submit_tag_properties = { :name => 'preview', :class => 'button' }
    submit_tag_properties[:disabled] = true if options.empty?
    submit_tag "Save and Preview", submit_tag_properties
  end

end