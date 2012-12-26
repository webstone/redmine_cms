class CmsMenu < ActiveRecord::Base
  unloadable
  belongs_to :source, :polymorphic => true

  acts_as_list :scope => 'menu_type = \'#{menu_type}\' AND parent_id = #{parent_id}'
  acts_as_tree :dependent => :nullify

  default_scope order(:menu_type).order(:position)
  scope :active, where(:status_id => RedmineCms::STATUS_ACTIVE)

  after_commit :rebuild_menu

  validates_presence_of :name, :caption
  validates_uniqueness_of :name
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
      CmsMenu.all.each{|m| menu.delete(m.name.to_sym) }

      CmsMenu.active.where(:menu_type => "top_menu", :parent_id => nil).each do |cms_menu|
        menu.push(cms_menu.name, cms_menu.path, :caption => cms_menu.caption, :first => cms_menu.first? )
        # Redmine::MenuManager.items(:top_menu).root.add_at(Redmine::MenuManager::MenuItem.new(cms_menu.name, cms_menu.path, :caption => cms_menu.caption), cms_menu.position.to_i)
      end  

      CmsMenu.active.where(:menu_type => "top_menu").where("#{CmsMenu.table_name}.parent_id IS NOT NULL").each do |cms_menu|
        menu.push cms_menu.name.to_sym, cms_menu.path, :parent => cms_menu.parent.name.to_sym, :caption => cms_menu.caption if cms_menu.parent.active?
      end
    end  

    Redmine::MenuManager.map :footer_menu do |menu|
      CmsMenu.all.each{|m| menu.delete(m.name.to_sym) }
      CmsMenu.where(:menu_type => "footer_menu").each do |cms_menu|
        menu.push(cms_menu.name, cms_menu.path, :caption => cms_menu.caption)
        # menu.add_at(Redmine::MenuManager::MenuItem.new(cms_menu.name, cms_menu.path, :caption => cms_menu.caption), cms_menu.position.to_i) if cms_menu.active?
        # Redmine::MenuManager.items(:footer_menu).root.add_at(Redmine::MenuManager::MenuItem.new(cms_menu.name, cms_menu.path, :caption => cms_menu.caption), cms_menu.position.to_i) if cms_menu.active?
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
