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
    user = users(:users_001) #admin
    page = pages(:page_001)
    assert page.visible?(user), 'Page does not visible for admin user'
    # not active page

    # anonymus user

    # logged page

    # public page
  end
end
