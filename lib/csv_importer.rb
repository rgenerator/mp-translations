require 'csv'

class CSVImporter
  ImportError = Struct.new(:row, :data, :message)

  def import(path)
    errors = []
    rownum = 1

    CSV.foreach(path, headers: true, skip_blanks: true) do |row|
      begin
        rownum += 1
        import_row(row)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
        errors << ImportError.new(rownum, row, e.message)
      end
    end

    errors
  end

  private

  def html_paragraphs(text)
    # Translations are looked up by the source text.
    # Any "\n"s will be replaced with  "\r\n" on form submission but we do this now so to minimize translation breakage.
    sprintf "<p>%s</p>", text.split(/^\s*$/).map{ |s| s.strip.gsub(/(?<!\r)\n/, "\r\n") }.join("</p><p>")
  end

  def import_row(row)
    languages = row.headers.dup.reject(&:nil?)
    languages.shift unless languages.first == 'en'

    source_language = languages.shift
    return unless row[source_language].present?

    source = Source.new
    source.language = source_language.gsub(/_/,'-')

    if /^\s*$/.match(row[source_language])
      source.text = html_paragraphs(row[source_language])
    else
      source.text = row[source_language]
    end

    languages.each do |lang|
      t = Translation.new
      t.language = lang.dup
      if /^\s*$/.match(row[lang])
	t.text = html_paragraphs(row[lang])
      else
	t.text = row[lang]
      end
      source.translations << t
    end

    source.save!
  end
end
