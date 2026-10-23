require "capybara"
require "capybara/rspec/matchers"

module TitleBrowserSpec
  class ShowClients < Lucid::Link; end
  class RenamePage < Lucid::Link; end
  class RefreshContent < Lucid::Link; end

  class Content < Lucid::Component::Base
    route ":section"
    param :section, Types.string.default("sessions".freeze)
    param :revision, Types.integer.default(0)
    title { |section| section.capitalize }
    to ShowClients, section: "clients"
    to RefreshContent, revision: 1

    element do |section, revision|
      h1 { text section.capitalize }
      p { text "Revision #{revision}" }
      svg { title { text "Icon title" } }
    end
  end

  class Layout < Lucid::Component::Base
    route "/", nest: :content
    param :suffix, Types.string.default("".freeze)
    title { |nested_title, suffix| "Lucid: #{nested_title}#{suffix}" }
    to RenamePage, suffix: ' & <Clients> "quoted"'
    nest(:content) { Content }

    element(:html) do
      html do
        head do
          title { text context.title }
          script(src: "/htmx.js")
        end
        body("hx-boost": "true") do
          nav do
            link_to ShowClients.new, "Clients"
            link_to RenamePage.new, "Rename page"
            link_to RefreshContent.new, "Refresh content"
          end
          subcomponent :content
        end
      end
    end
  end

  class TestApp < Lucid::App
    set :environment, :test
    set :app_root, ""
    set :component_class, Layout

    # Register before Lucid's catch-all state route.
    get "/htmx.js" do
      content_type "application/javascript"
      File.read(File.expand_path("../fixtures/htmx-2.0.4.min.js", __dir__))
    end
  end
end

describe "HTMX document titles", :browser do
  include Capybara::RSpecMatchers

  let(:browser) { Capybara::Session.new(:selenium_chrome_headless, TitleBrowserSpec::TestApp) }

  around do |example|
    previous_server = Capybara.server
    Capybara.server = :webrick
    example.run
  ensure
    browser.driver.quit
    Capybara.server = previous_server
  end

  before do
    browser.visit("/sessions")
    expect(browser).to have_title("Lucid: Sessions", exact: true)
    expect(browser.evaluate_script("htmx.version")).to eq("2.0.4")
    browser.execute_script(<<~JS)
      window.originalDocument = document;
      window.originalContent = document.getElementById("content");
      window.originalNavigation = document.querySelector("nav");
      document.addEventListener("htmx:afterRequest", function(event) {
        window.lastSwap = event.detail.xhr.getResponseHeader("HX-Reswap");
        window.lastResponse = event.detail.xhr.responseText;
      });
    JS
  end

  it "updates the composed page title while swapping the nested component" do
    browser.click_link("Clients")

    expect(browser).to have_title("Lucid: Clients", exact: true)
    expect(browser).to have_css("#content h1", text: "Clients")
    expect(browser).to have_current_path("/clients")
    expect(browser.evaluate_script("window.lastSwap")).to eq("outerHTML")
    expect(browser.evaluate_script("window.originalDocument === document")).to be(true)
    expect(browser.evaluate_script("window.originalNavigation === document.querySelector('nav')")).to be(true)
    expect(browser.evaluate_script("window.originalContent === document.getElementById('content')")).to be(false)
    expect(browser.find("#content svg title", visible: :all).text(:all)).to eq("Icon title")
    expect(browser).to have_css("head > title", count: 1, visible: :all)
    expect(browser).to have_no_css("body > title", visible: :all)
  end

  it "updates and unescapes the title when the response has no component changes" do
    browser.click_link("Rename page")

    expect(browser).to have_title('Lucid: Sessions & <Clients> "quoted"', exact: true)
    expect(browser.evaluate_script("window.lastSwap")).to eq("none")
    expect(browser.evaluate_script("window.originalDocument === document")).to be(true)
    expect(browser.evaluate_script("window.originalContent === document.getElementById('content')")).to be(true)
    expect(browser).to have_css("#content h1", text: "Sessions")
    expect(browser).to have_no_css("body > title", visible: :all)
  end

  it "preserves the title when unrelated HTML containing an SVG title changes" do
    browser.click_link("Refresh content")

    expect(browser).to have_css("#content p", text: "Revision 1")
    expect(browser).to have_title("Lucid: Sessions", exact: true)
    expect(browser.evaluate_script("window.lastResponse")).not_to start_with("<title>")
    expect(browser.evaluate_script("window.lastSwap")).to eq("outerHTML")
    expect(browser.evaluate_script("window.originalNavigation === document.querySelector('nav')")).to be(true)
    expect(browser.evaluate_script("window.originalContent === document.getElementById('content')")).to be(false)
    expect(browser.find("#content svg title", visible: :all).text(:all)).to eq("Icon title")
  end

end
