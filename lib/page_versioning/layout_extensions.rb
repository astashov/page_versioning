module PageVersioning::LayoutExtensions
  def self.included(base)
    base.class_eval do
      
      include PageVersioning::CommonRevisionExtensions      
      has_many :revisions, :dependent => :destroy, :class_name => "LayoutRevision"
      
      if self.connection.tables.include?("layout_revisions")      
        before_save :add_revision
      end   
      
    end
  end
end