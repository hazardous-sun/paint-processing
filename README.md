# Processing Paint Application

A simple drawing application built with Processing, featuring various tools for creating shapes and freehand drawings.

## Features

- **Drawing Tools**:
  - Square: Click to place squares with customizable size
  - Triangle: Click three points to define a triangle
  - Line: Click-drag to create lines
  - Star: Click to place stars with customizable size
  - Freehand: Draw freeform paths
  - Eraser: "Erase" by drawing with white color

- **Customization**:
  - Adjustable stroke weight (1-20px)
  - RGB color pickers for stroke and fill colors
  - Toggle fill on/off for shapes
  - Resizable canvas

- **Advanced Features**:
  - Undo/Redo functionality (Z/Y keys)
  - Config panel toggle
  - 20-step undo history

## How to Use

1. **Select a tool** from the top toolbar
2. **Adjust settings** in the config panel:
   - Colors (RGB values)
   - Stroke weight
   - Size (for squares and stars)
   - Fill toggle
3. **Draw** on the canvas:
   - Most tools: Click to place
   - Triangle: Click 3 points
   - Line: Click-drag
   - Freehand/Eraser: Click-drag

**Keyboard Shortcuts**:
- `Z`: Undo
- `Y`: Redo

## Technical Details

- Built with Processing (Java-based)
- Custom scanline fill algorithm for shapes
- Object-oriented design with tool hierarchy
- State management for undo/redo functionality

## File Structure

- `paint_processing.pde`: Main application logic
- `tools.pde`: Tool classes and implementations
- `sketch.properties`: Processing configuration

## Requirements

- Processing 3.5+ (https://processing.org/)

## Known Limitations

- Triangle filling can be slow for large shapes
- No save/load functionality
- Limited to 20 undo steps
