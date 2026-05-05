module Lucid
  class App
    describe ResponseEffects do
      describe "#redirect_to" do
        it "stores an absolute HTTP redirect URL" do
          effects = ResponseEffects.new

          effects.redirect_to("https://example.com/checkout")

          expect(effects.redirect_url).to eq("https://example.com/checkout")
        end

        it "rejects relative redirect URLs" do
          effects = ResponseEffects.new

          expect {
            effects.redirect_to("/checkout")
          }.to raise_error(ResponseEffects::InvalidRedirect)
        end

        it "rejects multiple redirects in the same request" do
          effects = ResponseEffects.new
          effects.redirect_to("https://example.com/checkout")

          expect {
            effects.redirect_to("https://example.com/other")
          }.to raise_error(ResponseEffects::RedirectAlreadySet)
        end
      end
    end
  end
end
