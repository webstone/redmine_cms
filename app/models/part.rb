class Part < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :pages, :uniq => true

  acts_as_attachable

  STATUS_ACTIVE = 1
  STATUS_LOCKED = 0

  after_commit :touch_pages

  validates_presence_of :name, :part_type, :content_type, :status_id

  def active?
    self.status_id == Part::STATUS_ACTIVE
  end

private
  def touch_pages
    pages.each{|p| p.touch} if pages
  end

end
