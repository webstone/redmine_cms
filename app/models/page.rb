class Page < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :page_project, :class_name => 'Project', :foreign_key => 'project_id'
  has_many :pages_parts

  if Rails::VERSION::MAJOR > 3
    has_many :parts, lambda {uniq }, :through => :pages_parts
  else
    has_many :parts, :uniq => true, :through => :pages_parts
  end

  acts_as_attachable
  acts_as_tree :dependent => :nullify
  acts_as_versionable

  scope :active, lambda{where(:status_id => RedmineCms::STATUS_ACTIVE)}
  scope :visible, lambda{where(Page.visible_condition)}

  validates_presence_of :name, :title
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_length_of :title, :maximum => 255
  validate :validate_page
  validates_format_of :name, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/i

  [:content, :header, :footer, :sidebar].each do |name, params|
    src = <<-END_SRC
    def #{name}_parts
      pages_parts.includes(:part).where(:parts => {:part_type => "#{name.to_s}"})
    end

    END_SRC
    class_eval src, __FILE__, __LINE__
  end
  attr_protected :id
  safe_attributes 'name',
    'title',
    'project_id',
    'visibility',
    'keywords',
    'description',
    'content_type',
    'is_cached',
    'content'

  def self.visible_condition(user=User.current)
    user_ids = [user.id] + user.groups.map(&:id)
    cond = ""
    cond << " ((#{table_name}.visibility = 'public')"
    cond << " OR (#{table_name}.visibility = 'logged')" if User.current.logged?
    cond << " OR (#{table_name}.visibility IN (#{user_ids.join(',')})))"
  end

  def visible?(user=User.current)
    if active?
      return true if visibility == 'public'
      return true if visibility == 'logged' && user.logged?
      user_ids = [user.id] + user.groups.map(&:id)
      return true if user_ids.include?(visibility.to_i) && user.logged?
    end
    RedmineCms.allow_edit?(user)
  end

  def active?
    self.status_id == RedmineCms::STATUS_ACTIVE
  end

  def to_param
    name.parameterize
  end

  def reload(*args)
    @valid_parents = nil
    super
  end

  def to_s
    name
  end

  def valid_parents
    @valid_parents ||= Page.all - self_and_descendants
  end

  def self.page_tree(pages, parent_id=nil, level=0)
    tree = []
    pages.select {|page| page.parent_id == parent_id}.sort_by(&:title).each do |page|
      tree << [page, level]
      tree += page_tree(pages, page.id, level+1)
    end
    if block_given?
      tree.each do |page, level|
        yield page, level
      end
    end
    tree
  end

  def copy_from(arg)
    page = arg.is_a?(Page) ? arg : Page.find_by_name(arg)
    self.attributes = page.attributes.dup.except("id", "created_at", "updated_at")
    self.name = self.name.to_s + "_copy"
    self
  end
  
  protected

  def validate_page
    if parent_id && parent_id_changed?
      errors.add(:parent_id, :invalid) unless valid_parents.include?(parent)
    end
  end

end
