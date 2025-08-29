package utils

import "os/exec"

func CleanupContainer() {
	stopCmd := exec.Command("docker", "stop", "controlplane")
	stopCmd.Run()

	rmCmd := exec.Command("docker", "rm", "-f", "controlplane")
	rmCmd.Run()
}
