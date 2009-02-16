module PageVersioning::PagePartExtensions
  def self.included(base)
    base.class_eval do
      include PageVersioning::CommonRevisionExtensions
      validates_uniqueness_of :name, :scope => :page_id
   
      
      # Return last revision
      def last_revision
        self.revision_model.find(:first, :conditions => { 'page_id' => self.page && self.page.id }, :order => "number DESC")
      end


      # Return published revision
      def published_revision
        self.revision_model.find(:first, :conditions => { 'page_id' => self.page && self.page.id , :number => self.published_revision_number })
      end
      
      
      protected
      
        # After initialization of PagePart we are changing some attributes to attributes
        # of published revision (if the revision exists)
        def after_initialize_with_revision  
          self.revision_model = PagePartRevision
          if self.page
            revision = PagePartRevision.find_by_page_id_and_number_and_name(self.page.id, self.page.published_revision_number, self.name)
            return true unless revision
            self.attributes = change_attributes_to_revision_attributes(revision)
          end
          after_initialize_without_revision
        end
        
        alias_method_chain :after_initialize, :revision
      
        
      private      

        # Return true if revision of page part with last number of page revision does not exist
        def was_changed?     
          if self.page && self.page.last_revision
            return !self.revision_model.exists?(:page_id => self.page.id, :number => self.page.last_revision.number, :name => self.name)
          else
            return true
          end
        end
        
    end
  end
end