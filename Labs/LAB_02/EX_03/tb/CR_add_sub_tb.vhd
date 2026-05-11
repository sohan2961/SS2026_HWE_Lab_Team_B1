entity CR_add_sub_tb is
end entity;

architecture Behavioral of CR_add_sub_tb is

    constant N : integer := 4;

    component CR_add_sub is
        generic (
            N : integer := 4
        );
        port (
            A         : in  bit_vector(N-1 downto 0);
            B         : in  bit_vector(N-1 downto 0);
            CARRY_IN      : in  bit;
            RESULT    : out bit_vector(N-1 downto 0);
            CARRY_OUT : out bit
        );
    end component;

    signal A_tb         : bit_vector(N-1 downto 0);
    signal B_tb         : bit_vector(N-1 downto 0);
    signal CARRY_IN_tb      : bit;
    signal RESULT_tb    : bit_vector(N-1 downto 0);
    signal CARRY_OUT_tb : bit;

begin

    DUT: CR_add_sub
        generic map (
            N => N
        )
        port map (
            A         => A_tb,
            B         => B_tb,
            CARRY_IN      => CARRY_IN_tb,
            RESULT    => RESULT_tb,
            CARRY_OUT => CARRY_OUT_tb
        );

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
                   '1' after 40 ns,
                   '1' after 50 ns,
                   '1' after 60 ns,
                   '1' after 70 ns;


end Behavioral;