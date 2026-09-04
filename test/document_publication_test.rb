require "minitest/autorun"
require "yaml"

class DocumentPublicationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PROFESSIONAL_CV = "files/resume/Bhuvesh_Resume_CV.pdf"
  CONCISE_RESUME = "files/resume/Bhuvesh_Kumar_Resume.pdf"
  IMMIGRATION_CV = "files/resume/Bhuvesh_Kumar_Immigration_CV.pdf"

  def source(relative_path)
    File.read(File.join(ROOT, relative_path))
  end

  def test_public_title_reflects_the_promotion
    config = YAML.safe_load(source("_config.yml"), aliases: true)
    assert_equal "Senior Research Scientist at Snap Inc", config.dig("author", "bio")
    assert_includes source("_pages/about.md"), "I am a Senior Research Scientist"
  end

  def test_cv_page_uses_the_approved_document_hierarchy
    cv_page = source("_pages/cv.md")
    assert_includes cv_page, 'title: "CV & Resume"'
    assert_includes cv_page, "/#{PROFESSIONAL_CV}"
    assert_includes cv_page, "/#{CONCISE_RESUME}"
    refute_includes cv_page, "/#{IMMIGRATION_CV}"
  end

  def test_all_current_documents_are_publishable_pdfs
    [PROFESSIONAL_CV, CONCISE_RESUME, IMMIGRATION_CV].each do |relative_path|
      path = File.join(ROOT, relative_path)
      assert File.file?(path), "missing #{relative_path}"
      assert_operator File.size(path), :>, 10_000, relative_path
      assert_equal "%PDF-", File.binread(path, 5), relative_path
    end
  end
end
