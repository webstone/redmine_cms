class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :title
      t.string :summary
      t.integer :status_id
      t.integer :parent_id
      t.text :content
      t.string :content_type
      t.timestamps 
    end
  end
end
