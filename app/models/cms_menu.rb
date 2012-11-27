class CmsMenu < ActiveRecord::Base
  unloadable
  belongs_to :source, :polymorphic => true

  after_save :rebuild_menu

  acts_as_list :scope => 'menu_type = \'#{menu_type}\''

  def rebuild_menu
    CmsMenu.rebuild 
  end

  def self.rebuild 
    Redmine::MenuManager.map :top_menu do |menu|
      CmsMenu.where(:menu_type => "top_menu").each do |cms_menu|
        menu.delete(cms_menu.name.to_sym)
        Redmine::MenuManager.items(:top_menu).root.add_at(Redmine::MenuManager::MenuItem.new(cms_menu.name, cms_menu.path, :caption => cms_menu.caption), cms_menu.position.to_i)
      end  
    end  
  end

end
