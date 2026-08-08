# Publications Data and Repository Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the five missing papers, make publications editable from one YAML file, and remove verified Academic Pages demo content while preserving the current site design and URLs.

**Architecture:** `_data/publications.yml` becomes the publication source of truth. A single Liquid include renders the ordered `publications` and `preprints` lists on both the homepage and `/publications/`; Ruby/Minitest checks validate the data and generated pages. Cleanup removes only the exact demo files approved in the design spec.

**Tech Stack:** Jekyll 3.10.0, Liquid, YAML, Ruby 3.4.7, Minitest, Git/GitHub Pages.

## Global Constraints

- Work only in `/Users/bkumar4/work/professional/website/bhuvesh-publications-cleanup` on branch `codex/publications-cleanup`.
- Preserve the current visual design, navigation, homepage, `/cv/`, `/publications/`, `/sitemap/`, custom domain, and legitimate publication links.
- Keep accepted and published papers under `Publications`; keep unpublished or under-submission work under `Preprint(s)`.
- Omit links when no verified public URL exists; the Training-Free paper must not link to `https://arxiv.org/abs/2410.16458`.
- Preserve Bhuvesh-specific PDFs and images even when they are currently unlinked.
- Do not modify `/Users/bkumar4/work/professional/website/bhuvesh.github.io` or `/Users/bkumar4/work/professional/website/website`.
- Use the existing Homebrew Ruby without installing or changing environments: `env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin"`.
- Do not push `master`. Push only `codex/publications-cleanup` and open a PR targeting `master` after local review.
- Do not add a production `/testing` path. Use a local browser preview; a public preview host is a separate, optional follow-up.

---

### Task 1: Publication Data Contract and Content

**Files:**
- Create: `test/publications_data_test.rb`
- Create: `_data/publications.yml`

**Interfaces:**
- Consumes: the publication metadata and grouping in the approved design spec.
- Produces: `site.data.publications.publications` and `site.data.publications.preprints`, each an ordered array of records with `title`, `authors`, `venue`, optional `note`, optional `highlight`, and optional `links`.

- [ ] **Step 1: Write the failing data-contract test**

Create `test/publications_data_test.rb`:

```ruby
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
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
```

Expected: FAIL because `_data/publications.yml` does not exist and the required sections are absent.

- [ ] **Step 3: Create the publication YAML**

Create `_data/publications.yml` with this shape and content, using YAML block scalars for long author lists:

```yaml
publications:
  - title: "Semantic IDs for Recommender Systems at Snapchat: Use Cases, Technical Challenges, and Design Choices"
    authors: >-
      Clark Mingxuan Ju, Tong Zhao, Leonardo Neves, Liam Collins, Bhuvesh Kumar,
      Jiwen Ren, Lili Zhang, Wenfeng Zhuo, Vincent Zhang, Xiao Bai, Jinchao Li,
      Karthik Iyer, Zihao Fan, Yilun Xu, Yiwen Chen, Peicheng Yu, Manish Malik,
      Neil Shah
    venue: "SIGIR 2026 Industry Papers Track"
    links:
      - label: "paper"
        url: "https://dl.acm.org/doi/10.1145/3805712.3808405"
      - label: "arXiv"
        url: "https://arxiv.org/abs/2604.03949"

  - title: "Exploiting ID-Text Complementarity via Ensembling for Sequential Recommendation"
    authors: "Liam Collins, Bhuvesh Kumar, Clark Mingxuan Ju, Tong Zhao, Donald Loveland, Leonardo Neves, Neil Shah"
    venue: "RecSys 2026"
    note: "Accepted"
    links:
      - label: "arXiv"
        url: "https://arxiv.org/abs/2512.17820"

  - title: "CoSearch: Joint Training of Reasoning and Document Ranking via Reinforcement Learning for Agentic Search"
    authors: "Hansi Zeng, Liam Collins, Bhuvesh Kumar, Neil Shah, Hamed Zamani"
    venue: "COLM 2026"
    note: "Accepted"
    links:
      - label: "arXiv"
        url: "https://arxiv.org/abs/2604.17555"

  - title: "Training-Free LLM-Based Recommendation with Post-LLM Item Refinement Using Collaborative Signals"
    authors: "Kyungho Kim, Sunwoo Kim, Geon Lee, Shinhwan Kang, Sojeong Kim, Liam Collins, Bhuvesh Kumar, Donald Loveland, Kijung Shin"
    venue: "CIKM'26 Short Paper"

  - title: "Sequential Data Augmentation for Generative Recommendation"
    authors: "G. Lee, B. Kumar, C. M. Ju, T. Zhao, K. Shin, N. Shah, L. Collins"
    venue: "WSDM 2026"
    links:
      - label: "pdf"
        url: "https://arxiv.org/pdf/2509.13648"

  - title: "Learning Universal User Representations Leveraging Cross-Domain User Intent at Snapchat"
    authors: "C. M. Ju, L. Neves, B. Kumar, L. Collins, T. Zhao, Y. Qiu, Q. Dou, et al."
    venue: "SIGIR 2025"
    links:
      - label: "pdf"
        url: "https://arxiv.org/pdf/2504.21838"

  - title: "Generative Recommendation with Semantic IDs: A Practitioner's Handbook"
    authors: "C. M. Ju, L. Collins, L. Neves, B. Kumar, Y. Y. Wang, T. Zhao, N. Shah"
    venue: "CIKM 2025"
    note: "Best Paper Award in Resource Papers"
    highlight: true
    links:
      - label: "pdf"
        url: "https://arxiv.org/pdf/2507.22224"
      - label: "Library"
        url: "https://github.com/snap-research/GRID"

  - title: "Private Mechanism Design via Quantile Estimation"
    authors: "Y. Yang, T. Xiao, B. Kumar, J. Morgenstern"
    venue: "ICLR 2025"
    links:
      - label: "pdf"
        url: "https://openreview.net/pdf?id=JQQDePbfxh"
      - label: "poster"
        url: "https://iclr.cc/media/PosterPDFs/ICLR%202025/30113.png?t=1744877049.8500702"

  - title: "Revisiting self-attention for cross-domain sequential recommendation"
    authors: "C. M. Ju, L. Neves, B. Kumar, L. Collins, T. Zhao, Y. Qiu, Q. Dou, S. Nizam, S. Yang, N. Shah"
    venue: "KDD 2025"
    links:
      - label: "pdf"
        url: "https://arxiv.org/pdf/2505.21811"

  - title: "Accelerated Federated Optimization with Quantization"
    authors: "Y. Youn, B. Kumar, J. Abernethy"
    venue: "IEEE Data Engineering Bulletin 2023"
    links:
      - label: "pdf"
        url: "http://sites.computer.org/debull/A23mar/p79.pdf"

  - title: "ActiveHedge: Hedge meets Active Learning"
    authors: "B. Kumar, J. Abernethy, V. Saligrama"
    venue: "ICML 2022"
    note: "Spotlight"
    links:
      - label: "pdf"
        url: "https://proceedings.mlr.press/v162/kumar22a/kumar22a.pdf"
      - label: "poster"
        url: "/files/papers/activehedge/activehedge_poster.pdf"
      - label: "talk"
        url: "https://icml.cc/virtual/2022/spotlight/16966"

  - title: "Observation Free Attacks on Stochastic Bandits"
    authors: "Y. Xu, B. Kumar, J. Abernethy"
    venue: "NeurIPS 2021"
    links:
      - label: "pdf"
        url: "https://proceedings.neurips.cc/paper_files/paper/2021/file/be315e7f05e9f13629031915fe87ad44-Paper.pdf"

  - title: "Bridging Truthfulness and Corruption-robustness in Multi-Armed Bandit Mechanisms"
    authors: "Y. Xu, B. Kumar, J. Abernethy, T. Lykouris"
    venue: "Incentives in ML Workshop at ICML 2020"
    links:
      - label: "pdf"
        url: "/files/papers/bridging_truthful/bridging_truthful.pdf"
      - label: "talk"
        url: "https://youtu.be/-ynxeiOuqoE"

  - title: "Learning Auctions with Robust Incentive Guarantees"
    authors: "B. Kumar, J. Abernethy, R. Cummings, J. Morgenstern, S. Taggart"
    venue: "NeurIPS 2019"
    links:
      - label: "pdf"
        url: "https://proceedings.neurips.cc/paper/2019/file/c14a2a57ead18f3532a5a8949382c536-Paper.pdf"
      - label: "poster"
        url: "/files/papers/learning_auctions/learning_auctions_poster.pdf"

preprints:
  - title: "LLM-Based Generative Retrieval for Snapchat Content Recommendation"
    authors: >-
      Liam Collins, Jiwen Ren, Donald Loveland, Bhuvesh Kumar, Clark Mingxuan Ju,
      Xuan Guo, Mo Li, Alvin Hou, Yi Cui, Peng Yang, Jian Wang, Saud Afzal Shafi,
      Nga Than, Ruiming Lu, Wenfeng Zhuo, Dongheng Li, Lili Zhang, Mingtao Zhang,
      Jinchao Ye, Vincent Xue, Chunhui Zhu, Neil Shah
    venue: "KDD submission"
    note: "Preprint posted July 30, 2026"
    links:
      - label: "arXiv"
        url: "https://arxiv.org/abs/2607.28895"

  - title: "Optimal spend rate estimation and pacing for ad campaigns with budgets"
    authors: "B. Kumar, J. Morgenstern, O. Schrijvers"
    venue: "arXiv (2022)"
    links:
      - label: "pdf"
        url: "https://arxiv.org/pdf/2202.05881"
      - label: "talk"
        url: "https://youtu.be/xcPPtnLxDCs"
```

- [ ] **Step 4: Run the contract test and verify it passes**

Run the Step 2 command.

Expected: 6 runs, 0 failures, 0 errors.

- [ ] **Step 5: Commit the data contract and content**

```bash
git add test/publications_data_test.rb _data/publications.yml
git commit -m "feat: add structured publication data"
```

### Task 2: Shared Publication Renderer

**Files:**
- Create: `_includes/publications-list.html`
- Delete: `_includes/publications-list.md`
- Modify: `_pages/about.md`
- Modify: `_pages/publications.html`
- Create: `test/rendered_site_test.rb`

**Interfaces:**
- Consumes: `site.data.publications.publications` and `site.data.publications.preprints` from Task 1.
- Produces: identical publication-list HTML on `/index.html` and `/publications/index.html`, with no anchor for records whose `links` field is absent.

- [ ] **Step 1: Write the failing rendered-site test**

Create `test/rendered_site_test.rb`:

```ruby
require "cgi"
require "minitest/autorun"
require "yaml"

class RenderedSiteTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SITE_DIR = ENV.fetch("SITE_DIR", File.join(ROOT, "_site"))
  DATA = YAML.safe_load_file(File.join(ROOT, "_data", "publications.yml"))
  PAGES = %w[index.html publications/index.html].freeze
  REQUIRED_ROUTES = %w[index.html cv/index.html publications/index.html sitemap/index.html].freeze
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
    assert_match(/<li>.*?#{Regexp.escape(escaped_title)}.*?<\/li>/m, html)
    item = html.match(/<li>.*?#{Regexp.escape(escaped_title)}.*?<\/li>/m).to_s
    refute_match(/<a\b/, item)
  end
end
```

- [ ] **Step 2: Build the current templates and verify the rendered-site test fails**

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" JEKYLL_ENV=production bundle exec jekyll build
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" SITE_DIR="_site" ruby test/rendered_site_test.rb
```

Expected: FAIL because the five new titles are not rendered from YAML.

- [ ] **Step 3: Implement the Liquid renderer**

Create `_includes/publications-list.html`:

```liquid
<h2>Publications</h2>

<ul>
{% for publication in site.data.publications.publications %}
  <li>
    <p>
      {{ publication.title }}<br>
      {{ publication.authors }}<br>
      <strong>{{ publication.venue }}</strong>
      {% if publication.note %}
        {% if publication.highlight %}
          <span style="color: red"><strong>[{{ publication.note }}]</strong></span>
        {% else %}
          ({{ publication.note }})
        {% endif %}
      {% endif %}
      {% if publication.links and publication.links.size > 0 %}
        <br>
        {% for link in publication.links %}<a href="{{ link.url }}">[{{ link.label }}]</a>{% unless forloop.last %}, {% endunless %}{% endfor %}
      {% endif %}
    </p>
  </li>
{% endfor %}
</ul>

{% if site.data.publications.preprints and site.data.publications.preprints.size > 0 %}
<h2>Preprint(s)</h2>

<ul>
{% for publication in site.data.publications.preprints %}
  <li>
    <p>
      {{ publication.title }}<br>
      {{ publication.authors }}<br>
      <strong>{{ publication.venue }}</strong>{% if publication.note %} ({{ publication.note }}){% endif %}
      {% if publication.links and publication.links.size > 0 %}
        <br>
        {% for link in publication.links %}<a href="{{ link.url }}">[{{ link.label }}]</a>{% unless forloop.last %}, {% endunless %}{% endfor %}
      {% endif %}
    </p>
  </li>
{% endfor %}
</ul>
{% endif %}
```

Change both `_pages/about.md` and `_pages/publications.html` from the capture/`markdownify` sequence to:

```liquid
{% include publications-list.html %}
```

Delete `_includes/publications-list.md`.

- [ ] **Step 4: Rebuild and run both test files**

Run the Step 2 commands, followed by:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
```

Expected: all tests pass.

- [ ] **Step 5: Commit the renderer**

```bash
git add _includes/publications-list.html _includes/publications-list.md _pages/about.md _pages/publications.html test/rendered_site_test.rb
git commit -m "feat: render publications from YAML"
```

### Task 3: Remove Verified Demo Content

**Files:**
- Delete: exact files and directories listed in the approved design's `Conservative Cleanup` section.
- Modify: `_config.yml`
- Modify: `_data/navigation.yml`
- Create: `test/repository_cleanup_test.rb`

**Interfaces:**
- Consumes: the five-page public surface (`404`, homepage, CV, Publications, sitemap) and theme dependencies.
- Produces: the same required routes without demo collections, demo pages, sample content, JSON-CV code, generators, comments, or sample assets.

- [ ] **Step 1: Write and run the failing cleanup test**

Create `test/repository_cleanup_test.rb`:

```ruby
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
```

Run the existing Task 2 tests first to capture the passing pre-cleanup baseline. Then run:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/repository_cleanup_test.rb
```

Expected: FAIL because the exact demo paths and unused configuration still exist.

- [ ] **Step 2: Remove exact tracked demo targets**

Run these exact commands:

```bash
git rm -r _publications _posts _talks _teaching _portfolio _drafts _data/comments
git rm -r markdown_generator talkmap images/themes
git rm talkmap.ipynb talkmap_out.ipynb talkmap.py
git rm _pages/archive-layout-with-content.md _pages/category-archive.html _pages/collection-archive.html _pages/cv-json.md _pages/markdown.md _pages/non-menu-page.md _pages/page-archive.html _pages/portfolio.html _pages/tag-archive.html _pages/talkmap.html _pages/talks.html _pages/teaching.html _pages/terms.md _pages/year-archive.html
git rm _data/cv.json _includes/cv-template.html _layouts/cv-layout.html scripts/cv_markdown_to_json.py scripts/update_cv_json.sh
git rm .github/workflows/scrape_talks.yml
git rm files/paper1.pdf files/paper2.pdf files/paper3.pdf files/slides1.pdf files/slides2.pdf files/slides3.pdf files/bibtex1.bib
git rm images/500x300.png images/bio-photo-2.jpg images/bio-photo.jpg images/editing-talk.png images/profile.png
git rm .DS_Store files/.DS_Store files/papers/.DS_Store pdf/.DS_Store
```

Do not delete `files/papers`, `files/resume`, `pdf` contents other than the explicitly listed tracked `.DS_Store` files, `images/portrait.jpg`, or any favicon/manifest files.

- [ ] **Step 3: Simplify configuration and navigation**

In `_config.yml`:

- Remove `publication_category`, `talkmap_link`, `comments`, and `staticman` configuration.
- Remove the entire `collections` mapping.
- Keep only the `pages` entry in `defaults`.
- Remove category/tag archive configuration.
- Keep `jekyll-feed`, `jekyll-sitemap`, `jekyll-redirect-from`, and `jemoji` plugins and whitelist entries.
- Remove `jekyll-gist` and `jekyll-paginate` from plugins and whitelist because no posts, gists, or pagination remain.

The resulting defaults and plugin blocks must be:

```yaml
defaults:
  - scope:
      path: ""
      type: pages
    values:
      layout: single
      author_profile: true

plugins:
  - jekyll-feed
  - jekyll-sitemap
  - jekyll-redirect-from
  - jemoji

whitelist:
  - jekyll-feed
  - jekyll-sitemap
  - jekyll-redirect-from
  - jemoji
```

In `_data/navigation.yml`, retain only:

```yaml
main:
  - title: "CV"
    url: /cv/

  - title: "Publications"
    url: /publications/
```

- [ ] **Step 4: Rebuild and verify cleanup behavior**

Run both Task 2 test files and `test/repository_cleanup_test.rb` again.

Also run:

```bash
git grep -n -E "Paper Title Number|Talk 1 on Relevant Topic|Short description of portfolio item|This is a description of a teaching experience"
```

Expected: both test files pass; `git grep` returns no matches.

- [ ] **Step 5: Commit cleanup**

```bash
git add -A
git commit -m "chore: remove academic pages demo content"
```

### Task 4: Maintenance Documentation and Ignore Rules

**Files:**
- Modify: `.gitignore`
- Replace: `README.md`

**Interfaces:**
- Consumes: the YAML schema and exact test/build commands from Tasks 1-3.
- Produces: one concise maintenance guide and ignore rules that prevent generated/OS files from returning.

- [ ] **Step 1: Write a failing documentation check**

Add this test to `test/publications_data_test.rb`:

```ruby
def test_readme_documents_the_publication_workflow
  readme = File.read(File.join(ROOT, "README.md"))
  assert_includes readme, "_data/publications.yml"
  assert_includes readme, "ruby test/publications_data_test.rb"
  assert_includes readme, "bundle exec jekyll build"
end
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run the Task 1 test command.

Expected: FAIL because the generic template README does not document `_data/publications.yml`.

- [ ] **Step 3: Replace README and update ignores**

Replace `README.md` with:

````markdown
# bhuveshkumar.com

Source for [bhuveshkumar.com](https://bhuveshkumar.com), built with Jekyll and published by GitHub Pages.

## Add or update a publication

Edit `_data/publications.yml`. Items under `publications` appear under **Publications**; items under `preprints` appear under **Preprint(s)**. Their order in the YAML file is their order on the website.

Linked example:

```yaml
- title: "Paper title"
  authors: "First Author, Bhuvesh Kumar"
  venue: "Conference 2026"
  note: "Accepted"
  links:
    - label: "paper"
      url: "https://example.com/paper"
```

Unlinked example:

```yaml
- title: "Paper awaiting a public URL"
  authors: "First Author, Bhuvesh Kumar"
  venue: "Conference 2026 Short Paper"
```

Omit `links` until a URL has been verified. Use `highlight: true` only for an award note that should retain the red emphasis used on the current site.

## Test and build

This Mac has the required Ruby and Bundler under Homebrew. Prefix commands so they do not use the older system Ruby:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" JEKYLL_ENV=production bundle exec jekyll build
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" SITE_DIR="_site" ruby test/rendered_site_test.rb
```

## Preview locally

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" bundle exec jekyll serve --host 127.0.0.1 --port 4000
```

Open [http://127.0.0.1:4000](http://127.0.0.1:4000). GitHub pull requests do not automatically receive a rendered GitHub Pages preview URL; use the local preview before merging.

## Publish through a pull request

1. Create a feature branch from `master`.
2. Make the change and run all three verification commands.
3. Push the feature branch, not `master`.
4. Open a pull request targeting `master`.
5. Merge only after reviewing the local preview and PR diff.

Merging to `master` triggers the existing GitHub Pages publication flow for [bhuveshkumar.com](https://bhuveshkumar.com).
````

Replace `.gitignore` with:

```gitignore
.DS_Store
_site/
.jekyll-cache/
.jekyll-metadata
.sass-cache/
local/
node_modules/
package-lock.json
/vendor/
.bundle/
.vscode/
```

- [ ] **Step 4: Run the documentation/data test and build tests**

Expected: all tests pass and the site builds.

- [ ] **Step 5: Commit maintenance documentation**

```bash
git add .gitignore README.md test/publications_data_test.rb
git commit -m "docs: explain website maintenance workflow"
```

### Task 5: Full Verification, Local Preview, and PR Handoff

**Files:**
- Modify only if verification exposes a defect in files already changed by Tasks 1-4.

**Interfaces:**
- Consumes: completed site, test suite, and feature branch.
- Produces: verified local pages, a pushed feature branch, and a PR into `master`; production remains unchanged until PR merge.

- [ ] **Step 1: Run clean automated verification**

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" JEKYLL_ENV=production bundle exec jekyll build
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" SITE_DIR="_site" ruby test/rendered_site_test.rb
git diff --check origin/master...HEAD
git status --short --branch
```

Expected: tests and build pass, diff check is clean, and the worktree has no uncommitted files.

- [ ] **Step 2: Review the branch diff and deletion scope**

```bash
git diff --stat origin/master...HEAD
git diff --name-status origin/master...HEAD
```

Confirm the diff does not delete Bhuvesh-specific files under `files/papers`, `files/resume`, or `pdf`, except the explicitly approved tracked `.DS_Store` files.

- [ ] **Step 3: Start a local preview**

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" bundle exec jekyll serve --host 127.0.0.1 --port 4000
```

Open `http://127.0.0.1:4000/` and `http://127.0.0.1:4000/publications/` in the Codex browser. Compare with the current live pages and verify the Training-Free paper has no link.

- [ ] **Step 4: Ask for visual approval**

Show the local preview to the user. Do not push until the user approves the rendered branch.

- [ ] **Step 5: Push the feature branch and open a PR**

After approval:

```bash
git push -u origin codex/publications-cleanup
```

Open a PR from `codex/publications-cleanup` into `master`. Do not merge it automatically. If GitHub.com CLI authentication remains unavailable, provide the GitHub compare URL after the branch push so the user can create the PR in their signed-in browser.
