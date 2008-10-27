class AddPublishedRevisionIdToSnippets < ActiveRecord::Migration
  def self.up
    add_column :snippets, :published_revision_number, :integer, :default => 1
    add_column :snippets, :is_preview, :boolean, :default => false
  end

  def self.down
    remove_column :snippets, :published_revision_number
    remove_column :snippets, :is_preview
  end
end