class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :title
      t.string :summary
      t.integer :status_id, :default => Page::STATUS_LOCKED
      t.integer :parent_id
      t.text :content
      t.string :content_type
      t.timestamps 
    end
    add_index :pages, :parent_id
  end
end
