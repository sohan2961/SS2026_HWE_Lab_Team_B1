-- Module-level Sobel golden-reference sanity testbench
-- This testbench checks the Sobel filter alone, not the full VGA top module.
-- It uses a small LINE_WIDTH = 3 and feeds a known vertical-edge pattern.
-- Expected result: the Sobel edge output should reach 255 for a strong edge.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_sobel3x3_golden is
end entity;

architecture sim of tb_sobel3x3_golden is
    signal clk          : std_logic := '0';
    signal ce           : std_logic := '1';
    signal pixel_in     : std_logic_vector(7 downto 0) := (others => '0');
    signal de_in        : std_logic := '1';
    signal hsync_in     : std_logic := '1';
    signal vsync_in     : std_logic := '1';
    signal edge_out     : std_logic_vector(7 downto 0);
    signal original_out : std_logic_vector(7 downto 0);
    signal de_out       : std_logic;
    signal hsync_out    : std_logic;
    signal vsync_out    : std_logic;

    signal edge_255_seen : boolean := false;
begin
    -- 100 MHz clock: 10 ns period
    clk <= not clk after 5 ns;

    -- Unit Under Test: Sobel module only
    uut : entity work.sobel3x3_simple
        generic map (
            LINE_WIDTH => 3
        )
        port map (
            clk          => clk,
            ce           => ce,
            pixel_in     => pixel_in,
            de_in        => de_in,
            hsync_in     => hsync_in,
            vsync_in     => vsync_in,
            edge_out     => edge_out,
            original_out => original_out,
            de_out       => de_out,
            hsync_out    => hsync_out,
            vsync_out    => vsync_out
        );

    -- Watch if Sobel output ever reaches 255 for a strong edge.
    monitor : process(clk)
    begin
        if rising_edge(clk) then
            if edge_out = x"FF" then
                edge_255_seen <= true;
            end if;
        end if;
    end process;

    stimulus : process
        procedure send_pixel(v : integer) is
        begin
            pixel_in <= std_logic_vector(to_unsigned(v, 8));
            wait until rising_edge(clk);
            wait for 1 ns;
        end procedure;
    begin
        report "Starting Sobel golden-reference sanity test." severity note;

        -- Test 1: flat black input should produce zero edge output after warm-up.
        de_in <= '1';
        ce <= '1';
        for i in 0 to 11 loop
            send_pixel(0);
        end loop;

        assert edge_out = x"00"
            report "FAILED: flat zero image should produce edge_out = 0."
            severity failure;

        report "Flat zero test passed." severity note;

        -- Test 2: vertical edge pattern.
        -- 3x3 window target:
        -- 0   0   255
        -- 0   0   255
        -- 0   0   255
        --
        -- gx = 1020, gy = 0, |gx| + |gy| = 1020, saturated to 255.
        -- Therefore edge_out should reach xFF.
        for row in 0 to 4 loop
            send_pixel(0);
            send_pixel(0);
            send_pixel(255);
        end loop;

        wait until rising_edge(clk);
        wait for 1 ns;

        assert edge_255_seen
            report "FAILED: vertical edge test did not produce edge_out = 255."
            severity failure;

        report "PASSED: Sobel module produced expected strong edge output for known vertical-edge input." severity note;
        wait;
    end process;
end architecture;
