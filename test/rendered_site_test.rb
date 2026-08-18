require "cgi"
require "minitest/autorun"
require "yaml"

class RenderedSiteTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SITE_DIR = ENV.fetch("SITE_DIR", File.join(ROOT, "_site"))
  DATA = YAML.safe_load_file(File.join(ROOT, "_data", "publications.yml"))
  PAGES = %w[index.html publications/index.html].freeze
  REQUIRED_ROUTES = %w[index.html cv/index.html publications/index.html sitemap/index.html].freeze
  UNLINKED_RESUME_PDFS = %w[
    files/resume/2026-08/Bhuvesh_Kumar_Resume.pdf
    files/resume/2026-08/Bhuvesh_Kumar_CV.pdf
  ].freeze
  DEMO_TITLES = ["Paper Title Number 1", "Paper Title Number 2", "Paper Title Number 3"].freeze

  def normalize(text)
    CGI.unescapeHTML(text)
       .gsub(/<[^>]+>/, " ")
       .tr("’‘", "''")
       .gsub(/\s+/, " ")
       .strip
  end

  def page(relative_path)
    File.read(File.join(SITE_DIR, relative_path))
  end

  def records
    %w[publications preprints].flat_map { |section| DATA.fetch(section) }
  end

  def test_required_routes_are_generated
    REQUIRED_ROUTES.each do |route|
      assert File.file?(File.join(SITE_DIR, route)), "missing #{route}"
    end
  end

  def test_dated_resume_pdfs_are_published_without_site_links
    UNLINKED_RESUME_PDFS.each do |relative_path|
      published_path = File.join(SITE_DIR, relative_path)
      assert File.file?(published_path), "missing #{relative_path}"
      assert_operator File.size(published_path), :>, 10_000, relative_path
      assert_equal "%PDF-", File.binread(published_path, 5), relative_path
    end

    rendered_html = Dir.glob(File.join(SITE_DIR, "**", "*.html")).map do |path|
      File.read(path)
    end.join("\n")
    UNLINKED_RESUME_PDFS.each do |relative_path|
      refute_includes rendered_html, "/#{relative_path}"
    end
  end

  def test_every_publication_is_on_home_and_publications_pages
    PAGES.each do |relative_path|
      rendered = normalize(page(relative_path))
      records.each { |record| assert_includes rendered, normalize(record.fetch("title")) }
    end
  end

  def test_demo_publications_are_absent
    PAGES.each do |relative_path|
      rendered = normalize(page(relative_path))
      DEMO_TITLES.each { |title| refute_includes rendered, title }
    end
  end

  def test_training_free_paper_has_no_link
    html = page("publications/index.html")
    title = "Training-Free LLM-Based Recommendation with Post-LLM Item Refinement Using Collaborative Signals"
    escaped_title = CGI.escapeHTML(title)
    items = html.scan(/<li>.*?<\/li>/m).select { |item| item.include?(escaped_title) }
    assert_equal 1, items.length
    item = items.fetch(0)
    refute_match(/<a\b/, item)
  end

  def test_authors_have_dedicated_typography_hook
    expected_count = records.length

    PAGES.each do |relative_path|
      html = page(relative_path)
      assert_equal expected_count, html.scan(/class="publication-authors"/).length, relative_path
    end
  end

  def test_venue_less_preprints_do_not_render_empty_venue_markup
    venue_less_titles = records.select { |record| record["venue"].nil? }
                                .map { |record| record["title"] }

    PAGES.each do |relative_path|
      html = page(relative_path)
      list_items = html.scan(/<li>.*?<\/li>/m)

      venue_less_titles.each do |title|
        item = list_items.find { |candidate| candidate.include?(title) }
        refute_nil item, title
        refute_includes item, "publication-venue", title
        refute_match(/<strong(?:\s+[^>]*)?>\s*<\/strong>/m, item, title)
      end
    end
  end

  def test_stylesheets_use_site_relative_urls
    PAGES.each do |relative_path|
      html = page(relative_path)
      assert_includes html, 'href="/assets/css/main.css"', relative_path
      assert_includes html, 'href="/assets/css/academicons.css"', relative_path
      refute_match(%r{href="https://bhuveshkumar\.com/+assets/css/}, html, relative_path)
    end
  end
end
