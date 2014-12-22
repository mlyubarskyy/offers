require 'rails_helper'

describe OffersController do
  describe "GET index" do
    let(:params) { { uid: "player1" } }

    it "assigns all offers as @offers" do
      get :index, params
      expect(assigns(:offers)).not_to be_nil
    end
  end
end
