class CmsRedirect
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :source_path, :destination_path

  validates_presence_of :source_path, :destination_path
  validates_format_of :source_path, :with => /^(?!\d+$)\/[a-z0-9\-_\/]*$/
  validates_length_of :source_path, :destination_path, :maximum => 200
  validate :validate_redirect

  def self.all
    RedmineCms.redirects.map{|k, v| CmsRedirect.new(:source_path => k, :destination_path => v) }
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    redirects = Setting.plugin_redmine_cms[:redirects].is_a?(Hash) ? Setting.plugin_redmine_cms[:redirects] : {}
    redirects.merge!(source_path => destination_path)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({:redirects => redirects})
  end

  def destroy
    redirects = Setting.plugin_redmine_cms[:redirects].is_a?(Hash) ? Setting.plugin_redmine_cms[:redirects] : {}
    redirects.delete(source_path)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({:redirects => redirects})
    true
  end

  def to_param
    if source_path == "/"
      "_"
    else
      source_path.parameterize
    end
  end

  def persisted?
    false
  end

  private

  def validate_redirect
    if source_path.to_s.start_with?("/admin") ||
            source_path.to_s.start_with?("/settings") ||
            source_path.to_s.start_with?("/users") ||
            source_path.to_s.start_with?("/groups") ||
            source_path.to_s.start_with?("/plugins") ||
            source_path.to_s.start_with?("/cms_redirects")
      errors.add :base, 'Invalid source path'
    end
  end

end