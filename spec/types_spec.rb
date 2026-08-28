describe Types do
  describe "parameter type helpers" do
    it "exposes the documented params types" do
      {
        string: "value",
        integer: "1",
        float: "1.5",
        bool: "true",
        date: "2026-08-28",
        time: "12:34:56",
        datetime: "2026-08-28T12:34:56Z",
        hash: {},
        symbol: "status"
      }.each do |name, value|
        expect { described_class.public_send(name)[value] }.not_to raise_error
      end
    end
  end
end
