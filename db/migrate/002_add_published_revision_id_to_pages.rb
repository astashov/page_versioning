class AddPublishedRevisionIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :published_revision_number, :integer, :default => 1
  end

  def self.down
    remove_column :pages, :published_revision_number
  end
end
