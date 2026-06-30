library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 640x480 VGA timing using the 100 MHz Nexys A7 clock.
-- We create a 25 MHz pixel-enable pulse, not a second clock.
entity vga_timing_640x480 is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        pixel_ce : out std_logic;
        x        : out unsigned(9 downto 0);
        y        : out unsigned(9 downto 0);
        visible  : out std_logic;
        hsync    : out std_logic;
        vsync    : out std_logic
    );
end entity;

architecture rtl of vga_timing_640x480 is
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

    signal div_cnt : unsigned(1 downto 0) := (others => '0');
    signal ce_i    : std_logic := '0';
    signal h_cnt   : integer range 0 to H_TOTAL-1 := 0;
    signal v_cnt   : integer range 0 to V_TOTAL-1 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                div_cnt <= (others => '0');
                ce_i    <= '0';
                h_cnt   <= 0;
                v_cnt   <= 0;
            else
                ce_i <= '0';
                if div_cnt = "11" then
                    div_cnt <= (others => '0');
                    ce_i    <= '1';
                    if h_cnt = H_TOTAL-1 then
                        h_cnt <= 0;
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
        end if;
    end process;

    pixel_ce <= ce_i;
    x        <= to_unsigned(h_cnt, 10);
    y        <= to_unsigned(v_cnt, 10);
    visible  <= '1' when (h_cnt < H_VISIBLE and v_cnt < V_VISIBLE) else '0';

    -- Standard VGA sync signals are active low.
    hsync <= '0' when (h_cnt >= H_VISIBLE + H_FRONT and
                       h_cnt <  H_VISIBLE + H_FRONT + H_SYNC) else '1';

    vsync <= '0' when (v_cnt >= V_VISIBLE + V_FRONT and
                       v_cnt <  V_VISIBLE + V_FRONT + V_SYNC) else '1';
end architecture;
