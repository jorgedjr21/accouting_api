class ApplicationController < ActionController::API
  def validate_token 
    return render json: { message: 'The auth_token was not provided' }, status: :forbidden if params[:auth_token].blank?

    account = Account.find_by(auth_token: params[:auth_token])
    return render json: { message: 'Wrong auth token' }, status: :forbidden if account.blank?

    render json: { message: 'The auth token provided is not from the requester account' }, status: :forbidden if account.auth_token != params[:auth_token] || account.id != params[:source_account_id].to_i
  end
end
