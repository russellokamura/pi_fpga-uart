---------------------------------------------------------------------------
-- File: uart_receiver.vhd
---------------------------------------------------------------------------
-- Written By: russellokamura
-- Date Created: November 07, 2020
--
-- Description: 
--    This file contains the UART Receiver.  It will read data bytes from
--       the RX line, following a 8-n-1 UART protocol.  When a byte has 
--       successfully been received, o_rx_valid will be driven high for one 
--       clock cycle.  
--
--    g_CLK_TCKS_PER_BIT should be set based on the baudrate given the 
--       equation below:
--       g_CLK_TCKS_PER_BIT = i_clk_f / baudrate
--
--       where i_clk_f is the frequency of the clk on i_clk
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_receiver is 
   generic (
      g_CLK_TCKS_PER_BIT : integer := 115;                 -- Based on baudrate
   )
   port (
      i_clk : in std_logic;
      i_rx : in std_logic;
      o_rx_byte : out std_logic_vector(7 downto 0);
      o_rx_valid : out std_logic
   );
end uart_receiver;

architecture rtl of uart_receiver is 

   type t_state is (s_IDLE, s_START, s_DATA, s_STOP, s_CLEANUP);
   
   signal r_state : t_state := s_IDLE;

   signal r_rx_meta : std_logic := '0';
   signal r_rx : std_logic := '0';

   signal r_clk_tck_counter : integer range 0 to g_CLK_TCKS_PER_BIT-1 := 0;
   signal r_bit_index : integer range 0 to 7 := 0;
   signal r_rx_byte : std_logic_vector(7 downto 0) := (others => '0');
   signal r_rx_valid : 
