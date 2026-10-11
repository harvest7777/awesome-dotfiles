# Fake motion blur by blending each N frames (default 3) of a high-fps
# recording into one 60fps frame; writes blurred_<name> next to the input.
# Usage: blur <file> [frames]
function blur
    set -l in $argv[1]
    set -l frames 3
    set -q argv[2]; and set frames $argv[2]
    set -l out (path dirname $in)/blurred_(path basename $in)
    ffmpeg -i $in -vf "tmix=frames=$frames,fps=60" -c:v h264_videotoolbox -b:v 40M -c:a copy $out
end
