class Page < ActiveRecord::Base
  unloadable

  has_many :pages_parts
  has_many :parts, :uniq => true, :through => :pages_parts

  acts_as_attachable
  acts_as_tree :dependent => :nullify

  validates_presence_of :name, :title
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_length_of :title, :maximum => 255
  validate :validate_page
  validates_format_of :name, :with => /^(?!\d+$)[a-z0-9\-_]*$/

  [:content, :header, :footer, :sidebar].each do |name, params|
    src = <<-END_SRC
    def #{name}_parts
      pages_parts.includes(:part).where(:parts => {:part_type => "#{name.to_s}"})
    end

    END_SRC
    class_eval src, __FILE__, __LINE__
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

  def self.main
    Page.find_by_name('main')
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

  protected

  def validate_page
    if parent_id && parent_id_changed?
      errors.add(:parent_id, :invalid) unless valid_parents.include?(parent)
    end
  end

end
