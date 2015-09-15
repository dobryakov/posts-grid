class Api::UpdatesController < ApplicationController

  def verify
    if c = Koala::Facebook::RealtimeUpdates.meet_challenge(params, ENV['VERIFY_TOKEN'])
      render text: c, status: 200
    else
      render text: "not authorized", status: 401
    end
  end

  def receive
    Rails.logger.debug '================================='
    Rails.logger.debug request.to_json
    Rails.logger.debug '================================='
  end

end
