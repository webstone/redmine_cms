class CmsMenu < ActiveRecord::Base
  unloadable
  belongs_to :source, :polymorphic => true

  acts_as_list :scope => 'menu_type = \'#{menu_type}\''

  default_scope order(:position)

  after_save :rebuild_menu

  validates_presence_of :name, :caption
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_length_of :caption, :maximum => 255

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
