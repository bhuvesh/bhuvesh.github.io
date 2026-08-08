require "minitest/autorun"
require "uri"
require "yaml"

class PublicationsDataTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  DATA_PATH = File.join(ROOT, "_data", "publications.yml")
  SECTIONS = %w[publications preprints].freeze
  REQUIRED_FIELDS = %w[title authors venue].freeze
  INCORRECT_TRAINING_FREE_URL = "https://arxiv.org/abs/2410.16458"

  def data
    return {} unless File.file?(DATA_PATH)

    YAML.safe_load_file(DATA_PATH, aliases: true) || {}
  end

  def records
    SECTIONS.flat_map { |section| Array(data[section]) }
  end

  def test_data_file_exists
    assert File.file?(DATA_PATH), "expected #{DATA_PATH} to exist"
  end

  def test_expected_sections_are_arrays
    SECTIONS.each do |section|
      assert_kind_of Array, data[section], "#{section} must be an array"
    end
  end

  def test_every_record_has_required_text_fields
    records.each do |record|
      REQUIRED_FIELDS.each do |field|
        value = record[field]
        assert_kind_of String, value, "#{field} must be text in #{record.inspect}"
        refute_empty value.strip, "#{field} must not be blank in #{record.inspect}"
      end
    end
  end

  def test_titles_are_unique_across_sections
    titles = records.map { |record| record["title"] }
    assert_equal titles.uniq, titles
  end

  def test_links_have_labels_and_safe_urls
    records.each do |record|
      Array(record["links"]).each do |link|
        refute_empty link.fetch("label").strip
        url = link.fetch("url")
        refute_empty url.strip
        next if url.start_with?("/")

        uri = URI.parse(url)
        assert_includes %w[http https], uri.scheme, "unsafe URL #{url.inspect}"
      end
    end
  end

  def test_training_free_paper_does_not_use_incorrect_arxiv_url
    urls = records.flat_map { |record| Array(record["links"]) }
                  .map { |link| link["url"] }
    refute_includes urls, INCORRECT_TRAINING_FREE_URL
  end
end
