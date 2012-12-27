class Part < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :pages, :uniq => true

  acts_as_attachable

  default_scope order(:part_type)

  liquid_methods :name, :attachments, :title


  after_commit :touch_pages

  validates_uniqueness_of :name
  validates_presence_of :name, :part_type, :content_type
  validates_format_of :name, :with => /^(?!\d+$)[a-z0-9\-_]*$/

 [:content, :header, :footer, :sidebar].each do |name, params|
    src = <<-END_SRC
    def is_#{name}_type?
      self.part_type.strip.downcase == "#{name.to_s}"
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end


private
  def touch_pages
    pages.each{|p| p.touch} if pages
  end

end
