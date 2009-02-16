module PageVersioning::PageExtensions
  def self.included(base)
    base.class_eval do
      include PageVersioning::CommonRevisionExtensions
      
      has_many :page_part_revisions, :dependent => :destroy, :class_name => "PagePartRevision", :foreign_key => "page_id"

      
      # Get array of PageParts with revisioned attributes. Revisioned attributes are changed
      # to attributes of PagePartRevision.
      def get_revision_of_page_parts(revision)
        parts_revisions = PagePartRevision.find_all_by_number_and_page_id(revision, self.id)
        
        parts_revisions.inject([]) do |parts, part_revision|
          part = self.part(part_revision.name) || self.parts.build
          part.attributes = part.change_attributes_to_revision_attributes(part_revision)
          parts << part
        end
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
          parts.to_a.select {|p| p.name == name.to_s }.first
        end
      end

      
      # Set Page and all it's PageParts to mentioned revision
      def set_to_revision(number)
        number = super(number)
        self.parts = get_revision_of_page_parts(number)
        number
      end
      
      
      # Return true if some of page's parts or its layout contain given snippet
      def contains_snippet?(snippet)
        regexp = /<r:snippet.*name=\"(\w+)\".*>/
        parts_with_snippets = self.parts.select do |part|
          part_match = part.content.match(regexp)
          part_match && part_match[1] == snippet.name
        end
        
        does_any_part_have_snippet = !parts_with_snippets.empty?
        if self.layout
          layout_match = self.layout.content.match(regexp)
          does_layout_have_snippet = layout_match && layout_match[1] == snippet.name
        end
        
        does_any_part_have_snippet || does_layout_have_snippet
      end
      
      
      private
        
        #  Return true if revisioned attributes of the page or any page part were changed.
        def was_changed?
          page_attributes = get_attributes 
          page_parts_attributes = self.parts.inject([]) { |attrs, part| attrs << part.get_attributes }
          
          previous_record = self.last_revision
          return true unless previous_record
          
          # Check page attributes for changing
          page_attributes.each do |field, value|
            return true if value.to_s != previous_record[field].to_s
          end
          
          previous_parts = PagePartRevision.find_all_by_page_id_and_number(previous_record.page.id, previous_record.number)
          
          # Check page parts attributes for changing
          return true if previous_parts.size != page_parts_attributes.size          
          page_parts_attributes.each_with_index do |page_part_attributes, index|
            previous_part = previous_parts[index]
            return true unless previous_part
            # 'Cause since Radiant v0.7.0 page_parts are recreated after each saving of page
            # we shouldn't compare page_id's of old and new page_part - page_id of new page_part is always 'nil' here
            # (it will be set in after_save callback, look at Page model
            page_part_attributes.delete('page_id')
            page_part_attributes.each do |field, value|
              return true if value.to_s != previous_part[field].to_s
            end
          end
          
          return false
        end
        
    end
  end  
end