unless defined? RADIANT_ROOT
  ENV["RAILS_ENV"] = "test"
  case
  when ENV["RADIANT_ENV_FILE"]
    require ENV["RADIANT_ENV_FILE"]
  when File.dirname(__FILE__) =~ %r{vendor/radiant/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../../")}/config/environment"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/environment"
  end
end
require "#{RADIANT_ROOT}/spec/spec_helper"

if File.directory?(File.dirname(__FILE__) + "/scenarios")
  Scenario.load_paths.unshift File.dirname(__FILE__) + "/scenarios"
end
if File.directory?(File.dirname(__FILE__) + "/matchers")
  Dir[File.dirname(__FILE__) + "/matchers/*.rb"].each {|file| require file }
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RADIANT_ROOT + '/test/fixtures'

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
end

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
  begin
    page.save!
    page.parts.each { |part| part.save! }
    return page
  rescue => msg
    puts msg
    return nil
  end
end

def show_rev(page)
  page.parts.each do |part|
    puts "#{part.id} #{part.name}"
    part.revisions.each do |revision|
      puts "    #{revision.id} #{revision.number} #{revision.page_part_id}"
    end
  end
end

PageVersioning.enable_versioning = true