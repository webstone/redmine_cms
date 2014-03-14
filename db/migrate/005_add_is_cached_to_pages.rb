class AddIsCachedToPages < ActiveRecord::Migration
  def change
    add_column :pages, :is_cached, :boolean, :default => false
  end
end