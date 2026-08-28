describe Caju do
  it "exposes the public API through the Caju namespace" do
    expect(Caju::App).to eq(Lucid::App)
    expect(Caju::Component::Base).to eq(Lucid::Component::Base)
    expect(Caju::Command).to eq(Lucid::Command)
    expect(Caju::Link).to eq(Lucid::Link)
    expect(Caju::Event).to eq(Lucid::Event)
    expect(Caju::Handler).to eq(Lucid::Handler)
    expect(Caju::State).to eq(Lucid::State)
    expect(Caju::HTTP).to eq(Lucid::HTTP)
    expect(Caju::HTML).to eq(Lucid::HTML)
  end

  it "loads the framework through require caju" do
    expect { require "caju" }.not_to raise_error
    expect(Caju::App).to eq(Lucid::App)
  end
end
