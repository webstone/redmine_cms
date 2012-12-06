module PartsHelper
  def change_part_status_link(part)
    url = {:controller => 'parts', :action => 'update', :id => part, :part => params[:part], :status => params[:status], :tab => nil}

    if part.active?
      link_to l(:button_lock), url.merge(:part => {:status_id => RedmineCms::STATUS_LOCKED}, :unlock => true), :method => :put, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(:part => {:status_id => RedmineCms::STATUS_ACTIVE}, :unlock => true), :method => :put, :class => 'icon icon-unlock'
    end
  end  
end
