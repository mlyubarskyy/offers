require 'spec_helper'

describe FyberClient do
  let(:args) { { uid: "player1", pub0: nil, page: nil } }

  subject do
    FyberClient.new(args)
  end


  describe ".initialize" do
    let(:query) { subject.instance_variable_get(:@query).symbolize_keys }

    it "assigns parameters" do
      expect(query[:uid]).to eq(args[:uid])
      expect(query[:pub0]).to eq(args[:pub0])
      expect(query[:page]).to eq(args[:page])

      expect(query[:timestamp]).not_to be_nil
      expect(query[:hashkey]).not_to be_nil
    end

    it "loads configuration" do
      %i(appid device_id locale ip offer_types).each do |param|
        expect(query[param]).not_to be_nil
      end
    end
  end

  describe "#get" do
    before do
      stub_request(:get, /api\.sponsorpay\.com/).to_return(
        body: "",
        headers: {"x-sponsorpay-response-signature" => "fabe540778d200b7f93b2710b39939dc267e4294"}
      )
      subject.get
    end

    it "fetches offers" do
      expect(WebMock).to have_requested(:get, "api.sponsorpay.com/feed/v1/offers.json/").
        with(query: subject.instance_variable_get(:@query))
    end

    it "validates response" do
      expect(subject.valid?).to be true
    end
  end

  describe "#offers" do
    before do
      allow(subject).to receive(:valid?).and_return(true)
      subject.instance_variable_set(:@body, response_body)
    end

    let(:response_body) { { "offers" => [ offer ] } }
    let(:offer) do
      {
        title: "Tap  Fish",
        offer_id: 13554,
        teaser: "Download and START",
        required_actions: "Download and START",
        link: "http://iframe.sponsorpay.com/mbrowser?appid=157&lpid=11387&uid=player1",
        offer_types: [
          {offer_type_id: 101, readable: "Download"},
          {offer_type_id: 112, readable: "Free"}
        ],
        thumbnail: {
          lowres: "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png",
          hires: "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_175.png"
        },
        payout: 90,
        time_to_payout: {
          amount: 1800,
          readable: "30 minutes"
        }
      }
    end

    it "returns offers" do
      expect(subject.offers).to eq([offer])
    end
  end

  describe "#message" do
    before do
      subject.instance_variable_set(:@body, response_body)
    end

    let(:response_body) { { "message" => message } }
    let(:message) {
      "Successful request, but no offers are currently available for this user."
    }

    it "returns offers" do
      expect(subject.message).to eq(message)
    end
  end

  describe "#hash_key" do
    let(:args) do
      {
        appid: 157,
        device_id: "2b6f0cc904d137be2e1730235f5664094b831186",
        ip: "212.45.111.17",
        locale: :de,
        page: 2,
        ps_time: 1312211903,
        pub0: "campaign2",
        timestamp: 1312553361,
        uid: "player1"
      }
    end
    let(:api_key) { "e95a21621a1865bcbae3bee89c4d4f84" }
    let(:expected_api_key) { "7a2b1604c03d46eec1ecd4a686787b75dd693c4d" }

    it "calculates hash_key in a special way" do
      Rails.application.secrets.fyber["api_key"] = api_key
      expect(subject.send(:sign_with_api_key, args)).to eq(expected_api_key)
    end
  end
end
