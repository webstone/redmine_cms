class AddVersionToPageAndParts < ActiveRecord::Migration
  def change
    add_column :pages, :version, :integer, :default => 0
    add_column :parts, :version, :integer, :default => 0
  end
end