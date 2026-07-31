library STANDARD;
use STANDARD.all;

entity clk_divider_tb is
end entity clk_divider_tb;

architecture testbench of clk_divider_tb is

    constant N_TEST : positive := 4;

    signal CLK   : bit := '0';
    signal CLK_N : bit;

begin

    DUT : entity work.clk_divider(rtl)
        generic map (
            N => N_TEST
        )
        port map (
            CLK   => CLK,
            CLK_N => CLK_N
        );

    clock_generation : process
    begin
        while now < 200 ns loop
            CLK <= '0';
            wait for 5 ns;
            CLK <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    verification : process
        variable first_rising_edge : time;
    begin
        wait for 1 ns;
        assert CLK_N = '1'
            report "Error: CLK_N should initially be high"
            severity error;

        wait until CLK'event and CLK = '1';
        wait for 1 ns;
        assert CLK_N = '1'
            report "Error after first CLK rising edge"
            severity error;

        wait until CLK'event and CLK = '1';
        wait for 1 ns;
        assert CLK_N = '0'
            report "Error after second CLK rising edge"
            severity error;

        wait until CLK'event and CLK = '1';
        wait for 1 ns;
        assert CLK_N = '0'
            report "Error after third CLK rising edge"
            severity error;

        wait until CLK'event and CLK = '1';
        wait for 1 ns;
        assert CLK_N = '1'
            report "Error after fourth CLK rising edge"
            severity error;

        wait until CLK_N'event and CLK_N = '1';
        first_rising_edge := now;

        wait until CLK_N'event and CLK_N = '1';
        assert now - first_rising_edge = 40 ns
            report "Error: output period is not N times the input period"
            severity error;

        assert false
            report "clk_divider_tb completed successfully"
            severity note;

        wait;
    end process;

end architecture testbench;
