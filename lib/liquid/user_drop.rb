class UserDrop < Liquid::Drop

  def initialize(user)
    @user = user
  end

  def name
    @user.name
  end

  def firstname
    @user.firstname
  end

  def lastname
    @user.lastname
  end

  def email
    @user.mail
  end  

  def active?
    @user.active?
  end  

  def admin?
    @user.admin?
  end

  def language
    ::I18n.locale.to_s    
  end  

  def permissions
    roles = @user.memberships.collect {|m| m.roles}.flatten.uniq
    roles << (@user.logged? ? Role.non_member : Role.anonymous)
    roles.map(&:permissions).flatten.uniq.map(&:to_s)
  end

  def groups
    @user.groups.map(&:name)
  end
 
  def projects
    @user.memberships.map(&:project).flatten.uniq.map(&:identifier).uniq
  end

end