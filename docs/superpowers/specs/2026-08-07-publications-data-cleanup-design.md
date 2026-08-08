# Publications Data and Repository Cleanup Design

## Goal

Make `bhuveshkumar.com` easy to update by placing publication metadata in one structured file, adding the five papers currently missing from the website, and removing clear Academic Pages demo content without changing the site's appearance, public URLs, or deployment model.

## Scope

The work applies only to `/Users/bkumar4/work/professional/website/bhuvesh.github.io`, whose `origin` is `bhuvesh/bhuvesh.github.io` and whose `CNAME` serves `bhuveshkumar.com`.

The older Hugo repository at `/Users/bkumar4/work/professional/website/website` is out of scope and will remain untouched.

## User-Visible Behavior

- Preserve the current visual design and navigation.
- Preserve the homepage, `/cv/`, `/publications/`, `bhuveshkumar.com`, and existing legitimate publication links.
- Continue showing the same publication list on both the homepage and `/publications/`.
- Keep accepted and published papers under `Publications`.
- Keep unpublished or under-submission work under `Preprint(s)`.
- Display publications in the explicit order in the data file, with newer work first.
- Omit a link entirely when no verified public URL exists.

## Publication Data Model

Create `_data/publications.yml` as the only file that normally needs editing when adding a paper. The top level will contain ordered `publications` and `preprints` lists.

Each record will support:

- `title`: required full paper title.
- `authors`: required display-ready author string.
- `venue`: required venue and year or current status.
- `note`: optional award, spotlight, or acceptance note.
- `links`: optional ordered list of `{ label, url }` objects.

The data deliberately stores a display-ready author string rather than splitting authors into objects. This matches the current site, keeps updates simple, and avoids adding unused author-profile functionality.

## Rendering

Replace `_includes/publications-list.md` with a small Liquid include that:

1. Iterates over `site.data.publications.publications`.
2. Renders title, authors, venue, optional note, and optional links in the current visual format.
3. Renders the `Preprint(s)` heading only when the preprint list is non-empty.
4. Iterates over `site.data.publications.preprints` using the same record format.

Both `_pages/about.md` and `_pages/publications.html` will call this include directly. No individual publication pages will be generated.

## Publication Content Changes

Retain all legitimate publications and preprints currently displayed on the live site, including their existing author strings, venues, notes, and links.

Add these accepted or published papers:

1. **Semantic IDs for Recommender Systems at Snapchat: Use Cases, Technical Challenges, and Design Choices**
   - Authors: Clark Mingxuan Ju, Tong Zhao, Leonardo Neves, Liam Collins, Bhuvesh Kumar, Jiwen Ren, Lili Zhang, Wenfeng Zhuo, Vincent Zhang, Xiao Bai, Jinchao Li, Karthik Iyer, Zihao Fan, Yilun Xu, Yiwen Chen, Peicheng Yu, Manish Malik, Neil Shah
   - Venue: SIGIR 2026 Industry Papers Track
   - Links: ACM DOI `https://dl.acm.org/doi/10.1145/3805712.3808405` and arXiv `https://arxiv.org/abs/2604.03949`

2. **Exploiting ID-Text Complementarity via Ensembling for Sequential Recommendation**
   - Authors: Liam Collins, Bhuvesh Kumar, Clark Mingxuan Ju, Tong Zhao, Donald Loveland, Leonardo Neves, Neil Shah
   - Venue: RecSys 2026
   - Note: Accepted
   - Link: arXiv `https://arxiv.org/abs/2512.17820`

3. **CoSearch: Joint Training of Reasoning and Document Ranking via Reinforcement Learning for Agentic Search**
   - Authors: Hansi Zeng, Liam Collins, Bhuvesh Kumar, Neil Shah, Hamed Zamani
   - Venue: COLM 2026
   - Note: Accepted
   - Link: arXiv `https://arxiv.org/abs/2604.17555`

4. **Training-Free LLM-Based Recommendation with Post-LLM Item Refinement Using Collaborative Signals**
   - Authors: Kyungho Kim, Sunwoo Kim, Geon Lee, Shinhwan Kang, Sojeong Kim, Liam Collins, Bhuvesh Kumar, Donald Loveland, Kijung Shin
   - Venue: CIKM'26 Short Paper
   - Links: none until a verified public page is available

Add this submission to `Preprint(s)`:

1. **LLM-Based Generative Retrieval for Snapchat Content Recommendation**
   - Authors: Liam Collins, Jiwen Ren, Donald Loveland, Bhuvesh Kumar, Clark Mingxuan Ju, Xuan Guo, Mo Li, Alvin Hou, Yi Cui, Peng Yang, Jian Wang, Saud Afzal Shafi, Nga Than, Ruiming Lu, Wenfeng Zhuo, Dongheng Li, Lili Zhang, Mingtao Zhang, Jinchao Ye, Vincent Xue, Chunhui Zhu, Neil Shah
   - Venue: KDD submission
   - Note: Preprint posted July 30, 2026
   - Link: arXiv `https://arxiv.org/abs/2607.28895`

Do not use the Google Doc URL currently associated with the Training-Free paper. It resolves to the unrelated paper `STAR: A Simple Training-free Approach for Recommendations using Large Language Models`, whose listed authors do not include Bhuvesh Kumar.

## Conservative Cleanup

Remove content that is clearly inherited demo material and is not used by the current homepage, CV, Publications page, navigation, or required theme rendering:

- Entire demo content directories: `_publications`, `_posts`, `_talks`, `_teaching`, `_portfolio`, `_drafts`, and `_data/comments`.
- Unused pages: `_pages/archive-layout-with-content.md`, `_pages/category-archive.html`, `_pages/collection-archive.html`, `_pages/cv-json.md`, `_pages/markdown.md`, `_pages/non-menu-page.md`, `_pages/page-archive.html`, `_pages/portfolio.html`, `_pages/tag-archive.html`, `_pages/talkmap.html`, `_pages/talks.html`, `_pages/teaching.html`, `_pages/terms.md`, and `_pages/year-archive.html`.
- Unused JSON-CV implementation: `_data/cv.json`, `_includes/cv-template.html`, `_layouts/cv-layout.html`, `scripts/cv_markdown_to_json.py`, and `scripts/update_cv_json.sh`.
- Entire demo generator directories/files: `markdown_generator`, `talkmap`, `talkmap.ipynb`, `talkmap_out.ipynb`, and `talkmap.py`.
- Sample workflow: `.github/workflows/scrape_talks.yml`.
- Sample publication assets: `files/paper1.pdf`, `files/paper2.pdf`, `files/paper3.pdf`, `files/slides1.pdf`, `files/slides2.pdf`, `files/slides3.pdf`, and `files/bibtex1.bib`.
- Unused template images: `images/500x300.png`, `images/bio-photo-2.jpg`, `images/bio-photo.jpg`, `images/editing-talk.png`, `images/profile.png`, and the `images/themes` directory.
- Tracked OS metadata: `.DS_Store`, `files/.DS_Store`, `files/papers/.DS_Store`, and `pdf/.DS_Store`. The untracked `files/resume/.DS_Store` will also be removed.
- Unused collection/default/archive configuration in `_config.yml` for posts, publications, teaching, portfolio, talks, categories, and tags. Keep the pages default, Sass settings, GitHub Pages plugins, redirects, and sitemap configuration.
- Commented-out Talks, Teaching, Portfolio, Blog Posts, JSON CV, and Guide entries in `_data/navigation.yml`.

Keep:

- Theme layouts, includes, Sass, JavaScript, fonts, and icons required to preserve the current appearance.
- `CNAME`, favicon assets, portrait images used by the site, the current CV, and publication-specific Bhuvesh assets.
- Bhuvesh-specific PDFs and images even when they are not currently linked, unless a later review explicitly approves their removal.
- The sitemap page and plugin because the live footer links to `/sitemap/`.
- `_pages/404.md`, `_pages/about.md`, `_pages/cv.md`, `_pages/publications.html`, and `_pages/sitemap.md` as the complete public page set.
- GitHub Pages-compatible build dependencies.

Add ignore rules for `.DS_Store`, `_site`, `.sass-cache`, `.jekyll-cache`, and other local build artifacts so they do not return.

## Documentation

Replace the generic Academic Pages README with site-specific maintenance instructions:

1. Edit `_data/publications.yml` to add or update a paper.
2. Leave `links` empty or omit it when no verified URL exists.
3. Run the publication validation test.
4. Run a production Jekyll build.
5. Preview locally when layout changes are involved.
6. Commit and push to the publishing branch after review.

The README will also document the record schema with one linked and one unlinked example.

## Validation and Testing

Add an automated content test that fails when:

- `_data/publications.yml` cannot be parsed.
- A record lacks `title`, `authors`, or `venue`.
- Publication titles are duplicated across either section.
- A link lacks a label or uses a non-HTTP(S), non-root-relative URL.
- The Training-Free paper accidentally receives the known incorrect arXiv URL `https://arxiv.org/abs/2410.16458`.

Verification will also:

- Run the content test before implementation to demonstrate the missing data behavior, then run it after implementation.
- Run `bundle exec jekyll build` from a clean generated-output directory.
- Confirm generated `/index.html` and `/publications/index.html` contain every YAML title and do not contain fake template publication titles.
- Confirm `/`, `/cv/`, `/publications/`, and `/sitemap/` are generated.
- Inspect the local homepage and Publications page in a browser to verify the current layout is preserved and the unlinked Training-Free paper renders without an empty link.
- Review the final Git diff to ensure only the active Jekyll repository changed and no Bhuvesh-specific assets were accidentally removed.

## Deployment Boundary

Implementation and verification will happen locally first. Publishing requires a separate reviewed commit and push to `origin/master`, which triggers the existing GitHub Pages deployment. The live site will be checked only after that push is approved and completes.
