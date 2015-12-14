class CreateCmsContentVersions < ActiveRecord::Migration
  def change
    create_table :cms_content_versions do |t|
      t.column :version, :integer, :null => false
      t.column :comments, :string
      t.column :content, :text
      t.column :author_id, :integer
      t.column :versionable_type, :string, :default => "", :null => false
      t.column :versionable_id, :integer, :default => 0, :null => false
    end
    add_index :cms_content_versions, :versionable_id
    add_index :cms_content_versions, ["versionable_id", "versionable_type"], :name => "index_cms_content_versions_on_versionable", :using => :btree
  end
end
