class SnippetRevision < ActiveRecord::Base
  
  belongs_to :snippet
  before_save :increase_number
  
  def increase_number
    snippet = self.snippet
    self.number = snippet && snippet.last_revision ? snippet.last_revision.number + 1 : 1
    return true
  end
  
end
