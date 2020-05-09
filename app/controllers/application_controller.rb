class ApplicationController < ActionController::API
  def validate_token 
    auth_token = params[:auth_token] || request.headers['auth-token']

    return render json: { message: 'The auth_token was not provided' }, status: :forbidden if auth_token.blank?

    account = Account.find_by(auth_token: auth_token)
    return render json: { message: 'Wrong auth token' }, status: :forbidden if account.blank?

    if account.auth_token != auth_token || (account.id != params[:source_account_id].to_i && account.id != params[:id].to_i )
      render json: { message: 'The auth token provided is not from the requester account' }, status: :forbidden
    end
  end
end
