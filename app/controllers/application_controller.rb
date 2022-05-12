require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

	configure do
		set :views, "app/views"
		enable :sessions
		set :session_secret, "password_security"
	end

	get "/" do
		erb :index
	end

	get "/signup" do
		erb :signup
	end

	post "/signup" do
		user = User.new(:username => params[:username], :password => params[:password])
		#because of has_secure_password, not able to save to DB unless user filled out password.  Calling user.save will return false if user can't be persisted.
		if user.save
			redirect "/login"
		else
			redirect "/failure"
		end
	end

	get "/login" do
		erb :login
	end

	post "/login" do
		user = User.find_by(:username => params[:username])
		#authenticate method added invisibly to class User by calling has_secure_password
		#takes string as an arguement
		#turns string in salted, hashed version
		#compares that to what is stored in DB
		#if match, return user instance otherwise false
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect "/success"
		else
			redirect "/failure"
		end
	end

	get "/success" do
		if logged_in?
			erb :success
		else
			redirect "/login"
		end
	end

	get "/failure" do
		erb :failure
	end

	get "/logout" do
		session.clear
		redirect "/"
	end

	helpers do
		def logged_in?
			!!session[:user_id]
		end

		def current_user
			User.find(session[:user_id])
		end
	end

end
