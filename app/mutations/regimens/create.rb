module Regimens
  class Create < Mutations::Command
    include FarmEvents::FragmentHelpers
    using Sequences::CanonicalCeleryHelpers

    required do
      model :device, class: Device
      string :name
      string :color, in: Sequence::COLORS
      array :regimen_items do
        hash do
          integer :time_offset
          integer :sequence_id
        end
      end
    end

    optional { body }

    def execute
      Regimen.silently do
        ActiveRecord::Base.transaction do
          inputs[:regimen_items].map! do |i|
            RegimenItem.new(i)
          end
          result = wrap_fragment_with(Regimen.create!(inputs.except(:body)))
        end
      end
      result.manually_sync!
    end
  end
end

Regimina ||= Regimens # Lol, inflection errors
