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
  @error = nil
  @name= params['name']
  @url = params['url']
  @description = params['description']
  repeat_url = false
  valid_url_regex = /^((http)?(s)?:\/\/)?(www\.)?[-a-z0-9]+\.[a-z]{2,3}(\/[-a-z0-9]+)*(\.[a-z]{2,4})?$/mi
  #binding.pry
  @list_of_articles = File.readlines('articles.csv')
  @list_of_articles.each do |article|
    if article.split(",")[1] == @url
      @error = "That article is already submitted"
      repeat_url = true
    end
  end
  if @name == '' || @url == '' || @description == ''
     @error = "Please Fill in all all fields"
     erb :article_new
  elsif @description.length < 1
    @error = "Description is less than 20 characters"
    erb :article_new
  elsif valid_url_regex.match(@url).nil?
    @error = "URL is invalid"
    erb :article_new
  elsif repeat_url == false
    csv_line = @name + "," + @url + "," + @description
    File.open('articles.csv', 'a') do |file|
      file.puts(csv_line)
    end
    redirect '/articles'
  else
    erb :article_new
  end
end
