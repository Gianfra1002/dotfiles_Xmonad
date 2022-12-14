--IMPORTS
--Default
import XMonad
import Data.Monoid
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

--Layout
import XMonad.Layout.Grid
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutHints
import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.PerWorkspace

--Hooks
import XMonad.Hooks.Place
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog --for xmobar

--Util and Actions
import XMonad.Actions.SpawnOn
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.SpawnOnce --Not working, for some reason...
--import XMonad.StackSet

-------------------------------------------------------------------------
-- VARIABLES

-- Colors
mainColor1 = "#ec5fcf"
mainColor2 = "#63c7b2"
mainColor3 = "#80ced7"
mainColor4 = "#0c7a89"
mainColor5 = "#0b2a2f"
mainColor6 = "#ee1212"

textColor = "#ccdbdc"

bgColor1 = "#263d42"
bgColor2 = "#343434"

-- My default terminal
myTerminal :: String
myTerminal = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth = 2

-- My default font
--myFont :: String
--myFont = ""

-- The Mod Key: WIN
-- By defaul it is mod1Mask: Alt
myModMask :: KeyMask
myModMask = mod4Mask

-- My workspaces (virtual screens) and their names
myWorkspaces = ["home","dev","web", "4", "5", "6", "7", "8", "9"]

-- Border colors for unfocused and focused windows, respectively.
myFocusedBorderColor = mainColor4
myNormalBorderColor  = mainColor5

-------------------------------------------------------------------------
-- AUTOSTART (or Startup hook) [restart xmonad with mod+q]
-- default: return ()
-- use 'do' and then concatenate 'spawn "command"' to run a command at every restart
-- (for startup executable is better to use the .xinitrc file)

myStartupHook = do
	spawn "/home/gianfra/.config/xmonad/startup.sh"
	--spawnOn "dev" "sleep 1s; kitty"
	--spawn "kitty vtop"
	--spawn "sleep 5; kitty nnn"
	--spawn "delay 60; kitty"
    --spawn "nitrogen --restore" 
    --spawn "picom &"
    --spawn "setxkbmap -layout it"
    --spawn "xrandr -s 1920x1080"
    --spawn "xfce4-terminal --title='nnn' --command=nnn"
    --spawn "xfce4-terminal --title='vtop' --command='vtop -t brew'"

-------------------------------------------------------------------------
-- LAYOUTS [restart layout with mod+shift+space]

tiled   = Tall 1 (50/100) (1/2)
grid = GridRatio (4/3)
fullscreen = noBorders Full

myLayout = avoidStruts $ 
        mkToggle (NBFULL ?? NOBORDERS ?? FULL ?? EOT) $ def_layout
        where
        def_layout = spacingWithEdge 8 grid 
                    ||| spacingWithEdge 8 tiled 
                    ||| fullscreen

------------------------------------------------------------------------
-- WINDOW RULES:
-- Use 'xmprop' for the Class Name

myManageHook = fullscreenManageHook <> manageSpawn <> composeAll
    [ className =? "firefox"                --> doShift "web"
    , resource  =? "desktop_window"         --> doIgnore
    , resource  =? "kdesktop"               --> doIgnore ]

-------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = fullscreenEventHook

------------------------------------------------------------------------
-- STATUS BAR: xmobar
myCurrentWSColor = mainColor1
myHiddenWSColor = mainColor2
myVisibleWSColor = mainColor3
myCurrentWSLeft = "["
myCurrentWSRight = "]"


myLogHook h = dynamicLogWithPP $ def
            { ppOrder = \(ws:_) -> [ws]
            , ppCurrent = xmobarColor myCurrentWSColor "" . wrap myCurrentWSLeft myCurrentWSRight
            , ppHidden = xmobarColor myVisibleWSColor "" . wrap "(" ")"
            , ppHiddenNoWindows = xmobarColor myHiddenWSColor ""
            , ppOutput = hPutStrLn h
            }

------------------------------------------------------------------------
-- MAIN:

main = do
  xmproc <- spawnPipe "xmobar /home/gianfra/.config/xmobar/xmobarrc"
  xmonad $ docks $ def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc,
        startupHook        = myStartupHook
    }


------------------------------------------------------------------------
-- KEY BINDINGS:
-- Use 'xev' to know the key code

toggleFloat w = windows (\s -> if M.member w (W.floating s)
		then W.sink w s
		else (W.float w (W.RationalRect (1/3) (1/4) (1/2) (4/5)) s))

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu (nb: background, sf: selected, sb: higlighted, nf: text, fn: font)
    , ((modm,	xK_p),	spawn "dmenu_run -nb '#0b2a2f' -nf '#ccdbdc' -sf '#8fee96' -sb '#0c7a89' -fn 'UbuntuMono'")

    -- launch firefox
    , ((modm .|. shiftMask, xK_f     ), spawn "firefox")

    -- increase brightness
    , ((0, 0x1008ff02), spawn "light -A 2")

    -- decrease brightness
    , ((0, 0x1008ff03), spawn "light -U 2")

    -- increase volume DA SISTEMARE
    , ((0, 0x1008ff13), spawn "amixer -c 1 set 'Master' 1%+")

    -- decrease volume
    , ((0, 0x1008ff11), spawn "amixer -c 1 set 'Master' 1%-")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Change Layout to fullscreen
    , ((modm,               xK_f     ), sendMessage $ Toggle NBFULL)

    -- Toggle Float Layout
    , ((modm,		xK_t	), withFocused toggleFloat)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    --, ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; killall xmobar; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- Mouse bindings: default actions bound to mouse events
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- A copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The modifier key is WIN. Keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-f      Launch firefox",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-f            Toggle Fullscreen",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Toggle Floating on selected window",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",             
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
