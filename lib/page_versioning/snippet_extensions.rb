module PageVersioning::SnippetExtensions
  def self.included(base)
    base.class_eval do
      
      include PageVersioning::CommonRevisionExtensions      
      has_many :revisions, :dependent => :destroy, :class_name => "SnippetRevision"     

      if self.connection.tables.include?("snippet_revisions")      
        before_save :add_revision
      end

    end
  end
end