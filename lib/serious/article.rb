# encoding: utf-8
#
# Backend for file-system based articles
#
class Serious::Article
  # Exception for invalid filenames
  class InvalidFilename < StandardError
  end

  class << self
    #
    # Returns all articles. Can be drilled down by (optional) :limit,
    # :offset and :tag options
    #
    def all(options={})
      options = {:limit => 10000, :offset => 0, :tag => nil}.merge(options)
      now = DateTime.now
      articles = article_paths.map do |article_path|
        article = new(article_path)
        if article && (Serious.future || article.date <= now)
          next article unless options[:tag]
          spaceless_tags = article.tags.map { |tag| tag.gsub ' ', '-' }
          article if spaceless_tags.include? options[:tag].gsub ' ', '-'
        end
      end.compact[options[:offset]...options[:limit]+options[:offset]]

      articles || []
    end

    #
    # Retrieves the article(s) for the given arguments. The arguments must be part of the filename.
    # You can give any combination, but the arguments must appear in the same order as given in the
    # arguments, so find(2009, 11) works for all articles in november 2009,
    # find('foo-bar') works for all articles with permalink 'foo-bar', but find(2009, 'foo-bar')
    # will not return anything.
    #
    def find(*args)
      # Reformat arguments (one-digit months and days should be converted to two-digit format)
      args = args.map {|a| a.to_s =~ /^\d{1}$/ ? "%02d" % a : a }
      now = DateTime.now
      articles = article_paths.select {|path| File.basename(path) =~ /#{args.join('-')}/i }.map do |path|
        article = new(path)
        article if article && (Serious.future || article.date <= now)
      end.compact
    end

    #
    # Find the article for given arguments (same as find), but returns only the first one
    #
    def first(*args)
      find(*args).first
    end

    #
    # Lists all the tags of all articles (very fucking expensive task at first time).
    #
    def tags
      @tags ||= find.map(&:tags).flatten.inject(Hash.new(0)) {|freqs, tag| freqs[tag] += 1; freqs}
    end

    private

      # Returns all article files in articles path
      def article_paths
        @article_paths ||= Dir[File.join(Serious.articles, '*')].sort.reverse
      end
  end

  attr_reader :path, :date, :permalink

  def initialize(path)
    @path = path
    extract_date_and_permalink!
    # TODO: Add some nice error handling!
  end

  # Lazy-loading title accessor
  def title
    @title ||= yaml["title"]
  end

  # Lazy-loading author accessor with fallback to Serious.author
  def author
    @author ||= yaml["author"] || Serious.author
  end

  # Lazy-loading tags accessor
  def tags
    @tags ||= yaml["tags"] || []
  end

  # Lazy-loading summary delimiter accessor with fallback to Serious.summary_delimiter
  def delimiter
    @delimiter ||= yaml["delimiter"] || Serious.summary_delimiter
  end

  # Cached lazy-loading of summary
  def summary
    return @summary if @summary
    @summary ||= content.split(delimiter, 2).first.chomp
  end

  # Cached lazy-loading of body
  def body
    return @body if @body
    @body ||= content.split(delimiter, 2).join("").chomp
  end

  # Compiles the url for this article
  def url
    @url ||= "/#{date.year}/#{"%02d" % date.month}/#{"%02d" % date.day}/#{permalink}"
  end

  # url combined with Serious.url
  def full_url
    @full_url ||= File.join(Serious.url, url)
  end

  # Equality comparison
  def ==(article)
    path == article.path
  rescue NoMethodError
    false
  end

  # Collection of validation errors
  def errors
    @errors || valid?
  end

  #
  # Loads the article and makes sure it can be loaded, formatted etc..
  # Error messages can be read through errors array
  #
  def valid?
    @errors = []

    unless title.kind_of?(String) and title.length > 0
      errors << I18n.t('serious.article.errors.no_title')
    end

    unless author.kind_of?(String) and author.length > 0
      errors << I18n.t('serious.article.errors.no_author')
    end

    unless tags.kind_of?(Array) and tags_are_strings?
      errors << I18n.t('serious.article.errors.wrong_tags')
    end

    begin
      summary.formatted
    rescue => err
      errors << I18n.t('serious.article.errors.summary_failed')
    end

    begin
      body.formatted
    rescue => err
      errors << I18n.t('serious.article.errors.body_failed')
    end
  ensure
    return errors.length == 0
  end

  private

    # Will extract the date and permalink from the filename.
    def extract_date_and_permalink!
      match = File.basename(path).match(/(\d{4})-(\d{1,2})-(\d{1,2})-([^\.]+)/)
      @date = Date.new(match[1].to_i, match[2].to_i, match[3].to_i)
      @permalink = match[4]
    rescue NoMethodError => err
      raise InvalidFilename, I18n.t('serious.article.errors.body_failed',
        :path => File.basename(path))
    end

    # Will check that every tag is a String
    def tags_are_strings?
      tags.inject(true) { |r, tag| r && tag.is_a?(String) }
    end

    #
    # Will read the actual article file and store the yaml front processed in @yaml,
    # the content in @content
    #
    def load!
      return true if @yaml and @content
      yaml, @content = File.read(path).split(/\n\n/, 2)
      @yaml = YAML.load(yaml)
    end

    # Cached lazy-loading yaml config
    def yaml
      return @yaml if @yaml
      load!
      @yaml
    end

    # Cached lazy-loading content
    def content
      return @content if @content
      load!
      @content
    end
end
