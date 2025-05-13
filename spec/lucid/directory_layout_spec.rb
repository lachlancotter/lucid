module Lucid
  describe DirectoryLayout::Project do
    describe "#feature_files" do
      
    end
  end
  
  describe DirectoryLayout::Feature do
    it "loads the feature file" do
      layout = DirectoryLayout::Feature.new("foo/bar/baz", Object)
      expect(layout.feature_file).to include(File.expand_path("foo/bar/baz.rb"))
    end
  end
end