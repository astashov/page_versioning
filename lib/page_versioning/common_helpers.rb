module PageVersioning::CommonHelpers
  
  def insert_select_revision_tag(element)
    selected_revision_number = params[:revision] ? params[:revision].to_i : element.published_revision_number
    revision_options = options_for_select(element.revisions.map {|r| [r.number, r.number] }, selected_revision_number)
    
    select_tag("revision", revision_options, :id => "revisions", :class => "revisions")
  end
  
  
  def insert_select_published_revision_tag(element, title)
    # Default is 0 ('<next>')
    options_for_published_revision = options_for_select(element.revisions.map {|r| [r.number, r.number] } + [['<next>', 0]], 0)
    select_tag "#{title}[published_revision_number]", options_for_published_revision, :id => "#{title}_published_revision_number"
  end
  
end