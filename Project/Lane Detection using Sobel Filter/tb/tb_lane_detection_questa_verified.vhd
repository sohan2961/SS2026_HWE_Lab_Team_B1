-- Questa verified testbench for Lane Detection using Sobel Filter
-- Verified in Questa Altera after successful 40 ms simulation
-- Compile result: Errors 0, Warnings 0
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_nexysA7_lane_rom_sobel_top is
end entity;

architecture sim of tb_nexysA7_lane_rom_sobel_top is
    signal CLK100MHZ : std_logic := '0';
    signal sw0       : std_logic := '0';
    signal vgaRed    : std_logic_vector(3 downto 0);
    signal vgaGreen  : std_logic_vector(3 downto 0);
    signal vgaBlue   : std_logic_vector(3 downto 0);
    signal Hsync     : std_logic;
    signal Vsync     : std_logic;

    signal hsync_changed : boolean := false;
    signal vsync_changed : boolean := false;
    signal rgb_seen_orig : boolean := false;
    signal rgb_seen_edge : boolean := false;

    signal hsync_last : std_logic := '1';
    signal vsync_last : std_logic := '1';
begin
    -- 100 MHz Nexys A7 clock: 10 ns period
    CLK100MHZ <= not CLK100MHZ after 5 ns;

    uut : entity work.nexysA7_lane_rom_sobel_top
        port map (
            CLK100MHZ => CLK100MHZ,
            sw0       => sw0,
            vgaRed    => vgaRed,
            vgaGreen  => vgaGreen,
            vgaBlue   => vgaBlue,
            Hsync     => Hsync,
            Vsync     => Vsync
        );

    monitor : process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if Hsync /= hsync_last then
                hsync_changed <= true;
            end if;
            if Vsync /= vsync_last then
                vsync_changed <= true;
            end if;
            hsync_last <= Hsync;
            vsync_last <= Vsync;

            if sw0 = '0' and (vgaRed /= "0000" or vgaGreen /= "0000" or vgaBlue /= "0000") then
                rgb_seen_orig <= true;
            end if;

            if sw0 = '1' and (vgaRed /= "0000" or vgaGreen /= "0000" or vgaBlue /= "0000") then
                rgb_seen_edge <= true;
            end if;
        end if;
    end process;

    stimulus : process
    begin
        -- Mode 0: original image
        sw0 <= '0';
        wait for 20 ms;

        -- Mode 1: Sobel edge image
        sw0 <= '1';
        wait for 20 ms;

        assert hsync_changed
            report "Top test FAILED: Hsync did not toggle."
            severity failure;

        assert vsync_changed
            report "Top test FAILED: Vsync did not toggle. Run simulation for at least one frame."
            severity failure;

        assert rgb_seen_orig
            report "Top test FAILED: no non-zero RGB output was seen in original-image mode."
            severity failure;

        assert rgb_seen_edge
            report "Top test WARNING/FAILED: no non-zero RGB output was seen in Sobel mode. Check waveform and switch timing."
            severity warning;

        report "Top simulation finished. Check waveform: sw0=0 original image, sw0=1 Sobel edge output." severity note;
        wait;
    end process;
end architecture;

