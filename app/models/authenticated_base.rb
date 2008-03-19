require 'digest/sha1'
module AuthenticatedBase
  def self.included(base)
    base.set_table_name base.name.tableize
    
    base.validates_presence_of     :login, :email
    base.with_options :if => :password_required? do |base_pass|
      base_pass.validates_presence_of     :password
      base_pass.validates_presence_of     :password_confirmation
      base_pass.validates_length_of       :password, :within => 4..40
      base_pass.validates_confirmation_of :password
    end
    base.validates_length_of       :login,    :within => 3..40
    base.validates_length_of       :email,    :within => 3..100
    base.validates_uniqueness_of   :login, :email, :case_sensitive => false
    base.before_save :encrypt_password

    # prevents a user from submitting a crafted form that bypasses activation
    # anything else you want your user to change should be added here.
    base.attr_accessible :login, :email, :password, :password_confirmation
    base.cattr_accessor :current_user
    
    base.extend ClassMethods
  end

  attr_accessor :password

  module ClassMethods
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login, password)
      u = find_by_login(login) # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end