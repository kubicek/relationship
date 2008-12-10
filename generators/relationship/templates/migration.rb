class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name%>, :<%= column_name%>, :integer
  end

  def self.down
    remove_column :<%= table_name%>, :<%= column_name%>
  end
end
