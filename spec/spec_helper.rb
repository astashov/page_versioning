module PageVersioning
  @enable_versioning = true
end

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
require File.expand_path(File.dirname(__FILE__) + "/page_versioning_spec_helpers")
require "#{RADIANT_ROOT}/spec/spec_helper"

include PageVersioningSpecHelpers

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RADIANT_ROOT + '/test/fixtures'
end

