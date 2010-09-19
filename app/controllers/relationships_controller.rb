class RelationshipsController < ApplicationController
  before_filter :authenticate

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)

    #Allows for Ajax request, either the  HTML request or the Ajax request is executed
    respond_to do |format|
      #HTML request
      format.html { redirect_to @user }
      #Ajax request
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)

    #Allows for Ajax request, either the  HTML request or the Ajax request is executed
    respond_to do |format|
      #HTML request
      format.html { redirect_to @user }
      #Ajax request
      format.js
    end
  end
end
