require "lucid/http/request_adaptor"

module Lucid
  module HTTP
    describe RequestAdaptor do
      describe "#href" do
        context "/" do
          it "eq /" do
            adaptor = RequestAdaptor.new(double(fullpath: "/"))
            expect(adaptor.href("/")).to eq("/")
          end
        end
      end
    end
  end
end