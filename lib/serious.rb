# encoding: utf-8

if "1.9".respond_to?(:encoding)
  Encoding.default_external = 'UTF-8'
  Encoding.default_internal = 'UTF-8'
end

require 'rubygems'
require 'sinatra/base'
require 'stupid_formatter'
require 'yaml'
require 'builder'
require 'ruby_ext'

class Serious < Sinatra::Base

  set :articles, Proc.new { File.join(Dir.getwd, 'articles') }
  set :pages, Proc.new { File.join(Dir.getwd, 'pages') }
  # Required to serve static files, see http://www.sinatrarb.com/configuration.html
  set :static, true
  set :future, false

  not_found do
    erb :"404"
  end

  before do
    headers['Cache-Control'] = "public, max-age=#{Serious.cache_timeout}"
  end

  helpers do
    # i18n
    def t *args
      I18n.t *args
    end

    # Helper for rendering partial _archives
    def render_archived(articles)
      render :erb, :'_archives', :locals => { :articles => articles },
        :layout => false
    end

    def render_article(article, summary_only=false)
      render :erb, :'_article', :locals => { :article => article,
        :summary_only => summary_only }, :layout => !summary_only
    end

    def render_partial(name)
      render :erb, :"_#{name}", :layout => false
    end
  end

  # Index page
  get '/' do
    @recent = Article.all(:limit => Serious.items_on_index)
    @archived = Article.all(:limit => Serious.archived_on_index,
      :offset => Serious.items_on_index)

    erb :index
  end

  get '/atom.xml' do
    @articles = Article.all(:limit => Serious.items_in_feed)

    builder :atom
  end

  # Specific article route
  get %r{^/(\d{4})/(\d{1,2})/(\d{1,2})/([^\/]+)} do
    halt 404 unless @article = Article.first(*params[:captures])

    render_article @article
  end

  # Archives route
  get %r{^/(\d{4})[/]{0,1}(\d{0,2})[/]{0,1}(\d{0,2})[/]{0,1}$} do
    selection = params[:captures].reject do |s|
      s.strip.length == 0
    end.map do |n|
      n.length == 1 ? "%02d" % n : n
    end

    @articles = Article.find(*selection)
    @title = t('serious.views.archives.dated', :date => selection.join('-'))

    erb :archives
  end

  get "/archives" do
    @articles = Article.all
    @title = t('serious.views.archives.general')

    erb :archives
  end

  get "/archives/:tag" do
    if params[:tag] && params[:tag].match(/ /)
      params[:tag].gsub! ' ', '-'
      redirect "/archives/#{params[:tag]}"
    end

    @articles = Article.all :tag => params[:tag]
    @title = t('serious.views.archives.tagged', :tag => params[:tag])

    erb :archives
  end

  get "/pages" do
    @articles = Page.all
    @title = t('serious.views.pages')

    erb :archives
  end

  get "/pages/:page" do
    halt 404 unless @article = Page.find(params[:page])
    render_article @article
  end
end

require 'serious/version'
require 'serious/i18n'
require 'serious/article'
require 'serious/page'

# Set up default stupid_formatter chain
StupidFormatter.chain = [StupidFormatter::Erb, StupidFormatter::RDiscount]

# Set up defaults for app
Serious.set :root, File.join(File.dirname(__FILE__), 'site')
Serious.set :title, "Serious"
Serious.set :author, "unknown"
Serious.set :url, 'http://localhost:3000'
# Number of items to display in atom feed
Serious.set :items_in_feed, 25
# Number of items to display with summary on main page
Serious.set :items_on_index, 3
# Number of items to display small (title only) on main page
Serious.set :archived_on_index, 10
Serious.set :cache_timeout, 300
Serious.set :run, false
Serious.set :environment, :test
Serious.set :date_format, "%B %o %Y"
Serious.set :disqus, false
Serious.set :google_analytics, false
Serious.set :feed_url, '/atom.xml'
Serious.set :summary_delimiter, '~'
