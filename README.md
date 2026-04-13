# DonutScene

A 3D donut modeled in Blender and brought to life with real-time animations in the Godot Engine.

![Blender render of the donut](screenshots/blender_donut.png)  
![Blender Workspace](screenshots/blender_work.png)

## What This Project Is

A realistic donut with icing and sprinkles. Originally modeled in Blender 5.1 and exported to Godot 4.6. The Godot scene features:

- A camera orbiting around the donut
- Donut hovering and slowly rotating
- Realistic PBR materials using baked textures from Blender 
- A procedural sky environment for dynamic reflections
- Cinematic 4-point lighting

## Animation Preview

Click the video link below to see the final animation running in Godot:
[🎥 Watch the Final Animation (Godot)](screenshots/final_animation_godot.mp4)

## MCP Servers Used

This project was built aggressively using the Model Context Protocol (MCP) to allow AI coding assistants to directly interface with the modeling tools and game engine. 

- **Blender MCP Server**: [https://github.com/ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) used for manipulating 3D assets and baking PBR textures.
- **Godot MCP Server**: [https://github.com/tugcantopaloglu/godot-mcp](https://github.com/tugcantopaloglu/godot-mcp) used for dynamically creating scenes, adding lighting, setting up the camera rig, and creating animations via GDScript.

## How It Was Built

- **Blender Workflow:** The `.glb` file was modeled, the procedural materials created, and textures (Base Color, Roughness, Normal) baked for export through automated scripting via MCP.
- **Godot Workflow:** The 3D scene, lighting, camera rig, and PBR environments were populated via GDScript using the Godot MCP server. The logic handles the real-time animation directly within the internal game engine.

## Guide: How to Run This Project

1. Clone or download this repository to your local machine.
2. Ensure you have [Godot Engine 4.6+](https://godotengine.org/download/) installed (Standard edition is fine).
3. Open Godot and click **Import**.
4. Navigate into the downloaded folder and select the `project.godot` file.
5. Once the project opens in Godot, press **F5** (or click the 'Play' button mapped to the main scene) to run the animation.
