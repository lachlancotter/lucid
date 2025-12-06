module Lucid
  class App
    describe Logger do
      let(:output) { StringIO.new }

      before do
        # Capture stdout to test log output
        allow(Logger).to receive(:puts) do |message|
          output.puts(message)
        end
      end

      describe "#session" do
        it "filters password field" do
          hash = { "username" => "john", "password" => "secret123" }
          Logger.session(hash)
          expect(output.string).to include("username")
          expect(output.string).to include("john")
          expect(output.string).to include("password")
          expect(output.string).not_to include("secret123")
          expect(output.string).to include("[FILTERED]")
        end

        it "filters password variations" do
          hash = {
            "Password" => "secret1",
            "PASSWORD" => "secret2",
            "user_password" => "secret3",
            "passwordConfirm" => "secret4",
            "password_confirmation" => "secret5"
          }
          Logger.session(hash)
          expect(output.string).not_to include("secret1")
          expect(output.string).not_to include("secret2")
          expect(output.string).not_to include("secret3")
          expect(output.string).not_to include("secret4")
          expect(output.string).not_to include("secret5")
          expect(output.string.scan(/\[FILTERED\]/).length).to eq(5)
        end

        it "filters other sensitive keys" do
          hash = {
            "token" => "abc123",
            "api_key" => "xyz789",
            "secret" => "hidden",
            "auth_token" => "auth123",
            "access_token" => "access456"
          }
          Logger.session(hash)
          expect(output.string).not_to include("abc123")
          expect(output.string).not_to include("xyz789")
          expect(output.string).not_to include("hidden")
          expect(output.string).not_to include("auth123")
          expect(output.string).not_to include("access456")
        end

        it "does not filter non-sensitive fields" do
          hash = { "username" => "john", "email" => "john@example.com" }
          Logger.session(hash)
          expect(output.string).to include("john")
          expect(output.string).to include("john@example.com")
        end
      end

      describe "#log_data" do
        it "filters password field from data hash" do
          data = { username: "alice", password: "mypassword" }
          Logger.send(:log_data, data)
          expect(output.string).to include("username")
          expect(output.string).to include("alice")
          expect(output.string).to include("password")
          expect(output.string).not_to include("mypassword")
          expect(output.string).to include("[FILTERED]")
        end

        it "filters multiple sensitive keys" do
          data = {
            user: "bob",
            password: "pass123",
            api_key: "key456",
            token: "tok789"
          }
          Logger.send(:log_data, data)
          expect(output.string).to include("bob")
          expect(output.string).not_to include("pass123")
          expect(output.string).not_to include("key456")
          expect(output.string).not_to include("tok789")
        end

        it "handles symbol and string keys" do
          data = {
            :password => "symbol_pass",
            "password" => "string_pass"
          }
          Logger.send(:log_data, data)
          expect(output.string).not_to include("symbol_pass")
          expect(output.string).not_to include("string_pass")
        end

        it "handles nested hashes" do
          data = {
            user: {
              name: "charlie",
              credentials: {
                password: "nested_pass",
                api_key: "nested_key"
              }
            }
          }
          Logger.send(:log_data, data)
          expect(output.string).to include("charlie")
          expect(output.string).not_to include("nested_pass")
          expect(output.string).not_to include("nested_key")
        end
      end

      describe "#link" do
        it "filters sensitive data from link hash" do
          link_class = Class.new do
            def self.name
              "TestLink"
            end

            def to_h
              { url: "/path", password: "link_pass" }
            end
          end
          link = link_class.new
          Logger.link(link)
          expect(output.string).to include("TestLink")
          expect(output.string).to include("/path")
          expect(output.string).not_to include("link_pass")
        end
      end

      describe "#command" do
        it "filters sensitive data from command hash" do
          command_class = Class.new do
            def self.name
              "TestCommand"
            end

            def to_h
              { action: "create", password: "cmd_pass", token: "cmd_token" }
            end
          end
          command = command_class.new
          Logger.command(command)
          expect(output.string).to include("TestCommand")
          expect(output.string).to include("create")
          expect(output.string).not_to include("cmd_pass")
          expect(output.string).not_to include("cmd_token")
        end
      end

      describe "#event" do
        it "filters sensitive data from event hash" do
          event_class = Class.new do
            def self.name
              "TestEvent"
            end

            def to_h
              { type: "user_login", secret: "event_secret" }
            end
          end
          event = event_class.new
          Logger.event(event)
          expect(output.string).to include("TestEvent")
          expect(output.string).to include("user_login")
          expect(output.string).not_to include("event_secret")
        end
      end

      describe "#debug" do
        it "filters sensitive data from debug data" do
          Logger.debug("Debug message", { user: "dave", password: "debug_pass" })
          expect(output.string).to include("Debug message")
          expect(output.string).to include("dave")
          expect(output.string).not_to include("debug_pass")
        end
      end

      describe "#warning" do
        it "filters sensitive data from warning data" do
          Logger.warning("Warning message", { issue: "auth", token: "warn_token" })
          expect(output.string).to include("Warning message")
          expect(output.string).to include("auth")
          expect(output.string).not_to include("warn_token")
        end
      end

      describe "#error" do
        it "filters sensitive data from error data" do
          Logger.error("Error message", { code: 500, api_key: "err_key" })
          expect(output.string).to include("Error message")
          expect(output.string).to include("500")
          expect(output.string).not_to include("err_key")
        end
      end

      describe "sensitive key patterns" do
        it "detects password variations" do
          patterns = [
            "password",
            "Password",
            "PASSWORD",
            "user_password",
            "userPassword",
            "password_confirmation",
            "passwordConfirmation",
            "current_password",
            "new_password",
            "old_password",
            "pw",
            "pwd",
            "user_pw",
            "current_pwd"
          ]
          patterns.each do |key|
            data = { key => "sensitive_value" }
            Logger.send(:log_data, data)
            expect(output.string).not_to include("sensitive_value")
            output.truncate(0)
            output.rewind
          end
        end

        it "detects token variations" do
          patterns = ["token", "auth_token", "access_token", "refresh_token", "csrf_token"]
          patterns.each do |key|
            data = { key => "token_value" }
            Logger.send(:log_data, data)
            expect(output.string).not_to include("token_value")
            output.truncate(0)
            output.rewind
          end
        end

        it "detects key variations" do
          patterns = ["key", "api_key", "apiKey", "secret_key", "private_key"]
          patterns.each do |key|
            data = { key => "key_value" }
            Logger.send(:log_data, data)
            expect(output.string).not_to include("key_value")
            output.truncate(0)
            output.rewind
          end
        end

        it "detects secret variations" do
          patterns = ["secret", "Secret", "client_secret", "app_secret"]
          patterns.each do |key|
            data = { key => "secret_value" }
            Logger.send(:log_data, data)
            expect(output.string).not_to include("secret_value")
            output.truncate(0)
            output.rewind
          end
        end
      end
    end
  end
end
