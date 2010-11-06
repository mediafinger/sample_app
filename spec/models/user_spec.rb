require 'spec_helper'

describe User do

  before :each do
    @attr = {
            :name => 'Laura Maier',
            :email => 'laura@maier.com',
            :password => 'password',
            :password_confirmation => 'password'
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

# NAME Tests
  describe "name validations" do
    it "should require a name" do
      no_name_user = User.new(@attr.merge(:name => ''))
      no_name_user.should_not be_valid
    end

    it "should have a name with 3 characters minimum" do
      short_name_user = User.new(@attr.merge(:name => 'XY'))
      short_name_user.should_not be_valid
    end

    it "should reject names that are too long" do
      long_name = "a" * 31
      long_name_user = User.new(@attr.merge(:name => long_name))
      long_name_user.should_not be_valid
    end
  end

# EMAIL Tests
  describe "email validations" do
    it "should require an email" do
      no_email_user = User.new(@attr.merge(:email => ''))
      no_email_user.should_not be_valid
    end

    it "should accept valid email addresses" do
      addresses = %w(a@f.d bla.bla.bla@fff.de blub-b@f-f.de bla@bla.bla.bla so_auch@eine.mail  SO@AUCH.de 12@tf4u.com)
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end

    it "should reject malformed email addresses" do
      bad_addresses = %w(an@aus. @hurra.de hall\ o@mail.de schreib.mir.mal warum.nicht.de@ so@nicht_keine.mail)
      bad_addresses.each do |address|
        malformed_email_user = User.new(@attr.merge(:email => address))
        malformed_email_user.should_not be_valid
      end
    end

    it "should have a unique email" do
      User.create!(@attr)
      email_user_2 = User.new(@attr)
      email_user_2.should_not be_valid
    end

    it "should have a unique email no matter uppercase or lowercase" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
  end

# PASSWORD Tests
  describe "password validations" do
    it "should require a password" do
      no_password_user = User.new(@attr.merge(:password => '', :password_confirmation => ''))
      no_password_user.should_not be_valid
    end

    it "should have a password with 6 or more characters" do
      short_password_user = User.new(@attr.merge(:password => 'short', :password_confirmation => 'short'))
      short_password_user.should_not be_valid
    end

    it "should have a password with 64 characters maximum" do
      p = 'a' * 65
      too_long_password_user = User.new(@attr.merge(:password => p, :password_confirmation => p))
      too_long_password_user.should_not be_valid
    end

    it "should confirm password" do
      unconfirmed = User.new(@attr.merge(:password_confirmation => 'foobar'))
      unconfirmed.should_not be_valid
    end
  end

# Encrypted PASSWORD Tests
  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

   it "should be true if the passwords match" do
      @user.matching_password?(@attr[:password]).should be_true
    end

    it "should be false if the passwords do not match" do
      @user.matching_password?("invalid").should be_false
    end

    it "should return nil on email/password mismatch" do
      User.authenticate(@attr[:email], 'wrong_password').should be_nil
    end

    it "should return nil when email does not exist" do
      User.authenticate('email-not@system.com', @attr[:password]).should be_nil
    end

    it "should return the user on success" do
      (User.authenticate(@attr[:email], @attr[:password]) == @user).should be_true
    end
  end

# ADMIN rights
  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
end

