class PagesPart < ActiveRecord::Base
  unloadable
  belongs_to :page
  belongs_to :part

  acts_as_list :scope => 'page_id = \'#{page_id}\''

  default_scope order(:page_id).order(:position)

  before_destroy :touch_page
  after_save :touch_page

  validates_presence_of :page, :part

private

  def touch_page
    page.touch
    page.save
  end

end