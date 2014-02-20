class MenusDrop < Liquid::Drop

  def initialize(menus)
    @menus = menus
  end

  def before_method(name)
    menu = @menus.where(:name => name).first || CmsMenu.new
    MenuDrop.new menu
  end

  def all
    @all ||= @menus.map do |menu|
      MenuDrop.new menu
    end
  end

  def footer_menu
    self.visible.footer_menu
  end

  def top_menu
    @top_menu ||= @menus.top_menu.map{|m| MenuDrop.new(m)}
  end

  def account_menu
    self.visible.account_menu
  end

  def size
    @menus.count
  end

  def visible
    @visible ||= @menus.visible.map do |menu|
      MenuDrop.new menu
    end
  end

  def each(&block)
    all.each(&block)
  end

end


class MenuDrop < Liquid::Drop

  delegate :name, :caption, :path, :menu_type, :visible?, :active?, :to => :@menu

  def initialize(menu)
    @menu = menu
  end

  def children
    @children ||= @menu.children.map{|p| MenuDrop.new(p)}
  end

  def parent
    @parent ||= MenuDrop.new(@menu.parent) if @menu.parent
  end

  private

  def helpers
    Rails.application.routes.url_helpers
  end

end