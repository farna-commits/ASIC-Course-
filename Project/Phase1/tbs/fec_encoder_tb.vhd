library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fec_tb is
end fec_tb;

architecture tb_arch of fec_tb is
    component states_FEC_encoder
        port(
            clk_50mhz, clk_100mhz                 : in    std_logic; 
            reset, rand_out_valid                 : in    std_logic; 
            tail_bits_in                          : in    std_logic_vector(5 downto 0); 
            data_in                               : in    std_logic; 
            x_output, y_output                    : out   std_logic; 
            FEC_encoder_out_valid                 : out   std_logic; 
            data_out                              : out   std_logic

        );
    end component;

    --constants 
    constant CLK_50_PERIOD         : Time := 20 ns; 
    constant CLK_50_HALF_PERIOD    : Time := CLK_50_PERIOD / 2; 
    constant CLK_100_PERIOD        : Time := 10 ns; 
    constant CLK_100_HALF_PERIOD   : Time := CLK_100_PERIOD / 2;
    --signals 
    signal clk_50               : std_logic := '0'; 
    signal clk_100              : std_logic := '1'; 
    signal reset                : std_logic; 
    signal en                   : std_logic; 
    signal test_in_vector       : std_logic_vector(95 downto 0) := x"558AC4A53A1724E163AC2BF9";
    signal test_out_vector      : std_logic_vector(191 downto 0) := x"000000000000000000000000000000000000000000000000";
    signal test_in_bit          : std_logic;
    signal test_out_bit         : std_logic;
    signal test_out_x           : std_logic;
    signal test_out_y           : std_logic;
    signal test_mk_out_bit      : std_logic;
    signal out_valid            : std_logic;
begin 

    --instant 
    uut: states_FEC_encoder port map (clk_50mhz => clk_50, clk_100mhz => clk_100, reset => reset, rand_out_valid => en, tail_bits_in => "000000", data_in => test_in_bit, x_output => test_out_x, y_output => test_out_y, FEC_encoder_out_valid => out_valid, data_out => test_out_bit);

    --clk process 
    clk_50 <= not clk_50 after CLK_50_HALF_PERIOD; 
    clk_100 <= not clk_100 after CLK_100_HALF_PERIOD; 

    --serial input in 
    process begin 
        reset   <= '1'; 
        wait for CLK_50_PERIOD + 10 ns; 
        reset   <= '0';
        en      <= '1';
        for i in 95 downto 0 loop 
            test_in_bit <= test_in_vector(i);
            wait for CLK_50_PERIOD; 
        end loop;
        wait;
    end process; 

    --check output 
    process begin 
        -- wait on out_valid; 
        -- wait for 1980 ns; 
        wait until out_valid = '1';
        wait for 2 ns;
        for i in 191 downto 0 loop 
            test_out_vector(i) <= test_out_bit; 
            wait for CLK_100_PERIOD; 
        end loop;
        wait;
    end process;
end tb_arch; 