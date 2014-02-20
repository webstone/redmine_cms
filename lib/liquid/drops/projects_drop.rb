class ProjectsDrop < Liquid::Drop

  def initialize(projects)
    @projects = projects
  end

  def before_method(identifier)
    project = @projects.where(:identifier => identifier).first || Project.new
    ProjectDrop.new project
  end

  def all
    @all ||= @projects.map do |project|
      ProjectDrop.new project
    end
  end

  def each(&block)
    all.each(&block)
  end

  def projects_count
    @projects.size
  end

  def previous_project
    project = @context['project']
    index = project && project_drops.keys.index(project.id)
    previous_id = index && !index.zero? && project_drops.keys[index-1]
    project_drops[previous_id].url if previous_id
  end

  def next_project
    project = @context['project']
    index = project && project_drops.keys.index(project.id)
    next_id = index && project_drops.keys[index+1]
    project_drops[next_id].url if next_id
  end

  private

  def project_drops # {1 => projectDrop.new(project)}
    Hash[ *self.all do |project_drop|
      [project_drop.id, project_drop]
    end.flatten ]
  end

end


class ProjectDrop < Liquid::Drop

  delegate :id,
           :identifier,
           :name,
           :is_public,
           :description,
           :visible?,
           :active?,
           :archived?,
           :short_description,
           :start_date,
           :due_date,
           :overdue?,
           :completed_percent,
           :to => :@project

  def initialize(project)
    @project = project
  end

  def users
    @users ||= @project.users.map{|u| UserDrop.new(u)}
  end

  def subprojects
    @subprojects ||= ProjectsDrop.new @project.children
  end

end

