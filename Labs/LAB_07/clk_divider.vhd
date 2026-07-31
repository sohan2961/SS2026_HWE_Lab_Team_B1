library STANDARD;
use STANDARD.all;

entity clk_divider is
    generic (
        N : positive := 100_000_000
    );
    port (
        CLK   : in  bit;
        CLK_N : out bit
    );
end entity clk_divider;

architecture rtl of clk_divider is
    signal counter : natural range 0 to N - 1 := 0;
begin

    assert N >= 2
        report "N must be at least 2"
        severity failure;

    process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if counter = N - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    CLK_N <= '1' when counter < (N + 1) / 2 else '0';

end architecture rtl;
