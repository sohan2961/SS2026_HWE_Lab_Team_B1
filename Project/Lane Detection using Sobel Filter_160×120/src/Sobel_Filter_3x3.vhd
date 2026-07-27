library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Simple streaming 3x3 Sobel filter for grayscale video.
-- Input:  one pixel at a time.
-- Output: edge strength for that pixel.
entity sobel3x3_simple is
    generic (
        LINE_WIDTH : integer := 640               -- VGA line width
    );
    port (
        clk          : in  std_logic;             -- 100 MHz clock
        ce           : in  std_logic;             -- process only when ce = 1
        pixel_in     : in  std_logic_vector(7 downto 0); -- input grayscale pixel
        de_in        : in  std_logic;             -- visible-area signal
        hsync_in     : in  std_logic;             -- VGA Hsync input
        vsync_in     : in  std_logic;             -- VGA Vsync input
        edge_out     : out std_logic_vector(7 downto 0); -- Sobel result
        original_out : out std_logic_vector(7 downto 0); -- delayed original pixel
        de_out       : out std_logic;             -- delayed visible signal
        hsync_out    : out std_logic;             -- delayed Hsync
        vsync_out    : out std_logic              -- delayed Vsync
    );
end entity;

architecture rtl of sobel3x3_simple is
    -- One line memory stores one full row of pixels.
    type line_t is array (0 to LINE_WIDTH-1) of std_logic_vector(7 downto 0);

    -- Sobel needs 3 rows, so we store the previous two rows.
    signal line1 : line_t := (others => (others => '0')); -- previous row
    signal line2 : line_t := (others => (others => '0')); -- two rows before

    -- Ask Vivado to use block RAM for these line buffers if possible.
    attribute ram_style : string;
    attribute ram_style of line1 : signal is "block";
    attribute ram_style of line2 : signal is "block";

    -- Current x-position inside the line buffer.
    signal wr_addr : integer range 0 to LINE_WIDTH-1 := 0;

    -- The 3x3 Sobel window:
    -- top_l top_c top_r
    -- mid_l mid_c mid_r
    -- bot_l bot_c bot_r
    signal top_l, top_c, top_r : std_logic_vector(7 downto 0) := (others => '0');
    signal mid_l, mid_c, mid_r : std_logic_vector(7 downto 0) := (others => '0');
    signal bot_l, bot_c, bot_r : std_logic_vector(7 downto 0) := (others => '0');

    -- Small delay for VGA control signals.
    type sl_pipe_t is array (0 to 3) of std_logic;
    signal de_pipe : sl_pipe_t := (others => '0');
    signal hs_pipe : sl_pipe_t := (others => '1');
    signal vs_pipe : sl_pipe_t := (others => '1');

    -- Absolute value function.
    function abs_int(a : integer) return integer is
    begin
        if a < 0 then
            return -a;
        else
            return a;
        end if;
    end function;

    -- Limit a number to 8-bit pixel range: 0 to 255.
    function sat8(a : integer) return std_logic_vector is
        variable v : integer;
    begin
        v := a;
        if v < 0 then
            v := 0;
        elsif v > 255 then
            v := 255;
        end if;
        return std_logic_vector(to_unsigned(v, 8));
    end function;
begin
    process(clk)
        variable old1 : std_logic_vector(7 downto 0); -- previous-row pixel
        variable old2 : std_logic_vector(7 downto 0); -- two-rows-before pixel
        variable p00, p01, p02 : integer;
        variable p10, p11, p12 : integer;
        variable p20, p21, p22 : integer;
        variable gx, gy, mag   : integer;
    begin
        if rising_edge(clk) then
            if ce = '1' then
                -- Convert the current 3x3 window from bits to numbers.
                p00 := to_integer(unsigned(top_l));
                p01 := to_integer(unsigned(top_c));
                p02 := to_integer(unsigned(top_r));
                p10 := to_integer(unsigned(mid_l));
                p11 := to_integer(unsigned(mid_c));
                p12 := to_integer(unsigned(mid_r));
                p20 := to_integer(unsigned(bot_l));
                p21 := to_integer(unsigned(bot_c));
                p22 := to_integer(unsigned(bot_r));

                -- Sobel calculation.
                -- gx finds left-right brightness change.
                -- gy finds top-bottom brightness change.
                gx := -p00 + p02 - (2*p10) + (2*p12) - p20 + p22;
                gy :=  p00 + (2*p01) + p02 - p20 - (2*p21) - p22;

                -- Approximate edge strength.
                mag := abs_int(gx) + abs_int(gy);

                -- Output Sobel edge and delayed original center pixel.
                edge_out     <= sat8(mag);
                original_out <= std_logic_vector(to_unsigned(p11, 8));

                -- Read old pixels from the two stored rows.
                old1 := line1(wr_addr);
                old2 := line2(wr_addr);

                if de_in = '1' then
                    -- Store the current pixel into line1.
                    -- Move the old line1 pixel into line2.
                    line1(wr_addr) <= pixel_in;
                    line2(wr_addr) <= old1;

                    -- Move line-buffer address to next x-position.
                    if wr_addr = LINE_WIDTH-1 then
                        wr_addr <= 0;
                    else
                        wr_addr <= wr_addr + 1;
                    end if;

                    -- Shift the 3x3 window left and insert a new right column.
                    top_l <= top_c; top_c <= top_r; top_r <= old2;
                    mid_l <= mid_c; mid_c <= mid_r; mid_r <= old1;
                    bot_l <= bot_c; bot_c <= bot_r; bot_r <= pixel_in;
                else
                    -- Outside visible area, start clean for next visible row.
                    wr_addr <= 0;
                    top_l <= (others => '0'); top_c <= (others => '0'); top_r <= (others => '0');
                    mid_l <= (others => '0'); mid_c <= (others => '0'); mid_r <= (others => '0');
                    bot_l <= (others => '0'); bot_c <= (others => '0'); bot_r <= (others => '0');
                end if;

                -- Delay visible/Hsync/Vsync so they match the delayed pixel output.
                de_pipe(0) <= de_in;
                hs_pipe(0) <= hsync_in;
                vs_pipe(0) <= vsync_in;
                for i in 1 to 3 loop
                    de_pipe(i) <= de_pipe(i-1);
                    hs_pipe(i) <= hs_pipe(i-1);
                    vs_pipe(i) <= vs_pipe(i-1);
                end loop;

                de_out    <= de_pipe(3);
                hsync_out <= hs_pipe(3);
                vsync_out <= vs_pipe(3);
            end if;
        end if;
    end process;
end architecture;
