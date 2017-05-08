-------------------------------------------------------------------------------
-- Title      : ALPIDE Control Interface BFM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : alpide_bfm_pkg.vhd
-- Author     : Ola Slettevoll Groettvik <Ola.Grottvik@student.uib.no>
-- Company    : 
-- Created    : 2016-09-08
-- Last update: 2017-05-08
-- Platform   : 
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description:
--! @file
--! @brief Bus functional model for ALPIDE4 Control Interface
--! @author Ola Slettevoll Groettvik <Ola.Grottvik@student.uib.no>
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-09-08  1.0      ogr043  Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Bitvis
library uvvm_util;
--context uvvm_util.uvvm_util_context;

package alpide_bfm_pkg is

  -----------------------------------------------------------------------------
  -- Types and constants for ALPIDE Control Interface BFM
  -----------------------------------------------------------------------------

  constant C_SCOPE         : string  := "ALPIDE BFM";
  constant C_ADDR_LENGTH   : natural := 16;
  constant C_CHIPID_LENGTH : natural := 7;

  
  --! Configuration record to be assigned in the test harness.
  type t_alpide_bfm_config is
  record
    max_wait_cycles          : integer;
    max_wait_cycles_severity : t_alert_level;
    clock_period             : time;
    id_for_bfm               : t_msg_id;
    id_for_bfm_wait          : t_msg_id;
    id_for_bfm_poll          : t_msg_id;
  end record;
  
  --! ALPIDE Control Interface
  type t_alpide_if is record            
    rst_n   : std_logic;                    -- Active low
    dctrl   : std_logic;                    -- DCTRL To ALPIDE
    chipid  : std_logic_vector(6 downto 0); -- CHIP ID
    drive   : std_logic;                    -- High if test is driving dctrl
    reading : std_logic;                    -- High when ALPIDE is driving dctrl
  end record t_alpide_if;

  constant C_ALPIDE_BFM_CONFIG_DEFAULT : t_alpide_bfm_config := (
    max_wait_cycles          => 100,
    max_wait_cycles_severity => failure,
    clock_period             => 25 ns,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL
    );


  -----------------------------------------------------------------------------
  -- TODO Configuration
  -----------------------------------------------------------------------------

  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  -------------------------------------------------------------------------------
  -- WRITE
  -------------------------------------------------------------------------------

  --! @brief Write to all chips connected to slow control
  --! @details Grabs control over bus then sends opcode, multicast ID, reg addr
  --! H and L, and data H and L. Sends random gap between each word.
  procedure alpide_multicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @overload alpide_multicast_write
  procedure alpide_multicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;    -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;  -- Interface
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );
  
  --! @brief Write to single chip by employing chip ID
  --! @details Grabs control over bus, then sends opcode, chip id, reg addr H
  --! and L, and data H and L. Sends random gap between each word.
  procedure alpide_unicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant chipid       : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @overload alpide_unicast_write
  procedure alpide_unicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant chipid       : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );
  
  --! @brief Sends global reset command to all chips
  --! @details Graps control over bus and sends GRST opcode. Ends with random gap.
  procedure alpide_broadcast_grst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @overload alpide_broadcast_grst
  procedure alpide_broadcast_grst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Sends pixel matrix reset to all chips
  --! @details Graps control over bus and sends PRST opcode. Ends with random gap.
  procedure alpide_broadcast_prst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @overload alpide_broadcast_prst
  procedure alpide_broadcast_prst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Sends pixel matrix pulse to all chips
  --! @details Grabs control over bus and sends PULSE opcode. Ends with random
  --! gap.
  procedure alpide_broadcast_pulse (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @overload alpide_broadcast_pulse
  procedure alpide_broadcast_pulse (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Sends bunch counter reset to all chips
  --! @details Grapbs control over bus and sends BCRST opcode. Ends with random
  --! gap.
  procedure alpide_broadcast_bcrst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @overload alpide_broadcast_bcrst
  procedure alpide_broadcast_bcrst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Sends readout (RRU/TRU/DMU) reset
  --! @details Grabs control over bus and sends RORST opcode. Ends with random
  --! gap.
  procedure alpide_broadcast_rorst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @overload
  procedure alpide_broadcast_rorst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Samples state in shadow registers on ALPIDEs
  --! @details Grabs control ocer bus and sends DEBUG opcode. Ends with random
  --! gap.
  procedure alpide_broadcast_debug (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );
  
  --! @overload
  procedure alpide_broadcast_debug (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );



  -----------------------------------------------------------------------------
  -- READ
  -----------------------------------------------------------------------------

  --! @brief Reads data from a specific ALPIDE chip
  --! @details Grabs control over bus and sends RDOP opcode. The chip ID, reg
  --! addr L and H is transmitted with random gaps between each word. The bus
  --! is turnaround before receiving the chip id and the data. The bus is then
  --! turnaround once again 
  procedure alpide_unicast_read (
    constant reg_addr     : in    unsigned;
    variable data         : out   std_logic_vector(15 downto 0);
    constant chipid_in    : in    unsigned;
    variable chipid_out   : out   std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal dctrl          : inout std_logic;
    signal dctrl_in       : in    std_logic;
    signal drive          : inout std_logic;
    signal reading        : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string              := "alpide_unicast_read");

  --! @overload
  procedure alpide_unicast_read (
    constant reg_addr     : in    unsigned;
    variable data         : out   std_logic_vector(15 downto 0);
    constant chipid_in    : in    unsigned;
    variable chipid_out   : out   std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal alpide_if      : inout t_alpide_if;
    signal dctrl_in       : in    std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT);

  -----------------------------------------------------------------------------
  -- CHECK
  -----------------------------------------------------------------------------
  --! @brief Uses alpide_unicast_read and then compares the received data with
  --! the input
  procedure alpide_check (
    constant reg_addr     : in    unsigned;
    constant data_exp     : in    std_logic_vector(15 downto 0);
    constant alert_level  : in    t_alert_level       := error;
    constant chipid_exp   : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal dctrl          : inout std_logic;
    signal dctrl_in       : in    std_logic;
    signal drive          : inout std_logic;
    signal reading        : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string              := "alpide_check"
    );

  --! @overload
  procedure alpide_check (
    constant reg_addr     : in    unsigned;
    constant data_exp     : in    std_logic_vector(15 downto 0);
    constant chipid_exp   : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal alpide_if      : inout t_alpide_if;
    signal dctrl_in       : in    std_logic;
    constant alert_level  : in    t_alert_level       := error;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT);


  -----------------------------------------------------------------------------
  -- SUPPORT PROCEDURES
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- send character
  -----------------------------------------------------------------------------
  --! @brief Sends a 8-bit character on DCTRL
  --! @details Grabs the bus, waits for 1/4 clock period after rising edge, and then
  --! asserts data bits every clock cycle. Then releases bus.
  procedure send_char (
    constant payload : in    std_logic_vector(7 downto 0);
    signal clk       : in    std_logic;
    signal dctrl     : inout std_logic;
    signal drive     : inout std_logic;
    constant config  :       t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  -----------------------------------------------------------------------------
  -- Send 
  -----------------------------------------------------------------------------
  --! Assert the reset signal for time_reset. Wait for time_idle for deasserting.
  procedure send_reset (
    constant time_reset   : in    natural;
    constant time_idle    : in    natural;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal rst_n          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       :       t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! Grab the bus for 1 clock cycle
  procedure send_gap (
    constant number : in    natural;
    signal clk      : in    std_logic;
    signal dctrl    : inout std_logic;
    signal drive    : inout std_logic;
    constant config : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! Grab the bus between min and max clock cycles
  procedure send_random_gap (
    constant min    : in    natural;
    constant max    : in    natural;
    signal clk      : in    std_logic;
    signal dctrl    : inout std_logic;
    signal drive    : inout std_logic;
    constant config : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Gives the bus control to/from the ALPIDE
  --! @details When giving the control to ALPIDE: take control of the bus for 5
  --! clock cycles, deassert the drive signal, assert the read signal. Chooses
  --! sampling point. Checks that chip drives the bus and wait for 5 clock cycles.
  --! When taking the control back from ALPIDE: deassert the reading signal and
  --! wait for 5 clock cycles. Assert the drive signal and wait for 5 clock cycles.
  procedure bus_turnaround (
    constant ctrl_to_alpide : in    boolean;
    signal clk              : in    std_logic;
    signal dctrl            : inout std_logic;
    signal dctrl_in         : in    std_logic;
    signal drive            : inout std_logic;
    signal reading          : inout std_logic;
    constant scope          : in    string              := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config         : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Receive a 8-bit character on DCTRL
  --! @details Wait until rising_edge, check if dctrl_in is START_BIT.
  --! Otherwise loop until this occurs. Then wait for 1 clock period and sample
  --! dctrl_in 8 times while shifting the data into variable. Confirm that last
  --! bit is STOP_BIT. 
  procedure receive_char (
    variable data_rec     : out std_logic_vector(7 downto 0);
    signal clk            : in  std_logic;
    signal dctrl_in       : in  std_logic;
    constant scope        : in  string              := C_SCOPE;
    constant msg_id_panel : in  t_msg_id_panel      := shared_msg_id_panel;
    constant config       :     t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );

  --! @brief Set up the ALPIDE in continuous mode
    procedure alpide_init_continuous (
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal dctrl          : inout std_logic;
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    );


end package alpide_bfm_pkg;

--=============================================================================
-- PACKAGE BODY
--=============================================================================

package body alpide_bfm_pkg is

  procedure alpide_multicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string := "alpide_multicast_write(A:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX)
                                   & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_OPCODE       : std_logic_vector(7 downto 0) := 8X"9C";
    constant C_MULTICAST_ID : std_logic_vector(7 downto 0)
      := '0' & 3X"0" & 4X"F";                 -- "0000_1111"
    constant C_REG : std_logic_vector(15 downto 0) := std_logic_vector(reg_addr);
  begin  -- procedure alpide_write
    -- Come out of idle
    send_gap(1, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send ID
    send_char(C_MULTICAST_ID, clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Reg Addr L
    send_char(C_REG(7 downto 0), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Reg Addr H
    send_char(C_REG(15 downto 8), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Data L
    send_char(data(7 downto 0), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Data H
    send_char(data(15 downto 8), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);

  end procedure alpide_multicast_write;
-- Overload
  procedure alpide_multicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;    -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;  -- Interface
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_multicast_write(reg_addr, data, msg, clk, alpide_if.dctrl,
                           alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_multicast_write;

  
  procedure alpide_unicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant chipid       : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string := "alpide_unicast_write(A:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX)
                                   & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    constant C_OPCODE     : std_logic_vector(7 downto 0)  := 8X"9C";
    constant C_UNICAST_ID : std_logic_vector(7 downto 0)  := '0' & std_logic_vector(chipid);
    constant C_REG        : std_logic_vector(15 downto 0) := std_logic_vector(reg_addr);
  begin
    -- Come out of idle
    send_gap(1, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send ID
    send_char(C_UNICAST_ID, clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Reg Addr L
    send_char(C_REG(7 downto 0), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Reg Addr H
    send_char(C_REG(15 downto 8), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Data L
    send_char(data(7 downto 0), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Data H
    send_char(data(15 downto 8), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);

  end procedure alpide_unicast_write;

  procedure alpide_unicast_write (
    constant reg_addr     : in    unsigned;
    constant data         : in    std_logic_vector(15 downto 0);
    constant chipid       : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_unicast_write(reg_addr, data, chipid, msg, clk, alpide_if.dctrl,
                         alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_unicast_write;

  procedure alpide_unicast_read (
    constant reg_addr     : in    unsigned;
    variable data         : out   std_logic_vector(15 downto 0);
    constant chipid_in    : in    unsigned;
    variable chipid_out   : out   std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal dctrl          : inout std_logic;
    signal dctrl_in       : in    std_logic;
    signal drive          : inout std_logic;
    signal reading        : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string              := "alpide_unicast_read"
--overwrite if called from other procedure, like alpide_check
    ) is
    constant proc_call : string := "alpide_unicast_read(A:" &
                                   to_string(reg_addr, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(chipid_in, HEX, AS_IS, INCL_RADIX)
                                   & ")";
    constant C_OPCODE     : std_logic_vector(7 downto 0)  := 8X"4E";
    constant C_UNICAST_ID : std_logic_vector(7 downto 0)  := '0' & std_logic_vector(chipid_in);
    constant C_REG        : std_logic_vector(15 downto 0) := std_logic_vector(reg_addr);
  begin

    -- Come out of idle
    send_gap(1, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send ID
    send_char(C_UNICAST_ID, clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Reg Addr L
    send_char(C_REG(7 downto 0), clk, dctrl, drive);
    send_random_gap(1, 1, clk, dctrl, drive);

    -- Send Reg Addr H
    send_char(C_REG(15 downto 8), clk, dctrl, drive);

    -- Turnaround
    bus_turnaround(true, clk, dctrl, dctrl_in, drive, reading);

    -- Reply phase

    -- Receive CHIP ID
    receive_char(chipid_out, clk, dctrl_in, scope, msg_id_panel, config);
    -- Receive DATA L
    receive_char(data(7 downto 0), clk, dctrl_in, scope, msg_id_panel, config);
    -- Receive DATA H
    receive_char(data(15 downto 8), clk, dctrl_in, scope, msg_id_panel, config);

    -- Turnaround again
    bus_turnaround(false, clk, dctrl, dctrl_in, drive, reading);
    if proc_name = "alpide_unicast_read" then
      log(config.id_for_bfm, proc_call & "=> " & to_string(chipid_out, HEX, AS_IS, INCL_RADIX) & ", " &
          to_string(data, HEX, AS_IS, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    end if;
  end procedure alpide_unicast_read;

  procedure alpide_unicast_read (
    constant reg_addr     : in    unsigned;
    variable data         : out   std_logic_vector(15 downto 0);
    constant chipid_in    : in    unsigned;
    variable chipid_out   : out   std_logic_vector(7 downto 0);
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal alpide_if      : inout t_alpide_if;
    signal dctrl_in       : in    std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_unicast_read(reg_addr, data, chipid_in, chipid_out, msg, clk, alpide_if.dctrl,
                        dctrl_in, alpide_if.drive, alpide_if.reading, scope, msg_id_panel, config);
  end procedure alpide_unicast_read;

  procedure alpide_check (
    constant reg_addr     : in    unsigned;
    constant data_exp     : in    std_logic_vector(15 downto 0);
    constant alert_level  : in    t_alert_level       := error;
    constant chipid_exp   : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal dctrl          : inout std_logic;
    signal dctrl_in       : in    std_logic;
    signal drive          : inout std_logic;
    signal reading        : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string              := "alpide_check"
    ) is
    constant proc_call : string := "alpide_check(A:" & to_string(reg_addr, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(chipid_exp, HEX, AS_IS, INCL_RADIX) & ")";
    variable data_returned   : std_logic_vector(15 downto 0);
    variable chipid_returned : std_logic_vector(7 downto 0);
    variable check_id_ok     : boolean;
    variable check_data_ok   : boolean;
  begin
    alpide_unicast_read(reg_addr, data_returned, chipid_exp, chipid_returned, msg, clk, dctrl,
                        dctrl_in, drive, reading, scope, msg_id_panel, config, proc_name);

    -- Check that both ID and Data is as expected
    check_id_ok := check_value(chipid_returned(6 downto 0), std_logic_vector(chipid_exp), failure, msg, scope,
                               HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
    check_data_ok := check_value(data_returned, data_exp, failure, msg, scope, HEX_BIN_IF_INVALID,
                                 SKIP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
    if (check_id_ok and check_data_ok) then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " &
          to_string(data_returned, HEX, AS_IS, INCL_RADIX) & ", " &
          to_string(chipid_returned, HEX, AS_IS, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
    end if;
  end procedure alpide_check;

  procedure alpide_check (
    constant reg_addr     : in    unsigned;
    constant data_exp     : in    std_logic_vector(15 downto 0);
    constant chipid_exp   : in    unsigned;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal alpide_if      : inout t_alpide_if;
    signal dctrl_in       : in    std_logic;
    constant alert_level  : in    t_alert_level       := error;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_check(reg_addr, data_exp, alert_level, chipid_exp, msg, clk, alpide_if.dctrl,
                 dctrl_in, alpide_if.drive, alpide_if.reading, scope, msg_id_panel, config);
  end procedure alpide_check;


  -- purpose: Send data on DCTRL
  procedure send_char (
    constant payload : in    std_logic_vector(7 downto 0);
    signal clk       : in    std_logic;
    signal dctrl     : inout std_logic;
    signal drive     : inout std_logic;
    constant config  :       t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    variable char : std_logic_vector(9 downto 0) := '1' & payload & '0';
  begin  -- procedure send_char
    -- Grab bus
    drive <= '1';
    dctrl <= '1';
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    -- Send data with LSB first
    for i in 0 to 9 loop
      dctrl <= char(i);
      wait for config.clock_period;
    end loop;
    -- Release bus
    drive <= '0';
  end procedure send_char;

  procedure receive_char (
    variable data_rec     : out std_logic_vector(7 downto 0);
    signal clk            : in  std_logic;
    signal dctrl_in       : in  std_logic;
    constant scope        : in  string              := C_SCOPE;
    constant msg_id_panel : in  t_msg_id_panel      := shared_msg_id_panel;
    constant config       :     t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    -- Wait for ALPIDE to send char
    loop
      wait until rising_edge(clk);
      if dctrl_in = '0' then
        check_value(dctrl_in, '0', failure, "Confirm start bit", scope, ID_POS_ACK, msg_id_panel);
        exit;
      else

      end if;
    end loop;

    -- Wait one clock period and then start sampling
    wait for config.clock_period;
    for i in 0 to 7 loop
      data_rec := dctrl_in & data_rec(7 downto 1);
      wait for config.clock_period;
    end loop;
    -- Check that stop bit
    check_value(dctrl_in, '1', failure, "Confirm stop bit", scope, ID_POS_ACK, msg_id_panel);
    wait for config.clock_period;
  end procedure receive_char;


  -- purpose: Send a gap on DCTRL
  procedure send_gap (
    constant number : in    natural;
    signal clk      : in    std_logic;
    signal dctrl    : inout std_logic;
    signal drive    : inout std_logic;
    constant config : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin  -- procedure send_gap
    -- Grab bus
    drive <= '1';
    dctrl <= '1';
    wait for number * config.clock_period;
    -- Release bus
    drive <= '0';
  end procedure send_gap;

  procedure send_random_gap (
    constant min    : in    natural;
    constant max    : in    natural;
    signal clk      : in    std_logic;
    signal dctrl    : inout std_logic;
    signal drive    : inout std_logic;
    constant config : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    send_gap(random(min, max), clk, dctrl, drive, config);
  end procedure send_random_gap;

  -- purpose: Reset ALPIDE
  procedure send_reset (
    constant time_reset   : in    natural;
    constant time_idle    : in    natural;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal rst_n          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string := "send_reset( Time reset: " & to_string(time_reset) & " clock period(s)" &
                                   ", Time idle: " & to_string(time_idle) & " clock period(s) )";
  begin  -- procedure send_reset
    log(config.id_for_bfm, proc_call & " " & msg, scope, msg_id_panel);
    rst_n <= '0';
    wait for time_reset * config.clock_period;
    rst_n <= '1';
    wait for time_idle * config.clock_period;
  end procedure send_reset;

  procedure bus_turnaround (
    constant ctrl_to_alpide : in    boolean;
    signal clk              : in    std_logic;
    signal dctrl            : inout std_logic;
    signal dctrl_in         : in    std_logic;
    signal drive            : inout std_logic;
    signal reading          : inout std_logic;
    constant scope          : in    string              := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config         : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    if ctrl_to_alpide = true then
      -- Master Idle Phase
      drive <= '1';
      dctrl <= '1';

      wait for 5 * config.clock_period;

      -- Turnaround phase
      -- Purpose: allow margin to prevent line contention
      drive   <= '0';
      reading <= '1';

      -- Choose a sampling point, rising edge
      wait until rising_edge(clk);
      wait for 4 * config.clock_period;

      -- Slave Idle Phase
      -- Check that chip drives dctrl or call error
      check_value(dctrl_in, '1', error, "ALPIDE must drive DCTRL", scope, ID_POS_ACK, msg_id_panel);
      wait for 5 * config.clock_period;


    else
      -- Slave Idle phase
      reading <= '0';
      wait for 5 * config.clock_period;

      -- Turnaround phase
      drive <= '1';
      wait for 5 * config.clock_period;

      -- Master Idle Phase
      wait for 5 * config.clock_period;
    end if;
  end procedure bus_turnaround;

  procedure alpide_broadcast_grst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string                       := "alpide_broadcast_grst( Chip Global Reset )";
    constant C_OPCODE  : std_logic_vector(7 downto 0) := 8X"D2";
  begin
    -- Come out of idle
    send_gap(5, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 10, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure alpide_broadcast_grst;

  procedure alpide_broadcast_grst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_broadcast_grst(msg, clk, alpide_if.dctrl, alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_broadcast_grst;

  procedure alpide_broadcast_prst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string                       := "alpide_broadcast_prst( Pixel Matrix Reset )";
    constant C_OPCODE  : std_logic_vector(7 downto 0) := 8X"E4";
  begin
-- Come out of idle
    send_gap(5, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 10, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure alpide_broadcast_prst;

  procedure alpide_broadcast_prst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_broadcast_prst(msg, clk, alpide_if.dctrl, alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_broadcast_prst;

  procedure alpide_broadcast_pulse (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string                       := "alpide_broadcast_pulse( Pixel Matrix Pulse )";
    constant C_OPCODE  : std_logic_vector(7 downto 0) := 8X"78";
  begin
-- Come out of idle
    send_gap(5, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 10, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure alpide_broadcast_pulse;

  procedure alpide_broadcast_pulse (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_broadcast_pulse(msg, clk, alpide_if.dctrl, alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_broadcast_pulse;

  procedure alpide_broadcast_bcrst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string                       := "alpide_broadcast_bcrst( Bunch Counter Reset )";
    constant C_OPCODE  : std_logic_vector(7 downto 0) := 8X"36";
  begin
-- Come out of idle
    send_gap(5, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 10, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure alpide_broadcast_bcrst;

  procedure alpide_broadcast_bcrst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_broadcast_bcrst(msg, clk, alpide_if.dctrl, alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_broadcast_bcrst;

  procedure alpide_broadcast_rorst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string                       := "alpide_broadcast_rorst( Readout [RRU, TRU, DMU] Reset )";
    constant C_OPCODE  : std_logic_vector(7 downto 0) := 8X"63";
  begin
-- Come out of idle
    send_gap(5, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 10, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure alpide_broadcast_rorst;

  procedure alpide_broadcast_rorst (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_broadcast_rorst(msg, clk, alpide_if.dctrl, alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_broadcast_rorst;

  procedure alpide_broadcast_debug (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal dctrl          : inout std_logic;  -- Bidirectional data line
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string                       := "alpide_broadcast_debug( Sample state in shadow registers )";
    constant C_OPCODE  : std_logic_vector(7 downto 0) := 8X"AA";
  begin
-- Come out of idle
    send_gap(5, clk, dctrl, drive);

    -- Send opcode
    send_char(C_OPCODE, clk, dctrl, drive);
    send_random_gap(1, 10, clk, dctrl, drive);

    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure alpide_broadcast_debug;

  procedure alpide_broadcast_debug (
    constant msg          : in    string;
    signal clk            : in    std_logic;  -- 40 Mhz
    signal alpide_if      : inout t_alpide_if;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT
    ) is
  begin
    alpide_broadcast_debug(msg, clk, alpide_if.dctrl, alpide_if.drive, scope, msg_id_panel, config);
  end procedure alpide_broadcast_debug;

  -----------------------------------------------------------------------------
  -- Initialization
  -----------------------------------------------------------------------------
  procedure alpide_init_continuous (
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal dctrl          : inout std_logic;
    signal drive          : inout std_logic;
    constant scope        : in    string              := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel      := shared_msg_id_panel;
    constant config       : in    t_alpide_bfm_config := C_ALPIDE_BFM_CONFIG_DEFAULT) is
  begin  -- procedure init
    -- Configuration of pixel logic

    -- Configuration of start-up of Data Transmission Unit
    alpide_multicast_write(16X"14", 16X"8D", "Set up PLL", clk, dctrl, drive, scope,
                           msg_id_panel, config);
    alpide_multicast_write(16X"15", 16X"88", "Set up charge pump", clk, dctrl, drive, scope,
                           msg_id_panel, config);
    -- Clear PLL off signal bit to start the PLL
    alpide_multicast_write(16X"14", 16X"85", "Start PLL", clk, dctrl, drive, scope,
                           msg_id_panel, config);
    -- Force a reset of the PLL
    alpide_multicast_write(16X"14", 16X"185", "Force reset", clk, dctrl, drive, scope,
                           msg_id_panel, config);
    alpide_multicast_write(16X"14", 16X"85", "Clear reset", clk, dctrl, drive, scope,
                           msg_id_panel, config);

    -- Setting up readout in inner barrel scenario
    -- Do nothing

    -- Setting FROMU Configuration and enabling readout mode
    alpide_multicast_write(16X"4", 16X"6", "Enable internal strobe generation", clk, dctrl, drive, scope,
                           msg_id_panel, config);
    -- May later set enable bit 6 that enables internal TRIGGER pulse after
    -- each PULSE signal

    alpide_multicast_write(16X"1", 16X"1FE", "Write to Periphery Control Register", clk, dctrl, drive, scope,
                           msg_id_panel, config);
    alpide_broadcast_rorst("Activate driving of the local bus by the chip", clk, dctrl, drive, scope,
                    msg_id_panel, config);

  end procedure alpide_init_continuous;
end package body alpide_bfm_pkg;
