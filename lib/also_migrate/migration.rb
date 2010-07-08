module AlsoMigrate
  module Migration
    
    def self.included(base)
      unless base.respond_to?(:method_missing_with_also_migrate)
        base.extend ClassMethods
        base.class_eval do
          class <<self
            alias_method :method_missing_without_also_migrate, :method_missing
            alias_method :method_missing, :method_missing_with_also_migrate
          end
        end
      end
    end

    module ClassMethods

      def method_missing_with_also_migrate(method, *arguments, &block)
        args = Marshal.load(Marshal.dump(arguments))
        method_missing_without_also_migrate(method, *arguments, &block)
        
        return if ENV['from_db_test_prepare']

        supported = [
          :add_column, :add_index, :add_timestamps, :change_column,
          :change_column_default, :change_table, :create_table,
          :drop_table, :remove_column, :remove_columns,
          :remove_timestamps, :rename_column, :rename_table
        ]

        if !args.empty? && supported.include?(method)
          connection = ActiveRecord::Base.connection
          table_name = ActiveRecord::Migrator.proper_table_name(args[0])
          
          # Find models
          Object.subclasses_of(ActiveRecord::Base).each do |klass|
            if klass.respond_to?(:also_migrate_config)
              next unless klass.table_name == table_name && !klass.also_migrate_config.nil?
              klass.also_migrate_config.each do |config|
                options = config[:options]
                tables = config[:tables]
                
                # Don't change ignored columns
                options[:ignore].each do |column|
                  next if args.include?(column) || args.include?(column.intern)
                end

                # Run migration
                config[:tables].each do |table|
                  if method == :create_table
                    ActiveRecord::Migrator::AlsoMigrate.create_tables(klass)
                  elsif method == :add_index && !options[:indexes].nil?
                    next
                  elsif connection.table_exists?(table)
                    args[0] = table
                    args[1] = table if method == :rename_table
                    connection.send(method, *args, &block)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end