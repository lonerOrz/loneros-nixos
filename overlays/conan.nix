self: super: {
  conan = super.conan.overrideAttrs (oldAttrs: {
    disabledTestPaths = (oldAttrs.disabledTestPaths or [ ]) ++ [
      "test/functional/tools/system/pip_manager_test.py"
    ];
  });
}
