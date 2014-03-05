class IndexController < ApplicationController
  def index
    render view: 'index', layout: 'full'
  end
end
