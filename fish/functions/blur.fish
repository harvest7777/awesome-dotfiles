# Fake motion blur by blending each 4 frames of a high-fps recording into one
# 60fps frame; writes blurred_<name> next to the input
function blur
    set -l in $argv[1]
    set -l out (path dirname $in)/blurred_(path basename $in)
    ffmpeg -i $in -vf "tmix=frames=4,fps=60" -c:v h264_videotoolbox -b:v 40M -c:a copy $out
end
