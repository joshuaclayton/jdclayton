task :create_admin_user => :environment do
  User.create!({
    :login                  => "admin",
    :email                  => "admin@fusionary.com",
    :password               => "fusionary",
    :password_confirmation  => "fusionary",
    :admin                  => 1
  })
end