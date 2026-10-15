# `open <dir>` shows it in Finder on the current AeroSpace workspace instead
# of switching to whichever workspace already has a Finder window. Bundles
# like Foo.app are directories too, so those still go to the real open.
function open
    if test (count $argv) -eq 1; and test -d $argv[1]
        and not mdls -raw -name kMDItemContentTypeTree $argv[1] 2>/dev/null | string match -q '*com.apple.package*'
        ~/Developer/dotfiles/aerospace/finder-here.sh $argv[1]
    else
        command open $argv
    end
end
