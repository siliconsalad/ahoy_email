Rails.application.routes.draw do
  mount AhoyEmail::Engine => "/ahoy"
end

AhoyEmail::Engine.routes.draw do
  scope module: "ahoy" do
    resources :messages, only: [] do
      get :open, on: :member
      get :click, on: :member
    end

    post 'email_notification', to: 'aws_sns#email_notification', format: :json
  end
end
