class SnippetRevision < ActiveRecord::Base
  
  belongs_to :snippet
  before_save :increase_number
  
  def increase_number
    snippet = self.snippet
    self.number = snippet ? snippet.number_of_last_revision + 1 : 1
    return true
  end
  
end