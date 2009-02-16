class CreatePagePartRevisions < ActiveRecord::Migration
  def self.up
    create_table :page_part_revisions do |t|
      t.integer :page_id
      t.string :filter_id, :limit => 25
      t.string :name
      t.integer :number, :default => 1
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :page_part_revisions
  end
end