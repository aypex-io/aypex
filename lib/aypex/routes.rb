module Aypex
  class Engine < ::Rails::Engine
    def self.add_routes(&block)
      @aypex_routes ||= []

      # Anything that causes the application's routes to be reloaded,
      # will cause this method to be called more than once
      # i.e. https://github.com/plataformatec/devise/blob/31971e69e6a1bcf6c7f01eaaa44f227c4af5d4d2/lib/devise/rails.rb#L14
      # In the case of Devise, this *only* happens in the production env
      # This coupled with Rails 4's insistence that routes are not drawn twice,
      # poses quite a serious problem.
      #
      # This is mainly why this whole file exists in the first place.
      #
      # Thus we need to make sure that the routes aren't drawn twice.
      @aypex_routes << block unless @aypex_routes.include?(block)
    end

    def self.append_routes(&block)
      @append_routes ||= []
      # See comment in add_routes.
      @append_routes << block unless @append_routes.include?(block)
    end

    def self.draw_routes(&block)
      @aypex_routes ||= []
      @append_routes ||= []
      eval_block(block) if block
      @aypex_routes.each { |r| eval_block(&r) }
      @append_routes.each { |r| eval_block(&r) }
      # # Clear out routes so that they aren't drawn twice.
      @aypex_routes = []
      @append_routes = []
    end

    def eval_block(&block)
      Aypex::Engine.routes.send :eval_block, block
    end
  end
end
