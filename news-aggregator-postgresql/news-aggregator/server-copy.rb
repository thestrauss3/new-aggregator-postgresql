require 'sinatra'
require 'pry'

set :bind, '0.0.0.0'  # bind to all interfaces

get '/' do
  erb :index
end
get "/articles" do
  @articles = File.readlines('articles.csv')
  erb :articles
end

get "/articles/new" do
  erb :article_new
end

post '/articles/new' do
  @error = ''
  @name= params['name']
  @url = params['url']
  @description = params['description']
  valid_url_regex = /((?:https?\:\/\/|www\.)(?:[-a-z0-9]+\.)*[-a-z0-9]+.*)/i
  #binding.pry
  @list_of_articles = File.readlines('articles.csv')

  if @name == '' || @url == '' || @description == ''

     @error += "Please Fill in all all fields\n"
     erb :article_new
  end
  if @description.length < 20
     @error += "Description is less than 20 characters\n"
     erb :article_new
  end
  if valid_url_regex.match(@url).nil?
     @error += "URL is invalid\n"
     erb :article_new
  end
  @list_of_articles.each do |article|
    if article.split(",")[1] == @url
      @error += "That article is already submitted"
      erb :article_new
    end
  end
  if @error == ''
    binding.pry
    csv_line = @name + "," + @url + "," + @description
    File.open('articles.csv', 'a') do |file|
      file.puts(csv_line)
    end
  redirect '/articles'
  end
end
