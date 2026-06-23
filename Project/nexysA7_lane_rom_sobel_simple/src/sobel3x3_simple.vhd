library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Simple streaming 3x3 Sobel filter for 8-bit grayscale video.
-- The module receives one pixel at a time and outputs edge strength.
entity sobel3x3_simple is
    generic (
        LINE_WIDTH : integer := 640
    );
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        ce           : in  std_logic;
        pixel_in     : in  std_logic_vector(7 downto 0);
        de_in        : in  std_logic;
        hsync_in     : in  std_logic;
        vsync_in     : in  std_logic;
        edge_out     : out std_logic_vector(7 downto 0);
        original_out : out std_logic_vector(7 downto 0);
        de_out       : out std_logic;
        hsync_out    : out std_logic;
        vsync_out    : out std_logic
    );
end entity;

architecture rtl of sobel3x3_simple is
    type line_t is array (0 to LINE_WIDTH-1) of std_logic_vector(7 downto 0);

    signal line1 : line_t := (others => (others => '0'));
    signal line2 : line_t := (others => (others => '0'));

    attribute ram_style : string;
    attribute ram_style of line1 : signal is "block";
    attribute ram_style of line2 : signal is "block";

    signal wr_addr : integer range 0 to LINE_WIDTH-1 := 0;

    -- 3x3 window:
    -- top_l top_c top_r
    -- mid_l mid_c mid_r
    -- bot_l bot_c bot_r
    signal top_l, top_c, top_r : std_logic_vector(7 downto 0) := (others => '0');
    signal mid_l, mid_c, mid_r : std_logic_vector(7 downto 0) := (others => '0');
    signal bot_l, bot_c, bot_r : std_logic_vector(7 downto 0) := (others => '0');

    type sl_pipe_t is array (0 to 3) of std_logic;
    signal de_pipe : sl_pipe_t := (others => '0');
    signal hs_pipe : sl_pipe_t := (others => '1');
    signal vs_pipe : sl_pipe_t := (others => '1');

    function abs_int(a : integer) return integer is
    begin
        if a < 0 then
            return -a;
        else
            return a;
        end if;
    end function;

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
        variable old1 : std_logic_vector(7 downto 0);
        variable old2 : std_logic_vector(7 downto 0);
        variable p00, p01, p02 : integer;
        variable p10, p11, p12 : integer;
        variable p20, p21, p22 : integer;
        variable gx, gy, mag   : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                wr_addr <= 0;
                top_l <= (others => '0'); top_c <= (others => '0'); top_r <= (others => '0');
                mid_l <= (others => '0'); mid_c <= (others => '0'); mid_r <= (others => '0');
                bot_l <= (others => '0'); bot_c <= (others => '0'); bot_r <= (others => '0');
                edge_out     <= (others => '0');
                original_out <= (others => '0');
                de_pipe <= (others => '0');
                hs_pipe <= (others => '1');
                vs_pipe <= (others => '1');
                de_out    <= '0';
                hsync_out <= '1';
                vsync_out <= '1';
            elsif ce = '1' then
                -- Calculate Sobel magnitude from the current 3x3 window.
                p00 := to_integer(unsigned(top_l));
                p01 := to_integer(unsigned(top_c));
                p02 := to_integer(unsigned(top_r));
                p10 := to_integer(unsigned(mid_l));
                p11 := to_integer(unsigned(mid_c));
                p12 := to_integer(unsigned(mid_r));
                p20 := to_integer(unsigned(bot_l));
                p21 := to_integer(unsigned(bot_c));
                p22 := to_integer(unsigned(bot_r));

                gx := -p00 + p02 - (2*p10) + (2*p12) - p20 + p22;
                gy :=  p00 + (2*p01) + p02 - p20 - (2*p21) - p22;
                mag := abs_int(gx) + abs_int(gy);

                edge_out     <= sat8(mag);
                original_out <= std_logic_vector(to_unsigned(p11, 8));

                -- Read previous two lines at the current x-position.
                old1 := line1(wr_addr);
                old2 := line2(wr_addr);

                if de_in = '1' then
                    -- Store current pixel and move previous-line data down by one line.
                    line1(wr_addr) <= pixel_in;
                    line2(wr_addr) <= old1;

                    if wr_addr = LINE_WIDTH-1 then
                        wr_addr <= 0;
                    else
                        wr_addr <= wr_addr + 1;
                    end if;

                    -- Shift the 3x3 window horizontally and insert the new right column.
                    top_l <= top_c; top_c <= top_r; top_r <= old2;
                    mid_l <= mid_c; mid_c <= mid_r; mid_r <= old1;
                    bot_l <= bot_c; bot_c <= bot_r; bot_r <= pixel_in;
                else
                    -- During VGA blanking, restart at the first pixel of the next visible line.
                    wr_addr <= 0;
                    top_l <= (others => '0'); top_c <= (others => '0'); top_r <= (others => '0');
                    mid_l <= (others => '0'); mid_c <= (others => '0'); mid_r <= (others => '0');
                    bot_l <= (others => '0'); bot_c <= (others => '0'); bot_r <= (others => '0');
                end if;

                -- Small delay for sync and data-enable signals.
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
