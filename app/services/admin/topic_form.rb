# frozen_string_literal: true

class Admin::TopicForm
  include MiniForm::Model

  model :topic, attributes: %i(name description image emoji kind parent_id), save: true

  attributes :aliases_attributes

  after_update :additional_alias

  delegate :aliases, :persisted?, :image_url, :to_param, to: :topic

  class << self
    def reflect_on_association(name)
      Topic.reflect_on_association name
    end
  end

  def initialize(topic = Topic.new)
    @topic = topic
  end

  def to_model
    topic
  end

  def aliases_attributes=(aliases)
    aliases.values.each do |attributes|
      model = attributes['id'].present? ? topic.aliases.find(attributes['id']) : TopicAlias.new
      model.name = attributes['name']

      if attributes['_destroy'] == '1'
        model.destroy
      else
        topic.aliases << model
      end
    end
  end

  private

  def additional_alias
    topic.aliases.create! name: name unless topic.aliases.any? { |model| model.name == name.downcase }
  end
end
