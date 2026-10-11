# Shrink a video under Discord's 20MB upload cap by spreading an 18MB budget
# over its duration; two-pass x264 still overshoots on some clips, so re-encode
# at a proportionally lower bitrate until it fits. Writes discord_<name> next
# to the input
function discord
    set -l in $argv[1]
    set -l out (path dirname $in)/discord_(path basename $in)
    set -l limit 19000000
    set -l dur (ffprobe -v error -show_entries format=duration -of csv=p=0 $in)
    set -l vbit (math -s0 "144000 / $dur - 128")
    set -l log (mktemp -d)/pass
    while true
        ffmpeg -y -i $in -vf scale=-2:720 -c:v libx264 -preset medium -b:v {$vbit}k -pass 1 -passlogfile $log -an -f mp4 /dev/null
        and ffmpeg -y -i $in -vf scale=-2:720 -c:v libx264 -preset medium -b:v {$vbit}k -pass 2 -passlogfile $log -c:a aac -b:a 128k $out
        or return 1
        set -l size (stat -f %z $out)
        test $size -le $limit; and return 0
        set vbit (math -s0 "$vbit * $limit / $size * 0.95")
        echo "discord: $size bytes is over the cap, retrying at $vbit"k >&2
    end
end
