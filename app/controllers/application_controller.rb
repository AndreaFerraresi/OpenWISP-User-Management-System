# This file is part of the OpenWISP User Management System
#
# Copyright (C) 2010 CASPUR (Davide Guerri d.guerri@caspur.it)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include SimpleCaptcha::ControllerHelpers
  has_mobile_fu()
  
  helper :all
  helper_method :current_account_session, :current_account
  helper_method :current_operator_session, :current_operator
  filter_parameter_logging :password, :password_confirmation, :crypted_password
  protect_from_forgery
  
  # Access current_operator from models
  before_filter :set_current_operator
  
  # Set locale from session
  before_filter :set_locale

  def available_locales; AVAILABLE_LOCALES; end

  def set_locale
    I18n.locale = available_locales.include?(session[:locale]) ? session[:locale] : nil
  end

  def set_session_locale
    session[:locale] = params[:locale]
    redirect_to request.env['HTTP_REFERER'] || :root
  end
  
  protected
  def current_account_session
    return @current_account_session if defined?(@current_account_session)
    @current_account_session = AccountSession.find
  end
  
  def current_account
    return @current_account if defined?(@current_account)
    @current_account = current_account_session && current_account_session.record
  end
  
  def require_account
    unless current_account
      store_location
      flash[:notice] = I18n.t(:Must_be_logged_in)
      redirect_to new_account_session_url
      return false
    end
  end

  def require_no_account
    if current_account
      store_location
      flash[:notice] = I18n.t(:Must_be_logged_out)
      redirect_to account_url
      return false
    end
  end

  def current_operator_session
    return @current_operator_session if defined?(@current_operator_session)
    @current_operator_session = OperatorSession.find
  end
  
  def current_operator
    return @current_operator if defined?(@current_operator)
    @current_operator = current_operator_session && current_operator_session.record
  end
  
  def require_operator
    unless current_operator
      store_location
      flash[:notice] = I18n.t(:Must_be_logged_in)
      redirect_to new_operator_session_url
      return false
    end
  end

  def require_no_operator
    if current_operator
      store_location
      flash[:notice] = I18n.t(:Must_be_logged_out)
      redirect_to users_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # Access current_operator from models
  def set_current_operator
    Operator.current_operator = self.current_operator
  end

protected
  exception_data :additional_data

  def additional_data
    { :operator => current_operator,
      :user => current_account }
  end

end