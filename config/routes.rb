Rails.application.routes.draw do
  root 'home#index'
  get '/download', to: redirect(ENV.fetch('DOWNLOAD_URL'))
  get '/install', to: redirect('/auth/github')
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
end
