from pathlib import Path
from PIL import Image, ImageOps
import sys

if len(sys.argv) != 3:
    print("Usage: python make_image_rom_320x240.py input_image output_vhdl")
    raise SystemExit(1)

inp = Path(sys.argv[1])
out = Path(sys.argv[2])

if not inp.exists():
    print(f"Input image not found: {inp}")
    raise SystemExit(1)

# Open image, resize to 320x240, convert to grayscale
img = Image.open(inp).convert("RGB")
img = img.resize((320, 240), Image.Resampling.LANCZOS)
gray = ImageOps.grayscale(img)
pixels = list(gray.getdata())

# Convert each grayscale value to VHDL hex format: x"AB"
entries = []
for i, pix in enumerate(pixels):
    comma = "," if i != len(pixels) - 1 else ""
    entries.append(f'x"{pix:02X}"{comma}')

# Put 16 pixel values per line, so the VHDL file is readable
rom_lines = []
for i in range(0, len(entries), 16):
    rom_lines.append("        " + " ".join(entries[i:i+16]))

vhdl_text = """library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity image_rom_320x240 is
    port (
        clk   : in  std_logic;
        ce    : in  std_logic;
        x     : in  unsigned(8 downto 0);
        y     : in  unsigned(7 downto 0);
        pixel : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of image_rom_320x240 is
    constant IMG_W : integer := 320;
    constant IMG_H : integer := 240;
    type rom_t is array (0 to IMG_W*IMG_H-1) of std_logic_vector(7 downto 0);
    constant ROM : rom_t := (
"""

vhdl_text += "\n".join(rom_lines)

vhdl_text += """
    );
begin
    process(clk)
        variable addr : integer range 0 to IMG_W*IMG_H-1;
    begin
        if rising_edge(clk) then
            if ce = '1' then
                addr := to_integer(y) * IMG_W + to_integer(x);
                pixel <= ROM(addr);
            end if;
        end if;
    end process;
end architecture;
"""

out.write_text(vhdl_text, encoding="utf-8")
print(f"Wrote {out}")
print(f"ROM size: {len(pixels)} bytes = {len(pixels)*8/1024:.0f} Kbit "
      f"(~{len(pixels)*8/36864:.1f} RAMB36 blocks on Artix-7)")
