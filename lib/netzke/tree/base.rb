module Netzke
  module Tree
    # Ext.tree.Panel-based component with the following features:
    #
    # * CRUD operations
    # * Persistence of node expand/collapse state
    # * Node reordering by DnD
    #
    # Client-side methods are documented here: http://api.netzke.org/client/classes/Netzke.Tree.Base.html.
    #
    # == Simple example
    #
    #     class Files < Netzke::Tree::Base
    #       def configure(c)
    #         super
    #         c.model = "FileRecord"
    #         c.columns = [
    #           {name: :name, xtype: :treecolumn}, # this column will show tree nodes
    #           :size
    #         ]
    #       end
    #     end
    #
    # == Instance configuration
    #
    # The following config options are supported:
    #
    # [model]
    #
    #   Name of the ActiveRecord model that provides data to this Tree, e.g. "FileRecord"
    #   The model must respond to the following methods:
    #
    #   * TreeModel.root - the root record
    #   * TreeModel#children - child records
    #
    #   Note that the awesome_nested_set gem implements the above, so, feel free to use it.
    #
    # [columns]
    #
    #   An array of columns to be displayed in the tree. See the "Columns" section in the `Netzke::Grid::Base`.
    #   Additionally, you probably will want to specify which column will have the tree nodes UI by providing the
    #   `xtype` config option set to `:treecolumn`.
    #
    # [root]
    #
    #   By default, the component will pick whatever record is returned by `TreeModel.root`, and use it as the root
    #   record. However, sometimes the model table has multiple root records (whith `parent_id` set to `nil`), and all
    #   of them should be shown in the panel. To achive this, you can define the `root` config option,
    #   which will serve as a virtual root record for those records. You may set it to `true`, or a hash of
    #   attributes, e.g.:
    #
    #       c.root = {name: 'Root', size: 1000}
    #
    #   Note, that the root record can be hidden from the tree by specifying the `Ext.tree.Panel`'s `root_visible`
    #   config option set to `false`, which is probably what you want when you have multiple root records.
    #
    # [scope]
    #
    #   A Proc or a Hash used to scope out grid data. The Proc will receive the current relation as a parameter and must
    #   return the modified relation. For example:
    #
    #      class Books < Netzke::Grid::Base
    #        def configure(c)
    #          super
    #          c.model = Book
    #          c.scope = lambda {|r| r.where(author_id: 1) }
    #        end
    #      end
    #
    #   Hash is being accepted for conivience, it will be directly passed to `where`. So the above can be rewritten as:
    #
    #      class Books < Netzke::Grid::Base
    #        def configure(c)
    #          super
    #          c.model = Book
    #          c.scope = {author_id: 1}
    #        end
    #      end
    #
    # [drag_drop]
    #
    #   Enables drag and drop in the tree.
    #
    # == Persisting nodes' expand/collapse state
    #
    # If the model includes the `expanded` DB field, the expand/collapse state will get stored in the DB.

    autoload :Endpoints, 'netzke/tree/endpoints'

    class Base < Netzke::Base
      NODE_ATTRS = {
        boolean: %w[leaf checked expanded expandable qtip qtitle],
        string: %w[icon icon_cls href href_target qtip qtitle]
      }

      include Netzke::Grid::Configuration
      include Netzke::Grid::Endpoints
      include Netzke::Grid::Services
      include Netzke::Grid::Actions
      include Netzke::Grid::Components
      include Netzke::Grid::Permissions
      include Netzke::Basepack::Columns
      include Netzke::Basepack::Attributes
      include Netzke::Basepack::DataAccessor
      include Netzke::Tree::Endpoints

      client_class do |c|
        c.extend = "Ext.tree.Panel"
        c.require :extensions
        c.mixins << "Netzke.Grid.Columns"
        c.mixins << "Netzke.Grid.EventHandlers"
        c.translate *%w[are_you_sure confirmation]
      end

      action :search do |c|
        c.excluded = true
      end

      class << self
        def server_side_config_options
          super + [:model]
        end

        # Borrow translations from the grid for now
        def i18n_id
          "netzke.grid.base"
        end
      end

      def columns
        add_node_interface_methods(super)
      end

      # Overrides Grid::Services#get_records
      def get_records(params)
        if params[:id] == 'root'
          model_adapter.find_root_records(config[:scope])
        else
          model_adapter.find_record_children(model_adapter.find_record(params[:id]), config[:scope])
        end
      end

      # Overrides Grid::Services#read so we send records as key-value JSON (instead of array)
      def read(params = {})
        {}.tap do |res|
          records = get_records(params)
          res["children"] = records.map{|r| node_to_hash(r, final_columns).netzke_literalize_keys}
          res["total"] = count_records(params)  if config[:enable_pagination]
        end
      end

      def node_to_hash(record, columns)
        model_adapter.record_to_hash(record, columns).tap do |hash|
          if is_node_expanded?(record)
            hash["children"] = model_adapter.find_record_children(record, config[:scope]).map {|child| node_to_hash(child, columns).netzke_literalize_keys}
          end
        end
      end

      def is_node_expanded?(record)
        record.respond_to?(:expanded) && record.expanded?
      end

      # Overrides `Grid::Configuration#configure_client`
      def configure_client(c)
        super

        c.root ||= model_adapter.record_to_hash(model_adapter.root, final_columns).netzke_literalize_keys
      end

      private

      def update_record(record, attrs)
        if config.drag_drop && attrs['parentId']
          parent_id = attrs['parentId'] == 'root' ? nil : attrs['parentId']
          model_adapter.set_record_value_for_attribute(record, { name: 'parent_id' }, parent_id)
        end

        super
      end

      # Adds attributes known to Ext.data.NodeInterface as meta columns (only those our model responds to)
      def add_node_interface_methods(columns)
        columns.clone.tap do |columns|
          NODE_ATTRS.each do |type, attrs|
            add_node_interface_methods_by_type!(columns, attrs, type)
          end
        end
      end

      def add_node_interface_methods_by_type!(columns, attrs, type)
        attrs.each do |a|
          next unless model_adapter.model_respond_to?(a.to_sym)
          columns << {type: type, name: a, meta: true}
        end
      end
    end
  end
end
