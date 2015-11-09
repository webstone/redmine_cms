require File.expand_path('../../test_helper', __FILE__)

class PartTest < ActiveSupport::TestCase

  fixtures :parts

  RedmineCMS::TestCase.create_fixtures( :parts)
  
  def test_create_part
    part = Part.new
    part.name = "name"
    part.part_type = "footer"
    part.content_type = "html"
    part.content = "New content"
    assert part.save, "Cannot save a part"
  end

  def test_fail_create
    part = Part.new
    assert !part.save, "Can save part without name, part_type and content_type"
    part.name = "name"
    assert !part.save, "Can save part without part_type and content_type"
    part.part_type = "header"
    assert !part.save, "Can save part without content_type"
  end

  def test_copy_part
    part = parts(:part_001)
    new_part = Part.new
    new_part.copy_from(part)
    assert_not_equal new_part.name, part.name
    assert_equal new_part.part_type, part.part_type
    assert_equal new_part.content_type, part.content_type
    assert_equal new_part.content, part.content
  end

  def test_fail_copy
    new_part = Part.new
    new_part.copy_from("trash")
    assert_equal new_part.part_type, nil
    assert_equal new_part.content_type, nil
    assert_equal new_part.content, nil
  end

  def test_to_s
    part = parts(:part_001)
    assert_equal "#{part.name} (#{part.content_type})", part.to_s
  end

end
