module PageVersioningSpecHelpers
  
  def valid_page_params
    {
    :title => 'New Page',
    :slug => 'page',
    :breadcrumb => 'New Page',
    :status_id => '1'
    }
  end

  def valid_page_revision_params
    {
    :title => 'New Page',
    :slug => 'page',
    :breadcrumb => 'New Page'
    }
  end

  def valid_page_part_params
    {
    :name => 'New page part',
    :content => "New Page Part Content",
    :filter_id => 1
    }
  end

  def valid_page_part_revision_params
    {
    :name => 'New page part',
    :content => "New Page Part Content",
    :filter_id => 1
    }
  end

  def valid_layout_params
    {
    :name => "New Layout",
    :content => "Content of New Layout",
    :content_type => "text/text"
    }
  end


  def valid_layout_revision_params
    {
    :name => "New Layout",
    :content => "Content of New Layout",
    :content_type => "text/text"
    }
  end

  def valid_snippet_params
    {
    :name => "new_snippet",
    :content => "Content of New Snippet"
    }
  end


  def valid_snippet_revision_params
    {
    :name => "new_snippet",
    :content => "Content of New Snippet"
    }
  end

  def page_save(page)
    page.save!
    page.parts.each { |part| part.save! }
  end
  
  def login_as(user)
    controller.stub!(:authenticate).and_return(true)
    controller.stub!(:logged_in?).and_return(true)
    controller.stub!(:current_user).and_return(user)
    @current_user = user
  end
  
end