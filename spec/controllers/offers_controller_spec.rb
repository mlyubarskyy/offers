require 'rails_helper'

describe OffersController do
  describe "GET index" do
    let(:client) { double(offers: [], message: "") }
    before do
      allow(subject).to receive(:init_fyber_client).and_return(client)
      subject.instance_variable_set :@client, client

      get :index, params
    end

    let(:params) { { uid: "player1" } }

    it "assigns all offers as @offers" do
      expect(assigns(:offers)).not_to be_nil
    end

    it "assigns message" do
      expect(assigns(:message)).not_to be_nil
    end
  end
end
