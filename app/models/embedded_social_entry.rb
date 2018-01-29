# Embedded Social Entry Model - meta data for social entry
class EmbeddedSocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Parseable

  field :text, type: String, default: ''
  field :last_submit, type: Time

  embedded_in :embeddable_social_entry, polymorphic: true

  def reset_text
    logger.info 'EmbeddedSocialEntry.reset_text called'
    update_attributes(text: '', tags: [])
  end

  def text=(params)
    super(params)
    parse_text
  end
end
