module PageVersioning::CommonRevisionExtensions
  attr_accessor :revision_model
  
  
  # Return number of last revision. Return 0 if there are no revisions for the page.
  def number_of_last_revision
    begin
      # This is dynamic expression, it turns out to similar to 
      # PageRevision.find_all_by_page_id(self.id), for example
      method = 'find_all_by_' + klass + '_id'
      revisions = self.revision_model.send(method.to_sym, self.id)
      revisions.map{ |r| r.number }.max.to_i
    rescue
      0
    end
  end

  
  # Return last revision (SomethingRevision object)
  def last_revision
    # This is dynamic expression, it turns out to similar to 
    # PageRevision.find_by_page_id_and_number(self.id, self.number_of_last_revision), for example
    method = 'find_by_' + klass + '_id_and_number'
    self.revision_model.send(method.to_sym, self.id, self.number_of_last_revision) rescue nil
  end

  
  # Return published revision (SomethingRevision model)
  def published_revision
    method = 'find_by_number_and_' + klass + '_id'
    self.revision_model.send(method.to_sym, self.published_revision_number, self.id) rescue nil
  end
  
  
  # Change attributes of model to attributes of definite revision (by revision number) 
  def set_to_revision(number)
    method = 'find_by_number_and_' + klass  + '_id'
    revision = self.revision_model.send(method.to_sym, number, self.id)

    self.attributes = change_attributes_to_revision_attributes(revision, FIELDS[klass + '_revision_specific_attributes'])
  end
  
  
  # Change Something revisioned attributes to SomethingRevision attributes
  def change_attributes_to_revision_attributes(revision, needed_attributes)
    revision ||= self.last_revision
    return self.attributes unless revision
    attributes = self.attributes
    revision_attributes = revision.attributes
    attributes.merge!(delete_specific_revision_attributes(revision_attributes, needed_attributes))
    attributes
  end
  
      
  def is_preview?
    self.is_preview rescue nil
  end
  
  def klass
    self.class.table_name.singularize
  end

  
  protected
  
  
    # Change attributes of model to last revision or published revision 
    # (depends of 'is_preview' flag) 
    def after_initialize
      self.revision_model = (klass.camelize + 'Revision').constantize
      revision = is_preview? ? self.last_revision : self.published_revision
      if PageVersioning.enable_versioning
        self.attributes = change_attributes_to_revision_attributes(revision, 
          FIELDS[self.class.to_s.underscore + '_revision_specific_attributes']) if revision
      end
    end
  
    
    # Get only revisioned attributes
    def get_attributes(needed_attributes)
      attributes = self.attributes
      attributes.delete_if { |key, value| !needed_attributes.include?(key) }
      return attributes
    end
      
    
    # Add Revision if revisioned attributes were changed
    def add_revision
      attributes = get_attributes(FIELDS[klass + '_revision_attributes'])
      attributes = convert_empty_id_attributes_to_nil(attributes)
      if was_changed?(attributes) || is_preview?
        self.revisions
        revision = self.revision_model.create(attributes)
        self.revisions << revision
      end
      set_correct_published_revision_number(revision)
    end

    
    # Return true if revisioned attributes were changed.
    # This is needed for making decision - create new revision or not.
    def was_changed?(attributes)
      previous_revision = self.last_revision
      return true unless previous_revision

      # Check page attributes for changing
      attributes.each do |attribute|
        return true if attribute[1].to_s != previous_revision[attribute[0]].to_s
      end

      return false
    end  
    
    
    # Notice: If published revision number = 0, then use number of last revision
    def set_correct_published_revision_number(revision = nil)
      if self.published_revision_number == 0
        self.published_revision_number = revision ? revision.number : self.last_revision.number
      end
    end
    
    
    def self.table_exists?(name)
      ActiveRecord::Base.connection.tables.include?(name)
    end
  
    
  private
  
    
    # Delete specific attributes (such as 'id', 'created_at', etc.) from revision attributes  
    def delete_specific_revision_attributes(attributes, needed_attributes)
      attributes.delete_if { |key, value| needed_attributes.include?(key) }
      attributes
    end
    
    
    # If any attributes like 'something_id' are 'blank' in params[] hash, 
    # they are needed to convert to nil. This is needed because if these attributes 
    # are NULL in database table, they should be founded by 'blank'. "" is not NULL,
    # but nil is NULL.
    def convert_empty_id_attributes_to_nil(attributes)
      attributes.each do |key, value|
        if key =~ /^.*_id$/ && value.blank?
          attributes[key] = nil
        end
      end
      attributes
    end
    

  
end