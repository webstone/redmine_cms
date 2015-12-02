require 'diff'

class ContentVersionAnnotate
  attr_reader :lines, :content

  def initialize(content)
    @content = content
    current = content
    current_lines = current.content.split(/\r?\n/)
    @lines = current_lines.collect {|t| [nil, nil, t]}
    positions = []
    current_lines.size.times {|i| positions << i}
    while (current.previous)
      d = current.previous.content.split(/\r?\n/).diff(current.content.split(/\r?\n/)).diffs.flatten
      d.each_slice(3) do |s|
        sign, line = s[0], s[1]
        if sign == '+' && positions[line] && positions[line] != -1
          if @lines[positions[line]][0].nil?
            @lines[positions[line]][0] = current.version
            @lines[positions[line]][1] = current.author
          end
        end
      end
      d.each_slice(3) do |s|
        sign, line = s[0], s[1]
        if sign == '-'
          positions.insert(line, -1)
        else
          positions[line] = nil
        end
      end
      positions.compact!
      # Stop if every line is annotated
      break unless @lines.detect { |line| line[0].nil? }
      current = current.previous
    end
    @lines.each { |line|
      line[0] ||= current.version
      # if the last known version is > 1 (eg. history was cleared), we don't know the author
      line[1] ||= current.author if current.version == 1
    }
  end
end


class ContentVersionDiff < Redmine::Helpers::Diff
  attr_reader :version_to, :version_from

  def initialize(version_to, version_from)
    @version_to = version_to
    @version_from = version_from
    super(version_to.content, version_from.content)
  end
end

module ActsAsVersionable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods


    def acts_as_versionable
      has_many :versions, :as => :versionable, :class_name => "CmsContentVersion"

      include ActsAsVersionable::SingletonMethods

      after_save :save_version
      before_save :set_version
    
    end
  end

  module SingletonMethods

    def save_version
      versions.create(:author => User.current, :content => content, :version => version)
    end

    def set_version
      self.version = version + 1
    end

    def annotate(version=nil)
      version = version ? version.to_i : self.version
      c = versions.find_by_version(version)
      c ? ContentVersionAnnotate.new(c) : nil
    end
    
    def diff(version_to=nil, version_from=nil)
      version_to = version_to ? version_to.to_i : self.version
      version_to = versions.find_by_version(version_to)
      version_from = version_from ? versions.find_by_version(version_from.to_i) : try(:previous)
      return nil unless version_to && version_from

      if version_from.version > version_to.version
        version_to, version_from = version_from, version_to
      end

      (version_to && version_from) ? ContentVersionDiff.new(version_to, version_from) : nil
    end

    def previous
      @previous ||= versions.
        reorder('version DESC').
        includes(:author).
        where("version < ?", version).first
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsVersionable)