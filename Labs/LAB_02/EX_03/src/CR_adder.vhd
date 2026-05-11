entity CR_adder is
    Generic (
        N : integer := 4    -- Bit width; change here or via generic map
    );
    Port (
        A    : in  BIT_VECTOR(N-1 downto 0);
        B    : in  BIT_VECTOR(N-1 downto 0);
        CARRY_IN  : in  BIT;
        SUM    : out BIT_VECTOR(N-1 downto 0);
        CARRY_OUT : out BIT
    );
end entity;
 
architecture Structural of CR_adder is
 
    component full_adder is
        Port (
            A    : in  BIT;
            B    : in  BIT;
            CARRY_IN  : in  BIT;
            SUM    : out BIT;
            CARRY_OUT : out BIT
        );
    end component;
 
    -- Internal carry chain: carry(0) = Cin, carry(N) = Cout
    signal CARRY : BIT_VECTOR(N downto 0);
 
begin
 
    -- Connect external Cin to first carry slot
    CARRY(0) <= CARRY_IN;
 
    -- Generate N full adder stages (bit 0 = LSB, bit N-1 = MSB)
    GEN_FA : for i in 0 to N-1 generate
        FA_i : full_adder
            Port Map (
                A    => A(i),
                B    => B(i),
                CARRY_IN  => CARRY(i),
                SUM    => SUM(i),
                CARRY_OUT => CARRY(i+1)
            );
    end generate GEN_FA;
 
    -- Final carry out
    CARRY_OUT <= CARRY(N);
 
end Structural;
