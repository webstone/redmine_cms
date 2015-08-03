require File.expand_path('../../test_helper', __FILE__)

class PageTest < ActiveSupport::TestCase

  fixtures :users, :pages

  RedmineCMS::TestCase.create_fixtures(:pages)
  # Replace this with your real tests.
  def test_create_page
    page = Page.new
    assert !page.save, 'Can save a page without name and title'
    page.name = 'first_page'
    assert !page.save, 'Can save a page without title'
    page.name = nil
    page.title = 'first page'
    assert !page.save, 'Can save a page without name'
    page.name = "first_page"
    assert page.save, 'Cannot save a page with name and title'
  end

  def test_validation_for_name
    page = Page.new(:title => "Page")
    page.name = "invalid name"
    assert !page.save, "Can save a page with invalid name include space" 
    page.name = "invalid&name"
    assert !page.save, "Can save a page with invalid name included &"
    page.name = "invalid?name"
    assert !page.save, "Can save a page with invalid name included ?"
    page.name = "valid_name"
    assert page.save, 'Cannot save a page with valid name'
  end

  def test_uniq_name
    page = Page.new(:title => "Page", :name => "page_001")
    assert !page.save, "Can save page with not uniq name"
  end

  def test_visible
    admin = users(:users_001) #admin
    non_admin = users(:users_003)
    other_non_admin = users(:users_002)
    anonymus = users(:users_006)
    page = pages(:page_001)
    assert page.visible?(admin), 'Page does not visible for admin user'
    assert !pages(:page_003).visible?(non_admin), 'Non visible page is visible for user'
    assert pages(:page_003).visible?(admin), 'Admin cannot see non visible page'
    # anonymus user
    assert pages(:page_002).visible?(anonymus), 'anonymus cannot see public page'
    assert !pages(:page_001).visible?(anonymus), 'anonymus can see logged page'

    assert pages(:page_002).visible?(non_admin), 'non admin user cannot see logged page'
    assert pages(:page_002).visible?(non_admin), 'non admin user cannot see logged page'
    
    # page for single user
    assert pages(:page_004).visible?(non_admin), 'non admin user cannot see his page'
    assert !pages(:page_004).visible?(other_non_admin), 'other non admin user can see his page'

  end
end
