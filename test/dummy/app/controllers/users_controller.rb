# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    User.create!(name: params[:user][:name])

    redirect_to users_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    user.update!(name: params[:user][:name])

    redirect_to users_path
  end

  def destroy
    user = User.find(params[:id])
    user.destroy

    redirect_to users_path
  end
end
