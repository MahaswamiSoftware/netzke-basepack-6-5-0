module Netzke
  module Basepack
    class SearchWindow < Netzke::Window::Base

      action :search
      action :cancel

      client_class do |c|
        c.width = "50%"
        c.auto_height = true
        c.close_action = "hide"
        c.modal = true
        c.init_component = l(<<-JS)
          function(){
            this.callParent();

            this.on('show', function(){
              this.closeRes = 'cancel';
            });
          }
        JS

        c.get_query = l(<<-JS)
          function(){
            return this.items.first().getQuery();
          }
        JS

        c.netzke_on_search = l(<<-JS)
          function(){
            this.closeRes = 'search';
            this.hide();
          }
        JS

        c.netzke_on_cancel = l(<<-JS)
          function(){
            this.hide();
          }
        JS
      end

      def configure(c)
        super
        c.items = [:query_builder]
        c.title = I18n.t('netzke.basepack.search_window.title')
        c.persistence = false
        c.prevent_header = true
        c.buttons = [:search, :cancel]
      end

      component :query_builder do |c|
        c.klass = QueryBuilder
        c.model = config[:model]
        c.fields = config[:fields]
      end

    end
  end
end
