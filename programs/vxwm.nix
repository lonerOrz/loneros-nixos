{
  config,
  pkgs,
  lib,
  ...
}:

let
  myConfig = ''
    #pragma once

    /* appearance */
    static const unsigned int borderpx  = 1;
    static const unsigned int snap      = 32;
    static const int showbar            = 1;
    static const int topbar             = 1;

    static const char *fonts[]          = {
      "monospace:size=10"
    };

    static const char dmenufont[]       = "monospace:size=10";

    static MAYBE_CONST char normbgcolor[]    = "#222222";
    static MAYBE_CONST char normbordercolor[] = "#444444";
    static MAYBE_CONST char normfgcolor[]    = "#bbbbbb";

    static MAYBE_CONST char selfgcolor[]     = "#eeeeee";
    static MAYBE_CONST char selbordercolor[] = "#005577";
    static MAYBE_CONST char selbgcolor[]     = "#005577";

    static MAYBE_CONST char *colors[][3] = {
      /*               fg           bg           border */
      [SchemeNorm] = {
        normfgcolor,
        normbgcolor,
        normbordercolor
      },

      [SchemeSel] = {
        selfgcolor,
        selbgcolor,
        selbordercolor
      },
    };

    #define CENTER_NEW_FLOATING_WINDOWS 1
    #define NEW_FLOATING_WINDOWS_APPEAR_UNDER_CURSOR 0

    #if GAPS
    static const unsigned int gappx = 10;
    #endif

    #if BAR_HEIGHT
    static const int user_bh = 24;
    #endif

    #if BAR_PADDING
    static const int top_vertpad    = 10;
    static const int bottom_vertpad = 10;

    static const int left_sidepad   = 10;
    static const int right_sidepad  = 10;
    #endif

    /* tagging */
    static const char *tags[] = {
      "1", "2", "3",
      "4", "5", "6",
      "7", "8", "9"
    };

    #if INFINITE_TAGS
    #define MOVE_CANVAS_STEP 120
    #endif

    #if INFINITE_TAGS && IT_SHOW_COORDINATES_IN_BAR
    #define COORDINATES_DIVISOR 10
    #endif

    #if MOVE_RESIZE_WITH_KEYBOARD
    #define MOVE_WITH_KEYBOARD_STEP 50
    #define RESIZE_WITH_KEYBOARD_STEP 50
    #endif

    #if AUTOSTART
    static const char *const autostart[] = {
      "ghostty",
      NULL
    };
    #endif

    static const Rule rules[] = {
      /* class      instance  title  tags mask  isfloating  monitor */
      { "Gimp",    NULL, NULL, 0,       1, -1 },
      { "Firefox", NULL, NULL, 1 << 8,  0, -1 },
    };

    /* layout(s) */
    static const float mfact     = 0.55;
    static const int nmaster     = 1;
    static const int resizehints = 1;
    static const int lockfullscreen = 1;

    #if LOCK_MOVE_RESIZE_REFRESH_RATE
    static const int refreshrate = 144;
    #endif

    static const Layout layouts[] = {
      /* symbol arrange function */
      { "><>", NULL },
      { "[]=", tile },
      { "[M]", monocle },
    };

    /* key definitions */
    #define MODKEY Mod1Mask
    #define ALTERNATE_MODKEY Mod4Mask

    #define TAGKEYS(KEY,TAG) \
      { MODKEY,                       KEY, view,       {.ui = 1 << TAG} }, \
      { MODKEY|ControlMask,           KEY, toggleview, {.ui = 1 << TAG} }, \
      { ALTERNATE_MODKEY,             KEY, tag,        {.ui = 1 << TAG} }, \
      { MODKEY|ControlMask|ShiftMask, KEY, toggletag,  {.ui = 1 << TAG} },

    #define SHCMD(cmd) \
      { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

    /* commands */
    static char dmenumon[2] = "0";

    static const char *dmenucmd[] = {
      "rofi",
      "-show",
      "drun",
      NULL
    };

    static const char *termcmd[] = {
      "ghostty",
      NULL
    };

    static const Key keys[] = {
      /* modifier                     key           function        argument */

      { MODKEY,                       XK_p,         spawn,          {.v = dmenucmd } },
      { MODKEY|ShiftMask,             XK_Return,    spawn,          {.v = termcmd } },

      { MODKEY,                       XK_b,         togglebar,      {0} },

      { MODKEY,                       XK_j,         focusstack,     {.i = +1 } },
      { MODKEY,                       XK_k,         focusstack,     {.i = -1 } },

      { MODKEY,                       XK_i,         incnmaster,     {.i = +1 } },
      { MODKEY,                       XK_d,         incnmaster,     {.i = -1 } },

      { MODKEY,                       XK_h,         setmfact,       {.f = -0.05} },
      { MODKEY,                       XK_l,         setmfact,       {.f = +0.05} },

      { MODKEY,                       XK_Return,    swapmaster,     {0} },

      { MODKEY,                       XK_0,         view,           {0} },

      { MODKEY|ShiftMask,             XK_c,         killclient,     {0} },

      { MODKEY,                       XK_t,         setlayout,      {.v = &layouts[0]} },
      { MODKEY,                       XK_f,         setlayout,      {.v = &layouts[1]} },
      { MODKEY,                       XK_m,         setlayout,      {.v = &layouts[2]} },

      { MODKEY,                       XK_space,     setlayout,      {0} },

      { MODKEY|ShiftMask,             XK_space,     togglefloating, {0} },

      { MODKEY,                       XK_Tab,       view,           {.ui = ~0 } },

      { MODKEY|ShiftMask,             XK_0,         tag,            {.ui = ~0 } },

      { MODKEY,                       XK_comma,     focusmon,       {.i = -1 } },
      { MODKEY,                       XK_period,    focusmon,       {.i = +1 } },

      { MODKEY|ShiftMask,             XK_comma,     tagmon,         {.i = -1 } },
      { MODKEY|ShiftMask,             XK_period,    tagmon,         {.i = +1 } },

      TAGKEYS(XK_1, 0)
      TAGKEYS(XK_2, 1)
      TAGKEYS(XK_3, 2)
      TAGKEYS(XK_4, 3)
      TAGKEYS(XK_5, 4)
      TAGKEYS(XK_6, 5)
      TAGKEYS(XK_7, 6)
      TAGKEYS(XK_8, 7)
      TAGKEYS(XK_9, 8)

      { MODKEY|ShiftMask,             XK_q,         quit,           {0} },
    };

    /* button definitions */
    static const Button buttons[] = {

    #if INFINITE_TAGS
      { ClkRootWin, MODKEY|ShiftMask, Button1,
        movecanvasmouse, {.f = 1.5 } },

      { ClkClientWin, MODKEY|ShiftMask, Button1,
        movecanvasmouse, {.f = 1.5 } },
    #endif

      { ClkLtSymbol,   0, Button1, setlayout,      {0} },
      { ClkLtSymbol,   0, Button3, setlayout,      {.v = &layouts[2]} },

      { ClkWinTitle,   0, Button2, swapmaster,     {0} },

      { ClkStatusText, 0, Button2, spawn,          {.v = termcmd } },

      { ClkClientWin,  MODKEY, Button1, movemouse,      {0} },
      { ClkClientWin,  MODKEY, Button2, togglefloating, {0} },
      { ClkClientWin,  MODKEY, Button3, resizemouse,    {0} },

      { ClkTagBar, 0,       Button1, view,       {0} },
      { ClkTagBar, 0,       Button3, toggleview, {0} },

      { ClkTagBar, MODKEY, Button1, tag,       {0} },
      { ClkTagBar, MODKEY, Button3, toggletag, {0} },
    };
  '';

  vxwmCustom = pkgs.nur.repos.lonerOrz.vxwm.override {
    conf = myConfig;
    patches = [ ];
    extraLibs = [ ];
  };

in
{
  services.xserver = {
    enable = true;

    videoDrivers = [ "nvidia" ];

    deviceSection = ''
      Option "ForceFullCompositionPipeline" "true"
      Option "TripleBuffer" "true"
    '';

    displayManager.startx.enable = true;

    windowManager.session = [
      {
        name = "vxwm";

        start = ''
          ${vxwmCustom}/bin/vxwm &
          waitPID=$!
        '';
      }
    ];
  };

  environment.systemPackages = [
    vxwmCustom
  ];
}
