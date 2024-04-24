module Lucid
  describe Session do
    describe "attributes" do
      it "defines attributes" do
        session_class = Class.new(Session) { attribute :foo }
        session       = session_class.new(foo: "bar")
        expect(session.foo).to eq("bar")
      end
    end

    describe "validation" do
      it "raises when invalid" do
        session_class = Class.new(Session) do
          attribute :foo
          validate { required(:foo) }
        end
        expect {
          session_class.new({})
        }.to raise_error(Session::Invalid)
      end
    end

    describe "mutation" do
      it "updates the original hash" do
        hash    = {}
        session = Session.new(hash)
        session.put(foo: "bar")
        expect(hash[:foo]).to eq("bar")
      end

      it "raises when invalid" do
        session_class = Class.new(Session) do
          attribute :foo
          validate { required(:foo).filled(:str?) }
        end
        session       = session_class.new(foo: "bar")
        expect {
          session.put(foo: "")
        }.to raise_error(Session::Invalid)
      end
    end

    describe "queries" do
      it "defines queries" do
        session_class = Class.new(Session) do
          attribute :foo
          let(:bar) { |foo| foo.upcase }
        end
        session       = session_class.new(foo: "bar")
        expect(session.bar).to eq("BAR")
      end
    end

    describe "notification" do
      it "notifies when fields are changed" do
        session_class = Class.new(Session) { attribute :foo }
        session       = session_class.new(foo: "bar")
        observed_value = nil
        session.watch(:foo) { observed_value = session[:foo] }
        session.put(foo: "baz")
        expect(observed_value).to eq("baz")
      end
    end
  end
end