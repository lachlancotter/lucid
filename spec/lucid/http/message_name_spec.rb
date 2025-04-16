module Lucid
  module HTTP
    describe MessageName do
      describe ".encode" do
        it "converts class names to URLs" do
          expect(MessageName.encode("Lucid::Component::Base")).to eq("lucid/component/base")
        end
      end

      describe ".decode" do
        it "converts URLs class names" do
          expect(MessageName.decode("lucid/component/base")).to eq("Lucid::Component::Base")
        end
      end

      describe ".to_class" do
        context "no namespace" do
          it "raises an exception" do
            url = "/not/a/message"
            expect { MessageName.to_class(url) }.to raise_error(MessageName::PathInvalid)
          end
        end

        context "no message name" do
          it "raises an exception" do
            url = "/@/"
            expect { MessageName.to_class(url) }.to raise_error(MessageName::PathInvalid)
          end
        end

        class TestMessage < Lucid::HTTP::Message
          #
          # Test of constant decoding. 
          # 
        end

        context "no params" do
          it "decodes the message name" do
            url   = "/@/lucid/h-t-t-p/test-message"
            klass = MessageName.to_class(url)
            expect(klass).to eq(TestMessage)
          end
        end

        context "app root" do
          it "decodes the message name" do
            url   = "/app_root/@/lucid/h-t-t-p/test-message"
            klass = MessageName.to_class(url)
            expect(klass).to eq(TestMessage)
          end
        end

        context "full message name and params" do
          it "decodes message names from URLs" do
            url   = "/@/lucid/h-t-t-p/test-message?category_slug=guitars-basses&state[step]=store"
            klass = MessageName.to_class(url)
            expect(klass).to eq(TestMessage)
          end
        end
      end

    end
  end
end