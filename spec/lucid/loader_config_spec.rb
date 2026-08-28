require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

module Lucid
  describe LoaderConfig do
    class LoaderConfigSpecApp
    end

    let(:root_path) { File.expand_path("../../support/test_app", __dir__) }

    describe ".configure" do
      it "autoloads collapsed default directories under the supplied namespace" do
        app = Module.new
        stub_const("LoaderConfigSpecAutoloadApp", app)

        Dir.mktmpdir do |root|
          FileUtils.mkdir_p(
            File.join(root, "lib", "loader_config_spec_autoload_app", "models")
          )
          FileUtils.mkdir_p(
            File.join(root, "lib", "loader_config_spec_autoload_app", "views")
          )
          FileUtils.mkdir_p(
            File.join(root, "lib", "loader_config_spec_autoload_app", "core")
          )
          File.write(
            File.join(root, "lib", "loader_config_spec_autoload_app", "models", "user.rb"),
            "class LoaderConfigSpecAutoloadApp::User; end\n"
          )
          File.write(
            File.join(root, "lib", "loader_config_spec_autoload_app", "views", "dashboard.rb"),
            "class LoaderConfigSpecAutoloadApp::Dashboard; end\n"
          )
          File.write(
            File.join(root, "lib", "loader_config_spec_autoload_app", "core", "boot.rb"),
            "class LoaderConfigSpecAutoloadApp::Boot; end\n"
          )

          zeitwerk_loader = Zeitwerk::Loader.new
          zeitwerk_loader.enable_reloading
          described_class.configure(
            zeitwerk_loader,
            namespace: app,
            root_path: root
          )
          zeitwerk_loader.setup

          expect(app::User.name).to eq("LoaderConfigSpecAutoloadApp::User")
          expect(app::Dashboard.name).to eq("LoaderConfigSpecAutoloadApp::Dashboard")
          expect(app::Boot.name).to eq("LoaderConfigSpecAutoloadApp::Boot")
        ensure
          zeitwerk_loader&.unload
        end
      end

      it "autoloads an explicit namespace path under the supplied namespace" do
        app = Module.new
        stub_const("LoaderConfigSpecExplicitApp", app)

        Dir.mktmpdir do |root|
          FileUtils.mkdir_p(File.join(root, "lib", "test_app", "models"))
          File.write(
            File.join(root, "lib", "test_app", "models", "user.rb"),
            "class LoaderConfigSpecExplicitApp::User; end\n"
          )

          zeitwerk_loader = Zeitwerk::Loader.new
          zeitwerk_loader.enable_reloading
          described_class.configure(
            zeitwerk_loader,
            namespace: app,
            root_path: root,
            namespace_path: "test_app"
          )
          zeitwerk_loader.setup

          expect(app::User.name).to eq("LoaderConfigSpecExplicitApp::User")
        ensure
          zeitwerk_loader&.unload
        end
      end

      it "autoloads an inferred acronym namespace path under the supplied namespace" do
        app = Module.new
        stub_const("LoaderConfigSpecAPIApp", app)

        Dir.mktmpdir do |root|
          FileUtils.mkdir_p(
            File.join(root, "lib", "loader_config_spec_api_app", "models")
          )
          File.write(
            File.join(root, "lib", "loader_config_spec_api_app", "models", "user.rb"),
            "class LoaderConfigSpecAPIApp::User; end\n"
          )

          zeitwerk_loader = Zeitwerk::Loader.new
          zeitwerk_loader.enable_reloading
          described_class.configure(
            zeitwerk_loader,
            namespace: app,
            root_path: root
          )
          zeitwerk_loader.setup

          expect(app::User.name).to eq("LoaderConfigSpecAPIApp::User")
        ensure
          zeitwerk_loader&.unload
        end
      end

      it "does not load sibling namespaces when the namespace path is inferred" do
        app = Module.new
        stub_const("LoaderConfigSpecScopedApp", app)

        Dir.mktmpdir do |root|
          FileUtils.mkdir_p(
            File.join(root, "lib", "loader_config_spec_scoped_app", "models")
          )
          FileUtils.mkdir_p(
            File.join(root, "lib", "loader_config_spec_other_app", "models")
          )
          File.write(
            File.join(root, "lib", "loader_config_spec_scoped_app", "models", "user.rb"),
            "class LoaderConfigSpecScopedApp::User; end\n"
          )
          File.write(
            File.join(root, "lib", "loader_config_spec_other_app", "models", "user.rb"),
            [
              "module LoaderConfigSpecOtherApp",
              "  module Models",
              "    class User; end",
              "  end",
              "end",
              ""
            ].join("\n")
          )

          zeitwerk_loader = Zeitwerk::Loader.new
          zeitwerk_loader.enable_reloading
          described_class.configure(
            zeitwerk_loader,
            namespace: app,
            root_path: root
          )
          zeitwerk_loader.setup
          zeitwerk_loader.eager_load

          expect(app::User.name).to eq("LoaderConfigSpecScopedApp::User")
          expect(defined?(LoaderConfigSpecOtherApp)).to be_nil
        ensure
          zeitwerk_loader&.unload
          Object.send(:remove_const, :LoaderConfigSpecOtherApp) if defined?(LoaderConfigSpecOtherApp)
        end
      end

      it "autoloads directories collapsed in the configuration block" do
        app = Module.new
        stub_const("LoaderConfigSpecPolicyApp", app)

        Dir.mktmpdir do |root|
          FileUtils.mkdir_p(File.join(root, "lib", "loader_config_spec_policy_app", "policies"))
          File.write(
            File.join(root, "lib", "loader_config_spec_policy_app", "policies", "admin_policy.rb"),
            "class LoaderConfigSpecPolicyApp::AdminPolicy; end\n"
          )

          zeitwerk_loader = Zeitwerk::Loader.new
          zeitwerk_loader.enable_reloading
          described_class.configure(
            zeitwerk_loader,
            namespace: app,
            root_path: root
          ) do |config|
            config.collapse "policies"
          end
          zeitwerk_loader.setup

          expect(app::AdminPolicy.name).to eq("LoaderConfigSpecPolicyApp::AdminPolicy")
        ensure
          zeitwerk_loader&.unload
        end
      end
    end

    describe ".infer_root_path" do
      it "finds the nearest project root from a file path" do
        expect(described_class.infer_root_path(from: __FILE__)).to eq(
          File.expand_path("../..", __dir__)
        )
      end

      it "works when loader config is required directly" do
        ruby = RbConfig.ruby
        lib_path = File.expand_path("../../lib", __dir__)
        script = [
          'require "lucid/loader_config"',
          "Lucid::LoaderConfig.infer_root_path(from: __FILE__)"
        ].join("; ")
        env = {
          "BUNDLE_BIN_PATH" => nil,
          "BUNDLE_GEMFILE"  => nil,
          "RUBYLIB"         => nil,
          "RUBYOPT"         => nil
        }

        _stdout, stderr, status = nil
        run = lambda do
          _stdout, stderr, status = Open3.capture3(
            env,
            ruby,
            "-I#{lib_path}",
            "-e",
            script
          )
        end
        if defined?(Bundler)
          Bundler.with_unbundled_env { run.call }
        else
          run.call
        end

        expect(status).to be_success, stderr
      end
    end

    describe ".namespace_path" do
      it "derives a path from the namespace constant name" do
        expect(described_class.namespace_path(LoaderConfigSpecApp)).to eq(
          "lucid/loader_config_spec_app"
        )
      end

      it "derives a path from a nested namespace constant name" do
        stub_const("LoaderConfigSpecAdmin", Module.new)
        stub_const("LoaderConfigSpecAdmin::Portal", Module.new)

        expect(described_class.namespace_path(LoaderConfigSpecAdmin::Portal)).to eq(
          "loader_config_spec_admin/portal"
        )
      end

      it "requires the namespace to have a name" do
        expect {
          described_class.namespace_path(Class.new)
        }.to raise_error(ArgumentError, "namespace must have a name")
      end
    end

    describe "#collapse" do
      it "starts with Lucid's default organisational directories" do
        config = described_class.new(
          namespace: LoaderConfigSpecApp,
          root_path: root_path,
          namespace_path: "test_app"
        )

        expect(config.collapse_dirs).to eq([
          "core",
          "features",
          "**/models",
          "**/views",
          "**/handlers",
          "**/services"
        ])
      end

      it "adds custom collapse patterns" do
        config = described_class.new(
          namespace: LoaderConfigSpecApp,
          root_path: root_path,
          namespace_path: "test_app"
        )

        config.collapse("policies")
        config.collapse("forms")

        expect(config.collapse_dirs).to include("policies", "forms")
      end

      it "does not add duplicate collapse patterns" do
        config = described_class.new(
          namespace: LoaderConfigSpecApp,
          root_path: root_path,
          namespace_path: "test_app"
        )

        config.collapse("**/models")

        expect(config.collapse_dirs.count("**/models")).to eq(1)
      end
    end
  end
end
