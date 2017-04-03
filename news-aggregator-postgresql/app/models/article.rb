require "pry"

class Article
  attr_reader :title, :url, :description, :errors
  def initialize(hash = {"title" => nil, "url" => nil, "description" => nil})
    @title = hash["title"]
    @url = hash["url"]
    @description = hash["description"]
    @errors = []
    error_check
  end

  def error_check
    any_field_is_empty?
    url_is_invalid?
    url_repeated?
    description_length_is_20_chars?
  end

  def any_field_is_empty?
    if @title.nil? || @title.strip == '' || @url.nil? || @url.strip == '' || @description.nil? || @description.strip == ''
      @errors << "Please completely fill out form"
      true
    end
  end

  def url_is_invalid?
    valid_url_regex = /^((http)?(s)?:\/\/)?(www\.)?[-a-z0-9]+\.[a-z]{2,3}(\/[-a-z0-9]+)*(\.[a-z]{2,4})?$/mi
    if @url.nil? || @url == ''
      true
    elsif valid_url_regex.match(@url).nil?
      @errors << "Invalid URL"
      true
    end
  end

  def url_repeated?
    articles = db_connection { |conn| conn.exec("SELECT * from articles")}
    articles = articles.to_a
    articles.each do |article|
      if @url == article["url"]
        @errors << "Article with same url already submitted"
        break
      end
    end
    !@errors.empty?
  end

  def description_length_is_20_chars?
    if !@description.nil? && @description.length != 0 && @description.length < 20
      @errors << "Description must be at least 20 characters long"
    end
  end


  def self.all
    @articles = []
    articles = db_connection { |conn| conn.exec("SELECT * from articles")}
    articles.each do |article|
      new_article =  Article.new(article)
      @articles << new_article
    end
    @articles
  end

  def valid?
    @errors.empty?
  end

  def save
    if valid?
      db_connection do |conn|
        sql = "INSERT INTO articles (title, url, description) VALUES ($1, $2, $3)"
        conn.exec_params(sql, [@title, @url, @description])
      end
      true
    else
      false
    end
  end
end
