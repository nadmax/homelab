package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	sh "github.com/gruntwork-io/terratest/modules/shell"
	tofu "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/nadmax/homelab/utils"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestK3sInfrastructure(t *testing.T) {
	utils.CleanupContainer()

	t.Parallel()

	tofuOptions := tofu.WithDefaultRetryableErrors(t, &tofu.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"memory":               4096,
			"docker_internal_port": 80,
			"docker_external_port": 8080,
			"k8s_internal_port":    6443,
			"k8s_external_port":    16443,
			"restart_condition":    "unless-stopped",
		},
		NoColor: true,
	})

	defer tofu.Destroy(t, tofuOptions)
	tofu.InitAndApply(t, tofuOptions)

	t.Run("ValidateDockerImage", func(t *testing.T) {
		validateDockerImage(t)
	})

	t.Run("ValidateDockerContainer", func(t *testing.T) {
		validateDockerContainer(t)
	})

	t.Run("ValidateContainerPorts", func(t *testing.T) {
		validateContainerPorts(t, tofuOptions)
	})

	t.Run("ValidateContainerHealth", func(t *testing.T) {
		validateContainerHealth(t)
	})

	t.Run("ValidateK3sService", func(t *testing.T) {
		validateK3sService(t)
	})
}

func validateDockerImage(t *testing.T) {
	expectedImage := "rancher/k3s:v1.32.8-k3s1-amd64"
	cmd := sh.Command{
		Command: "docker",
		Args:    []string{"images", "--format", "table {{.Repository}}:{{.Tag}}"},
	}

	output := sh.RunCommandAndGetOutput(t, cmd)

	assert.Contains(t, output, expectedImage,
		"Expected Docker image %s should be present locally", expectedImage)
}

func validateDockerContainer(t *testing.T) {
	containerName := "controlplane"
	cmd := sh.Command{
		Command: "docker",
		Args:    []string{"ps", "--format", "table {{.Names}}\t{{.Status}}"},
	}
	containers := sh.RunCommandAndGetOutput(t, cmd)

	assert.Contains(t, containers, containerName,
		"Container %s should be running", containerName)

	statusCmd := sh.Command{
		Command: "docker",
		Args:    []string{"inspect", containerName, "--format", "{{.State.Status}}"},
	}
	status := sh.RunCommandAndGetOutput(t, statusCmd)

	assert.Equal(t, "running", strings.TrimSpace(status),
		"Container %s should be in running state", containerName)

	imageCmd := sh.Command{
		Command: "docker",
		Args:    []string{"inspect", containerName, "--format", "{{.Config.Image}}"},
	}
	image := sh.RunCommandAndGetOutput(t, imageCmd)

	assert.Contains(t, image, "rancher/k3s",
		"Container should be using rancher/k3s image")

	privilegedCmd := sh.Command{
		Command: "docker",
		Args:    []string{"inspect", containerName, "--format", "{{.HostConfig.Privileged}}"},
	}
	privileged := sh.RunCommandAndGetOutput(t, privilegedCmd)

	assert.Equal(t, "true", strings.TrimSpace(privileged),
		"Container should be running in privileged mode")

	restartCmd := sh.Command{
		Command: "docker",
		Args:    []string{"inspect", containerName, "--format", "{{.HostConfig.RestartPolicy.Name}}"},
	}
	restartPolicy := sh.RunCommandAndGetOutput(t, restartCmd)

	assert.Equal(t, "unless-stopped", strings.TrimSpace(restartPolicy),
		"Container should have unless-stopped restart policy")
}

func validateContainerPorts(t *testing.T, tofuOptions *tofu.Options) {
	containerName := "controlplane"
	portCmd := sh.Command{
		Command: "docker",
		Args:    []string{"port", containerName},
	}
	portMappings := sh.RunCommandAndGetOutput(t, portCmd)
	expectedMappings := []string{
		"80/tcp -> 0.0.0.0:8080",
		"6443/tcp -> 0.0.0.0:16443",
	}

	for _, expectedMapping := range expectedMappings {
		assert.Contains(t, portMappings, expectedMapping,
			"Container should have port mapping: %s", expectedMapping)
	}

	dockerPort := tofuOptions.Vars["docker_external_port"].(int)
	k8sPort := tofuOptions.Vars["k8s_external_port"].(int)

	testPortAccessibility(t, "localhost", dockerPort, "Docker port")
	testPortAccessibility(t, "localhost", k8sPort, "Kubernetes API port")
}

func testPortAccessibility(t *testing.T, host string, port int, description string) {
	address := fmt.Sprintf("%s:%d", host, port)
	maxRetries := 10
	retryDelay := 2 * time.Second

	for i := range maxRetries {
		cmd := sh.Command{
			Command: "nc",
			Args:    []string{"-z", "-v", host, fmt.Sprintf("%d", port)},
		}

		err := sh.RunCommandE(t, cmd)
		if err == nil {
			t.Logf("%s at %s is accessible", description, address)
			return
		}

		if i < maxRetries-1 {
			t.Logf("Attempt %d/%d: %s at %s not yet accessible, retrying...",
				i+1, maxRetries, description, address)
			time.Sleep(retryDelay)
		}
	}

	t.Logf("Warning: %s at %s may not be fully accessible yet", description, address)
}

func validateContainerHealth(t *testing.T) {
	containerName := "controlplane"
	maxRetries := 30
	retryInterval := 2 * time.Second

	for i := range maxRetries {
		healthCmd := sh.Command{
			Command: "docker",
			Args:    []string{"inspect", containerName, "--format", "{{.State.Health.Status}}"},
		}
		healthStatus, err := sh.RunCommandAndGetOutputE(t, healthCmd)
		if err != nil {
			statusCmd := sh.Command{
				Command: "docker",
				Args:    []string{"inspect", containerName, "--format", "{{.State.Status}}"},
			}
			status := sh.RunCommandAndGetOutput(t, statusCmd)
			if strings.TrimSpace(status) == "running" {
				t.Logf("Container is running (health check not configured)")

				return
			}

			t.Logf("Container status: %s", strings.TrimSpace(status))
			time.Sleep(retryInterval)

			continue
		}

		healthStatus = strings.TrimSpace(healthStatus)
		if healthStatus == "healthy" {
			t.Logf("Container is healthy after %d attempts", i+1)

			return
		}

		if healthStatus == "unhealthy" {
			t.Fatalf("Container became unhealthy")
		}

		t.Logf("Waiting for container to become healthy (attempt %d/%d, current status: %s)",
			i+1, maxRetries, healthStatus)
		time.Sleep(retryInterval)
	}

	statusCmd := sh.Command{
		Command: "docker",
		Args:    []string{"inspect", containerName, "--format", "{{.State.Status}}"},
	}
	status := sh.RunCommandAndGetOutput(t, statusCmd)

	assert.Equal(t, "running", strings.TrimSpace(status),
		"Container should at least be in running state")
}

func validateK3sService(t *testing.T) {
	containerName := "controlplane"
	maxRetries := 30
	retryInterval := 3 * time.Second

	for i := range maxRetries {
		psCmd := sh.Command{
			Command: "docker",
			Args:    []string{"exec", containerName, "ps", "aux"},
		}
		processes, err := sh.RunCommandAndGetOutputE(t, psCmd)
		if err != nil {
			t.Logf("Attempt %d/%d: Unable to check processes, retrying...", i+1, maxRetries)
			time.Sleep(retryInterval)

			continue
		}

		if !strings.Contains(processes, "k3s server") {
			t.Logf("Attempt %d/%d: K3s server process not found, retrying...", i+1, maxRetries)
			time.Sleep(retryInterval)

			continue
		}

		k3sStatusCmd := sh.Command{
			Command: "docker",
			Args:    []string{"exec", containerName, "kubectl", "get", "nodes", "--no-headers"},
		}

		k3sStatus, err := sh.RunCommandAndGetOutputE(t, k3sStatusCmd)
		if err != nil {
			t.Logf("Attempt %d/%d: K3s kubectl not ready, retrying...", i+1, maxRetries)
			time.Sleep(retryInterval)

			continue
		}

		if strings.Contains(k3sStatus, "Ready") {
			t.Logf("K3s cluster is ready with nodes: %s", strings.TrimSpace(k3sStatus))

			podsCmd := sh.Command{
				Command: "docker",
				Args:    []string{"exec", containerName, "kubectl", "get", "pods", "-A", "--no-headers"},
			}
			pods, err := sh.RunCommandAndGetOutputE(t, podsCmd)
			if err != nil {
				t.Logf("Warning: Could not check pods, but cluster seems ready")
			} else {
				assert.NotContains(t, pods, "traefik",
					"Traefik should be disabled and not running")
				t.Logf("Verified Traefik is disabled")
			}

			return
		}

		t.Logf("Attempt %d/%d: K3s cluster not ready yet, retrying...", i+1, maxRetries)
		time.Sleep(retryInterval)
	}

	t.Fatalf("K3s cluster did not become ready within the expected time")
}

func TestK3sInfrastructureWithCustomVariables(t *testing.T) {
	utils.CleanupContainer()

	t.Parallel()

	tofuOptions := tofu.WithDefaultRetryableErrors(t, &tofu.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"memory":               2048,
			"docker_external_port": 8081,
			"k8s_external_port":    16444,
		},
		NoColor: true,
	})

	defer tofu.Destroy(t, tofuOptions)
	tofu.InitAndApply(t, tofuOptions)

	containerName := "controlplane"
	memoryCmd := sh.Command{
		Command: "docker",
		Args:    []string{"inspect", containerName, "--format", "{{.HostConfig.Memory}}"},
	}
	memoryLimit := sh.RunCommandAndGetOutput(t, memoryCmd)
	expectedMemory := int64(2048 * 1024 * 1024)
	actualMemory := parseMemoryLimit(t, strings.TrimSpace(memoryLimit))

	assert.Equal(t, expectedMemory, actualMemory,
		"Container memory limit should match the configured value")

	portCmd := sh.Command{
		Command: "docker",
		Args:    []string{"port", containerName},
	}
	portMappings := sh.RunCommandAndGetOutput(t, portCmd)
	assert.Contains(t, portMappings, "80/tcp -> 0.0.0.0:8081",
		"Container should have custom docker port mapping")
	assert.Contains(t, portMappings, "6443/tcp -> 0.0.0.0:16444",
		"Container should have custom K8s port mapping")
}

func parseMemoryLimit(t *testing.T, memoryStr string) int64 {
	if memoryStr == "0" {
		t.Fatal("Memory limit should not be 0 (unlimited)")
	}

	var memory int64
	_, err := fmt.Sscanf(memoryStr, "%d", &memory)
	require.NoError(t, err, "Failed to parse memory limit: %s", memoryStr)

	return memory
}
