class IssuesDrop < Liquid::Drop

  def initialize(issues)
    @issues = issues
  end

  def before_method(id)
    issue = @issues.where(:id => id).first || Issue.new
    IssueDrop.new issue
  end

  def all
    @all ||= @issues.map do |issue|
      IssueDrop.new issue
    end
  end

  def last_updated
    all.sort{ |x,y| y.updated_on <=> x.updated_on }.first
  end

  def each(&block)
    all.each(&block)
  end

  def size
    @issues.size
  end

  def previous_issue
    issue = @context['issue']
    index = issue && issue_drops.keys.index(issue.id)
    previous_id = index && !index.zero? && issue_drops.keys[index-1]
    issue_drops[previous_id].url if previous_id
  end

  def next_issue
    issue = @context['issue']
    index = issue && issue_drops.keys.index(issue.id)
    next_id = index && issue_drops.keys[index+1]
    issue_drops[next_id].url if next_id
  end

  private

  def issue_drops # {1 => issueDrop.new(issue)}
    Hash[ *self.all do |issue_drop|
      [issue_drop.id, issue_drop]
    end.flatten ]
  end

end


class IssueDrop < Liquid::Drop
  include ActionView::Helpers::UrlHelper

  delegate :id,
           :subject,
           :description,
           :visible?,
           :open?,
           :start_date,
           :due_date,
           :overdue?,
           :completed_percent,
           :updated_on,
           :created_on,
           :to => :@issue

  def initialize(issue)
    @issue = issue
  end

  def link
    link_to @issue.name, self.url
  end

  def url
    Rails.application.routes.url_helpers.issue_path(@issue)
  end

  def author
    @users ||= UsersDrop.new @issue.author
  end

end

