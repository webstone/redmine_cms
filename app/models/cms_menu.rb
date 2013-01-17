class CmsMenu < ActiveRecord::Base
  unloadable
  belongs_to :source, :polymorphic => true

  acts_as_list :scope => 'menu_type = \'#{menu_type}\' AND parent_id #{parent_id ? \'=\' + parent_id : \'IS NULL\'}'
  acts_as_tree :dependent => :nullify

  default_scope order(:menu_type).order(:position)
  scope :active, where(:status_id => RedmineCms::STATUS_ACTIVE)
  scope :footer_menu, where(:menu_type => "footer_menu")
  scope :top_menu, where(:menu_type => "top_menu")
  scope :account_menu, where(:menu_type => "account_menu")

  after_commit :rebuild_menu

  validates_presence_of :name, :caption
  validates_uniqueness_of :name, :scope => :menu_type
  validates_length_of :name, :maximum => 30
  validates_length_of :caption, :maximum => 255
  validate :validate_menu
  validates_format_of :name, :with => /^(?!\d+$)[a-z0-9\-_]*$/

  def active?
    self.status_id == RedmineCms::STATUS_ACTIVE
  end

  def rebuild_menu
    CmsMenu.rebuild 
  end

  def reload(*args)
    @valid_parents = nil
    super
  end

  def self.menu_tree(menus, parent_id=nil, level=0)
    tree = []
    menus.select {|menu| menu.parent_id == parent_id}.sort_by(&:position).sort_by(&:menu_type).each do |menu|
      tree << [menu, level]
      tree += menu_tree(menus, menu.id, level+1)
    end
    if block_given?
      tree.each do |menu, level|
        yield menu, level
      end
    end
    tree
  end

  def self.rebuild 
    Redmine::MenuManager.map :top_menu do |menu|
      CmsMenu.top_menu.each{|m| menu.delete(m.name.to_sym) }

      CmsMenu.active.top_menu.where(:parent_id => nil).each do |cms_menu|
        menu.push(cms_menu.name, cms_menu.path, :caption => cms_menu.caption, :first => cms_menu.first? ) unless menu.exists?(cms_menu.name.to_sym)
        # Redmine::MenuManager.items(:top_menu).root.add_at(Redmine::MenuManager::MenuItem.new(cms_menu.name, cms_menu.path, :caption => cms_menu.caption), cms_menu.position.to_i)
      end  

      CmsMenu.active.top_menu.where("#{CmsMenu.table_name}.parent_id IS NOT NULL").each do |cms_menu|
        menu.push cms_menu.name.to_sym, cms_menu.path, :parent => cms_menu.parent.name.to_sym, :caption => cms_menu.caption if cms_menu.parent.active? && !menu.exists?(cms_menu.name.to_sym)
      end
    end  

    Redmine::MenuManager.map :account_menu do |menu|
      CmsMenu.account_menu.each{|m| menu.delete(m.name.to_sym) }

      CmsMenu.active.account_menu.where(:parent_id => nil).each do |cms_menu|
        menu.push(cms_menu.name, cms_menu.path, :caption => cms_menu.caption, :first => cms_menu.first? ) unless menu.exists?(cms_menu.name.to_sym)
        # Redmine::MenuManager.items(:top_menu).root.add_at(Redmine::MenuManager::MenuItem.new(cms_menu.name, cms_menu.path, :caption => cms_menu.caption), cms_menu.position.to_i)
      end  

      CmsMenu.active.account_menu.where("#{CmsMenu.table_name}.parent_id IS NOT NULL").each do |cms_menu|
        menu.push cms_menu.name.to_sym, cms_menu.path, :parent => cms_menu.parent.name.to_sym, :caption => cms_menu.caption if cms_menu.parent.active? && !menu.exists?(cms_menu.name.to_sym)
      end
    end 

    Redmine::MenuManager.map :footer_menu do |menu|
      CmsMenu.footer_menu.each{|m| menu.delete(m.name.to_sym) }
      CmsMenu.active.footer_menu.each do |cms_menu|
        menu.push(cms_menu.name, cms_menu.path, :caption => cms_menu.caption)
      end  
    end 

  end

  def valid_parents
    @valid_parents ||= (self.children.any? ? [] : CmsMenu.where(:menu_type => self.menu_type, :parent_id => nil) - self_and_descendants)
  end  

  protected

  def validate_menu
    if parent_id && parent_id_changed?
      errors.add(:parent_id, :invalid) unless valid_parents.include?(parent)
    end
  end  

end
