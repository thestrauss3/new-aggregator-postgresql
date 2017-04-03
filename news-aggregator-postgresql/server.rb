require "sinatra"
require "pg"
require_relative "./app/models/article"

set :bind, '0.0.0.0'  # bind to all interfaces
set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_dev" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/articles'
end

get '/articles' do
  @articles = db_connection { |conn| conn.exec("SELECT * from articles")}
  # @articles = @articles.to_a
  erb :index
end

get '/articles/new' do
  erb :new
end

# post '/articles/new' do
#   repeat_url = false
#   # valid_url_regex = /^((http)?(s)?:\/\/)?(www\.)?[-a-z0-9]+\.[a-z]{2,3}(\/[-a-z0-9]+)*(\.[a-z]{2,4})?$/mi
#   @title= params['Title']
#   @url = params['url']
#   @description = params['description']
#   @error = nil
#   if @title == '' || @url == '' || @description == ''
#      @error = "Please Fill in all all fields"
#      erb :new
#   elsif @description.length < 1
#     @error = "Description is less than 20 characters"
#     erb :new
#   elsif repeat_url == false
#     sql_query = "INSERT INTO articles (title, url, description) VALUES ($1, $2, $3)"
#     article_data = [@title, @url, @description]
#     db_connection { |conn| conn.exec_params(sql_query, article_data)}
#     redirect '/articles'
#   else
#     erb :new
#   end
# end

post '/articles/new' do
  repeat_url = false
  article_info = {
    "title" => params['Title'],
    "url" => params['url'],
    "description" => params['description']
  }
  new_article = Article.new(article_info)
  if new_article.save
    redirect '/articles'
  else
    @title = new_article.title
    @url = new_article.url
    @description = new_article.description
    @errors = new_article.errors
    erb :new
  end
end

# Put your News Aggregator server.rb route code here



#
# @article = Article.new("stuff")
# @article_2 = Article.new("other stuff")
#
# @article.error_check
# @article_2.error_check
#
# Article.all
