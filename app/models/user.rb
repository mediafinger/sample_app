# == Schema Information
# Schema version: 20101106124457
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean(1)
#


class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || "is not a valid email") unless
      #value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      value =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  end
end

require 'digest'    # for password encryption via SHA2

class User < ActiveRecord::Base
  attr_accessor :password                   # virtual attribute - that means: no database column
  attr_accessible :name, :email, :password, :password_confirmation
  has_many :microposts, :dependent => :destroy
  default_scope :order => 'users.name ASC'

  validates :name,      :presence => true,
                        :length   => { :within => 3..30 }
  validates :email,     :presence   => true,
                        :email      => true,      # self written Validator in users_helper.rb
                        :uniqueness => { :case_sensitive => false }     # uniqueness => true , and ignoring the case
                        #:format    => { :with => email_regex }
  validates :password,  :presence     => true,
                        :length       => { :within => 6..64 },
                        :confirmation => true

  before_save :encrypt_password

  # CLASS Method defined through "self."authenticate
  def self.authenticate(email, submitted_password)
    user = User.find_by_email(email)
    (user && user.matching_password?(submitted_password)) ? user : nil
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = User.find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def self.per_page               # class method, used by will_paginate
    10
  end

  def feed
    microposts
    # Micropost.where("user_id =?", id)
  end

  def matching_password?(submitted_password)
    encrypt(submitted_password) == self.encrypted_password
  end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{self.salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

end

