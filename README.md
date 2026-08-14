# Tileset Compositor for Godot

WIP

## What Is It?

Tileset Compositor is a Godot 4 project that includes scenes, scripts, and samples. It is meant to be used from the editor, with occasinal running of the game in order to use the export function.

It allows you to compose an image using the equivalent of "smart objects", which is to say instanced sprites that will auto-update if you update the graphics of their base texture.

With the added benefit of being able to turn on Y-ordering for these sprites (they will be drawn in front of other sprites that are higher on Y axis) this becomes a useful tool for composing tilesets with large and complex tiles that are made of several graphical objects.

I am sure there could be more uses for it, but tileset image composition was my main inspiration. During work on a game that uses large 128px tiles composed out of many graphical elements such as trees, I ran into several issues during texture asset creation. 

1. I wanted to use small individual graphics (such as a single tree variant) to compose tile images. However, these objects are just copies and will not update if I later choose to alter the appearance of base image. This would make my image composing work useless and I would have to do a lot of clicking to replace copies with the updated image. I have not found a free raster graphic software that has a good workflow for this.

2. These same individual objects would sometimes overlap, so I had to sort them according to Y axis, which is quite a painful work if there are a lot of them and all you can do is drag a layer up or down. Automated Y-sorting is another feature I could not find in free raster graphic software.

I have decided that creating a Godot project with specific scripts and scene setups is the path of least resistence. I don't know if there are better ways but this project is allowing me to overcome the two issues mentioned above and create large funcional auto-tiling terrain tiles, and now I am sharing it with the world. Considering the wealth of features present in Godot editor, you should be able to expand functionalities of this setup in any direction you need.

## How Does It Work?

The basic idea is you will import your individual graphical objects as textures (sprites), turn them into reusable scene objects, compose a scene out of these objects (and any other element you need) and export the composition as transparent png.

### Initial Setup

#### Configure output image

Decide what the target image is, project's default is 1024x1024px. Open the `main` scene that is in `res` root and update the `RenderingViewport`: under its `SubViewport` options set x and y `size` to your desired export format.

#### Prepare the "canvas"

The `RenderingViewport` must be parent to all graphical elements that will appear in the exported image. Whatever the preview image is showing in its inspector view is what will be rendered. If something is not there but it should be then you have to figure it out.

To keep it clean I suggest you only use other scenes in there. The project starts with a `SampleTileset` scene, you should replace it with your own and then do all the graphical editing inside that scene. 

The `SampleTileset` scene is showing a suggested setup, with three layers of containers (background, foreground, sky) all having Y-sorting turned on (very important) and locked for editing. It also has a grid object that can be made visible.

1. Create a new scene that will do something similar and add a grid of appropriate cell size (if what you are making is a tileset), some pre-made grids are available in the project. Remember to make grid invisible if you are exporting the image.
2. Add the scene that you have just created as parent to `RenderingViewport->Graphics` in the `main` scene. From now on you should leave the `main` scene alone, unless you want to make some wide adjustment.

#### Importing graphics: proposed Workflow

The project only has sample graphics, you should import your own trees, rocks, buildings, people, whatever are the elements that you will use to compose the final image.

1. Export your individual objects from your graphic software as images and import them as sprite textures.
2. Decide how you will use them as objects - either just drag&drop images themselves (in which case they will still be objects as sprites and auto-update if you change the source texture) or turn them into scenes first, perhaps by duplicating one of the `base...` objects and replacing the sprite and offset. The scene approach is preferable as you should set your sprites offset so that its bottom part is where the wrapping node's center is, this will make automatic Y-sorting feel more natural.

#### Composing the scene

TODO

