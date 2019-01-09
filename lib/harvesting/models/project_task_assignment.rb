module Harvesting
  module Models
    class ProjectTaskAssignment < Base
      attributed :id,
                 :project,
                 :task,
                 :user,
                 :is_active,
                 :is_project_manager,
                 :hourly_rate,
                 :budget,
                 :created_at,
                 :updated_at

      def initialize(ref_project, attrs, opts = {})
        super(attrs, opts)
        @ref_project = ref_project
      end

      def path
        @attributes['id'].nil? ? "projects/#{@ref_project.id}/task_assignments" : "projects/#{@ref_project.id}/task_assignments/#{@attributes['id']}"
      end
    end
  end
end
