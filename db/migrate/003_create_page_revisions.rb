class CreatePageRevisions < ActiveRecord::Migration
  def self.up
    create_table :page_revisions do |t|
      t.integer :page_id
      t.integer :number
      t.string :title
      t.string :slug
      t.string :breadcrumb
      t.string :description
      t.string :keywords
      t.integer :layout_id
      t.string :class_name

      t.timestamps
    end
  end

  def self.down
    drop_table :page_revisions
  end
end
