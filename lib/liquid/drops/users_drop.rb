class UsersDrop < Liquid::Drop

  def initialize(users)
    @users = users
  end

  def before_method(login)
    user = @users.where(:login => login).first || User.new
    UserDrop.new user
  end

  def current
    UserDrop.new User.current
  end

  def all
    @all ||= @users.map do |user|
      UserDrop.new user
    end
  end

  def each(&block)
    all.each(&block)
  end

  def size
    @users.size
  end

  def previous_user
    user = @context['user']
    index = user && user_drops.keys.index(user.id)
    previous_id = index && !index.zero? && user_drops.keys[index-1]
    user_drops[previous_id].url if previous_id
  end

  def next_user
    user = @context['user']
    index = user && user_drops.keys.index(user.id)
    next_id = index && user_drops.keys[index+1]
    user_drops[next_id].url if next_id
  end

  private

  def user_drops # {1 => userDrop.new(user)}
    Hash[ *self.all do |user_drop|
      [user_drop.id, user_drop]
    end.flatten ]
  end

end


class UserDrop < Liquid::Drop

  delegate :id, :name, :firstname, :lastname, :mail, :active?, :admin?, :logged?, :language, :to => :@user

  def initialize(user)
    @user = user
  end

  def avatar
    ApplicationController.helpers.avatar(@user)
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

