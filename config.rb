###
# Page options, layouts, aliases and proxies
###


###
# Markdown
###

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

###
# Code highlighting
###

activate :syntax

# set site URL
set :site_url, 'http://garciajames.com'
# set site title
set :site_title, 'James Garcia'
# set site description (only used for meta description for the moment)
set :site_description, 'My Portfolio'
# set site author name
set :site_author, 'James Garcia'
# set site author profile information
# set :site_author_profile, 'Lorem ipsum dolor sit amet, cu facilis indoctum interpretaris has. Ius ea quod euismod fierent, per in legere gubergren accommodare, ut labitur partiendo urbanitas duo. Tamquam inciderint at sed. Per at nibh graecis intellegebat. Probo brute ancillae sit ex, tota recusabo disputando usu et.'
# set site author profile image (should be in images_dir)
set :site_author_image, 'profile_pic.jpg'
# when true, the page and site titles will be reversed (page title | site title)
set :reverse_title, true
# twitter/facebook/github/linkedin links in author page (otherwise set nil)
set :social_links,
    twitter: 'https://twitter.com',
    facebook: 'https://facebook.com',
    github: 'https://github.com/jamgar',
    linkedin: 'https://linkedin.com'
# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }
data.projects.each do |p|
  proxy p.path + ".html", "project/template.html", :locals => { :project => p }, :ignore => true
end

###
# Helpers
###

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "article_layout"
  blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = "md"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end

# pretty urls
activate :directory_indexes

page "/feed.xml", layout: false
# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def nav_active(path)
#     current_page.path == path ? { :class => "active" } : {}
#   end
# end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end
