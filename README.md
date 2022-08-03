# Crossy Road VHDL Project - README
*** 
![](https://m.media-amazon.com/images/G/01/DeveloperBlogs/AmazonDeveloperBlogs/legacy/c1._CB520204065_.png)  

**Instructions on how to compile/execute program:**    
1. Open Vivado and create project   
2. For simulation/design, enter the following files:   
    a. `block_controller.v`  
    b. `display_controller.v`  
    c. `vga_top.v`  
3. For constraint, enter this file: `nexys4.xdc`    
4. Generate bitstream   
5. Write bistream and enjoy the game on your Nexys 4 FPGA board 

## **Overview**
This is a VGA project written in Verilog inspired by the popular game, Crossy Road. Crossy Road is a game where a chicken is trying to safely cross a road with fast approaching, oncoming traffic (if you get hit once, it’s game over). In my version of the game, I take the same concept, but the chicken has three lives and when you reach the end of the VGA screen, the user accumulates a point and the main character respawns at its initial starting point at the bottom of the screen (everytime you get hit, you lose a life and zero lives mean game over). After each point the user accumulates, traffic speed gets significantly faster and if lives are lost, traffic speed doesn’t change. The main objective of our game is to see the highest possible score that the user can achieve.