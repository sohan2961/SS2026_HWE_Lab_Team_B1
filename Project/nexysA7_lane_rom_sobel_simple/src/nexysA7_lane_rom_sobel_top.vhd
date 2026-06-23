library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top file for Nexys A7 lane detection demo.
-- SW0 = 0: show original road image.
-- SW0 = 1: show Sobel edge/lane output.
-- SW1 = 1: threshold Sobel output to black/white.
-- BTNC: reset.
entity nexysA7_lane_rom_sobel_top is
    port (
        CLK100MHZ : in  std_logic;
        btnC      : in  std_logic;
        sw        : in  std_logic_vector(1 downto 0);
        vgaRed    : out std_logic_vector(3 downto 0);
        vgaGreen  : out std_logic_vector(3 downto 0);
        vgaBlue   : out std_logic_vector(3 downto 0);
        Hsync     : out std_logic;
        Vsync     : out std_logic
    );
end entity;

architecture rtl of nexysA7_lane_rom_sobel_top is
    signal rst       : std_logic;
    signal pixel_ce  : std_logic;
    signal x         : unsigned(9 downto 0);
    signal y         : unsigned(9 downto 0);
    signal visible   : std_logic;
    signal hs_timing : std_logic;
    signal vs_timing : std_logic;

    -- The stored image is 160x120. VGA is 640x480.
    -- Dividing x and y by 4 scales the image to full VGA size.
    signal img_x : unsigned(7 downto 0);
    signal img_y : unsigned(6 downto 0);

    signal rom_pixel  : std_logic_vector(7 downto 0);
    signal edge_pixel : std_logic_vector(7 downto 0);
    signal orig_pixel : std_logic_vector(7 downto 0);
    signal video_gray : std_logic_vector(7 downto 0) := (others => '0');

    signal de_sobel : std_logic;
    signal hs_sobel : std_logic;
    signal vs_sobel : std_logic;
begin
    rst <= btnC;

    timing_inst : entity work.vga_timing_640x480
        port map (
            clk      => CLK100MHZ,
            rst      => rst,
            pixel_ce => pixel_ce,
            x        => x,
            y        => y,
            visible  => visible,
            hsync    => hs_timing,
            vsync    => vs_timing
        );

    -- Protect the ROM address during VGA blanking.
    img_x <= x(9 downto 2) when visible = '1' else (others => '0');
    img_y <= y(8 downto 2) when visible = '1' else (others => '0');

    rom_inst : entity work.image_rom_160x120
        port map (
            clk   => CLK100MHZ,
            ce    => pixel_ce,
            x     => img_x,
            y     => img_y,
            pixel => rom_pixel
        );

    sobel_inst : entity work.sobel3x3_simple
        generic map (
            LINE_WIDTH => 640
        )
        port map (
            clk          => CLK100MHZ,
            rst          => rst,
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

    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if rst = '1' then
                video_gray <= (others => '0');
            elsif pixel_ce = '1' then
                if de_sobel = '0' then
                    video_gray <= (others => '0');
                elsif sw(0) = '0' then
                    video_gray <= orig_pixel;
                else
                    if sw(1) = '1' then
                        -- Threshold mode: cleaner black/white edge result.
                        if unsigned(edge_pixel) > 55 then
                            video_gray <= x"FF";
                        else
                            video_gray <= x"00";
                        end if;
                    else
                        -- Normal Sobel mode: edge strength as brightness.
                        video_gray <= edge_pixel;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- VGA connector uses 4 bits per color. We use grayscale, so R=G=B.
    vgaRed   <= video_gray(7 downto 4);
    vgaGreen <= video_gray(7 downto 4);
    vgaBlue  <= video_gray(7 downto 4);

    Hsync <= hs_sobel;
    Vsync <= vs_sobel;
end architecture;
