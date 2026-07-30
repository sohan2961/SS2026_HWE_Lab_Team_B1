library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- VGA timing generator for 640x480 display.
-- Nexys A7 clock is 100 MHz.
-- This module creates a 25 MHz pixel enable by using one pulse every 4 clocks.
entity vga_timing_640x480 is
    port (
        clk      : in  std_logic;                  -- 100 MHz board clock
        pixel_ce : out std_logic;                  -- one-pixel enable pulse
        x        : out unsigned(9 downto 0);       -- current x position
        y        : out unsigned(9 downto 0);       -- current y position
        visible  : out std_logic;                  -- 1 inside visible 640x480 image
        hsync    : out std_logic;                  -- VGA horizontal sync
        vsync    : out std_logic                   -- VGA vertical sync
    );
end entity;

architecture rtl of vga_timing_640x480 is
    -- Standard 640x480 VGA timing numbers.
    constant H_VISIBLE : integer := 640;
    constant H_FRONT   : integer := 16;
    constant H_SYNC    : integer := 96;
    constant H_BACK    : integer := 48;
    constant H_TOTAL   : integer := H_VISIBLE + H_FRONT + H_SYNC + H_BACK; -- 800

    constant V_VISIBLE : integer := 480;
    constant V_FRONT   : integer := 10;
    constant V_SYNC    : integer := 2;
    constant V_BACK    : integer := 33;
    constant V_TOTAL   : integer := V_VISIBLE + V_FRONT + V_SYNC + V_BACK; -- 525

    -- div_cnt divides 100 MHz by 4.
    signal div_cnt : unsigned(1 downto 0) := (others => '0');
    signal ce_i    : std_logic := '0';

    -- h_cnt and v_cnt scan the monitor pixel by pixel.
    signal h_cnt   : integer range 0 to H_TOTAL-1 := 0;
    signal v_cnt   : integer range 0 to V_TOTAL-1 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            ce_i <= '0';

            -- Every 4 clock cycles, create one pixel_ce pulse.
            if div_cnt = "11" then
                div_cnt <= (others => '0');
                ce_i    <= '1';

                -- Move to the next pixel position.
                if h_cnt = H_TOTAL-1 then
                    h_cnt <= 0;

                    -- End of one row, so move to next row.
                    if v_cnt = V_TOTAL-1 then
                        v_cnt <= 0;
                    else
                        v_cnt <= v_cnt + 1;
                    end if;
                else
                    h_cnt <= h_cnt + 1;
                end if;
            else
                div_cnt <= div_cnt + 1;
            end if;
        end if;
    end process;

    pixel_ce <= ce_i;
    x        <= to_unsigned(h_cnt, 10);
    y        <= to_unsigned(v_cnt, 10);

    -- visible is 1 only for the actual 640x480 image area.
    visible <= '1' when (h_cnt < H_VISIBLE and v_cnt < V_VISIBLE) else '0';

    -- VGA sync signals are active low.
    hsync <= '0' when (h_cnt >= H_VISIBLE + H_FRONT and
                       h_cnt <  H_VISIBLE + H_FRONT + H_SYNC) else '1';

    vsync <= '0' when (v_cnt >= V_VISIBLE + V_FRONT and
                       v_cnt <  V_VISIBLE + V_FRONT + V_SYNC) else '1';
end architecture;
