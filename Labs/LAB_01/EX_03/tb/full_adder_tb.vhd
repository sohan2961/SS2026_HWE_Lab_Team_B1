entity full_adder_tb is
end entity;

architecture Behavioral of full_adder_tb is

    -- Component declaration
    component full_adder
        port (
            A     : in  bit;
            B     : in  bit;
            CIN   : in  bit;
            SUM   : out bit;
            CARRY : out bit
        );
    end component;

    -- Signal declaratiops
    signal A_TB     : bit;
    signal B_TB     : bit;
    signal CIN_TB   : bit;
    signal SUM_TB   : bit;
    signal CARRY_TB : bit;

begin

    -- DUT ipstantiation
    DUT: full_adder
        port map (
            A     => A_TB,
            B     => B_TB,
            CIN   => CIN_TB,
            SUM   => SUM_TB,
            CARRY => CARRY_TB
        );

    -- Stimulus generation
    
A_TB <= '0',
            '0' after 10 ns,
            '0' after 20 ns,
            '0' after 30 ns,
            '1' after 40 ns,
            '1' after 50 ns,
            '1' after 60 ns,
            '1' after 70 ns;
 
    B_TB <= '0',
            '0' after 10 ns,
            '1' after 20 ns,
            '1' after 30 ns,
            '0' after 40 ns,
            '0' after 50 ns,
            '1' after 60 ns,
            '1' after 70 ns;
 
    CIN_TB <= '0',
              '1' after 10 ns,
              '0' after 20 ns,
              '1' after 30 ns,
              '0' after 40 ns,
              '1' after 50 ns,
              '0' after 60 ns,
              '1' after 70 ns;

end Behavioral;
