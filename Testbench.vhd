LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.HdmiPkg.ALL;
 
ENTITY Testbench IS
  PORT (
    -- Main Clock (125 MHz)
    i_Clk : IN STD_LOGIC;
     
    -- HDMI
    o_Hdmi_Data_N : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_Hdmi_Data_P : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_Hdmi_Clk_N : OUT STD_LOGIC;
    o_Hdmi_Clk_P : OUT STD_LOGIC
    );
END ENTITY;
 
ARCHITECTURE RTL OF Testbench IS
    -- Wires
    SIGNAL w_Clk_400_MHz : STD_LOGIC;
    SIGNAL w_Pixel_Clk : STD_LOGIC := '0';
    SIGNAL w_Video_Enable : STD_LOGIC := '0';
    SIGNAL w_H_Sync : STD_LOGIC := '0';
    SIGNAL w_V_Sync : STD_LOGIC := '0';
    SIGNAL w_H_Pos : INTEGER RANGE 0 TO c_H_MAX := 0;
    SIGNAL w_V_Pos : INTEGER RANGE 0 TO c_V_MAX := 0;
    
    -- Registers
    SIGNAL r_Video_Enable_Align : STD_LOGIC := '0';
    SIGNAL r_H_Sync_Align : STD_LOGIC := '0';
    SIGNAL r_V_Sync_Align : STD_LOGIC := '0';
    SIGNAL r_Channel_R : t_Byte := (OTHERS => '0');
    SIGNAL r_Channel_G : t_Byte := (OTHERS => '0');
    SIGNAL r_Channel_B : t_Byte := (OTHERS => '0');
BEGIN
    e_CLK_DOUBLER : ENTITY WORK.ClockDoubler
    PORT MAP (
        i_Clk => i_Clk,
        reset => '0',
        o_Clk => w_Clk_400_MHz,
        o_Locked => OPEN
    );
    
    e_HDMI_SYNC: ENTITY WORK.HdmiSync
    PORT MAP (
        i_Clk           => w_Clk_400_MHz,
        o_Pixel_Clk     => w_Pixel_Clk,
        o_Video_Enable  => w_Video_Enable,
        o_H_Sync        => w_H_Sync,
        o_V_Sync        => w_V_Sync,
        o_H_Pos         => w_H_Pos,
        o_V_Pos         => w_V_Pos
    );
    
    e_HDMI_OUT: ENTITY WORK.HdmiOut
    PORT MAP (
        i_Channel_R     => r_Channel_R,
        i_Channel_G     => r_Channel_G,
        i_Channel_B     => r_Channel_B,
        i_Clk           => w_Clk_400_MHz,
        i_Pixel_Clk     => w_Pixel_Clk,
        i_H_Sync        => r_H_Sync_Align,
        i_V_Sync        => r_V_Sync_Align,
        i_Video_Enable  => r_Video_Enable_Align,
        o_Hdmi_Data_N   => o_Hdmi_Data_N,
        o_Hdmi_Data_P   => o_Hdmi_Data_P,
        o_Hdmi_Clk_N    => o_Hdmi_Clk_N,
        o_Hdmi_Clk_P    => o_Hdmi_Clk_P
    );
    
    p_GENERATE_LIMIT_LINES:
    PROCESS(w_Pixel_Clk)
    BEGIN
        IF(RISING_EDGE(w_Pixel_Clk)) THEN
            IF(
                w_H_Pos = 0 OR
                w_H_Pos = c_FRAME_WIDTH - 1 OR
                w_v_Pos = 0 OR
                w_v_Pos = c_FRAME_HEIGHT - 1
            ) THEN
                r_Channel_R <= (OTHERS => '1');
                r_Channel_G <= (OTHERS => '1');
                r_Channel_B <= (OTHERS => '1');
            ELSE
                r_Channel_R <= (OTHERS => '0');
                r_Channel_G <= (OTHERS => '0');
                r_Channel_B <= (OTHERS => '0');
            END IF;
            
            -- Align signals to the delayed data
            r_Video_Enable_Align <= w_Video_Enable;
            r_H_Sync_Align <= w_H_Sync;
            r_V_Sync_Align <= w_V_Sync;
        END IF;
    END PROCESS p_GENERATE_LIMIT_LINES;
END ARCHITECTURE;