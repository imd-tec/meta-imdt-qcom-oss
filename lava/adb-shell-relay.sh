#!/bin/sh
# Forced command for the LAVA dut-key (see authorized_keys). Relays the ssh
# session transparently through to the QCS8550 board attached to this host
# over USB/adb, so LAVA's ssh device type and one-shot `ssh ... "<cmd>"`
# invocations both work unmodified against a board with no network of its own.
#
# - A one-shot command (ssh host "cmd", scp, the ostree-deploy/ar1335-capture
#   docker jobs) arrives as $SSH_ORIGINAL_COMMAND: forward it verbatim.
# - No command (an interactive session, LAVA's persistent ssh-tests.yaml
#   shell) drops into an interactive DUT shell with a prompt containing
#   'root@', matching what ssh-tests.yaml's boot action waits for.
#
# Install on each harness host (pi-tester-3, pi-tester-6):
#   scp lava/adb-shell-relay.sh pi-tester-N:~/adb-shell-relay.sh
#   ssh pi-tester-N chmod 755 ~/adb-shell-relay.sh
#   ssh pi-tester-N 'echo "command=\"/home/pi/adb-shell-relay.sh\",no-agent-forwarding,no-X11-forwarding,no-user-rc,no-port-forwarding $(cat lava-dut-key.pub)" >> ~/.ssh/authorized_keys'
# where lava-dut-key.pub matches recipes-core/lava-ssh-keys/files/lava-dut-key.pub.
case "$SSH_ORIGINAL_COMMAND" in
    */sftp-server)
        # scp defaults to the SFTP protocol on modern OpenSSH clients: the
        # forced command becomes the *harness host's* sftp-server path, which
        # does not exist on the DUT's own rootfs. Translate to the DUT's path.
        exec adb shell /usr/libexec/sftp-server
        ;;
    "")
        exec adb shell -t "export PS1='root@dut# '; exec sh -i"
        ;;
    *)
        exec adb shell "$SSH_ORIGINAL_COMMAND"
        ;;
esac
