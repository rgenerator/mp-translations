# -*- encoding : utf-8 -*-
require 'csv_importer'

class Translations < Thor
  require './config/environment.rb'

  # Needed to avoid circular reference caused by observers + Rails autoloading
  Dir['./app/models/*.rb'].each { |path| require path }

  class Cache < Thor
    desc 'load', 'load all of the translations into the cache'
    def load
      cache = TranslationCache.new
      Translation.includes(:source).find_in_batches { |t| cache.update(t) }
    end
  end

  desc 'export <languages>', "export PO file(s) for the given language(s). Supported languages are: #{Source.supported_languages.to_sentence}"
  def export(language, *others)
    (others << language).each do |language|
      check_language(language)
      file = generate_file_with_comments(language)
      search_and_write_file(file, language)
      close_file_with_comments(file, language)
    end
  end

  desc "import <csv_file>", "create sources and translations from the given CSV file"
  def import(csv_file)
    errors = CSVImporter.new.import(csv_file)
    if errors.none?
      puts "Import succeeded."
    else
      printf "Import resulted in %s %s.\n", errors.size, "error".pluralize(errors.size)
      errors.each { |error| printf "Row: %d, error: %s\n", error.row, error.message }
    end
  end

  no_tasks do
    def check_language(language)
      raise UnsupportedLanguageError unless Source.supported_languages.include?(language)
    end

    def generate_file_with_comments(language)
      file = File.new("#{Rails.root}/tmp/#{language}.po", 'wb')
      file.write "# -*- encoding : utf-8 -*-\n"
      file.write "# Autogenerated file\n"
      file.write "# Language: #{language}\n"
      file.write "#\n"
      file
    end

    def close_file_with_comments(file, language)
      file.close
    end

    def get_source_text_to_write(idx, text, ary_length)
      str = "msgid \"#{text}\" \n"
      str = "msgid \"#{text + '\n'}\" \n" if(ary_length > 1 && idx+1 < ary_length)
      str.gsub!('msgid','') if idx > 0
      str
    end

    def get_translation_text_to_write(idx, text, ary_length)
      str = "msgstr \"#{text}\" \n"
      str = "msgstr \"#{text + '\n'}\" \n" if(ary_length > 1 && idx+1 < ary_length)
      str.gsub!('msgstr','') if idx > 0
      str  << "\n" if idx + 1  == ary_length
      str
    end


    def search_and_write_file(file, language)
      Source.includes(:translations)
	.where('translations.language = ?', language)
	.references(:translations)
	.find_each do |source|

	translation = source.translations.find_by(language: language)
	next unless translation

	source_text = source.text.dup
	source_text_ary = source_text.split("\n")

	source_text_ary.each_with_index do |l, idx|
	  l.gsub!("\r",'')
	  file.write(get_source_text_to_write(idx, l, source_text_ary.length))
	end

	translation_text = translation.text.dup
	translation_text_ary = translation_text.split("\n")

	translation_text_ary.each_with_index do |l, idx|
	  l.gsub!("\r",'')
	  file.write(get_translation_text_to_write(idx, l, translation_text_ary.length))
	end
      end
    end
  end
end
