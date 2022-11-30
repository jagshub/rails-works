# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Notifications::Target < GraphQL::Batch::Loader
    def perform(targets)
      targets = targets.select do |target|
        klass = target['type']
        id = target['id']

        if id.present? && %w(Post Discussion::Thread Comment).include?(klass)
          true
        else
          fulfill(target, nil)
          false
        end
      end

      groups = targets.group_by { |t| t['type'] }
      groups.keys.each do |klass|
        group = groups[klass]

        klass.safe_constantize.where(id: group.pluck('id')).each do |instance|
          target = group.find { |t| t['id'] == instance.id }
          if target.present?
            fulfill(target, instance)
            targets = targets.reject { |t| t == target }
          end
        end
      end

      targets.each do |target|
        fulfill(target, nil)
      end
    end
  end
end
