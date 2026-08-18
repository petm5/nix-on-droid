# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ pkgs, crossPkgs }:

let

  crossPkgsStatic = crossPkgs.pkgsStatic.pkgsLLVM.extend (self: super: {
    musl = super.musl.overrideAttrs (prev: {
      preConfigure = ''
        for sys in _sysctl access afs_syscall alarm arch_prctl chmod chown creat create_module dup2 epoll_create epoll_ctl_old epoll_wait epoll_wait_old eventfd fork futimesat get_kernel_syms get_thread_area getdents getpgrp getpmsg inotify_init ioperm iopl lchown link lstat mkdir mknod modify_ldt open pause pipe poll putpmsg query_module readlink rename rmdir security select set_thread_area signalfd stat symlink sysfs time tuxcall unlink uprobe uretprobe uselib ustat utime utimes vfork vserver; do
          echo "#undef __NR_$sys" >> arch/x86_64/bits/syscall.h.in
        done
      '';
    });

    talloc = crossPkgsStatic.callPackage ./talloc { };

    prootTermux = crossPkgsStatic.callPackage ./proot-termux { };
  });

in

{
  inherit (crossPkgsStatic) talloc prootTermux;
  streamZip = pkgs.callPackage ./stream-zip.nix { };
}
