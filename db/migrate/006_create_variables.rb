class CreateVariables < ActiveRecord::Migration
  def change
    create_table :cms_variables do |t|
      t.string :name
      t.string :value
    end
  end
end
