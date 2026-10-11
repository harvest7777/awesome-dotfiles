# Shrink a video under Discord's 20MB upload cap by spreading a ~19MB budget
# over its duration; two-pass x264 so the size lands on target. Writes
# discord_<name> next to the input
function discord
    set -l in $argv[1]
    set -l out (path dirname $in)/discord_(path basename $in)
    set -l dur (ffprobe -v error -show_entries format=duration -of csv=p=0 $in)
    set -l vbit (math -s0 "152000 / $dur - 128")
    set -l log (mktemp -d)/pass
    ffmpeg -y -i $in -vf scale=-2:720 -c:v libx264 -preset medium -b:v {$vbit}k -pass 1 -passlogfile $log -an -f mp4 /dev/null
    and ffmpeg -i $in -vf scale=-2:720 -c:v libx264 -preset medium -b:v {$vbit}k -pass 2 -passlogfile $log -c:a aac -b:a 128k $out
end
