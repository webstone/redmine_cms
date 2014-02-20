class NewssDrop < Liquid::Drop

  def initialize(newss)
    @newss = newss
  end

  def before_method(id)
    news = @newss.where(:id => id).first || News.new
    NewsDrop.new news
  end

  def last
    NewsDrop.new News.last
  end

  def all
    @all ||= @newss.map do |news|
      NewsDrop.new news
    end
  end

  def each(&block)
    all.each(&block)
  end

  def newss_count
    @newss.size
  end

  def previous_news
    news = @context['news']
    index = news && news_drops.keys.index(news.id)
    previous_id = index && !index.zero? && news_drops.keys[index-1]
    news_drops[previous_id].url if previous_id
  end

  def next_news
    news = @context['news']
    index = news && news_drops.keys.index(news.id)
    next_id = index && news_drops.keys[index+1]
    news_drops[next_id].url if next_id
  end

  private

  def news_drops # {1 => newsDrop.new(news)}
    Hash[ *self.all do |news_drop|
      [news_drop.id, news_drop]
    end.flatten ]
  end

end


class NewsDrop < Liquid::Drop

  delegate :id, :title, :summary, :description, :visible?, :commentable?, :to => :@news

  def initialize(news)
    @news = news
  end

  def author
    UserDrop.new @news.author
  end

end

