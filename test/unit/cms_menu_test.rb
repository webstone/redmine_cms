require File.expand_path('../../test_helper', __FILE__)

class CmsMenuTest < ActiveSupport::TestCase

  
  fixtures :users, :cms_menus

  RedmineCMS::TestCase.create_fixtures(:cms_menus)

  def test_create_menu
    menu = CmsMenu.new
    assert !menu.save, 'Can save a menu without name and caption'
    menu.name = "main_menu"
    assert !menu.save, 'Can save a menu without caption'
    menu.name = nil
    menu.caption = 'caption'
    assert !menu.save, 'Can save a menu without name'
    menu.name = "main_menu"
    assert menu.save, 'Cannot save a menu with name and caption'
  end

  def test_validateion_for_menu
    menu = CmsMenu.new(:caption => "Caption for new menu item")
    menu.name = "invalid name"
    assert !menu.save, 'Can save a menu with invalid name'
    menu.name = "a"*31
    assert !menu.save, 'Can save a menu with too long name'
    menu.menu_type = 'top_menu'
    menu.name = 'first_menu'
    assert !menu.save, 'Can save a menu with not uniq name'
  end

  def test_visibile
    admin = users(:users_001) #admin
    non_admin = users(:users_003)
    other_non_admin = users(:users_002)
    anonymus = users(:users_006)
    assert cms_menus(:menu_001).visible?(admin), 'Admin cannot see public page'
    assert cms_menus(:menu_002).visible?(admin), 'Admin cannot see logged page'
    assert cms_menus(:menu_003).visible?(admin), 'Admin cannot see private page'

    assert cms_menus(:menu_001).visible?(non_admin), 'Non admin cannot see public page'
    assert cms_menus(:menu_002).visible?(non_admin), 'Non admin cannot see logged page'
    

    assert cms_menus(:menu_003).visible?(non_admin), 'Non admin cannot see private page for this user'
    assert !cms_menus(:menu_003).visible?(other_non_admin), 'Another non admin cannot see private page'

    assert cms_menus(:menu_001).visible?(anonymus), 'Anonymus cannot see public page'
    assert !cms_menus(:menu_002).visible?(anonymus), 'Anonymus can see logged page'
    assert !cms_menus(:menu_003).visible?(anonymus), 'Anonymus cannot see private page'
  end

  def test_rebuild_menu
    CmsMenu.rebuild
    User.current = users(:users_003)
    count = 0
    CmsMenu.active.top_menu.each do |menu|
      assert Redmine::MenuManager.map(:top_menu).exists?(menu.name.to_sym), "#{menu.name} didn't exist"
    end
    CmsMenu.active.footer_menu.each do |menu|
      assert Redmine::MenuManager.map(:footer_menu).exists?(menu.name.to_sym), "#{menu.name} didn't exist"
    end

    CmsMenu.active.account_menu.each do |menu|
      assert Redmine::MenuManager.map(:account_menu).exists?(menu.name.to_sym), "#{menu.name} didn't exist"
    end
  end

  def test_clear_cache
    new_top_item = CmsMenu.new(
      :name => "new_item_for_top", 
      :caption => "new item for top",
      :menu_type => "top_menu",
      :path => '/new_item_for_top',
      :status_id => 1
    )
    new_top_item.save
    assert !Redmine::MenuManager.map(:top_menu).exists?(new_top_item.name.to_sym)
    CmsMenu.check_cache
    assert Redmine::MenuManager.map(:top_menu).exists?(new_top_item.name.to_sym)
  end
end
