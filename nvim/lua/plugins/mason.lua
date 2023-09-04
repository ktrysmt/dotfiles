return {
  'williamboman/mason.nvim',
  cmd = {
    "Mason",
    "MasonInstall",
    "MasonUninstall",
    "MasonUninstallAll",
    "MasonLog",
    "MasonUpdate",
  },
  opts = {
    ui = {
      check_outdated_packages_on_open = true,
      icons = {
        package_installed = "✓",
        package_uninstalled = "✗",
        package_pending = "⟳",
      },
    },
  },
  build = ":MasonUpdate",
}
