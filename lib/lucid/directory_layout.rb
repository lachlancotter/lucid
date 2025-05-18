module Lucid
  #
  # Describes the organisation of directories in a Lucid project and
  # configures a Zeitwerk loader to load code from those directories.
  #
  class DirectoryLayout
    def initialize (root_path, namespace)
      @root_path = File.expand_path(root_path)
      @namespace = namespace
    end

    def configure (zeitwerk_loader)
      config_files.each { |f| require_file(f) }
      code_dirs.each { |dir| autoload_directory(dir, zeitwerk_loader) }
    end

    def code_dirs
      self.class.const_get(:CODE_DIRS)
    end

    def config_files
      self.class.const_get(:CONFIG_FILES)
    end

    def config_file (filename)
      "#{@root_path}/#{filename}"
    end

    def full_directory_path (directory_path)
      "#{@root_path}/#{directory_path}"
    end

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

    #
    # Project directory loads code from core, and feature directories.
    #
    class Project < DirectoryLayout
      CONFIG_FILES = %w[]
      CODE_DIRS = %w[config]

      def configure (zeitwerk_loader)
        super
        core_layout.configure(zeitwerk_loader)
        feature_files.each { |f| require f }
        feature_layouts.each { |l| l.configure(zeitwerk_loader) }
      end

      def core_layout
        DirectoryLayout::Core.new("#{@root_path}/core", @namespace)
      end

      def feature_layouts
        feature_directories.map do |name|
          DirectoryLayout::Feature.new(feature_root(name), feature_class(name))
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
    class Feature < DirectoryLayout
      CONFIG_FILES = %w[]
      CODE_DIRS    = %w[data models services views handlers policies]
      
      def configure (zeitwerk_loader)
        require feature_file
        super
      end
      
      def feature_file
        "#{@root_path}.rb"
      end
    end

    #
    # The Core module loads code from lib.
    #
    class Core < DirectoryLayout
      CONFIG_FILES = %w[]
      CODE_DIRS    = %w[models]
    end
  end
end
