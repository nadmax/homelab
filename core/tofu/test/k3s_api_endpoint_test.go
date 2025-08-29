//go:build endpoint

package test

import (
	"crypto/tls"
	"net/http"
	"testing"
	"time"

	tofu "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestK3sAPIEndpoint(t *testing.T) {
	t.Parallel()

	tofuOptions := tofu.WithDefaultRetryableErrors(t, &tofu.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"k3s_external_port": 16443,
		},
		NoColor: true,
	})

	defer tofu.Destroy(t, tofuOptions)
	tofu.InitAndApply(t, tofuOptions)

	apiURL := "https://localhost:16443/version"
	maxRetries := 30
	retryDelay := 2 * time.Second

	for i := range maxRetries {
		client := &http.Client{
			Timeout: 5 * time.Second,
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
			},
		}

		resp, err := client.Get(apiURL)
		if err == nil && resp.StatusCode == http.StatusUnauthorized {
			t.Logf("Kubernetes API is accessible at %s (got expected 401)", apiURL)
			resp.Body.Close()

			return
		}

		if err != nil {
			t.Logf("Attempt %d/%d: API not accessible yet: %v", i+1, maxRetries, err)
		} else {
			t.Logf("Attempt %d/%d: Got status %d", i+1, maxRetries, resp.StatusCode)
			resp.Body.Close()
		}

		if i < maxRetries-1 {
			time.Sleep(retryDelay)
		}
	}
}
