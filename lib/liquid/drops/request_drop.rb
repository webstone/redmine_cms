class RequestDrop < Liquid::Drop
  delegate :accept_language, :path, :fullpath, :url, :remote_ip, :query_string, :method, :to => :@request

  def initialize(app_request)
    @request = app_request
  end

end

