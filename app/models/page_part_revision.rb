class PagePartRevision < ActiveRecord::Base
  belongs_to :page
  before_save :increase_number
  
  def increase_number
    page = self.page
    self.number = page && page.last_revision ? page.last_revision.number : 1
    return true
  end
  
end
