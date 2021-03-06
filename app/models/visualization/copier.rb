# encoding: utf-8
require 'ostruct'
require_relative './name_generator'
require_relative '../map/copier'
require_relative '../overlay/member'
require_relative '../overlay/copier'

module CartoDB
  module Visualization
    class Copier
      def initialize(user, visualization, name=nil)
        @user           = user
        @visualization  = visualization
        @name           = name
      end

      def copy(overlays=true, layers=true, additional_fields = {})
        member = Member.new(
          name:         new_name,
          tags:         visualization.tags,
          description:  visualization.description,
          type:         type_from(additional_fields),
          parent_id:    additional_fields.fetch(:parent_id, nil),
          map_id:       map_copy(layers, type_from(additional_fields) == Member::TYPE_SLIDE).id,
          privacy:      visualization.privacy,
          user_id:      @user.id
        )
        if overlays
          overlays_copy(member)
        end
        member
      end

      private

      attr_reader :visualization, :user, :name

      def type_from(fields)
        fields.fetch(:type, Member::TYPE_DERIVED)
      end

      def overlays_copy(new_visualization)
        copier = CartoDB::Overlay::Copier.new(new_visualization.id)
        visualization.overlays.each.map { |overlay|
          new_overlay = copier.copy_from(overlay)
          new_overlay.store
        }
      end

      def map_copy(layers, create_as_children=false)
        @map_copy ||= CartoDB::Map::Copier.new.copy(visualization.map, layers, create_as_children)
      end

      def new_name
        @new_name ||= NameGenerator.new(user).name(name || visualization.name)
      end
    end
  end
end

