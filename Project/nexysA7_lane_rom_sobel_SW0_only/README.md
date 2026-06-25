# Nexys A7 ROM Sobel Project - SW0 Only Version

This is the simpler ROM-based Sobel lane-edge detection project.

## Files to add in Vivado

Add these VHDL files:

- `src/nexysA7_lane_rom_sobel_top.vhd`
- `src/vga_timing_640x480.vhd`
- `src/image_rom_160x120.vhd`
- `src/sobel3x3_simple.vhd`

Add this constraint file:

- `constraints/nexysA7_lane_rom_sobel.xdc`

## Top entity

Use this top entity:

`nexysA7_lane_rom_sobel_top`

## Board control

Only one switch is used:

- `SW0 = 0`: show original road image
- `SW0 = 1`: show Sobel edge image

No reset button is used.

## Simple explanation

The VGA timing module creates screen positions `x` and `y`.
The image ROM gives one road-image pixel for that position.
The Sobel module detects edges from the pixel stream.
SW0 selects whether the VGA monitor shows the original image or the Sobel result.
