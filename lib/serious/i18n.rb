# encoding: utf-8

require 'i18n'

I18n.load_path << Dir[File.expand_path('../locale/**/*.yml', __FILE__)]

if Serious.root
  I18n.load_path << Dir[File.expand_path('locales/**/*.yml', Serious.root)]
end

I18n.reload!
