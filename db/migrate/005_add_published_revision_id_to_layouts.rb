class AddPublishedRevisionIdToLayouts < ActiveRecord::Migration
  def self.up
    add_column :layouts, :published_revision_number, :integer, :default => 1
    add_column :layouts, :is_preview, :boolean, :default => false
  end

  def self.down
    remove_column :layouts, :published_revision_number
    remove_column :layouts, :is_preview
  end
end