class LayoutRevision < ActiveRecord::Base
  
  belongs_to :layout
  before_save :increase_number
  
  def increase_number
    layout = self.layout
    self.number = layout ? layout.number_of_last_revision + 1 : 1
    return true
  end
  
end