class Variable < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  attr_protected :id
  safe_attributes 'name', 'value'

  validates_presence_of :name
  validates_format_of :name, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/
  
end
