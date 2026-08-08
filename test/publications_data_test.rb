require "minitest/autorun"
require "uri"
require "yaml"

class PublicationsDataTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  DATA_PATH = File.join(ROOT, "_data", "publications.yml")
  SECTIONS = %w[publications preprints].freeze
  REQUIRED_FIELDS = %w[title authors venue].freeze
  INCORRECT_TRAINING_FREE_URL = "https://arxiv.org/abs/2410.16458"
  EXPECTED_NEW_PAPER_AUTHORS = {
    "Semantic IDs for Recommender Systems at Snapchat: Use Cases, Technical Challenges, and Design Choices" =>
      "C. M. Ju, T. Zhao, L. Neves, L. Collins, B. Kumar, J. Ren, L. Zhang, W. Zhuo, V. Zhang, X. Bai, J. Li, K. Iyer, Z. Fan, Y. Xu, Y. Chen, P. Yu, M. Malik, N. Shah",
    "Exploiting ID-Text Complementarity via Ensembling for Sequential Recommendation" =>
      "L. Collins, B. Kumar, C. M. Ju, T. Zhao, D. Loveland, L. Neves, N. Shah",
    "CoSearch: Joint Training of Reasoning and Document Ranking via Reinforcement Learning for Agentic Search" =>
      "H. Zeng, L. Collins, B. Kumar, N. Shah, H. Zamani",
    "Training-Free LLM-Based Recommendation with Post-LLM Item Refinement Using Collaborative Signals" =>
      "K. Kim, S. Kim, G. Lee, S. Kang, S. Kim, L. Collins, B. Kumar, D. Loveland, K. Shin",
    "LLM-Based Generative Retrieval for Snapchat Content Recommendation" =>
      "L. Collins, J. Ren, D. Loveland, B. Kumar, C. M. Ju, X. Guo, M. Li, A. Hou, Y. Cui, P. Yang, J. Wang, S. A. Shafi, N. Than, R. Lu, W. Zhuo, D. Li, L. Zhang, M. Zhang, J. Ye, V. Xue, C. Zhu, N. Shah"
  }.freeze

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

  def test_new_papers_use_abbreviated_author_names
    records_by_title = records.to_h { |record| [record["title"], record] }

    EXPECTED_NEW_PAPER_AUTHORS.each do |title, expected_authors|
      assert_equal expected_authors, records_by_title.fetch(title).fetch("authors")
    end
  end

  def test_readme_documents_the_publication_workflow
    readme = File.read(File.join(ROOT, "README.md"))
    assert_includes readme, "_data/publications.yml"
    assert_includes readme, "ruby test/publications_data_test.rb"
    assert_includes readme, "ruby test/repository_cleanup_test.rb"
    assert_includes readme, "bundle exec jekyll build"
  end
end
