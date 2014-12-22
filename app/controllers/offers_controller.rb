class OffersController < ApplicationController
  respond_to :html

  def index
    @offers = FyberClient::Offer.all(search_params)
    respond_with @offers
  end

  private

  def search_params
    params.permit(:uid, :pub0, :page)
  end
end
