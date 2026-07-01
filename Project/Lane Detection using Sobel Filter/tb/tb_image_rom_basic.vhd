-- Module-level image ROM basic testbench
-- This checks that image_rom_160x120 returns the expected stored pixel values
-- for a few known x,y coordinates.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_image_rom_basic is
end entity;

architecture sim of tb_image_rom_basic is
    signal clk   : std_logic := '0';
    signal ce    : std_logic := '1';
    signal x     : unsigned(7 downto 0) := (others => '0');
    signal y     : unsigned(6 downto 0) := (others => '0');
    signal pixel : std_logic_vector(7 downto 0);
begin
    -- 100 MHz clock: 10 ns period
    clk <= not clk after 5 ns;

    uut : entity work.image_rom_160x120
        port map (
            clk   => clk,
            ce    => ce,
            x     => x,
            y     => y,
            pixel => pixel
        );

    stimulus : process
        procedure check_pixel(
            constant px       : integer;
            constant py       : integer;
            constant expected : std_logic_vector(7 downto 0)
        ) is
        begin
            x <= to_unsigned(px, 8);
            y <= to_unsigned(py, 7);
            ce <= '1';
            wait until rising_edge(clk);
            wait for 1 ns;

            assert pixel = expected
                report "FAILED: ROM pixel mismatch at x=" & integer'image(px) &
                       ", y=" & integer'image(py) &
                       ". Expected " & integer'image(to_integer(unsigned(expected))) &
                       ", got " & integer'image(to_integer(unsigned(pixel)))
                severity failure;
        end procedure;
    begin
        report "Starting image ROM basic coordinate test." severity note;

        -- Known values from the ROM table.
        -- First row starts: x36, x37, x39, ...
        check_pixel(0,   0, x"36");
        check_pixel(1,   0, x"37");
        check_pixel(2,   0, x"39");
        check_pixel(15,  0, x"40");

        -- Last value of first 160-pixel row.
        check_pixel(159, 0, x"26");

        -- First value of second row.
        check_pixel(0,   1, x"38");

        report "PASSED: image_rom_160x120 returned expected values for tested coordinates." severity note;
        wait;
    end process;
end architecture;
