import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ICCCMFocus
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WorkspaceNames
import XMonad.Prompt
import XMonad.Prompt.Workspace
import XMonad.Layout.Spacing (smartSpacing)
import XMonad.Layout.NoBorders
import System.IO
import Graphics.X11.ExtraTypes.XF86
import Data.Monoid 

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = myLayoutHook 
        -- fix for xmobar to stop hiding behind windows
        , handleEventHook = mconcat
                          [ docksEventHook
                          , handleEventHook defaultConfig ]
        -- the setVMName option causes firefox to fail on a resize
        -- , startupHook = setWMName "LG3D" 
        -- fixed it using _JAVA_AWT_WM_NONREPARENTING=1 in ~/.profile
        , logHook = myLogHook xmproc
        , modMask = mod1Mask     
        , terminal = "gnome-terminal"
        } `additionalKeys`
        [ ((mod4Mask,               xK_l), spawn "gnome-screensaver-command -l")
        , ((mod1Mask .|. shiftMask, xK_r), renameWorkspace defaultXPConfig)
        , ((0,   xF86XK_AudioRaiseVolume), spawn "amixer set Master 5%+")
        , ((0,   xF86XK_AudioLowerVolume), spawn "amixer set Master 5%-")
        , ((0,          xF86XK_AudioMute), spawn "amixer set Master toggle")
        , ((controlMask,        xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0,                  xK_Print), spawn "scrot")
        , ((0,                    xK_F12), spawn "~/Code/conf/paste.sh")
        ]

myLogHook s = (dynamicLogWithPP =<< workspaceNamesPP xmobarPP { ppOutput = hPutStrLn s
                                                              , ppTitle = xmobarColor "green" "" . shorten 90
                                                              }) >> updatePointer (0.5,0.5) (0,0)

myLayoutHook = avoidStruts $ smartSpacing 2 $ layoutHook defaultConfig

