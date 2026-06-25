library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Main file for the Nexys A7 ROM-based Sobel demo.
-- Only one switch is used now:
--   sw0 = '0'  -> show original road image
--   sw0 = '1'  -> show Sobel edge image
-- There is no reset button in this simplified version.
entity nexysA7_lane_rom_sobel_top is
    port (
        CLK100MHZ : in  std_logic;                    -- Nexys A7 100 MHz clock
        sw0       : in  std_logic;                    -- only switch used
        vgaRed    : out std_logic_vector(3 downto 0); -- VGA red
        vgaGreen  : out std_logic_vector(3 downto 0); -- VGA green
        vgaBlue   : out std_logic_vector(3 downto 0); -- VGA blue
        Hsync     : out std_logic;                    -- VGA horizontal sync
        Vsync     : out std_logic                     -- VGA vertical sync
    );
end entity;

architecture rtl of nexysA7_lane_rom_sobel_top is
    -- VGA timing signals.
    signal pixel_ce  : std_logic;              -- 1 pulse = process one pixel
    signal x         : unsigned(9 downto 0);   -- current VGA x position
    signal y         : unsigned(9 downto 0);   -- current VGA y position
    signal visible   : std_logic;              -- 1 only inside 640x480 area
    signal hs_timing : std_logic;
    signal vs_timing : std_logic;

    -- The ROM image is 160x120, but VGA is 640x480.
    -- So x/4 and y/4 are used as ROM coordinates.
    signal img_x : unsigned(7 downto 0);       -- 0 to 159
    signal img_y : unsigned(6 downto 0);       -- 0 to 119

    -- Pixel signals. All are 8-bit grayscale values.
    signal rom_pixel  : std_logic_vector(7 downto 0); -- pixel from image ROM
    signal edge_pixel : std_logic_vector(7 downto 0); -- Sobel result
    signal orig_pixel : std_logic_vector(7 downto 0); -- delayed original pixel
    signal video_gray : std_logic_vector(7 downto 0) := (others => '0');

    -- Sobel module also delays sync signals so they match the delayed pixels.
    signal de_sobel : std_logic;
    signal hs_sobel : std_logic;
    signal vs_sobel : std_logic;
begin
    -- VGA timing block: creates x, y, visible, Hsync, Vsync and pixel_ce.
    timing_inst : entity work.vga_timing_640x480
        port map (
            clk      => CLK100MHZ,
            pixel_ce => pixel_ce,
            x        => x,
            y        => y,
            visible  => visible,
            hsync    => hs_timing,
            vsync    => vs_timing
        );

    -- Convert 640x480 screen coordinate to 160x120 image coordinate.
    -- Taking bits 9 downto 2 is the same as integer divide by 4.
    img_x <= x(9 downto 2) when visible = '1' else (others => '0');
    img_y <= y(8 downto 2) when visible = '1' else (others => '0');

    -- Image ROM: gives one grayscale pixel from the stored road image.
    rom_inst : entity work.image_rom_160x120
        port map (
            clk   => CLK100MHZ,
            ce    => pixel_ce,
            x     => img_x,
            y     => img_y,
            pixel => rom_pixel
        );

    -- Sobel filter: receives the ROM pixel stream and creates edge pixels.
    sobel_inst : entity work.sobel3x3_simple
        generic map (
            LINE_WIDTH => 640
        )
        port map (
            clk          => CLK100MHZ,
            ce           => pixel_ce,
            pixel_in     => rom_pixel,
            de_in        => visible,
            hsync_in     => hs_timing,
            vsync_in     => vs_timing,
            edge_out     => edge_pixel,
            original_out => orig_pixel,
            de_out       => de_sobel,
            hsync_out    => hs_sobel,
            vsync_out    => vs_sobel
        );

    -- Final output selector.
    -- sw0 = 0 -> original image
    -- sw0 = 1 -> Sobel edge image
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if pixel_ce = '1' then
                if de_sobel = '0' then
                    video_gray <= (others => '0'); -- black outside visible area
                elsif sw0 = '0' then
                    video_gray <= orig_pixel;       -- original road image
                else
                    video_gray <= edge_pixel;       -- Sobel edge image
                end if;
            end if;
        end if;
    end process;

    -- VGA uses 4 bits per color.
    -- For grayscale, red = green = blue.
    vgaRed   <= video_gray(7 downto 4);
    vgaGreen <= video_gray(7 downto 4);
    vgaBlue  <= video_gray(7 downto 4);

    Hsync <= hs_sobel;
    Vsync <= vs_sobel;
end architecture;
