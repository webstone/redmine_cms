require File.expand_path('../../test_helper', __FILE__)

class PagesPartTest < ActiveSupport::TestCase

  fixtures :pages, :parts, :pages_parts

  RedmineCMS::TestCase.create_fixtures([:pages, :parts, :pages_parts])

  def test_creating
    page_last_update_at = pages(:page_002).updated_at
    new_pp = PagesPart.new
    assert !new_pp.save, "Can save pages part without a page and a part"
    new_pp.page = pages(:page_001)
    assert !new_pp.save, "Can save pages part without a part"
    new_pp.page = nil
    new_pp.part = parts(:part_002)
    assert !new_pp.save, "Can save pages part without a page"
    assert PagesPart.create(:page => pages(:page_002), :part => parts(:part_002))
    assert_not_equal page_last_update_at, pages(:page_002).updated_at
  end

  def test_active
    assert pages_parts(:pages_part_001).active?, "Wrong result in active? function"
  end
end