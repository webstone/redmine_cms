class ContactsDrop < Liquid::Drop

  def initialize(contacts)
    @contacts = contacts
  end

  def before_method(id) 
    contact = @contacts.where(:id => id).first || Contact.new
    ContactDrop.new contact
  end

  def all
    @all ||= @contacts.map do |contact|
      ContactDrop.new contact
    end
  end

  def visible
    @visible ||= @contacts.visible.map do |contact|
      ContactDrop.new contact
    end
  end

  def each(&block) 
    all.each(&block)
  end

end


class ContactDrop < Liquid::Drop

  delegate :id, :name, :firstname, :lastname, :tags, :company, :address, :phones, :emails, :to => :@contact

  def initialize(contact)
    @contact = contact
  end

  def avatar
    helpers.url_for :controller => "attachments", :action => "contacts_thumbnail", :id => @contact.avatar, :size => '64', :only_path => true
  end

  private

  def helpers
    Rails.application.routes.url_helpers
  end    

end