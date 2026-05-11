entity CR_adder_tb is
end entity;
 
architecture Behavioral of CR_adder_tb is

component CR_adder is
        Generic ( N : integer := 4 );
        Port (
            A    : in  BIT_VECTOR(N-1 downto 0);
            B    : in  BIT_VECTOR(N-1 downto 0);
            CARRY_IN  : in  BIT;
            SUM    : out BIT_VECTOR(N-1 downto 0);
            CARRY_OUT : out BIT
        );
    end component;

    -- 4-bit signals
    constant N : integer := 4;

    signal A_tb         : bit_vector(N-1 downto 0);
    signal B_tb        : bit_vector(N-1 downto 0);
    signal CARRY_IN_tb  : bit;
    signal SUM_tb      : bit_vector(N-1 downto 0);
    signal CARRY_OUT_tb : bit;

begin

    DUT: CR_adder
        generic map (
            N => N
        )
        port map (
            A         => A_tb,
            B         => B_tb,
            CARRY_IN  => CARRY_IN_tb,
            SUM       => SUM_tb,
            CARRY_OUT => CARRY_OUT_tb
        );

    

-- Stimulus generation
    


    A_tb <= "0000",
            "0001" after 10 ns,
            "0011" after 20 ns,
            "0101" after 30 ns,
            "0111" after 40 ns,
            "1111" after 50 ns,
            "1111" after 60 ns,
            "0101" after 70 ns;

    B_tb <= "0000",
            "0001" after 10 ns,
            "0010" after 20 ns,
            "0011" after 30 ns,
            "0001" after 40 ns,
            "0001" after 50 ns,
            "1111" after 60 ns,
            "0011" after 70 ns;

    CARRY_IN_tb <= '0',
                   '0' after 10 ns,
                   '0' after 20 ns,
                   '0' after 30 ns,
                   '0' after 40 ns,
                   '0' after 50 ns,
                   '0' after 60 ns,
                   '1' after 70 ns;

end Behavioral;