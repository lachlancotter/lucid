module Lucid
  module Session
    describe FileStore do

      describe ".save" do
        context "valid data" do
          it "saves data to a session file" do
            id       = "test-session"
            data     = { foo: "bar" }
            filepath = FileStore.filename(id)
            FileStore.save(id, data)
            expect(File.exist?(filepath)).to be(true)
          end
        end
      end

      describe ".load" do
        context "session does not exist" do
          it "returns an empty hash" do
            id = "nonexistent-session"
            expect(FileStore.load(id)).to eq({})
          end
        end

        context "session exists" do
          it "loads data from the session file" do
            id   = "test-session"
            data = { foo: "bar" }
            FileStore.save(id, data)
            expect(FileStore.load(id)).to eq(data)
          end
        end
      end

      describe ".delete" do
        context "session exists" do
          it "deletes a session file" do
            id   = "test-session"
            data = { foo: "bar" }
            FileStore.save(id, data)
            FileStore.delete(id)
            expect(File.exist?(FileStore.filename(id))).to be(false)
          end
        end

        context "session does not exist" do
          it "does nothing" do
            id = "nonexistent-session"
            FileStore.delete(id)
            expect(File.exist?(FileStore.filename(id))).to be(false)
          end
        end
      end

      describe ".use" do
        it "yields current data and saves changes" do
          id = "test-session"
          data = { foo: "bar" }
          FileStore.save(id, data)
          FileStore.use(id) do |current|
            expect(current).to eq(data)
            current[:foo] = "baz"
          end
          expect(FileStore.load(id)).to eq(foo: "baz")
        end
      end

    end
  end
end