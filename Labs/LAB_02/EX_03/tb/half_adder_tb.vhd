entity half_adder_tb is
end entity;

architecture Behavioral of half_adder_tb is

    -- Component declaration
    component half_adder
        port (
            A     : in  bit;
            B     : in  bit;
            SUM   : out bit;
            CARRY : out bit
        );
    end component;

    -- Signal declarations
    signal A_TB     : bit;
    signal B_TB     : bit;
    signal SUM_TB   : bit;
    signal CARRY_TB : bit;

begin

    -- DUT instantiation
    DUT: half_adder
        port map (
            A     => A_TB,
            B     => B_TB,
            SUM   => SUM_TB,
            CARRY => CARRY_TB
        );

    -- Stimulus generation
    -- Covers all possible input combinations: 00, 01, 10, 11
    A_TB <= '0', '0' after 10 ps, '1' after 20 ps, '1' after 30 ps;
    B_TB <= '0', '1' after 10 ps, '0' after 20 ps, '1' after 30 ps;

end Behavioral;