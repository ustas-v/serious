# encoding: utf-8
require 'helper'

class TestI18n < Test::Unit::TestCase
  context 'Internationalization' do
    setup do
      locales_path = File.expand_path('../locales/**/*.yml', __FILE__)
      I18n.load_path << (@locales = Dir[locales_path])
      I18n.reload!
    end

    teardown do
      I18n.load_path -= @locales
      I18n.reload!
    end

    should 'use English by default' do
      assert_equal :en, I18n.locale
      assert_equal :en, I18n.default_locale
    end

    context 'English' do
      setup do
        @old_locale = I18n.locale
        I18n.locale = :en
      end

      teardown do
        I18n.locale = @old_locale
      end

      should 'validate serious.views locales' do
        assert_equal 'Archives', I18n.t('serious.views.archives.general')
        assert_equal 'Archives for 2012',
          I18n.t('serious.views.archives.dated', :date => '2012')
        assert_equal 'Archives for "serious" tag',
          I18n.t('serious.views.archives.tagged', :tag => 'serious')
        assert_equal 'Pages', I18n.t('serious.views.pages')
      end

      should 'validate serious.article locales' do
        assert_equal 'Title is absent',
          I18n.t('serious.article.errors.no_title')
        assert_equal 'No author given',
          I18n.t('serious.article.errors.no_author')
        assert_equal 'Wrong tags given',
          I18n.t('serious.article.errors.wrong_tags')
        assert_equal 'Failed to format summary',
          I18n.t('serious.article.errors.summary_failed')
        assert_equal 'Failed to format body',
          I18n.t('serious.article.errors.body_failed')
        assert_equal 'Failed to extract date or permalink from /dev/null',
          I18n.t('serious.article.errors.invalid_filename',
            :path => '/dev/null')
      end
    end

    context 'Russian' do
      setup do
        @old_locale = I18n.locale
        I18n.locale = :ru
      end

      teardown do
        I18n.locale = @old_locale
      end

      should 'validate serious.views locales' do
        assert_equal 'Все посты', I18n.t('serious.views.archives.general')
        assert_equal 'Все посты с датой 2012',
          I18n.t('serious.views.archives.dated', :date => '2012')
        assert_equal 'Все посты с тегом "serious"',
          I18n.t('serious.views.archives.tagged', :tag => 'serious')
        assert_equal 'Страницы', I18n.t('serious.views.pages')
      end

      should 'validate serious.article locales' do
        assert_equal 'Заголовок пуст',
          I18n.t('serious.article.errors.no_title')
        assert_equal 'Автор не указан',
          I18n.t('serious.article.errors.no_author')
        assert_equal 'Теги перечислены неверно',
          I18n.t('serious.article.errors.wrong_tags')
        assert_equal 'Не получилось отформатировать сводку поста',
          I18n.t('serious.article.errors.summary_failed')
        assert_equal 'Не получилось отформатировать тело поста',
          I18n.t('serious.article.errors.body_failed')
        assert_equal 'Не получилось извлечь дату или URL из файла /dev/null',
          I18n.t('serious.article.errors.invalid_filename',
            :path => '/dev/null')
      end
    end
  end
end
