class CreateSnippetRevisions < ActiveRecord::Migration
  def self.up
    create_table :snippet_revisions do |t|
      t.integer :snippet_id
      t.integer :number
      t.string :name
      t.string :content
      t.string :filter_id, :limit => 25

      t.timestamps
    end
  end

  def self.down
    drop_table :snippet_revisions
  end
end
