require File.expand_path('../../test_helper', __FILE__)

class CmsVariableTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_create_variable
    new_variable = CmsVariable.new
    assert !new_variable.save, "Can save Variable without name"
    new_variable.name = "bad format for name"
    assert !new_variable.save, "Can save Variable with a bad format of name"
    new_variable.name = "нельзя_использовать_кириллицу"
    assert !new_variable.save, "Can save Variable with a cirillic symbol in name"
    new_variable.name = "good_name"
    assert new_variable.save, "Cannot save Variable with correct name"
  end
end
