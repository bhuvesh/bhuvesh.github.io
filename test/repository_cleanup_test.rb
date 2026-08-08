require "minitest/autorun"
require "yaml"

class RepositoryCleanupTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REMOVED_PATHS = %w[
    _publications _posts _talks _teaching _portfolio _drafts _data/comments
    markdown_generator talkmap talkmap.ipynb talkmap_out.ipynb talkmap.py
    _pages/archive-layout-with-content.md _pages/category-archive.html
    _pages/collection-archive.html _pages/cv-json.md _pages/markdown.md
    _pages/non-menu-page.md _pages/page-archive.html _pages/portfolio.html
    _pages/tag-archive.html _pages/talkmap.html _pages/talks.html
    _pages/teaching.html _pages/terms.md _pages/year-archive.html
    _data/cv.json _includes/cv-template.html _layouts/cv-layout.html
    scripts/cv_markdown_to_json.py scripts/update_cv_json.sh
    .github/workflows/scrape_talks.yml
    files/paper1.pdf files/paper2.pdf files/paper3.pdf
    files/slides1.pdf files/slides2.pdf files/slides3.pdf files/bibtex1.bib
    images/500x300.png images/bio-photo-2.jpg images/bio-photo.jpg
    images/editing-talk.png images/profile.png images/themes
    .DS_Store files/.DS_Store files/papers/.DS_Store pdf/.DS_Store
  ].freeze

  def test_demo_paths_are_removed
    remaining = REMOVED_PATHS.select { |path| File.exist?(File.join(ROOT, path)) }
    assert_empty remaining, "demo paths remain: #{remaining.join(', ')}"
  end

  def test_only_page_defaults_remain
    config = YAML.safe_load_file(File.join(ROOT, "_config.yml"), aliases: true)
    assert_nil config["collections"]
    assert_nil config["comments"]
    assert_nil config["staticman"]
    assert_nil config["category_archive"]
    assert_nil config["tag_archive"]
    assert_equal ["pages"], config.fetch("defaults").map { |entry| entry.dig("scope", "type") }
    assert_equal %w[jekyll-feed jekyll-sitemap jekyll-redirect-from jemoji], config.fetch("plugins")
  end

  def test_navigation_contains_only_cv_and_publications
    navigation = YAML.safe_load_file(File.join(ROOT, "_data", "navigation.yml"))
    assert_equal [
      {"title" => "CV", "url" => "/cv/"},
      {"title" => "Publications", "url" => "/publications/"}
    ], navigation.fetch("main")
  end
end
