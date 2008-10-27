class CreateLayoutRevisions < ActiveRecord::Migration
  def self.up
    create_table :layout_revisions do |t|
      t.integer :layout_id
      t.integer :number
      t.string :name
      t.string :content
      t.string :content_type

      t.timestamps
    end
  end

  def self.down
    drop_table :layout_revisions
  end
end
