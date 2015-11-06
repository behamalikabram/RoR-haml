RailsAdmin.config do |config|

  config.authenticate_with {} # leave it to authorize

  config.authorize_with do
    redirect_to main_app.root_path if current_user.nil? or !current_user.is_admin?
  end

  config.current_user_method(&:current_user)

  config.included_models = ["User", "Wallet", "Ticket"]

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    show
    edit
    new
    delete
    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model "User" do 
    edit do 
      field :username
      field :email
      field :wallet
      field :role
      field :password
      field :password_confirmation
      field :ip
      field :ip_banned
      field :banned
    end

    create do 
      field :username
      field :email
      field :wallet
      field :role
      field :password
      field :password_confirmation
    end

    list do 
      field :id
      field :username
      field :wallet 
      field :role
      field :email
      field :banned
      field :ip_banned
    end

    show do 
      field :id
      field :username
      field :wallet 
      field :role
      field :ip
      field :email
    end
  end

  config.model "Wallet" do 
    edit do 
      field :add_amount
      field :value
    end

    list do 
      field :id
      field :value_to_s do 
        label "Money"
      end
      field :value
      field :user
    end

    show do 
      field :user
      field :value_to_s do 
        label "Money"
      end
    end
  end

  config.model "Ticket" do 
    edit do 
    end

    list do 
      field :id
      field :created_at
      field :type
      field :amount
      field :state
      field :currency
      field :user
      field :recipient_user
    end

    show do 
      field :id
      field :message
      field :created_at
      field :type
      field :amount
      field :state
      field :currency
      field :user
      field :recipient_user
    end
  end
end
