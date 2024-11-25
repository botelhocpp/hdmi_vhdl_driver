# HDMI VHDL Driver

A driver for the HDMI interface made in VHDL, with the Zybo board. Primary for 800x600@60Hz and 640x480@60Hz resolutions.

# Problem Fix:

For 640x480@60Hz, we need a 24.5MHz pixel clock to achieve 60 frames per seconds. The problem is that HDMI specifies a 25MHz minimum pixel clock, and if we use 25MHz for the 640x480@60Hz parameters we will have some problems due to the clock synchronization. 

Instead of the screen going from 0 to 639 in horizontal, and 0 to 479 in vertical, it goes from 19 to 622 and 15 to 464, respectively (and it may vary).

To solve this problem, use the 800x600@60Hz resolution, at 40MHz!
