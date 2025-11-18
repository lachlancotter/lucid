module Lucid
  module HTTP
    describe Message do

      describe ".url" do
        let(:response) { double("response") }
        let(:component_class) { Class.new(Component::Base) { param :baz } }
        let(:container_class) { Class.new(App::Container) }
        let(:config) { { component_class: component_class } }
        let(:container) { container_class.new(config, env) }

        def build_cycle (request)
          App::Cycle.new(request, response, container)
        end

        context "GET request" do
          let(:message_class) do
            Class.new(Message) do
              def self.message_name
                "test/message"
              end

              def self.http_method
                Message::GET
              end
            end
          end

          context "HTML basic" do
            it "includes the current state" do
              HTTP::Message.with_state({ baz: "qux" }) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?foo=bar&state%5Bbaz%5D=qux")
              end
            end
          end
          
          context "base url" do
            it "includes the current state" do
              HTTP::Message.with_url_base("/base/url") do
                HTTP::Message.with_state({ baz: "qux" }) do
                  expect(message_class.url(foo: "bar")).to eq("/base/url/@/test/message?foo=bar&state%5Bbaz%5D=qux")
                end
              end
            end
          end
        end

        context "POST request" do
          let(:message_class) do
            Class.new(HTTP::Message) do
              def self.message_name
                "test/message"
              end

              def self.http_method
                HTTP::Message::POST
              end
            end
          end

          context "HTML basic" do
            it "includes the current state and omits message params" do
              HTTP::Message.with_state({ baz: "qux" }) do
                expect(message_class.url(foo: "bar")).to eq("/@/test/message?state%5Bbaz%5D=qux")
              end
            end
          end
        end
      end

    end
  end
end