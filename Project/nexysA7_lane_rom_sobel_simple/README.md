# Nexys A7 Simple Lane Detection with Sobel Filter



## Idea

Instead of using a live camera, the FPGA stores one road image in ROM:

```text
Image ROM -> Sobel filter -> VGA monitor
```

## Files

### Main VHDL source files

1. `src/nexysA7\_lane\_rom\_sobel\_top.vhd`  
Main top file for the Nexys A7 board.
2. `src/vga\_timing\_640x480.vhd`  
Creates 640x480 VGA timing using the 100 MHz board clock.
3. `src/image\_rom\_160x120.vhd`  
Stores the grayscale road image inside FPGA ROM.
4. `src/sobel3x3\_simple.vhd`  
Performs the 3x3 Sobel edge detection.

### Constraint file

`constraints/nexysA7\_lane\_rom\_sobel.xdc`

### Preview images

The `docs` folder contains:

* `original\_road\_image\_from\_pdf.png`
* `road\_image\_160x120\_gray.png`
* `preview\_original\_on\_vga.png`
* `preview\_sobel\_expected.png`

## Vivado steps

1. Open Vivado.
2. Create new RTL project.
3. Select your Nexys A7 board or the correct Artix-7 part.
4. Add all VHDL files from the `src` folder.
5. Add `constraints/nexysA7\_lane\_rom\_sobel.xdc`.
6. Set top module/entity:

```text
nexysA7\_lane\_rom\_sobel\_top
```

7. Run Synthesis.
8. Run Implementation.
9. Generate Bitstream.
10. Program the Nexys A7 board.

## Board controls

```text
BTNC      = reset
SW0 = 0   = show original road image
SW0 = 1   = show Sobel edge output
SW1 = 1   = black/white threshold mode for Sobel output
```

## Important note

This project uses a stored image, not a live camera. This is intentional because it keeps the hardware design easy. After this works, a camera input can be added as a future improvement.

