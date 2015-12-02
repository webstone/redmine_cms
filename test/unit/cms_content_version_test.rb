require File.expand_path('../../test_helper', __FILE__)

class CmsContentVersionTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_create_page_with_version
    page = Page.new(:title => "Page with history", :name => "page_with_history", :content => "This is content for page with history (v1)")
    page.save
    assert_equal page.content, page.versions.first.content
    assert_equal 1, page.version
    assert_equal 1, page.versions.first.version
    assert page.versions.first.current_version?
  end

  def test_create_part_with_version
    part = Part.new(:part_type => "footer", :name => "part_with_history", :content => "This is content for part with history (v1)", :content_type => "html")
    part.save
    assert_equal part.content, part.versions.first.content
    assert_equal 1, part.version
    assert_equal 1, part.versions.first.version
    assert part.versions.first.current_version?
  end

end
