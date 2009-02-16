class AddRevisionFieldsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :published_revision_number, :integer, :default => 1
    add_column :pages, :is_preview, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :published_revision_number
    remove_column :pages, :is_preview
  end
end
