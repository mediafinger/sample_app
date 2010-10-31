require 'spec_helper'

describe User do

  before :each do
    @attr = { :name => 'Laura Maier', :email => 'laura@meier.com' }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

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
