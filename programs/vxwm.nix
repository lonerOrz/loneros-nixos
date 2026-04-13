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
    static const char *fonts[]          = { "monospace:size=10" };
    static const char dmenufont[]       = "monospace:size=10";

    static MAYBE_CONST char normbgcolor[]           = "#222222";
    static MAYBE_CONST char normbordercolor[]       = "#444444";
    static MAYBE_CONST char normfgcolor[]           = "#bbbbbb";
    static MAYBE_CONST char selfgcolor[]            = "#eeeeee";
    static MAYBE_CONST char selbordercolor[]        = "#005577";
    static MAYBE_CONST char selbgcolor[]            = "#005577";
    static MAYBE_CONST char *colors[][3] = {
           /*               fg           bg           border   */
           [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
           [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
    };

    #define CENTER_NEW_FLOATING_WINDOWS 1
    #define NEW_FLOATING_WINDOWS_APPEAR_UNDER_CURSOR 0

    #if GAPS
    static const unsigned int gappx = 10;  // 窗口间距
    #endif

    #if BAR_HEIGHT
    static const int user_bh = 24;  // 状态栏高度
    #endif

    #if BAR_PADDING
    static const int vertpad = 10;
    static const int sidepad = 10;
    #endif

    /* tagging */
    static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

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
      /* class      instance    title       tags mask     isfloating   monitor */
      { "Gimp",     NULL,       NULL,       0,            1,           -1 },
      { "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
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
      /* symbol     arrange function */
      { "><>",      NULL },
      { "[]=",      tile },
      { "[M]",      monocle },
    };

    /* key definitions */
    #define MODKEY Mod1Mask  // 改用 Alt 键！
    #define ALTERNATE_MODKEY Mod4Mask

    #define TAGKEYS(KEY,TAG) \
      { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
      { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
      { ALTERNATE_MODKEY,             KEY,      tag,            {.ui = 1 << TAG} }, \
      { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

    #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

    /* commands */
    static char dmenumon[2] = "0";
    static const char *dmenucmd[] = { "rofi", "-show", "drun", NULL };  // 用 rofi 替代 dmenu
    static const char *termcmd[]  = { "ghostty", NULL };  // 用 ghostty 替代 st

    static const Key keys[] = {
      /* modifier                     key        function        argument */
      { MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
      { MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
      { MODKEY,                       XK_b,      togglebar,      {0} },
      { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
      { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
      { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
      { MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
      { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
      { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
      { MODKEY,                       XK_Return, zoom,           {0} },
      { MODKEY,                       XK_0,      view,           {0} },
      { MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
      { MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
      { MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
      { MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
      { MODKEY,                       XK_space,  setlayout,      {0} },
      { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
      { MODKEY,                       XK_Tab,    view,           {.ui = ~0 } },
      { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
      { MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
      { MODKEY,                       XK_period, focusmon,       {.i = +1 } },
      { MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
      { MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
      TAGKEYS(                        XK_1,                      0)
      TAGKEYS(                        XK_2,                      1)
      TAGKEYS(                        XK_3,                      2)
      TAGKEYS(                        XK_4,                      3)
      TAGKEYS(                        XK_5,                      4)
      TAGKEYS(                        XK_6,                      5)
      TAGKEYS(                        XK_7,                      6)
      TAGKEYS(                        XK_8,                      7)
      TAGKEYS(                        XK_9,                      8)
      { MODKEY|ShiftMask,             XK_q,      quit,           {0} },
    #if XRDB
      { MODKEY,                       XK_F5,     xrdb,           {.v = NULL } },
    #endif
    #if FULLSCREEN
      { MODKEY|ShiftMask,             XK_f,      togglefullscr,  {0} },
    #endif
    #if ENHANCED_TOGGLE_FLOATING
      { MODKEY,                       XK_q,      enhancedtogglefloating, {0} },
    #endif
    #if GAPS
      { MODKEY,                       XK_minus,  setgaps,        {.i = -1 } },
      { MODKEY,                       XK_equal,  setgaps,        {.i = +1 } },
      { MODKEY|ShiftMask,             XK_equal,  setgaps,        {.i = 0  } },
    #endif
    #if MOVE_RESIZE_WITH_KEYBOARD
      { MODKEY,                       XK_Down,   moveresize,     {.v = (int []){ 0, MOVE_WITH_KEYBOARD_STEP, 0, 0 }}},
      { MODKEY,                       XK_Up,     moveresize,     {.v = (int []){ 0, -MOVE_WITH_KEYBOARD_STEP, 0, 0 }}},
      { MODKEY,                       XK_Right,  moveresize,     {.v = (int []){ MOVE_WITH_KEYBOARD_STEP, 0, 0, 0 }}},
      { MODKEY,                       XK_Left,   moveresize,     {.v = (int []){ -MOVE_WITH_KEYBOARD_STEP, 0, 0, 0 }}},
      { MODKEY|ControlMask,           XK_Down,   moveresize,     {.v = (int []){ 0, 0, 0, RESIZE_WITH_KEYBOARD_STEP }}},
      { MODKEY|ControlMask,           XK_Up,     moveresize,     {.v = (int []){ 0, 0, 0, -RESIZE_WITH_KEYBOARD_STEP }}},
      { MODKEY|ControlMask,           XK_Right,  moveresize,     {.v = (int []){ 0, 0, RESIZE_WITH_KEYBOARD_STEP, 0 }}},
      { MODKEY|ControlMask,           XK_Left,   moveresize,     {.v = (int []){ 0, 0, -RESIZE_WITH_KEYBOARD_STEP, 0 }}},
    #endif
    #if INFINITE_TAGS
      { MODKEY,                       XK_r,      homecanvas,     {0} },
      { MODKEY|ShiftMask,             XK_Left,   movecanvas,     {.i = 0} },
      { MODKEY|ShiftMask,             XK_Right,  movecanvas,     {.i = 1} },
      { MODKEY|ShiftMask,             XK_Up,     movecanvas,     {.i = 2} },
      { MODKEY|ShiftMask,             XK_Down,   movecanvas,     {.i = 3} },
      { MODKEY|ShiftMask,             XK_d,      centerwindow,   {0} },
    #endif
    #if DIRECTIONAL_FOCUS
      { ALTERNATE_MODKEY,             XK_Left,   focusdir,       {.i = 0 } },
      { ALTERNATE_MODKEY,             XK_Right,  focusdir,       {.i = 1 } },
      { ALTERNATE_MODKEY,             XK_Up,     focusdir,       {.i = 2 } },
      { ALTERNATE_MODKEY,             XK_Down,   focusdir,       {.i = 3 } },
    #endif
    };

    /* button definitions */
    static const Button buttons[] = {
      /* click                event mask      button          function        argument */
    #if INFINITE_TAGS
      { ClkRootWin,      MODKEY|ShiftMask,         Button1,        movecanvasmouse,     {.f = 1.5 } },
      { ClkClientWin,    MODKEY|ShiftMask,         Button1,        movecanvasmouse,     {.f = 1.5 } },
    #endif
      { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
      { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
      { ClkWinTitle,          0,              Button2,        zoom,           {0} },
      { ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
      { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
      { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
      { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
      { ClkTagBar,            0,              Button1,        view,           {0} },
      { ClkTagBar,            0,              Button3,        toggleview,     {0} },
      { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
      { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
    };
  '';

  # === 2. 自定义 modules.def.h（通过 patch 方式修改） ===
  # 如果你想关闭某些模块，可以用 sed 在 postPatch 里处理
  disableModulesPatch = ''
    # 示例：关闭自动启动模块
    sed -i 's/#define AUTOSTART 1/#define AUTOSTART 0/' modules.def.h

    # 示例：关闭光标扭曲模块
    sed -i 's/#define WARP_TO_CLIENT 1/#define WARP_TO_CLIENT 0/' modules.def.h
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

    # 使用 NVIDIA 驱动
    videoDrivers = [ "nvidia" ];

    # 核心：强制合成管线（解决拖影/撕裂关键）
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
