module PageVersioning::PageExtensions
  def self.included(base)
    base.class_eval do
      include PageVersioning::CommonRevisionExtensions
      
      has_many :revisions, :dependent => :destroy, :class_name => "PageRevision"
      
      if self.connection.tables.include?("page_revisions")
        before_update :add_revision
        before_create :create_first_revision
        before_destroy :delete_all_page_part_revisions
      end        
      
      attr_writer :preview
            
      
      # Delete all PagePart revisions of the page. It's needed because there are
      # no dependant PagePartRevisions from PageParts - if we delete PagePart,
      # PagePartRevisions don't delete. We can roll back to PagePart ever if it was
      # destroyed.
      def delete_all_page_part_revisions
        PagePartRevision.destroy_all(:page_id => self.id)
      end

      
      # Get array of PageParts with revisioned attributes. Revisioned attributes are changed
      # to attributes of PagePartRevision. (This method is needed in PageController)
      def get_revision_of_page_parts(revision)
        part_names = self.parts.map {|part| part.name}
        parts = []
        parts_revisions = PagePartRevision.find_all_by_number_and_page_id(revision, self.id)
        
        parts_revisions.each do |part_revision|
          
          part = part_names.include?(part_revision.name) ? self.part(part_revision.name) : self.parts.build
          
          part.attributes = part.change_attributes_to_revision_attributes(part_revision, 
            FIELDS['page_part_revision_specific_attributes'])
          parts << part

        end
        
        parts
      end
      
      # Override of part method of Page model. Changed
      #   parts.find_by_name name.to_s
      # to
      #   self.parts.to_a.select {|p| p.name == name.to_s }[0]
      # for proper work of previews (if we use #find method, we will initialize Part again).
      def part(name)
        if new_record? or parts.to_a.any?(&:new_record?)
          parts.to_a.find {|p| p.name == name.to_s }
        else
          self.parts.to_a.select {|p| p.name == name.to_s }[0]
        end
      end
      
      
      def is_preview?
        @preview
      end
      
      
      def is_preview=(param)
        @preview = param
      end
      
      
      # After initialization of Page we are changing some attributes to attributes
      # of published revision
      def after_initialize
        self.revision_model = PageRevision
        @preview = false
        if PageVersioning.enable_versioning
          self.attributes = change_attributes_to_revision_attributes(self.published_revision, 
            FIELDS['page_revision_specific_attributes']) rescue nil
        end
      end
      
      # Set Page and all it's PageParts to mentioned revision
      def set_to_revision(number)
        revision = PageRevision.find_by_number_and_page_id(number, self.id)
        
        self.attributes = change_attributes_to_revision_attributes(revision, FIELDS['page_revision_specific_attributes'])
        self.parts = get_revision_of_page_parts(number)
        true
      end
      
      
      # Return true if some of page's parts or its layout contain given snippet
      def contains_snippet?(snippet)
        regexp = /<r:snippet.*name=\"(\w+)\".*>/
        
        parts_with_snippets = self.parts.select do |part|
          part.content.match(regexp)[1] == snippet.name rescue nil
        end
        does_any_part_have_snippet = !parts_with_snippets.empty?
        
        does_layout_have_snippet = self.layout.content.match(regexp)[1] == snippet.name rescue nil
        
        does_any_part_have_snippet || does_layout_have_snippet
      end
      
      
      private
      
        # Create revision before creating of the page
        def create_first_revision
          attributes = get_attributes(FIELDS['page_revision_attributes'])
          self.revisions << PageRevision.create(attributes)
          return true
        end
        
        
        # Add revision before updating of the page, if revisioned attributes of the page
        # or any page part were changed.
        def add_revision
          # Get only revisioned attributes (without 'id', 'created_at', etc.)
          @page_attributes = get_attributes(FIELDS['page_revision_attributes'])
          @page_parts_attributes = []
          self.parts.each do |page_part|
            attributes = page_part.get_attributes(FIELDS['page_part_revision_attributes'])
            @page_parts_attributes << attributes
          end
          
          if was_changed? || is_preview?
            revision = PageRevision.create(@page_attributes)
            self.revisions << revision
          end
          
          set_correct_published_revision_number(revision)
          
          return true
        end
        
      
        # Return true if revisioned attributes of the page or any page part were changed.
        def was_changed?
          @previous_record = self.last_revision
          return true unless @previous_record
          
          # Check page attributes for changing
          @page_attributes.each do |attribute|
            return true if attribute[1].to_s != @previous_record[attribute[0]].to_s
          end
          
          # Check page parts attributes for changing
          @page_parts_attributes.each_with_index do |page_part_attributes, index|
            previous_part = @previous_record.page.parts[index].last_revision rescue nil
            return true unless previous_part
            
            page_part_attributes.each do |attribute|
              return true if attribute[1].to_s != previous_part[attribute[0]].to_s
            end
          end
          
          return false
        end
    end
  end  
end