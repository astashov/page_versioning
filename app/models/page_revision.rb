class PageRevision < ActiveRecord::Base
  
  belongs_to :page
  before_save :increase_number
  
  def increase_number
    page = self.page
    self.number = page ? page.number_of_last_revision + 1 : 1
    return true
  end
  
  def parts
    return PagePartRevision.find_all_by_page_id_and_number(self.page.id, self.number) rescue []
  end
  
end
