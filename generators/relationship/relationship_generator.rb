module Rails
  module Generator
    module Commands
      class Create < Base
        def relationship(first_class, relation, second_class)
          
          # has_many is opposite to belongs_to, so just turn around
          if relation=="has_many"
            first_class, second_class = second_class, first_class
            relation="belongs_to"
          end
          
          first_class_name=first_class.camelize
          second_class_name=second_class.camelize
          migration_file_name = "add_#{second_class}_id_to_#{first_class}"
          
          # process belongs_to relationship
          if relation=="belongs_to"
            
            # add migration
            migration_template 'migration.rb', 'db/migrate', :assigns => {
              :migration_name => migration_file_name.camelize,
              :table_name => first_class.pluralize,
              :column_name => "#{second_class}_id"
            }, :migration_file_name => migration_file_name
            
            # add relationship to models
            # first_class belongs_to second_class
            insert_relationship( first_class, 
              "  belongs_to :#{second_class}," +
              " :class_name => \"#{second_class_name}\"," +
              " :foreign_key => \"#{second_class}_id\""
            )
            # second_class has_many first_classes
            insert_relationship( second_class,
              "  has_many :#{first_class.pluralize}," +
              " :class_name => \"#{first_class_name}\"," + 
              " :foreign_key => \"#{second_class}_id\""
            )
          end
        end

        private
        # from dbmodel gem
        def insert_relationship(modelfile, relationship)
          File.open("app/models/#{modelfile}.rb",'r+'){ |file|
            modelcode = file.readlines
            class_line = find_class_declaration_line(modelcode)
            if class_line >= 0            
              our_relation = Regexp.new(relationship.strip)
              unless modelcode.grep(our_relation).any?
                puts "  --> insert#{relationship}  (into #{modelfile}.rb)" if not $silent
                modelcode.insert(class_line + 1, relationship + "\n")
              end
            end
            # File should always grow with our additions
            file.rewind
            file.puts(modelcode)
          }
        end
        # from dbmodel gem
        def find_class_declaration_line(code)
          code.each_with_index do |line, index|     
            return index if line =~ /class/
          end
          puts "error: couldn't find class to insert relationships"
          return -2
        end
        
      end
    end
  end
end

class RelationshipGenerator < Rails::Generator::Base

  def initialize(*runtime_args)
    super(runtime_args)
    @first_class, @relationship, @second_class = args[0]
  end
    
  def manifest
    record do |m| 
      m.relationship @first_class, @relationship, @second_class
    end
  end
  
protected
 
  def banner
    "Usage: #{$0} relationship FirstClass relation SecondClass"
  end
 
end

