class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :name
      t.string :part_type
      t.text :content
      t.string :content_type
      t.integer :position
      t.timestamps 
    end

    create_table :pages_parts do |t|
      t.integer :page_id
      t.integer :part_id
      t.integer :status_id, :default => RedmineCms::STATUS_LOCKED
    end
    add_index :page_parts, [:page_id, :part_id]

  end
end