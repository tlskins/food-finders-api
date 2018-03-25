# Embedded Social Entry Model - meta data for social entry
class EmbeddedSocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Parseable

  field :text, type: String, default: ''
  field :last_submit, type: Time

  embedded_in :embeddable_social_entry, polymorphic: true

  after_save :parse_text

  def submitted
    update_attributes(
      text: '',
      tags: [],
      creatable_tags: [],
      last_submit: Time.now
    )
  end

  def text=(params)
    super(params)
    parse_text
  end
end
