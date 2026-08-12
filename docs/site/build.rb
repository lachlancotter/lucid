# frozen_string_literal: true

require "cgi"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
SITE_ROOT = __dir__

PAGES = [
  { title: "Overview", label: "Overview", source: "index.md", output: "index.html", section: "Start Here" },
  { title: "Why Lucid?", label: "Why Lucid?", source: "why.md", output: "why.html", section: "Start Here" },
  { title: "Hello World", label: "Hello World", source: "hello.md", output: "hello.html", section: "Start Here" },
  { title: "Architecture", label: "Architecture", source: "architecture.md", output: "architecture.html", section: "Start Here" },
  { title: "Messages", label: "Messages", source: "messages.md", output: "messages.html", section: "Start Here" },
  { title: "Components", label: "Components", source: "components.md", output: "components.html", section: "Start Here" },
  { title: "Handlers", label: "Handlers", source: "handlers.md", output: "handlers.html", section: "Start Here" },
  { title: "State", label: "State", source: "reference/state.md", output: "reference/state.html", section: "Reference" },
  { title: "Templates", label: "Templates", source: "reference/templates.md", output: "reference/templates.html", section: "Reference" },
  { title: "Configuration", label: "Configuration", source: "reference/configuration.md", output: "reference/configuration.html", section: "Reference" },
  { title: "Project Structure", label: "Project Structure", source: "reference/project_structure.md", output: "reference/project_structure.html", section: "Reference" }
].freeze

PAGE_BY_SOURCE = PAGES.to_h { |page| [page[:source], page] }

def escape_html(value)
  CGI.escapeHTML(value)
end

def page_depth(page)
  page[:output].count("/")
end

def relative_href(from_page, to_page)
  prefix = "../" * page_depth(from_page)
  "#{prefix}#{to_page[:output]}"
end

def stylesheet_href(page)
  "#{"../" * page_depth(page)}styles.css"
end

def convert_doc_link(from_page, href)
  return href unless href.end_with?(".md")

  source_dir = File.join(ROOT, File.dirname(from_page[:source]))
  normalized = File.expand_path(href, source_dir)
  relative = normalized.delete_prefix("#{ROOT}/")
  target = PAGE_BY_SOURCE[relative]

  target ? relative_href(from_page, target) : href
end

def inline_markdown(text, from_page)
  html = escape_html(text)
  html = html.gsub(/`([^`]+)`/) { "<code>#{Regexp.last_match(1)}</code>" }
  html.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do
    label = Regexp.last_match(1)
    href = convert_doc_link(from_page, Regexp.last_match(2))
    %(<a href="#{escape_html(href)}">#{label}</a>)
  end
end

def slug(text)
  text.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
end

def render_markdown(markdown, from_page)
  lines = markdown.lines.map(&:chomp)
  title = lines.first&.start_with?("# ") ? lines.shift.delete_prefix("# ").strip : from_page[:title]
  html = +""
  paragraph = []
  list_type = nil
  list_items = []
  in_code = false
  code_lines = []

  flush_paragraph = lambda do
    next if paragraph.empty?

    html << "<p>#{inline_markdown(paragraph.join(" "), from_page)}</p>\n"
    paragraph.clear
  end

  flush_list = lambda do
    next unless list_type

    list_items.each do |item|
      html << "<li>#{inline_markdown(item, from_page)}</li>\n"
    end
    html << "</#{list_type}>\n"
    list_type = nil
    list_items.clear
  end

  lines.each do |line|
    if in_code
      if line.start_with?("```")
        html << "<pre><code>#{escape_html(code_lines.join("\n"))}</code></pre>\n"
        code_lines.clear
        in_code = false
      else
        code_lines << line
      end
      next
    end

    if line.start_with?("```")
      flush_paragraph.call
      flush_list.call
      in_code = true
      next
    end

    if line.strip.empty?
      flush_paragraph.call
      flush_list.call
      next
    end

    if (match = line.match(/\A(#{'#'}{2,3})\s+(.+)\z/))
      flush_paragraph.call
      flush_list.call
      level = match[1].length
      text = match[2].strip
      html << %(<h#{level} id="#{slug(text)}">#{inline_markdown(text, from_page)}</h#{level}>\n)
      next
    end

    if (match = line.match(/\A-\s+(.+)\z/))
      flush_paragraph.call
      unless list_type == "ul"
        flush_list.call
        html << "<ul>\n"
        list_type = "ul"
      end
      list_items << match[1]
      next
    end

    if (match = line.match(/\A\d+\.\s+(.+)\z/))
      flush_paragraph.call
      unless list_type == "ol"
        flush_list.call
        html << "<ol>\n"
        list_type = "ol"
      end
      list_items << match[1]
      next
    end

    if list_type && (match = line.match(/\A\s{2,}(.+)\z/))
      list_items[-1] = "#{list_items[-1]} #{match[1].strip}"
      next
    end

    if line.start_with?("> ")
      flush_paragraph.call
      flush_list.call
      html << "<blockquote><p>#{inline_markdown(line.delete_prefix("> "), from_page)}</p></blockquote>\n"
      next
    end

    flush_list.call
    paragraph << line.strip
  end

  flush_paragraph.call
  flush_list.call
  [title, html]
end

def nav_html(current_page)
  PAGES.group_by { |page| page[:section] }.map do |section, pages|
    links = pages.map do |page|
      active = page == current_page ? %( class="active" aria-current="page") : ""
      %(<a#{active} href="#{relative_href(current_page, page)}">#{escape_html(page[:label])}</a>)
    end.join("\n")

    <<~HTML
      <div class="rail-group">
        <p class="rail-title">#{escape_html(section)}</p>
        #{links}
      </div>
    HTML
  end.join("\n")
end

def page_intro(page)
  case page[:output]
  when "index.html"
    "Lucid is a Ruby framework for building reactive, hypermedia applications with a message-driven architecture."
  when "why.html"
    "The design pressure that led Lucid toward messages, handlers, and components."
  when "hello.html"
    "Build the smallest useful Lucid application and see how state, links, and rendering connect."
  when "architecture.html"
    "Trace the request, message dispatch, and rendering loops that make Lucid work."
  when "messages.html"
    "Understand links, commands, and events as typed descriptions of user and system intent."
  when "components.html"
    "Learn how components hold typed state, compose views, and render HTML."
  when "handlers.html"
    "Use handlers for effectful command behavior, policies, redirects, and event publication."
  when "reference/state.html"
    "Reference for URL-backed state, state maps, and nested component state."
  when "reference/templates.html"
    "Reference for Lucid templates, rendering context, helpers, and multipart forms."
  when "reference/configuration.html"
    "Reference for application settings, request containers, and extension points."
  else
    "Reference for Lucid's feature-oriented project layout."
  end
end

def previous_next(page)
  index = PAGES.index(page)
  previous_page = index&.positive? ? PAGES[index - 1] : nil
  next_page = index && index < PAGES.length - 1 ? PAGES[index + 1] : nil

  [previous_page, next_page].compact.map do |target|
    direction = target == previous_page ? "Previous" : "Next"
    <<~HTML
      <a href="#{relative_href(page, target)}">
        <span>#{direction}</span>
        <strong>#{escape_html(target[:label])}</strong>
      </a>
    HTML
  end.join
end

def render_page(page)
  return render_index_page if page[:output] == "index.html"

  source = File.read(File.join(ROOT, page[:source]))
  title, body = render_markdown(source, page)

  <<~HTML
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>#{escape_html(title == "Lucid Documentation" ? title : "#{title} | Lucid Documentation")}</title>
        <meta name="description" content="#{escape_html(page_intro(page))}">
        <link rel="stylesheet" href="#{stylesheet_href(page)}">
      </head>
      <body>
        <a class="skip-link" href="#main">Skip to content</a>

        <div class="site-shell">
          <aside class="docs-rail" aria-label="Documentation navigation">
            <a class="brand" href="#{relative_href(page, PAGES.first)}" aria-label="Lucid documentation home">
              <span class="brand-mark" aria-hidden="true">L</span>
              <span>Lucid</span>
            </a>

            #{nav_html(page)}

            <a class="github-link" href="https://github.com/lachlancotter/lucid">GitHub</a>
          </aside>

          <main id="main" class="content">
            <article class="doc-page">
              <header class="doc-header">
                <p class="section-label">#{escape_html(page[:section])}</p>
                <h1>#{escape_html(title)}</h1>
                <p class="lede">#{escape_html(page_intro(page))}</p>
              </header>

              #{body}

              <nav class="page-nav" aria-label="Previous and next pages">
                #{previous_next(page)}
              </nav>
            </article>
          </main>
        </div>
      </body>
    </html>
  HTML
end

def render_index_page
  (<<~HTML).gsub(/^    /, "")
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Lucid Documentation</title>
        <meta
          name="description"
          content="Documentation for Lucid, a Ruby framework for reactive hypermedia applications."
        >
        <link rel="stylesheet" href="styles.css">
      </head>
      <body>
        <a class="skip-link" href="#main">Skip to content</a>

        <div class="site-shell">
          <aside class="docs-rail" aria-label="Documentation navigation">
            <a class="brand" href="index.html" aria-label="Lucid documentation home">
              <span class="brand-mark" aria-hidden="true">L</span>
              <span>Lucid</span>
            </a>

            <div class="rail-group">
              <p class="rail-title">Start Here</p>
              <a class="active" href="index.html">Overview</a>
              <a href="why.html">Why Lucid?</a>
              <a href="hello.html">Hello World</a>
              <a href="architecture.html">Architecture</a>
              <a href="messages.html">Messages</a>
              <a href="components.html">Components</a>
              <a href="handlers.html">Handlers</a>
            </div>

            <div class="rail-group">
              <p class="rail-title">Reference</p>
              <a href="reference/state.html">State</a>
              <a href="reference/templates.html">Templates</a>
              <a href="reference/configuration.html">Configuration</a>
              <a href="reference/project_structure.html">Project Structure</a>
            </div>

            <a class="github-link" href="https://github.com/lachlancotter/lucid">GitHub</a>
          </aside>

          <main id="main" class="content">
            <article class="doc-page">
              <header class="doc-header">
                <p class="section-label">Overview</p>
                <h1>Lucid Documentation</h1>
                <p class="lede">
                  Lucid is a Ruby framework for building reactive, hypermedia
                  applications with a message-driven architecture.
                </p>
              </header>

              <section aria-labelledby="how-lucid-is-different">
                <h2 id="how-lucid-is-different">How Lucid is different</h2>
                <p>
                  In a typical MVC framework like Rails, an interaction usually
                  starts with a route, moves through a controller action, and
                  renders a view. That is a familiar shape, but rich interfaces can
                  make the layers feel tightly coupled: templates need route
                  helpers, controllers collect rendering decisions, and UI state
                  often gets split across params, sessions, and client-side code.
                </p>
                <p>
                  As the interface becomes more stateful, developers usually face
                  an uncomfortable choice. They can keep state coordination on the
                  server, where controllers become the central place that knows too
                  much about view structure and user flow. Or they can move state
                  coordination into the browser, where the application gains a
                  thicker front end, a separate state model, and more client-side
                  tooling.
                </p>
                <p>
                  Lucid starts from intent instead of endpoints. User interactions
                  are represented as typed messages, so views describe what should
                  happen without knowing which route or controller shape will serve
                  it. Components own view state transitions, handlers own business
                  effects, and the request cycle decides what HTML needs to be
                  replaced.
                </p>
                <p>
                  That gives Lucid apps a SPA-like feel while staying loosely
                  coupled, reactive, and server-driven. You can update precise
                  parts of the page without introducing a front-end build pipeline,
                  client-side application state, or the imperative state management
                  that often appears in HTMX-heavy views.
                </p>
              </section>

              <section aria-labelledby="design-goals">
                <h2 id="design-goals">Design goals</h2>
                <p>
                  Lucid is designed to make rich server-rendered interfaces direct
                  to build and easy to change.
                </p>
                <ul>
                  <li>
                    Keep view code semantic. Components describe application
                    behavior through messages, state, props, and data flow rather
                    than route helpers, DOM IDs, JavaScript hooks, or client-side
                    wiring.
                  </li>
                  <li>
                    Make UX refactoring local. Changing a workflow should not
                    require coordinated edits across routes, controllers, templates,
                    and browser-side state.
                  </li>
                  <li>
                    Let the server coordinate interaction. Lucid follows component
                    data flow and state changes to decide which parts of the page
                    update, so rich UIs can scale without manually maintaining swap
                    targets.
                  </li>
                  <li>
                    Preserve hypermedia foundations. Lucid enhances plain links and
                    forms into SPA-like interactions without abandoning HTTP
                    semantics or requiring a front-end toolchain, so applications
                    degrade gracefully without JavaScript.
                  </li>
                </ul>
              </section>

              <section aria-labelledby="core-model">
                <h2 id="core-model">Core model</h2>
                <p>
                  Lucid has three core primitives. Messages name intent, handlers
                  apply effects, and components render state back to HTML.
                </p>
                <dl class="concept-list">
                  <div>
                    <dt>Messages</dt>
                    <dd>
                      Value objects that describe intent. Links represent navigation,
                      commands represent mutations, and events represent things that
                      happened in the system.
                    </dd>
                  </div>
                  <div>
                    <dt>Handlers</dt>
                    <dd>
                      Objects that apply business effects for commands: loading data,
                      enforcing policies, writing records, publishing events, and
                      registering redirects.
                    </dd>
                  </div>
                  <div>
                    <dt>Components</dt>
                    <dd>
                      Ruby objects that hold typed state, compose subcomponents, react
                      to messages or events, and render HTML.
                    </dd>
                  </div>
                </dl>
              </section>

              <section aria-labelledby="request-flow">
                <h2 id="request-flow">Request flow</h2>
                <ol>
                  <li>A user action submits a link or command message over HTTP.</li>
                  <li>Lucid decodes the HTTP request into a typed message object.</li>
                  <li>
                    <code>Link</code> messages are sent with <code>GET</code> and
                    dispatched through the component tree.
                  </li>
                  <li>
                    <code>Command</code> messages are sent with <code>POST</code> and
                    dispatched to the message bus.
                  </li>
                  <li>Handlers process command messages and publish events.</li>
                  <li>
                    Components can react to link messages or published events and
                    update their state.
                  </li>
                  <li>The component tree renders a full page or targeted HTML update.</li>
                </ol>
              </section>

              <section aria-labelledby="quickstart">
                <h2 id="quickstart">Quickstart</h2>
                <p>From a checkout of this repository, run the included example app:</p>
                <pre><code>bundle install
#{'bundle exec ruby examples/hello_world/app.rb'}</code></pre>
                <p>Then open <code>http://localhost:4567</code>.</p>
                <p>
                  This repository quickstart requires Ruby <code>3.2.8</code> and
                  Bundler. The example app does not require a database or external
                  services.
                </p>
                <p>
                  For the full walkthrough, continue to
                  <a href="hello.html">Hello World</a>.
                </p>
              </section>

              <section aria-labelledby="next">
                <h2 id="next">Next steps</h2>
                <h3>Start here</h3>
                <div class="link-list">
                  <a href="why.html">
                    <strong>Why Lucid?</strong>
                    <span>Understand the problems Lucid is designed to solve.</span>
                  </a>
                  <a href="hello.html">
                    <strong>Hello World</strong>
                    <span>Build the smallest useful Lucid application.</span>
                  </a>
                  <a href="architecture.html">
                    <strong>Architecture</strong>
                    <span>Trace the command, navigation, and rendering loops.</span>
                  </a>
                  <a href="messages.html">
                    <strong>Messages</strong>
                    <span>Learn how links, commands, and events encode intent.</span>
                  </a>
                  <a href="components.html">
                    <strong>Components</strong>
                    <span>Learn how components hold state, compose views, and render HTML.</span>
                  </a>
                  <a href="handlers.html">
                    <strong>Handlers</strong>
                    <span>
                      Put command-side behavior, policies, redirects, and event
                      publication in handlers.
                    </span>
                  </a>
                </div>

                <h3>Reference</h3>
                <div class="link-list">
                  <a href="reference/state.html">
                    <strong>State</strong>
                    <span>
                      Work with URL-backed state, state maps, and nested component
                      state.
                    </span>
                  </a>
                  <a href="reference/templates.html">
                    <strong>Templates</strong>
                    <span>
                      Use the template context, helpers, and multipart form support.
                    </span>
                  </a>
                  <a href="reference/configuration.html">
                    <strong>Configuration</strong>
                    <span>
                      Configure application settings, request containers, and
                      extension points.
                    </span>
                  </a>
                  <a href="reference/project_structure.html">
                    <strong>Project Structure</strong>
                    <span>Organize Lucid code around features.</span>
                  </a>
                </div>
              </section>
            </article>
          </main>
        </div>
      </body>
    </html>
  HTML
end

PAGES.each do |page|
  output_path = File.join(SITE_ROOT, page[:output])
  FileUtils.mkdir_p(File.dirname(output_path))
  File.write(output_path, render_page(page))
end
