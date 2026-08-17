require "pathname"

module Lucid
  #
  # Configures a Zeitwerk loader for Lucid's conventional application layout.
  #
  # The layout keeps application code under the application's normal Ruby
  # namespace, while allowing organisational directories such as core, features,
  # models, views, handlers, and services to be collapsed.
  #
  class LoaderConfig
    DEFAULT_COLLAPSE_DIRS = [
      "core",
      "features",
      "**/models",
      "**/views",
      "**/handlers",
      "**/services"
    ].freeze

    def self.configure (loader, namespace:, root_path: nil, namespace_path: nil, &block)
      inferred_root_path = root_path || infer_root_path(from: caller_locations(1, 1).first.path)
      config = new(
        namespace:      namespace,
        root_path:      inferred_root_path,
        namespace_path: namespace_path
      )
      yield config if block_given?
      config.configure(loader)
    end

    def self.infer_root_path (from: caller_locations(1, 1).first.path)
      Pathname.new(from).dirname.ascend do |path|
        return path.to_s if project_root?(path)
      end
      Dir.pwd
    end

    def self.project_root? (path)
      path.join("Gemfile").exist? ||
         path.join(".git").exist? ||
         path.join("config.ru").exist?
    end

    def initialize (namespace:, root_path:, namespace_path: nil, collapse_dirs: DEFAULT_COLLAPSE_DIRS)
      @namespace      = namespace
      @root_path      = File.expand_path(root_path)
      @namespace_path = namespace_path || self.class.namespace_path(namespace)
      @collapse_dirs  = collapse_dirs.dup
    end

    attr_reader :namespace, :root_path, :namespace_path, :collapse_dirs

    def self.namespace_path (namespace)
      name = namespace.name
      raise ArgumentError, "namespace must have a name" unless name && !name.empty?

      name.split("::").map { |part| underscore(part) }.join("/")
    end

    def self.underscore (string)
      string
        .gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
        .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
        .tr("-", "_")
        .downcase
    end

    def collapse (pattern)
      @collapse_dirs << pattern unless @collapse_dirs.include?(pattern)
      self
    end

    def configure (loader)
      loader.push_dir(namespace_root, namespace: namespace)

      collapse_dirs.each do |pattern|
        loader.collapse(File.join(namespace_root, pattern))
      end

      loader
    end

    private

    def lib_path
      File.join(root_path, "lib")
    end

    def namespace_root
      File.join(lib_path, namespace_path)
    end
  end
end
