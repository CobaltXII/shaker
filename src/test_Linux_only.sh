#!/bin/bash

# Author : Eric Bachard
# Copyright 2019 march 3rd  
# this shell script is under GPL v2+ License

# adapt to your path
shaders_dir=../glsl
# change the value if you want another delay between the slideshow
delay=5


# uncomment if you want to test the debug version
#DEBUG_EXT=_debug

# default window size is 1280x720.
# Uncomment the line below, and test with your own values
#CUSTOM_WINDOW_SIZE="800 600"


#
APPLICATION=./shaker${DEBUG_EXT}


# the idea is to launch shaker with the right options
# as you can see, you can customize the list !

liste="fragment.glsl \
        ${shaders_dir}/brownian.glsl \
        ${shaders_dir}/raymarch_1.glsl \
        ${shaders_dir}/raymarch_2.glsl \
        ${shaders_dir}/raymarch_3.glsl \
        ${shaders_dir}/raymarch_4.glsl"

sauvegarde_stty=$(stty -g)
stty -icanon time 2 min 0 -echo

#initialize
car=""

# in the case this is needed on Linux. Helps to make OpenGL > 3.0 to work ;-)
#MESA_GLSL_VERSION_OVERRIDE=450
#MESA_GL_VERSION_OVERRIDE=4.5

#export MESA_GL_VERSION_OVERRIDE MESA_GLSL_VERSION_OVERRIDE

function simple_shaders()
{
    for frag in ${liste}
        do
            # DEUG ONLY echo Current command "line" : ${APPLICATION} $frag ${CUSTOM_WINDOW_SIZE} &
            ${APPLICATION} $frag ${CUSTOM_WINDOW_SIZE} &
            sleep $delay;
            kill $(pidof ${APPLICATION}) 2>/dev/null

            read car

            if test "x$car" != "x"
                then
                    # key pressed
                    killall -9 `basename $0`
            fi
    done
}


# the main
simple_shaders

#be sure no more ShaderToy remain at the end
killall -9 shaker 2>/dev/null
echo "test completed"

# return to a sane terminal state
stty $sauvegarde_stty

