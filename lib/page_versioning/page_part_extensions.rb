module PageVersioning::PagePartExtensions
  def self.included(base)
    base.class_eval do
      include PageVersioning::CommonRevisionExtensions
      
      has_many :revisions, :class_name => "PagePartRevision"
      has_one :published_revision, :foreign_key => 'published_revision_id', :class_name => "PagePartRevision"
      
      if self.connection.tables.include?("page_part_revisions")
        before_update :add_revision
        before_create :create_first_revision
      end
      
      protected
      
        # After initialization of PagePart we are changing some attributes to attributes
        # of published revision
        def after_initialize  
        self.revision_model = PagePartRevision          
          begin
            revision = PagePartRevision.find_by_page_part_id_and_number(self.id, self.page.published_revision.number)
            self.attributes = change_attributes_to_revision_attributes(revision, FIELDS['page_part_revision_specific_attributes'])
          rescue 
            nil
          end
        end
      
        
      private      
        
        
        # Create revision after creating of the page part
        def create_first_revision
          attributes = get_attributes(FIELDS['page_part_revision_attributes'])
          number = self.page.number_of_last_revision == 0 ? 1 : self.page.number_of_last_revision
          attributes['number'] = number
          self.revisions << PagePartRevision.create(attributes)
          return true
        end
      
        
        # Add revision after updating of the page. If revisioned attributes of the page
        # or any page part were changed.
        def add_revision
          attributes = get_attributes(FIELDS['page_part_revision_attributes'])
          attributes['number'] = self.page.number_of_last_revision
          attributes['filter_id'] = nil if attributes['filter_id'].blank?
          if was_changed?(attributes)
            self.revisions << PagePartRevision.create(attributes)
          end
          return true
        end
        

        # Return true if revision of page part with last number of page revision does not exist
        def was_changed?(attributes)          
          if PagePartRevision.exists?(attributes)
            return false
          else
            return true
          end
        end
        
    end
  end
end