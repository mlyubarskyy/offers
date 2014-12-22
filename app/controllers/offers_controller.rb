class OffersController < ApplicationController
  respond_to :html
  before_action :init_fyber_client

  def index
    @offers = @client.offers
    @message = @client.message

    respond_with @offers
  end

  private

  def init_fyber_client
    @client = FyberClient.new(search_params).get
  end

  def search_params
    params.permit(:uid, :pub0, :page)
  end
end
