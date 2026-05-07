entity half_subtractor_tb is
end entity;

architecture Behavioral of half_subtractor_tb is

    -- Component declaration
    component half_subtractor
        port (
            A      : in  bit;
            B      : in  bit;
            DIFF   : out bit;
            BORROW : out bit
        );
    end component;

    -- Signal declarations
    signal A_TB      : bit;
    signal B_TB      : bit;
    signal DIFF_TB   : bit;
    signal BORROW_TB : bit;

begin

    -- DUT instantiation
    DUT: half_subtractor
        port map (
            A      => A_TB,
            B      => B_TB,
            DIFF   => DIFF_TB,
            BORROW => BORROW_TB
        );

    -- Stimulus generation
    -- Covers all possible input combinations: 00, 01, 10, 11
    A_TB <= '0', '0' after 10 ns, '1' after 20 ns, '1' after 30 ns;
    B_TB <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns;

end architecture;
