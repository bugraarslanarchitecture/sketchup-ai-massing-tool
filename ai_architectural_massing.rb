
module SketchUpAIMassingTool
  extend self

  def create_building
    prompts = [
      "Building Length (m)",
      "Building Width (m)",
      "Number of Floors",
      "Floor Height (m)"
    ]

    defaults = [30.0, 20.0, 5, 3.2]

    values = UI.inputbox(
      prompts,
      defaults,
      "AI Architectural Massing Tool"
    )

    return unless values

    length, width, floors, height = values

    if length.to_f <= 0 || width.to_f <= 0 ||
       floors.to_i <= 0 || height.to_f <= 0
      UI.messagebox("Please enter positive values.")
      return
    end

    model = Sketchup.active_model
    model.start_operation("Create Building Mass", true)

    begin
      building = model.active_entities.add_group
      building.name = "AI_Building_Massing"

      floors.to_i.times do |i|
        floor = building.entities.add_group
        floor.name = "Floor_#{i + 1}"

        z = i * height.to_f
        h = height.to_f

        points = [
          [0, 0, z],
          [length.to_f, 0, z],
          [length.to_f, width.to_f, z],
          [0, width.to_f, z]
        ].map { |p| Geom::Point3d.new(
          p[0].m, p[1].m, p[2].m
        ) }

        face = floor.entities.add_face(points)

        next unless face

        face.reverse! if face.normal.z < 0
        face.pushpull(h.m)
      end

      model.commit_operation

      UI.messagebox(
        "Building created successfully!\n" \
        "#{floors.to_i} floors generated."
      )

    rescue => error
      model.abort_operation
      UI.messagebox("Error: #{error.message}")
    end
  end

  unless file_loaded?(__FILE__)
    UI.menu("Extensions").add_item(
      "AI Architectural Massing Tool"
    ) {
      create_building
    }

    file_loaded(__FILE__)
  end
end
