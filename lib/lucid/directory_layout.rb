module Lucid
  #
  # Describes the organisation of directories in a Lucid project and
  # configures a Zeitwerk loader to load code from those directories.
  #
  class DirectoryLayout
    def initialize (root_path, namespace, &block)
      @root_path    = File.expand_path(root_path)
      @namespace    = namespace
      @code_dirs    = []
      @config_files = []
      yield self if block_given?
    end

    attr_reader :code_dirs, :config_files

    def configure (zeitwerk_loader)
      config_files.each { |f| require_file(f) }
      code_dirs.each { |dir| autoload_directory(dir, zeitwerk_loader) }
    end

    private

    def require_file (filename)
      # puts "Require file: #{config_file(filename)}"
      if File.file?(config_file(filename))
        require config_file(filename)
      end
    end

    def autoload_directory (directory, zeitwerk_loader)
      # puts "Autoload from: #{full_directory_path(directory)}: #{@namespace}"
      if File.directory?(full_directory_path(directory))
        zeitwerk_loader.push_dir(full_directory_path(directory), namespace: @namespace)
      end
    end

    def config_file (filename)
      "#{@root_path}/#{filename}"
    end

    def full_directory_path (directory_path)
      "#{@root_path}/#{directory_path}"
    end

    #
    # Project directory loads code from core, and feature directories.
    #
    class Project < DirectoryLayout
      # def initialize(root_path, namespace, &block)
      #   super
      #   code_dirs << "config" if File.directory?("#{root_path}/config")
      # end

      def configure (zeitwerk_loader)
        super
        core_layout.configure(zeitwerk_loader)
        feature_files.each { |f| require f }
        feature_layouts.each { |l| l.configure(zeitwerk_loader) }
      end

      def core_layout
        CoreDir.new("#{@root_path}/core", @namespace)
      end

      def feature_layouts
        feature_directories.map do |name|
          FeatureDir.new(feature_root(name), feature_class(name))
        end
      end

      def features_path
        "#{@root_path}/features"
      end

      def feature_root (feature_name)
        "#{features_path}/#{feature_name}"
      end

      def feature_class (feature_name)
        @namespace.const_get(
           feature_name.split("_").map(&:capitalize).join
        )
      end

      def feature_directories
        Dir.children(features_path).select do |entry|
          File.directory?("#{features_path}/#{entry}")
        end
      end

      def feature_files
        Dir.children(features_path).select do |entry|
          File.file?("#{features_path}/#{entry}") && entry.end_with?(".rb")
        end.map do |filename|
          "#{features_path}/#{filename}"
        end
      end
    end

    #
    # Feature modules load code from data, models, services, and views directories.
    #
    class FeatureDir < DirectoryLayout
      def initialize(root_path, namespace, &block)
        super
        Dir.children(root_path).each do |entry|
          code_dirs << entry if load_dir?(entry)
        end
      end

      private

      def load_dir?(entry)
        File.directory?("#{@root_path}/#{entry}") &&
           !entry.start_with?(".") &&
           !["css", "js", "data"].include?(entry)
      end
    end

    #
    # The Core module loads code from lib.
    #
    class CoreDir < DirectoryLayout
      def initialize(root_path, namespace, &block)
        super
        Dir.children(root_path).each do |entry|
          code_dirs << entry if load_dir?("#{root_path}/#{entry}")
        end
      end

      private

      def load_dir?(entry)
        File.directory?(entry) && !entry.start_with?(".")
      end
    end
  end
end
