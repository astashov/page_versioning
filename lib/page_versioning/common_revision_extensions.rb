module PageVersioning::CommonRevisionExtensions
  attr_accessor :revision_model
  
  def self.included(base)
    base.class_eval do
      before_save :add_revision
      
      # PagePartRevision is not binded to PagePart, it is binded to Page. Because
      # different page parts (with their revisions) can be destroyed and created again, but we can
      # save whole history of Page.
      unless self == PagePart
        has_many :revisions, :dependent => :destroy, :class_name => self.table_name.singularize.camelize + "Revision"
      end
      
      def self.set_preview(id, value)
        update_all(["is_preview = ?", value ? true : false], ['id = ?', id])
      end
      
    end
  end
  
  
  # Return last revision (SomethingRevision object)
  def last_revision
    self.revision_model.find(:first, :conditions => { klass + '_id' => self.id }, :order => "number DESC")
  end

  
  # Return published revision (SomethingRevision model)
  def published_revision
    self.revision_model.find(:first, :conditions => { klass + '_id' => self.id, :number => self.published_revision_number })
  end
  
  
  # Change attributes of model to attributes of definite revision (by revision number) 
  def set_to_revision(number)
    revision = self.revision_model.find(:first, :conditions => { klass + '_id' => self.id, :number => number })
    revision ||= self.last_revision
    logger.warn("There is no revision with such number: #{revision}") and return unless revision
    self.attributes = change_attributes_to_revision_attributes(revision)
    
    # Return number of selected revision (because we can change it if set last_revision
    revision.number
  end
  
  
  # Change Something revisioned attributes to SomethingRevision attributes
  def change_attributes_to_revision_attributes(revision)
    revision ||= self.last_revision
    return self.attributes unless revision
    
    attributes = get_attributes
    
    revision_attributes = delete_specific_revision_attributes(revision.attributes)
    attributes.merge!(revision_attributes)
    attributes
  end
  
  
  def klass
    self.class.table_name.singularize
  end

  
  protected
  
  
    # Change attributes of model to last revision or published revision 
    # (depends of 'is_preview' flag) 
    def after_initialize
      self.revision_model = (klass.camelize + 'Revision').constantize
      revision = is_preview ? self.last_revision : self.published_revision
      self.attributes = change_attributes_to_revision_attributes(revision) if revision
    end
    
    
    # Get only revisioned attributes
    def get_attributes
      necessary_attributes = PageVersioning::Config[klass + '_revision_attributes']
      attributes = self.attributes
      attributes.delete_if { |key, value| !necessary_attributes.include?(key) }
      attributes
    end
      
    
    # Add Revision if revisioned attributes were changed
    def add_revision
      attributes = get_attributes
      attributes = convert_empty_id_attributes_to_nil(attributes)
      if was_changed?
        revision = self.revision_model.create!(attributes)
        self.revisions << revision if self.respond_to?(:revisions)
      end
      set_correct_published_revision_number(revision) if self.respond_to?(:published_revision_number)
    end
    
    
    # Return true if revisioned attributes were changed.
    # This is needed for making decision - create new revision or not.
    def was_changed?
      attributes = get_attributes 
      previous_revision = self.last_revision
      return true unless previous_revision
 
      # Check page attributes for changing
      attributes.each do |field, value|
        return true if value.to_s != previous_revision[field].to_s
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
    def delete_specific_revision_attributes(attributes)
      necessary_attributes = PageVersioning::Config[klass + '_revision_specific_attributes']
      attributes.delete_if { |key, value| necessary_attributes.include?(key) }
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
