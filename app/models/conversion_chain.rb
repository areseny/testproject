require 'conversion_errors/conversion_errors'

# create_table "conversion_chains", force: :cascade do |t|
#   t.integer  "user_id",           null: false
#   t.datetime "executed_at"
#   t.string   "input_file"
#   t.integer  "chain_template_id", null: false
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
# end

class ConversionChain < ActiveRecord::Base
  include ConversionErrors

  belongs_to :user
  belongs_to :chain_template
  has_many :conversion_steps, inverse_of: :conversion_chain

  mount_uploaders :files, FileUploader
  has_many :files, as: :file_handler

  validates_presence_of :user, :chain_template

  def execute_conversion!
    raise ConversionErrors::NoFileSuppliedError unless input_file.present?
    self.update_attribute(:executed_at, Time.zone.now)
  end

  def input_file_name
    input_file.name
  rescue => e
    "cannot render name"
  end

end