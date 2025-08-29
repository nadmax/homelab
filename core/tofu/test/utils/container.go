package utils

import "os/exec"

func CleanupContainer(containerName string) {
	stopCmd := exec.Command("docker", "stop", containerName)
	stopCmd.Run()

	rmCmd := exec.Command("docker", "rm", "-f", containerName)
	rmCmd.Run()
}
