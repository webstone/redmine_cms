class PagesPart < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :page
  belongs_to :part

  acts_as_list :scope => 'page_id = \'#{page_id}\''

  scope :active, lambda{where(:status_id => RedmineCms::STATUS_ACTIVE)}
  scope :order_by_type, lambda{includes(:part).order("#{Part.table_name}.part_type").order(:position)}

  before_destroy :touch_page
  after_save :touch_page

  validates_presence_of :page, :part

  def active?
    self.status_id == RedmineCms::STATUS_ACTIVE
  end

  attr_protected :id
  safe_attributes 'page',
    'part'
  
private

  def touch_page
    page.touch
    page.save
  end

end