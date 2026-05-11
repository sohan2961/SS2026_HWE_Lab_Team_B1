entity CR_add_sub is
    generic (
        N : integer := 4
    );
    port (
        A         : in  bit_vector(N-1 downto 0);
        B         : in  bit_vector(N-1 downto 0);
        CARRY_IN      : in  bit;  -- 0 = addition, 1 = subtraction
        RESULT    : out bit_vector(N-1 downto 0);
        CARRY_OUT : out bit
    );
end entity;

architecture Structural of CR_add_sub is

    component CR_adder is
        generic (
            N : integer := 4
        );
        port (
            A         : in  bit_vector(N-1 downto 0);
            B         : in  bit_vector(N-1 downto 0);
            CARRY_IN  : in  bit;
            SUM       : out bit_vector(N-1 downto 0);
            CARRY_OUT : out bit
        );
    end component;

    signal B_xor : bit_vector(N-1 downto 0);

begin

    -- If MODE = 0, B_xor = B
    -- If MODE = 1, B_xor = NOT B
    GEN_XOR : for i in 0 to N-1 generate
        B_xor(i) <= B(i) xor CARRY_IN;
    end generate;

    -- Ripple Carry Adder component
    RCA: CR_adder
        generic map (
            N => N
        )
        port map (
            A         => A,
            B         => B_xor,
            CARRY_IN  => CARRY_IN,
            SUM       => RESULT,
            CARRY_OUT => CARRY_OUT
        );

end Structural;
