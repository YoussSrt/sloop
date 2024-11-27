class ChangeStatusInSloopiesToBeString < ActiveRecord::Migration[7.0]
  def up
    change_column :sloopies, :status, :string
  end

  def down
    change_column :sloopies, :status, :boolean
  end
end
